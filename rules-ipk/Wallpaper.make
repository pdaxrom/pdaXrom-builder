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
ifdef PTXCONF_WALLPAPER
PACKAGES += Wallpaper
endif

#
# Paths and names
#
WALLPAPER_VERSION	= 1.9.2
WALLPAPER		= Wallpaper-$(WALLPAPER_VERSION)
WALLPAPER_SUFFIX		= tgz
WALLPAPER_URL		= http://heanet.dl.sourceforge.net/sourceforge/rox/$(WALLPAPER).$(WALLPAPER_SUFFIX)
WALLPAPER_SOURCE		= $(SRCDIR)/$(WALLPAPER).$(WALLPAPER_SUFFIX)
WALLPAPER_DIR		= $(BUILDDIR)/$(WALLPAPER)
WALLPAPER_IPKG_TMP	= $(WALLPAPER_DIR)/ipkg_tmp

# ----------------------------------------------------------------------------
# Get
# ----------------------------------------------------------------------------

Wallpaper_get: $(STATEDIR)/Wallpaper.get

Wallpaper_get_deps = $(WALLPAPER_SOURCE)

$(STATEDIR)/Wallpaper.get: $(Wallpaper_get_deps)
	@$(call targetinfo, $@)
	@$(call get_patches, $(WALLPAPER))
	touch $@

$(WALLPAPER_SOURCE):
	@$(call targetinfo, $@)
	@$(call get, $(WALLPAPER_URL))

# ----------------------------------------------------------------------------
# Extract
# ----------------------------------------------------------------------------

Wallpaper_extract: $(STATEDIR)/Wallpaper.extract

Wallpaper_extract_deps = $(STATEDIR)/Wallpaper.get

$(STATEDIR)/Wallpaper.extract: $(Wallpaper_extract_deps)
	@$(call targetinfo, $@)
	@$(call clean, $(WALLPAPER_DIR))
	@$(call extract, $(WALLPAPER_SOURCE))
	@$(call patchin, $(WALLPAPER))
	touch $@

# ----------------------------------------------------------------------------
# Prepare
# ----------------------------------------------------------------------------

Wallpaper_prepare: $(STATEDIR)/Wallpaper.prepare

#
# dependencies
#
Wallpaper_prepare_deps = \
	$(STATEDIR)/Wallpaper.extract \
	$(STATEDIR)/virtual-xchain.install

WALLPAPER_PATH	=  PATH=$(CROSS_PATH)
WALLPAPER_ENV 	=  $(CROSS_ENV)
#WALLPAPER_ENV	+=
WALLPAPER_ENV	+= PKG_CONFIG_PATH=$(CROSS_LIB_DIR)/lib/pkgconfig:$(CROSS_LIB_DIR)/lib/pkgconfig
#ifdef PTXCONF_XFREE430
#WALLPAPER_ENV	+= LDFLAGS=-Wl,-rpath-link,$(CROSS_LIB_DIR)/lib
#endif

#
# autoconf
#
WALLPAPER_AUTOCONF = \
	--build=$(GNU_HOST) \
	--host=$(PTXCONF_GNU_TARGET) \
	--prefix=/usr

ifdef PTXCONF_XFREE430
WALLPAPER_AUTOCONF += --x-includes=$(CROSS_LIB_DIR)/include
WALLPAPER_AUTOCONF += --x-libraries=$(CROSS_LIB_DIR)/lib
endif

$(STATEDIR)/Wallpaper.prepare: $(Wallpaper_prepare_deps)
	@$(call targetinfo, $@)
	@$(call clean, $(WALLPAPER_DIR)/config.cache)
	cd $(WALLPAPER_DIR) && \
		$(WALLPAPER_PATH) $(WALLPAPER_ENV) \
		./configure $(WALLPAPER_AUTOCONF)
	touch $@

# ----------------------------------------------------------------------------
# Compile
# ----------------------------------------------------------------------------

Wallpaper_compile: $(STATEDIR)/Wallpaper.compile

Wallpaper_compile_deps = $(STATEDIR)/Wallpaper.prepare

$(STATEDIR)/Wallpaper.compile: $(Wallpaper_compile_deps)
	@$(call targetinfo, $@)
	$(WALLPAPER_PATH) $(MAKE) -C $(WALLPAPER_DIR)
	touch $@

# ----------------------------------------------------------------------------
# Install
# ----------------------------------------------------------------------------

Wallpaper_install: $(STATEDIR)/Wallpaper.install

$(STATEDIR)/Wallpaper.install: $(STATEDIR)/Wallpaper.compile
	@$(call targetinfo, $@)
	$(WALLPAPER_PATH) $(MAKE) -C $(WALLPAPER_DIR) install
	touch $@

# ----------------------------------------------------------------------------
# Target-Install
# ----------------------------------------------------------------------------

Wallpaper_targetinstall: $(STATEDIR)/Wallpaper.targetinstall

Wallpaper_targetinstall_deps = $(STATEDIR)/Wallpaper.compile

$(STATEDIR)/Wallpaper.targetinstall: $(Wallpaper_targetinstall_deps)
	@$(call targetinfo, $@)
	$(WALLPAPER_PATH) $(MAKE) -C $(WALLPAPER_DIR) DESTDIR=$(WALLPAPER_IPKG_TMP) install
	mkdir -p $(WALLPAPER_IPKG_TMP)/CONTROL
	echo "Package: wallpaper" 			>$(WALLPAPER_IPKG_TMP)/CONTROL/control
	echo "Priority: optional" 			>>$(WALLPAPER_IPKG_TMP)/CONTROL/control
	echo "Section: pdaXrom" 			>>$(WALLPAPER_IPKG_TMP)/CONTROL/control
	echo "Maintainer: Alexander Chukov <sash@pdaXrom.org>" 			>>$(WALLPAPER_IPKG_TMP)/CONTROL/control
	echo "Architecture: $(SHORT_TARGET)" 		>>$(WALLPAPER_IPKG_TMP)/CONTROL/control
	echo "Version: $(WALLPAPER_VERSION)" 		>>$(WALLPAPER_IPKG_TMP)/CONTROL/control
	echo "Depends: " 				>>$(WALLPAPER_IPKG_TMP)/CONTROL/control
	echo "Description: generated with pdaXrom builder">>$(WALLPAPER_IPKG_TMP)/CONTROL/control
	cd $(FEEDDIR) && $(XMKIPKG) $(WALLPAPER_IPKG_TMP)
	touch $@

# ----------------------------------------------------------------------------
# Image-Install
# ----------------------------------------------------------------------------

ifdef PTXCONF_WALLPAPER_INSTALL
ROMPACKAGES += $(STATEDIR)/Wallpaper.imageinstall
endif

Wallpaper_imageinstall_deps = $(STATEDIR)/Wallpaper.targetinstall \
	$(STATEDIR)/virtual-image.install

$(STATEDIR)/Wallpaper.imageinstall: $(Wallpaper_imageinstall_deps)
	@$(call targetinfo, $@)
	cd $(FEEDDIR) && $(XIPKG) install wallpaper
	touch $@

# ----------------------------------------------------------------------------
# Clean
# ----------------------------------------------------------------------------

Wallpaper_clean:
	rm -rf $(STATEDIR)/Wallpaper.*
	rm -rf $(WALLPAPER_DIR)

# vim: syntax=make
