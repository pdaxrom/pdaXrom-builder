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
ifdef PTXCONF_SDL_NET
PACKAGES += SDL_net
endif

#
# Paths and names
#
SDL_NET_VERSION		= 1.2.5
SDL_NET			= SDL_net-$(SDL_NET_VERSION)
SDL_NET_SUFFIX		= tar.gz
SDL_NET_URL		= http://www.libsdl.org/projects/SDL_net/release/$(SDL_NET).$(SDL_NET_SUFFIX)
SDL_NET_SOURCE		= $(SRCDIR)/$(SDL_NET).$(SDL_NET_SUFFIX)
SDL_NET_DIR		= $(BUILDDIR)/$(SDL_NET)
SDL_NET_IPKG_TMP	= $(SDL_NET_DIR)/ipkg_tmp

# ----------------------------------------------------------------------------
# Get
# ----------------------------------------------------------------------------

SDL_net_get: $(STATEDIR)/SDL_net.get

SDL_net_get_deps = $(SDL_NET_SOURCE)

$(STATEDIR)/SDL_net.get: $(SDL_net_get_deps)
	@$(call targetinfo, $@)
	@$(call get_patches, $(SDL_NET))
	touch $@

$(SDL_NET_SOURCE):
	@$(call targetinfo, $@)
	@$(call get, $(SDL_NET_URL))

# ----------------------------------------------------------------------------
# Extract
# ----------------------------------------------------------------------------

SDL_net_extract: $(STATEDIR)/SDL_net.extract

SDL_net_extract_deps = $(STATEDIR)/SDL_net.get

$(STATEDIR)/SDL_net.extract: $(SDL_net_extract_deps)
	@$(call targetinfo, $@)
	@$(call clean, $(SDL_NET_DIR))
	@$(call extract, $(SDL_NET_SOURCE))
	@$(call patchin, $(SDL_NET))
	touch $@

# ----------------------------------------------------------------------------
# Prepare
# ----------------------------------------------------------------------------

SDL_net_prepare: $(STATEDIR)/SDL_net.prepare

#
# dependencies
#
SDL_net_prepare_deps = \
	$(STATEDIR)/SDL_net.extract \
	$(STATEDIR)/SDL.install \
	$(STATEDIR)/virtual-xchain.install

SDL_NET_PATH	=  PATH=$(CROSS_PATH)
SDL_NET_ENV 	=  $(CROSS_ENV)
#SDL_NET_ENV	+=
SDL_NET_ENV	+= PKG_CONFIG_PATH=$(CROSS_LIB_DIR)/lib/pkgconfig:$(CROSS_LIB_DIR)/lib/pkgconfig
#ifdef PTXCONF_XFREE430
#SDL_NET_ENV	+= LDFLAGS=-Wl,-rpath-link,$(CROSS_LIB_DIR)/lib
#endif

#
# autoconf
#
SDL_NET_AUTOCONF = \
	--build=$(GNU_HOST) \
	--host=$(PTXCONF_GNU_TARGET) \
	--prefix=/usr \
	--disable-debug \
	--disable-static \
	--enable-shared \
	--disable-sdltest

ifdef PTXCONF_XFREE430
SDL_NET_AUTOCONF += --x-includes=$(CROSS_LIB_DIR)/include
SDL_NET_AUTOCONF += --x-libraries=$(CROSS_LIB_DIR)/lib
endif

$(STATEDIR)/SDL_net.prepare: $(SDL_net_prepare_deps)
	@$(call targetinfo, $@)
	@$(call clean, $(SDL_NET_DIR)/config.cache)
	cd $(SDL_NET_DIR) && \
		$(SDL_NET_PATH) $(SDL_NET_ENV) \
		./configure $(SDL_NET_AUTOCONF)
	touch $@

# ----------------------------------------------------------------------------
# Compile
# ----------------------------------------------------------------------------

SDL_net_compile: $(STATEDIR)/SDL_net.compile

SDL_net_compile_deps = $(STATEDIR)/SDL_net.prepare

$(STATEDIR)/SDL_net.compile: $(SDL_net_compile_deps)
	@$(call targetinfo, $@)
	$(SDL_NET_PATH) $(MAKE) -C $(SDL_NET_DIR)
	touch $@

# ----------------------------------------------------------------------------
# Install
# ----------------------------------------------------------------------------

SDL_net_install: $(STATEDIR)/SDL_net.install

$(STATEDIR)/SDL_net.install: $(STATEDIR)/SDL_net.compile
	@$(call targetinfo, $@)
	$(SDL_NET_PATH) $(MAKE) -C $(SDL_NET_DIR) DESTDIR=$(SDL_NET_IPKG_TMP) install
	cp -a  $(SDL_NET_IPKG_TMP)/usr/include/* $(CROSS_LIB_DIR)/include
	cp -a  $(SDL_NET_IPKG_TMP)/usr/lib/*     $(CROSS_LIB_DIR)/lib
	rm -rf $(SDL_NET_IPKG_TMP)
	perl -p -i -e "s/\/usr\/lib/`echo $(PTXCONF_PREFIX)/$(PTXCONF_GNU_TARGET)/lib | sed -e '/\//s//\\\\\//g'`/g" $(PTXCONF_PREFIX)/$(PTXCONF_GNU_TARGET)/lib/libSDL_net.la
	touch $@

# ----------------------------------------------------------------------------
# Target-Install
# ----------------------------------------------------------------------------

SDL_net_targetinstall: $(STATEDIR)/SDL_net.targetinstall

SDL_net_targetinstall_deps = $(STATEDIR)/SDL_net.compile

$(STATEDIR)/SDL_net.targetinstall: $(SDL_net_targetinstall_deps)
	@$(call targetinfo, $@)

	$(SDL_NET_PATH) $(MAKE) -C $(SDL_NET_DIR) DESTDIR=$(SDL_NET_IPKG_TMP) install
	mkdir -p $(SDL_NET_IPKG_TMP)/CONTROL
	echo "Package: sdl-net" 			>$(SDL_NET_IPKG_TMP)/CONTROL/control
	echo "Priority: optional" 			>>$(SDL_NET_IPKG_TMP)/CONTROL/control
	echo "Section: pdaXrom" 			>>$(SDL_NET_IPKG_TMP)/CONTROL/control
	echo "Maintainer: Alexander Chukov <sash@pdaxrom.org>" 			>>$(SDL_NET_IPKG_TMP)/CONTROL/control
	echo "Architecture: $(SHORT_TARGET)" 		>>$(SDL_NET_IPKG_TMP)/CONTROL/control
	echo "Version: $(SDL_NET_VERSION)" 		>>$(SDL_NET_IPKG_TMP)/CONTROL/control
	echo "Depends: sdl" 				>>$(SDL_NET_IPKG_TMP)/CONTROL/control
	echo "Description: generated with pdaXrom builder">>$(SDL_NET_IPKG_TMP)/CONTROL/control

	rm -rf $(SDL_NET_IPKG_TMP)/usr/include
	rm -rf $(SDL_NET_IPKG_TMP)/usr/lib/*.la
	$(CROSSSTRIP) $(SDL_NET_IPKG_TMP)/usr/lib/libSDL_net-1.2.so.0.0.5

	cd $(FEEDDIR) && $(XMKIPKG) $(SDL_NET_IPKG_TMP)
	touch $@

# ----------------------------------------------------------------------------
# Clean
# ----------------------------------------------------------------------------

SDL_net_clean:
	rm -rf $(STATEDIR)/SDL_net.*
	rm -rf $(SDL_NET_DIR)

# vim: syntax=make
