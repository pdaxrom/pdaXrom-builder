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
ifdef PTXCONF_LAME
PACKAGES += lame
endif

#
# Paths and names
#
LAME_VERSION		= 3.96.1
LAME			= lame-$(LAME_VERSION)
LAME_SUFFIX		= tar.gz
LAME_URL		= http://heanet.dl.sourceforge.net/sourceforge/lame/$(LAME).$(LAME_SUFFIX)
LAME_SOURCE		= $(SRCDIR)/$(LAME).$(LAME_SUFFIX)
LAME_DIR		= $(BUILDDIR)/$(LAME)
LAME_IPKG_TMP		= $(LAME_DIR)/ipkg_tmp

# ----------------------------------------------------------------------------
# Get
# ----------------------------------------------------------------------------

lame_get: $(STATEDIR)/lame.get

lame_get_deps = $(LAME_SOURCE)

$(STATEDIR)/lame.get: $(lame_get_deps)
	@$(call targetinfo, $@)
	@$(call get_patches, $(LAME))
	touch $@

$(LAME_SOURCE):
	@$(call targetinfo, $@)
	@$(call get, $(LAME_URL))

# ----------------------------------------------------------------------------
# Extract
# ----------------------------------------------------------------------------

lame_extract: $(STATEDIR)/lame.extract

lame_extract_deps = $(STATEDIR)/lame.get

$(STATEDIR)/lame.extract: $(lame_extract_deps)
	@$(call targetinfo, $@)
	@$(call clean, $(LAME_DIR))
	@$(call extract, $(LAME_SOURCE))
	@$(call patchin, $(LAME))
	touch $@

# ----------------------------------------------------------------------------
# Prepare
# ----------------------------------------------------------------------------

lame_prepare: $(STATEDIR)/lame.prepare

#
# dependencies
#
lame_prepare_deps = \
	$(STATEDIR)/lame.extract \
	$(STATEDIR)/ncurses.install \
	$(STATEDIR)/gtk1210.install \
	$(STATEDIR)/virtual-xchain.install

LAME_PATH	=  PATH=$(CROSS_PATH)
LAME_ENV 	=  $(CROSS_ENV)
LAME_ENV	+= CFLAGS="$(TARGET_OPT_CFLAGS)"
LAME_ENV	+= PKG_CONFIG_PATH=$(CROSS_LIB_DIR)/lib/pkgconfig:$(CROSS_LIB_DIR)/lib/pkgconfig
#ifdef PTXCONF_XFREE430
#LAME_ENV	+= LDFLAGS=-Wl,-rpath-link,$(CROSS_LIB_DIR)/lib
#endif

#
# autoconf
#
LAME_AUTOCONF = \
	--build=$(GNU_HOST) \
	--host=$(PTXCONF_GNU_TARGET) \
	--prefix=/usr \
	--disable-static \
	--enable-shared \
	--enable-mp3x

ifdef PTXCONF_XFREE430
LAME_AUTOCONF += --x-includes=$(CROSS_LIB_DIR)/include
LAME_AUTOCONF += --x-libraries=$(CROSS_LIB_DIR)/lib
endif

$(STATEDIR)/lame.prepare: $(lame_prepare_deps)
	@$(call targetinfo, $@)
	@$(call clean, $(LAME_DIR)/config.cache)
	cd $(LAME_DIR) && \
		$(LAME_PATH) $(LAME_ENV) \
		./configure $(LAME_AUTOCONF)
	touch $@

# ----------------------------------------------------------------------------
# Compile
# ----------------------------------------------------------------------------

lame_compile: $(STATEDIR)/lame.compile

lame_compile_deps = $(STATEDIR)/lame.prepare

$(STATEDIR)/lame.compile: $(lame_compile_deps)
	@$(call targetinfo, $@)
	$(LAME_PATH) $(MAKE) -C $(LAME_DIR)
	touch $@

# ----------------------------------------------------------------------------
# Install
# ----------------------------------------------------------------------------

lame_install: $(STATEDIR)/lame.install

$(STATEDIR)/lame.install: $(STATEDIR)/lame.compile
	@$(call targetinfo, $@)
	$(LAME_PATH) $(MAKE) -C $(LAME_DIR) DESTDIR=$(LAME_IPKG_TMP) install
	asdasd
	rm -rf $(LAME_IPKG_TMP)
	touch $@

# ----------------------------------------------------------------------------
# Target-Install
# ----------------------------------------------------------------------------

lame_targetinstall: $(STATEDIR)/lame.targetinstall

lame_targetinstall_deps = $(STATEDIR)/lame.compile \
	$(STATEDIR)/ncurses.targetinstall \
	$(STATEDIR)/gtk1210.targetinstall

$(STATEDIR)/lame.targetinstall: $(lame_targetinstall_deps)
	@$(call targetinfo, $@)
	$(LAME_PATH) $(MAKE) -C $(LAME_DIR) DESTDIR=$(LAME_IPKG_TMP) install
	rm -rf $(LAME_IPKG_TMP)/usr/include
	rm -rf $(LAME_IPKG_TMP)/usr/lib/*.*a
	rm -rf $(LAME_IPKG_TMP)/usr/man
	rm -rf $(LAME_IPKG_TMP)/usr/share
	$(CROSSSTRIP) $(LAME_IPKG_TMP)/usr/bin/*
	$(CROSSSTRIP) $(LAME_IPKG_TMP)/usr/lib/*
	
	mkdir -p $(LAME_IPKG_TMP)-gtk/usr/bin
	mv $(LAME_IPKG_TMP)/usr/bin/mp3x $(LAME_IPKG_TMP)-gtk/usr/bin/
	mkdir -p $(LAME_IPKG_TMP)/CONTROL
	echo "Package: lame" 							>$(LAME_IPKG_TMP)/CONTROL/control
	echo "Priority: optional" 						>>$(LAME_IPKG_TMP)/CONTROL/control
	echo "Section: Multimedia"			 			>>$(LAME_IPKG_TMP)/CONTROL/control
	echo "Maintainer: Alexander Chukov <sash@pdaXrom.org>" 			>>$(LAME_IPKG_TMP)/CONTROL/control
	echo "Architecture: $(SHORT_TARGET)" 					>>$(LAME_IPKG_TMP)/CONTROL/control
	echo "Version: $(LAME_VERSION)" 					>>$(LAME_IPKG_TMP)/CONTROL/control
	echo "Depends: ncurses" 						>>$(LAME_IPKG_TMP)/CONTROL/control
	echo "Description: LAME Ain't an MP3 Encoder"				>>$(LAME_IPKG_TMP)/CONTROL/control
	cd $(FEEDDIR) && $(XMKIPKG) $(LAME_IPKG_TMP)
	
	mkdir -p $(LAME_IPKG_TMP)-gtk/CONTROL
	echo "Package: mp3x" 							>$(LAME_IPKG_TMP)-gtk/CONTROL/control
	echo "Priority: optional" 						>>$(LAME_IPKG_TMP)-gtk/CONTROL/control
	echo "Section: Multimedia"			 			>>$(LAME_IPKG_TMP)-gtk/CONTROL/control
	echo "Maintainer: Alexander Chukov <sash@pdaXrom.org>" 			>>$(LAME_IPKG_TMP)-gtk/CONTROL/control
	echo "Architecture: $(SHORT_TARGET)" 					>>$(LAME_IPKG_TMP)-gtk/CONTROL/control
	echo "Version: $(LAME_VERSION)" 					>>$(LAME_IPKG_TMP)-gtk/CONTROL/control
	echo "Depends: lame, gtk" 						>>$(LAME_IPKG_TMP)-gtk/CONTROL/control
	echo "Description: LAME GTK frontend"					>>$(LAME_IPKG_TMP)-gtk/CONTROL/control
	cd $(FEEDDIR) && $(XMKIPKG) $(LAME_IPKG_TMP)-gtk
	touch $@

# ----------------------------------------------------------------------------
# Image-Install
# ----------------------------------------------------------------------------

ifdef PTXCONF_LAME_INSTALL
ROMPACKAGES += $(STATEDIR)/lame.imageinstall
endif

lame_imageinstall_deps = $(STATEDIR)/lame.targetinstall \
	$(STATEDIR)/virtual-image.install

$(STATEDIR)/lame.imageinstall: $(lame_imageinstall_deps)
	@$(call targetinfo, $@)
	cd $(FEEDDIR) && $(XIPKG) install lame
ifdef PTXCONF_LAME_FRONT_INSTALL
	cd $(FEEDDIR) && $(XIPKG) install mp3x
endif
	touch $@

# ----------------------------------------------------------------------------
# Clean
# ----------------------------------------------------------------------------

lame_clean:
	rm -rf $(STATEDIR)/lame.*
	rm -rf $(LAME_DIR)

# vim: syntax=make
