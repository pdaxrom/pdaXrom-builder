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
ifdef PTXCONF_MB-APPLET-VOLUME
PACKAGES += mb-applet-volume
endif

#
# Paths and names
#
MB-APPLET-VOLUME_VERSION	= 0.1
MB-APPLET-VOLUME		= mb-applet-volume-$(MB-APPLET-VOLUME_VERSION)
MB-APPLET-VOLUME_SUFFIX		= tar.bz2
MB-APPLET-VOLUME_URL		= http://www.pdaXrom.org/src/$(MB-APPLET-VOLUME).$(MB-APPLET-VOLUME_SUFFIX)
MB-APPLET-VOLUME_SOURCE		= $(SRCDIR)/$(MB-APPLET-VOLUME).$(MB-APPLET-VOLUME_SUFFIX)
MB-APPLET-VOLUME_DIR		= $(BUILDDIR)/$(MB-APPLET-VOLUME)
MB-APPLET-VOLUME_IPKG_TMP	= $(MB-APPLET-VOLUME_DIR)/ipkg_tmp

# ----------------------------------------------------------------------------
# Get
# ----------------------------------------------------------------------------

mb-applet-volume_get: $(STATEDIR)/mb-applet-volume.get

mb-applet-volume_get_deps = $(MB-APPLET-VOLUME_SOURCE)

$(STATEDIR)/mb-applet-volume.get: $(mb-applet-volume_get_deps)
	@$(call targetinfo, $@)
	@$(call get_patches, $(MB-APPLET-VOLUME))
	touch $@

$(MB-APPLET-VOLUME_SOURCE):
	@$(call targetinfo, $@)
	@$(call get, $(MB-APPLET-VOLUME_URL))

# ----------------------------------------------------------------------------
# Extract
# ----------------------------------------------------------------------------

mb-applet-volume_extract: $(STATEDIR)/mb-applet-volume.extract

mb-applet-volume_extract_deps = $(STATEDIR)/mb-applet-volume.get

$(STATEDIR)/mb-applet-volume.extract: $(mb-applet-volume_extract_deps)
	@$(call targetinfo, $@)
	@$(call clean, $(MB-APPLET-VOLUME_DIR))
	@$(call extract, $(MB-APPLET-VOLUME_SOURCE))
	@$(call patchin, $(MB-APPLET-VOLUME))
	touch $@

# ----------------------------------------------------------------------------
# Prepare
# ----------------------------------------------------------------------------

mb-applet-volume_prepare: $(STATEDIR)/mb-applet-volume.prepare

#
# dependencies
#
mb-applet-volume_prepare_deps = \
	$(STATEDIR)/mb-applet-volume.extract \
	$(STATEDIR)/libmatchbox.install \
	$(STATEDIR)/gtk22.install \
	$(STATEDIR)/virtual-xchain.install

MB-APPLET-VOLUME_PATH	=  PATH=$(CROSS_PATH)
MB-APPLET-VOLUME_ENV 	=  $(CROSS_ENV)
#MB-APPLET-VOLUME_ENV	+=
MB-APPLET-VOLUME_ENV	+= PKG_CONFIG_PATH=$(CROSS_LIB_DIR)/lib/pkgconfig:$(CROSS_LIB_DIR)/lib/pkgconfig
#ifdef PTXCONF_XFREE430
#MB-APPLET-VOLUME_ENV	+= LDFLAGS=-Wl,-rpath-link,$(CROSS_LIB_DIR)/lib
#endif

#
# autoconf
#
MB-APPLET-VOLUME_AUTOCONF = \
	--build=$(GNU_HOST) \
	--host=$(PTXCONF_GNU_TARGET) \
	--prefix=/usr

ifdef PTXCONF_XFREE430
MB-APPLET-VOLUME_AUTOCONF += --x-includes=$(CROSS_LIB_DIR)/include
MB-APPLET-VOLUME_AUTOCONF += --x-libraries=$(CROSS_LIB_DIR)/lib
endif

$(STATEDIR)/mb-applet-volume.prepare: $(mb-applet-volume_prepare_deps)
	@$(call targetinfo, $@)
	@$(call clean, $(MB-APPLET-VOLUME_DIR)/config.cache)
	cd $(MB-APPLET-VOLUME_DIR) && \
		$(MB-APPLET-VOLUME_PATH) $(MB-APPLET-VOLUME_ENV) \
		./configure $(MB-APPLET-VOLUME_AUTOCONF)
	touch $@

# ----------------------------------------------------------------------------
# Compile
# ----------------------------------------------------------------------------

mb-applet-volume_compile: $(STATEDIR)/mb-applet-volume.compile

mb-applet-volume_compile_deps = $(STATEDIR)/mb-applet-volume.prepare

$(STATEDIR)/mb-applet-volume.compile: $(mb-applet-volume_compile_deps)
	@$(call targetinfo, $@)
	$(MB-APPLET-VOLUME_PATH) $(MAKE) -C $(MB-APPLET-VOLUME_DIR)
	touch $@

# ----------------------------------------------------------------------------
# Install
# ----------------------------------------------------------------------------

mb-applet-volume_install: $(STATEDIR)/mb-applet-volume.install

$(STATEDIR)/mb-applet-volume.install: $(STATEDIR)/mb-applet-volume.compile
	@$(call targetinfo, $@)
	touch $@

# ----------------------------------------------------------------------------
# Target-Install
# ----------------------------------------------------------------------------

mb-applet-volume_targetinstall: $(STATEDIR)/mb-applet-volume.targetinstall

mb-applet-volume_targetinstall_deps = $(STATEDIR)/mb-applet-volume.compile \
	$(STATEDIR)/gtk22.targetinstall \
	$(STATEDIR)/libmatchbox.targetinstall

$(STATEDIR)/mb-applet-volume.targetinstall: $(mb-applet-volume_targetinstall_deps)
	@$(call targetinfo, $@)
	$(MB-APPLET-VOLUME_PATH) $(MAKE) -C $(MB-APPLET-VOLUME_DIR) DESTDIR=$(MB-APPLET-VOLUME_IPKG_TMP) install
	$(CROSSSTRIP) $(MB-APPLET-VOLUME_IPKG_TMP)/usr/bin/*
	mkdir -p $(MB-APPLET-VOLUME_IPKG_TMP)/CONTROL
	echo "Package: mb-applet-volume" 				 >$(MB-APPLET-VOLUME_IPKG_TMP)/CONTROL/control
	echo "Priority: optional" 					>>$(MB-APPLET-VOLUME_IPKG_TMP)/CONTROL/control
	echo "Section: Matchbox" 					>>$(MB-APPLET-VOLUME_IPKG_TMP)/CONTROL/control
	echo "Maintainer: Alexander Chukov <sash@pdaXrom.org>" 		>>$(MB-APPLET-VOLUME_IPKG_TMP)/CONTROL/control
	echo "Architecture: $(SHORT_TARGET)" 				>>$(MB-APPLET-VOLUME_IPKG_TMP)/CONTROL/control
	echo "Version: $(MB-APPLET-VOLUME_VERSION)" 			>>$(MB-APPLET-VOLUME_IPKG_TMP)/CONTROL/control
	echo "Depends: libmatchbox" 					>>$(MB-APPLET-VOLUME_IPKG_TMP)/CONTROL/control
	echo "Description: matchbox volume applet"			>>$(MB-APPLET-VOLUME_IPKG_TMP)/CONTROL/control
	cd $(FEEDDIR) && $(XMKIPKG) $(MB-APPLET-VOLUME_IPKG_TMP)
	touch $@

# ----------------------------------------------------------------------------
# Image-Install
# ----------------------------------------------------------------------------

ifdef PTXCONF_MB-APPLET-VOLUME_INSTALL
ROMPACKAGES += $(STATEDIR)/mb-applet-volume.imageinstall
endif

mb-applet-volume_imageinstall_deps = $(STATEDIR)/mb-applet-volume.targetinstall \
	$(STATEDIR)/virtual-image.install

$(STATEDIR)/mb-applet-volume.imageinstall: $(mb-applet-volume_imageinstall_deps)
	@$(call targetinfo, $@)
	cd $(FEEDDIR) && $(XIPKG) install mb-applet-volume
	touch $@

# ----------------------------------------------------------------------------
# Clean
# ----------------------------------------------------------------------------

mb-applet-volume_clean:
	rm -rf $(STATEDIR)/mb-applet-volume.*
	rm -rf $(MB-APPLET-VOLUME_DIR)

# vim: syntax=make
