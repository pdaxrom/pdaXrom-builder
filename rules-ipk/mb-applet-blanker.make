# -*-makefile-*-
# $Id: template,v 1.10 2004/01/24 15:50:34 mkl Exp $
#
# Copyright (C) 2004 by Matt Purvis <matt@beer.geek.nz>
#          
# See CREDITS for details about who has contributed to this project.
#
# For further information about the PTXdist project and license conditions
# see the README file.
#

#
# We provide this package
#
ifdef PTXCONF_MB-APPLET-BLANKER
PACKAGES += mb-applet-blanker
endif

#
# Paths and names
#
MB-APPLET-BLANKER_VERSION	= 0.6.1
MB-APPLET-BLANKER		= mb-applet-blanker_$(MB-APPLET-BLANKER_VERSION)
MB-APPLET-BLANKER_SUFFIX	= tar.bz2
MB-APPLET-BLANKER_URL		= http://www.pdaXrom.org/src/$(MB-APPLET-BLANKER).$(MB-APPLET-BLANKER_SUFFIX)
MB-APPLET-BLANKER_SOURCE	= $(SRCDIR)/$(MB-APPLET-BLANKER).$(MB-APPLET-BLANKER_SUFFIX)
MB-APPLET-BLANKER_DIR		= $(BUILDDIR)/$(MB-APPLET-BLANKER)
MB-APPLET-BLANKER_IPKG_TMP	= $(MB-APPLET-BLANKER_DIR)/ipkg_tmp

# ----------------------------------------------------------------------------
# Get
# ----------------------------------------------------------------------------

mb-applet-blanker_get: $(STATEDIR)/mb-applet-blanker.get

mb-applet-blanker_get_deps = $(MB-APPLET-BLANKER_SOURCE)

$(STATEDIR)/mb-applet-blanker.get: $(mb-applet-blanker_get_deps)
	@$(call targetinfo, $@)
	@$(call get_patches, $(MB-APPLET-BLANKER))
	touch $@

$(MB-APPLET-BLANKER_SOURCE):
	@$(call targetinfo, $@)
	@$(call get, $(MB-APPLET-BLANKER_URL))

# ----------------------------------------------------------------------------
# Extract
# ----------------------------------------------------------------------------

mb-applet-blanker_extract: $(STATEDIR)/mb-applet-blanker.extract

mb-applet-blanker_extract_deps = $(STATEDIR)/mb-applet-blanker.get

$(STATEDIR)/mb-applet-blanker.extract: $(mb-applet-blanker_extract_deps)
	@$(call targetinfo, $@)
	@$(call clean, $(MB-APPLET-BLANKER_DIR))
	@$(call extract, $(MB-APPLET-BLANKER_SOURCE))
	@$(call patchin, $(MB-APPLET-BLANKER))
	touch $@

# ----------------------------------------------------------------------------
# Prepare
# ----------------------------------------------------------------------------

mb-applet-blanker_prepare: $(STATEDIR)/mb-applet-blanker.prepare

#
# dependencies
#
mb-applet-blanker_prepare_deps = \
	$(STATEDIR)/mb-applet-blanker.extract \
	$(STATEDIR)/virtual-xchain.install

MB-APPLET-BLANKER_PATH	=  PATH=$(CROSS_PATH)
MB-APPLET-BLANKER_ENV 	=  $(CROSS_ENV)
#MB-APPLET-BLANKER_ENV	+=
MB-APPLET-BLANKER_ENV	+= PKG_CONFIG_PATH=$(CROSS_LIB_DIR)/lib/pkgconfig:$(CROSS_LIB_DIR)/lib/pkgconfig
#ifdef PTXCONF_XFREE430
#MB-APPLET-BLANKER_ENV	+= LDFLAGS=-Wl,-rpath-link,$(CROSS_LIB_DIR)/lib
#endif

#
# autoconf
#
MB-APPLET-BLANKER_AUTOCONF = \
	--build=$(GNU_HOST) \
	--host=$(PTXCONF_GNU_TARGET) \
	--prefix=/usr \
	--enable-startup-notification

ifdef PTXCONF_XFREE430
MB-APPLET-BLANKER_AUTOCONF += --x-includes=$(CROSS_LIB_DIR)/include
MB-APPLET-BLANKER_AUTOCONF += --x-libraries=$(CROSS_LIB_DIR)/lib
endif

$(STATEDIR)/mb-applet-blanker.prepare: $(mb-applet-blanker_prepare_deps)
	@$(call targetinfo, $@)
	@$(call clean, $(MB-APPLET-BLANKER_DIR)/config.cache)
	cd $(MB-APPLET-BLANKER_DIR) && \
		$(MB-APPLET-BLANKER_PATH) $(MB-APPLET-BLANKER_ENV) \
		./configure $(MB-APPLET-BLANKER_AUTOCONF)
	touch $@

# ----------------------------------------------------------------------------
# Compile
# ----------------------------------------------------------------------------

mb-applet-blanker_compile: $(STATEDIR)/mb-applet-blanker.compile

mb-applet-blanker_compile_deps = $(STATEDIR)/mb-applet-blanker.prepare

$(STATEDIR)/mb-applet-blanker.compile: $(mb-applet-blanker_compile_deps)
	@$(call targetinfo, $@)
	$(MB-APPLET-BLANKER_PATH) $(MAKE) -C $(MB-APPLET-BLANKER_DIR)
	touch $@

# ----------------------------------------------------------------------------
# Install
# ----------------------------------------------------------------------------

mb-applet-blanker_install: $(STATEDIR)/mb-applet-blanker.install

$(STATEDIR)/mb-applet-blanker.install: $(STATEDIR)/mb-applet-blanker.compile
	@$(call targetinfo, $@)
	$(MB-APPLET-BLANKER_PATH) $(MAKE) -C $(MB-APPLET-BLANKER_DIR) install
	touch $@

# ----------------------------------------------------------------------------
# Target-Install
# ----------------------------------------------------------------------------

mb-applet-blanker_targetinstall: $(STATEDIR)/mb-applet-blanker.targetinstall

mb-applet-blanker_targetinstall_deps = $(STATEDIR)/mb-applet-blanker.compile

$(STATEDIR)/mb-applet-blanker.targetinstall: $(mb-applet-blanker_targetinstall_deps)
	@$(call targetinfo, $@)
	$(MB-APPLET-BLANKER_PATH) $(MAKE) -C $(MB-APPLET-BLANKER_DIR) DESTDIR=$(MB-APPLET-BLANKER_IPKG_TMP) install
	$(CROSSSTRIP) $(MB-APPLET-BLANKER_IPKG_TMP)/usr/bin/*
	mkdir -p $(MB-APPLET-BLANKER_IPKG_TMP)/CONTROL
	echo "Package: mb-applet-blanker" 						>$(MB-APPLET-BLANKER_IPKG_TMP)/CONTROL/control
	echo "Priority: optional" 							>>$(MB-APPLET-BLANKER_IPKG_TMP)/CONTROL/control
	echo "Section: Matchbox" 							>>$(MB-APPLET-BLANKER_IPKG_TMP)/CONTROL/control
	echo "Maintainer: Matt Purvis <matt@beer.geek.nz>" 				>>$(MB-APPLET-BLANKER_IPKG_TMP)/CONTROL/control
	echo "Architecture: $(SHORT_TARGET)" 						>>$(MB-APPLET-BLANKER_IPKG_TMP)/CONTROL/control
	echo "Version: $(MB-APPLET-BLANKER_VERSION)" 					>>$(MB-APPLET-BLANKER_IPKG_TMP)/CONTROL/control
	echo "Depends: libmatchbox, gtk2" 						>>$(MB-APPLET-BLANKER_IPKG_TMP)/CONTROL/control
	echo "Description: a screen blanking applet"					>>$(MB-APPLET-BLANKER_IPKG_TMP)/CONTROL/control
	cd $(FEEDDIR) && $(XMKIPKG) $(MB-APPLET-BLANKER_IPKG_TMP)
	touch $@

# ----------------------------------------------------------------------------
# Image-Install
# ----------------------------------------------------------------------------

ifdef PTXCONF_MB-APPLET-BLANKER_INSTALL
ROMPACKAGES += $(STATEDIR)/mb-applet-blanker.imageinstall
endif

mb-applet-blanker_imageinstall_deps = $(STATEDIR)/mb-applet-blanker.targetinstall \
	$(STATEDIR)/virtual-image.install

$(STATEDIR)/mb-applet-blanker.imageinstall: $(mb-applet-blanker_imageinstall_deps)
	@$(call targetinfo, $@)
	cd $(FEEDDIR) && $(XIPKG) install mb-applet-blanker
	touch $@

# ----------------------------------------------------------------------------
# Clean
# ----------------------------------------------------------------------------

mb-applet-blanker_clean:
	rm -rf $(STATEDIR)/mb-applet-blanker.*
	rm -rf $(MB-APPLET-BLANKER_DIR)

# vim: syntax=make
