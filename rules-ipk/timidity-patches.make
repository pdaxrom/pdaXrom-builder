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
ifdef PTXCONF_TIMIDITY-PATCHES
PACKAGES += timidity-patches
endif

#
# Paths and names
#
TIMIDITY-PATCHES_VERSION	= 1.0.0
TIMIDITY-PATCHES		= timidity-patches-$(TIMIDITY-PATCHES_VERSION)
TIMIDITY-PATCHES_SUFFIX		= tar.bz2
TIMIDITY-PATCHES_URL		= http://www.pdaXrom.org/src/$(TIMIDITY-PATCHES).$(TIMIDITY-PATCHES_SUFFIX)
TIMIDITY-PATCHES_SOURCE		= $(SRCDIR)/$(TIMIDITY-PATCHES).$(TIMIDITY-PATCHES_SUFFIX)
TIMIDITY-PATCHES_DIR		= $(BUILDDIR)/$(TIMIDITY-PATCHES)
TIMIDITY-PATCHES_IPKG_TMP	= $(TIMIDITY-PATCHES_DIR)

# ----------------------------------------------------------------------------
# Get
# ----------------------------------------------------------------------------

timidity-patches_get: $(STATEDIR)/timidity-patches.get

timidity-patches_get_deps = $(TIMIDITY-PATCHES_SOURCE)

$(STATEDIR)/timidity-patches.get: $(timidity-patches_get_deps)
	@$(call targetinfo, $@)
	@$(call get_patches, $(TIMIDITY-PATCHES))
	touch $@

$(TIMIDITY-PATCHES_SOURCE):
	@$(call targetinfo, $@)
	@$(call get, $(TIMIDITY-PATCHES_URL))

# ----------------------------------------------------------------------------
# Extract
# ----------------------------------------------------------------------------

timidity-patches_extract: $(STATEDIR)/timidity-patches.extract

timidity-patches_extract_deps = $(STATEDIR)/timidity-patches.get

$(STATEDIR)/timidity-patches.extract: $(timidity-patches_extract_deps)
	@$(call targetinfo, $@)
	@$(call clean, $(TIMIDITY-PATCHES_DIR))
	@$(call extract, $(TIMIDITY-PATCHES_SOURCE))
	@$(call patchin, $(TIMIDITY-PATCHES))
	touch $@

# ----------------------------------------------------------------------------
# Prepare
# ----------------------------------------------------------------------------

timidity-patches_prepare: $(STATEDIR)/timidity-patches.prepare

#
# dependencies
#
timidity-patches_prepare_deps = \
	$(STATEDIR)/timidity-patches.extract \
	$(STATEDIR)/virtual-xchain.install

TIMIDITY-PATCHES_PATH	=  PATH=$(CROSS_PATH)
TIMIDITY-PATCHES_ENV 	=  $(CROSS_ENV)
#TIMIDITY-PATCHES_ENV	+=
TIMIDITY-PATCHES_ENV	+= PKG_CONFIG_PATH=$(CROSS_LIB_DIR)/lib/pkgconfig:$(CROSS_LIB_DIR)/lib/pkgconfig
#ifdef PTXCONF_XFREE430
#TIMIDITY-PATCHES_ENV	+= LDFLAGS=-Wl,-rpath-link,$(CROSS_LIB_DIR)/lib
#endif

#
# autoconf
#
TIMIDITY-PATCHES_AUTOCONF = \
	--build=$(GNU_HOST) \
	--host=$(PTXCONF_GNU_TARGET) \
	--prefix=/usr

ifdef PTXCONF_XFREE430
TIMIDITY-PATCHES_AUTOCONF += --x-includes=$(CROSS_LIB_DIR)/include
TIMIDITY-PATCHES_AUTOCONF += --x-libraries=$(CROSS_LIB_DIR)/lib
endif

$(STATEDIR)/timidity-patches.prepare: $(timidity-patches_prepare_deps)
	@$(call targetinfo, $@)
	@$(call clean, $(TIMIDITY-PATCHES_DIR)/config.cache)
	#cd $(TIMIDITY-PATCHES_DIR) && \
	#	$(TIMIDITY-PATCHES_PATH) $(TIMIDITY-PATCHES_ENV) \
	#	./configure $(TIMIDITY-PATCHES_AUTOCONF)
	touch $@

# ----------------------------------------------------------------------------
# Compile
# ----------------------------------------------------------------------------

timidity-patches_compile: $(STATEDIR)/timidity-patches.compile

timidity-patches_compile_deps = $(STATEDIR)/timidity-patches.prepare

$(STATEDIR)/timidity-patches.compile: $(timidity-patches_compile_deps)
	@$(call targetinfo, $@)
	#$(TIMIDITY-PATCHES_PATH) $(MAKE) -C $(TIMIDITY-PATCHES_DIR)
	touch $@

# ----------------------------------------------------------------------------
# Install
# ----------------------------------------------------------------------------

timidity-patches_install: $(STATEDIR)/timidity-patches.install

$(STATEDIR)/timidity-patches.install: $(STATEDIR)/timidity-patches.compile
	@$(call targetinfo, $@)
	#$(TIMIDITY-PATCHES_PATH) $(MAKE) -C $(TIMIDITY-PATCHES_DIR) install
	touch $@

# ----------------------------------------------------------------------------
# Target-Install
# ----------------------------------------------------------------------------

timidity-patches_targetinstall: $(STATEDIR)/timidity-patches.targetinstall

timidity-patches_targetinstall_deps = $(STATEDIR)/timidity-patches.compile

$(STATEDIR)/timidity-patches.targetinstall: $(timidity-patches_targetinstall_deps)
	@$(call targetinfo, $@)
	#$(TIMIDITY-PATCHES_PATH) $(MAKE) -C $(TIMIDITY-PATCHES_DIR) DESTDIR=$(TIMIDITY-PATCHES_IPKG_TMP) install
	mkdir -p $(TIMIDITY-PATCHES_IPKG_TMP)/CONTROL
	echo "Package: timidity-patches" 							>$(TIMIDITY-PATCHES_IPKG_TMP)/CONTROL/control
	echo "Priority: optional" 								>>$(TIMIDITY-PATCHES_IPKG_TMP)/CONTROL/control
	echo "Section: Multimedia" 								>>$(TIMIDITY-PATCHES_IPKG_TMP)/CONTROL/control
	echo "Maintainer: Alexander Chukov <sash@pdaXrom.org>" 					>>$(TIMIDITY-PATCHES_IPKG_TMP)/CONTROL/control
	echo "Architecture: $(SHORT_TARGET)" 							>>$(TIMIDITY-PATCHES_IPKG_TMP)/CONTROL/control
	echo "Version: $(TIMIDITY-PATCHES_VERSION)" 						>>$(TIMIDITY-PATCHES_IPKG_TMP)/CONTROL/control
	echo "Depends: timidity" 								>>$(TIMIDITY-PATCHES_IPKG_TMP)/CONTROL/control
	echo "Description: 10MB TiMidity voice patches"						>>$(TIMIDITY-PATCHES_IPKG_TMP)/CONTROL/control
	cd $(FEEDDIR) && $(XMKIPKG) $(TIMIDITY-PATCHES_IPKG_TMP)
	touch $@

# ----------------------------------------------------------------------------
# Image-Install
# ----------------------------------------------------------------------------

ifdef PTXCONF_TIMIDITY-PATCHES_INSTALL
ROMPACKAGES += $(STATEDIR)/timidity-patches.imageinstall
endif

timidity-patches_imageinstall_deps = $(STATEDIR)/timidity-patches.targetinstall \
	$(STATEDIR)/virtual-image.install

$(STATEDIR)/timidity-patches.imageinstall: $(timidity-patches_imageinstall_deps)
	@$(call targetinfo, $@)
	cd $(FEEDDIR) && $(XIPKG) install timidity-patches
	touch $@

# ----------------------------------------------------------------------------
# Clean
# ----------------------------------------------------------------------------

timidity-patches_clean:
	rm -rf $(STATEDIR)/timidity-patches.*
	rm -rf $(TIMIDITY-PATCHES_DIR)

# vim: syntax=make
