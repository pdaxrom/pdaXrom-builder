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
ifdef PTXCONF_PCIUTILS
PACKAGES += pciutils
endif

#
# Paths and names
#
PCIUTILS_VENDOR_VERSION	= 1
PCIUTILS_VERSION	= 2.1.11
PCIUTILS		= pciutils-$(PCIUTILS_VERSION)
PCIUTILS_SUFFIX		= tar.gz
PCIUTILS_URL		= ftp://atrey.karlin.mff.cuni.cz/pub/linux/pci/$(PCIUTILS).$(PCIUTILS_SUFFIX)
PCIUTILS_SOURCE		= $(SRCDIR)/$(PCIUTILS).$(PCIUTILS_SUFFIX)
PCIUTILS_DIR		= $(BUILDDIR)/$(PCIUTILS)
PCIUTILS_IPKG_TMP	= $(PCIUTILS_DIR)/ipkg_tmp

# ----------------------------------------------------------------------------
# Get
# ----------------------------------------------------------------------------

pciutils_get: $(STATEDIR)/pciutils.get

pciutils_get_deps = $(PCIUTILS_SOURCE)

$(STATEDIR)/pciutils.get: $(pciutils_get_deps)
	@$(call targetinfo, $@)
	@$(call get_patches, $(PCIUTILS))
	touch $@

$(PCIUTILS_SOURCE):
	@$(call targetinfo, $@)
	@$(call get, $(PCIUTILS_URL))

# ----------------------------------------------------------------------------
# Extract
# ----------------------------------------------------------------------------

pciutils_extract: $(STATEDIR)/pciutils.extract

pciutils_extract_deps = $(STATEDIR)/pciutils.get

$(STATEDIR)/pciutils.extract: $(pciutils_extract_deps)
	@$(call targetinfo, $@)
	@$(call clean, $(PCIUTILS_DIR))
	@$(call extract, $(PCIUTILS_SOURCE))
	@$(call patchin, $(PCIUTILS))
	touch $@

# ----------------------------------------------------------------------------
# Prepare
# ----------------------------------------------------------------------------

pciutils_prepare: $(STATEDIR)/pciutils.prepare

#
# dependencies
#
pciutils_prepare_deps = \
	$(STATEDIR)/pciutils.extract \
	$(STATEDIR)/virtual-xchain.install

PCIUTILS_PATH	=  PATH=$(CROSS_PATH)
PCIUTILS_ENV 	=  $(CROSS_ENV)
#PCIUTILS_ENV	+=
PCIUTILS_ENV	+= PKG_CONFIG_PATH=$(CROSS_LIB_DIR)/lib/pkgconfig:$(CROSS_LIB_DIR)/lib/pkgconfig
#ifdef PTXCONF_XFREE430
#PCIUTILS_ENV	+= LDFLAGS=-Wl,-rpath-link,$(CROSS_LIB_DIR)/lib
#endif

#
# autoconf
#
PCIUTILS_AUTOCONF = \
	--build=$(GNU_HOST) \
	--host=$(PTXCONF_GNU_TARGET) \
	--prefix=/usr

ifdef PTXCONF_XFREE430
PCIUTILS_AUTOCONF += --x-includes=$(CROSS_LIB_DIR)/include
PCIUTILS_AUTOCONF += --x-libraries=$(CROSS_LIB_DIR)/lib
endif

$(STATEDIR)/pciutils.prepare: $(pciutils_prepare_deps)
	@$(call targetinfo, $@)
	@$(call clean, $(PCIUTILS_DIR)/config.cache)
	#cd $(PCIUTILS_DIR) && \
	#	$(PCIUTILS_PATH) $(PCIUTILS_ENV) \
	#	./configure $(PCIUTILS_AUTOCONF)
	touch $@

# ----------------------------------------------------------------------------
# Compile
# ----------------------------------------------------------------------------

pciutils_compile: $(STATEDIR)/pciutils.compile

pciutils_compile_deps = $(STATEDIR)/pciutils.prepare

$(STATEDIR)/pciutils.compile: $(pciutils_compile_deps)
	@$(call targetinfo, $@)
	$(PCIUTILS_PATH) $(PCIUTILS_ENV) $(MAKE) -C $(PCIUTILS_DIR)
	touch $@

# ----------------------------------------------------------------------------
# Install
# ----------------------------------------------------------------------------

pciutils_install: $(STATEDIR)/pciutils.install

$(STATEDIR)/pciutils.install: $(STATEDIR)/pciutils.compile
	@$(call targetinfo, $@)
	##$(PCIUTILS_PATH) $(MAKE) -C $(PCIUTILS_DIR) install
	asdasd
	touch $@

# ----------------------------------------------------------------------------
# Target-Install
# ----------------------------------------------------------------------------

pciutils_targetinstall: $(STATEDIR)/pciutils.targetinstall

pciutils_targetinstall_deps = $(STATEDIR)/pciutils.compile

$(STATEDIR)/pciutils.targetinstall: $(pciutils_targetinstall_deps)
	@$(call targetinfo, $@)
	$(PCIUTILS_PATH) $(MAKE) -C $(PCIUTILS_DIR) PREFIX=$(PCIUTILS_IPKG_TMP)/usr install
	rm -rf $(PCIUTILS_IPKG_TMP)/usr/man
	rm -rf $(PCIUTILS_IPKG_TMP)/usr/share/hwdata/*.ids
	$(CROSSSTRIP) $(PCIUTILS_IPKG_TMP)/usr/sbin/{lspci,pcimodules,setpci}
	mkdir -p $(PCIUTILS_IPKG_TMP)/CONTROL
	echo "Package: pciutils" 							 >$(PCIUTILS_IPKG_TMP)/CONTROL/control
	echo "Priority: optional" 							>>$(PCIUTILS_IPKG_TMP)/CONTROL/control
	echo "Section: Utilities" 							>>$(PCIUTILS_IPKG_TMP)/CONTROL/control
	echo "Maintainer: Alexander Chukov <sash@pdaXrom.org>" 				>>$(PCIUTILS_IPKG_TMP)/CONTROL/control
	echo "Architecture: $(SHORT_TARGET)" 						>>$(PCIUTILS_IPKG_TMP)/CONTROL/control
	echo "Version: $(PCIUTILS_VERSION)-$(PCIUTILS_VENDOR_VERSION)" 			>>$(PCIUTILS_IPKG_TMP)/CONTROL/control
	echo "Depends: " 								>>$(PCIUTILS_IPKG_TMP)/CONTROL/control
	echo "Description: The PCI Utilities package contains a library for portable access to PCI bus configuration space and several utilities based on this library." >>$(PCIUTILS_IPKG_TMP)/CONTROL/control
	cd $(FEEDDIR) && $(XMKIPKG) $(PCIUTILS_IPKG_TMP)
	touch $@

# ----------------------------------------------------------------------------
# Image-Install
# ----------------------------------------------------------------------------

ifdef PTXCONF_PCIUTILS_INSTALL
ROMPACKAGES += $(STATEDIR)/pciutils.imageinstall
endif

pciutils_imageinstall_deps = $(STATEDIR)/pciutils.targetinstall \
	$(STATEDIR)/virtual-image.install

$(STATEDIR)/pciutils.imageinstall: $(pciutils_imageinstall_deps)
	@$(call targetinfo, $@)
	cd $(FEEDDIR) && $(XIPKG) install pciutils
	touch $@

# ----------------------------------------------------------------------------
# Clean
# ----------------------------------------------------------------------------

pciutils_clean:
	rm -rf $(STATEDIR)/pciutils.*
	rm -rf $(PCIUTILS_DIR)

# vim: syntax=make
