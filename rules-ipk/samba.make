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
ifdef PTXCONF_SAMBA
PACKAGES += samba
endif

#
# Paths and names
#
SAMBA_VERSION		= 2.2.9
##SAMBA_VERSION		= 3.0.2a
###SAMBA_VERSION		= 3.0.4
SAMBA			= samba-$(SAMBA_VERSION)
SAMBA_SUFFIX		= tar.gz
SAMBA_URL		= http://us1.samba.org/samba/ftp/old-versions/$(SAMBA).$(SAMBA_SUFFIX)
###SAMBA_URL		= http://us1.samba.org/samba/ftp/$(SAMBA).$(SAMBA_SUFFIX)
SAMBA_SOURCE		= $(SRCDIR)/$(SAMBA).$(SAMBA_SUFFIX)
SAMBA_DIR		= $(BUILDDIR)/$(SAMBA)
SAMBA_IPKG_TMP		= $(SAMBA_DIR)/ipkg_tmp

# ----------------------------------------------------------------------------
# Get
# ----------------------------------------------------------------------------

samba_get: $(STATEDIR)/samba.get

samba_get_deps = $(SAMBA_SOURCE)

$(STATEDIR)/samba.get: $(samba_get_deps)
	@$(call targetinfo, $@)
	@$(call get_patches, $(SAMBA))
	touch $@

$(SAMBA_SOURCE):
	@$(call targetinfo, $@)
	@$(call get, $(SAMBA_URL))

# ----------------------------------------------------------------------------
# Extract
# ----------------------------------------------------------------------------

samba_extract: $(STATEDIR)/samba.extract

samba_extract_deps = $(STATEDIR)/samba.get

$(STATEDIR)/samba.extract: $(samba_extract_deps)
	@$(call targetinfo, $@)
	@$(call clean, $(SAMBA_DIR))
	@$(call extract, $(SAMBA_SOURCE))
	@$(call patchin, $(SAMBA))
	#cd $(SAMBA_DIR)/source && aclocal
	#cd $(SAMBA_DIR)/source && automake
	###cd $(SAMBA_DIR)/source && autoconf
	touch $@

# ----------------------------------------------------------------------------
# Prepare
# ----------------------------------------------------------------------------

samba_prepare: $(STATEDIR)/samba.prepare

#
# dependencies
#
samba_prepare_deps = \
	$(STATEDIR)/samba.extract \
	$(STATEDIR)/readline.install \
	$(STATEDIR)/virtual-xchain.install

ifdef PTXCONF_LIBICONV
samba_prepare_deps += $(STATEDIR)/libiconv.install
endif

SAMBA_PATH	=  PATH=$(CROSS_PATH)
SAMBA_ENV 	=  $(CROSS_ENV)
ifeq	(2.3.2,$(GLIBC_VERSION))
SAMBA_ENV	+= linux_getgrouplist_ok=yes
else
SAMBA_ENV	+= linux_getgrouplist_ok=no
endif
#SAMBA_ENV	+=
SAMBA_ENV	+= PKG_CONFIG_PATH=$(CROSS_LIB_DIR)/lib/pkgconfig:$(CROSS_LIB_DIR)/lib/pkgconfig
#ifdef PTXCONF_XFREE430
#SAMBA_ENV	+= LDFLAGS=-Wl,-rpath-link,$(CROSS_LIB_DIR)/lib
#endif

#
# autoconf
#
SAMBA_AUTOCONF = \
	--build=$(GNU_HOST) \
	--host=$(PTXCONF_GNU_TARGET) \
	--prefix=/usr \
	--with-smbmount \
	--with-libsmbclient \
	--with-fhs \
	--sysconfdir=/etc \
	--localstatedir=/var \
	--with-privatedir=/etc/samba \
	--cache-file=config.cache

ifdef PTXCONF_LIBICONV
SAMBA_AUTOCONF += --with-libiconv=$(CROSS_LIB_DIR)
endif

ifdef PTXCONF_XFREE430
SAMBA_AUTOCONF += --x-includes=$(CROSS_LIB_DIR)/include
SAMBA_AUTOCONF += --x-libraries=$(CROSS_LIB_DIR)/lib
endif

$(STATEDIR)/samba.prepare: $(samba_prepare_deps)
	@$(call targetinfo, $@)
	@$(call clean, $(SAMBA_DIR)/source/config.cache)
ifdef PTXCONF_ARCH_ARM
	cp -a $(TOPDIR)/config/samba/samba-config.cache $(SAMBA_DIR)/source/config.cache
endif
	cd $(SAMBA_DIR)/source && \
		$(SAMBA_PATH) $(SAMBA_ENV) \
		CFLAGS="-O2 -fomit-frame-pointer" ./configure $(SAMBA_AUTOCONF)
	touch $@

# ----------------------------------------------------------------------------
# Compile
# ----------------------------------------------------------------------------

samba_compile: $(STATEDIR)/samba.compile

samba_compile_deps = $(STATEDIR)/samba.prepare

$(STATEDIR)/samba.compile: $(samba_compile_deps)
	@$(call targetinfo, $@)
	$(SAMBA_PATH) $(MAKE) -C $(SAMBA_DIR)/source bin/make_smbcodepage CC=gcc LD=gcc
	$(SAMBA_PATH) $(MAKE) -C $(SAMBA_DIR)/source bin/make_unicodemap  CC=gcc LD=gcc
	mv -f $(SAMBA_DIR)/source/bin/make_smbcodepage $(SAMBA_DIR)/source/bin/make_smbcodepage-host
	mv -f $(SAMBA_DIR)/source/bin/make_unicodemap  $(SAMBA_DIR)/source/bin/make_unicodemap-host
	$(SAMBA_PATH) $(MAKE) -C $(SAMBA_DIR)/source clean
	$(SAMBA_PATH) $(MAKE) -C $(SAMBA_DIR)/source
	touch $@

# ----------------------------------------------------------------------------
# Install
# ----------------------------------------------------------------------------

samba_install: $(STATEDIR)/samba.install

$(STATEDIR)/samba.install: $(STATEDIR)/samba.compile
	@$(call targetinfo, $@)
	$(SAMBA_PATH) $(MAKE) -C $(SAMBA_DIR)/source DESTDIR=$(SAMBA_IPKG_TMP) install
	asdasd
	touch $@

# ----------------------------------------------------------------------------
# Target-Install
# ----------------------------------------------------------------------------

samba_targetinstall: $(STATEDIR)/samba.targetinstall

samba_targetinstall_deps = \
	$(STATEDIR)/samba.compile \
	$(STATEDIR)/readline.targetinstall


ifdef PTXCONF_LIBICONV
samba_targetinstall_deps += $(STATEDIR)/libiconv.targetinstall
endif

$(STATEDIR)/samba.targetinstall: $(samba_targetinstall_deps)
	@$(call targetinfo, $@)
	rm -rf $(SAMBA_IPKG_TMP)
	$(SAMBA_PATH) $(MAKE) -C $(SAMBA_DIR)/source prefix=$(SAMBA_IPKG_TMP)/usr sysconfdir=$(SAMBA_IPKG_TMP)/etc BASEDIR=$(SAMBA_IPKG_TMP) VARDIR=$(SAMBA_IPKG_TMP)/var PRIVATEDIR=$(SAMBA_IPKG_TMP)/etc/samba install
	rm -rf $(SAMBA_IPKG_TMP)-common $(SAMBA_IPKG_TMP)-client $(SAMBA_IPKG_TMP)-server $(SAMBA_IPKG_TMP)-mount
	mkdir -p $(SAMBA_IPKG_TMP)-common/CONTROL
	mkdir -p $(SAMBA_IPKG_TMP)-client/CONTROL
	mkdir -p $(SAMBA_IPKG_TMP)-server/CONTROL

	mkdir -p $(SAMBA_IPKG_TMP)-common/etc/samba
	mkdir -p $(SAMBA_IPKG_TMP)-common/usr/share/samba/codepages
	mkdir -p $(SAMBA_IPKG_TMP)-common/var/lib/samba
	cp $(TOPDIR)/config/samba/smb.conf                    $(SAMBA_IPKG_TMP)-common/etc/samba
	cp $(SAMBA_IPKG_TMP)/usr/share/samba/codepages/*.ISO8859-1 $(SAMBA_IPKG_TMP)-common/usr/share/samba/codepages
	cp $(SAMBA_IPKG_TMP)/usr/share/samba/codepages/*.850       $(SAMBA_IPKG_TMP)-common/usr/share/samba/codepages

	mkdir -p $(SAMBA_IPKG_TMP)-client/usr/bin
	cp $(SAMBA_IPKG_TMP)/usr/bin/smbclient       $(SAMBA_IPKG_TMP)-client/usr/bin
	$(CROSSSTRIP) $(SAMBA_IPKG_TMP)-client/usr/bin/smbclient

	mkdir -p $(SAMBA_IPKG_TMP)-mount/CONTROL
	mkdir -p $(SAMBA_IPKG_TMP)-mount/usr/bin
	cp $(SAMBA_IPKG_TMP)/usr/bin/smbmount       $(SAMBA_IPKG_TMP)-mount/usr/bin
	cp $(SAMBA_IPKG_TMP)/usr/bin/smbmnt       $(SAMBA_IPKG_TMP)-mount/usr/bin
	$(CROSSSTRIP) $(SAMBA_IPKG_TMP)-mount/usr/bin/smbmount
	$(CROSSSTRIP) $(SAMBA_IPKG_TMP)-mount/usr/bin/smbmnt
	mkdir -p $(SAMBA_IPKG_TMP)-mount/sbin
	ln -sf /usr/bin/smbmount $(SAMBA_IPKG_TMP)-mount/sbin/mount.smbfs

	mkdir -p $(SAMBA_IPKG_TMP)-server/etc/rc.d/init.d
	mkdir -p $(SAMBA_IPKG_TMP)-server/etc/rc.d/rc3.d
	mkdir -p $(SAMBA_IPKG_TMP)-server/etc/rc.d/rc5.d
	mkdir -p $(SAMBA_IPKG_TMP)-server/usr/bin
	mkdir -p $(SAMBA_IPKG_TMP)-server/usr/sbin
	cp $(TOPDIR)/config/samba/samba $(SAMBA_IPKG_TMP)-server/etc/rc.d/init.d
	ln -sf ../init.d/samba          $(SAMBA_IPKG_TMP)-server/etc/rc.d/rc3.d/S55samba
	ln -sf ../init.d/samba          $(SAMBA_IPKG_TMP)-server/etc/rc.d/rc5.d/S55samba
	cp $(SAMBA_IPKG_TMP)/usr/bin/smbpasswd $(SAMBA_IPKG_TMP)-server/usr/bin
	$(CROSSSTRIP) $(SAMBA_IPKG_TMP)-server/usr/bin/smbpasswd
	cp $(SAMBA_IPKG_TMP)/usr/sbin/smbd     $(SAMBA_IPKG_TMP)-server/usr/sbin
	cp $(SAMBA_IPKG_TMP)/usr/sbin/nmbd     $(SAMBA_IPKG_TMP)-server/usr/sbin
	$(CROSSSTRIP) $(SAMBA_IPKG_TMP)-server/usr/sbin/*
	echo "#!/bin/sh"                     >$(SAMBA_IPKG_TMP)-server/CONTROL/postinst
	echo "/etc/rc.d/init.d/samba start" >>$(SAMBA_IPKG_TMP)-server/CONTROL/postinst
	chmod 755 $(SAMBA_IPKG_TMP)-server/CONTROL/postinst
	echo "#!/bin/sh"                     >$(SAMBA_IPKG_TMP)-server/CONTROL/prerm
	echo "/etc/rc.d/init.d/samba stop"  >>$(SAMBA_IPKG_TMP)-server/CONTROL/prerm
	chmod 755 $(SAMBA_IPKG_TMP)-server/CONTROL/prerm

	echo "Package: samba-common" 			 >$(SAMBA_IPKG_TMP)-common/CONTROL/control
	echo "Priority: optional" 			>>$(SAMBA_IPKG_TMP)-common/CONTROL/control
	echo "Section: Network" 			>>$(SAMBA_IPKG_TMP)-common/CONTROL/control
	echo "Maintainer: Alexander Chukov <sash@pdaXrom.org>">>$(SAMBA_IPKG_TMP)-common/CONTROL/control
	echo "Architecture: $(SHORT_TARGET)" 		>>$(SAMBA_IPKG_TMP)-common/CONTROL/control
	echo "Version: $(SAMBA_VERSION)" 		>>$(SAMBA_IPKG_TMP)-common/CONTROL/control
	echo "Depends: "	 			>>$(SAMBA_IPKG_TMP)-common/CONTROL/control
	echo "Description: common samba files"          >>$(SAMBA_IPKG_TMP)-common/CONTROL/control
	cd $(FEEDDIR) && $(XMKIPKG) $(SAMBA_IPKG_TMP)-common
	
	echo "Package: samba-client" 			 >$(SAMBA_IPKG_TMP)-client/CONTROL/control
	echo "Priority: optional" 			>>$(SAMBA_IPKG_TMP)-client/CONTROL/control
	echo "Section: Network" 			>>$(SAMBA_IPKG_TMP)-client/CONTROL/control
	echo "Maintainer: Alexander Chukov <sash@pdaXrom.org>">>$(SAMBA_IPKG_TMP)-client/CONTROL/control
	echo "Architecture: $(SHORT_TARGET)" 		>>$(SAMBA_IPKG_TMP)-client/CONTROL/control
	echo "Version: $(SAMBA_VERSION)" 		>>$(SAMBA_IPKG_TMP)-client/CONTROL/control
	echo "Depends: samba-common, readline" 		>>$(SAMBA_IPKG_TMP)-client/CONTROL/control
	echo "Description: ftp-like client to access SMB/CIFS resources  on servers">>$(SAMBA_IPKG_TMP)-client/CONTROL/control
	cd $(FEEDDIR) && $(XMKIPKG) $(SAMBA_IPKG_TMP)-client

	echo "Package: samba-mount" 			 >$(SAMBA_IPKG_TMP)-mount/CONTROL/control
	echo "Priority: optional" 			>>$(SAMBA_IPKG_TMP)-mount/CONTROL/control
	echo "Section: Network" 			>>$(SAMBA_IPKG_TMP)-mount/CONTROL/control
	echo "Maintainer: Alexander Chukov <sash@pdaXrom.org>">>$(SAMBA_IPKG_TMP)-mount/CONTROL/control
	echo "Architecture: $(SHORT_TARGET)" 		>>$(SAMBA_IPKG_TMP)-mount/CONTROL/control
	echo "Version: $(SAMBA_VERSION)" 		>>$(SAMBA_IPKG_TMP)-mount/CONTROL/control
	echo "Depends: samba-common"	 		>>$(SAMBA_IPKG_TMP)-mount/CONTROL/control
	echo "Description: mount an smbfs filesystem">>$(SAMBA_IPKG_TMP)-mount/CONTROL/control
	cd $(FEEDDIR) && $(XMKIPKG) $(SAMBA_IPKG_TMP)-mount

	echo "Package: samba-server" 			 >$(SAMBA_IPKG_TMP)-server/CONTROL/control
	echo "Priority: optional" 			>>$(SAMBA_IPKG_TMP)-server/CONTROL/control
	echo "Section: Network" 			>>$(SAMBA_IPKG_TMP)-server/CONTROL/control
	echo "Maintainer: Alexander Chukov <sash@pdaXrom.org>">>$(SAMBA_IPKG_TMP)-server/CONTROL/control
	echo "Architecture: $(SHORT_TARGET)" 		>>$(SAMBA_IPKG_TMP)-server/CONTROL/control
	echo "Version: $(SAMBA_VERSION)" 		>>$(SAMBA_IPKG_TMP)-server/CONTROL/control
	echo "Depends: samba-common" 			>>$(SAMBA_IPKG_TMP)-server/CONTROL/control
	echo "Description: server to provide SMB/CIFS and NetBIOS name server to provide NetBIOS over IP naming services to clients">>$(SAMBA_IPKG_TMP)-server/CONTROL/control
	cd $(FEEDDIR) && $(XMKIPKG) $(SAMBA_IPKG_TMP)-server

	for codep in 1125 1251 437 737 775 850 852 857 861 866 932 936 949 950 ISO8859-1 ISO8859-13 ISO8859-15 ISO8859-2 ISO8859-5 ISO8859-7 ISO8859-9 KOI8-R KOI8-U; do \
	    rm -rf $(SAMBA_IPKG_TMP)-codep ;				\
	    mkdir -p $(SAMBA_IPKG_TMP)-codep/usr/share/samba/codepages ;\
	    cp $(SAMBA_IPKG_TMP)/usr/share/samba/codepages/*.$$codep $(SAMBA_IPKG_TMP)-codep/usr/share/samba/codepages ;\
	    mkdir -p $(SAMBA_IPKG_TMP)-codep/CONTROL ;			\
	    echo "Package: samba-codepage-`echo $$codep | perl -e 'print lc(<STDIN>)'`" 	 >$(SAMBA_IPKG_TMP)-codep/CONTROL/control ; \
	    echo "Priority: optional" 								>>$(SAMBA_IPKG_TMP)-codep/CONTROL/control ; \
	    echo "Section: Network" 								>>$(SAMBA_IPKG_TMP)-codep/CONTROL/control ; \
	    echo "Maintainer: Alexander Chukov <sash@pdaXrom.org>"				>>$(SAMBA_IPKG_TMP)-codep/CONTROL/control ; \
	    echo "Architecture: $(SHORT_TARGET)" 						>>$(SAMBA_IPKG_TMP)-codep/CONTROL/control ; \
	    echo "Version: $(SAMBA_VERSION)" 							>>$(SAMBA_IPKG_TMP)-codep/CONTROL/control ; \
	    echo "Depends: "	 								>>$(SAMBA_IPKG_TMP)-codep/CONTROL/control ; \
	    echo "Description: codepage $$codep for samba"     					>>$(SAMBA_IPKG_TMP)-codep/CONTROL/control ; \
	    cd $(FEEDDIR) && $(XMKIPKG) $(SAMBA_IPKG_TMP)-codep;		\
	done
	touch $@

# ----------------------------------------------------------------------------
# Clean
# ----------------------------------------------------------------------------

samba_clean:
	rm -rf $(STATEDIR)/samba.*
	rm -rf $(SAMBA_DIR)

# vim: syntax=make
