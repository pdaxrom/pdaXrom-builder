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
ifdef PTXCONF_USBDCONFIG
PACKAGES += usbdconfig
endif

#
# Paths and names
#
USBDCONFIG_VENDOR_VERSION	= 1
USBDCONFIG_VERSION		= 1.1.0
USBDCONFIG			= usbdconfig-$(USBDCONFIG_VERSION)
USBDCONFIG_SUFFIX		= tar.bz2
USBDCONFIG_URL			= http://www.pdaXrom.org/src/$(USBDCONFIG).$(USBDCONFIG_SUFFIX)
USBDCONFIG_SOURCE		= $(SRCDIR)/$(USBDCONFIG).$(USBDCONFIG_SUFFIX)
USBDCONFIG_DIR			= $(BUILDDIR)/$(USBDCONFIG)
USBDCONFIG_IPKG_TMP		= $(USBDCONFIG_DIR)/ipkg_tmp

# ----------------------------------------------------------------------------
# Get
# ----------------------------------------------------------------------------

usbdconfig_get: $(STATEDIR)/usbdconfig.get

usbdconfig_get_deps = $(USBDCONFIG_SOURCE)

$(STATEDIR)/usbdconfig.get: $(usbdconfig_get_deps)
	@$(call targetinfo, $@)
	@$(call get_patches, $(USBDCONFIG))
	touch $@

$(USBDCONFIG_SOURCE):
	@$(call targetinfo, $@)
	@$(call get, $(USBDCONFIG_URL))

# ----------------------------------------------------------------------------
# Extract
# ----------------------------------------------------------------------------

usbdconfig_extract: $(STATEDIR)/usbdconfig.extract

usbdconfig_extract_deps = $(STATEDIR)/usbdconfig.get

$(STATEDIR)/usbdconfig.extract: $(usbdconfig_extract_deps)
	@$(call targetinfo, $@)
	@$(call clean, $(USBDCONFIG_DIR))
	@$(call extract, $(USBDCONFIG_SOURCE))
	@$(call patchin, $(USBDCONFIG))
	touch $@

# ----------------------------------------------------------------------------
# Prepare
# ----------------------------------------------------------------------------

usbdconfig_prepare: $(STATEDIR)/usbdconfig.prepare

#
# dependencies
#
usbdconfig_prepare_deps = \
	$(STATEDIR)/usbdconfig.extract \
	$(STATEDIR)/virtual-xchain.install

USBDCONFIG_PATH	=  PATH=$(CROSS_PATH)
USBDCONFIG_ENV 	=  $(CROSS_ENV)
USBDCONFIG_ENV	+= CFLAGS="-O2 -fomit-frame-pointer"
USBDCONFIG_ENV	+= PKG_CONFIG_PATH=$(CROSS_LIB_DIR)/lib/pkgconfig
#ifdef PTXCONF_XFREE430
#USBDCONFIG_ENV	+= LDFLAGS=-Wl,-rpath-link,$(CROSS_LIB_DIR)/X11R6/lib
#endif

#
# autoconf
#
USBDCONFIG_AUTOCONF = \
	--build=$(GNU_HOST) \
	--host=$(PTXCONF_GNU_TARGET) \
	--prefix=/usr \
	--disable-debug

ifdef PTXCONF_XFREE430
USBDCONFIG_AUTOCONF += --x-includes=$(CROSS_LIB_DIR)/include
USBDCONFIG_AUTOCONF += --x-libraries=$(CROSS_LIB_DIR)/lib
endif

$(STATEDIR)/usbdconfig.prepare: $(usbdconfig_prepare_deps)
	@$(call targetinfo, $@)
	@$(call clean, $(USBDCONFIG_DIR)/config.cache)
	cd $(USBDCONFIG_DIR) && $(USBDCONFIG_PATH) ./autogen.sh
	cd $(USBDCONFIG_DIR) && \
		$(USBDCONFIG_PATH) $(USBDCONFIG_ENV) \
		./configure $(USBDCONFIG_AUTOCONF)
	touch $@

# ----------------------------------------------------------------------------
# Compile
# ----------------------------------------------------------------------------

usbdconfig_compile: $(STATEDIR)/usbdconfig.compile

usbdconfig_compile_deps = $(STATEDIR)/usbdconfig.prepare

$(STATEDIR)/usbdconfig.compile: $(usbdconfig_compile_deps)
	@$(call targetinfo, $@)
	$(USBDCONFIG_PATH) $(MAKE) -C $(USBDCONFIG_DIR)
	touch $@

# ----------------------------------------------------------------------------
# Install
# ----------------------------------------------------------------------------

usbdconfig_install: $(STATEDIR)/usbdconfig.install

$(STATEDIR)/usbdconfig.install: $(STATEDIR)/usbdconfig.compile
	@$(call targetinfo, $@)
	touch $@

# ----------------------------------------------------------------------------
# Target-Install
# ----------------------------------------------------------------------------

usbdconfig_targetinstall: $(STATEDIR)/usbdconfig.targetinstall

usbdconfig_targetinstall_deps = $(STATEDIR)/usbdconfig.compile

$(STATEDIR)/usbdconfig.targetinstall: $(usbdconfig_targetinstall_deps)
	@$(call targetinfo, $@)
	$(USBDCONFIG_PATH) $(MAKE) -C $(USBDCONFIG_DIR) DESTDIR=$(USBDCONFIG_IPKG_TMP) install
	$(CROSSSTRIP) $(USBDCONFIG_IPKG_TMP)/usr/bin/*
	mkdir -p $(USBDCONFIG_IPKG_TMP)/usr/share/usbdconfig/pixmaps
	ln -sf ../../pixmaps/usb.png $(USBDCONFIG_IPKG_TMP)/usr/share/usbdconfig/pixmaps/usb.png
	mkdir -p $(USBDCONFIG_IPKG_TMP)/CONTROL
	echo "Package: usbdconfig" 							 >$(USBDCONFIG_IPKG_TMP)/CONTROL/control
	echo "Priority: optional" 							>>$(USBDCONFIG_IPKG_TMP)/CONTROL/control
	echo "Section: X11" 								>>$(USBDCONFIG_IPKG_TMP)/CONTROL/control
	echo "Maintainer: Alexander Chukov <sash@pdaXrom.org>" 				>>$(USBDCONFIG_IPKG_TMP)/CONTROL/control
	echo "Architecture: $(SHORT_TARGET)" 						>>$(USBDCONFIG_IPKG_TMP)/CONTROL/control
	echo "Version: $(USBDCONFIG_VERSION)-$(USBDCONFIG_VENDOR_VERSION)" 		>>$(USBDCONFIG_IPKG_TMP)/CONTROL/control
	echo "Depends: gtk2" 								>>$(USBDCONFIG_IPKG_TMP)/CONTROL/control
	echo "Description: USB Device emulation settings"				>>$(USBDCONFIG_IPKG_TMP)/CONTROL/control
	cd $(FEEDDIR) && $(XMKIPKG) $(USBDCONFIG_IPKG_TMP)
	touch $@

# ----------------------------------------------------------------------------
# Image-Install
# ----------------------------------------------------------------------------

ifdef PTXCONF_USBDCONFIG_INSTALL
ROMPACKAGES += $(STATEDIR)/usbdconfig.imageinstall
endif

usbdconfig_imageinstall_deps = $(STATEDIR)/usbdconfig.targetinstall \
	$(STATEDIR)/virtual-image.install

$(STATEDIR)/usbdconfig.imageinstall: $(usbdconfig_imageinstall_deps)
	@$(call targetinfo, $@)
	cd $(FEEDDIR) && $(XIPKG) install usbdconfig
	touch $@

# ----------------------------------------------------------------------------
# Clean
# ----------------------------------------------------------------------------

usbdconfig_clean:
	rm -rf $(STATEDIR)/usbdconfig.*
	rm -rf $(USBDCONFIG_DIR)

# vim: syntax=make
