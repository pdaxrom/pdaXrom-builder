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
ifdef PTXCONF_APACHE
PACKAGES += apache
endif

#
# Paths and names
#
APACHE_VERSION		= 2.0.52
APACHE			= httpd-$(APACHE_VERSION)
APACHE_SUFFIX		= tar.bz2
APACHE_URL		= http://www.sai.msu.su/apache/dist/httpd/$(APACHE).$(APACHE_SUFFIX)
APACHE_SOURCE		= $(SRCDIR)/$(APACHE).$(APACHE_SUFFIX)
APACHE_DIR		= $(BUILDDIR)/$(APACHE)
APACHE_IPKG_TMP		= $(APACHE_DIR)/ipkg_tmp

# ----------------------------------------------------------------------------
# Get
# ----------------------------------------------------------------------------

apache_get: $(STATEDIR)/apache.get

apache_get_deps = $(APACHE_SOURCE)

$(STATEDIR)/apache.get: $(apache_get_deps)
	@$(call targetinfo, $@)
	@$(call get_patches, $(APACHE))
	touch $@

$(APACHE_SOURCE):
	@$(call targetinfo, $@)
	@$(call get, $(APACHE_URL))

# ----------------------------------------------------------------------------
# Extract
# ----------------------------------------------------------------------------

apache_extract: $(STATEDIR)/apache.extract

apache_extract_deps = $(STATEDIR)/apache.get

$(STATEDIR)/apache.extract: $(apache_extract_deps)
	@$(call targetinfo, $@)
	@$(call clean, $(APACHE_DIR))
	@$(call extract, $(APACHE_SOURCE))
	@$(call patchin, $(APACHE))
	touch $@

# ----------------------------------------------------------------------------
# Prepare
# ----------------------------------------------------------------------------

apache_prepare: $(STATEDIR)/apache.prepare

#
# dependencies
#
apache_prepare_deps = \
	$(STATEDIR)/apache.extract \
	$(STATEDIR)/expat.install \
	$(STATEDIR)/openssl.install \
	$(STATEDIR)/gdbm.install \
	$(STATEDIR)/virtual-xchain.install

ifdef PTXCONF_LIBICONV
apache_prepare_deps += $(STATEDIR)/libiconv.install
endif

APACHE_PATH	=  PATH=$(CROSS_PATH)
APACHE_ENV 	=  $(CROSS_ENV)
APACHE_ENV	+= CFLAGS="$(TARGET_OPT_CFLAGS)"
APACHE_ENV	+= CXXFLAGS="$(TARGET_OPT_CFLAGS)"
APACHE_ENV	+= PKG_CONFIG_PATH=$(CROSS_LIB_DIR)/lib/pkgconfig:$(CROSS_LIB_DIR)/lib/pkgconfig
#ifdef PTXCONF_XFREE430
#APACHE_ENV	+= LDFLAGS=-Wl,-rpath-link,$(CROSS_LIB_DIR)/lib
#endif

#
# autoconf
#
APACHE_AUTOCONF = \
	--build=$(GNU_HOST) \
	--host=$(PTXCONF_GNU_TARGET) \
	--prefix=/usr/local/apache \
	--sysconfdir=/etc/apache \
	--localstatedir=/var \
	--enable-ssl \
	--with-ssl=$(CROSS_LIB_DIR) \
	--enable-dav \
	--enable-dav-fs \
	--with-dbm=sdbm \
	--with-berkeley-db=no \
	--with-gdbm=no \
	--with-ndbm=no \
	--enable-shared \
	--disable-static \
	--enable-so

###	--libexecdir=/usr/sbin

ifdef PTXCONF_XFREE430
APACHE_AUTOCONF += --x-includes=$(CROSS_LIB_DIR)/include
APACHE_AUTOCONF += --x-libraries=$(CROSS_LIB_DIR)/lib
endif

$(STATEDIR)/apache.prepare: $(apache_prepare_deps)
	@$(call targetinfo, $@)
	@$(call clean, $(APACHE_DIR)/config.cache)
	cd $(APACHE_DIR) && \
		$(APACHE_PATH) $(APACHE_ENV) \
		./configure $(APACHE_AUTOCONF)
	cp -f $(PTXCONF_PREFIX)/bin/libtool $(APACHE_DIR)/
	cp -f $(PTXCONF_PREFIX)/bin/libtool $(APACHE_DIR)/srclib/apr/
	touch $@

# ----------------------------------------------------------------------------
# Compile
# ----------------------------------------------------------------------------

apache_compile: $(STATEDIR)/apache.compile

apache_compile_deps = $(STATEDIR)/apache.prepare

$(STATEDIR)/apache.compile: $(apache_compile_deps)
	@$(call targetinfo, $@)
	$(APACHE_PATH) $(MAKE) -C $(APACHE_DIR)
	touch $@

# ----------------------------------------------------------------------------
# Install
# ----------------------------------------------------------------------------

apache_install: $(STATEDIR)/apache.install

$(STATEDIR)/apache.install: $(STATEDIR)/apache.compile
	@$(call targetinfo, $@)
	$(APACHE_PATH) $(MAKE) -C $(APACHE_DIR) DESTDIR=$(APACHE_IPKG_TMP) install
	perl -i -p -e "s,\/usr/local/apache,$(APACHE_IPKG_TMP)/usr/local/apache,g" $(APACHE_IPKG_TMP)/usr/local/apache/bin/apu-config
	perl -i -p -e "s,\/usr/local/apache,$(APACHE_IPKG_TMP)/usr/local/apache,g" $(APACHE_IPKG_TMP)/usr/local/apache/bin/apr-config
	perl -i -p -e "s,\/usr/local/apache,$(APACHE_IPKG_TMP)/usr/local/apache,g" $(APACHE_IPKG_TMP)/usr/local/apache/bin/apxs
	perl -i -p -e "s,\/usr/local/apache,$(APACHE_IPKG_TMP)/usr/local/apache,g" $(APACHE_IPKG_TMP)/usr/local/apache/build/config_vars.mk
	#rm -rf $(APACHE_IPKG_TMP)
	touch $@

# ----------------------------------------------------------------------------
# Target-Install
# ----------------------------------------------------------------------------

apache_targetinstall: $(STATEDIR)/apache.targetinstall

apache_targetinstall_deps = $(STATEDIR)/apache.compile \
	$(STATEDIR)/expat.targetinstall \
	$(STATEDIR)/openssl.targetinstall \
	$(STATEDIR)/gdbm.targetinstall

ifdef PTXCONF_LIBICONV
apache_targetinstall_deps += $(STATEDIR)/libiconv.targetinstall
endif

$(STATEDIR)/apache.targetinstall: $(apache_targetinstall_deps)
	@$(call targetinfo, $@)
	rm -rf $(APACHE_IPKG_TMP)
	$(APACHE_PATH) $(MAKE) -C $(APACHE_DIR) DESTDIR=$(APACHE_IPKG_TMP) install
	###rm -rf $(APACHE_IPKG_TMP)/usr/local/apache/build
	rm -rf $(APACHE_IPKG_TMP)/usr/local/apache/include
	rm -rf $(APACHE_IPKG_TMP)/usr/local/apache/lib/*.*a
	rm -rf $(APACHE_IPKG_TMP)/usr/local/apache/man
	rm -rf $(APACHE_IPKG_TMP)/usr/local/apache/manual
	###rm -rf $(APACHE_IPKG_TMP)/usr/local/apache/bin/*-config
	for FILE in `find $(APACHE_IPKG_TMP)/usr/ -type f`; do		\
	    ZZZ=`file $$FILE | grep 'ELF 32-bit'`;			\
	    if [  "$$ZZZ" != "" ]; then					\
		$(CROSSSTRIP) $$FILE;					\
	    fi;								\
	done
	mkdir -p $(APACHE_IPKG_TMP)/etc/rc.d/init.d
	mkdir -p $(APACHE_IPKG_TMP)/etc/rc.d/rc0.d
	mkdir -p $(APACHE_IPKG_TMP)/etc/rc.d/rc1.d
	mkdir -p $(APACHE_IPKG_TMP)/etc/rc.d/rc2.d
	mkdir -p $(APACHE_IPKG_TMP)/etc/rc.d/rc3.d
	mkdir -p $(APACHE_IPKG_TMP)/etc/rc.d/rc4.d
	mkdir -p $(APACHE_IPKG_TMP)/etc/rc.d/rc5.d
	mkdir -p $(APACHE_IPKG_TMP)/etc/rc.d/rc6.d

	ln -sf /usr/local/apache/bin/apachectl $(APACHE_IPKG_TMP)/etc/rc.d/init.d/apachectl
	ln -sf ../init.d/apachectl $(APACHE_IPKG_TMP)/etc/rc.d/rc0.d/K50apachectl
	ln -sf ../init.d/apachectl $(APACHE_IPKG_TMP)/etc/rc.d/rc1.d/K50apachectl
	ln -sf ../init.d/apachectl $(APACHE_IPKG_TMP)/etc/rc.d/rc3.d/S50apachectl
	ln -sf ../init.d/apachectl $(APACHE_IPKG_TMP)/etc/rc.d/rc4.d/S50apachectl
	ln -sf ../init.d/apachectl $(APACHE_IPKG_TMP)/etc/rc.d/rc5.d/S50apachectl
	ln -sf ../init.d/apachectl $(APACHE_IPKG_TMP)/etc/rc.d/rc6.d/K50apachectl

	mkdir -p $(APACHE_IPKG_TMP)/CONTROL
	echo "Package: apache2" 							>$(APACHE_IPKG_TMP)/CONTROL/control
	echo "Priority: optional" 							>>$(APACHE_IPKG_TMP)/CONTROL/control
	echo "Section: Network" 							>>$(APACHE_IPKG_TMP)/CONTROL/control
	echo "Maintainer: Alexander Chukov <sash@pdaXrom.org>" 				>>$(APACHE_IPKG_TMP)/CONTROL/control
	echo "Architecture: $(SHORT_TARGET)" 						>>$(APACHE_IPKG_TMP)/CONTROL/control
	echo "Version: $(APACHE_VERSION)" 						>>$(APACHE_IPKG_TMP)/CONTROL/control
ifdef PTXCONF_LIBICONV
	echo "Depends: libiconv, expat, openssl" 					>>$(APACHE_IPKG_TMP)/CONTROL/control
else
	echo "Depends: expat, openssl" 							>>$(APACHE_IPKG_TMP)/CONTROL/control
endif
	echo "Description: Apache - popular web server"					>>$(APACHE_IPKG_TMP)/CONTROL/control

	echo "#!/bin/sh"								 >$(APACHE_IPKG_TMP)/CONTROL/postinst
	echo "/etc/rc.d/init.d/apachectl start"						>>$(APACHE_IPKG_TMP)/CONTROL/postinst

	echo "#!/bin/sh"								 >$(APACHE_IPKG_TMP)/CONTROL/prerm
	echo "/etc/rc.d/init.d/apachectl stop"						>>$(APACHE_IPKG_TMP)/CONTROL/prerm

	chmod 755 $(APACHE_IPKG_TMP)/CONTROL/prerm $(APACHE_IPKG_TMP)/CONTROL/postinst

	cd $(FEEDDIR) && $(XMKIPKG) $(APACHE_IPKG_TMP)
	touch $@

# ----------------------------------------------------------------------------
# Image-Install
# ----------------------------------------------------------------------------

ifdef PTXCONF_APACHE_INSTALL
ROMPACKAGES += $(STATEDIR)/apache.imageinstall
endif

apache_imageinstall_deps = $(STATEDIR)/apache.targetinstall \
	$(STATEDIR)/virtual-image.install

$(STATEDIR)/apache.imageinstall: $(apache_imageinstall_deps)
	@$(call targetinfo, $@)
	cd $(FEEDDIR) && $(XIPKG) install apache2
	touch $@

# ----------------------------------------------------------------------------
# Clean
# ----------------------------------------------------------------------------

apache_clean:
	rm -rf $(STATEDIR)/apache.*
	rm -rf $(APACHE_DIR)

# vim: syntax=make
