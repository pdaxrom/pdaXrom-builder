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
ifdef PTXCONF_MTOOLS
PACKAGES += mtools
endif

#
# Paths and names
#
MTOOLS_VENDOR_VERSION	= 1
MTOOLS_VERSION		= 3.9.9
MTOOLS			= mtools-$(MTOOLS_VERSION)
MTOOLS_SUFFIX		= tar.bz2
MTOOLS_URL		= http://mtools.linux.lu/$(MTOOLS).$(MTOOLS_SUFFIX)
MTOOLS_SOURCE		= $(SRCDIR)/$(MTOOLS).$(MTOOLS_SUFFIX)
MTOOLS_DIR		= $(BUILDDIR)/$(MTOOLS)
MTOOLS_IPKG_TMP		= $(MTOOLS_DIR)/ipkg_tmp

# ----------------------------------------------------------------------------
# Get
# ----------------------------------------------------------------------------

mtools_get: $(STATEDIR)/mtools.get

mtools_get_deps = $(MTOOLS_SOURCE)

$(STATEDIR)/mtools.get: $(mtools_get_deps)
	@$(call targetinfo, $@)
	@$(call get_patches, $(MTOOLS))
	touch $@

$(MTOOLS_SOURCE):
	@$(call targetinfo, $@)
	@$(call get, $(MTOOLS_URL))

# ----------------------------------------------------------------------------
# Extract
# ----------------------------------------------------------------------------

mtools_extract: $(STATEDIR)/mtools.extract

mtools_extract_deps = $(STATEDIR)/mtools.get

$(STATEDIR)/mtools.extract: $(mtools_extract_deps)
	@$(call targetinfo, $@)
	@$(call clean, $(MTOOLS_DIR))
	@$(call extract, $(MTOOLS_SOURCE))
	@$(call patchin, $(MTOOLS))
	touch $@

# ----------------------------------------------------------------------------
# Prepare
# ----------------------------------------------------------------------------

mtools_prepare: $(STATEDIR)/mtools.prepare

#
# dependencies
#
mtools_prepare_deps = \
	$(STATEDIR)/mtools.extract \
	$(STATEDIR)/virtual-xchain.install

MTOOLS_PATH	=  PATH=$(CROSS_PATH)
MTOOLS_ENV 	=  $(CROSS_ENV)
#MTOOLS_ENV	+=
MTOOLS_ENV	+= PKG_CONFIG_PATH=$(CROSS_LIB_DIR)/lib/pkgconfig:$(CROSS_LIB_DIR)/lib/pkgconfig
#ifdef PTXCONF_XFREE430
#MTOOLS_ENV	+= LDFLAGS=-Wl,-rpath-link,$(CROSS_LIB_DIR)/lib
#endif

#
# autoconf
#
MTOOLS_AUTOCONF = \
	--build=$(GNU_HOST) \
	--host=$(PTXCONF_GNU_TARGET) \
	--prefix=/usr \
	--sysconfdir=/etc

ifdef PTXCONF_XFREE430
MTOOLS_AUTOCONF += --x-includes=$(CROSS_LIB_DIR)/include
MTOOLS_AUTOCONF += --x-libraries=$(CROSS_LIB_DIR)/lib
endif

$(STATEDIR)/mtools.prepare: $(mtools_prepare_deps)
	@$(call targetinfo, $@)
	@$(call clean, $(MTOOLS_DIR)/config.cache)
	cd $(MTOOLS_DIR) && \
		$(MTOOLS_PATH) $(MTOOLS_ENV) \
		./configure $(MTOOLS_AUTOCONF)
	touch $@

# ----------------------------------------------------------------------------
# Compile
# ----------------------------------------------------------------------------

mtools_compile: $(STATEDIR)/mtools.compile

mtools_compile_deps = $(STATEDIR)/mtools.prepare

$(STATEDIR)/mtools.compile: $(mtools_compile_deps)
	@$(call targetinfo, $@)
	$(MTOOLS_PATH) $(MAKE) -C $(MTOOLS_DIR)
	touch $@

# ----------------------------------------------------------------------------
# Install
# ----------------------------------------------------------------------------

mtools_install: $(STATEDIR)/mtools.install

$(STATEDIR)/mtools.install: $(STATEDIR)/mtools.compile
	@$(call targetinfo, $@)
	touch $@

# ----------------------------------------------------------------------------
# Target-Install
# ----------------------------------------------------------------------------

mtools_targetinstall: $(STATEDIR)/mtools.targetinstall

mtools_targetinstall_deps = $(STATEDIR)/mtools.compile

$(STATEDIR)/mtools.targetinstall: $(mtools_targetinstall_deps)
	@$(call targetinfo, $@)
	$(MTOOLS_PATH) $(MAKE) -C $(MTOOLS_DIR) prefix=$(MTOOLS_IPKG_TMP)/usr install MAKEINFO=true
	rm -rf $(MTOOLS_IPKG_TMP)/usr/info
	rm -rf $(MTOOLS_IPKG_TMP)/usr/man
	$(CROSSSTRIP) $(MTOOLS_IPKG_TMP)/usr/bin/floppyd*
	$(CROSSSTRIP) $(MTOOLS_IPKG_TMP)/usr/bin/mtools
	$(CROSSSTRIP) $(MTOOLS_IPKG_TMP)/usr/bin/mkmanifest
	mkdir -p $(MTOOLS_IPKG_TMP)/CONTROL
	echo "Package: mtools" 											 >$(MTOOLS_IPKG_TMP)/CONTROL/control
	echo "Priority: optional" 										>>$(MTOOLS_IPKG_TMP)/CONTROL/control
	echo "Section: Utilities" 										>>$(MTOOLS_IPKG_TMP)/CONTROL/control
	echo "Maintainer: Alexander Chukov <sash@pdaXrom.org>" 							>>$(MTOOLS_IPKG_TMP)/CONTROL/control
	echo "Architecture: $(SHORT_TARGET)" 									>>$(MTOOLS_IPKG_TMP)/CONTROL/control
	echo "Version: $(MTOOLS_VERSION)-$(MTOOLS_VENDOR_VERSION)" 						>>$(MTOOLS_IPKG_TMP)/CONTROL/control
	echo "Depends: " 											>>$(MTOOLS_IPKG_TMP)/CONTROL/control
	echo "Description: Mtools is a collection of utilities to access MS-DOS disks from Unix without mounting them. It supports Win'95 style long file names, OS/2 Xdf disks and 2m disks (store up to 1992k on a high density 3 1/2 disk)."	>>$(MTOOLS_IPKG_TMP)/CONTROL/control
	cd $(FEEDDIR) && $(XMKIPKG) $(MTOOLS_IPKG_TMP)
	touch $@

# ----------------------------------------------------------------------------
# Image-Install
# ----------------------------------------------------------------------------

ifdef PTXCONF_MTOOLS_INSTALL
ROMPACKAGES += $(STATEDIR)/mtools.imageinstall
endif

mtools_imageinstall_deps = $(STATEDIR)/mtools.targetinstall \
	$(STATEDIR)/virtual-image.install

$(STATEDIR)/mtools.imageinstall: $(mtools_imageinstall_deps)
	@$(call targetinfo, $@)
	cd $(FEEDDIR) && $(XIPKG) install mtools
	touch $@

# ----------------------------------------------------------------------------
# Clean
# ----------------------------------------------------------------------------

mtools_clean:
	rm -rf $(STATEDIR)/mtools.*
	rm -rf $(MTOOLS_DIR)

# vim: syntax=make
