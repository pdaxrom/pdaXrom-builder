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
ifdef PTXCONF_PRBOOM
PACKAGES += prboom
endif

#
# Paths and names
#
PRBOOM_VERSION	= 2.2.3
PRBOOM		= prboom-$(PRBOOM_VERSION)
PRBOOM_SUFFIX	= tar.gz
PRBOOM_URL	= http://aleron.dl.sourceforge.net/sourceforge/prboom/$(PRBOOM).$(PRBOOM_SUFFIX)
PRBOOM_SOURCE	= $(SRCDIR)/$(PRBOOM).$(PRBOOM_SUFFIX)
PRBOOM_DIR	= $(BUILDDIR)/$(PRBOOM)
PRBOOM_IPKG_TMP	= $(PRBOOM_DIR)/ipkg_tmp

# ----------------------------------------------------------------------------
# Get
# ----------------------------------------------------------------------------

prboom_get: $(STATEDIR)/prboom.get

prboom_get_deps = $(PRBOOM_SOURCE)

$(STATEDIR)/prboom.get: $(prboom_get_deps)
	@$(call targetinfo, $@)
	@$(call get_patches, $(PRBOOM))
	touch $@

$(PRBOOM_SOURCE):
	@$(call targetinfo, $@)
	@$(call get, $(PRBOOM_URL))

# ----------------------------------------------------------------------------
# Extract
# ----------------------------------------------------------------------------

prboom_extract: $(STATEDIR)/prboom.extract

prboom_extract_deps = $(STATEDIR)/prboom.get

$(STATEDIR)/prboom.extract: $(prboom_extract_deps)
	@$(call targetinfo, $@)
	@$(call clean, $(PRBOOM_DIR))
	@$(call extract, $(PRBOOM_SOURCE))
	@$(call patchin, $(PRBOOM))
	touch $@

# ----------------------------------------------------------------------------
# Prepare
# ----------------------------------------------------------------------------

prboom_prepare: $(STATEDIR)/prboom.prepare

#
# dependencies
#
prboom_prepare_deps = \
	$(STATEDIR)/prboom.extract \
	$(STATEDIR)/SDL.install \
	$(STATEDIR)/SDL_mixer.install \
	$(STATEDIR)/SDL_net.install \
	$(STATEDIR)/virtual-xchain.install

PRBOOM_PATH	=  PATH=$(CROSS_PATH)
PRBOOM_ENV 	=  $(CROSS_ENV)
#PRBOOM_ENV	+=
PRBOOM_ENV	+= PKG_CONFIG_PATH=$(CROSS_LIB_DIR)/lib/pkgconfig:$(CROSS_LIB_DIR)/lib/pkgconfig
PRBOOM_ENV	+= CFLAGS="$(TARGET_OPT_CFLAGS)"
#ifdef PTXCONF_XFREE430
#PRBOOM_ENV	+= LDFLAGS=-Wl,-rpath-link,$(CROSS_LIB_DIR)/lib
#endif

#
# autoconf
#
PRBOOM_AUTOCONF = \
	--build=$(GNU_HOST) \
	--host=$(PTXCONF_GNU_TARGET) \
	--prefix=/usr \
	--enable-debug

ifdef PTXCONF_XFREE430
PRBOOM_AUTOCONF += --x-includes=$(CROSS_LIB_DIR)/include
PRBOOM_AUTOCONF += --x-libraries=$(CROSS_LIB_DIR)/lib
endif

$(STATEDIR)/prboom.prepare: $(prboom_prepare_deps)
	@$(call targetinfo, $@)
	@$(call clean, $(PRBOOM_DIR)/config.cache)
	cd $(PRBOOM_DIR) && \
		$(PRBOOM_PATH) $(PRBOOM_ENV) \
		./configure $(PRBOOM_AUTOCONF)
	touch $@

# ----------------------------------------------------------------------------
# Compile
# ----------------------------------------------------------------------------

prboom_compile: $(STATEDIR)/prboom.compile

prboom_compile_deps = $(STATEDIR)/prboom.prepare

$(STATEDIR)/prboom.compile: $(prboom_compile_deps)
	@$(call targetinfo, $@)
	$(PRBOOM_PATH) $(MAKE) -C $(PRBOOM_DIR)
	touch $@

# ----------------------------------------------------------------------------
# Install
# ----------------------------------------------------------------------------

prboom_install: $(STATEDIR)/prboom.install

$(STATEDIR)/prboom.install: $(STATEDIR)/prboom.compile
	@$(call targetinfo, $@)
	$(PRBOOM_PATH) $(MAKE) -C $(PRBOOM_DIR) install
	touch $@

# ----------------------------------------------------------------------------
# Target-Install
# ----------------------------------------------------------------------------

prboom_targetinstall: $(STATEDIR)/prboom.targetinstall

prboom_targetinstall_deps = $(STATEDIR)/prboom.compile \
	$(STATEDIR)/SDL.targetinstall \
	$(STATEDIR)/SDL_mixer.targetinstall \
	$(STATEDIR)/SDL_net.targetinstall 

$(STATEDIR)/prboom.targetinstall: $(prboom_targetinstall_deps)
	@$(call targetinfo, $@)

	$(PRBOOM_PATH) $(MAKE) -C $(PRBOOM_DIR) DESTDIR=$(PRBOOM_IPKG_TMP) install
	mkdir -p $(PRBOOM_IPKG_TMP)/CONTROL
	echo "Package: prboom" 			>$(PRBOOM_IPKG_TMP)/CONTROL/control
	echo "Priority: optional" 			>>$(PRBOOM_IPKG_TMP)/CONTROL/control
	echo "Section: pdaXrom" 			>>$(PRBOOM_IPKG_TMP)/CONTROL/control
	echo "Maintainer: Alexander Chukov <sash@pdaxrom.org>" >>$(PRBOOM_IPKG_TMP)/CONTROL/control
	echo "Architecture: $(SHORT_TARGET)" 		>>$(PRBOOM_IPKG_TMP)/CONTROL/control
	echo "Version: $(PRBOOM_VERSION)" 		>>$(PRBOOM_IPKG_TMP)/CONTROL/control
	echo "Depends: sdl, sdl-mixer, sdl-net" 	>>$(PRBOOM_IPKG_TMP)/CONTROL/control
	echo "Description: generated with pdaXrom builder">>$(PRBOOM_IPKG_TMP)/CONTROL/control

	rm -rf $(PRBOOM_IPKG_TMP)/usr/man $(PRBOOM_IPKG_TMP)/usr/bin
	mkdir $(PRBOOM_IPKG_TMP)/usr/bin
	ln -sf /usr/games/prboom $(PRBOOM_IPKG_TMP)/usr/bin/prboom
	ln -sf /usr/games/prboom-game-server $(PRBOOM_IPKG_TMP)/usr/bin/prboom-game-server
	$(CROSSSTRIP) $(PRBOOM_IPKG_TMP)/usr/games/prboom
	$(CROSSSTRIP) $(PRBOOM_IPKG_TMP)/usr/games/prboom-game-server

	cd $(FEEDDIR) && $(XMKIPKG) $(PRBOOM_IPKG_TMP)
	touch $@

# ----------------------------------------------------------------------------
# Image-Install
# ----------------------------------------------------------------------------

ifdef PTXCONF_PRBOOM_INSTALL
ROMPACKAGES += $(STATEDIR)/prboom.imageinstall
endif

prboom_imageinstall_deps = $(STATEDIR)/prboom.targetinstall \
	$(STATEDIR)/virtual-image.install

$(STATEDIR)/prboom.imageinstall: $(prboom_imageinstall_deps)
	@$(call targetinfo, $@)
	cd $(FEEDDIR) && $(XIPKG) install prboom
	touch $@

# ----------------------------------------------------------------------------
# Clean
# ----------------------------------------------------------------------------

prboom_clean:
	rm -rf $(STATEDIR)/prboom.*
	rm -rf $(PRBOOM_DIR)

# vim: syntax=make
