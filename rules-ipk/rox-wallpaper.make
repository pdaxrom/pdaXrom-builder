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
ifdef PTXCONF_ROX-WALLPAPER
PACKAGES += rox-wallpaper
endif

#
# Paths and names
#
ROX-WALLPAPER_VERSION	= 1.9.2
ROX-WALLPAPER		= wallpaper-$(ROX-WALLPAPER_VERSION)
ROX-WALLPAPER_SUFFIX	= tgz
ROX-WALLPAPER_URL	= http://heanet.dl.sourceforge.net/sourceforge/rox/$(ROX-WALLPAPER).$(ROX-WALLPAPER_SUFFIX)
ROX-WALLPAPER_SOURCE	= $(SRCDIR)/$(ROX-WALLPAPER).$(ROX-WALLPAPER_SUFFIX)
ROX-WALLPAPER_DIR	= $(BUILDDIR)/$(ROX-WALLPAPER)
ROX-WALLPAPER_IPKG_TMP	= $(ROX-WALLPAPER_DIR)/ipkg_tmp

# ----------------------------------------------------------------------------
# Get
# ----------------------------------------------------------------------------

rox-wallpaper_get: $(STATEDIR)/rox-wallpaper.get

rox-wallpaper_get_deps = $(ROX-WALLPAPER_SOURCE)

$(STATEDIR)/rox-wallpaper.get: $(rox-wallpaper_get_deps)
	@$(call targetinfo, $@)
	@$(call get_patches, $(ROX-WALLPAPER))
	touch $@

$(ROX-WALLPAPER_SOURCE):
	@$(call targetinfo, $@)
	@$(call get, $(ROX-WALLPAPER_URL))

# ----------------------------------------------------------------------------
# Extract
# ----------------------------------------------------------------------------

rox-wallpaper_extract: $(STATEDIR)/rox-wallpaper.extract

rox-wallpaper_extract_deps = $(STATEDIR)/rox-wallpaper.get

$(STATEDIR)/rox-wallpaper.extract: $(rox-wallpaper_extract_deps)
	@$(call targetinfo, $@)
	@$(call clean, $(ROX-WALLPAPER_DIR))
	@$(call extract, $(ROX-WALLPAPER_SOURCE))
	@$(call patchin, $(ROX-WALLPAPER))
	touch $@

# ----------------------------------------------------------------------------
# Prepare
# ----------------------------------------------------------------------------

rox-wallpaper_prepare: $(STATEDIR)/rox-wallpaper.prepare

#
# dependencies
#
rox-wallpaper_prepare_deps = \
	$(STATEDIR)/rox-wallpaper.extract \
	$(STATEDIR)/ROX-Session.install \
	$(STATEDIR)/virtual-xchain.install

ROX-WALLPAPER_PATH	=  PATH=$(CROSS_PATH)
ROX-WALLPAPER_ENV 	=  $(CROSS_ENV)
#ROX-WALLPAPER_ENV	+=
ROX-WALLPAPER_ENV	+= PKG_CONFIG_PATH=$(CROSS_LIB_DIR)/lib/pkgconfig:$(CROSS_LIB_DIR)/lib/pkgconfig
#ifdef PTXCONF_XFREE430
#ROX-WALLPAPER_ENV	+= LDFLAGS=-Wl,-rpath-link,$(CROSS_LIB_DIR)/lib
#endif

#
# autoconf
#
ROX-WALLPAPER_AUTOCONF = \
	--build=$(GNU_HOST) \
	--host=$(PTXCONF_GNU_TARGET) \
	--prefix=/usr

ifdef PTXCONF_XFREE430
ROX-WALLPAPER_AUTOCONF += --x-includes=$(CROSS_LIB_DIR)/include
ROX-WALLPAPER_AUTOCONF += --x-libraries=$(CROSS_LIB_DIR)/lib
endif

$(STATEDIR)/rox-wallpaper.prepare: $(rox-wallpaper_prepare_deps)
	@$(call targetinfo, $@)
	@$(call clean, $(ROX-WALLPAPER_DIR)/config.cache)
	touch $@

# ----------------------------------------------------------------------------
# Compile
# ----------------------------------------------------------------------------

rox-wallpaper_compile: $(STATEDIR)/rox-wallpaper.compile

rox-wallpaper_compile_deps = $(STATEDIR)/rox-wallpaper.prepare

$(STATEDIR)/rox-wallpaper.compile: $(rox-wallpaper_compile_deps)
	@$(call targetinfo, $@)
	touch $@

# ----------------------------------------------------------------------------
# Install
# ----------------------------------------------------------------------------

rox-wallpaper_install: $(STATEDIR)/rox-wallpaper.install

$(STATEDIR)/rox-wallpaper.install: $(STATEDIR)/rox-wallpaper.compile
	@$(call targetinfo, $@)
	touch $@

# ----------------------------------------------------------------------------
# Target-Install
# ----------------------------------------------------------------------------

rox-wallpaper_targetinstall: $(STATEDIR)/rox-wallpaper.targetinstall

rox-wallpaper_targetinstall_deps = $(STATEDIR)/rox-wallpaper.compile \
	$(STATEDIR)/ROX-Session.targetinstall

$(STATEDIR)/rox-wallpaper.targetinstall: $(rox-wallpaper_targetinstall_deps)
	@$(call targetinfo, $@)
	mkdir -p $(ROX-WALLPAPER_IPKG_TMP)/usr/apps/Settings
	cp -a $(ROX-WALLPAPER_DIR)/Wallpaper $(ROX-WALLPAPER_IPKG_TMP)/usr/apps/Settings
	mkdir -p $(ROX-WALLPAPER_IPKG_TMP)/CONTROL
	echo "Package: wallpaper" 			>$(ROX-WALLPAPER_IPKG_TMP)/CONTROL/control
	echo "Priority: optional" 			>>$(ROX-WALLPAPER_IPKG_TMP)/CONTROL/control
	echo "Section: ROX" 				>>$(ROX-WALLPAPER_IPKG_TMP)/CONTROL/control
	echo "Maintainer: Alexander Chukov <sash@pdaXrom.org>">>$(ROX-WALLPAPER_IPKG_TMP)/CONTROL/control
	echo "Architecture: $(SHORT_TARGET)" 		>>$(ROX-WALLPAPER_IPKG_TMP)/CONTROL/control
	echo "Version: $(ROX-WALLPAPER_VERSION)" 	>>$(ROX-WALLPAPER_IPKG_TMP)/CONTROL/control
	echo "Depends: rox-session" 			>>$(ROX-WALLPAPER_IPKG_TMP)/CONTROL/control
	echo "Description: Choose a random image for your desktop background">>$(ROX-WALLPAPER_IPKG_TMP)/CONTROL/control
	cd $(FEEDDIR) && $(XMKIPKG) $(ROX-WALLPAPER_IPKG_TMP)
	touch $@

# ----------------------------------------------------------------------------
# Image-Install
# ----------------------------------------------------------------------------

ifdef PTXCONF_ROX-WALLPAPER_INSTALL
ROMPACKAGES += $(STATEDIR)/rox-wallpaper.imageinstall
endif

rox-wallpaper_imageinstall_deps = $(STATEDIR)/rox-wallpaper.targetinstall \
	$(STATEDIR)/virtual-image.install

$(STATEDIR)/rox-wallpaper.imageinstall: $(rox-wallpaper_imageinstall_deps)
	@$(call targetinfo, $@)
	cd $(FEEDDIR) && $(XIPKG) install wallpaper
	touch $@

# ----------------------------------------------------------------------------
# Clean
# ----------------------------------------------------------------------------

rox-wallpaper_clean:
	rm -rf $(STATEDIR)/rox-wallpaper.*
	rm -rf $(ROX-WALLPAPER_DIR)

# vim: syntax=make
