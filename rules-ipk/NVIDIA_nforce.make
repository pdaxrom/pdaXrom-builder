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
ifdef PTXCONF_NVIDIA_NFORCE
PACKAGES += NVIDIA_nforce
endif

#
# Paths and names
#
NVIDIA_NFORCE_VENDOR_VERSION	= 1
NVIDIA_NFORCE_VERSION		= 1.0-0274
NVIDIA_NFORCE			= NVIDIA_nforce-$(NVIDIA_NFORCE_VERSION)
NVIDIA_NFORCE_SUFFIX		= tar.gz
NVIDIA_NFORCE_URL		= http://www.pdaXrom.org/src/$(NVIDIA_NFORCE).$(NVIDIA_NFORCE_SUFFIX)
NVIDIA_NFORCE_SOURCE		= $(SRCDIR)/$(NVIDIA_NFORCE).$(NVIDIA_NFORCE_SUFFIX)
NVIDIA_NFORCE_DIR		= $(BUILDDIR)/nforce
NVIDIA_NFORCE_IPKG_TMP		= $(NVIDIA_NFORCE_DIR)/ipkg_tmp

# ----------------------------------------------------------------------------
# Get
# ----------------------------------------------------------------------------

NVIDIA_nforce_get: $(STATEDIR)/NVIDIA_nforce.get

NVIDIA_nforce_get_deps = $(NVIDIA_NFORCE_SOURCE)

$(STATEDIR)/NVIDIA_nforce.get: $(NVIDIA_nforce_get_deps)
	@$(call targetinfo, $@)
	@$(call get_patches, $(NVIDIA_NFORCE))
	touch $@

$(NVIDIA_NFORCE_SOURCE):
	@$(call targetinfo, $@)
	@$(call get, $(NVIDIA_NFORCE_URL))

# ----------------------------------------------------------------------------
# Extract
# ----------------------------------------------------------------------------

NVIDIA_nforce_extract: $(STATEDIR)/NVIDIA_nforce.extract

NVIDIA_nforce_extract_deps = $(STATEDIR)/NVIDIA_nforce.get

$(STATEDIR)/NVIDIA_nforce.extract: $(NVIDIA_nforce_extract_deps)
	@$(call targetinfo, $@)
	@$(call clean,   $(NVIDIA_NFORCE_DIR))
	@$(call extract, $(NVIDIA_NFORCE_SOURCE))
	@$(call patchin, $(NVIDIA_NFORCE), $(NVIDIA_NFORCE_DIR))
	touch $@

# ----------------------------------------------------------------------------
# Prepare
# ----------------------------------------------------------------------------

NVIDIA_nforce_prepare: $(STATEDIR)/NVIDIA_nforce.prepare

#
# dependencies
#
NVIDIA_nforce_prepare_deps = \
	$(STATEDIR)/NVIDIA_nforce.extract \
	$(STATEDIR)/virtual-xchain.install

NVIDIA_NFORCE_PATH	=  PATH=$(CROSS_PATH)
NVIDIA_NFORCE_ENV 	=  $(CROSS_ENV)
#NVIDIA_NFORCE_ENV	+=
NVIDIA_NFORCE_ENV	+= PKG_CONFIG_PATH=$(CROSS_LIB_DIR)/lib/pkgconfig:$(CROSS_LIB_DIR)/lib/pkgconfig
#ifdef PTXCONF_XFREE430
#NVIDIA_NFORCE_ENV	+= LDFLAGS=-Wl,-rpath-link,$(CROSS_LIB_DIR)/lib
#endif

#
# autoconf
#
NVIDIA_NFORCE_AUTOCONF = \
	--build=$(GNU_HOST) \
	--host=$(PTXCONF_GNU_TARGET) \
	--prefix=/usr

ifdef PTXCONF_XFREE430
NVIDIA_NFORCE_AUTOCONF += --x-includes=$(CROSS_LIB_DIR)/include
NVIDIA_NFORCE_AUTOCONF += --x-libraries=$(CROSS_LIB_DIR)/lib
endif

$(STATEDIR)/NVIDIA_nforce.prepare: $(NVIDIA_nforce_prepare_deps)
	@$(call targetinfo, $@)
	@$(call clean, $(NVIDIA_NFORCE_DIR)/config.cache)
	cd $(NVIDIA_NFORCE_DIR) && \
		$(NVIDIA_NFORCE_PATH) $(NVIDIA_NFORCE_ENV) \
		sh ./Configure --kernel=$(KERNEL_DIR)
	touch $@

# ----------------------------------------------------------------------------
# Compile
# ----------------------------------------------------------------------------

NVIDIA_nforce_compile: $(STATEDIR)/NVIDIA_nforce.compile

NVIDIA_nforce_compile_deps = $(STATEDIR)/NVIDIA_nforce.prepare

$(STATEDIR)/NVIDIA_nforce.compile: $(NVIDIA_nforce_compile_deps)
	@$(call targetinfo, $@)
	$(NVIDIA_NFORCE_PATH) $(MAKE) -C $(NVIDIA_NFORCE_DIR)/nvaudio
	$(NVIDIA_NFORCE_PATH) $(MAKE) -C $(NVIDIA_NFORCE_DIR)/nvnet
	touch $@

# ----------------------------------------------------------------------------
# Install
# ----------------------------------------------------------------------------

NVIDIA_nforce_install: $(STATEDIR)/NVIDIA_nforce.install

$(STATEDIR)/NVIDIA_nforce.install: $(STATEDIR)/NVIDIA_nforce.compile
	@$(call targetinfo, $@)
	touch $@

# ----------------------------------------------------------------------------
# Target-Install
# ----------------------------------------------------------------------------

NVIDIA_nforce_targetinstall: $(STATEDIR)/NVIDIA_nforce.targetinstall

NVIDIA_nforce_targetinstall_deps = $(STATEDIR)/NVIDIA_nforce.compile

$(STATEDIR)/NVIDIA_nforce.targetinstall: $(NVIDIA_nforce_targetinstall_deps)
	@$(call targetinfo, $@)
	$(NVIDIA_NFORCE_PATH) $(MAKE) -C $(NVIDIA_NFORCE_DIR)/nvaudio INSTROOT=$(NVIDIA_NFORCE_IPKG_TMP) install
	$(NVIDIA_NFORCE_PATH) $(MAKE) -C $(NVIDIA_NFORCE_DIR)/nvnet   INSTROOT=$(NVIDIA_NFORCE_IPKG_TMP) install
	mkdir -p $(NVIDIA_NFORCE_IPKG_TMP)/CONTROL
	echo "Package: nforce-modules" 								 >$(NVIDIA_NFORCE_IPKG_TMP)/CONTROL/control
	echo "Priority: optional" 								>>$(NVIDIA_NFORCE_IPKG_TMP)/CONTROL/control
	echo "Section: Kernel"	 								>>$(NVIDIA_NFORCE_IPKG_TMP)/CONTROL/control
	echo "Maintainer: Alexander Chukov <sash@pdaXrom.org>" 					>>$(NVIDIA_NFORCE_IPKG_TMP)/CONTROL/control
	echo "Architecture: $(SHORT_TARGET)" 							>>$(NVIDIA_NFORCE_IPKG_TMP)/CONTROL/control
	echo "Version: $(NVIDIA_NFORCE_VERSION)"				 		>>$(NVIDIA_NFORCE_IPKG_TMP)/CONTROL/control
	echo "Depends: " 									>>$(NVIDIA_NFORCE_IPKG_TMP)/CONTROL/control
	echo "Description: Nvidia NForce kernel modules"					>>$(NVIDIA_NFORCE_IPKG_TMP)/CONTROL/control
	cd $(FEEDDIR) && $(XMKIPKG) $(NVIDIA_NFORCE_IPKG_TMP)
	touch $@

# ----------------------------------------------------------------------------
# Image-Install
# ----------------------------------------------------------------------------

ifdef PTXCONF_NVIDIA_NFORCE_INSTALL
ROMPACKAGES += $(STATEDIR)/NVIDIA_nforce.imageinstall
endif

NVIDIA_nforce_imageinstall_deps = $(STATEDIR)/NVIDIA_nforce.targetinstall \
	$(STATEDIR)/virtual-image.install

$(STATEDIR)/NVIDIA_nforce.imageinstall: $(NVIDIA_nforce_imageinstall_deps)
	@$(call targetinfo, $@)
	cd $(FEEDDIR) && $(XIPKG) install nforce-modules
	touch $@

# ----------------------------------------------------------------------------
# Clean
# ----------------------------------------------------------------------------

NVIDIA_nforce_clean:
	rm -rf $(STATEDIR)/NVIDIA_nforce.*
	rm -rf $(NVIDIA_NFORCE_DIR)

# vim: syntax=make
