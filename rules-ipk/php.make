# -*-makefile-*-
# $Id: template,v 1.10 2004/01/24 15:50:34 mkl Exp $
#
# Copyright (C) 2004 by Alexander Chukov <sash@pdaXrom.org>
#          
# See CREDITS for details about who has contributed to this project.
#
# For further information about the PTXdist project and license conditions
# see the README file.
#

#
# We provide this package
#
ifdef PTXCONF_PHP
PACKAGES += php
endif

#
# Paths and names
#
PHP_VERSION	= 4.3.9
PHP		= php-$(PHP_VERSION)
PHP_SUFFIX	= tar.bz2
PHP_URL		= http://de3.php.net/distributions/$(PHP).$(PHP_SUFFIX)
PHP_SOURCE	= $(SRCDIR)/$(PHP).$(PHP_SUFFIX)
PHP_DIR		= $(BUILDDIR)/$(PHP)
PHP_IPKG_TMP	= $(PHP_DIR)/ipkg_tmp

# ----------------------------------------------------------------------------
# Get
# ----------------------------------------------------------------------------

php_get: $(STATEDIR)/php.get

php_get_deps = $(PHP_SOURCE)

$(STATEDIR)/php.get: $(php_get_deps)
	@$(call targetinfo, $@)
	@$(call get_patches, $(PHP))
	touch $@

$(PHP_SOURCE):
	@$(call targetinfo, $@)
	@$(call get, $(PHP_URL))

# ----------------------------------------------------------------------------
# Extract
# ----------------------------------------------------------------------------

php_extract: $(STATEDIR)/php.extract

php_extract_deps = $(STATEDIR)/php.get

$(STATEDIR)/php.extract: $(php_extract_deps)
	@$(call targetinfo, $@)
	@$(call clean, $(PHP_DIR))
	@$(call extract, $(PHP_SOURCE))
	@$(call patchin, $(PHP))
	touch $@

# ----------------------------------------------------------------------------
# Prepare
# ----------------------------------------------------------------------------

php_prepare: $(STATEDIR)/php.prepare

#
# dependencies
#
php_prepare_deps = \
	$(STATEDIR)/php.extract \
	$(STATEDIR)/mysql.install \
	$(STATEDIR)/apache.install \
	$(STATEDIR)/virtual-xchain.install

PHP_PATH	=  PATH=$(CROSS_PATH)
PHP_ENV 	=  $(CROSS_ENV)
PHP_ENV		+= CFLAGS="$(TARGET_OPT_CFLAGS)"
PHP_ENV		+= CXXFLAGS="$(TARGET_OPT_CFLAGS)"
PHP_ENV		+= PKG_CONFIG_PATH=$(CROSS_LIB_DIR)/lib/pkgconfig:$(CROSS_LIB_DIR)/lib/pkgconfig
#ifdef PTXCONF_XFREE430
#PHP_ENV		+= LDFLAGS=-Wl,-rpath-link,$(CROSS_LIB_DIR)/lib
#endif

PHP_ENV		+= APR_BINDIR="$(APACHE_IPKG_TMP)/usr/local/apache/bin"
PHP_ENV		+= APU_BINDIR="$(APACHE_IPKG_TMP)/usr/local/apache/bin"

#
# autoconf
#
PHP_AUTOCONF = \
	--build=$(GNU_HOST) \
	--host=$(PTXCONF_GNU_TARGET) \
	--prefix=/usr \
	--with-cgi \
	--enable-sockets \
	--enable-pcntl \
        --with-mysql=$(MYSQL_IPKG_TMP)/usr \
	--with-apxs2=$(APACHE_IPKG_TMP)/usr/local/apache/bin/apxs \
        --with-zlib \
	--with-zlib-dir=$(CROSS_LIB_DIR) \
        --with-config-file-path=/etc/php4 \
	--without-pear

#       --without-libpng
#	--without-libjpeg

ifdef PTXCONF_XFREE430
PHP_AUTOCONF += --x-includes=$(CROSS_LIB_DIR)/include
PHP_AUTOCONF += --x-libraries=$(CROSS_LIB_DIR)/lib
endif

$(STATEDIR)/php.prepare: $(php_prepare_deps)
	@$(call targetinfo, $@)
	@$(call clean, $(PHP_DIR)/config.cache)
	cd $(PHP_DIR) && \
		$(PHP_PATH) $(PHP_ENV) \
		./configure $(PHP_AUTOCONF)
	touch $@

# ----------------------------------------------------------------------------
# Compile
# ----------------------------------------------------------------------------

php_compile: $(STATEDIR)/php.compile

php_compile_deps = $(STATEDIR)/php.prepare

$(STATEDIR)/php.compile: $(php_compile_deps)
	@$(call targetinfo, $@)
	$(PHP_PATH) $(MAKE) -C $(PHP_DIR)
	touch $@

# ----------------------------------------------------------------------------
# Install
# ----------------------------------------------------------------------------

php_install: $(STATEDIR)/php.install

$(STATEDIR)/php.install: $(STATEDIR)/php.compile
	@$(call targetinfo, $@)
	$(PHP_PATH) $(MAKE) -C $(PHP_DIR) install
	touch $@

# ----------------------------------------------------------------------------
# Target-Install
# ----------------------------------------------------------------------------

php_targetinstall: $(STATEDIR)/php.targetinstall

php_targetinstall_deps = $(STATEDIR)/php.compile

$(STATEDIR)/php.targetinstall: $(php_targetinstall_deps)
	@$(call targetinfo, $@)
	rm -rf $(PHP_IPKG_TMP)
	###$(PHP_PATH) $(MAKE) -C $(PHP_DIR) INSTALL_ROOT=$(PHP_IPKG_TMP) install
	mkdir -p $(PHP_IPKG_TMP)/usr/local/apache/modules
	$(INSTALL) -m 755 $(PHP_DIR)/.libs/libphp4.so $(PHP_IPKG_TMP)/usr/local/apache/modules/
	$(CROSSSTRIP) $(PHP_IPKG_TMP)/usr/local/apache/modules/*
	mkdir -p $(PHP_IPKG_TMP)/CONTROL
	echo "Package: apache2-php-module" 						>$(PHP_IPKG_TMP)/CONTROL/control
	echo "Priority: optional" 							>>$(PHP_IPKG_TMP)/CONTROL/control
	echo "Section: Network" 							>>$(PHP_IPKG_TMP)/CONTROL/control
	echo "Maintainer: Alexander Chukov <sash@pdaXrom.org>" 				>>$(PHP_IPKG_TMP)/CONTROL/control
	echo "Architecture: $(SHORT_TARGET)" 						>>$(PHP_IPKG_TMP)/CONTROL/control
	echo "Version: $(PHP_VERSION)" 							>>$(PHP_IPKG_TMP)/CONTROL/control
	echo "Depends: mysql, apache2" 							>>$(PHP_IPKG_TMP)/CONTROL/control
	echo "Description: php4 apache2 module"						>>$(PHP_IPKG_TMP)/CONTROL/control

	echo "#!/bin/sh"								 >$(PHP_IPKG_TMP)/CONTROL/postinst
	echo "cat /etc/apache/httpd.conf | sed 's/#LoadModule php4_module/LoadModule php4_module/' > /etc/apache/httpd_php4.conf" >>$(PHP_IPKG_TMP)/CONTROL/postinst
	echo "rm -f /etc/apache/httpd.conf"						>>$(PHP_IPKG_TMP)/CONTROL/postinst
	echo "mv /etc/apache/httpd_php4.conf /etc/apache/httpd.conf"			>>$(PHP_IPKG_TMP)/CONTROL/postinst
	echo "/etc/rc.d/init.d/apachectl restart"					>>$(PHP_IPKG_TMP)/CONTROL/postinst

	echo "#!/bin/sh"								 >$(PHP_IPKG_TMP)/CONTROL/prerm
	echo "cat /etc/apache/httpd.conf | sed 's/LoadModule php4_module/#LoadModule php4_module/' > /etc/apache/httpd_php4.conf" >>$(PHP_IPKG_TMP)/CONTROL/prerm
	echo "rm -f /etc/apache/httpd.conf"						>>$(PHP_IPKG_TMP)/CONTROL/prerm
	echo "mv /etc/apache/httpd_php4.conf /etc/apache/httpd.conf"			>>$(PHP_IPKG_TMP)/CONTROL/prerm
	echo "/etc/rc.d/init.d/apachectl restart"					>>$(PHP_IPKG_TMP)/CONTROL/prerm

	chmod 755 $(PHP_IPKG_TMP)/CONTROL/postinst $(PHP_IPKG_TMP)/CONTROL/prerm

	cd $(FEEDDIR) && $(XMKIPKG) $(PHP_IPKG_TMP)

	#mkdir -p $(PHP_IPKG_TMP)/CONTROL
	#echo "Package: php" 								>$(PHP_IPKG_TMP)/CONTROL/control
	#echo "Priority: optional" 							>>$(PHP_IPKG_TMP)/CONTROL/control
	#echo "Section: Development" 							>>$(PHP_IPKG_TMP)/CONTROL/control
	#echo "Maintainer: Alexander Chukov <sash@pdaXrom.org>" 				>>$(PHP_IPKG_TMP)/CONTROL/control
	#echo "Architecture: $(SHORT_TARGET)" 						>>$(PHP_IPKG_TMP)/CONTROL/control
	#echo "Version: $(PHP_VERSION)" 							>>$(PHP_IPKG_TMP)/CONTROL/control
	#echo "Depends: " 								>>$(PHP_IPKG_TMP)/CONTROL/control
	#echo "Description: generated with pdaXrom builder"				>>$(PHP_IPKG_TMP)/CONTROL/control

	touch $@

# ----------------------------------------------------------------------------
# Image-Install
# ----------------------------------------------------------------------------

ifdef PTXCONF_PHP_INSTALL
ROMPACKAGES += $(STATEDIR)/php.imageinstall
endif

php_imageinstall_deps = $(STATEDIR)/php.targetinstall \
	$(STATEDIR)/virtual-image.install

$(STATEDIR)/php.imageinstall: $(php_imageinstall_deps)
	@$(call targetinfo, $@)
	cd $(FEEDDIR) && $(XIPKG) install apache2-php-module
	touch $@

# ----------------------------------------------------------------------------
# Clean
# ----------------------------------------------------------------------------

php_clean:
	rm -rf $(STATEDIR)/php.*
	rm -rf $(PHP_DIR)

# vim: syntax=make
