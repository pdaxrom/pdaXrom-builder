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
ifdef PTXCONF_SDL_MIXER
PACKAGES += SDL_mixer
endif

#
# Paths and names
#
SDL_MIXER_VERSION	= 1.2.5
SDL_MIXER		= SDL_mixer-$(SDL_MIXER_VERSION)
SDL_MIXER_SUFFIX	= tar.gz
SDL_MIXER_URL		= http://www.libsdl.org/projects/SDL_mixer/release/$(SDL_MIXER).$(SDL_MIXER_SUFFIX)
SDL_MIXER_SOURCE	= $(SRCDIR)/$(SDL_MIXER).$(SDL_MIXER_SUFFIX)
SDL_MIXER_DIR		= $(BUILDDIR)/$(SDL_MIXER)
SDL_MIXER_IPKG_TMP	= $(SDL_MIXER_DIR)/ipkg_tmp

# ----------------------------------------------------------------------------
# Get
# ----------------------------------------------------------------------------

SDL_mixer_get: $(STATEDIR)/SDL_mixer.get

SDL_mixer_get_deps = $(SDL_MIXER_SOURCE)

$(STATEDIR)/SDL_mixer.get: $(SDL_mixer_get_deps)
	@$(call targetinfo, $@)
	@$(call get_patches, $(SDL_MIXER))
	touch $@

$(SDL_MIXER_SOURCE):
	@$(call targetinfo, $@)
	@$(call get, $(SDL_MIXER_URL))

# ----------------------------------------------------------------------------
# Extract
# ----------------------------------------------------------------------------

SDL_mixer_extract: $(STATEDIR)/SDL_mixer.extract

SDL_mixer_extract_deps = $(STATEDIR)/SDL_mixer.get

$(STATEDIR)/SDL_mixer.extract: $(SDL_mixer_extract_deps)
	@$(call targetinfo, $@)
	@$(call clean, $(SDL_MIXER_DIR))
	@$(call extract, $(SDL_MIXER_SOURCE))
	@$(call patchin, $(SDL_MIXER))
	touch $@

# ----------------------------------------------------------------------------
# Prepare
# ----------------------------------------------------------------------------

SDL_mixer_prepare: $(STATEDIR)/SDL_mixer.prepare

#
# dependencies
#
SDL_mixer_prepare_deps = \
	$(STATEDIR)/SDL_mixer.extract \
	$(STATEDIR)/SDL.install \
	$(STATEDIR)/virtual-xchain.install

SDL_MIXER_PATH	=  PATH=$(CROSS_PATH)
SDL_MIXER_ENV 	=  $(CROSS_ENV)
#SDL_MIXER_ENV	+=
#SDL_MIXER_ENV	+= CFLAGS="$(TARGET_OPT_CFLAGS)"
SDL_MIXER_ENV	+= PKG_CONFIG_PATH=$(CROSS_LIB_DIR)/lib/pkgconfig:$(CROSS_LIB_DIR)/lib/pkgconfig
#ifdef PTXCONF_XFREE430
#SDL_MIXER_ENV	+= LDFLAGS=-Wl,-rpath-link,$(CROSS_LIB_DIR)/lib
#endif

#
# autoconf
#
SDL_MIXER_AUTOCONF = \
	--build=$(GNU_HOST) \
	--host=$(PTXCONF_GNU_TARGET) \
	--prefix=/usr \
	--disable-debug \
	--disable-static \
	--enable-shared \
	--disable-sdltest

ifdef PTXCONF_XFREE430
SDL_MIXER_AUTOCONF += --x-includes=$(CROSS_LIB_DIR)/include
SDL_MIXER_AUTOCONF += --x-libraries=$(CROSS_LIB_DIR)/lib
endif

$(STATEDIR)/SDL_mixer.prepare: $(SDL_mixer_prepare_deps)
	@$(call targetinfo, $@)
	@$(call clean, $(SDL_MIXER_DIR)/config.cache)
	cd $(SDL_MIXER_DIR) && \
		$(SDL_MIXER_PATH) $(SDL_MIXER_ENV) \
		./configure $(SDL_MIXER_AUTOCONF)
	touch $@

# ----------------------------------------------------------------------------
# Compile
# ----------------------------------------------------------------------------

SDL_mixer_compile: $(STATEDIR)/SDL_mixer.compile

SDL_mixer_compile_deps = $(STATEDIR)/SDL_mixer.prepare

$(STATEDIR)/SDL_mixer.compile: $(SDL_mixer_compile_deps)
	@$(call targetinfo, $@)
	$(SDL_MIXER_PATH) $(MAKE) -C $(SDL_MIXER_DIR)
	touch $@

# ----------------------------------------------------------------------------
# Install
# ----------------------------------------------------------------------------

SDL_mixer_install: $(STATEDIR)/SDL_mixer.install

$(STATEDIR)/SDL_mixer.install: $(STATEDIR)/SDL_mixer.compile
	@$(call targetinfo, $@)
	$(SDL_MIXER_PATH) $(MAKE) -C $(SDL_MIXER_DIR) DESTDIR=$(SDL_MIXER_IPKG_TMP) install
	cp -a  $(SDL_MIXER_IPKG_TMP)/usr/include/* $(CROSS_LIB_DIR)/include
	cp -a  $(SDL_MIXER_IPKG_TMP)/usr/lib/*     $(CROSS_LIB_DIR)/lib
	rm -rf $(SDL_MIXER_IPKG_TMP)
	perl -p -i -e "s/\/usr\/lib/`echo $(PTXCONF_PREFIX)/$(PTXCONF_GNU_TARGET)/lib | sed -e '/\//s//\\\\\//g'`/g" $(PTXCONF_PREFIX)/$(PTXCONF_GNU_TARGET)/lib/libSDL_mixer.la
	touch $@

# ----------------------------------------------------------------------------
# Target-Install
# ----------------------------------------------------------------------------

SDL_mixer_targetinstall: $(STATEDIR)/SDL_mixer.targetinstall

SDL_mixer_targetinstall_deps = $(STATEDIR)/SDL_mixer.compile

$(STATEDIR)/SDL_mixer.targetinstall: $(SDL_mixer_targetinstall_deps)
	@$(call targetinfo, $@)

	$(SDL_MIXER_PATH) $(MAKE) -C $(SDL_MIXER_DIR) DESTDIR=$(SDL_MIXER_IPKG_TMP) install
	mkdir -p $(SDL_MIXER_IPKG_TMP)/CONTROL
	echo "Package: sdl-mixer" 			>$(SDL_MIXER_IPKG_TMP)/CONTROL/control
	echo "Priority: optional" 			>>$(SDL_MIXER_IPKG_TMP)/CONTROL/control
	echo "Section: pdaXrom" 			>>$(SDL_MIXER_IPKG_TMP)/CONTROL/control
	echo "Maintainer: Alexander Chukov <sash@pdaxrom.org>" 			>>$(SDL_MIXER_IPKG_TMP)/CONTROL/control
	echo "Architecture: $(SHORT_TARGET)" 		>>$(SDL_MIXER_IPKG_TMP)/CONTROL/control
	echo "Version: $(SDL_MIXER_VERSION)" 		>>$(SDL_MIXER_IPKG_TMP)/CONTROL/control
	echo "Depends: sdl" 				>>$(SDL_MIXER_IPKG_TMP)/CONTROL/control
	echo "Description: generated with pdaXrom builder">>$(SDL_MIXER_IPKG_TMP)/CONTROL/control

	rm -rf $(SDL_MIXER_IPKG_TMP)/usr/include
	rm -rf $(SDL_MIXER_IPKG_TMP)/usr/lib/*.la
	$(CROSSSTRIP) $(SDL_MIXER_IPKG_TMP)/usr/lib/libSDL_mixer-1.2.so.0.2.3

	cd $(FEEDDIR) && $(XMKIPKG) $(SDL_MIXER_IPKG_TMP)
	touch $@

# ----------------------------------------------------------------------------
# Clean
# ----------------------------------------------------------------------------

SDL_mixer_clean:
	rm -rf $(STATEDIR)/SDL_mixer.*
	rm -rf $(SDL_MIXER_DIR)

# vim: syntax=make
