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
ifdef PTXCONF_DOSBOX
PACKAGES += dosbox
endif

#
# Paths and names
#
DOSBOX_VENDOR_VERSION	= 1
DOSBOX_VERSION		= 0.61
###DOSBOX_VERSION		= 0.63
DOSBOX			= dosbox-$(DOSBOX_VERSION)
DOSBOX_SUFFIX		= tar.gz
DOSBOX_URL		= http://unc.dl.sourceforge.net/sourceforge/dosbox/$(DOSBOX).$(DOSBOX_SUFFIX)
DOSBOX_SOURCE		= $(SRCDIR)/$(DOSBOX).$(DOSBOX_SUFFIX)
DOSBOX_DIR		= $(BUILDDIR)/$(DOSBOX)
DOSBOX_IPKG_TMP		= $(DOSBOX_DIR)/ipkg_tmp

# ----------------------------------------------------------------------------
# Get
# ----------------------------------------------------------------------------

dosbox_get: $(STATEDIR)/dosbox.get

dosbox_get_deps = $(DOSBOX_SOURCE)

$(STATEDIR)/dosbox.get: $(dosbox_get_deps)
	@$(call targetinfo, $@)
	@$(call get_patches, $(DOSBOX))
	touch $@

$(DOSBOX_SOURCE):
	@$(call targetinfo, $@)
	@$(call get, $(DOSBOX_URL))

# ----------------------------------------------------------------------------
# Extract
# ----------------------------------------------------------------------------

dosbox_extract: $(STATEDIR)/dosbox.extract

dosbox_extract_deps = $(STATEDIR)/dosbox.get

$(STATEDIR)/dosbox.extract: $(dosbox_extract_deps)
	@$(call targetinfo, $@)
	@$(call clean, $(DOSBOX_DIR))
	@$(call extract, $(DOSBOX_SOURCE))
	@$(call patchin, $(DOSBOX))
	touch $@

# ----------------------------------------------------------------------------
# Prepare
# ----------------------------------------------------------------------------

dosbox_prepare: $(STATEDIR)/dosbox.prepare

#
# dependencies
#
dosbox_prepare_deps = \
	$(STATEDIR)/dosbox.extract \
	$(STATEDIR)/SDL.install \
	$(STATEDIR)/SDL_net.install \
	$(STATEDIR)/virtual-xchain.install

DOSBOX_PATH	=  PATH=$(CROSS_PATH)
DOSBOX_ENV 	=  $(CROSS_ENV)
#DOSBOX_ENV	+= CFLAGS="-O2 -fomit-frame-pointer"
#DOSBOX_ENV	+= CXXFLAGS="-O2 -fomit-frame-pointer -fno-rtti"
DOSBOX_ENV	+= PKG_CONFIG_PATH=$(CROSS_LIB_DIR)/lib/pkgconfig:$(CROSS_LIB_DIR)/lib/pkgconfig
#ifdef PTXCONF_XFREE430
#DOSBOX_ENV	+= LDFLAGS=-Wl,-rpath-link,$(CROSS_LIB_DIR)/lib
#endif

#
# autoconf
#
DOSBOX_AUTOCONF = \
	--build=$(GNU_HOST) \
	--host=$(PTXCONF_GNU_TARGET) \
	--prefix=/usr \
	--disable-debug

ifdef PTXCONF_ARCH_X86
DOSBOX_AUTOCONF += \
	--enable-core-inline \
	--disable-opengl
DOSBOX_ENV	+= CFLAGS="-O3 -fomit-frame-pointer"
DOSBOX_ENV	+= CXXFLAGS="-O3 -fomit-frame-pointer -fno-rtti"
endif

ifdef PTXCONF_ARCH_ARM
DOSBOX_AUTOCONF += \
	--enable-core-inline \
	--enable-dynamic-x86 \
	--enable-fpu \
	--disable-opengl
DOSBOX_ENV	+= CFLAGS="$(TARGET_OPT_CFLAGS)"
DOSBOX_ENV	+= CXXFLAGS="$(TARGET_OPT_CFLAGS) -fno-rtti"
endif

ifdef PTXCONF_XFREE430
DOSBOX_AUTOCONF += --x-includes=$(CROSS_LIB_DIR)/include
DOSBOX_AUTOCONF += --x-libraries=$(CROSS_LIB_DIR)/lib
endif

$(STATEDIR)/dosbox.prepare: $(dosbox_prepare_deps)
	@$(call targetinfo, $@)
	@$(call clean, $(DOSBOX_DIR)/config.cache)
	cd $(DOSBOX_DIR) && \
		$(DOSBOX_PATH) $(DOSBOX_ENV) \
		./configure $(DOSBOX_AUTOCONF)
	touch $@

# ----------------------------------------------------------------------------
# Compile
# ----------------------------------------------------------------------------

dosbox_compile: $(STATEDIR)/dosbox.compile

dosbox_compile_deps = $(STATEDIR)/dosbox.prepare

$(STATEDIR)/dosbox.compile: $(dosbox_compile_deps)
	@$(call targetinfo, $@)
	$(DOSBOX_PATH) $(MAKE) -C $(DOSBOX_DIR)
	touch $@

# ----------------------------------------------------------------------------
# Install
# ----------------------------------------------------------------------------

dosbox_install: $(STATEDIR)/dosbox.install

$(STATEDIR)/dosbox.install: $(STATEDIR)/dosbox.compile
	@$(call targetinfo, $@)
	$(DOSBOX_PATH) $(MAKE) -C $(DOSBOX_DIR) install
	touch $@

# ----------------------------------------------------------------------------
# Target-Install
# ----------------------------------------------------------------------------

dosbox_targetinstall: $(STATEDIR)/dosbox.targetinstall

dosbox_targetinstall_deps = $(STATEDIR)/dosbox.compile \
	$(STATEDIR)/SDL.targetinstall \
	$(STATEDIR)/SDL_net.targetinstall

$(STATEDIR)/dosbox.targetinstall: $(dosbox_targetinstall_deps)
	@$(call targetinfo, $@)
	$(DOSBOX_PATH) $(MAKE) -C $(DOSBOX_DIR) DESTDIR=$(DOSBOX_IPKG_TMP) install
	$(CROSSSTRIP) $(DOSBOX_IPKG_TMP)/usr/bin/*
	$(INSTALL) -m 644 -D $(TOPDIR)/config/pics/dosbox.desktop	$(DOSBOX_IPKG_TMP)/usr/share/applications/dosbox.desktop
	$(INSTALL) -m 644 -D $(TOPDIR)/config/pics/dosbox.png 		$(DOSBOX_IPKG_TMP)/usr/share/pixmaps/dosbox.png
	rm -rf $(DOSBOX_IPKG_TMP)/usr/man
	mkdir -p $(DOSBOX_IPKG_TMP)/CONTROL
	echo "Package: dosbox" 								 >$(DOSBOX_IPKG_TMP)/CONTROL/control
	echo "Priority: optional" 							>>$(DOSBOX_IPKG_TMP)/CONTROL/control
	echo "Section: Emulators" 							>>$(DOSBOX_IPKG_TMP)/CONTROL/control
	echo "Maintainer: Alexander Chukov <sash@pdaXrom.org>" 				>>$(DOSBOX_IPKG_TMP)/CONTROL/control
	echo "Architecture: $(SHORT_TARGET)" 						>>$(DOSBOX_IPKG_TMP)/CONTROL/control
	echo "Version: $(DOSBOX_VERSION)-$(DOSBOX_VENDOR_VERSION)" 			>>$(DOSBOX_IPKG_TMP)/CONTROL/control
	echo "Depends: sdl, sdl-net" 							>>$(DOSBOX_IPKG_TMP)/CONTROL/control
	echo "Description: a x86 emulator with DOS."					>>$(DOSBOX_IPKG_TMP)/CONTROL/control
	cd $(FEEDDIR) && $(XMKIPKG) $(DOSBOX_IPKG_TMP)
	touch $@

# ----------------------------------------------------------------------------
# Image-Install
# ----------------------------------------------------------------------------

ifdef PTXCONF_DOSBOX_INSTALL
ROMPACKAGES += $(STATEDIR)/dosbox.imageinstall
endif

dosbox_imageinstall_deps = $(STATEDIR)/dosbox.targetinstall \
	$(STATEDIR)/virtual-image.install

$(STATEDIR)/dosbox.imageinstall: $(dosbox_imageinstall_deps)
	@$(call targetinfo, $@)
	cd $(FEEDDIR) && $(XIPKG) install dosbox
	touch $@

# ----------------------------------------------------------------------------
# Clean
# ----------------------------------------------------------------------------

dosbox_clean:
	rm -rf $(STATEDIR)/dosbox.*
	rm -rf $(DOSBOX_DIR)

# vim: syntax=make
