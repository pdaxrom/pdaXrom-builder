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
ifdef PTXCONF_TIMIDITY
PACKAGES += TiMidity
endif

#
# Paths and names
#
TIMIDITY_VERSION	= 2.13.2
TIMIDITY		= TiMidity++-$(TIMIDITY_VERSION)
TIMIDITY_SUFFIX		= tar.bz2
TIMIDITY_URL		= http://easynews.dl.sourceforge.net/sourceforge/timidity/$(TIMIDITY).$(TIMIDITY_SUFFIX)
TIMIDITY_SOURCE		= $(SRCDIR)/$(TIMIDITY).$(TIMIDITY_SUFFIX)
TIMIDITY_DIR		= $(BUILDDIR)/$(TIMIDITY)
TIMIDITY_IPKG_TMP	= $(TIMIDITY_DIR)/ipkg_tmp

# ----------------------------------------------------------------------------
# Get
# ----------------------------------------------------------------------------

TiMidity_get: $(STATEDIR)/TiMidity.get

TiMidity_get_deps = $(TIMIDITY_SOURCE)

$(STATEDIR)/TiMidity.get: $(TiMidity_get_deps)
	@$(call targetinfo, $@)
	@$(call get_patches, $(TIMIDITY))
	touch $@

$(TIMIDITY_SOURCE):
	@$(call targetinfo, $@)
	@$(call get, $(TIMIDITY_URL))

# ----------------------------------------------------------------------------
# Extract
# ----------------------------------------------------------------------------

TiMidity_extract: $(STATEDIR)/TiMidity.extract

TiMidity_extract_deps = $(STATEDIR)/TiMidity.get

$(STATEDIR)/TiMidity.extract: $(TiMidity_extract_deps)
	@$(call targetinfo, $@)
	@$(call clean, $(TIMIDITY_DIR))
	@$(call extract, $(TIMIDITY_SOURCE))
	@$(call patchin, $(TIMIDITY))
	touch $@

# ----------------------------------------------------------------------------
# Prepare
# ----------------------------------------------------------------------------

TiMidity_prepare: $(STATEDIR)/TiMidity.prepare

#
# dependencies
#
TiMidity_prepare_deps = \
	$(STATEDIR)/TiMidity.extract \
	$(STATEDIR)/esound.install \
	$(STATEDIR)/gtk22.install \
	$(STATEDIR)/virtual-xchain.install

TIMIDITY_PATH	=  PATH=$(CROSS_PATH)
TIMIDITY_ENV 	=  $(CROSS_ENV)
TIMIDITY_ENV	+= CFLAGS="$(TARGET_OPT_CFLAGS)"
TIMIDITY_ENV	+= PKG_CONFIG_PATH=$(CROSS_LIB_DIR)/lib/pkgconfig:$(CROSS_LIB_DIR)/lib/pkgconfig
#ifdef PTXCONF_XFREE430
#TIMIDITY_ENV	+= LDFLAGS=-Wl,-rpath-link,$(CROSS_LIB_DIR)/lib
#endif

#
# autoconf
#
TIMIDITY_AUTOCONF = \
	--build=$(GNU_HOST) \
	--host=$(PTXCONF_GNU_TARGET) \
	--prefix=/usr \
	--enable-audio=oss,esd \
	--enable-dynamic=ncurses,gtk

#	--enable-ncurses
#	--enable-gtk

ifdef PTXCONF_XFREE430
TIMIDITY_AUTOCONF += --x-includes=$(CROSS_LIB_DIR)/include
TIMIDITY_AUTOCONF += --x-libraries=$(CROSS_LIB_DIR)/lib
endif

$(STATEDIR)/TiMidity.prepare: $(TiMidity_prepare_deps)
	@$(call targetinfo, $@)
	@$(call clean, $(TIMIDITY_DIR)/config.cache)
	cd $(TIMIDITY_DIR) && \
		$(TIMIDITY_PATH) $(TIMIDITY_ENV) \
		./configure $(TIMIDITY_AUTOCONF)
	touch $@

# ----------------------------------------------------------------------------
# Compile
# ----------------------------------------------------------------------------

TiMidity_compile: $(STATEDIR)/TiMidity.compile

TiMidity_compile_deps = $(STATEDIR)/TiMidity.prepare

$(STATEDIR)/TiMidity.compile: $(TiMidity_compile_deps)
	@$(call targetinfo, $@)
	$(TIMIDITY_PATH) $(MAKE) -C $(TIMIDITY_DIR) HOST_CC=gcc
	touch $@

# ----------------------------------------------------------------------------
# Install
# ----------------------------------------------------------------------------

TiMidity_install: $(STATEDIR)/TiMidity.install

$(STATEDIR)/TiMidity.install: $(STATEDIR)/TiMidity.compile
	@$(call targetinfo, $@)
	touch $@

# ----------------------------------------------------------------------------
# Target-Install
# ----------------------------------------------------------------------------

TiMidity_targetinstall: $(STATEDIR)/TiMidity.targetinstall

TiMidity_targetinstall_deps = $(STATEDIR)/TiMidity.compile \
	$(STATEDIR)/esound.targetinstall \
	$(STATEDIR)/gtk22.targetinstall

$(STATEDIR)/TiMidity.targetinstall: $(TiMidity_targetinstall_deps)
	@$(call targetinfo, $@)
	$(TIMIDITY_PATH) $(MAKE) -C $(TIMIDITY_DIR) DESTDIR=$(TIMIDITY_IPKG_TMP) install
	$(CROSSSTRIP) $(TIMIDITY_IPKG_TMP)/usr/bin/*
	$(CROSSSTRIP) $(TIMIDITY_IPKG_TMP)/usr/lib/timidity/*.so
	rm -rf $(TIMIDITY_IPKG_TMP)/usr/man
	mkdir -p $(TIMIDITY_IPKG_TMP)/usr/share/{applications,pixmaps}
	cp -f $(TOPDIR)/config/pics/timidity.desktop		$(TIMIDITY_IPKG_TMP)/usr/share/applications/
	cp -f $(TIMIDITY_DIR)/interface/pixmaps/timidity.xpm	$(TIMIDITY_IPKG_TMP)/usr/share/pixmaps/
	mkdir -p $(TIMIDITY_IPKG_TMP)/CONTROL
	echo "Package: timidity" 						>$(TIMIDITY_IPKG_TMP)/CONTROL/control
	echo "Priority: optional" 						>>$(TIMIDITY_IPKG_TMP)/CONTROL/control
	echo "Section: Multimedia" 						>>$(TIMIDITY_IPKG_TMP)/CONTROL/control
	echo "Maintainer: Vladimir Bourdigyn <vladimip@bk.ru>" 			>>$(TIMIDITY_IPKG_TMP)/CONTROL/control
	echo "Architecture: $(SHORT_TARGET)" 					>>$(TIMIDITY_IPKG_TMP)/CONTROL/control
	echo "Version: $(TIMIDITY_VERSION)" 					>>$(TIMIDITY_IPKG_TMP)/CONTROL/control
	echo "Depends: esound, gtk2" 						>>$(TIMIDITY_IPKG_TMP)/CONTROL/control
	echo "Description: Midi player"						>>$(TIMIDITY_IPKG_TMP)/CONTROL/control
	cd $(FEEDDIR) && $(XMKIPKG) $(TIMIDITY_IPKG_TMP)
	touch $@

# ----------------------------------------------------------------------------
# Image-Install
# ----------------------------------------------------------------------------

ifdef PTXCONF_TIMIDITY_INSTALL
ROMPACKAGES += $(STATEDIR)/TiMidity.imageinstall
endif

TiMidity_imageinstall_deps = $(STATEDIR)/TiMidity.targetinstall \
	$(STATEDIR)/virtual-image.install

$(STATEDIR)/TiMidity.imageinstall: $(TiMidity_imageinstall_deps)
	@$(call targetinfo, $@)
	cd $(FEEDDIR) && $(XIPKG) install timidity
	touch $@

# ----------------------------------------------------------------------------
# Clean
# ----------------------------------------------------------------------------

TiMidity_clean:
	rm -rf $(STATEDIR)/TiMidity.*
	rm -rf $(TIMIDITY_DIR)

# vim: syntax=make
