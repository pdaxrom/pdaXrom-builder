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
ifdef PTXCONF_OVLFS
PACKAGES += ovlfs
endif

#
# Paths and names
#
OVLFS_VERSION		= 2.0.1
OVLFS			= ovlfs-$(OVLFS_VERSION)
OVLFS_SUFFIX		= tgz
OVLFS_URL		= http://mesh.dl.sourceforge.net/sourceforge/ovlfs/$(OVLFS).$(OVLFS_SUFFIX)
OVLFS_SOURCE		= $(SRCDIR)/$(OVLFS).$(OVLFS_SUFFIX)
OVLFS_DIR		= $(BUILDDIR)/$(OVLFS)
OVLFS_IPKG_TMP		= $(OVLFS_DIR)/ipkg_tmp

# ----------------------------------------------------------------------------
# Get
# ----------------------------------------------------------------------------

ovlfs_get: $(STATEDIR)/ovlfs.get

ovlfs_get_deps = $(OVLFS_SOURCE)

$(STATEDIR)/ovlfs.get: $(ovlfs_get_deps)
	@$(call targetinfo, $@)
	@$(call get_patches, $(OVLFS))
	touch $@

$(OVLFS_SOURCE):
	@$(call targetinfo, $@)
	@$(call get, $(OVLFS_URL))

# ----------------------------------------------------------------------------
# Extract
# ----------------------------------------------------------------------------

ovlfs_extract: $(STATEDIR)/ovlfs.extract

ovlfs_extract_deps = $(STATEDIR)/ovlfs.get

$(STATEDIR)/ovlfs.extract: $(ovlfs_extract_deps)
	@$(call targetinfo, $@)
	@$(call clean, $(OVLFS_DIR))
	@$(call extract, $(OVLFS_SOURCE))
	@$(call patchin, $(OVLFS))
	touch $@

# ----------------------------------------------------------------------------
# Prepare
# ----------------------------------------------------------------------------

ovlfs_prepare: $(STATEDIR)/ovlfs.prepare

#
# dependencies
#
ovlfs_prepare_deps = \
	$(STATEDIR)/ovlfs.extract \
	$(STATEDIR)/flex.install \
	$(STATEDIR)/virtual-xchain.install

OVLFS_PATH	=  PATH=$(CROSS_PATH)
OVLFS_ENV 	=  $(CROSS_ENV)
#OVLFS_ENV	+=
OVLFS_ENV	+= PKG_CONFIG_PATH=$(CROSS_LIB_DIR)/lib/pkgconfig:$(CROSS_LIB_DIR)/lib/pkgconfig
#ifdef PTXCONF_XFREE430
#OVLFS_ENV	+= LDFLAGS=-Wl,-rpath-link,$(CROSS_LIB_DIR)/lib
#endif

#
# autoconf
#
OVLFS_AUTOCONF = \
	--build=$(GNU_HOST) \
	--host=$(PTXCONF_GNU_TARGET) \
	--prefix=/usr

ifdef PTXCONF_XFREE430
OVLFS_AUTOCONF += --x-includes=$(CROSS_LIB_DIR)/include
OVLFS_AUTOCONF += --x-libraries=$(CROSS_LIB_DIR)/lib
endif

$(STATEDIR)/ovlfs.prepare: $(ovlfs_prepare_deps)
	@$(call targetinfo, $@)
	@$(call clean, $(OVLFS_DIR)/config.cache)
	cd $(OVLFS_DIR) && \
		$(OVLFS_PATH) $(OVLFS_ENV) \
		./configure --kernel=$(KERNEL_DIR)
	touch $@

# ----------------------------------------------------------------------------
# Compile
# ----------------------------------------------------------------------------

ovlfs_compile: $(STATEDIR)/ovlfs.compile

ovlfs_compile_deps = $(STATEDIR)/ovlfs.prepare

$(STATEDIR)/ovlfs.compile: $(ovlfs_compile_deps)
	@$(call targetinfo, $@)
	$(OVLFS_PATH) $(MAKE) -C $(OVLFS_DIR) \
	    AR_FOR_TARGET=$(PTXCONF_GNU_TARGET)-ar \
	    CC_FOR_TARGET=$(PTXCONF_GNU_TARGET)-gcc \
	    CXX_FOR_TARGET=$(PTXCONF_GNU_TARGET)-g++ \
	    LD_FOR_TARGET=$(PTXCONF_GNU_TARGET)-ld \
	    $(CROSS_ENV_CC) $(CROSS_ENV_LD)
	touch $@

# ----------------------------------------------------------------------------
# Install
# ----------------------------------------------------------------------------

ovlfs_install: $(STATEDIR)/ovlfs.install

$(STATEDIR)/ovlfs.install: $(STATEDIR)/ovlfs.compile
	@$(call targetinfo, $@)
	touch $@

# ----------------------------------------------------------------------------
# Target-Install
# ----------------------------------------------------------------------------

ovlfs_targetinstall: $(STATEDIR)/ovlfs.targetinstall

ovlfs_targetinstall_deps = $(STATEDIR)/ovlfs.compile

$(STATEDIR)/ovlfs.targetinstall: $(ovlfs_targetinstall_deps)
	@$(call targetinfo, $@)
	$(OVLFS_PATH) $(MAKE) -C $(OVLFS_DIR) INSTALL_ROOT=$(OVLFS_IPKG_TMP) install
	rm -rf $(OVLFS_IPKG_TMP)/usr
	chmod +w $(OVLFS_IPKG_TMP)/sbin/*
	$(CROSSSTRIP) $(OVLFS_IPKG_TMP)/sbin/*
	mkdir -p $(OVLFS_IPKG_TMP)/CONTROL
	echo "Package: ovlfs" 						>$(OVLFS_IPKG_TMP)/CONTROL/control
	echo "Priority: optional" 					>>$(OVLFS_IPKG_TMP)/CONTROL/control
	echo "Section: Libraries" 					>>$(OVLFS_IPKG_TMP)/CONTROL/control
	echo "Maintainer: Alexander Chukov <sash@pdaXrom.org>" 		>>$(OVLFS_IPKG_TMP)/CONTROL/control
	echo "Architecture: $(SHORT_TARGET)" 				>>$(OVLFS_IPKG_TMP)/CONTROL/control
	echo "Version: $(OVLFS_VERSION)" 				>>$(OVLFS_IPKG_TMP)/CONTROL/control
	echo "Depends: " 						>>$(OVLFS_IPKG_TMP)/CONTROL/control
	echo "Description: The overlay filesystem is a pseudo filesystem that allows users to work with files from another filesystem without affecting it.">>$(OVLFS_IPKG_TMP)/CONTROL/control
	cd $(FEEDDIR) && $(XMKIPKG) $(OVLFS_IPKG_TMP)
	touch $@

# ----------------------------------------------------------------------------
# Image-Install
# ----------------------------------------------------------------------------

ifdef PTXCONF_OVLFS_INSTALL
ROMPACKAGES += $(STATEDIR)/ovlfs.imageinstall
endif

ovlfs_imageinstall_deps = $(STATEDIR)/ovlfs.targetinstall \
	$(STATEDIR)/virtual-image.install

$(STATEDIR)/ovlfs.imageinstall: $(ovlfs_imageinstall_deps)
	@$(call targetinfo, $@)
	cd $(FEEDDIR) && $(XIPKG) install ovlfs
	touch $@

# ----------------------------------------------------------------------------
# Clean
# ----------------------------------------------------------------------------

ovlfs_clean:
	rm -rf $(STATEDIR)/ovlfs.*
	rm -rf $(OVLFS_DIR)

# vim: syntax=make
