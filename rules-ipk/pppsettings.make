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
ifdef PTXCONF_PPPSETTINGS
PACKAGES += pppsettings
endif

#
# Paths and names
#
PPPSETTINGS_VENDOR_VERSION = 1
PPPSETTINGS_VERSION	= 1.0.3
PPPSETTINGS		= pppsettings-$(PPPSETTINGS_VERSION)
PPPSETTINGS_SUFFIX	= tar.bz2
PPPSETTINGS_URL		= http://www.pdaXrom.org/src/$(PPPSETTINGS).$(PPPSETTINGS_SUFFIX)
PPPSETTINGS_SOURCE	= $(SRCDIR)/$(PPPSETTINGS).$(PPPSETTINGS_SUFFIX)
PPPSETTINGS_DIR		= $(BUILDDIR)/$(PPPSETTINGS)
PPPSETTINGS_IPKG_TMP	= $(PPPSETTINGS_DIR)/ipkg_root

# ----------------------------------------------------------------------------
# Get
# ----------------------------------------------------------------------------

pppsettings_get: $(STATEDIR)/pppsettings.get

pppsettings_get_deps = $(PPPSETTINGS_SOURCE)

$(STATEDIR)/pppsettings.get: $(pppsettings_get_deps)
	@$(call targetinfo, $@)
	@$(call get_patches, $(PPPSETTINGS))
	touch $@

$(PPPSETTINGS_SOURCE):
	@$(call targetinfo, $@)
	@$(call get, $(PPPSETTINGS_URL))

# ----------------------------------------------------------------------------
# Extract
# ----------------------------------------------------------------------------

pppsettings_extract: $(STATEDIR)/pppsettings.extract

pppsettings_extract_deps = $(STATEDIR)/pppsettings.get

$(STATEDIR)/pppsettings.extract: $(pppsettings_extract_deps)
	@$(call targetinfo, $@)
	@$(call clean, $(PPPSETTINGS_DIR))
	@$(call extract, $(PPPSETTINGS_SOURCE))
	@$(call patchin, $(PPPSETTINGS))
	touch $@

# ----------------------------------------------------------------------------
# Prepare
# ----------------------------------------------------------------------------

pppsettings_prepare: $(STATEDIR)/pppsettings.prepare

#
# dependencies
#
pppsettings_prepare_deps = \
	$(STATEDIR)/pppsettings.extract \
	$(STATEDIR)/startup-notification.install \
	$(STATEDIR)/qt-x11-free.install \
	$(STATEDIR)/virtual-xchain.install

PPPSETTINGS_PATH	=  PATH=$(QT-X11-FREE_DIR)/bin:$(CROSS_PATH)
PPPSETTINGS_ENV 	=  $(CROSS_ENV)
PPPSETTINGS_ENV		+= QTDIR=$(QT-X11-FREE_DIR)
PPPSETTINGS_ENV		+= PKG_CONFIG_PATH=$(CROSS_LIB_DIR)/lib/pkgconfig:$(CROSS_LIB_DIR)/lib/pkgconfig

#
# autoconf
#
PPPSETTINGS_AUTOCONF = \
	--build=$(GNU_HOST) \
	--host=$(PTXCONF_GNU_TARGET) \
	--prefix=/usr

ifdef PTXCONF_XFREE430
PPPSETTINGS_AUTOCONF += --x-includes=$(CROSS_LIB_DIR)/include
PPPSETTINGS_AUTOCONF += --x-libraries=$(CROSS_LIB_DIR)/lib
endif

$(STATEDIR)/pppsettings.prepare: $(pppsettings_prepare_deps)
	@$(call targetinfo, $@)
	@$(call clean, $(PPPSETTINGS_DIR)/config.cache)
	cd $(PPPSETTINGS_DIR) && \
		$(PPPSETTINGS_PATH) $(PPPSETTINGS_ENV) \
		qmake pppsettings.pro
	touch $@

# ----------------------------------------------------------------------------
# Compile
# ----------------------------------------------------------------------------

pppsettings_compile: $(STATEDIR)/pppsettings.compile

pppsettings_compile_deps = $(STATEDIR)/pppsettings.prepare

$(STATEDIR)/pppsettings.compile: $(pppsettings_compile_deps)
	@$(call targetinfo, $@)
	$(PPPSETTINGS_PATH) $(PPPSETTINGS_ENV) $(MAKE) -C $(PPPSETTINGS_DIR) UIC=uic
	touch $@

# ----------------------------------------------------------------------------
# Install
# ----------------------------------------------------------------------------

pppsettings_install: $(STATEDIR)/pppsettings.install

$(STATEDIR)/pppsettings.install: $(STATEDIR)/pppsettings.compile
	@$(call targetinfo, $@)
	touch $@

# ----------------------------------------------------------------------------
# Target-Install
# ----------------------------------------------------------------------------

pppsettings_targetinstall: $(STATEDIR)/pppsettings.targetinstall

pppsettings_targetinstall_deps = $(STATEDIR)/pppsettings.compile \
	$(STATEDIR)/qt-x11-free.targetinstall \
	$(STATEDIR)/startup-notification.targetinstall

$(STATEDIR)/pppsettings.targetinstall: $(pppsettings_targetinstall_deps)
	@$(call targetinfo, $@)
	$(CROSSSTRIP) $(PPPSETTINGS_IPKG_TMP)/usr/lib/qt/bin/*
	mkdir -p $(PPPSETTINGS_IPKG_TMP)/CONTROL
	echo "Package: pppsettings" 						 >$(PPPSETTINGS_IPKG_TMP)/CONTROL/control
	echo "Priority: optional" 						>>$(PPPSETTINGS_IPKG_TMP)/CONTROL/control
	echo "Section: X11"				 			>>$(PPPSETTINGS_IPKG_TMP)/CONTROL/control
	echo "Maintainer: Alexander Chukov <sash@pdaXrom.org>" 			>>$(PPPSETTINGS_IPKG_TMP)/CONTROL/control
	echo "Architecture: $(SHORT_TARGET)" 					>>$(PPPSETTINGS_IPKG_TMP)/CONTROL/control
	echo "Version: $(PPPSETTINGS_VERSION)-$(PPPSETTINGS_VENDOR_VERSION)" 	>>$(PPPSETTINGS_IPKG_TMP)/CONTROL/control
	echo "Depends: qt-mt, startup-notification" 				>>$(PPPSETTINGS_IPKG_TMP)/CONTROL/control
	echo "Description: PPP settings tools and dialer"			>>$(PPPSETTINGS_IPKG_TMP)/CONTROL/control
	cd $(FEEDDIR) && $(XMKIPKG) $(PPPSETTINGS_IPKG_TMP)
	touch $@

# ----------------------------------------------------------------------------
# Image-Install
# ----------------------------------------------------------------------------

ifdef PTXCONF_PPPSETTINGS_INSTALL
ROMPACKAGES += $(STATEDIR)/pppsettings.imageinstall
endif

pppsettings_imageinstall_deps = $(STATEDIR)/pppsettings.targetinstall \
	$(STATEDIR)/virtual-image.install

$(STATEDIR)/pppsettings.imageinstall: $(pppsettings_imageinstall_deps)
	@$(call targetinfo, $@)
	cd $(FEEDDIR) && $(XIPKG) install pppsettings
	touch $@

# ----------------------------------------------------------------------------
# Clean
# ----------------------------------------------------------------------------

pppsettings_clean:
	rm -rf $(STATEDIR)/pppsettings.*
	rm -rf $(PPPSETTINGS_DIR)

# vim: syntax=make
