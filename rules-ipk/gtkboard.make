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
ifdef PTXCONF_GTKBOARD
PACKAGES += gtkboard
endif

#
# Paths and names
#
GTKBOARD_VERSION	= 0.11pre0
GTKBOARD		= gtkboard-$(GTKBOARD_VERSION)
GTKBOARD_SUFFIX		= tar.gz
GTKBOARD_URL		= http://heanet.dl.sourceforge.net/sourceforge/gtkboard/$(GTKBOARD).$(GTKBOARD_SUFFIX)
GTKBOARD_SOURCE		= $(SRCDIR)/$(GTKBOARD).$(GTKBOARD_SUFFIX)
GTKBOARD_DIR		= $(BUILDDIR)/$(GTKBOARD)
GTKBOARD_IPKG_TMP	= $(GTKBOARD_DIR)/ipkg_tmp

# ----------------------------------------------------------------------------
# Get
# ----------------------------------------------------------------------------

gtkboard_get: $(STATEDIR)/gtkboard.get

gtkboard_get_deps = $(GTKBOARD_SOURCE)

$(STATEDIR)/gtkboard.get: $(gtkboard_get_deps)
	@$(call targetinfo, $@)
	@$(call get_patches, $(GTKBOARD))
	touch $@

$(GTKBOARD_SOURCE):
	@$(call targetinfo, $@)
	@$(call get, $(GTKBOARD_URL))

# ----------------------------------------------------------------------------
# Extract
# ----------------------------------------------------------------------------

gtkboard_extract: $(STATEDIR)/gtkboard.extract

gtkboard_extract_deps = $(STATEDIR)/gtkboard.get

$(STATEDIR)/gtkboard.extract: $(gtkboard_extract_deps)
	@$(call targetinfo, $@)
	@$(call clean, $(GTKBOARD_DIR))
	@$(call extract, $(GTKBOARD_SOURCE))
	@$(call patchin, $(GTKBOARD))
	touch $@

# ----------------------------------------------------------------------------
# Prepare
# ----------------------------------------------------------------------------

gtkboard_prepare: $(STATEDIR)/gtkboard.prepare

#
# dependencies
#
gtkboard_prepare_deps = \
	$(STATEDIR)/gtkboard.extract \
	$(STATEDIR)/gtk22.install \
	$(STATEDIR)/SDL.install \
	$(STATEDIR)/SDL_mixer.install \
	$(STATEDIR)/virtual-xchain.install

GTKBOARD_PATH	=  PATH=$(CROSS_PATH)
GTKBOARD_ENV 	=  $(CROSS_ENV)
GTKBOARD_ENV	+= CFLAGS="$(TARGET_OPT_CFLAGS)"
GTKBOARD_ENV	+= PKG_CONFIG_PATH=$(CROSS_LIB_DIR)/lib/pkgconfig:$(CROSS_LIB_DIR)/lib/pkgconfig
#ifdef PTXCONF_XFREE430
#GTKBOARD_ENV	+= LDFLAGS=-Wl,-rpath-link,$(CROSS_LIB_DIR)/lib
#endif

#
# autoconf
#
GTKBOARD_AUTOCONF = \
	--build=$(GNU_HOST) \
	--host=$(PTXCONF_GNU_TARGET) \
	--prefix=/usr \
	--with-sdl-prefix=$(PTXCONF_PREFIX)

ifdef PTXCONF_XFREE430
GTKBOARD_AUTOCONF += --x-includes=$(CROSS_LIB_DIR)/include
GTKBOARD_AUTOCONF += --x-libraries=$(CROSS_LIB_DIR)/lib
endif

$(STATEDIR)/gtkboard.prepare: $(gtkboard_prepare_deps)
	@$(call targetinfo, $@)
	@$(call clean, $(GTKBOARD_DIR)/config.cache)
	cd $(GTKBOARD_DIR) && \
		$(GTKBOARD_PATH) $(GTKBOARD_ENV) \
		./configure $(GTKBOARD_AUTOCONF)
	touch $@

# ----------------------------------------------------------------------------
# Compile
# ----------------------------------------------------------------------------

gtkboard_compile: $(STATEDIR)/gtkboard.compile

gtkboard_compile_deps = $(STATEDIR)/gtkboard.prepare

$(STATEDIR)/gtkboard.compile: $(gtkboard_compile_deps)
	@$(call targetinfo, $@)
	$(GTKBOARD_PATH) $(MAKE) -C $(GTKBOARD_DIR)
	touch $@

# ----------------------------------------------------------------------------
# Install
# ----------------------------------------------------------------------------

gtkboard_install: $(STATEDIR)/gtkboard.install

$(STATEDIR)/gtkboard.install: $(STATEDIR)/gtkboard.compile
	@$(call targetinfo, $@)
	touch $@

# ----------------------------------------------------------------------------
# Target-Install
# ----------------------------------------------------------------------------

gtkboard_targetinstall: $(STATEDIR)/gtkboard.targetinstall

gtkboard_targetinstall_deps = $(STATEDIR)/gtkboard.compile \
	$(STATEDIR)/gtk22.targetinstall \
	$(STATEDIR)/SDL_mixer.targetinstall \
	$(STATEDIR)/SDL.targetinstall

$(STATEDIR)/gtkboard.targetinstall: $(gtkboard_targetinstall_deps)
	@$(call targetinfo, $@)
	$(GTKBOARD_PATH) $(MAKE) -C $(GTKBOARD_DIR) DESTDIR=$(GTKBOARD_IPKG_TMP) install
	$(CROSSSTRIP) $(GTKBOARD_IPKG_TMP)/usr/bin/*
	mkdir -p $(GTKBOARD_IPKG_TMP)/usr/share/applications
	cp -a $(TOPDIR)/config/pics/gtkboard.desktop $(GTKBOARD_IPKG_TMP)/usr/share/applications
	mkdir -p $(GTKBOARD_IPKG_TMP)/CONTROL
	echo "Package: gtkboard" 				 >$(GTKBOARD_IPKG_TMP)/CONTROL/control
	echo "Priority: optional" 				>>$(GTKBOARD_IPKG_TMP)/CONTROL/control
	echo "Section: Games"	 				>>$(GTKBOARD_IPKG_TMP)/CONTROL/control
	echo "Maintainer: Alexander Chukov <sash@pdaXrom.org>" 	>>$(GTKBOARD_IPKG_TMP)/CONTROL/control
	echo "Architecture: $(SHORT_TARGET)" 			>>$(GTKBOARD_IPKG_TMP)/CONTROL/control
	echo "Version: $(GTKBOARD_VERSION)" 			>>$(GTKBOARD_IPKG_TMP)/CONTROL/control
	echo "Depends: gtk2, sdl, sdl-mixer" 			>>$(GTKBOARD_IPKG_TMP)/CONTROL/control
	echo "Description: 31 games in a single program."	>>$(GTKBOARD_IPKG_TMP)/CONTROL/control
	cd $(FEEDDIR) && $(XMKIPKG) $(GTKBOARD_IPKG_TMP)
	touch $@

# ----------------------------------------------------------------------------
# Image-Install
# ----------------------------------------------------------------------------

ifdef PTXCONF_GTKBOARD_INSTALL
ROMPACKAGES += $(STATEDIR)/gtkboard.imageinstall
endif

gtkboard_imageinstall_deps = $(STATEDIR)/gtkboard.targetinstall \
	$(STATEDIR)/virtual-image.install

$(STATEDIR)/gtkboard.imageinstall: $(gtkboard_imageinstall_deps)
	@$(call targetinfo, $@)
	cd $(FEEDDIR) && $(XIPKG) install gtkboard
	touch $@

# ----------------------------------------------------------------------------
# Clean
# ----------------------------------------------------------------------------

gtkboard_clean:
	rm -rf $(STATEDIR)/gtkboard.*
	rm -rf $(GTKBOARD_DIR)

# vim: syntax=make
