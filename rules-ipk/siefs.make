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
ifdef PTXCONF_SIEFS
PACKAGES += siefs
endif

#
# Paths and names
#
SIEFS_VENDOR_VERSION	= 1
SIEFS_VERSION		= 0.4
SIEFS			= siefs-$(SIEFS_VERSION)
SIEFS_SUFFIX		= tar.gz
SIEFS_URL		= http://chaos.allsiemens.com/download/$(SIEFS).$(SIEFS_SUFFIX)
SIEFS_SOURCE		= $(SRCDIR)/$(SIEFS).$(SIEFS_SUFFIX)
SIEFS_DIR		= $(BUILDDIR)/$(SIEFS)
SIEFS_IPKG_TMP		= $(SIEFS_DIR)/ipkg_tmp

# ----------------------------------------------------------------------------
# Get
# ----------------------------------------------------------------------------

siefs_get: $(STATEDIR)/siefs.get

siefs_get_deps = $(SIEFS_SOURCE)

$(STATEDIR)/siefs.get: $(siefs_get_deps)
	@$(call targetinfo, $@)
	@$(call get_patches, $(SIEFS))
	touch $@

$(SIEFS_SOURCE):
	@$(call targetinfo, $@)
	@$(call get, $(SIEFS_URL))

# ----------------------------------------------------------------------------
# Extract
# ----------------------------------------------------------------------------

siefs_extract: $(STATEDIR)/siefs.extract

siefs_extract_deps = $(STATEDIR)/siefs.get

$(STATEDIR)/siefs.extract: $(siefs_extract_deps)
	@$(call targetinfo, $@)
	@$(call clean, $(SIEFS_DIR))
	@$(call extract, $(SIEFS_SOURCE))
	@$(call patchin, $(SIEFS))
	touch $@

# ----------------------------------------------------------------------------
# Prepare
# ----------------------------------------------------------------------------

siefs_prepare: $(STATEDIR)/siefs.prepare

#
# dependencies
#
siefs_prepare_deps = \
	$(STATEDIR)/siefs.extract \
	$(STATEDIR)/fuse.install \
	$(STATEDIR)/virtual-xchain.install

SIEFS_PATH	=  PATH=$(CROSS_PATH)
SIEFS_ENV 	=  $(CROSS_ENV)
SIEFS_ENV	+= CFLAGS="-O2 -fomit-frame-pointer -D_FILE_OFFSET_BITS=64"
SIEFS_ENV	+= PKG_CONFIG_PATH=$(CROSS_LIB_DIR)/lib/pkgconfig:$(CROSS_LIB_DIR)/lib/pkgconfig
#ifdef PTXCONF_XFREE430
#SIEFS_ENV	+= LDFLAGS=-Wl,-rpath-link,$(CROSS_LIB_DIR)/lib
#endif

#
# autoconf
#
SIEFS_AUTOCONF = \
	--build=$(GNU_HOST) \
	--host=$(PTXCONF_GNU_TARGET) \
	--prefix=/usr \
	--sysconfdir=/etc \
	--with-fuse=$(CROSS_LIB_DIR)

ifdef PTXCONF_XFREE430
SIEFS_AUTOCONF += --x-includes=$(CROSS_LIB_DIR)/include
SIEFS_AUTOCONF += --x-libraries=$(CROSS_LIB_DIR)/lib
endif

$(STATEDIR)/siefs.prepare: $(siefs_prepare_deps)
	@$(call targetinfo, $@)
	@$(call clean, $(SIEFS_DIR)/config.cache)
	cd $(SIEFS_DIR) && \
		$(SIEFS_PATH) $(SIEFS_ENV) \
		./configure $(SIEFS_AUTOCONF)
	touch $@

# ----------------------------------------------------------------------------
# Compile
# ----------------------------------------------------------------------------

siefs_compile: $(STATEDIR)/siefs.compile

siefs_compile_deps = $(STATEDIR)/siefs.prepare

$(STATEDIR)/siefs.compile: $(siefs_compile_deps)
	@$(call targetinfo, $@)
	$(SIEFS_PATH) $(MAKE) -C $(SIEFS_DIR) CFLAGS="-O2 -fomit-frame-pointer -D_FILE_OFFSET_BITS=64"
	touch $@

# ----------------------------------------------------------------------------
# Install
# ----------------------------------------------------------------------------

siefs_install: $(STATEDIR)/siefs.install

$(STATEDIR)/siefs.install: $(STATEDIR)/siefs.compile
	@$(call targetinfo, $@)
	touch $@

# ----------------------------------------------------------------------------
# Target-Install
# ----------------------------------------------------------------------------

siefs_targetinstall: $(STATEDIR)/siefs.targetinstall

siefs_targetinstall_deps = $(STATEDIR)/siefs.compile \
	$(STATEDIR)/fuse.targetinstall

$(STATEDIR)/siefs.targetinstall: $(siefs_targetinstall_deps)
	@$(call targetinfo, $@)
	$(SIEFS_PATH) $(MAKE) -C $(SIEFS_DIR) DESTDIR=$(SIEFS_IPKG_TMP) install
	rm -f $(SIEFS_IPKG_TMP)/usr/bin/vmo2wav
	$(CROSSSTRIP) $(SIEFS_IPKG_TMP)/usr/bin/*
	mkdir -p $(SIEFS_IPKG_TMP)/CONTROL
	echo "Package: siefs" 											 >$(SIEFS_IPKG_TMP)/CONTROL/control
	echo "Priority: optional" 										>>$(SIEFS_IPKG_TMP)/CONTROL/control
	echo "Section: Kernel"	 										>>$(SIEFS_IPKG_TMP)/CONTROL/control
	echo "Maintainer: Alexander Chukov <sash@pdaXrom.org>" 							>>$(SIEFS_IPKG_TMP)/CONTROL/control
	echo "Architecture: $(SHORT_TARGET)" 									>>$(SIEFS_IPKG_TMP)/CONTROL/control
	echo "Version: $(SIEFS_VERSION)-$(SIEFS_VENDOR_VERSION)" 						>>$(SIEFS_IPKG_TMP)/CONTROL/control
	echo "Depends: fuse"			 								>>$(SIEFS_IPKG_TMP)/CONTROL/control
	echo "Description: SieFS is a virtual filesystem for accessing Siemens mobile phones' memory (flexmem or MultiMediaCard) from Linux. Now you can mount your phone (by datacable or IRDA) and work with it like with any other removable storage." >>$(SIEFS_IPKG_TMP)/CONTROL/control
	cd $(FEEDDIR) && $(XMKIPKG) $(SIEFS_IPKG_TMP)
	touch $@

# ----------------------------------------------------------------------------
# Image-Install
# ----------------------------------------------------------------------------

ifdef PTXCONF_SIEFS_INSTALL
ROMPACKAGES += $(STATEDIR)/siefs.imageinstall
endif

siefs_imageinstall_deps = $(STATEDIR)/siefs.targetinstall \
	$(STATEDIR)/virtual-image.install

$(STATEDIR)/siefs.imageinstall: $(siefs_imageinstall_deps)
	@$(call targetinfo, $@)
	cd $(FEEDDIR) && $(XIPKG) install siefs
	touch $@

# ----------------------------------------------------------------------------
# Clean
# ----------------------------------------------------------------------------

siefs_clean:
	rm -rf $(STATEDIR)/siefs.*
	rm -rf $(SIEFS_DIR)

# vim: syntax=make
