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
ifdef PTXCONF_XKBD
PACKAGES += xkbd
endif

#
# Paths and names
#
XKBD_VERSION		= 0.8.15
XKBD			= xkbd-$(XKBD_VERSION)
XKBD_SUFFIX		= tar.gz
XKBD_URL		= http://handhelds.org/~mallum/xkbd/$(XKBD).$(XKBD_SUFFIX)
XKBD_SOURCE		= $(SRCDIR)/$(XKBD).$(XKBD_SUFFIX)
XKBD_DIR		= $(BUILDDIR)/$(XKBD)
XKBD_IPKG_TMP		= $(XKBD_DIR)/ipkg_tmp

# ----------------------------------------------------------------------------
# Get
# ----------------------------------------------------------------------------

xkbd_get: $(STATEDIR)/xkbd.get

xkbd_get_deps = $(XKBD_SOURCE)

$(STATEDIR)/xkbd.get: $(xkbd_get_deps)
	@$(call targetinfo, $@)
	@$(call get_patches, $(XKBD))
	touch $@

$(XKBD_SOURCE):
	@$(call targetinfo, $@)
	@$(call get, $(XKBD_URL))

# ----------------------------------------------------------------------------
# Extract
# ----------------------------------------------------------------------------

xkbd_extract: $(STATEDIR)/xkbd.extract

xkbd_extract_deps = $(STATEDIR)/xkbd.get

$(STATEDIR)/xkbd.extract: $(xkbd_extract_deps)
	@$(call targetinfo, $@)
	@$(call clean, $(XKBD_DIR))
	@$(call extract, $(XKBD_SOURCE))
	@$(call patchin, $(XKBD))
	touch $@

# ----------------------------------------------------------------------------
# Prepare
# ----------------------------------------------------------------------------

xkbd_prepare: $(STATEDIR)/xkbd.prepare

#
# dependencies
#
xkbd_prepare_deps = \
	$(STATEDIR)/xkbd.extract \
	$(STATEDIR)/xfree430.install \
	$(STATEDIR)/xresizewindow.install \
	$(STATEDIR)/virtual-xchain.install

XKBD_PATH	=  PATH=$(CROSS_PATH)
XKBD_ENV 	=  $(CROSS_ENV)
XKBD_ENV	+= CFLAGS="-O2 -fomit-frame-pointer"
XKBD_ENV	+= PKG_CONFIG_PATH=$(CROSS_LIB_DIR)/lib/pkgconfig:$(CROSS_LIB_DIR)/lib/pkgconfig
#ifdef PTXCONF_XFREE430
#XKBD_ENV	+= LDFLAGS=-Wl,-rpath-link,$(CROSS_LIB_DIR)/lib
#endif

#
# autoconf
#
XKBD_AUTOCONF = \
	--build=$(GNU_HOST) \
	--host=$(PTXCONF_GNU_TARGET) \
	--prefix=/usr

ifdef PTXCONF_XFREE430
XKBD_AUTOCONF += --x-includes=$(CROSS_LIB_DIR)/include
XKBD_AUTOCONF += --x-libraries=$(CROSS_LIB_DIR)/lib
endif

$(STATEDIR)/xkbd.prepare: $(xkbd_prepare_deps)
	@$(call targetinfo, $@)
	@$(call clean, $(XKBD_DIR)/config.cache)
	cd $(XKBD_DIR) && \
		$(XKBD_PATH) $(XKBD_ENV) \
		./configure $(XKBD_AUTOCONF)
	touch $@

# ----------------------------------------------------------------------------
# Compile
# ----------------------------------------------------------------------------

xkbd_compile: $(STATEDIR)/xkbd.compile

xkbd_compile_deps = $(STATEDIR)/xkbd.prepare

$(STATEDIR)/xkbd.compile: $(xkbd_compile_deps)
	@$(call targetinfo, $@)
	$(XKBD_PATH) $(MAKE) -C $(XKBD_DIR)
	touch $@

# ----------------------------------------------------------------------------
# Install
# ----------------------------------------------------------------------------

xkbd_install: $(STATEDIR)/xkbd.install

$(STATEDIR)/xkbd.install: $(STATEDIR)/xkbd.compile
	@$(call targetinfo, $@)
	touch $@

# ----------------------------------------------------------------------------
# Target-Install
# ----------------------------------------------------------------------------

xkbd_targetinstall: $(STATEDIR)/xkbd.targetinstall

xkbd_targetinstall_deps = $(STATEDIR)/xkbd.compile \
	$(STATEDIR)/xfree430.targetinstall \
	$(STATEDIR)/xresizewindow.targetinstall

$(STATEDIR)/xkbd.targetinstall: $(xkbd_targetinstall_deps)
	@$(call targetinfo, $@)
	$(XKBD_PATH) $(MAKE) -C $(XKBD_DIR) DESTDIR=$(XKBD_IPKG_TMP) install mkdir_p="mkdir -p"
	rm -rf $(XKBD_IPKG_TMP)/usr/man
	$(CROSSSTRIP) $(XKBD_IPKG_TMP)/usr/bin/*
	rm -rf $(XKBD_IPKG_TMP)/usr/share/applications/*
	cp -a $(TOPDIR)/config/pics/xkbd.png	 $(XKBD_IPKG_TMP)/usr/share/pixmaps
	cp -a $(TOPDIR)/config/pics/xkbd.desktop $(XKBD_IPKG_TMP)/usr/share/applications
	cp -a $(TOPDIR)/config/pics/xkbdlauncher $(XKBD_IPKG_TMP)/usr/bin
	mkdir -p $(XKBD_IPKG_TMP)/CONTROL
	echo "Package: xkbd" 					 >$(XKBD_IPKG_TMP)/CONTROL/control
	echo "Priority: optional" 				>>$(XKBD_IPKG_TMP)/CONTROL/control
	echo "Section: X11"	 				>>$(XKBD_IPKG_TMP)/CONTROL/control
	echo "Maintainer: mallum <mallum@handhelds.org>" 	>>$(XKBD_IPKG_TMP)/CONTROL/control
	echo "Architecture: $(SHORT_TARGET)" 			>>$(XKBD_IPKG_TMP)/CONTROL/control
	echo "Version: $(XKBD_VERSION)" 			>>$(XKBD_IPKG_TMP)/CONTROL/control
	echo "Depends: xfree430, xresizewindow" 		>>$(XKBD_IPKG_TMP)/CONTROL/control
	echo "Description: A small, highly configurable virtual on-screen keyboard for X11 based on xlib.">>$(XKBD_IPKG_TMP)/CONTROL/control
	cd $(FEEDDIR) && $(XMKIPKG) $(XKBD_IPKG_TMP)
	touch $@

# ----------------------------------------------------------------------------
# Image-Install
# ----------------------------------------------------------------------------

ifdef PTXCONF_XKBD_INSTALL
ROMPACKAGES += $(STATEDIR)/xkbd.imageinstall
endif

xkbd_imageinstall_deps = $(STATEDIR)/xkbd.targetinstall \
	$(STATEDIR)/virtual-image.install

$(STATEDIR)/xkbd.imageinstall: $(xkbd_imageinstall_deps)
	@$(call targetinfo, $@)
	cd $(FEEDDIR) && $(XIPKG) install xkbd
	touch $@

# ----------------------------------------------------------------------------
# Clean
# ----------------------------------------------------------------------------

xkbd_clean:
	rm -rf $(STATEDIR)/xkbd.*
	rm -rf $(XKBD_DIR)

# vim: syntax=make
