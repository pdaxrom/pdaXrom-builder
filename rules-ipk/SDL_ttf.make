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
ifdef PTXCONF_SDL_TTF
PACKAGES += SDL_ttf
endif

#
# Paths and names
#
SDL_TTF_VERSION		= 2.0.6
SDL_TTF			= SDL_ttf-$(SDL_TTF_VERSION)
SDL_TTF_SUFFIX		= tar.gz
SDL_TTF_URL		= http://www.libsdl.org/projects/SDL_ttf/release/$(SDL_TTF).$(SDL_TTF_SUFFIX)
SDL_TTF_SOURCE		= $(SRCDIR)/$(SDL_TTF).$(SDL_TTF_SUFFIX)
SDL_TTF_DIR		= $(BUILDDIR)/$(SDL_TTF)
SDL_TTF_IPKG_TMP	= $(SDL_TTF_DIR)/ipkg_tmp

# ----------------------------------------------------------------------------
# Get
# ----------------------------------------------------------------------------

SDL_ttf_get: $(STATEDIR)/SDL_ttf.get

SDL_ttf_get_deps = $(SDL_TTF_SOURCE)

$(STATEDIR)/SDL_ttf.get: $(SDL_ttf_get_deps)
	@$(call targetinfo, $@)
	@$(call get_patches, $(SDL_TTF))
	touch $@

$(SDL_TTF_SOURCE):
	@$(call targetinfo, $@)
	@$(call get, $(SDL_TTF_URL))

# ----------------------------------------------------------------------------
# Extract
# ----------------------------------------------------------------------------

SDL_ttf_extract: $(STATEDIR)/SDL_ttf.extract

SDL_ttf_extract_deps = $(STATEDIR)/SDL_ttf.get

$(STATEDIR)/SDL_ttf.extract: $(SDL_ttf_extract_deps)
	@$(call targetinfo, $@)
	@$(call clean, $(SDL_TTF_DIR))
	@$(call extract, $(SDL_TTF_SOURCE))
	@$(call patchin, $(SDL_TTF))
	touch $@

# ----------------------------------------------------------------------------
# Prepare
# ----------------------------------------------------------------------------

SDL_ttf_prepare: $(STATEDIR)/SDL_ttf.prepare

#
# dependencies
#
SDL_ttf_prepare_deps = \
	$(STATEDIR)/SDL_ttf.extract \
	$(STATEDIR)/SDL.install \
	$(STATEDIR)/freetype.install \
	$(STATEDIR)/virtual-xchain.install

SDL_TTF_PATH	=  PATH=$(CROSS_PATH)
SDL_TTF_ENV 	=  $(CROSS_ENV)
SDL_TTF_ENV	+= CFLAGS="$(TARGET_OPT_CFLAGS)"
SDL_TTF_ENV	+= PKG_CONFIG_PATH=$(CROSS_LIB_DIR)/lib/pkgconfig:$(CROSS_LIB_DIR)/lib/pkgconfig
#ifdef PTXCONF_XFREE430
#SDL_TTF_ENV	+= LDFLAGS=-Wl,-rpath-link,$(CROSS_LIB_DIR)/lib
#endif

#
# autoconf
#
SDL_TTF_AUTOCONF = \
	--build=$(GNU_HOST) \
	--host=$(PTXCONF_GNU_TARGET) \
	--prefix=/usr \
	--disable-debug \
	--disable-static \
	--enable-shared \
	--disable-sdltest

ifdef PTXCONF_XFREE430
SDL_TTF_AUTOCONF += --x-includes=$(CROSS_LIB_DIR)/include
SDL_TTF_AUTOCONF += --x-libraries=$(CROSS_LIB_DIR)/lib
endif

$(STATEDIR)/SDL_ttf.prepare: $(SDL_ttf_prepare_deps)
	@$(call targetinfo, $@)
	@$(call clean, $(SDL_TTF_DIR)/config.cache)
	cd $(SDL_TTF_DIR) && \
		$(SDL_TTF_PATH) $(SDL_TTF_ENV) \
		./configure $(SDL_TTF_AUTOCONF)
	touch $@

# ----------------------------------------------------------------------------
# Compile
# ----------------------------------------------------------------------------

SDL_ttf_compile: $(STATEDIR)/SDL_ttf.compile

SDL_ttf_compile_deps = $(STATEDIR)/SDL_ttf.prepare

$(STATEDIR)/SDL_ttf.compile: $(SDL_ttf_compile_deps)
	@$(call targetinfo, $@)
	$(SDL_TTF_PATH) $(MAKE) -C $(SDL_TTF_DIR)
	touch $@

# ----------------------------------------------------------------------------
# Install
# ----------------------------------------------------------------------------

SDL_ttf_install: $(STATEDIR)/SDL_ttf.install

$(STATEDIR)/SDL_ttf.install: $(STATEDIR)/SDL_ttf.compile
	@$(call targetinfo, $@)
	$(SDL_TTF_PATH) $(MAKE) -C $(SDL_TTF_DIR) DESTDIR=$(SDL_TTF_IPKG_TMP) install
	cp -a  $(SDL_TTF_IPKG_TMP)/usr/include/* $(CROSS_LIB_DIR)/include
	cp -a  $(SDL_TTF_IPKG_TMP)/usr/lib/*     $(CROSS_LIB_DIR)/lib
	perl -p -i -e "s/\/usr\/lib/`echo $(PTXCONF_PREFIX)/$(PTXCONF_GNU_TARGET)/lib | sed -e '/\//s//\\\\\//g'`/g" $(PTXCONF_PREFIX)/$(PTXCONF_GNU_TARGET)/lib/libSDL_ttf.la
	rm -rf $(SDL_TTF_IPKG_TMP)
	touch $@

# ----------------------------------------------------------------------------
# Target-Install
# ----------------------------------------------------------------------------

SDL_ttf_targetinstall: $(STATEDIR)/SDL_ttf.targetinstall

SDL_ttf_targetinstall_deps = $(STATEDIR)/SDL_ttf.compile \
	$(STATEDIR)/freetype.targetinstall \
	$(STATEDIR)/SDL.targetinstall

$(STATEDIR)/SDL_ttf.targetinstall: $(SDL_ttf_targetinstall_deps)
	@$(call targetinfo, $@)
	$(SDL_TTF_PATH) $(MAKE) -C $(SDL_TTF_DIR) DESTDIR=$(SDL_TTF_IPKG_TMP) install
	rm -rf $(SDL_TTF_IPKG_TMP)/usr/include
	rm -rf $(SDL_TTF_IPKG_TMP)/usr/lib/*.*a
	$(CROSSSTRIP) $(SDL_TTF_IPKG_TMP)/usr/lib/*.so*
	mkdir -p $(SDL_TTF_IPKG_TMP)/CONTROL
	echo "Package: sdl-ttf" 						>$(SDL_TTF_IPKG_TMP)/CONTROL/control
	echo "Priority: optional" 						>>$(SDL_TTF_IPKG_TMP)/CONTROL/control
	echo "Section: Libraries"			 			>>$(SDL_TTF_IPKG_TMP)/CONTROL/control
	echo "Maintainer: Alexander Chukov <sash@pdaXrom.org>" 			>>$(SDL_TTF_IPKG_TMP)/CONTROL/control
	echo "Architecture: $(SHORT_TARGET)" 					>>$(SDL_TTF_IPKG_TMP)/CONTROL/control
	echo "Version: $(SDL_TTF_VERSION)" 					>>$(SDL_TTF_IPKG_TMP)/CONTROL/control
	echo "Depends: sdl, freetype, libz" 					>>$(SDL_TTF_IPKG_TMP)/CONTROL/control
	echo "Description: This is a sample library which allows you to use TrueType fonts in your SDL applications." >>$(SDL_TTF_IPKG_TMP)/CONTROL/control
	cd $(FEEDDIR) && $(XMKIPKG) $(SDL_TTF_IPKG_TMP)
	touch $@

# ----------------------------------------------------------------------------
# Image-Install
# ----------------------------------------------------------------------------

ifdef PTXCONF_SDL_TTF_INSTALL
ROMPACKAGES += $(STATEDIR)/SDL_ttf.imageinstall
endif

SDL_ttf_imageinstall_deps = $(STATEDIR)/SDL_ttf.targetinstall \
	$(STATEDIR)/virtual-image.install

$(STATEDIR)/SDL_ttf.imageinstall: $(SDL_ttf_imageinstall_deps)
	@$(call targetinfo, $@)
	cd $(FEEDDIR) && $(XIPKG) install sdl-ttf
	touch $@

# ----------------------------------------------------------------------------
# Clean
# ----------------------------------------------------------------------------

SDL_ttf_clean:
	rm -rf $(STATEDIR)/SDL_ttf.*
	rm -rf $(SDL_TTF_DIR)

# vim: syntax=make
