# -*-makefile-*-
# $Id: template,v 1.10 2004/01/24 15:50:34 mkl Exp $
#
# Copyright (C) 2004 by Alexander Chukov <sash@pdaxrom.org>
#          
# See CREDITS for details about who has contributed to this project.
#
# For further information about the PTXdist project and license conditions
# see the README file.
#

#
# We provide this package
#
ifdef PTXCONF_SDL_IMAGE
PACKAGES += SDL_image
endif

#
# Paths and names
#
SDL_IMAGE_VERSION	= 1.2.3
SDL_IMAGE		= SDL_image-$(SDL_IMAGE_VERSION)
SDL_IMAGE_SUFFIX	= tar.gz
SDL_IMAGE_URL		= http://www.libsdl.org/projects/SDL_image/release/$(SDL_IMAGE).$(SDL_IMAGE_SUFFIX)
SDL_IMAGE_SOURCE	= $(SRCDIR)/$(SDL_IMAGE).$(SDL_IMAGE_SUFFIX)
SDL_IMAGE_DIR		= $(BUILDDIR)/$(SDL_IMAGE)
SDL_IMAGE_IPKG_TMP	= $(SDL_IMAGE_DIR)/ipkg_tmp

# ----------------------------------------------------------------------------
# Get
# ----------------------------------------------------------------------------

SDL_image_get: $(STATEDIR)/SDL_image.get

SDL_image_get_deps = $(SDL_IMAGE_SOURCE)

$(STATEDIR)/SDL_image.get: $(SDL_image_get_deps)
	@$(call targetinfo, $@)
	@$(call get_patches, $(SDL_IMAGE))
	touch $@

$(SDL_IMAGE_SOURCE):
	@$(call targetinfo, $@)
	@$(call get, $(SDL_IMAGE_URL))

# ----------------------------------------------------------------------------
# Extract
# ----------------------------------------------------------------------------

SDL_image_extract: $(STATEDIR)/SDL_image.extract

SDL_image_extract_deps = $(STATEDIR)/SDL_image.get

$(STATEDIR)/SDL_image.extract: $(SDL_image_extract_deps)
	@$(call targetinfo, $@)
	@$(call clean, $(SDL_IMAGE_DIR))
	@$(call extract, $(SDL_IMAGE_SOURCE))
	@$(call patchin, $(SDL_IMAGE))
	touch $@

# ----------------------------------------------------------------------------
# Prepare
# ----------------------------------------------------------------------------

SDL_image_prepare: $(STATEDIR)/SDL_image.prepare

#
# dependencies
#
SDL_image_prepare_deps = \
	$(STATEDIR)/SDL_image.extract \
	$(STATEDIR)/SDL.install \
	$(STATEDIR)/virtual-xchain.install

SDL_IMAGE_PATH	=  PATH=$(CROSS_PATH)
SDL_IMAGE_ENV 	=  $(CROSS_ENV)
#SDL_IMAGE_ENV	+=
SDL_IMAGE_ENV	+= PKG_CONFIG_PATH=$(CROSS_LIB_DIR)/lib/pkgconfig:$(CROSS_LIB_DIR)/lib/pkgconfig
#ifdef PTXCONF_XFREE430
#SDL_IMAGE_ENV	+= LDFLAGS=-Wl,-rpath-link,$(CROSS_LIB_DIR)/lib
#endif

#
# autoconf
#
SDL_IMAGE_AUTOCONF = \
	--build=$(GNU_HOST) \
	--host=$(PTXCONF_GNU_TARGET) \
	--prefix=/usr \
	--disable-debug \
	--disable-static \
	--enable-shared \
	--disable-sdltest

ifdef PTXCONF_XFREE430
SDL_IMAGE_AUTOCONF += --x-includes=$(CROSS_LIB_DIR)/include
SDL_IMAGE_AUTOCONF += --x-libraries=$(CROSS_LIB_DIR)/lib
endif

$(STATEDIR)/SDL_image.prepare: $(SDL_image_prepare_deps)
	@$(call targetinfo, $@)
	@$(call clean, $(SDL_IMAGE_DIR)/config.cache)
	cd $(SDL_IMAGE_DIR) && \
		$(SDL_IMAGE_PATH) $(SDL_IMAGE_ENV) \
		./configure $(SDL_IMAGE_AUTOCONF)
	touch $@

# ----------------------------------------------------------------------------
# Compile
# ----------------------------------------------------------------------------

SDL_image_compile: $(STATEDIR)/SDL_image.compile

SDL_image_compile_deps = $(STATEDIR)/SDL_image.prepare

$(STATEDIR)/SDL_image.compile: $(SDL_image_compile_deps)
	@$(call targetinfo, $@)
	$(SDL_IMAGE_PATH) $(MAKE) -C $(SDL_IMAGE_DIR)
	touch $@

# ----------------------------------------------------------------------------
# Install
# ----------------------------------------------------------------------------

SDL_image_install: $(STATEDIR)/SDL_image.install

$(STATEDIR)/SDL_image.install: $(STATEDIR)/SDL_image.compile
	@$(call targetinfo, $@)
	$(SDL_IMAGE_PATH) $(MAKE) -C $(SDL_IMAGE_DIR) DESTDIR=$(SDL_IMAGE_IPKG_TMP) install
	cp -a  $(SDL_IMAGE_IPKG_TMP)/usr/include/* $(CROSS_LIB_DIR)/include
	cp -a  $(SDL_IMAGE_IPKG_TMP)/usr/lib/*     $(CROSS_LIB_DIR)/lib
	rm -rf $(SDL_IMAGE_IPKG_TMP)
	perl -p -i -e "s/\/usr\/lib/`echo $(PTXCONF_PREFIX)/$(PTXCONF_GNU_TARGET)/lib | sed -e '/\//s//\\\\\//g'`/g" $(PTXCONF_PREFIX)/$(PTXCONF_GNU_TARGET)/lib/libSDL_image.la
	touch $@

# ----------------------------------------------------------------------------
# Target-Install
# ----------------------------------------------------------------------------

SDL_image_targetinstall: $(STATEDIR)/SDL_image.targetinstall

SDL_image_targetinstall_deps = $(STATEDIR)/SDL_image.compile

$(STATEDIR)/SDL_image.targetinstall: $(SDL_image_targetinstall_deps)
	@$(call targetinfo, $@)

	$(SDL_IMAGE_PATH) $(MAKE) -C $(SDL_IMAGE_DIR) DESTDIR=$(SDL_IMAGE_IPKG_TMP) install
	mkdir -p $(SDL_IMAGE_IPKG_TMP)/CONTROL
	echo "Package: sdl-image" 			>$(SDL_IMAGE_IPKG_TMP)/CONTROL/control
	echo "Priority: optional" 			>>$(SDL_IMAGE_IPKG_TMP)/CONTROL/control
	echo "Section: pdaXrom" 			>>$(SDL_IMAGE_IPKG_TMP)/CONTROL/control
	echo "Maintainer: Alexander Chukov <sash@pdaxrom.org>" 	>>$(SDL_IMAGE_IPKG_TMP)/CONTROL/control
	echo "Architecture: $(SHORT_TARGET)" 		>>$(SDL_IMAGE_IPKG_TMP)/CONTROL/control
	echo "Version: $(SDL_IMAGE_VERSION)" 		>>$(SDL_IMAGE_IPKG_TMP)/CONTROL/control
	echo "Depends: sdl" 				>>$(SDL_IMAGE_IPKG_TMP)/CONTROL/control
	echo "Description: generated with pdaXrom builder">>$(SDL_IMAGE_IPKG_TMP)/CONTROL/control

	rm -rf $(SDL_IMAGE_IPKG_TMP)/usr/include
	rm -rf $(SDL_IMAGE_IPKG_TMP)/usr/lib/*.la
	$(CROSSSTRIP) $(SDL_IMAGE_IPKG_TMP)/usr/lib/libSDL_image-1.2.so.0.1.2

	cd $(FEEDDIR) && $(XMKIPKG) $(SDL_IMAGE_IPKG_TMP)
	touch $@

# ----------------------------------------------------------------------------
# Clean
# ----------------------------------------------------------------------------

SDL_image_clean:
	rm -rf $(STATEDIR)/SDL_image.*
	rm -rf $(SDL_IMAGE_DIR)

# vim: syntax=make
