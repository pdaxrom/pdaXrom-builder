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
ifdef PTXCONF_BMP
PACKAGES += bmp
endif

#
# Paths and names
#
BMP_VERSION	= 0.9.6.1
BMP		= bmp-$(BMP_VERSION)
BMP_SUFFIX	= tar.gz
BMP_URL		= http://heanet.dl.sourceforge.net/sourceforge/beepmp/$(BMP).$(BMP_SUFFIX)
BMP_SOURCE	= $(SRCDIR)/$(BMP).$(BMP_SUFFIX)
BMP_DIR		= $(BUILDDIR)/$(BMP)
BMP_IPKG_TMP	= $(BMP_DIR)/ipkg_tmp

# ----------------------------------------------------------------------------
# Get
# ----------------------------------------------------------------------------

bmp_get: $(STATEDIR)/bmp.get

bmp_get_deps = $(BMP_SOURCE)

$(STATEDIR)/bmp.get: $(bmp_get_deps)
	@$(call targetinfo, $@)
	@$(call get_patches, $(BMP))
	touch $@

$(BMP_SOURCE):
	@$(call targetinfo, $@)
	@$(call get, $(BMP_URL))

# ----------------------------------------------------------------------------
# Extract
# ----------------------------------------------------------------------------

bmp_extract: $(STATEDIR)/bmp.extract

bmp_extract_deps = $(STATEDIR)/bmp.get

$(STATEDIR)/bmp.extract: $(bmp_extract_deps)
	@$(call targetinfo, $@)
	@$(call clean, $(BMP_DIR))
	@$(call extract, $(BMP_SOURCE))
	@$(call patchin, $(BMP))
	touch $@

# ----------------------------------------------------------------------------
# Prepare
# ----------------------------------------------------------------------------

bmp_prepare: $(STATEDIR)/bmp.prepare

#
# dependencies
#
bmp_prepare_deps = \
	$(STATEDIR)/bmp.extract \
	$(STATEDIR)/libid3tag.install \
	$(STATEDIR)/gtk22.install \
	$(STATEDIR)/esound.install \
	$(STATEDIR)/virtual-xchain.install

ifdef PTXCONF_ALSA-UTILS
bmp_prepare_deps += $(STATEDIR)/alsa-lib.install
endif

BMP_PATH	=  PATH=$(CROSS_PATH)
BMP_ENV 	=  $(CROSS_ENV)
#BMP_ENV	+=
BMP_ENV	+= PKG_CONFIG_PATH=$(CROSS_LIB_DIR)/lib/pkgconfig:$(CROSS_LIB_DIR)/X11R6/lib/pkgconfig
ifdef PTXCONF_XFREE430
BMP_ENV	+= LDFLAGS=-Wl,-rpath-link,$(CROSS_LIB_DIR)/X11R6/lib
endif

#
# autoconf
#
BMP_AUTOCONF = \
	--build=$(GNU_HOST) \
	--host=$(PTXCONF_GNU_TARGET) \
	--prefix=/usr \
	--disable-opengl \
	--disable-static \
	--enable-shared

ifndef PTXCONF_ALSA-UTILS
BMP_AUTOCONF += --disable-alsa
endif

ifdef PTXCONF_XFREE430
BMP_AUTOCONF += --x-includes=$(CROSS_LIB_DIR)/X11R6/include
BMP_AUTOCONF += --x-libraries=$(CROSS_LIB_DIR)/X11R6/lib
endif

$(STATEDIR)/bmp.prepare: $(bmp_prepare_deps)
	@$(call targetinfo, $@)
	@$(call clean, $(BMP_DIR)/config.cache)
	cd $(BMP_DIR) && \
		$(BMP_PATH) $(BMP_ENV) \
		./configure $(BMP_AUTOCONF)
	cp -f $(PTXCONF_PREFIX)/bin/libtool $(BMP_DIR)
	cp -f $(PTXCONF_PREFIX)/bin/libtool $(BMP_DIR)/libbeep
	touch $@

# ----------------------------------------------------------------------------
# Compile
# ----------------------------------------------------------------------------

bmp_compile: $(STATEDIR)/bmp.compile

bmp_compile_deps = $(STATEDIR)/bmp.prepare

$(STATEDIR)/bmp.compile: $(bmp_compile_deps)
	@$(call targetinfo, $@)
	$(BMP_PATH) $(MAKE) -C $(BMP_DIR)
	touch $@

# ----------------------------------------------------------------------------
# Install
# ----------------------------------------------------------------------------

bmp_install: $(STATEDIR)/bmp.install

$(STATEDIR)/bmp.install: $(STATEDIR)/bmp.compile
	@$(call targetinfo, $@)
	###$(BMP_PATH) $(MAKE) -C $(BMP_DIR) install
	touch $@

# ----------------------------------------------------------------------------
# Target-Install
# ----------------------------------------------------------------------------

bmp_targetinstall: $(STATEDIR)/bmp.targetinstall

bmp_targetinstall_deps = $(STATEDIR)/bmp.compile \
	$(STATEDIR)/gtk22.targetinstall \
	$(STATEDIR)/esound.targetinstall \
	$(STATEDIR)/libid3tag.targetinstall

$(STATEDIR)/bmp.targetinstall: $(bmp_targetinstall_deps)
	@$(call targetinfo, $@)
	$(BMP_PATH) $(MAKE) -C $(BMP_DIR) DESTDIR=$(BMP_IPKG_TMP) install
	rm -rf $(BMP_IPKG_TMP)/usr/include
	rm -rf $(BMP_IPKG_TMP)/usr/lib/pkgconfig
	rm -rf $(BMP_IPKG_TMP)/usr/man
	rm -rf $(BMP_IPKG_TMP)/usr/share/aclocal
	rm -rf $(BMP_IPKG_TMP)/usr/share/locale
	rm -f $(BMP_IPKG_TMP)/usr/bin/beep-config
	$(CROSSSTRIP) $(BMP_IPKG_TMP)/usr/bin/beep-media-player
	rm -f $(BMP_IPKG_TMP)/usr/lib/libbeep.a
	rm -f $(BMP_IPKG_TMP)/usr/lib/libbeep.la
	$(CROSSSTRIP) $(BMP_IPKG_TMP)/usr/lib/libbeep.so.1.0.0
	rm -f $(BMP_IPKG_TMP)/usr/lib/bmp/Input/*.a
	rm -f $(BMP_IPKG_TMP)/usr/lib/bmp/Input/*.la
	$(CROSSSTRIP) $(BMP_IPKG_TMP)/usr/lib/bmp/Input/*.so
	rm -f $(BMP_IPKG_TMP)/usr/lib/bmp/Output/*.a
	rm -f $(BMP_IPKG_TMP)/usr/lib/bmp/Output/*.la
	$(CROSSSTRIP) $(BMP_IPKG_TMP)/usr/lib/bmp/Output/*.so
	rm -f $(BMP_IPKG_TMP)/usr/lib/bmp/Visualization/*.a
	rm -f $(BMP_IPKG_TMP)/usr/lib/bmp/Visualization/*.la
	$(CROSSSTRIP) $(BMP_IPKG_TMP)/usr/lib/bmp/Visualization/*.so
	perl -p -i -e "s/beep\.svg/beep_mini\.xpm/g" $(BMP_IPKG_TMP)/usr/share/applications/beep.desktop
	mkdir -p $(BMP_IPKG_TMP)/usr/share/pixmaps
	cp -a $(TOPDIR)/config/pics/beep_mini.xpm $(BMP_IPKG_TMP)/usr/share/pixmaps
	mkdir -p $(BMP_IPKG_TMP)/CONTROL
	echo "Package: beep" 						>$(BMP_IPKG_TMP)/CONTROL/control
	echo "Priority: optional" 					>>$(BMP_IPKG_TMP)/CONTROL/control
	echo "Section: Multimedia" 					>>$(BMP_IPKG_TMP)/CONTROL/control
	echo "Maintainer: Alexander Chukov <sash@pdaXrom.org>"		>>$(BMP_IPKG_TMP)/CONTROL/control
	echo "Architecture: $(SHORT_TARGET)" 				>>$(BMP_IPKG_TMP)/CONTROL/control
	echo "Version: $(BMP_VERSION)" 					>>$(BMP_IPKG_TMP)/CONTROL/control
	echo "Depends: gtk2"	 					>>$(BMP_IPKG_TMP)/CONTROL/control
	echo "Description: A Cross platform Multimedia Player"		>>$(BMP_IPKG_TMP)/CONTROL/control
	cd $(FEEDDIR) && $(XMKIPKG) $(BMP_IPKG_TMP)
	touch $@

# ----------------------------------------------------------------------------
# Image-Install
# ----------------------------------------------------------------------------

ifdef PTXCONF_BMP_INSTALL
ROMPACKAGES += $(STATEDIR)/bmp.imageinstall
endif

bmp_imageinstall_deps = $(STATEDIR)/bmp.targetinstall \
	$(STATEDIR)/virtual-image.install

$(STATEDIR)/bmp.imageinstall: $(bmp_imageinstall_deps)
	@$(call targetinfo, $@)
	cd $(FEEDDIR) && $(XIPKG) install beep
	touch $@

# ----------------------------------------------------------------------------
# Clean
# ----------------------------------------------------------------------------

bmp_clean:
	rm -rf $(STATEDIR)/bmp.*
	rm -rf $(BMP_DIR)

# vim: syntax=make
