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
ifdef PTXCONF_MPLAYER
PACKAGES += MPlayer
endif

#
# Paths and names
#
MPLAYER_VERSION		= 1.0pre5
MPLAYER			= MPlayer-$(MPLAYER_VERSION)
MPLAYER_SUFFIX		= tar.bz2
MPLAYER_URL		= http://www1.mplayerhq.hu/MPlayer/releases/$(MPLAYER).$(MPLAYER_SUFFIX)
MPLAYER_SOURCE		= $(SRCDIR)/$(MPLAYER).$(MPLAYER_SUFFIX)
MPLAYER_DIR		= $(BUILDDIR)/$(MPLAYER)
MPLAYER_IPKG_TMP	= $(MPLAYER_DIR)/ipkg_tmp
MPLAYER_IPP_SOURCE	= $(SRCDIR)/ipp_arm_lnx.tar.bz2

# ----------------------------------------------------------------------------
# Get
# ----------------------------------------------------------------------------

MPlayer_get: $(STATEDIR)/MPlayer.get

MPlayer_get_deps = $(MPLAYER_SOURCE)

$(STATEDIR)/MPlayer.get: $(MPlayer_get_deps)
	@$(call targetinfo, $@)
	@$(call get_patches, $(MPLAYER))
	touch $@

$(MPLAYER_SOURCE):
	@$(call targetinfo, $@)
	@$(call get, $(MPLAYER_URL))

# ----------------------------------------------------------------------------
# Extract
# ----------------------------------------------------------------------------

MPlayer_extract: $(STATEDIR)/MPlayer.extract

MPlayer_extract_deps = $(STATEDIR)/MPlayer.get

$(STATEDIR)/MPlayer.extract: $(MPlayer_extract_deps)
	@$(call targetinfo, $@)
	@$(call clean, $(MPLAYER_DIR))
	@$(call extract, $(MPLAYER_SOURCE))
	@$(call patchin, $(MPLAYER))
	@$(call extract, $(MPLAYER_IPP_SOURCE), $(MPLAYER_DIR))
	touch $@

# ----------------------------------------------------------------------------
# Prepare
# ----------------------------------------------------------------------------

MPlayer_prepare: $(STATEDIR)/MPlayer.prepare

#
# dependencies
#
MPlayer_prepare_deps = \
	$(STATEDIR)/MPlayer.extract \
	$(STATEDIR)/esound.install \
	$(STATEDIR)/xfree430.install \
	$(STATEDIR)/libmad.install \
	$(STATEDIR)/tremor.install \
	$(STATEDIR)/SDL.install \
	$(STATEDIR)/ffmpeg.install \
	$(STATEDIR)/virtual-xchain.install

ifdef PTXCONF_ALSA-UTILS
MPlayer_prepare_deps += $(STATEDIR)/alsa-lib.install
endif

MPLAYER_PATH	=  PATH=$(CROSS_PATH)
MPLAYER_ENV 	=  $(CROSS_ENV)
#MPLAYER_ENV	+=
MPLAYER_ENV	+= PKG_CONFIG_PATH=$(CROSS_LIB_DIR)/lib/pkgconfig:$(CROSS_LIB_DIR)/lib/pkgconfig
#ifdef PTXCONF_XFREE430
#MPLAYER_ENV	+= LDFLAGS=-Wl,-rpath-link,$(CROSS_LIB_DIR)/lib
#endif

#
# autoconf
#
MPLAYER_AUTOCONF = \
	--target=$(PTXCONF_GNU_TARGET) \
	--prefix=/usr \
	--disable-arts \
	--disable-sunaudio \
	--disable-nas \
	--disable-gui \
	--disable-mpdvdkit \
	--disable-big-endian \
	--enable-esd \
	--enable-png \
	--enable-jpeg \
	--enable-freetype \
	--enable-sdl \
	--enable-menu \
	--enable-fbdev \
	--enable-vorbis \
	--enable-tremor \
	--with-extraincdir=$(CROSS_LIB_DIR)/include \
	--with-extralibdir=$(CROSS_LIB_DIR)/lib \
	--with-x11incdir=$(CROSS_LIB_DIR)/include \
	--with-x11libdir=$(CROSS_LIB_DIR)/lib \
	--cc=$(PTXCONF_GNU_TARGET)-gcc \
	--disable-mencoder \
	--enable-rtc \
	--enable-linux-devfs \
	--confdir=/usr/share/mplayer \
	--disable-static \
	--disable-libavcodec \
	--disable-gl

ifdef PTXCONF_ARCH_ARM
MPLAYER_AUTOCONF += --enable-ipp
MPLAYER_AUTOCONF += --with-ippincdir=$(MPLAYER_DIR)/ipp/include
MPLAYER_AUTOCONF += --with-ipplibdir=$(MPLAYER_DIR)/ipp/lib
MPLAYER_AUTOCONF += --enable-w100
MPLAYER_AUTOCONF += --disable-mp3lib
MPLAYER_AUTOCONF += --disable-tv
MPLAYER_AUTOCONF += --disable-liba52
endif

ifndef PTXCONF_ALSA-UTILS
MPLAYER_AUTOCONF += --disable-alsa
endif

#ifdef PTXCONF_XFREE430
#MPLAYER_AUTOCONF += --x-includes=$(CROSS_LIB_DIR)/include
#MPLAYER_AUTOCONF += --x-libraries=$(CROSS_LIB_DIR)/lib
#endif

$(STATEDIR)/MPlayer.prepare: $(MPlayer_prepare_deps)
	@$(call targetinfo, $@)
	@$(call clean, $(MPLAYER_DIR)/config.cache)
	cd $(MPLAYER_DIR) && \
		$(MPLAYER_PATH) $(MPLAYER_ENV) \
		./configure $(MPLAYER_AUTOCONF)
	touch $@

# ----------------------------------------------------------------------------
# Compile
# ----------------------------------------------------------------------------

MPlayer_compile: $(STATEDIR)/MPlayer.compile

MPlayer_compile_deps = $(STATEDIR)/MPlayer.prepare

$(STATEDIR)/MPlayer.compile: $(MPlayer_compile_deps)
	@$(call targetinfo, $@)
	$(MPLAYER_PATH) $(MAKE) -C $(MPLAYER_DIR) HOST_CC=gcc
	touch $@

# ----------------------------------------------------------------------------
# Install
# ----------------------------------------------------------------------------

MPlayer_install: $(STATEDIR)/MPlayer.install

$(STATEDIR)/MPlayer.install: $(STATEDIR)/MPlayer.compile
	@$(call targetinfo, $@)
	###$(MPLAYER_PATH) $(MAKE) -C $(MPLAYER_DIR) install
	touch $@

# ----------------------------------------------------------------------------
# Target-Install
# ----------------------------------------------------------------------------

MPlayer_targetinstall: $(STATEDIR)/MPlayer.targetinstall

MPlayer_targetinstall_deps = $(STATEDIR)/MPlayer.compile \
	$(STATEDIR)/esound.targetinstall \
	$(STATEDIR)/xfree430.targetinstall \
	$(STATEDIR)/libmad.targetinstall \
	$(STATEDIR)/tremor.targetinstall \
	$(STATEDIR)/ffmpeg.targetinstall \
	$(STATEDIR)/SDL.targetinstall

$(STATEDIR)/MPlayer.targetinstall: $(MPlayer_targetinstall_deps)
	@$(call targetinfo, $@)
	$(MPLAYER_PATH) $(MAKE) -C $(MPLAYER_DIR) DESTDIR=$(MPLAYER_IPKG_TMP) install STRIPBINARIES=no
	$(CROSSSTRIP) $(MPLAYER_IPKG_TMP)/usr/bin/*
	rm -rf $(MPLAYER_IPKG_TMP)/usr/man
ifdef PTXCONF_ARCH_ARM
	echo "framedrop = yes" 							 >$(MPLAYER_IPKG_TMP)/usr/share/mplayer/mplayer.conf
	echo "cache = 1024" 							>>$(MPLAYER_IPKG_TMP)/usr/share/mplayer/mplayer.conf
	echo "dr = yes" 							>>$(MPLAYER_IPKG_TMP)/usr/share/mplayer/mplayer.conf
	echo "af=resample=44100" 						>>$(MPLAYER_IPKG_TMP)/usr/share/mplayer/mplayer.conf
else
	echo "zoom = yes" 							 >$(MPLAYER_IPKG_TMP)/usr/share/mplayer/mplayer.conf
endif
	mkdir -p $(MPLAYER_IPKG_TMP)/CONTROL
	echo "Package: mplayer" 						 >$(MPLAYER_IPKG_TMP)/CONTROL/control
	echo "Priority: optional" 						>>$(MPLAYER_IPKG_TMP)/CONTROL/control
	echo "Section: Multimedia"			 			>>$(MPLAYER_IPKG_TMP)/CONTROL/control
	echo "Maintainer: Alexander Chukov <sash@pdaXrom.org>" 			>>$(MPLAYER_IPKG_TMP)/CONTROL/control
	echo "Architecture: $(SHORT_TARGET)" 					>>$(MPLAYER_IPKG_TMP)/CONTROL/control
	echo "Version: $(MPLAYER_VERSION)" 					>>$(MPLAYER_IPKG_TMP)/CONTROL/control
ifdef PTXCONF_ARCH_ARM
	echo "Depends: xfree430, libmad, tremor, aticore, sdl, esound, libffmpeg" 	>>$(MPLAYER_IPKG_TMP)/CONTROL/control
else
	echo "Depends: xfree430, libmad, tremor, sdl, esound, libffmpeg" 		>>$(MPLAYER_IPKG_TMP)/CONTROL/control
endif
	echo "Description: the Unix movie player."				>>$(MPLAYER_IPKG_TMP)/CONTROL/control
	cd $(FEEDDIR) && $(XMKIPKG) $(MPLAYER_IPKG_TMP)
	touch $@

# ----------------------------------------------------------------------------
# Image-Install
# ----------------------------------------------------------------------------

ifdef PTXCONF_MPLAYER_INSTALL
ROMPACKAGES += $(STATEDIR)/MPlayer.imageinstall
endif

MPlayer_imageinstall_deps = $(STATEDIR)/MPlayer.targetinstall \
	$(STATEDIR)/virtual-image.install

$(STATEDIR)/MPlayer.imageinstall: $(MPlayer_imageinstall_deps)
	@$(call targetinfo, $@)
	cd $(FEEDDIR) && $(XIPKG) install mplayer
	touch $@

# ----------------------------------------------------------------------------
# Clean
# ----------------------------------------------------------------------------

MPlayer_clean:
	rm -rf $(STATEDIR)/MPlayer.*
	rm -rf $(MPLAYER_DIR)

# vim: syntax=make
