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
ifdef PTXCONF_BATTERY-STATUS
PACKAGES += Battery-Status
endif

#
# Paths and names
#
BATTERY-STATUS_VERSION	= 0.2.1
BATTERY-STATUS		= Battery-Status-$(BATTERY-STATUS_VERSION)
BATTERY-STATUS_SUFFIX	= tar.bz2
BATTERY-STATUS_URL	= http://www.pdaXrom.org/src/$(BATTERY-STATUS).$(BATTERY-STATUS_SUFFIX)
BATTERY-STATUS_SOURCE	= $(SRCDIR)/$(BATTERY-STATUS).$(BATTERY-STATUS_SUFFIX)
BATTERY-STATUS_DIR	= $(BUILDDIR)/Battery-Status
BATTERY-STATUS_IPKG_TMP	= $(BATTERY-STATUS_DIR)-ipkg_tmp

# ----------------------------------------------------------------------------
# Get
# ----------------------------------------------------------------------------

Battery-Status_get: $(STATEDIR)/Battery-Status.get

Battery-Status_get_deps = $(BATTERY-STATUS_SOURCE)

$(STATEDIR)/Battery-Status.get: $(Battery-Status_get_deps)
	@$(call targetinfo, $@)
	@$(call get_patches, $(BATTERY-STATUS))
	touch $@

$(BATTERY-STATUS_SOURCE):
	@$(call targetinfo, $@)
	@$(call get, $(BATTERY-STATUS_URL))

# ----------------------------------------------------------------------------
# Extract
# ----------------------------------------------------------------------------

Battery-Status_extract: $(STATEDIR)/Battery-Status.extract

Battery-Status_extract_deps = $(STATEDIR)/Battery-Status.get

$(STATEDIR)/Battery-Status.extract: $(Battery-Status_extract_deps)
	@$(call targetinfo, $@)
	@$(call clean, $(BATTERY-STATUS_DIR))
	@$(call extract, $(BATTERY-STATUS_SOURCE))
	@$(call patchin, $(BATTERY-STATUS), $(BATTERY-STATUS_DIR))
	touch $@

# ----------------------------------------------------------------------------
# Prepare
# ----------------------------------------------------------------------------

Battery-Status_prepare: $(STATEDIR)/Battery-Status.prepare

#
# dependencies
#
Battery-Status_prepare_deps = \
	$(STATEDIR)/Battery-Status.extract \
	$(STATEDIR)/apmd.install \
	$(STATEDIR)/gtk22.install \
	$(STATEDIR)/virtual-xchain.install

BATTERY-STATUS_PATH	=  PATH=$(CROSS_PATH)
BATTERY-STATUS_ENV 	=  $(CROSS_ENV)
BATTERY-STATUS_ENV	+= CFLAGS="-O2 -fomit-frame-pointer"
BATTERY-STATUS_ENV	+= PKG_CONFIG_PATH=$(CROSS_LIB_DIR)/lib/pkgconfig:$(CROSS_LIB_DIR)/lib/pkgconfig
#ifdef PTXCONF_XFREE430
#BATTERY-STATUS_ENV	+= LDFLAGS=-Wl,-rpath-link,$(CROSS_LIB_DIR)/lib
#endif

#
# autoconf
#
BATTERY-STATUS_AUTOCONF = \
	--build=$(GNU_HOST) \
	--host=$(PTXCONF_GNU_TARGET) \
	--disable-debug \
	--with-platform=Linux-$(PTXCONF_ARCH)

ifdef PTXCONF_XFREE430
BATTERY-STATUS_AUTOCONF += --x-includes=$(CROSS_LIB_DIR)/include
BATTERY-STATUS_AUTOCONF += --x-libraries=$(CROSS_LIB_DIR)/lib
endif

$(STATEDIR)/Battery-Status.prepare: $(Battery-Status_prepare_deps)
	@$(call targetinfo, $@)
	@$(call clean, $(BATTERY-STATUS_DIR)/config.cache)
	cd $(BATTERY-STATUS_DIR)/src && \
		$(BATTERY-STATUS_PATH) $(BATTERY-STATUS_ENV) \
		./configure $(BATTERY-STATUS_AUTOCONF)
	touch $@

# ----------------------------------------------------------------------------
# Compile
# ----------------------------------------------------------------------------

Battery-Status_compile: $(STATEDIR)/Battery-Status.compile

Battery-Status_compile_deps = $(STATEDIR)/Battery-Status.prepare

$(STATEDIR)/Battery-Status.compile: $(Battery-Status_compile_deps)
	@$(call targetinfo, $@)
	$(BATTERY-STATUS_PATH) $(BATTERY-STATUS_ENV) $(MAKE) -C $(BATTERY-STATUS_DIR)/src
	touch $@

# ----------------------------------------------------------------------------
# Install
# ----------------------------------------------------------------------------

Battery-Status_install: $(STATEDIR)/Battery-Status.install

$(STATEDIR)/Battery-Status.install: $(STATEDIR)/Battery-Status.compile
	@$(call targetinfo, $@)
	touch $@

# ----------------------------------------------------------------------------
# Target-Install
# ----------------------------------------------------------------------------

Battery-Status_targetinstall: $(STATEDIR)/Battery-Status.targetinstall

Battery-Status_targetinstall_deps = $(STATEDIR)/Battery-Status.compile \
	$(STATEDIR)/apmd.targetinstall \
	$(STATEDIR)/gtk22.targetinstall

$(STATEDIR)/Battery-Status.targetinstall: $(Battery-Status_targetinstall_deps)
	@$(call targetinfo, $@)
	rm -rf $(BATTERY-STATUS_IPKG_TMP)
	mkdir -p $(BATTERY-STATUS_IPKG_TMP)/usr/apps
	cp -a $(BATTERY-STATUS_DIR) $(BATTERY-STATUS_IPKG_TMP)/usr/apps
	rm -rf $(BATTERY-STATUS_IPKG_TMP)/usr/apps/Battery-Status/src
	$(CROSSSTRIP) $(BATTERY-STATUS_IPKG_TMP)/usr/apps/Battery-Status/Linux-$(PTXCONF_ARCH)/*
	mkdir -p $(BATTERY-STATUS_IPKG_TMP)/CONTROL
	echo "Package: battery-status" 			>$(BATTERY-STATUS_IPKG_TMP)/CONTROL/control
	echo "Priority: optional" 			>>$(BATTERY-STATUS_IPKG_TMP)/CONTROL/control
	echo "Section: ROX"	 			>>$(BATTERY-STATUS_IPKG_TMP)/CONTROL/control
	echo "Maintainer: Alexander Chukov <sash@pdaXrom.org>">>$(BATTERY-STATUS_IPKG_TMP)/CONTROL/control
	echo "Architecture: $(SHORT_TARGET)" 		>>$(BATTERY-STATUS_IPKG_TMP)/CONTROL/control
	echo "Version: $(BATTERY-STATUS_VERSION)" 	>>$(BATTERY-STATUS_IPKG_TMP)/CONTROL/control
	echo "Depends: gtk2" 				>>$(BATTERY-STATUS_IPKG_TMP)/CONTROL/control
	echo "Description: Applet that shows the status of you laptop battery.">>$(BATTERY-STATUS_IPKG_TMP)/CONTROL/control
	cd $(FEEDDIR) && $(XMKIPKG) $(BATTERY-STATUS_IPKG_TMP)
	rm -rf $(BATTERY-STATUS_IPKG_TMP)
	touch $@

# ----------------------------------------------------------------------------
# Image-Install
# ----------------------------------------------------------------------------

ifdef PTXCONF_BATTERY-STATUS_INSTALL
ROMPACKAGES += $(STATEDIR)/Battery-Status.imageinstall
endif

Battery-Status_imageinstall_deps = $(STATEDIR)/Battery-Status.targetinstall \
	$(STATEDIR)/virtual-image.install

$(STATEDIR)/Battery-Status.imageinstall: $(Battery-Status_imageinstall_deps)
	@$(call targetinfo, $@)
	cd $(FEEDDIR) && $(XIPKG) install battery-status
	touch $@

# ----------------------------------------------------------------------------
# Clean
# ----------------------------------------------------------------------------

Battery-Status_clean:
	rm -rf $(STATEDIR)/Battery-Status.*
	rm -rf $(BATTERY-STATUS_DIR)

# vim: syntax=make
