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
ifdef PTXCONF_HOT-BABE
PACKAGES += hot-babe
endif

#
# Paths and names
#
HOT-BABE_VENDOR_VERSION	= 1
HOT-BABE_VERSION	= 0.2.2
HOT-BABE		= hot-babe-$(HOT-BABE_VERSION)
HOT-BABE_SUFFIX		= tar.bz2
HOT-BABE_URL		= http://dindinx.net/hotbabe/downloads/$(HOT-BABE).$(HOT-BABE_SUFFIX)
HOT-BABE_SOURCE		= $(SRCDIR)/$(HOT-BABE).$(HOT-BABE_SUFFIX)
HOT-BABE_DIR		= $(BUILDDIR)/$(HOT-BABE)
HOT-BABE_IPKG_TMP	= $(HOT-BABE_DIR)/ipkg_tmp

# ----------------------------------------------------------------------------
# Get
# ----------------------------------------------------------------------------

hot-babe_get: $(STATEDIR)/hot-babe.get

hot-babe_get_deps = $(HOT-BABE_SOURCE)

$(STATEDIR)/hot-babe.get: $(hot-babe_get_deps)
	@$(call targetinfo, $@)
	@$(call get_patches, $(HOT-BABE))
	touch $@

$(HOT-BABE_SOURCE):
	@$(call targetinfo, $@)
	@$(call get, $(HOT-BABE_URL))

# ----------------------------------------------------------------------------
# Extract
# ----------------------------------------------------------------------------

hot-babe_extract: $(STATEDIR)/hot-babe.extract

hot-babe_extract_deps = $(STATEDIR)/hot-babe.get

$(STATEDIR)/hot-babe.extract: $(hot-babe_extract_deps)
	@$(call targetinfo, $@)
	@$(call clean, $(HOT-BABE_DIR))
	@$(call extract, $(HOT-BABE_SOURCE))
	@$(call patchin, $(HOT-BABE))
	touch $@

# ----------------------------------------------------------------------------
# Prepare
# ----------------------------------------------------------------------------

hot-babe_prepare: $(STATEDIR)/hot-babe.prepare

#
# dependencies
#
hot-babe_prepare_deps = \
	$(STATEDIR)/hot-babe.extract \
	$(STATEDIR)/gtk22.install \
	$(STATEDIR)/virtual-xchain.install

HOT-BABE_PATH	=  PATH=$(CROSS_PATH)
HOT-BABE_ENV 	=  $(CROSS_ENV)
#HOT-BABE_ENV	+=
HOT-BABE_ENV	+= PKG_CONFIG_PATH=$(CROSS_LIB_DIR)/lib/pkgconfig:$(CROSS_LIB_DIR)/lib/pkgconfig
#ifdef PTXCONF_XFREE430
#HOT-BABE_ENV	+= LDFLAGS=-Wl,-rpath-link,$(CROSS_LIB_DIR)/lib
#endif

#
# autoconf
#
HOT-BABE_AUTOCONF = \
	--build=$(GNU_HOST) \
	--host=$(PTXCONF_GNU_TARGET) \
	--prefix=/usr

ifdef PTXCONF_XFREE430
HOT-BABE_AUTOCONF += --x-includes=$(CROSS_LIB_DIR)/include
HOT-BABE_AUTOCONF += --x-libraries=$(CROSS_LIB_DIR)/lib
endif

$(STATEDIR)/hot-babe.prepare: $(hot-babe_prepare_deps)
	@$(call targetinfo, $@)
	@$(call clean, $(HOT-BABE_DIR)/config.cache)
	#cd $(HOT-BABE_DIR) && \
	#	$(HOT-BABE_PATH) $(HOT-BABE_ENV) \
	#	./configure $(HOT-BABE_AUTOCONF)
	touch $@

# ----------------------------------------------------------------------------
# Compile
# ----------------------------------------------------------------------------

hot-babe_compile: $(STATEDIR)/hot-babe.compile

hot-babe_compile_deps = $(STATEDIR)/hot-babe.prepare

$(STATEDIR)/hot-babe.compile: $(hot-babe_compile_deps)
	@$(call targetinfo, $@)
	$(HOT-BABE_PATH) $(HOT-BABE_ENV) $(MAKE) -C $(HOT-BABE_DIR) $(CROSS_ENV_CC) OPT_LIBS="" PREFIX=/usr
	touch $@

# ----------------------------------------------------------------------------
# Install
# ----------------------------------------------------------------------------

hot-babe_install: $(STATEDIR)/hot-babe.install

$(STATEDIR)/hot-babe.install: $(STATEDIR)/hot-babe.compile
	@$(call targetinfo, $@)
	touch $@

# ----------------------------------------------------------------------------
# Target-Install
# ----------------------------------------------------------------------------

hot-babe_targetinstall: $(STATEDIR)/hot-babe.targetinstall

hot-babe_targetinstall_deps = $(STATEDIR)/hot-babe.compile \
	$(STATEDIR)/gtk22.targetinstall

$(STATEDIR)/hot-babe.targetinstall: $(hot-babe_targetinstall_deps)
	@$(call targetinfo, $@)
	$(HOT-BABE_PATH) $(MAKE) -C $(HOT-BABE_DIR) DESTDIR=$(HOT-BABE_IPKG_TMP) install PREFIX=/usr
	$(CROSSSTRIP) $(HOT-BABE_IPKG_TMP)/usr/bin/*
	rm -rf $(HOT-BABE_IPKG_TMP)/usr/share/{doc,man}
	mkdir -p $(HOT-BABE_IPKG_TMP)/usr/share/applications
	rm -f $(HOT-BABE_IPKG_TMP)/usr/share/pixmaps/hot-babe.xpm
	cp -a $(TOPDIR)/config/pics/hot-babe.desktop $(HOT-BABE_IPKG_TMP)/usr/share/applications/
	cp -a $(TOPDIR)/config/pics/hot-babe.png     $(HOT-BABE_IPKG_TMP)/usr/share/pixmaps/
	mkdir -p $(HOT-BABE_IPKG_TMP)/CONTROL
	echo "Package: hot-babe" 								 >$(HOT-BABE_IPKG_TMP)/CONTROL/control
	echo "Priority: optional" 								>>$(HOT-BABE_IPKG_TMP)/CONTROL/control
	echo "Section: X11"	 								>>$(HOT-BABE_IPKG_TMP)/CONTROL/control
	echo "Maintainer: Alexander Chukov <sash@pdaXrom.org>" 					>>$(HOT-BABE_IPKG_TMP)/CONTROL/control
	echo "Architecture: $(SHORT_TARGET)" 							>>$(HOT-BABE_IPKG_TMP)/CONTROL/control
	echo "Version: $(HOT-BABE_VERSION)-$(HOT-BABE_VENDOR_VERSION)" 				>>$(HOT-BABE_IPKG_TMP)/CONTROL/control
	echo "Depends: gtk2" 									>>$(HOT-BABE_IPKG_TMP)/CONTROL/control
	echo "Description: Hot-babe is a small graphical utility which displays the system activity in a very special way." >>$(HOT-BABE_IPKG_TMP)/CONTROL/control
	cd $(FEEDDIR) && $(XMKIPKG) $(HOT-BABE_IPKG_TMP)
	touch $@

# ----------------------------------------------------------------------------
# Image-Install
# ----------------------------------------------------------------------------

ifdef PTXCONF_HOT-BABE_INSTALL
ROMPACKAGES += $(STATEDIR)/hot-babe.imageinstall
endif

hot-babe_imageinstall_deps = $(STATEDIR)/hot-babe.targetinstall \
	$(STATEDIR)/virtual-image.install

$(STATEDIR)/hot-babe.imageinstall: $(hot-babe_imageinstall_deps)
	@$(call targetinfo, $@)
	cd $(FEEDDIR) && $(XIPKG) install hot-babe
	touch $@

# ----------------------------------------------------------------------------
# Clean
# ----------------------------------------------------------------------------

hot-babe_clean:
	rm -rf $(STATEDIR)/hot-babe.*
	rm -rf $(HOT-BABE_DIR)

# vim: syntax=make
