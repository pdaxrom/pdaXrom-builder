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
ifdef PTXCONF_SDL
PACKAGES += SDL
endif

#
# Paths and names
#
#SDL_VERSION	= 1.2.6
SDL_VERSION	= 1.2.7
SDL		= SDL-$(SDL_VERSION)
SDL_SUFFIX	= tar.gz
SDL_URL		= http://www.libsdl.org/release/$(SDL).$(SDL_SUFFIX)
SDL_SOURCE	= $(SRCDIR)/$(SDL).$(SDL_SUFFIX)
SDL_DIR		= $(BUILDDIR)/$(SDL)
SDL_IPKG_TMP	= $(SDL_DIR)/ipkg_tmp

# ----------------------------------------------------------------------------
# Get
# ----------------------------------------------------------------------------

SDL_get: $(STATEDIR)/SDL.get

SDL_get_deps = $(SDL_SOURCE)

$(STATEDIR)/SDL.get: $(SDL_get_deps)
	@$(call targetinfo, $@)
	@$(call get_patches, $(SDL))
	touch $@

$(SDL_SOURCE):
	@$(call targetinfo, $@)
	@$(call get, $(SDL_URL))

# ----------------------------------------------------------------------------
# Extract
# ----------------------------------------------------------------------------

SDL_extract: $(STATEDIR)/SDL.extract

SDL_extract_deps = $(STATEDIR)/SDL.get

$(STATEDIR)/SDL.extract: $(SDL_extract_deps)
	@$(call targetinfo, $@)
	@$(call clean, $(SDL_DIR))
	@$(call extract, $(SDL_SOURCE))
	@$(call patchin, $(SDL))
	touch $@

# ----------------------------------------------------------------------------
# Prepare
# ----------------------------------------------------------------------------

SDL_prepare: $(STATEDIR)/SDL.prepare

#
# dependencies
#
SDL_prepare_deps = \
	$(STATEDIR)/SDL.extract \
	$(STATEDIR)/esound.install \
	$(STATEDIR)/virtual-xchain.install

ifdef PTXCONF_ALSA-UTILS
SDL_prepare_deps += $(STATEDIR)/alsa-lib.install
endif

ifdef PTXCONF_XFREE430
SDL_prepare_deps += $(STATEDIR)/xfree430.install
endif

SDL_PATH	=  PATH=$(CROSS_PATH)
SDL_ENV 	=  $(CROSS_ENV)
#SDL_ENV	+=
SDL_ENV	+= PKG_CONFIG_PATH=$(CROSS_LIB_DIR)/lib/pkgconfig:$(CROSS_LIB_DIR)/lib/pkgconfig
#SDL_ENV	+= LDFLAGS=-Wl,-rpath-link,$(CROSS_LIB_DIR)/lib

#
# autoconf
#
SDL_AUTOCONF = \
	--build=$(GNU_HOST) \
	--host=$(PTXCONF_GNU_TARGET) \
	--prefix=/usr \
	--disable-debug \
	--sysconfdir=/etc \
	--disable-video-opengl \
	--disable-arts \
	--disable-static \
	--enable-shared

ifndef PTXCONF_ALSA-UTILS
SDL_AUTOCONF += --disable-alsa
endif

ifdef PTXCONF_XFREE430
SDL_AUTOCONF += --x-includes=$(CROSS_LIB_DIR)/include
SDL_AUTOCONF += --x-libraries=$(CROSS_LIB_DIR)/lib
endif

$(STATEDIR)/SDL.prepare: $(SDL_prepare_deps)
	@$(call targetinfo, $@)
	@$(call clean, $(SDL_DIR)/config.cache)
	cd $(SDL_DIR) && \
		$(SDL_PATH) $(SDL_ENV) \
		./configure $(SDL_AUTOCONF)
	touch $@

# ----------------------------------------------------------------------------
# Compile
# ----------------------------------------------------------------------------

SDL_compile: $(STATEDIR)/SDL.compile

SDL_compile_deps = $(STATEDIR)/SDL.prepare

$(STATEDIR)/SDL.compile: $(SDL_compile_deps)
	@$(call targetinfo, $@)
	$(SDL_PATH) $(MAKE) -C $(SDL_DIR)
	touch $@

# ----------------------------------------------------------------------------
# Install
# ----------------------------------------------------------------------------

SDL_install: $(STATEDIR)/SDL.install

$(STATEDIR)/SDL.install: $(STATEDIR)/SDL.compile
	@$(call targetinfo, $@)
	$(SDL_PATH) $(MAKE) -C $(SDL_DIR) DESTDIR=$(SDL_IPKG_TMP) install
	cp -a  $(SDL_IPKG_TMP)/usr/include/* $(CROSS_LIB_DIR)/include
	cp -a  $(SDL_IPKG_TMP)/usr/lib/*     $(CROSS_LIB_DIR)/lib
	cp -a  $(SDL_IPKG_TMP)/usr/share/aclocal/*   $(CROSS_LIB_DIR)/share/aclocal
	cp -a  $(SDL_IPKG_TMP)/usr/bin/*     $(PTXCONF_PREFIX)/bin
	rm -rf $(SDL_IPKG_TMP)
	perl -p -i -e "s/\/usr/`echo $(PTXCONF_PREFIX)/$(PTXCONF_GNU_TARGET) | sed -e '/\//s//\\\\\//g'`/g" $(PTXCONF_PREFIX)/bin/sdl-config
	perl -p -i -e "s/\/usr\/lib/`echo $(PTXCONF_PREFIX)/$(PTXCONF_GNU_TARGET)/lib | sed -e '/\//s//\\\\\//g'`/g" $(PTXCONF_PREFIX)/$(PTXCONF_GNU_TARGET)/lib/libSDL.la
	touch $@

# ----------------------------------------------------------------------------
# Target-Install
# ----------------------------------------------------------------------------

SDL_targetinstall: $(STATEDIR)/SDL.targetinstall

SDL_targetinstall_deps = $(STATEDIR)/SDL.compile \
	$(STATEDIR)/esound.targetinstall

ifdef PTXCONF_XFREE430
SDL_targetinstall_deps += $(STATEDIR)/xfree430.targetinstall
endif

$(STATEDIR)/SDL.targetinstall: $(SDL_targetinstall_deps)
	@$(call targetinfo, $@)
	$(SDL_PATH) $(MAKE) -C $(SDL_DIR) DESTDIR=$(SDL_IPKG_TMP) install
	mkdir -p $(SDL_IPKG_TMP)/CONTROL
	echo "Package: sdl"					 >$(SDL_IPKG_TMP)/CONTROL/control
	echo "Priority: optional"				>>$(SDL_IPKG_TMP)/CONTROL/control
	echo "Section: X11" 					>>$(SDL_IPKG_TMP)/CONTROL/control
	echo "Maintainer: Alexander Chukov <sash@cacko.biz>" 	>>$(SDL_IPKG_TMP)/CONTROL/control
	echo "Architecture: $(SHORT_TARGET)" 			>>$(SDL_IPKG_TMP)/CONTROL/control
	echo "Version: $(SDL_VERSION)" 				>>$(SDL_IPKG_TMP)/CONTROL/control
ifdef PTXCONF_XFREE430
	echo "Depends: xfree430, esound" 			>>$(SDL_IPKG_TMP)/CONTROL/control
else
	echo "Depends: esound" 					>>$(SDL_IPKG_TMP)/CONTROL/control
endif
	echo "Description: generated with pdaXrom builder"	>>$(SDL_IPKG_TMP)/CONTROL/control
	
	rm -fr $(SDL_IPKG_TMP)/usr/bin
	rm -fr $(SDL_IPKG_TMP)/usr/include
	rm -fr $(SDL_IPKG_TMP)/usr/share
	rm -fr $(SDL_IPKG_TMP)/usr/man
	rm -fr $(SDL_IPKG_TMP)/usr/lib/*.a
	rm -fr $(SDL_IPKG_TMP)/usr/lib/*.la
	
	$(CROSSSTRIP) $(SDL_IPKG_TMP)/usr/lib/libSDL-1.2.so.0.0.6
	
	cd $(FEEDDIR) && $(XMKIPKG) $(SDL_IPKG_TMP)
	touch $@

# ----------------------------------------------------------------------------
# Clean
# ----------------------------------------------------------------------------

SDL_clean:
	rm -rf $(STATEDIR)/SDL.*
	rm -rf $(SDL_DIR)

# vim: syntax=make
