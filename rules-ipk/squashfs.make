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
ifdef PTXCONF_SQUASHFS
PACKAGES += squashfs
endif

#
# Paths and names
#
SQUASHFS_VERSION	= 2.0
SQUASHFS		= squashfs$(SQUASHFS_VERSION)-r2
SQUASHFS_SUFFIX		= tar.gz
SQUASHFS_URL		= http://mesh.dl.sourceforge.net/sourceforge/squashfs/$(SQUASHFS).$(SQUASHFS_SUFFIX)
SQUASHFS_SOURCE		= $(SRCDIR)/$(SQUASHFS).$(SQUASHFS_SUFFIX)
SQUASHFS_DIR		= $(BUILDDIR)/squashfs$(SQUASHFS_VERSION)r2
SQUASHFS_IPKG_TMP	= $(SQUASHFS_DIR)/ipkg_tmp

# ----------------------------------------------------------------------------
# Get
# ----------------------------------------------------------------------------

squashfs_get: $(STATEDIR)/squashfs.get

squashfs_get_deps = $(SQUASHFS_SOURCE)

$(STATEDIR)/squashfs.get: $(squashfs_get_deps)
	@$(call targetinfo, $@)
	@$(call get_patches, $(SQUASHFS))
	touch $@

$(SQUASHFS_SOURCE):
	@$(call targetinfo, $@)
	@$(call get, $(SQUASHFS_URL))

# ----------------------------------------------------------------------------
# Extract
# ----------------------------------------------------------------------------

squashfs_extract: $(STATEDIR)/squashfs.extract

squashfs_extract_deps = $(STATEDIR)/squashfs.get

$(STATEDIR)/squashfs.extract: $(squashfs_extract_deps)
	@$(call targetinfo, $@)
	@$(call clean, $(SQUASHFS_DIR))
	@$(call extract, $(SQUASHFS_SOURCE))
	@$(call patchin, $(SQUASHFS))
	touch $@

# ----------------------------------------------------------------------------
# Prepare
# ----------------------------------------------------------------------------

squashfs_prepare: $(STATEDIR)/squashfs.prepare

#
# dependencies
#
squashfs_prepare_deps = \
	$(STATEDIR)/squashfs.extract \
	$(STATEDIR)/virtual-xchain.install

SQUASHFS_PATH	=  PATH=$(CROSS_PATH)
SQUASHFS_ENV 	=  $(CROSS_ENV)
#SQUASHFS_ENV	+=
SQUASHFS_ENV	+= PKG_CONFIG_PATH=$(CROSS_LIB_DIR)/lib/pkgconfig:$(CROSS_LIB_DIR)/lib/pkgconfig
#ifdef PTXCONF_XFREE430
#SQUASHFS_ENV	+= LDFLAGS=-Wl,-rpath-link,$(CROSS_LIB_DIR)/lib
#endif

#
# autoconf
#
SQUASHFS_AUTOCONF = \
	--build=$(GNU_HOST) \
	--host=$(PTXCONF_GNU_TARGET) \
	--prefix=/usr

ifdef PTXCONF_XFREE430
SQUASHFS_AUTOCONF += --x-includes=$(CROSS_LIB_DIR)/include
SQUASHFS_AUTOCONF += --x-libraries=$(CROSS_LIB_DIR)/lib
endif

$(STATEDIR)/squashfs.prepare: $(squashfs_prepare_deps)
	@$(call targetinfo, $@)
	@$(call clean, $(SQUASHFS_DIR)/config.cache)
	cd $(SQUASHFS_DIR) && \
		$(SQUASHFS_PATH) $(SQUASHFS_ENV) \
		./configure $(SQUASHFS_AUTOCONF)
	touch $@

# ----------------------------------------------------------------------------
# Compile
# ----------------------------------------------------------------------------

squashfs_compile: $(STATEDIR)/squashfs.compile

squashfs_compile_deps = $(STATEDIR)/squashfs.prepare

$(STATEDIR)/squashfs.compile: $(squashfs_compile_deps)
	@$(call targetinfo, $@)
	$(SQUASHFS_PATH) $(MAKE) -C $(SQUASHFS_DIR)
	touch $@

# ----------------------------------------------------------------------------
# Install
# ----------------------------------------------------------------------------

squashfs_install: $(STATEDIR)/squashfs.install

$(STATEDIR)/squashfs.install: $(STATEDIR)/squashfs.compile
	@$(call targetinfo, $@)
	$(SQUASHFS_PATH) $(MAKE) -C $(SQUASHFS_DIR) install
	touch $@

# ----------------------------------------------------------------------------
# Target-Install
# ----------------------------------------------------------------------------

squashfs_targetinstall: $(STATEDIR)/squashfs.targetinstall

squashfs_targetinstall_deps = $(STATEDIR)/squashfs.compile

$(STATEDIR)/squashfs.targetinstall: $(squashfs_targetinstall_deps)
	@$(call targetinfo, $@)
	$(SQUASHFS_PATH) $(MAKE) -C $(SQUASHFS_DIR) DESTDIR=$(SQUASHFS_IPKG_TMP) install
	mkdir -p $(SQUASHFS_IPKG_TMP)/CONTROL
	echo "Package: squashfs" 			>$(SQUASHFS_IPKG_TMP)/CONTROL/control
	echo "Priority: optional" 			>>$(SQUASHFS_IPKG_TMP)/CONTROL/control
	echo "Section: pdaXrom" 			>>$(SQUASHFS_IPKG_TMP)/CONTROL/control
	echo "Maintainer: Alexander Chukov <sash@pdaXrom.org>" 			>>$(SQUASHFS_IPKG_TMP)/CONTROL/control
	echo "Architecture: $(SHORT_TARGET)" 		>>$(SQUASHFS_IPKG_TMP)/CONTROL/control
	echo "Version: $(SQUASHFS_VERSION)" 		>>$(SQUASHFS_IPKG_TMP)/CONTROL/control
	echo "Depends: " 				>>$(SQUASHFS_IPKG_TMP)/CONTROL/control
	echo "Description: generated with pdaXrom builder">>$(SQUASHFS_IPKG_TMP)/CONTROL/control
	cd $(FEEDDIR) && $(XMKIPKG) $(SQUASHFS_IPKG_TMP)
	touch $@

# ----------------------------------------------------------------------------
# Image-Install
# ----------------------------------------------------------------------------

ifdef PTXCONF_SQUASHFS_INSTALL
ROMPACKAGES += $(STATEDIR)/squashfs.imageinstall
endif

squashfs_imageinstall_deps = $(STATEDIR)/squashfs.targetinstall \
	$(STATEDIR)/virtual-image.install

$(STATEDIR)/squashfs.imageinstall: $(squashfs_imageinstall_deps)
	@$(call targetinfo, $@)
	cd $(FEEDDIR) && $(XIPKG) install squashfs
	touch $@

# ----------------------------------------------------------------------------
# Clean
# ----------------------------------------------------------------------------

squashfs_clean:
	rm -rf $(STATEDIR)/squashfs.*
	rm -rf $(SQUASHFS_DIR)

# vim: syntax=make
