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
ifdef PTXCONF_XVKBD
PACKAGES += xvkbd
endif

#
# Paths and names
#
XVKBD_VERSION_VENDOR	= -3
XVKBD_VERSION		= 2.6
XVKBD			= xvkbd-$(XVKBD_VERSION)
XVKBD_SUFFIX		= tar.gz
XVKBD_URL		= http://homepage3.nifty.com/tsato/xvkbd/$(XVKBD).$(XVKBD_SUFFIX)
XVKBD_SOURCE		= $(SRCDIR)/$(XVKBD).$(XVKBD_SUFFIX)
XVKBD_DIR		= $(BUILDDIR)/$(XVKBD)
XVKBD_IPKG_TMP		= $(XVKBD_DIR)/ipkg_tmp

# ----------------------------------------------------------------------------
# Get
# ----------------------------------------------------------------------------

xvkbd_get: $(STATEDIR)/xvkbd.get

xvkbd_get_deps = $(XVKBD_SOURCE)

$(STATEDIR)/xvkbd.get: $(xvkbd_get_deps)
	@$(call targetinfo, $@)
	@$(call get_patches, $(XVKBD))
	touch $@

$(XVKBD_SOURCE):
	@$(call targetinfo, $@)
	@$(call get, $(XVKBD_URL))

# ----------------------------------------------------------------------------
# Extract
# ----------------------------------------------------------------------------

xvkbd_extract: $(STATEDIR)/xvkbd.extract

xvkbd_extract_deps = $(STATEDIR)/xvkbd.get

$(STATEDIR)/xvkbd.extract: $(xvkbd_extract_deps)
	@$(call targetinfo, $@)
	@$(call clean, $(XVKBD_DIR))
	@$(call extract, $(XVKBD_SOURCE))
	@$(call patchin, $(XVKBD))
	touch $@

# ----------------------------------------------------------------------------
# Prepare
# ----------------------------------------------------------------------------

xvkbd_prepare: $(STATEDIR)/xvkbd.prepare

#
# dependencies
#
xvkbd_prepare_deps = \
	$(STATEDIR)/xvkbd.extract \
	$(STATEDIR)/xfree430.install \
	$(STATEDIR)/xresizewindow.install \
	$(STATEDIR)/virtual-xchain.install

XVKBD_PATH	=  PATH=$(CROSS_PATH)
XVKBD_ENV 	=  $(CROSS_ENV)
#XVKBD_ENV	+=
XVKBD_ENV	+= PKG_CONFIG_PATH=$(CROSS_LIB_DIR)/lib/pkgconfig:$(CROSS_LIB_DIR)/lib/pkgconfig
#ifdef PTXCONF_XFREE430
#XVKBD_ENV	+= LDFLAGS=-Wl,-rpath-link,$(CROSS_LIB_DIR)/lib
#endif

#
# autoconf
#
XVKBD_AUTOCONF = \
	--build=$(GNU_HOST) \
	--host=$(PTXCONF_GNU_TARGET) \
	--prefix=/usr

ifdef PTXCONF_XFREE430
XVKBD_AUTOCONF += --x-includes=$(CROSS_LIB_DIR)/include
XVKBD_AUTOCONF += --x-libraries=$(CROSS_LIB_DIR)/lib
endif

$(STATEDIR)/xvkbd.prepare: $(xvkbd_prepare_deps)
	@$(call targetinfo, $@)
	@$(call clean, $(XVKBD_DIR)/config.cache)
	perl -i -p -e "s,\#define XAW3D,,g" $(XVKBD_DIR)/Imakefile
	perl -i -p -e "s,\#define XAW3D,,g" $(XVKBD_DIR)/Imakefile
	perl -i -p -e "s,\#define XAW3D,,g" $(XVKBD_DIR)/Imakefile
	cd $(XVKBD_DIR) &&  $(XVKBD_PATH) $(XVKBD_ENV) imake -I$(XFREE430_DIR)/config/cf
	perl -i -p -e "s,\\$$\(TOP\)/exports/include,$(CROSS_LIB_DIR)/include,g" $(XVKBD_DIR)/Makefile
	perl -i -p -e "s,\\$$\(TOP\)/exports/lib,$(CROSS_LIB_DIR)/lib,g" $(XVKBD_DIR)/Makefile
	touch $@

# ----------------------------------------------------------------------------
# Compile
# ----------------------------------------------------------------------------

xvkbd_compile: $(STATEDIR)/xvkbd.compile

xvkbd_compile_deps = $(STATEDIR)/xvkbd.prepare

$(STATEDIR)/xvkbd.compile: $(xvkbd_compile_deps)
	@$(call targetinfo, $@)
	$(XVKBD_PATH) $(MAKE) -C $(XVKBD_DIR) RMAN=true RMANBASENAME=true $(CROSS_ENV_CC)
	touch $@

# ----------------------------------------------------------------------------
# Install
# ----------------------------------------------------------------------------

xvkbd_install: $(STATEDIR)/xvkbd.install

$(STATEDIR)/xvkbd.install: $(STATEDIR)/xvkbd.compile
	@$(call targetinfo, $@)
	touch $@

# ----------------------------------------------------------------------------
# Target-Install
# ----------------------------------------------------------------------------

xvkbd_targetinstall: $(STATEDIR)/xvkbd.targetinstall

xvkbd_targetinstall_deps = $(STATEDIR)/xvkbd.compile \
	$(STATEDIR)/xfree430.targetinstall \
	$(STATEDIR)/xresizewindow.targetinstall

$(STATEDIR)/xvkbd.targetinstall: $(xvkbd_targetinstall_deps)
	@$(call targetinfo, $@)
	$(XVKBD_PATH) $(MAKE) -C $(XVKBD_DIR) DESTDIR=$(XVKBD_IPKG_TMP) install RMAN=true RMANBASENAME=true $(CROSS_ENV_CC)
	$(CROSSSTRIP) $(XVKBD_IPKG_TMP)/usr/X11R6/bin/*
	mkdir -p $(XVKBD_IPKG_TMP)/etc/X11/app-defaults
	mkdir -p $(XVKBD_IPKG_TMP)/usr/bin
	mkdir -p $(XVKBD_IPKG_TMP)/usr/share/{pixmaps,applications,dict}
	cp -af $(TOPDIR)/config/pics/XVkbd-common   $(XVKBD_IPKG_TMP)/etc/X11/app-defaults
	cp -a $(TOPDIR)/config/pics/xvkbdlauncher  $(XVKBD_IPKG_TMP)/usr/bin/
	cp -a $(TOPDIR)/config/pics/xkbd.png	   $(XVKBD_IPKG_TMP)/usr/share/pixmaps/xvkbd.png
	cp -a $(TOPDIR)/config/pics/xvkbd.desktop  $(XVKBD_IPKG_TMP)/usr/share/applications/
	cp -a $(TOPDIR)/config/pics/mb-launcher-xvkb.desktop  $(XVKBD_IPKG_TMP)/usr/share/applications/
	rm -rf $(XVKBD_IPKG_TMP)/usr/X11R6/lib/X11
	cp -a $(TOPDIR)/config/pics/xvkbd.dic	   $(XVKBD_IPKG_TMP)/usr/share/dict/
	mkdir -p $(XVKBD_IPKG_TMP)/CONTROL
	echo "Package: xvkbd" 							>$(XVKBD_IPKG_TMP)/CONTROL/control
	echo "Priority: optional" 						>>$(XVKBD_IPKG_TMP)/CONTROL/control
	echo "Section: X11"	 						>>$(XVKBD_IPKG_TMP)/CONTROL/control
	echo "Maintainer: Alexander Chukov <sash@pdaXrom.org>" 			>>$(XVKBD_IPKG_TMP)/CONTROL/control
	echo "Architecture: $(SHORT_TARGET)" 					>>$(XVKBD_IPKG_TMP)/CONTROL/control
	echo "Version: $(XVKBD_VERSION)$(XVKBD_VERSION_VENDOR)" 		>>$(XVKBD_IPKG_TMP)/CONTROL/control
	echo "Depends: xfree430, xresizewindow" 				>>$(XVKBD_IPKG_TMP)/CONTROL/control
	echo "Description: Virtual keyboard for X window system"		>>$(XVKBD_IPKG_TMP)/CONTROL/control
	cd $(FEEDDIR) && $(XMKIPKG) $(XVKBD_IPKG_TMP)
	touch $@

# ----------------------------------------------------------------------------
# Image-Install
# ----------------------------------------------------------------------------

ifdef PTXCONF_XVKBD_INSTALL
ROMPACKAGES += $(STATEDIR)/xvkbd.imageinstall
endif

xvkbd_imageinstall_deps = $(STATEDIR)/xvkbd.targetinstall \
	$(STATEDIR)/virtual-image.install

$(STATEDIR)/xvkbd.imageinstall: $(xvkbd_imageinstall_deps)
	@$(call targetinfo, $@)
	cd $(FEEDDIR) && $(XIPKG) install xvkbd
	touch $@

# ----------------------------------------------------------------------------
# Clean
# ----------------------------------------------------------------------------

xvkbd_clean:
	rm -rf $(STATEDIR)/xvkbd.*
	rm -rf $(XVKBD_DIR)

# vim: syntax=make
