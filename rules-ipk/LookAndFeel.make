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
ifdef PTXCONF_LOOKANDFEEL
PACKAGES += LookAndFeel
endif

#
# Paths and names
#
LOOKANDFEEL_VERSION	= 0.0.1
LOOKANDFEEL		= config
LOOKANDFEEL_SUFFIX	= tgz
LOOKANDFEEL_URL		= http://rox.sourceforge.net/snapshots/config.tgz
LOOKANDFEEL_SOURCE	= $(SRCDIR)/$(LOOKANDFEEL).$(LOOKANDFEEL_SUFFIX)
LOOKANDFEEL_DIR		= $(BUILDDIR)/$(LOOKANDFEEL)
LOOKANDFEEL_IPKG_TMP	= $(LOOKANDFEEL_DIR)/ipkg_tmp

# ----------------------------------------------------------------------------
# Get
# ----------------------------------------------------------------------------

LookAndFeel_get: $(STATEDIR)/LookAndFeel.get

LookAndFeel_get_deps = $(LOOKANDFEEL_SOURCE)

$(STATEDIR)/LookAndFeel.get: $(LookAndFeel_get_deps)
	@$(call targetinfo, $@)
	@$(call get_patches, $(LOOKANDFEEL))
	touch $@

$(LOOKANDFEEL_SOURCE):
	@$(call targetinfo, $@)
	@$(call get, $(LOOKANDFEEL_URL))

# ----------------------------------------------------------------------------
# Extract
# ----------------------------------------------------------------------------

LookAndFeel_extract: $(STATEDIR)/LookAndFeel.extract

LookAndFeel_extract_deps = $(STATEDIR)/LookAndFeel.get

$(STATEDIR)/LookAndFeel.extract: $(LookAndFeel_extract_deps)
	@$(call targetinfo, $@)
	@$(call clean, $(LOOKANDFEEL_DIR))
	@$(call extract, $(LOOKANDFEEL_SOURCE))
	@$(call patchin, $(LOOKANDFEEL))
	touch $@

# ----------------------------------------------------------------------------
# Prepare
# ----------------------------------------------------------------------------

LookAndFeel_prepare: $(STATEDIR)/LookAndFeel.prepare

#
# dependencies
#
LookAndFeel_prepare_deps = \
	$(STATEDIR)/LookAndFeel.extract \
	$(STATEDIR)/ROX-Session.install \
	$(STATEDIR)/virtual-xchain.install

LOOKANDFEEL_PATH	=  PATH=$(CROSS_PATH)
LOOKANDFEEL_ENV 	=  $(CROSS_ENV)
#LOOKANDFEEL_ENV	+=
LOOKANDFEEL_ENV	+= PKG_CONFIG_PATH=$(CROSS_LIB_DIR)/lib/pkgconfig:$(CROSS_LIB_DIR)/lib/pkgconfig
#ifdef PTXCONF_XFREE430
#LOOKANDFEEL_ENV	+= LDFLAGS=-Wl,-rpath-link,$(CROSS_LIB_DIR)/lib
#endif

#
# autoconf
#
LOOKANDFEEL_AUTOCONF = \
	--build=$(GNU_HOST) \
	--host=$(PTXCONF_GNU_TARGET) \
	--prefix=/usr

ifdef PTXCONF_XFREE430
LOOKANDFEEL_AUTOCONF += --x-includes=$(CROSS_LIB_DIR)/include
LOOKANDFEEL_AUTOCONF += --x-libraries=$(CROSS_LIB_DIR)/lib
endif

$(STATEDIR)/LookAndFeel.prepare: $(LookAndFeel_prepare_deps)
	@$(call targetinfo, $@)
	@$(call clean, $(LOOKANDFEEL_DIR)/config.cache)
	touch $@

# ----------------------------------------------------------------------------
# Compile
# ----------------------------------------------------------------------------

LookAndFeel_compile: $(STATEDIR)/LookAndFeel.compile

LookAndFeel_compile_deps = $(STATEDIR)/LookAndFeel.prepare

$(STATEDIR)/LookAndFeel.compile: $(LookAndFeel_compile_deps)
	@$(call targetinfo, $@)
	touch $@

# ----------------------------------------------------------------------------
# Install
# ----------------------------------------------------------------------------

LookAndFeel_install: $(STATEDIR)/LookAndFeel.install

$(STATEDIR)/LookAndFeel.install: $(STATEDIR)/LookAndFeel.compile
	@$(call targetinfo, $@)
	touch $@

# ----------------------------------------------------------------------------
# Target-Install
# ----------------------------------------------------------------------------

LookAndFeel_targetinstall: $(STATEDIR)/LookAndFeel.targetinstall

LookAndFeel_targetinstall_deps = $(STATEDIR)/LookAndFeel.compile \
	$(STATEDIR)/ROX-Session.targetinstall

$(STATEDIR)/LookAndFeel.targetinstall: $(LookAndFeel_targetinstall_deps)
	@$(call targetinfo, $@)
	mkdir -p $(LOOKANDFEEL_IPKG_TMP)/usr/apps/Settings
	cp -a $(LOOKANDFEEL_DIR)/LookAndFeel $(LOOKANDFEEL_IPKG_TMP)/usr/apps/Settings
	rm -rf $(LOOKANDFEEL_IPKG_TMP)/usr/apps/Settings/LookAndFeel/CVS
	mkdir -p $(LOOKANDFEEL_IPKG_TMP)/CONTROL
	echo "Package: lookandfeel" 			>$(LOOKANDFEEL_IPKG_TMP)/CONTROL/control
	echo "Priority: optional" 			>>$(LOOKANDFEEL_IPKG_TMP)/CONTROL/control
	echo "Section: ROX" 				>>$(LOOKANDFEEL_IPKG_TMP)/CONTROL/control
	echo "Maintainer: Alexander Chukov <sash@pdaXrom.org>">>$(LOOKANDFEEL_IPKG_TMP)/CONTROL/control
	echo "Architecture: $(SHORT_TARGET)" 		>>$(LOOKANDFEEL_IPKG_TMP)/CONTROL/control
	echo "Version: $(LOOKANDFEEL_VERSION)" 		>>$(LOOKANDFEEL_IPKG_TMP)/CONTROL/control
	echo "Depends: rox-session" 			>>$(LOOKANDFEEL_IPKG_TMP)/CONTROL/control
	echo "Description: LookAndFeel is a small Python application that lets you set things like the default font, theme, cursor blink rate, mouse speed, etc.">>$(LOOKANDFEEL_IPKG_TMP)/CONTROL/control
	cd $(FEEDDIR) && $(XMKIPKG) $(LOOKANDFEEL_IPKG_TMP)
	touch $@

# ----------------------------------------------------------------------------
# Image-Install
# ----------------------------------------------------------------------------

ifdef PTXCONF_LOOKANDFEEL_INSTALL
ROMPACKAGES += $(STATEDIR)/LookAndFeel.imageinstall
endif

LookAndFeel_imageinstall_deps = $(STATEDIR)/LookAndFeel.targetinstall \
	$(STATEDIR)/virtual-image.install

$(STATEDIR)/LookAndFeel.imageinstall: $(LookAndFeel_imageinstall_deps)
	@$(call targetinfo, $@)
	cd $(FEEDDIR) && $(XIPKG) install lookandfeel
	touch $@

# ----------------------------------------------------------------------------
# Clean
# ----------------------------------------------------------------------------

LookAndFeel_clean:
	rm -rf $(STATEDIR)/LookAndFeel.*
	rm -rf $(LOOKANDFEEL_DIR)

# vim: syntax=make
