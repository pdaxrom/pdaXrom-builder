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
ifdef PTXCONF_DLUME
PACKAGES += dlume
endif

#
# Paths and names
#
DLUME_VERSION		= 0.2.4
DLUME			= dlume-$(DLUME_VERSION)
DLUME_SUFFIX		= tar.gz
DLUME_URL		= http://clay.ll.pl/download/$(DLUME).$(DLUME_SUFFIX)
DLUME_SOURCE		= $(SRCDIR)/$(DLUME).$(DLUME_SUFFIX)
DLUME_DIR		= $(BUILDDIR)/$(DLUME)
DLUME_IPKG_TMP		= $(DLUME_DIR)/ipkg_tmp

# ----------------------------------------------------------------------------
# Get
# ----------------------------------------------------------------------------

dlume_get: $(STATEDIR)/dlume.get

dlume_get_deps = $(DLUME_SOURCE)

$(STATEDIR)/dlume.get: $(dlume_get_deps)
	@$(call targetinfo, $@)
	@$(call get_patches, $(DLUME))
	touch $@

$(DLUME_SOURCE):
	@$(call targetinfo, $@)
	@$(call get, $(DLUME_URL))

# ----------------------------------------------------------------------------
# Extract
# ----------------------------------------------------------------------------

dlume_extract: $(STATEDIR)/dlume.extract

dlume_extract_deps = $(STATEDIR)/dlume.get

$(STATEDIR)/dlume.extract: $(dlume_extract_deps)
	@$(call targetinfo, $@)
	@$(call clean, $(DLUME_DIR))
	@$(call extract, $(DLUME_SOURCE))
	@$(call patchin, $(DLUME))
	touch $@

# ----------------------------------------------------------------------------
# Prepare
# ----------------------------------------------------------------------------

dlume_prepare: $(STATEDIR)/dlume.prepare

#
# dependencies
#
dlume_prepare_deps = \
	$(STATEDIR)/dlume.extract \
	$(STATEDIR)/gtk22.install \
	$(STATEDIR)/libxml2.install \
	$(STATEDIR)/virtual-xchain.install

DLUME_PATH	=  PATH=$(CROSS_PATH)
DLUME_ENV 	=  $(CROSS_ENV)
#DLUME_ENV	+=
DLUME_ENV	+= PKG_CONFIG_PATH=$(CROSS_LIB_DIR)/lib/pkgconfig:$(CROSS_LIB_DIR)/lib/pkgconfig
#ifdef PTXCONF_XFREE430
#DLUME_ENV	+= LDFLAGS=-Wl,-rpath-link,$(CROSS_LIB_DIR)/lib
#endif

#
# autoconf
#
DLUME_AUTOCONF = \
	--build=$(GNU_HOST) \
	--host=$(PTXCONF_GNU_TARGET) \
	--prefix=/usr

ifdef PTXCONF_XFREE430
DLUME_AUTOCONF += --x-includes=$(CROSS_LIB_DIR)/include
DLUME_AUTOCONF += --x-libraries=$(CROSS_LIB_DIR)/lib
endif

$(STATEDIR)/dlume.prepare: $(dlume_prepare_deps)
	@$(call targetinfo, $@)
	@$(call clean, $(DLUME_DIR)/config.cache)
	cd $(DLUME_DIR) && \
		$(DLUME_PATH) $(DLUME_ENV) \
		./configure $(DLUME_AUTOCONF)
	touch $@

# ----------------------------------------------------------------------------
# Compile
# ----------------------------------------------------------------------------

dlume_compile: $(STATEDIR)/dlume.compile

dlume_compile_deps = $(STATEDIR)/dlume.prepare

$(STATEDIR)/dlume.compile: $(dlume_compile_deps)
	@$(call targetinfo, $@)
	$(DLUME_PATH) $(MAKE) -C $(DLUME_DIR)
	touch $@

# ----------------------------------------------------------------------------
# Install
# ----------------------------------------------------------------------------

dlume_install: $(STATEDIR)/dlume.install

$(STATEDIR)/dlume.install: $(STATEDIR)/dlume.compile
	@$(call targetinfo, $@)
	touch $@

# ----------------------------------------------------------------------------
# Target-Install
# ----------------------------------------------------------------------------

dlume_targetinstall: $(STATEDIR)/dlume.targetinstall

dlume_targetinstall_deps = $(STATEDIR)/dlume.compile \
	$(STATEDIR)/gtk22.targetinstall \
	$(STATEDIR)/libxml2.targetinstall

$(STATEDIR)/dlume.targetinstall: $(dlume_targetinstall_deps)
	@$(call targetinfo, $@)
	$(DLUME_PATH) $(MAKE) -C $(DLUME_DIR) DESTDIR=$(DLUME_IPKG_TMP) install
	$(CROSSSTRIP) $(DLUME_IPKG_TMP)/usr/bin/*
	rm -rf $(DLUME_IPKG_TMP)/usr/man
	mkdir -p $(DLUME_IPKG_TMP)/usr/share/applications
	cp -a $(TOPDIR)/config/pics/dlume.desktop $(DLUME_IPKG_TMP)/usr/share/applications
	mkdir -p $(DLUME_IPKG_TMP)/CONTROL
	echo "Package: dlume" 				>$(DLUME_IPKG_TMP)/CONTROL/control
	echo "Priority: optional" 			>>$(DLUME_IPKG_TMP)/CONTROL/control
	echo "Section: X11"	 			>>$(DLUME_IPKG_TMP)/CONTROL/control
	echo "Maintainer: Alexander Chukov <sash@pdaXrom.org>">>$(DLUME_IPKG_TMP)/CONTROL/control
	echo "Architecture: $(SHORT_TARGET)" 		>>$(DLUME_IPKG_TMP)/CONTROL/control
	echo "Version: $(DLUME_VERSION)" 		>>$(DLUME_IPKG_TMP)/CONTROL/control
	echo "Depends: gtk2, libxml2" 			>>$(DLUME_IPKG_TMP)/CONTROL/control
	echo "Description: Dlume is handy and easy to use addressbook.">>$(DLUME_IPKG_TMP)/CONTROL/control
	cd $(FEEDDIR) && $(XMKIPKG) $(DLUME_IPKG_TMP)
	touch $@

# ----------------------------------------------------------------------------
# Image-Install
# ----------------------------------------------------------------------------

ifdef PTXCONF_DLUME_INSTALL
ROMPACKAGES += $(STATEDIR)/dlume.imageinstall
endif

dlume_imageinstall_deps = $(STATEDIR)/dlume.targetinstall \
	$(STATEDIR)/virtual-image.install

$(STATEDIR)/dlume.imageinstall: $(dlume_imageinstall_deps)
	@$(call targetinfo, $@)
	cd $(FEEDDIR) && $(XIPKG) install dlume
	touch $@

# ----------------------------------------------------------------------------
# Clean
# ----------------------------------------------------------------------------

dlume_clean:
	rm -rf $(STATEDIR)/dlume.*
	rm -rf $(DLUME_DIR)

# vim: syntax=make
