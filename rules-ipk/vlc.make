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
ifdef PTXCONF_VLC
PACKAGES += vlc
endif

#
# Paths and names
#
VLC_VENDOR_VERSION	= 1
VLC_VERSION		= 0.8.1
VLC			= vlc-$(VLC_VERSION)
VLC_SUFFIX		= tar.bz2
VLC_URL			= http://download.videolan.org/pub/vlc/0.8.1/$(VLC).$(VLC_SUFFIX)
VLC_SOURCE		= $(SRCDIR)/$(VLC).$(VLC_SUFFIX)
VLC_DIR			= $(BUILDDIR)/$(VLC)
VLC_IPKG_TMP		= $(VLC_DIR)/ipkg_tmp

# ----------------------------------------------------------------------------
# Get
# ----------------------------------------------------------------------------

vlc_get: $(STATEDIR)/vlc.get

vlc_get_deps = $(VLC_SOURCE)

$(STATEDIR)/vlc.get: $(vlc_get_deps)
	@$(call targetinfo, $@)
	@$(call get_patches, $(VLC))
	touch $@

$(VLC_SOURCE):
	@$(call targetinfo, $@)
	@$(call get, $(VLC_URL))

# ----------------------------------------------------------------------------
# Extract
# ----------------------------------------------------------------------------

vlc_extract: $(STATEDIR)/vlc.extract

vlc_extract_deps = $(STATEDIR)/vlc.get

$(STATEDIR)/vlc.extract: $(vlc_extract_deps)
	@$(call targetinfo, $@)
	@$(call clean, $(VLC_DIR))
	@$(call extract, $(VLC_SOURCE))
	@$(call patchin, $(VLC))
	touch $@

# ----------------------------------------------------------------------------
# Prepare
# ----------------------------------------------------------------------------

vlc_prepare: $(STATEDIR)/vlc.prepare

#
# dependencies
#
vlc_prepare_deps = \
	$(STATEDIR)/vlc.extract \
	$(STATEDIR)/zlib.install \
	$(STATEDIR)/fribidi.install \
	$(STATEDIR)/freetype.install \
	$(STATEDIR)/ffmpeg.install \
	$(STATEDIR)/xfree430.install \
	$(STATEDIR)/SDL.install \
	$(STATEDIR)/libdvbpsi3.install \
	$(STATEDIR)/wxWidgets.install \
	$(STATEDIR)/virtual-xchain.install

ifdef PTXCONF_ALSA-UTILS
vlc_prepare_deps += $(STATEDIR)/alsa-lib.install
endif

vlc_prepare_deps += $(STATEDIR)/mpeg2dec.install

VLC_PATH	=  PATH=$(CROSS_PATH)
VLC_ENV 	=  $(CROSS_ENV)
VLC_ENV		+= CFLAGS="$(TARGET_OPT_CFLAGS)"
VLC_ENV		+= PKG_CONFIG_PATH=$(CROSS_LIB_DIR)/lib/pkgconfig:$(CROSS_LIB_DIR)/lib/pkgconfig
#ifdef PTXCONF_XFREE430
#VLC_ENV		+= LDFLAGS=-Wl,-rpath-link,$(CROSS_LIB_DIR)/lib
#endif

#
# autoconf
#
VLC_AUTOCONF = \
	--build=$(GNU_HOST) \
	--host=$(PTXCONF_GNU_TARGET) \
	--prefix=/usr \
	--enable-release \
	--disable-ogg \
	--disable-vorbis \
	--enable-tremor \
	--disable-vorbis \
	--enable-wxwindow \
	--disable-mozilla \
	--with-mad=$(CROSS_LIB_DIR) \
	--disable-skins2 \
	--enable-optimizations

ifdef PTXCONF_LIBICONV
VLC_AUTOCONF +=	--with-libiconv-prefix=$(CROSS_LIB_DIR)
endif

ifndef PTXCONF_ALSA-UTILS
VLC_AUTOCONF += --disable-alsa
endif

###VLC_AUTOCONF +=	--disable-libmpeg2

ifdef PTXCONF_XFREE430
VLC_AUTOCONF += --x-includes=$(CROSS_LIB_DIR)/include
VLC_AUTOCONF += --x-libraries=$(CROSS_LIB_DIR)/lib
endif

$(STATEDIR)/vlc.prepare: $(vlc_prepare_deps)
	@$(call targetinfo, $@)
	@$(call clean, $(VLC_DIR)/config.cache)
	cd $(VLC_DIR) && \
		$(VLC_PATH) $(VLC_ENV) \
		./configure $(VLC_AUTOCONF)
	touch $@

# ----------------------------------------------------------------------------
# Compile
# ----------------------------------------------------------------------------

vlc_compile: $(STATEDIR)/vlc.compile

vlc_compile_deps = $(STATEDIR)/vlc.prepare

$(STATEDIR)/vlc.compile: $(vlc_compile_deps)
	@$(call targetinfo, $@)
	$(VLC_PATH) $(MAKE) -C $(VLC_DIR)
	touch $@

# ----------------------------------------------------------------------------
# Install
# ----------------------------------------------------------------------------

vlc_install: $(STATEDIR)/vlc.install

$(STATEDIR)/vlc.install: $(STATEDIR)/vlc.compile
	@$(call targetinfo, $@)
	asdasd
	touch $@

# ----------------------------------------------------------------------------
# Target-Install
# ----------------------------------------------------------------------------

vlc_targetinstall: $(STATEDIR)/vlc.targetinstall

vlc_targetinstall_deps = $(STATEDIR)/vlc.compile \
	$(STATEDIR)/zlib.targetinstall \
	$(STATEDIR)/fribidi.targetinstall \
	$(STATEDIR)/freetype.targetinstall \
	$(STATEDIR)/xfree430.targetinstall \
	$(STATEDIR)/SDL.targetinstall \
	$(STATEDIR)/libdvbpsi3.targetinstall \
	$(STATEDIR)/wxWidgets.targetinstall \
	$(STATEDIR)/ffmpeg.targetinstall

vlc_targetinstall_deps += $(STATEDIR)/mpeg2dec.targetinstall

$(STATEDIR)/vlc.targetinstall: $(vlc_targetinstall_deps)
	@$(call targetinfo, $@)
	$(VLC_PATH) $(MAKE) -C $(VLC_DIR) DESTDIR=$(VLC_IPKG_TMP) install
	rm  -f $(VLC_IPKG_TMP)/usr/bin/vlc-config
	rm -rf $(VLC_IPKG_TMP)/usr/include
	rm -rf $(VLC_IPKG_TMP)/usr/share/doc
	rm -rf $(VLC_IPKG_TMP)/usr/share/locale
	rm  -f $(VLC_IPKG_TMP)/usr/lib/*.a
	rm  -f $(VLC_IPKG_TMP)/usr/lib/vlc/*.a
	for FILE in `find $(VLC_IPKG_TMP)/usr/ -type f`; do		\
	    ZZZ=`file $$FILE | grep 'ELF 32-bit'`;			\
	    if [  "$$ZZZ" != "" ]; then					\
		$(CROSSSTRIP) $$FILE;					\
	    fi;								\
	done
	$(INSTALL) -m 644 -D $(TOPDIR)/config/pics/vlc.desktop $(VLC_IPKG_TMP)/usr/share/applications/vlc.desktop
	mkdir -p $(VLC_IPKG_TMP)/CONTROL
	echo "Package: vlc" 									>$(VLC_IPKG_TMP)/CONTROL/control
	echo "Priority: optional" 								>>$(VLC_IPKG_TMP)/CONTROL/control
	echo "Section: Multimedia" 								>>$(VLC_IPKG_TMP)/CONTROL/control
	echo "Maintainer: Alexander Chukov <sash@pdaXrom.org>" 					>>$(VLC_IPKG_TMP)/CONTROL/control
	echo "Architecture: $(SHORT_TARGET)" 							>>$(VLC_IPKG_TMP)/CONTROL/control
	echo "Version: $(VLC_VERSION)-$(VLC_VENDOR_VERSION)" 					>>$(VLC_IPKG_TMP)/CONTROL/control
	echo "Depends: wxwidgets, libz, libffmpeg, xfree430, sdl, freetype, fribidi, libdvbpsi3, libmpeg2" 	>>$(VLC_IPKG_TMP)/CONTROL/control
	echo "Description: videolan client"							>>$(VLC_IPKG_TMP)/CONTROL/control
	cd $(FEEDDIR) && $(XMKIPKG) $(VLC_IPKG_TMP)
	touch $@

# ----------------------------------------------------------------------------
# Image-Install
# ----------------------------------------------------------------------------

ifdef PTXCONF_VLC_INSTALL
ROMPACKAGES += $(STATEDIR)/vlc.imageinstall
endif

vlc_imageinstall_deps = $(STATEDIR)/vlc.targetinstall \
	$(STATEDIR)/virtual-image.install

$(STATEDIR)/vlc.imageinstall: $(vlc_imageinstall_deps)
	@$(call targetinfo, $@)
	cd $(FEEDDIR) && $(XIPKG) install vlc
	touch $@

# ----------------------------------------------------------------------------
# Clean
# ----------------------------------------------------------------------------

vlc_clean:
	rm -rf $(STATEDIR)/vlc.*
	rm -rf $(VLC_DIR)

# vim: syntax=make
