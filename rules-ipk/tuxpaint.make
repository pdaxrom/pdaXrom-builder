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
ifdef PTXCONF_TUXPAINT
PACKAGES += tuxpaint
endif

#
# Paths and names
#
TUXPAINT_VERSION	= 0.9.14
TUXPAINT		= tuxpaint-$(TUXPAINT_VERSION)
TUXPAINT_SUFFIX		= tar.gz
TUXPAINT_URL		= http://voxel.dl.sourceforge.net/sourceforge/tuxpaint/$(TUXPAINT).$(TUXPAINT_SUFFIX)
TUXPAINT_SOURCE		= $(SRCDIR)/$(TUXPAINT).$(TUXPAINT_SUFFIX)
TUXPAINT_DIR		= $(BUILDDIR)/$(TUXPAINT)
TUXPAINT_IPKG_TMP	= $(TUXPAINT_DIR)/ipkg_tmp

# ----------------------------------------------------------------------------
# Get
# ----------------------------------------------------------------------------

tuxpaint_get: $(STATEDIR)/tuxpaint.get

tuxpaint_get_deps = $(TUXPAINT_SOURCE)

$(STATEDIR)/tuxpaint.get: $(tuxpaint_get_deps)
	@$(call targetinfo, $@)
	@$(call get_patches, $(TUXPAINT))
	touch $@

$(TUXPAINT_SOURCE):
	@$(call targetinfo, $@)
	@$(call get, $(TUXPAINT_URL))

# ----------------------------------------------------------------------------
# Extract
# ----------------------------------------------------------------------------

tuxpaint_extract: $(STATEDIR)/tuxpaint.extract

tuxpaint_extract_deps = $(STATEDIR)/tuxpaint.get

$(STATEDIR)/tuxpaint.extract: $(tuxpaint_extract_deps)
	@$(call targetinfo, $@)
	@$(call clean, $(TUXPAINT_DIR))
	@$(call extract, $(TUXPAINT_SOURCE))
	@$(call patchin, $(TUXPAINT))
	touch $@

# ----------------------------------------------------------------------------
# Prepare
# ----------------------------------------------------------------------------

tuxpaint_prepare: $(STATEDIR)/tuxpaint.prepare

#
# dependencies
#
tuxpaint_prepare_deps = \
	$(STATEDIR)/tuxpaint.extract \
	$(STATEDIR)/SDL_ttf.install \
	$(STATEDIR)/virtual-xchain.install

TUXPAINT_PATH	=  PATH=$(CROSS_PATH)
TUXPAINT_ENV 	=  $(CROSS_ENV)
###TUXPAINT_ENV	+= CFLAGS="$(TARGET_OPT_CFLAGS)"
TUXPAINT_ENV	+= PKG_CONFIG_PATH=$(CROSS_LIB_DIR)/lib/pkgconfig:$(CROSS_LIB_DIR)/lib/pkgconfig
#ifdef PTXCONF_XFREE430
#TUXPAINT_ENV	+= LDFLAGS=-Wl,-rpath-link,$(CROSS_LIB_DIR)/lib
#endif

#
# autoconf
#
TUXPAINT_AUTOCONF = \
	--build=$(GNU_HOST) \
	--host=$(PTXCONF_GNU_TARGET) \
	--prefix=/usr

ifdef PTXCONF_XFREE430
TUXPAINT_AUTOCONF += --x-includes=$(CROSS_LIB_DIR)/include
TUXPAINT_AUTOCONF += --x-libraries=$(CROSS_LIB_DIR)/lib
endif

$(STATEDIR)/tuxpaint.prepare: $(tuxpaint_prepare_deps)
	@$(call targetinfo, $@)
	@$(call clean, $(TUXPAINT_DIR)/config.cache)
	#cd $(TUXPAINT_DIR) && \
	#	$(TUXPAINT_PATH) $(TUXPAINT_ENV) \
	#	./configure $(TUXPAINT_AUTOCONF)
	touch $@

# ----------------------------------------------------------------------------
# Compile
# ----------------------------------------------------------------------------

tuxpaint_compile: $(STATEDIR)/tuxpaint.compile

tuxpaint_compile_deps = $(STATEDIR)/tuxpaint.prepare

$(STATEDIR)/tuxpaint.compile: $(tuxpaint_compile_deps)
	@$(call targetinfo, $@)
	$(TUXPAINT_PATH) $(TUXPAINT_ENV) \
	    $(MAKE) -C $(TUXPAINT_DIR) ARCH_LINKS="" PREFIX=/usr
	touch $@

# ----------------------------------------------------------------------------
# Install
# ----------------------------------------------------------------------------

tuxpaint_install: $(STATEDIR)/tuxpaint.install

$(STATEDIR)/tuxpaint.install: $(STATEDIR)/tuxpaint.compile
	@$(call targetinfo, $@)
	touch $@

# ----------------------------------------------------------------------------
# Target-Install
# ----------------------------------------------------------------------------

tuxpaint_targetinstall: $(STATEDIR)/tuxpaint.targetinstall

tuxpaint_targetinstall_deps = $(STATEDIR)/tuxpaint.compile \
	$(STATEDIR)/SDL_mixer.install \
	$(STATEDIR)/SDL_ttf.install

$(STATEDIR)/tuxpaint.targetinstall: $(tuxpaint_targetinstall_deps)
	@$(call targetinfo, $@)
	$(TUXPAINT_PATH) $(MAKE) -C $(TUXPAINT_DIR) PREFIX=$(TUXPAINT_IPKG_TMP)/usr install GNOME_PREFIX=$(TUXPAINT_IPKG_TMP)/usr
	$(CROSSSTRIP) $(TUXPAINT_IPKG_TMP)/usr/bin/tuxpaint
	mv -f $(TUXPAINT_IPKG_TMP)/usr/etc $(TUXPAINT_IPKG_TMP)/
	rm -rf $(TUXPAINT_IPKG_TMP)/usr/X11R6
	mkdir -p $(TUXPAINT_IPKG_TMP)/CONTROL
	echo "Package: tuxpaint" 						>$(TUXPAINT_IPKG_TMP)/CONTROL/control
	echo "Priority: optional" 						>>$(TUXPAINT_IPKG_TMP)/CONTROL/control
	echo "Section: Office"				 			>>$(TUXPAINT_IPKG_TMP)/CONTROL/control
	echo "Maintainer: Alexander Chukov <sash@pdaXrom.org>" 			>>$(TUXPAINT_IPKG_TMP)/CONTROL/control
	echo "Architecture: $(SHORT_TARGET)" 					>>$(TUXPAINT_IPKG_TMP)/CONTROL/control
	echo "Version: $(TUXPAINT_VERSION)" 					>>$(TUXPAINT_IPKG_TMP)/CONTROL/control
	echo "Depends: sdl, sdl-ttf, sdl-mixer, sdl-image" 			>>$(TUXPAINT_IPKG_TMP)/CONTROL/control
	echo "Description: Tux Paint is a free drawing program designed for young children (kids ages 3 and up)." >>$(TUXPAINT_IPKG_TMP)/CONTROL/control
	cd $(FEEDDIR) && $(XMKIPKG) $(TUXPAINT_IPKG_TMP)
	touch $@

# ----------------------------------------------------------------------------
# Image-Install
# ----------------------------------------------------------------------------

ifdef PTXCONF_TUXPAINT_INSTALL
ROMPACKAGES += $(STATEDIR)/tuxpaint.imageinstall
endif

tuxpaint_imageinstall_deps = $(STATEDIR)/tuxpaint.targetinstall \
	$(STATEDIR)/virtual-image.install

$(STATEDIR)/tuxpaint.imageinstall: $(tuxpaint_imageinstall_deps)
	@$(call targetinfo, $@)
	cd $(FEEDDIR) && $(XIPKG) install tuxpaint
	touch $@

# ----------------------------------------------------------------------------
# Clean
# ----------------------------------------------------------------------------

tuxpaint_clean:
	rm -rf $(STATEDIR)/tuxpaint.*
	rm -rf $(TUXPAINT_DIR)

# vim: syntax=make
