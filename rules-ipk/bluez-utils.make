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
ifdef PTXCONF_BLUEZ-UTILS
PACKAGES += bluez-utils
endif

#
# Paths and names
#
BLUEZ-UTILS_VERSION	= 2.4
BLUEZ-UTILS		= bluez-utils-$(BLUEZ-UTILS_VERSION)
BLUEZ-UTILS_SUFFIX	= tar.gz
BLUEZ-UTILS_URL		= http://bluez.sourceforge.net/download/$(BLUEZ-UTILS).$(BLUEZ-UTILS_SUFFIX)
BLUEZ-UTILS_SOURCE	= $(SRCDIR)/$(BLUEZ-UTILS).$(BLUEZ-UTILS_SUFFIX)
BLUEZ-UTILS_DIR		= $(BUILDDIR)/$(BLUEZ-UTILS)
BLUEZ-UTILS_IPKG_TMP	= $(BLUEZ-UTILS_DIR)/ipkg_tmp

# ----------------------------------------------------------------------------
# Get
# ----------------------------------------------------------------------------

bluez-utils_get: $(STATEDIR)/bluez-utils.get

bluez-utils_get_deps = $(BLUEZ-UTILS_SOURCE)

$(STATEDIR)/bluez-utils.get: $(bluez-utils_get_deps)
	@$(call targetinfo, $@)
	@$(call get_patches, $(BLUEZ-UTILS))
	touch $@

$(BLUEZ-UTILS_SOURCE):
	@$(call targetinfo, $@)
	@$(call get, $(BLUEZ-UTILS_URL))

# ----------------------------------------------------------------------------
# Extract
# ----------------------------------------------------------------------------

bluez-utils_extract: $(STATEDIR)/bluez-utils.extract

bluez-utils_extract_deps = $(STATEDIR)/bluez-utils.get

$(STATEDIR)/bluez-utils.extract: $(bluez-utils_extract_deps)
	@$(call targetinfo, $@)
	@$(call clean, $(BLUEZ-UTILS_DIR))
	@$(call extract, $(BLUEZ-UTILS_SOURCE))
	@$(call patchin, $(BLUEZ-UTILS))
	touch $@

# ----------------------------------------------------------------------------
# Prepare
# ----------------------------------------------------------------------------

bluez-utils_prepare: $(STATEDIR)/bluez-utils.prepare

#
# dependencies
#
bluez-utils_prepare_deps = \
	$(STATEDIR)/bluez-utils.extract \
	$(STATEDIR)/bluez-libs.install \
	$(STATEDIR)/virtual-xchain.install

BLUEZ-UTILS_PATH	=  PATH=$(CROSS_PATH)
BLUEZ-UTILS_ENV 	=  $(CROSS_ENV)
#BLUEZ-UTILS_ENV	+=
BLUEZ-UTILS_ENV	+= PKG_CONFIG_PATH=$(CROSS_LIB_DIR)/lib/pkgconfig:$(CROSS_LIB_DIR)/lib/pkgconfig
#ifdef PTXCONF_XFREE430
#BLUEZ-UTILS_ENV	+= LDFLAGS=-Wl,-rpath-link,$(CROSS_LIB_DIR)/lib
#endif

#
# autoconf
#
BLUEZ-UTILS_AUTOCONF = \
	--build=$(GNU_HOST) \
	--host=$(PTXCONF_GNU_TARGET) \
	--prefix=/	\
	--disable-static \
	--enable-shared \
	--sysconfdir=/etc \
	--enable-pcmcia \
	--with-bluez-includes=$(CROSS_LIB_DIR)/include \
	--with-bluez-libs=$(CROSS_LIB_DIR)/lib \
	--disable-debug

ifdef PTXCONF_XFREE430
BLUEZ-UTILS_AUTOCONF += --x-includes=$(CROSS_LIB_DIR)/include
BLUEZ-UTILS_AUTOCONF += --x-libraries=$(CROSS_LIB_DIR)/lib
endif

$(STATEDIR)/bluez-utils.prepare: $(bluez-utils_prepare_deps)
	@$(call targetinfo, $@)
	@$(call clean, $(BLUEZ-UTILS_DIR)/config.cache)
	cd $(BLUEZ-UTILS_DIR) && \
		$(BLUEZ-UTILS_PATH) $(BLUEZ-UTILS_ENV) \
		./configure $(BLUEZ-UTILS_AUTOCONF)
	touch $@

# ----------------------------------------------------------------------------
# Compile
# ----------------------------------------------------------------------------

bluez-utils_compile: $(STATEDIR)/bluez-utils.compile

bluez-utils_compile_deps = $(STATEDIR)/bluez-utils.prepare

$(STATEDIR)/bluez-utils.compile: $(bluez-utils_compile_deps)
	@$(call targetinfo, $@)
	cp -f $(PTXCONF_PREFIX)/bin/libtool $(BLUEZ-UTILS_DIR)
	$(BLUEZ-UTILS_PATH) $(MAKE) -C $(BLUEZ-UTILS_DIR) CC=$(PTXCONF_GNU_TARGET)-gcc
	touch $@

# ----------------------------------------------------------------------------
# Install
# ----------------------------------------------------------------------------

bluez-utils_install: $(STATEDIR)/bluez-utils.install

$(STATEDIR)/bluez-utils.install: $(STATEDIR)/bluez-utils.compile
	@$(call targetinfo, $@)
	touch $@

# ----------------------------------------------------------------------------
# Target-Install
# ----------------------------------------------------------------------------

bluez-utils_targetinstall: $(STATEDIR)/bluez-utils.targetinstall

bluez-utils_targetinstall_deps = $(STATEDIR)/bluez-utils.compile \
	$(STATEDIR)/bluez-libs.targetinstall \

$(STATEDIR)/bluez-utils.targetinstall: $(bluez-utils_targetinstall_deps)
	@$(call targetinfo, $@)

	$(BLUEZ-UTILS_PATH) $(MAKE) -C $(BLUEZ-UTILS_DIR) DESTDIR=$(BLUEZ-UTILS_IPKG_TMP) install
	mkdir -p $(BLUEZ-UTILS_IPKG_TMP)/CONTROL
	echo "Package: bluez-utils" 			>$(BLUEZ-UTILS_IPKG_TMP)/CONTROL/control
	echo "Priority: optional" 			>>$(BLUEZ-UTILS_IPKG_TMP)/CONTROL/control
	echo "Section: pdaXrom" 			>>$(BLUEZ-UTILS_IPKG_TMP)/CONTROL/control
	echo "Maintainer: Alexander Chukov <sash@pdaXrom.org>" >>$(BLUEZ-UTILS_IPKG_TMP)/CONTROL/control
	echo "Architecture: $(SHORT_TARGET)" 		>>$(BLUEZ-UTILS_IPKG_TMP)/CONTROL/control
	echo "Version: $(BLUEZ-UTILS_VERSION)" 		>>$(BLUEZ-UTILS_IPKG_TMP)/CONTROL/control
	echo "Depends: bluez-libs" 			>>$(BLUEZ-UTILS_IPKG_TMP)/CONTROL/control
	echo "Description: generated with pdaXrom builder">>$(BLUEZ-UTILS_IPKG_TMP)/CONTROL/control	
	echo "#!/bin/sh" 				>$(BLUEZ-UTILS_IPKG_TMP)/CONTROL/postinst
	echo "/etc/rc.d/init.d/pcmcia restart" 		>>$(BLUEZ-UTILS_IPKG_TMP)/CONTROL/postinst
	echo "/etc/rc.d/init.d/bluetooth start" 	>>$(BLUEZ-UTILS_IPKG_TMP)/CONTROL/postinst
	chmod 755 $(BLUEZ-UTILS_IPKG_TMP)/CONTROL/postinst
	$(CROSSSTRIP) $(BLUEZ-UTILS_IPKG_TMP)/bin/hcitool
	$(CROSSSTRIP) $(BLUEZ-UTILS_IPKG_TMP)/bin/l2ping
	$(CROSSSTRIP) $(BLUEZ-UTILS_IPKG_TMP)/bin/rfcomm
	$(CROSSSTRIP) $(BLUEZ-UTILS_IPKG_TMP)/sbin/hciattach
	$(CROSSSTRIP) $(BLUEZ-UTILS_IPKG_TMP)/sbin/hciconfig
	$(CROSSSTRIP) $(BLUEZ-UTILS_IPKG_TMP)/sbin/hcid
	$(INSTALL) -m 755 -D $(BLUEZ-UTILS_DIR)/scripts/bluetooth.rc.rh $(BLUEZ-UTILS_IPKG_TMP)/etc/rc.d/init.d/bluetooth
	$(INSTALL) -m 755 -D $(BLUEZ-UTILS_DIR)/scripts/create_dev      $(BLUEZ-UTILS_IPKG_TMP)/etc/rc.d/init.d/create_dev
	$(INSTALL) -d $(BLUEZ-UTILS_IPKG_TMP)/etc/rc.d/rc3.d
	$(INSTALL) -d $(BLUEZ-UTILS_IPKG_TMP)/etc/rc.d/rc5.d
	$(INSTALL) -d $(BLUEZ-UTILS_IPKG_TMP)/etc/rc.d/rc6.d
	ln -sf ../init.d/bluetooth $(BLUEZ-UTILS_IPKG_TMP)/etc/rc.d/rc3.d/S50bluetooth
	ln -sf ../init.d/bluetooth $(BLUEZ-UTILS_IPKG_TMP)/etc/rc.d/rc5.d/S50bluetooth
	ln -sf ../init.d/bluetooth $(BLUEZ-UTILS_IPKG_TMP)/etc/rc.d/rc6.d/K40bluetooth
	rm -rf $(BLUEZ-UTILS_IPKG_TMP)/usr/share/man
	cd $(FEEDDIR) && $(XMKIPKG) $(BLUEZ-UTILS_IPKG_TMP)
	touch $@

# ----------------------------------------------------------------------------
# Image-Install
# ----------------------------------------------------------------------------

ifdef PTXCONF_BLUEZ-UTILS_INSTALL
ROMPACKAGES += $(STATEDIR)/bluez-utils.imageinstall
endif

bluez-utils_imageinstall_deps = $(STATEDIR)/bluez-utils.targetinstall \
	$(STATEDIR)/virtual-image.install

$(STATEDIR)/bluez-utils.imageinstall: $(bluez-utils_imageinstall_deps)
	@$(call targetinfo, $@)
	cd $(FEEDDIR) && $(XIPKG) install bluez-utils
	touch $@

# ----------------------------------------------------------------------------
# Clean
# ----------------------------------------------------------------------------

bluez-utils_clean:
	rm -rf $(STATEDIR)/bluez-utils.*
	rm -rf $(BLUEZ-UTILS_DIR)

# vim: syntax=make
