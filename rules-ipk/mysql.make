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
ifdef PTXCONF_MYSQL
PACKAGES += mysql
endif

#
# Paths and names
#
MYSQL_VERSION		= 4.1.7
MYSQL			= mysql-$(MYSQL_VERSION)
MYSQL_SUFFIX		= tar.gz
MYSQL_URL		= http://dev.mysql.com/get/Downloads/MySQL-4.1/mysql-$(MYSQL_VERSION).tar.gz/from/http://mysql.borsen.dk/
MYSQL_SOURCE		= $(SRCDIR)/$(MYSQL).$(MYSQL_SUFFIX)
MYSQL_DIR		= $(BUILDDIR)/$(MYSQL)
MYSQL_IPKG_TMP		= $(MYSQL_DIR)/ipkg_tmp

# ----------------------------------------------------------------------------
# Get
# ----------------------------------------------------------------------------

mysql_get: $(STATEDIR)/mysql.get

mysql_get_deps = $(MYSQL_SOURCE)

$(STATEDIR)/mysql.get: $(mysql_get_deps)
	@$(call targetinfo, $@)
	@$(call get_patches, $(MYSQL))
	touch $@

$(MYSQL_SOURCE):
	@$(call targetinfo, $@)
	@$(call get, $(MYSQL_URL))

# ----------------------------------------------------------------------------
# Extract
# ----------------------------------------------------------------------------

mysql_extract: $(STATEDIR)/mysql.extract

mysql_extract_deps = $(STATEDIR)/mysql.get

$(STATEDIR)/mysql.extract: $(mysql_extract_deps)
	@$(call targetinfo, $@)
	@$(call clean, $(MYSQL_DIR))
	@$(call extract, $(MYSQL_SOURCE))
	@$(call patchin, $(MYSQL))
	touch $@

# ----------------------------------------------------------------------------
# Prepare
# ----------------------------------------------------------------------------

mysql_prepare: $(STATEDIR)/mysql.prepare

#
# dependencies
#
mysql_prepare_deps = \
	$(STATEDIR)/mysql.extract \
	$(STATEDIR)/ncurses.install \
	$(STATEDIR)/xchain-mysql.compile \
	$(STATEDIR)/virtual-xchain.install

MYSQL_PATH	=  PATH=$(CROSS_PATH)
MYSQL_ENV 	=  $(CROSS_ENV)
MYSQL_ENV	+= CFLAGS="$(TARGET_OPT_CFLAGS)"
MYSQL_ENV	+= CXXFLAGS="$(TARGET_OPT_CFLAGS)"
MYSQL_ENV	+= PKG_CONFIG_PATH=$(CROSS_LIB_DIR)/lib/pkgconfig:$(CROSS_LIB_DIR)/lib/pkgconfig
#ifdef PTXCONF_XFREE430
#MYSQL_ENV	+= LDFLAGS=-Wl,-rpath-link,$(CROSS_LIB_DIR)/lib
#endif

#
# autoconf
#
MYSQL_AUTOCONF = \
	--build=$(GNU_HOST) \
	--host=$(PTXCONF_GNU_TARGET) \
	--prefix=/usr \
	--sysconfdir=/etc \
	--libexecdir=/usr/sbin \
	--localstatedir=/var/mysql \
	--with-openssl=$(CROSS_LIB_DIR) \
	--without-debug \
	--with-mysqld-user=nobody

###	--without-docs
###	--without-man
###	--without-bench
###	--enable-thread-safe-client
###	--with-pthread
###	--with-named-thread-libs=-lpthread
###	--with-zlib-dir=$(CROSS_LIB_DIR)

ifdef PTXCONF_XFREE430
MYSQL_AUTOCONF += --x-includes=$(CROSS_LIB_DIR)/include
MYSQL_AUTOCONF += --x-libraries=$(CROSS_LIB_DIR)/lib
endif

$(STATEDIR)/mysql.prepare: $(mysql_prepare_deps)
	@$(call targetinfo, $@)
	@$(call clean, $(MYSQL_DIR)/config.cache)
	perl -i -p -e "s,\@CROSS_LIB_DIR@,$(CROSS_LIB_DIR),g" $(MYSQL_DIR)/configure.in
	cd $(MYSQL_DIR) && $(MYSQL_PATH) aclocal
	cd $(MYSQL_DIR) && $(MYSQL_PATH) automake --add-missing
	cd $(MYSQL_DIR) && $(MYSQL_PATH) autoconf
	cd $(MYSQL_DIR) && \
		$(MYSQL_PATH) $(MYSQL_ENV) \
		./configure $(MYSQL_AUTOCONF)
	touch $@

# ----------------------------------------------------------------------------
# Compile
# ----------------------------------------------------------------------------

mysql_compile: $(STATEDIR)/mysql.compile

mysql_compile_deps = $(STATEDIR)/mysql.prepare

$(STATEDIR)/mysql.compile: $(mysql_compile_deps)
	@$(call targetinfo, $@)
	$(MYSQL_PATH) $(MAKE) -C $(MYSQL_DIR) GEN_LEX_HASH=$(XCHAIN_MYSQL_DIR)/sql/gen_lex_hash
	touch $@

# ----------------------------------------------------------------------------
# Install
# ----------------------------------------------------------------------------

mysql_install: $(STATEDIR)/mysql.install

$(STATEDIR)/mysql.install: $(STATEDIR)/mysql.compile
	@$(call targetinfo, $@)
	rm -rf $(MYSQL_IPKG_TMP)
	$(MYSQL_PATH) $(MAKE) -C $(MYSQL_DIR) DESTDIR=$(MYSQL_IPKG_TMP) install
	#rm -rf $(MYSQL_IPKG_TMP)
	touch $@

# ----------------------------------------------------------------------------
# Target-Install
# ----------------------------------------------------------------------------

mysql_targetinstall: $(STATEDIR)/mysql.targetinstall

mysql_targetinstall_deps = $(STATEDIR)/mysql.compile \
	$(STATEDIR)/ncurses.targetinstall

$(STATEDIR)/mysql.targetinstall: $(mysql_targetinstall_deps)
	@$(call targetinfo, $@)
	rm -rf $(MYSQL_IPKG_TMP)
	$(MYSQL_PATH) $(MAKE) -C $(MYSQL_DIR) DESTDIR=$(MYSQL_IPKG_TMP) install
	rm -rf $(MYSQL_IPKG_TMP)/usr/include
	rm -rf $(MYSQL_IPKG_TMP)/usr/info
	rm -rf $(MYSQL_IPKG_TMP)/usr/lib/mysql/*.*a
	rm -rf $(MYSQL_IPKG_TMP)/usr/man
	rm -rf $(MYSQL_IPKG_TMP)/usr/mysql-test
	rm -rf $(MYSQL_IPKG_TMP)/usr/sql-bench
	for FILE in `find $(MYSQL_IPKG_TMP)/usr/ -type f`; do		\
	    ZZZ=`file $$FILE | grep 'ELF 32-bit'`;			\
	    if [  "$$ZZZ" != "" ]; then					\
		$(CROSSSTRIP) $$FILE;					\
	    fi;								\
	done

	mkdir -p $(MYSQL_IPKG_TMP)/usr/lib
	ln -sf /usr/lib/mysql/libmysqlclient.so.14.0.0 $(MYSQL_IPKG_TMP)/usr/lib/libmysqlclient.so.14

	mkdir -p $(MYSQL_IPKG_TMP)/etc/rc.d/init.d
	mkdir -p $(MYSQL_IPKG_TMP)/etc/rc.d/rc0.d
	mkdir -p $(MYSQL_IPKG_TMP)/etc/rc.d/rc1.d
	mkdir -p $(MYSQL_IPKG_TMP)/etc/rc.d/rc2.d
	mkdir -p $(MYSQL_IPKG_TMP)/etc/rc.d/rc3.d
	mkdir -p $(MYSQL_IPKG_TMP)/etc/rc.d/rc4.d
	mkdir -p $(MYSQL_IPKG_TMP)/etc/rc.d/rc5.d
	mkdir -p $(MYSQL_IPKG_TMP)/etc/rc.d/rc6.d

	$(INSTALL) -m 644 $(MYSQL_IPKG_TMP)/usr/share/mysql/my-small.cnf $(MYSQL_IPKG_TMP)/etc/my.cnf
	
	$(INSTALL) -m 755 $(MYSQL_IPKG_TMP)/usr/share/mysql/mysql.server $(MYSQL_IPKG_TMP)/etc/rc.d/init.d/
	ln -sf ../init.d/mysql.server $(MYSQL_IPKG_TMP)/etc/rc.d/rc0.d/K50mysql.server
	ln -sf ../init.d/mysql.server $(MYSQL_IPKG_TMP)/etc/rc.d/rc1.d/K50mysql.server
	ln -sf ../init.d/mysql.server $(MYSQL_IPKG_TMP)/etc/rc.d/rc3.d/S50mysql.server
	ln -sf ../init.d/mysql.server $(MYSQL_IPKG_TMP)/etc/rc.d/rc4.d/S50mysql.server
	ln -sf ../init.d/mysql.server $(MYSQL_IPKG_TMP)/etc/rc.d/rc5.d/S50mysql.server
	ln -sf ../init.d/mysql.server $(MYSQL_IPKG_TMP)/etc/rc.d/rc6.d/K50mysql.server
	
	mkdir -p $(MYSQL_IPKG_TMP)/CONTROL
	echo "Package: mysql" 								>$(MYSQL_IPKG_TMP)/CONTROL/control
	echo "Priority: optional" 							>>$(MYSQL_IPKG_TMP)/CONTROL/control
	echo "Section: Databases" 							>>$(MYSQL_IPKG_TMP)/CONTROL/control
	echo "Maintainer: Alexander Chukov <sash@pdaXrom.org>" 				>>$(MYSQL_IPKG_TMP)/CONTROL/control
	echo "Architecture: $(SHORT_TARGET)" 						>>$(MYSQL_IPKG_TMP)/CONTROL/control
	echo "Version: $(MYSQL_VERSION)" 						>>$(MYSQL_IPKG_TMP)/CONTROL/control
	echo "Depends: ncurses" 							>>$(MYSQL_IPKG_TMP)/CONTROL/control
	echo "Description: Popular opensource database"					>>$(MYSQL_IPKG_TMP)/CONTROL/control

	echo "#!/bin/sh"								 >$(MYSQL_IPKG_TMP)/CONTROL/postinst
	echo "mysql_install_db"								>>$(MYSQL_IPKG_TMP)/CONTROL/postinst
	echo "chown -R nobody:nobody /var/mysql"					>>$(MYSQL_IPKG_TMP)/CONTROL/postinst
	echo "/etc/rc.d/init.d/mysql.server start"					>>$(MYSQL_IPKG_TMP)/CONTROL/postinst

	echo "#!/bin/sh"								 >$(MYSQL_IPKG_TMP)/CONTROL/prerm
	echo "/etc/rc.d/init.d/mysql.server stop"					>>$(MYSQL_IPKG_TMP)/CONTROL/prerm

	chmod 755 $(MYSQL_IPKG_TMP)/CONTROL/prerm $(MYSQL_IPKG_TMP)/CONTROL/postinst

	cd $(FEEDDIR) && $(XMKIPKG) $(MYSQL_IPKG_TMP)
	touch $@

# ----------------------------------------------------------------------------
# Image-Install
# ----------------------------------------------------------------------------

ifdef PTXCONF_MYSQL_INSTALL
ROMPACKAGES += $(STATEDIR)/mysql.imageinstall
endif

mysql_imageinstall_deps = $(STATEDIR)/mysql.targetinstall \
	$(STATEDIR)/virtual-image.install

$(STATEDIR)/mysql.imageinstall: $(mysql_imageinstall_deps)
	@$(call targetinfo, $@)
	cd $(FEEDDIR) && $(XIPKG) install mysql
	touch $@

# ----------------------------------------------------------------------------
# Clean
# ----------------------------------------------------------------------------

mysql_clean:
	rm -rf $(STATEDIR)/mysql.*
	rm -rf $(MYSQL_DIR)

# vim: syntax=make
