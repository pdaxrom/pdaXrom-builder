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
ifdef PTXCONF_BZFLAG
PACKAGES += bzflag
endif

#
# Paths and names
#
BZFLAG_VENDOR_VERSION	= 1
BZFLAG_VERSION		= 2.0.0.20050117
BZFLAG			= bzflag-$(BZFLAG_VERSION)
BZFLAG_SUFFIX		= tar.bz2
BZFLAG_URL		= http://ftp.bzflag.org/bzflag/$(BZFLAG).$(BZFLAG_SUFFIX)
BZFLAG_SOURCE		= $(SRCDIR)/$(BZFLAG).$(BZFLAG_SUFFIX)
BZFLAG_DIR		= $(BUILDDIR)/$(BZFLAG)
BZFLAG_IPKG_TMP		= $(BZFLAG_DIR)/ipkg_tmp

# ----------------------------------------------------------------------------
# Get
# ----------------------------------------------------------------------------

bzflag_get: $(STATEDIR)/bzflag.get

bzflag_get_deps = $(BZFLAG_SOURCE)

$(STATEDIR)/bzflag.get: $(bzflag_get_deps)
	@$(call targetinfo, $@)
	@$(call get_patches, $(BZFLAG))
	touch $@

$(BZFLAG_SOURCE):
	@$(call targetinfo, $@)
	@$(call get, $(BZFLAG_URL))

# ----------------------------------------------------------------------------
# Extract
# ----------------------------------------------------------------------------

bzflag_extract: $(STATEDIR)/bzflag.extract

bzflag_extract_deps = $(STATEDIR)/bzflag.get

$(STATEDIR)/bzflag.extract: $(bzflag_extract_deps)
	@$(call targetinfo, $@)
	@$(call clean, $(BZFLAG_DIR))
	@$(call extract, $(BZFLAG_SOURCE))
	@$(call patchin, $(BZFLAG))
	touch $@

# ----------------------------------------------------------------------------
# Prepare
# ----------------------------------------------------------------------------

bzflag_prepare: $(STATEDIR)/bzflag.prepare

#
# dependencies
#
bzflag_prepare_deps = \
	$(STATEDIR)/bzflag.extract \
	$(STATEDIR)/MesaLib.install \
	$(STATEDIR)/curl.install \
	$(STATEDIR)/virtual-xchain.install

BZFLAG_PATH	=  PATH=$(CROSS_PATH)
BZFLAG_ENV 	=  $(CROSS_ENV)
BZFLAG_ENV	+= CFLAGS="$(TARGET_OPT_CFLAGS)"
BZFLAG_ENV	+= CXXFLAGS="$(TARGET_OPT_CFLAGS)"
BZFLAG_ENV	+= PKG_CONFIG_PATH=$(CROSS_LIB_DIR)/lib/pkgconfig:$(CROSS_LIB_DIR)/lib/pkgconfig
#ifdef PTXCONF_XFREE430
#BZFLAG_ENV	+= LDFLAGS=-Wl,-rpath-link,$(CROSS_LIB_DIR)/lib
#endif

#
# autoconf
#
BZFLAG_AUTOCONF = \
	--build=$(GNU_HOST) \
	--host=$(PTXCONF_GNU_TARGET) \
	--prefix=/usr \
	--without-SDL

ifdef PTXCONF_XFREE430
BZFLAG_AUTOCONF += --x-includes=$(CROSS_LIB_DIR)/include
BZFLAG_AUTOCONF += --x-libraries=$(CROSS_LIB_DIR)/lib
endif

$(STATEDIR)/bzflag.prepare: $(bzflag_prepare_deps)
	@$(call targetinfo, $@)
	@$(call clean, $(BZFLAG_DIR)/config.cache)
	cd $(BZFLAG_DIR) && \
		$(BZFLAG_PATH) $(BZFLAG_ENV) \
		./configure $(BZFLAG_AUTOCONF)
	touch $@

# ----------------------------------------------------------------------------
# Compile
# ----------------------------------------------------------------------------

bzflag_compile: $(STATEDIR)/bzflag.compile

bzflag_compile_deps = $(STATEDIR)/bzflag.prepare

$(STATEDIR)/bzflag.compile: $(bzflag_compile_deps)
	@$(call targetinfo, $@)
	$(BZFLAG_PATH) $(MAKE) -C $(BZFLAG_DIR)
	touch $@

# ----------------------------------------------------------------------------
# Install
# ----------------------------------------------------------------------------

bzflag_install: $(STATEDIR)/bzflag.install

$(STATEDIR)/bzflag.install: $(STATEDIR)/bzflag.compile
	@$(call targetinfo, $@)
	touch $@

# ----------------------------------------------------------------------------
# Target-Install
# ----------------------------------------------------------------------------

bzflag_targetinstall: $(STATEDIR)/bzflag.targetinstall

bzflag_targetinstall_deps = $(STATEDIR)/bzflag.compile \
	$(STATEDIR)/MesaLib.targetinstall \
	$(STATEDIR)/curl.targetinstall 

$(STATEDIR)/bzflag.targetinstall: $(bzflag_targetinstall_deps)
	@$(call targetinfo, $@)
	$(BZFLAG_PATH) $(MAKE) -C $(BZFLAG_DIR) DESTDIR=$(BZFLAG_IPKG_TMP) install
	rm -rf $(BZFLAG_IPKG_TMP)/usr/man
	$(CROSSSTRIP) $(BZFLAG_IPKG_TMP)/usr/bin/*
	mkdir -p $(BZFLAG_IPKG_TMP)/CONTROL
	echo "Package: bzflag" 											 >$(BZFLAG_IPKG_TMP)/CONTROL/control
	echo "Priority: optional" 										>>$(BZFLAG_IPKG_TMP)/CONTROL/control
	echo "Section: Games" 											>>$(BZFLAG_IPKG_TMP)/CONTROL/control
	echo "Maintainer: Alexander Chukov <sash@pdaXrom.org>" 							>>$(BZFLAG_IPKG_TMP)/CONTROL/control
	echo "Architecture: $(SHORT_TARGET)" 									>>$(BZFLAG_IPKG_TMP)/CONTROL/control
	echo "Version: $(BZFLAG_VERSION)-$(BZFLAG_VENDOR_VERSION)" 						>>$(BZFLAG_IPKG_TMP)/CONTROL/control
	echo "Depends: mesa3d, curl" 										>>$(BZFLAG_IPKG_TMP)/CONTROL/control
	echo "Description: BZFlag is a free multiplayer multiplatform 3D tank battle game."			>>$(BZFLAG_IPKG_TMP)/CONTROL/control
	cd $(FEEDDIR) && $(XMKIPKG) $(BZFLAG_IPKG_TMP)
	touch $@

# ----------------------------------------------------------------------------
# Image-Install
# ----------------------------------------------------------------------------

ifdef PTXCONF_BZFLAG_INSTALL
ROMPACKAGES += $(STATEDIR)/bzflag.imageinstall
endif

bzflag_imageinstall_deps = $(STATEDIR)/bzflag.targetinstall \
	$(STATEDIR)/virtual-image.install

$(STATEDIR)/bzflag.imageinstall: $(bzflag_imageinstall_deps)
	@$(call targetinfo, $@)
	cd $(FEEDDIR) && $(XIPKG) install bzflag
	touch $@

# ----------------------------------------------------------------------------
# Clean
# ----------------------------------------------------------------------------

bzflag_clean:
	rm -rf $(STATEDIR)/bzflag.*
	rm -rf $(BZFLAG_DIR)

# vim: syntax=make
