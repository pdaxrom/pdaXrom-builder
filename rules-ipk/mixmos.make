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
ifdef PTXCONF_MIXMOS
PACKAGES += mixmos
endif

#
# Paths and names
#
MIXMOS_VENDOR_VERSION	= 1
MIXMOS_VERSION		= 0.2.0
MIXMOS			= mixmos-$(MIXMOS_VERSION)
MIXMOS_SUFFIX		= tar.gz
MIXMOS_URL		= http://clay.ll.pl/download/$(MIXMOS).$(MIXMOS_SUFFIX)
MIXMOS_SOURCE		= $(SRCDIR)/$(MIXMOS).$(MIXMOS_SUFFIX)
MIXMOS_DIR		= $(BUILDDIR)/$(MIXMOS)
MIXMOS_IPKG_TMP		= $(MIXMOS_DIR)/ipkg_tmp

# ----------------------------------------------------------------------------
# Get
# ----------------------------------------------------------------------------

mixmos_get: $(STATEDIR)/mixmos.get

mixmos_get_deps = $(MIXMOS_SOURCE)

$(STATEDIR)/mixmos.get: $(mixmos_get_deps)
	@$(call targetinfo, $@)
	@$(call get_patches, $(MIXMOS))
	touch $@

$(MIXMOS_SOURCE):
	@$(call targetinfo, $@)
	@$(call get, $(MIXMOS_URL))

# ----------------------------------------------------------------------------
# Extract
# ----------------------------------------------------------------------------

mixmos_extract: $(STATEDIR)/mixmos.extract

mixmos_extract_deps = $(STATEDIR)/mixmos.get

$(STATEDIR)/mixmos.extract: $(mixmos_extract_deps)
	@$(call targetinfo, $@)
	@$(call clean, $(MIXMOS_DIR))
	@$(call extract, $(MIXMOS_SOURCE))
	@$(call patchin, $(MIXMOS))
	touch $@

# ----------------------------------------------------------------------------
# Prepare
# ----------------------------------------------------------------------------

mixmos_prepare: $(STATEDIR)/mixmos.prepare

#
# dependencies
#
mixmos_prepare_deps = \
	$(STATEDIR)/mixmos.extract \
	$(STATEDIR)/gtk22.install \
	$(STATEDIR)/virtual-xchain.install

MIXMOS_PATH	=  PATH=$(CROSS_PATH)
MIXMOS_ENV 	=  $(CROSS_ENV)
#MIXMOS_ENV	+=
MIXMOS_ENV	+= PKG_CONFIG_PATH=$(CROSS_LIB_DIR)/lib/pkgconfig:$(CROSS_LIB_DIR)/lib/pkgconfig
#ifdef PTXCONF_XFREE430
#MIXMOS_ENV	+= LDFLAGS=-Wl,-rpath-link,$(CROSS_LIB_DIR)/lib
#endif

#
# autoconf
#
MIXMOS_AUTOCONF = \
	--build=$(GNU_HOST) \
	--host=$(PTXCONF_GNU_TARGET) \
	--prefix=/usr

ifdef PTXCONF_XFREE430
MIXMOS_AUTOCONF += --x-includes=$(CROSS_LIB_DIR)/include
MIXMOS_AUTOCONF += --x-libraries=$(CROSS_LIB_DIR)/lib
endif

$(STATEDIR)/mixmos.prepare: $(mixmos_prepare_deps)
	@$(call targetinfo, $@)
	@$(call clean, $(MIXMOS_DIR)/config.cache)
	cd $(MIXMOS_DIR) && \
		$(MIXMOS_PATH) $(MIXMOS_ENV) \
		./configure $(MIXMOS_AUTOCONF)
	touch $@

# ----------------------------------------------------------------------------
# Compile
# ----------------------------------------------------------------------------

mixmos_compile: $(STATEDIR)/mixmos.compile

mixmos_compile_deps = $(STATEDIR)/mixmos.prepare

$(STATEDIR)/mixmos.compile: $(mixmos_compile_deps)
	@$(call targetinfo, $@)
	$(MIXMOS_PATH) $(MAKE) -C $(MIXMOS_DIR)
	touch $@

# ----------------------------------------------------------------------------
# Install
# ----------------------------------------------------------------------------

mixmos_install: $(STATEDIR)/mixmos.install

$(STATEDIR)/mixmos.install: $(STATEDIR)/mixmos.compile
	@$(call targetinfo, $@)
	$(MIXMOS_PATH) $(MAKE) -C $(MIXMOS_DIR) install
	touch $@

# ----------------------------------------------------------------------------
# Target-Install
# ----------------------------------------------------------------------------

mixmos_targetinstall: $(STATEDIR)/mixmos.targetinstall

mixmos_targetinstall_deps = $(STATEDIR)/mixmos.compile \
	$(STATEDIR)/gtk22.targetinstall

$(STATEDIR)/mixmos.targetinstall: $(mixmos_targetinstall_deps)
	@$(call targetinfo, $@)
	$(MIXMOS_PATH) $(MAKE) -C $(MIXMOS_DIR) DESTDIR=$(MIXMOS_IPKG_TMP) install
	mkdir -p $(MIXMOS_IPKG_TMP)/usr/share/applications
	cp -a $(TOPDIR)/config/pics/mixmos.desktop $(MIXMOS_IPKG_TMP)/usr/share/applications/
	$(CROSSSTRIP) $(MIXMOS_IPKG_TMP)/usr/bin/*
	rm -rf $(MIXMOS_IPKG_TMP)/usr/man
	mkdir -p $(MIXMOS_IPKG_TMP)/CONTROL
	echo "Package: mixmos" 										 >$(MIXMOS_IPKG_TMP)/CONTROL/control
	echo "Priority: optional" 									>>$(MIXMOS_IPKG_TMP)/CONTROL/control
	echo "Section: Multimedia" 									>>$(MIXMOS_IPKG_TMP)/CONTROL/control
	echo "Maintainer: Alexander Chukov <sash@pdaXrom.org>" 						>>$(MIXMOS_IPKG_TMP)/CONTROL/control
	echo "Architecture: $(SHORT_TARGET)" 								>>$(MIXMOS_IPKG_TMP)/CONTROL/control
	echo "Version: $(MIXMOS_VERSION)-$(MIXMOS_VENDOR_VERSION)" 					>>$(MIXMOS_IPKG_TMP)/CONTROL/control
	echo "Depends: gtk2" 										>>$(MIXMOS_IPKG_TMP)/CONTROL/control
	echo "Description: It's attempt to create a nice and useful soundcard volume control program."	>>$(MIXMOS_IPKG_TMP)/CONTROL/control
	cd $(FEEDDIR) && $(XMKIPKG) $(MIXMOS_IPKG_TMP)
	touch $@

# ----------------------------------------------------------------------------
# Image-Install
# ----------------------------------------------------------------------------

ifdef PTXCONF_MIXMOS_INSTALL
ROMPACKAGES += $(STATEDIR)/mixmos.imageinstall
endif

mixmos_imageinstall_deps = $(STATEDIR)/mixmos.targetinstall \
	$(STATEDIR)/virtual-image.install

$(STATEDIR)/mixmos.imageinstall: $(mixmos_imageinstall_deps)
	@$(call targetinfo, $@)
	cd $(FEEDDIR) && $(XIPKG) install mixmos
	touch $@

# ----------------------------------------------------------------------------
# Clean
# ----------------------------------------------------------------------------

mixmos_clean:
	rm -rf $(STATEDIR)/mixmos.*
	rm -rf $(MIXMOS_DIR)

# vim: syntax=make
