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
ifdef PTXCONF_XDEMINEUR
PACKAGES += xdemineur
endif

#
# Paths and names
#
XDEMINEUR_VERSION	= 2.1.1
XDEMINEUR		= xdemineur-$(XDEMINEUR_VERSION)
XDEMINEUR_SUFFIX	= tar.gz
XDEMINEUR_URL		= http://ftp.debian.org/debian/pool/main/x/xdemineur/xdemineur_$(XDEMINEUR_VERSION).orig.tar.gz
XDEMINEUR_SOURCE	= $(SRCDIR)/xdemineur_$(XDEMINEUR_VERSION).orig.tar.gz
XDEMINEUR_DIR		= $(BUILDDIR)/$(XDEMINEUR)
XDEMINEUR_IPKG_TMP	= $(XDEMINEUR_DIR)/ipkg_tmp

# ----------------------------------------------------------------------------
# Get
# ----------------------------------------------------------------------------

xdemineur_get: $(STATEDIR)/xdemineur.get

xdemineur_get_deps = $(XDEMINEUR_SOURCE)

$(STATEDIR)/xdemineur.get: $(xdemineur_get_deps)
	@$(call targetinfo, $@)
	@$(call get_patches, $(XDEMINEUR))
	touch $@

$(XDEMINEUR_SOURCE):
	@$(call targetinfo, $@)
	@$(call get, $(XDEMINEUR_URL))

# ----------------------------------------------------------------------------
# Extract
# ----------------------------------------------------------------------------

xdemineur_extract: $(STATEDIR)/xdemineur.extract

xdemineur_extract_deps = $(STATEDIR)/xdemineur.get

$(STATEDIR)/xdemineur.extract: $(xdemineur_extract_deps)
	@$(call targetinfo, $@)
	@$(call clean, $(XDEMINEUR_DIR))
	@$(call extract, $(XDEMINEUR_SOURCE))
	@$(call patchin, $(XDEMINEUR))
	touch $@

# ----------------------------------------------------------------------------
# Prepare
# ----------------------------------------------------------------------------

xdemineur_prepare: $(STATEDIR)/xdemineur.prepare

#
# dependencies
#
xdemineur_prepare_deps = \
	$(STATEDIR)/xdemineur.extract \
	$(STATEDIR)/xfree430.install \
	$(STATEDIR)/virtual-xchain.install

XDEMINEUR_PATH	=  PATH=$(CROSS_PATH)
XDEMINEUR_ENV 	=  $(CROSS_ENV)
XDEMINEUR_ENV	+= CFLAGS="-O2 -fomit-frame-pointer"
XDEMINEUR_ENV	+= PKG_CONFIG_PATH=$(CROSS_LIB_DIR)/lib/pkgconfig:$(CROSS_LIB_DIR)/lib/pkgconfig
#ifdef PTXCONF_XFREE430
#XDEMINEUR_ENV	+= LDFLAGS=-Wl,-rpath-link,$(CROSS_LIB_DIR)/lib
#endif

#
# autoconf
#
XDEMINEUR_AUTOCONF = \
	--build=$(GNU_HOST) \
	--host=$(PTXCONF_GNU_TARGET) \
	--prefix=/usr

ifdef PTXCONF_XFREE430
XDEMINEUR_AUTOCONF += --x-includes=$(CROSS_LIB_DIR)/include
XDEMINEUR_AUTOCONF += --x-libraries=$(CROSS_LIB_DIR)/lib
endif

$(STATEDIR)/xdemineur.prepare: $(xdemineur_prepare_deps)
	@$(call targetinfo, $@)
	@$(call clean, $(XDEMINEUR_DIR)/config.cache)
	###cd $(XDEMINEUR_DIR) && xmkmf
	#cd $(XDEMINEUR_DIR) && $(XFREE430_DIR)/config/imake/imake -I$(XFREE430_DIR)/config/cf
	cd $(XDEMINEUR_DIR) && imake -I$(XFREE430_DIR)/config/cf
	touch $@

# ----------------------------------------------------------------------------
# Compile
# ----------------------------------------------------------------------------

xdemineur_compile: $(STATEDIR)/xdemineur.compile

xdemineur_compile_deps = $(STATEDIR)/xdemineur.prepare

$(STATEDIR)/xdemineur.compile: $(xdemineur_compile_deps)
	@$(call targetinfo, $@)
	$(XDEMINEUR_PATH) $(MAKE) -C $(XDEMINEUR_DIR) \
	    CC=$(PTXCONF_GNU_TARGET)-gcc \
	    CFLAGS="-O2 -fomit-frame-pointer -I$(CROSS_LIB_DIR)/include" \
	    LDLIBS=-L$(CROSS_LIB_DIR)/lib \
	    USRLIBDIR=. \
	    RMAN=true RMANBASENAME=true
	touch $@

# ----------------------------------------------------------------------------
# Install
# ----------------------------------------------------------------------------

xdemineur_install: $(STATEDIR)/xdemineur.install

$(STATEDIR)/xdemineur.install: $(STATEDIR)/xdemineur.compile
	@$(call targetinfo, $@)
	touch $@

# ----------------------------------------------------------------------------
# Target-Install
# ----------------------------------------------------------------------------

xdemineur_targetinstall: $(STATEDIR)/xdemineur.targetinstall

xdemineur_targetinstall_deps = $(STATEDIR)/xdemineur.compile \
	$(STATEDIR)/xfree430.targetinstall

$(STATEDIR)/xdemineur.targetinstall: $(xdemineur_targetinstall_deps)
	@$(call targetinfo, $@)
	mkdir -p $(XDEMINEUR_IPKG_TMP)/usr/bin
	mkdir -p $(XDEMINEUR_IPKG_TMP)/usr/share/applications
	mkdir -p $(XDEMINEUR_IPKG_TMP)/usr/share/pixmaps
	cp -a $(XDEMINEUR_DIR)/xdemineur $(XDEMINEUR_IPKG_TMP)/usr/bin
	$(CROSSSTRIP) $(XDEMINEUR_IPKG_TMP)/usr/bin/*
	cp -a $(TOPDIR)/config/pics/xdemineur.desktop $(XDEMINEUR_IPKG_TMP)/usr/share/applications
	cp -a $(TOPDIR)/config/pics/kmines.png        $(XDEMINEUR_IPKG_TMP)/usr/share/pixmaps
	mkdir -p $(XDEMINEUR_IPKG_TMP)/CONTROL
	echo "Package: xdemineur" 				 >$(XDEMINEUR_IPKG_TMP)/CONTROL/control
	echo "Priority: optional" 				>>$(XDEMINEUR_IPKG_TMP)/CONTROL/control
	echo "Section: Games"	 				>>$(XDEMINEUR_IPKG_TMP)/CONTROL/control
	echo "Maintainer: Alexander Chukov <sash@pdaXrom.org>"	>>$(XDEMINEUR_IPKG_TMP)/CONTROL/control
	echo "Architecture: $(SHORT_TARGET)" 			>>$(XDEMINEUR_IPKG_TMP)/CONTROL/control
	echo "Version: $(XDEMINEUR_VERSION)" 			>>$(XDEMINEUR_IPKG_TMP)/CONTROL/control
	echo "Depends: xfree430" 				>>$(XDEMINEUR_IPKG_TMP)/CONTROL/control
	echo "Description: Yet another minesweeper for X"	>>$(XDEMINEUR_IPKG_TMP)/CONTROL/control
	cd $(FEEDDIR) && $(XMKIPKG) $(XDEMINEUR_IPKG_TMP)
	touch $@

# ----------------------------------------------------------------------------
# Image-Install
# ----------------------------------------------------------------------------

ifdef PTXCONF_XDEMINEUR_INSTALL
ROMPACKAGES += $(STATEDIR)/xdemineur.imageinstall
endif

xdemineur_imageinstall_deps = $(STATEDIR)/xdemineur.targetinstall \
	$(STATEDIR)/virtual-image.install

$(STATEDIR)/xdemineur.imageinstall: $(xdemineur_imageinstall_deps)
	@$(call targetinfo, $@)
	cd $(FEEDDIR) && $(XIPKG) install xdemineur
	touch $@

# ----------------------------------------------------------------------------
# Clean
# ----------------------------------------------------------------------------

xdemineur_clean:
	rm -rf $(STATEDIR)/xdemineur.*
	rm -rf $(XDEMINEUR_DIR)

# vim: syntax=make
