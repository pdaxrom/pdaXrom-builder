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
ifdef PTXCONF_XMMSMPLAYER
PACKAGES += xmmsmplayer
endif

#
# Paths and names
#
XMMSMPLAYER_VERSION	= 0.5
XMMSMPLAYER		= xmmsmplayer-$(XMMSMPLAYER_VERSION)
XMMSMPLAYER_SUFFIX	= tar.bz2
XMMSMPLAYER_URL		= http://heanet.dl.sourceforge.net/sourceforge/xmmsmplayer/$(XMMSMPLAYER).$(XMMSMPLAYER_SUFFIX)
XMMSMPLAYER_SOURCE	= $(SRCDIR)/$(XMMSMPLAYER).$(XMMSMPLAYER_SUFFIX)
XMMSMPLAYER_DIR		= $(BUILDDIR)/$(XMMSMPLAYER)
XMMSMPLAYER_IPKG_TMP	= $(XMMSMPLAYER_DIR)/ipkg_tmp

# ----------------------------------------------------------------------------
# Get
# ----------------------------------------------------------------------------

xmmsmplayer_get: $(STATEDIR)/xmmsmplayer.get

xmmsmplayer_get_deps = $(XMMSMPLAYER_SOURCE)

$(STATEDIR)/xmmsmplayer.get: $(xmmsmplayer_get_deps)
	@$(call targetinfo, $@)
	@$(call get_patches, $(XMMSMPLAYER))
	touch $@

$(XMMSMPLAYER_SOURCE):
	@$(call targetinfo, $@)
	@$(call get, $(XMMSMPLAYER_URL))

# ----------------------------------------------------------------------------
# Extract
# ----------------------------------------------------------------------------

xmmsmplayer_extract: $(STATEDIR)/xmmsmplayer.extract

xmmsmplayer_extract_deps = $(STATEDIR)/xmmsmplayer.get

$(STATEDIR)/xmmsmplayer.extract: $(xmmsmplayer_extract_deps)
	@$(call targetinfo, $@)
	@$(call clean, $(XMMSMPLAYER_DIR))
	@$(call extract, $(XMMSMPLAYER_SOURCE))
	@$(call patchin, $(XMMSMPLAYER))
	touch $@

# ----------------------------------------------------------------------------
# Prepare
# ----------------------------------------------------------------------------

xmmsmplayer_prepare: $(STATEDIR)/xmmsmplayer.prepare

#
# dependencies
#
xmmsmplayer_prepare_deps = \
	$(STATEDIR)/xmmsmplayer.extract \
	$(STATEDIR)/xmms.install \
	$(STATEDIR)/virtual-xchain.install

XMMSMPLAYER_PATH	=  PATH=$(CROSS_PATH)
XMMSMPLAYER_ENV 	=  $(CROSS_ENV)
XMMSMPLAYER_ENV		+= CFLAGS="-O2 -fomit-frame-pointer"
XMMSMPLAYER_ENV		+= PKG_CONFIG_PATH=$(CROSS_LIB_DIR)/lib/pkgconfig:$(CROSS_LIB_DIR)/lib/pkgconfig
#ifdef PTXCONF_XFREE430
#XMMSMPLAYER_ENV		+= LDFLAGS=-Wl,-rpath-link,$(CROSS_LIB_DIR)/lib
#endif

#
# autoconf
#
XMMSMPLAYER_AUTOCONF = \
	--build=$(GNU_HOST) \
	--host=$(PTXCONF_GNU_TARGET) \
	--prefix=/usr \
	--disable-debug
#	--with-xmms-prefix=/usr

ifdef PTXCONF_XFREE430
XMMSMPLAYER_AUTOCONF += --x-includes=$(CROSS_LIB_DIR)/include
XMMSMPLAYER_AUTOCONF += --x-libraries=$(CROSS_LIB_DIR)/lib
endif

$(STATEDIR)/xmmsmplayer.prepare: $(xmmsmplayer_prepare_deps)
	@$(call targetinfo, $@)
	@$(call clean, $(XMMSMPLAYER_DIR)/config.cache)
	cd $(XMMSMPLAYER_DIR) && \
		$(XMMSMPLAYER_PATH) $(XMMSMPLAYER_ENV) \
		XMMS_CONFIG="$(PTXCONF_PREFIX)/bin/xmms-config" \
		./configure $(XMMSMPLAYER_AUTOCONF)
	touch $@

# ----------------------------------------------------------------------------
# Compile
# ----------------------------------------------------------------------------

xmmsmplayer_compile: $(STATEDIR)/xmmsmplayer.compile

xmmsmplayer_compile_deps = $(STATEDIR)/xmmsmplayer.prepare

$(STATEDIR)/xmmsmplayer.compile: $(xmmsmplayer_compile_deps)
	@$(call targetinfo, $@)
	$(XMMSMPLAYER_PATH) $(MAKE) -C $(XMMSMPLAYER_DIR)
	touch $@

# ----------------------------------------------------------------------------
# Install
# ----------------------------------------------------------------------------

xmmsmplayer_install: $(STATEDIR)/xmmsmplayer.install

$(STATEDIR)/xmmsmplayer.install: $(STATEDIR)/xmmsmplayer.compile
	@$(call targetinfo, $@)
	###$(XMMSMPLAYER_PATH) $(MAKE) -C $(XMMSMPLAYER_DIR) install
	touch $@

# ----------------------------------------------------------------------------
# Target-Install
# ----------------------------------------------------------------------------

xmmsmplayer_targetinstall: $(STATEDIR)/xmmsmplayer.targetinstall

xmmsmplayer_targetinstall_deps = $(STATEDIR)/xmmsmplayer.compile \
	$(STATEDIR)/xmms.targetinstall \
	$(STATEDIR)/MPlayer.targetinstall

$(STATEDIR)/xmmsmplayer.targetinstall: $(xmmsmplayer_targetinstall_deps)
	@$(call targetinfo, $@)
	$(XMMSMPLAYER_PATH) $(MAKE) -C $(XMMSMPLAYER_DIR) DESTDIR=$(XMMSMPLAYER_IPKG_TMP) install libdir=/usr/lib/xmms/Input
	rm -rf $(XMMSMPLAYER_IPKG_TMP)/usr/lib/xmms/Input/*.*a
	$(CROSSSTRIP) $(XMMSMPLAYER_IPKG_TMP)/usr/lib/xmms/Input/*
	mkdir -p $(XMMSMPLAYER_IPKG_TMP)/CONTROL
	echo "Package: xmmsmplayer" 						 >$(XMMSMPLAYER_IPKG_TMP)/CONTROL/control
	echo "Priority: optional" 						>>$(XMMSMPLAYER_IPKG_TMP)/CONTROL/control
	echo "Section: Multimedia" 						>>$(XMMSMPLAYER_IPKG_TMP)/CONTROL/control
	echo "Maintainer: Alexander Chukov <sash@pdaXrom.org>" 			>>$(XMMSMPLAYER_IPKG_TMP)/CONTROL/control
	echo "Architecture: $(SHORT_TARGET)" 					>>$(XMMSMPLAYER_IPKG_TMP)/CONTROL/control
	echo "Version: $(XMMSMPLAYER_VERSION)" 					>>$(XMMSMPLAYER_IPKG_TMP)/CONTROL/control
	echo "Depends: xmms, mplayer" 						>>$(XMMSMPLAYER_IPKG_TMP)/CONTROL/control
	echo "Description: This an xmms plugin that allows you to use xmms as a front-end for MPlayer.">>$(XMMSMPLAYER_IPKG_TMP)/CONTROL/control
	cd $(FEEDDIR) && $(XMKIPKG) $(XMMSMPLAYER_IPKG_TMP)
	touch $@

# ----------------------------------------------------------------------------
# Image-Install
# ----------------------------------------------------------------------------

ifdef PTXCONF_XMMSMPLAYER_INSTALL
ROMPACKAGES += $(STATEDIR)/xmmsmplayer.imageinstall
endif

xmmsmplayer_imageinstall_deps = $(STATEDIR)/xmmsmplayer.targetinstall \
	$(STATEDIR)/virtual-image.install

$(STATEDIR)/xmmsmplayer.imageinstall: $(xmmsmplayer_imageinstall_deps)
	@$(call targetinfo, $@)
	cd $(FEEDDIR) && $(XIPKG) install xmmsmplayer
	touch $@

# ----------------------------------------------------------------------------
# Clean
# ----------------------------------------------------------------------------

xmmsmplayer_clean:
	rm -rf $(STATEDIR)/xmmsmplayer.*
	rm -rf $(XMMSMPLAYER_DIR)

# vim: syntax=make
