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
ifdef PTXCONF_MATCHBOX-PDAXROM
PACKAGES += matchbox-pdaXrom
endif

#
# Paths and names
#
MATCHBOX-PDAXROM_VENDOR_VERSION	= 7
MATCHBOX-PDAXROM_VERSION	= 1.0.9
MATCHBOX-PDAXROM		= matchbox-pdaXrom-$(MATCHBOX-PDAXROM_VERSION)
MATCHBOX-PDAXROM_SUFFIX		= tar.bz2
MATCHBOX-PDAXROM_URL		= http://www.pdaXrom.org/src/$(MATCHBOX-PDAXROM).$(MATCHBOX-PDAXROM_SUFFIX)
MATCHBOX-PDAXROM_SOURCE		= $(SRCDIR)/$(MATCHBOX-PDAXROM).$(MATCHBOX-PDAXROM_SUFFIX)
MATCHBOX-PDAXROM_DIR		= $(BUILDDIR)/$(MATCHBOX-PDAXROM)
MATCHBOX-PDAXROM_IPKG_TMP	= $(MATCHBOX-PDAXROM_DIR)

# ----------------------------------------------------------------------------
# Get
# ----------------------------------------------------------------------------

matchbox-pdaXrom_get: $(STATEDIR)/matchbox-pdaXrom.get

matchbox-pdaXrom_get_deps = $(MATCHBOX-PDAXROM_SOURCE)

$(STATEDIR)/matchbox-pdaXrom.get: $(matchbox-pdaXrom_get_deps)
	@$(call targetinfo, $@)
	@$(call get_patches, $(MATCHBOX-PDAXROM))
	touch $@

$(MATCHBOX-PDAXROM_SOURCE):
	@$(call targetinfo, $@)
	@$(call get, $(MATCHBOX-PDAXROM_URL))

# ----------------------------------------------------------------------------
# Extract
# ----------------------------------------------------------------------------

matchbox-pdaXrom_extract: $(STATEDIR)/matchbox-pdaXrom.extract

matchbox-pdaXrom_extract_deps = $(STATEDIR)/matchbox-pdaXrom.get

$(STATEDIR)/matchbox-pdaXrom.extract: $(matchbox-pdaXrom_extract_deps)
	@$(call targetinfo, $@)
	@$(call clean, $(MATCHBOX-PDAXROM_DIR))
	@$(call extract, $(MATCHBOX-PDAXROM_SOURCE))
	@$(call patchin, $(MATCHBOX-PDAXROM))
	touch $@

# ----------------------------------------------------------------------------
# Prepare
# ----------------------------------------------------------------------------

matchbox-pdaXrom_prepare: $(STATEDIR)/matchbox-pdaXrom.prepare

#
# dependencies
#
matchbox-pdaXrom_prepare_deps = \
	$(STATEDIR)/matchbox-pdaXrom.extract \
	$(STATEDIR)/virtual-xchain.install

MATCHBOX-PDAXROM_PATH	=  PATH=$(CROSS_PATH)
MATCHBOX-PDAXROM_ENV 	=  $(CROSS_ENV)
#MATCHBOX-PDAXROM_ENV	+=
MATCHBOX-PDAXROM_ENV	+= PKG_CONFIG_PATH=$(CROSS_LIB_DIR)/lib/pkgconfig:$(CROSS_LIB_DIR)/lib/pkgconfig
#ifdef PTXCONF_XFREE430
#MATCHBOX-PDAXROM_ENV	+= LDFLAGS=-Wl,-rpath-link,$(CROSS_LIB_DIR)/lib
#endif

#
# autoconf
#
MATCHBOX-PDAXROM_AUTOCONF = \
	--build=$(GNU_HOST) \
	--host=$(PTXCONF_GNU_TARGET) \
	--prefix=/usr

ifdef PTXCONF_XFREE430
MATCHBOX-PDAXROM_AUTOCONF += --x-includes=$(CROSS_LIB_DIR)/include
MATCHBOX-PDAXROM_AUTOCONF += --x-libraries=$(CROSS_LIB_DIR)/lib
endif

$(STATEDIR)/matchbox-pdaXrom.prepare: $(matchbox-pdaXrom_prepare_deps)
	@$(call targetinfo, $@)
	@$(call clean, $(MATCHBOX-PDAXROM_DIR)/config.cache)
	touch $@

# ----------------------------------------------------------------------------
# Compile
# ----------------------------------------------------------------------------

matchbox-pdaXrom_compile: $(STATEDIR)/matchbox-pdaXrom.compile

matchbox-pdaXrom_compile_deps = $(STATEDIR)/matchbox-pdaXrom.prepare

$(STATEDIR)/matchbox-pdaXrom.compile: $(matchbox-pdaXrom_compile_deps)
	@$(call targetinfo, $@)
	touch $@

# ----------------------------------------------------------------------------
# Install
# ----------------------------------------------------------------------------

matchbox-pdaXrom_install: $(STATEDIR)/matchbox-pdaXrom.install

$(STATEDIR)/matchbox-pdaXrom.install: $(STATEDIR)/matchbox-pdaXrom.compile
	@$(call targetinfo, $@)
	touch $@

# ----------------------------------------------------------------------------
# Target-Install
# ----------------------------------------------------------------------------

matchbox-pdaXrom_targetinstall: $(STATEDIR)/matchbox-pdaXrom.targetinstall

matchbox-pdaXrom_targetinstall_deps = $(STATEDIR)/matchbox-pdaXrom.compile

$(STATEDIR)/matchbox-pdaXrom.targetinstall: $(matchbox-pdaXrom_targetinstall_deps)
	@$(call targetinfo, $@)
	mkdir -p $(MATCHBOX-PDAXROM_IPKG_TMP)/etc/X11
	cp -af $(TOPDIR)/config/pdaXrom/kb $(MATCHBOX-PDAXROM_IPKG_TMP)/etc/X11
	#mkdir -p $(MATCHBOX-PDAXROM_IPKG_TMP)/CONTROL
	#echo "Package: matchbox-pdaxrom" 								 >$(MATCHBOX-PDAXROM_IPKG_TMP)/CONTROL/control
	#echo "Priority: optional"	 								>>$(MATCHBOX-PDAXROM_IPKG_TMP)/CONTROL/control
	#echo "Section: X11" 										>>$(MATCHBOX-PDAXROM_IPKG_TMP)/CONTROL/control
	#echo "Maintainer: Alexander Chukov <sash@pdaXrom.org>" 					>>$(MATCHBOX-PDAXROM_IPKG_TMP)/CONTROL/control
	#echo "Architecture: $(SHORT_TARGET)" 								>>$(MATCHBOX-PDAXROM_IPKG_TMP)/CONTROL/control
	#echo "Version: $(MATCHBOX-PDAXROM_VERSION)-$(MATCHBOX-PDAXROM_VENDOR_VERSION)" 		>>$(MATCHBOX-PDAXROM_IPKG_TMP)/CONTROL/control
	#echo "Depends: python-unixadmin" 								>>$(MATCHBOX-PDAXROM_IPKG_TMP)/CONTROL/control
	#echo "Description: pdaXrom matchbox config files"						>>$(MATCHBOX-PDAXROM_IPKG_TMP)/CONTROL/control
	cd $(FEEDDIR) && $(XMKIPKG) $(MATCHBOX-PDAXROM_IPKG_TMP)
	touch $@

# ----------------------------------------------------------------------------
# Image-Install
# ----------------------------------------------------------------------------

ifdef PTXCONF_MATCHBOX-PDAXROM_INSTALL
ROMPACKAGES += $(STATEDIR)/matchbox-pdaXrom.imageinstall
endif

matchbox-pdaXrom_imageinstall_deps = $(STATEDIR)/matchbox-pdaXrom.targetinstall \
	$(STATEDIR)/virtual-image.install

$(STATEDIR)/matchbox-pdaXrom.imageinstall: $(matchbox-pdaXrom_imageinstall_deps)
	@$(call targetinfo, $@)
	cd $(FEEDDIR) && $(XIPKG) install matchbox-pdaxrom
	touch $@

# ----------------------------------------------------------------------------
# Image-Vendor-Install
# ----------------------------------------------------------------------------

ifdef PTXCONF_MATCHBOX-PDAXROM_VENDOR-INSTALL
VENDORPACKAGES += $(STATEDIR)/matchbox-pdaXrom.vendorinstall
endif

matchbox-pdaXrom_vendorinstall_deps = $(STATEDIR)/matchbox-pdaXrom.targetinstall \
	$(STATEDIR)/virtual-image.install

$(STATEDIR)/matchbox-pdaXrom.vendorinstall: $(matchbox-pdaXrom_vendorinstall_deps)
	@$(call targetinfo, $@)
	cd $(FEEDDIR) && $(XIPKG) install matchbox-pdaxrom
	touch $@

# ----------------------------------------------------------------------------
# Clean
# ----------------------------------------------------------------------------

matchbox-pdaXrom_clean:
	rm -rf $(STATEDIR)/matchbox-pdaXrom.*
	rm -rf $(MATCHBOX-PDAXROM_DIR)

# vim: syntax=make
