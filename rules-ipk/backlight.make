# -*-makefile-*-
# $Id: template,v 1.10 2004/01/24 15:50:34 mkl Exp $
#
# Copyright (C) 2004 by Mikkel Skovgaard <laze@pdaxrom.org>
#          
# See CREDITS for details about who has contributed to this project.
#
# For further information about the PTXdist project and license conditions
# see the README file.
#

#
# We provide this package
#
ifdef PTXCONF_BACKLIGHT
PACKAGES += backlight
endif

#
# Paths and names
#
BACKLIGHT_VERSION	= 1.0.6
BACKLIGHT		= backlight-$(BACKLIGHT_VERSION)
BACKLIGHT_SUFFIX	= tar.bz2
BACKLIGHT_URL		= http://www.pdaXrom.org/src/$(BACKLIGHT).$(BACKLIGHT_SUFFIX)
BACKLIGHT_SOURCE	= $(SRCDIR)/$(BACKLIGHT).$(BACKLIGHT_SUFFIX)
BACKLIGHT_DIR		= $(BUILDDIR)/$(BACKLIGHT)
BACKLIGHT_IPKG_TMP	= $(BACKLIGHT_DIR)

# ----------------------------------------------------------------------------
# Get
# ----------------------------------------------------------------------------

backlight_get: $(STATEDIR)/backlight.get

backlight_get_deps = $(BACKLIGHT_SOURCE)

$(STATEDIR)/backlight.get: $(backlight_get_deps)
	@$(call targetinfo, $@)
	@$(call get_patches, $(BACKLIGHT))
	touch $@

$(BACKLIGHT_SOURCE):
	@$(call targetinfo, $@)
	@$(call get, $(BACKLIGHT_URL))

# ----------------------------------------------------------------------------
# Extract
# ----------------------------------------------------------------------------

backlight_extract: $(STATEDIR)/backlight.extract

backlight_extract_deps = $(STATEDIR)/backlight.get

$(STATEDIR)/backlight.extract: $(backlight_extract_deps)
	@$(call targetinfo, $@)
	@$(call clean, $(BACKLIGHT_DIR))
	@$(call extract, $(BACKLIGHT_SOURCE))
	@$(call patchin, $(BACKLIGHT))
	touch $@

# ----------------------------------------------------------------------------
# Prepare
# ----------------------------------------------------------------------------

backlight_prepare: $(STATEDIR)/backlight.prepare

#
# dependencies
#
backlight_prepare_deps = \
	$(STATEDIR)/backlight.extract \
	$(STATEDIR)/pygtk.install \
	$(STATEDIR)/virtual-xchain.install

BACKLIGHT_PATH	=  PATH=$(CROSS_PATH)
BACKLIGHT_ENV 	=  $(CROSS_ENV)
#BACKLIGHT_ENV	+=
BACKLIGHT_ENV	+= PKG_CONFIG_PATH=$(CROSS_LIB_DIR)/lib/pkgconfig:$(CROSS_LIB_DIR)/lib/pkgconfig
#ifdef PTXCONF_XFREE430
#BACKLIGHT_ENV	+= LDFLAGS=-Wl,-rpath-link,$(CROSS_LIB_DIR)/lib
#endif

#
# autoconf
#
BACKLIGHT_AUTOCONF = \
	--build=$(GNU_HOST) \
	--host=$(PTXCONF_GNU_TARGET) \
	--prefix=/usr

ifdef PTXCONF_XFREE430
BACKLIGHT_AUTOCONF += --x-includes=$(CROSS_LIB_DIR)/include
BACKLIGHT_AUTOCONF += --x-libraries=$(CROSS_LIB_DIR)/lib
endif

$(STATEDIR)/backlight.prepare: $(backlight_prepare_deps)
	@$(call targetinfo, $@)
	@$(call clean, $(BACKLIGHT_DIR)/config.cache)
	touch $@

# ----------------------------------------------------------------------------
# Compile
# ----------------------------------------------------------------------------

backlight_compile: $(STATEDIR)/backlight.compile

backlight_compile_deps = $(STATEDIR)/backlight.prepare

$(STATEDIR)/backlight.compile: $(backlight_compile_deps)
	@$(call targetinfo, $@)
	touch $@

# ----------------------------------------------------------------------------
# Install
# ----------------------------------------------------------------------------

backlight_install: $(STATEDIR)/backlight.install

$(STATEDIR)/backlight.install: $(STATEDIR)/backlight.compile
	@$(call targetinfo, $@)
	touch $@

# ----------------------------------------------------------------------------
# Target-Install
# ----------------------------------------------------------------------------

backlight_targetinstall: $(STATEDIR)/backlight.targetinstall

backlight_targetinstall_deps = $(STATEDIR)/backlight.compile \
	$(STATEDIR)/dbus.targetinstall \
	$(STATEDIR)/pygtk.targetinstall

$(STATEDIR)/backlight.targetinstall: $(backlight_targetinstall_deps)
	@$(call targetinfo, $@)
	mkdir -p $(BACKLIGHT_IPKG_TMP)/CONTROL
	echo "Package: backlight" 						 >$(BACKLIGHT_IPKG_TMP)/CONTROL/control
	echo "Priority: optional" 						>>$(BACKLIGHT_IPKG_TMP)/CONTROL/control
	echo "Section: X11"				 			>>$(BACKLIGHT_IPKG_TMP)/CONTROL/control
	echo "Maintainer: Mikkel Skovgaard <laze@pdaxrom.org>" 			>>$(BACKLIGHT_IPKG_TMP)/CONTROL/control
	echo "Architecture: $(SHORT_TARGET)" 					>>$(BACKLIGHT_IPKG_TMP)/CONTROL/control
	echo "Version: $(BACKLIGHT_VERSION)" 					>>$(BACKLIGHT_IPKG_TMP)/CONTROL/control
	echo "Depends: pygtk, python-core, python-codecs, python-dbus, python-fcntl, python-io, python-math, python-stringold, python-xml" >>$(BACKLIGHT_IPKG_TMP)/CONTROL/control
	echo "Description: Backlight settings"					>>$(BACKLIGHT_IPKG_TMP)/CONTROL/control
	cd $(FEEDDIR) && $(XMKIPKG) $(BACKLIGHT_IPKG_TMP)
	touch $@

# ----------------------------------------------------------------------------
# Image-Install
# ----------------------------------------------------------------------------

ifdef PTXCONF_BACKLIGHT_INSTALL
ROMPACKAGES += $(STATEDIR)/backlight.imageinstall
endif

backlight_imageinstall_deps = $(STATEDIR)/backlight.targetinstall \
	$(STATEDIR)/virtual-image.install

$(STATEDIR)/backlight.imageinstall: $(backlight_imageinstall_deps)
	@$(call targetinfo, $@)
	cd $(FEEDDIR) && $(XIPKG) install backlight
	touch $@

# ----------------------------------------------------------------------------
# Clean
# ----------------------------------------------------------------------------

backlight_clean:
	rm -rf $(STATEDIR)/backlight.*
	rm -rf $(BACKLIGHT_DIR)

# vim: syntax=make
