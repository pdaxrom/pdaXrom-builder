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
ifdef PTXCONF_MIKMOD
PACKAGES += mikmod
endif

#
# Paths and names
#
MIKMOD_VERSION		= 3.2.2-beta1
MIKMOD			= mikmod-$(MIKMOD_VERSION)
MIKMOD_SUFFIX		= tar.bz2
MIKMOD_URL		= http://mikmod.raphnet.net/files/$(MIKMOD).$(MIKMOD_SUFFIX)
MIKMOD_SOURCE		= $(SRCDIR)/$(MIKMOD).$(MIKMOD_SUFFIX)
MIKMOD_DIR		= $(BUILDDIR)/$(MIKMOD)
MIKMOD_IPKG_TMP		= $(MIKMOD_DIR)/ipkg_tmp

# ----------------------------------------------------------------------------
# Get
# ----------------------------------------------------------------------------

mikmod_get: $(STATEDIR)/mikmod.get

mikmod_get_deps = $(MIKMOD_SOURCE)

$(STATEDIR)/mikmod.get: $(mikmod_get_deps)
	@$(call targetinfo, $@)
	@$(call get_patches, $(MIKMOD))
	touch $@

$(MIKMOD_SOURCE):
	@$(call targetinfo, $@)
	@$(call get, $(MIKMOD_URL))

# ----------------------------------------------------------------------------
# Extract
# ----------------------------------------------------------------------------

mikmod_extract: $(STATEDIR)/mikmod.extract

mikmod_extract_deps = $(STATEDIR)/mikmod.get

$(STATEDIR)/mikmod.extract: $(mikmod_extract_deps)
	@$(call targetinfo, $@)
	@$(call clean, $(MIKMOD_DIR))
	@$(call extract, $(MIKMOD_SOURCE))
	@$(call patchin, $(MIKMOD))
	touch $@

# ----------------------------------------------------------------------------
# Prepare
# ----------------------------------------------------------------------------

mikmod_prepare: $(STATEDIR)/mikmod.prepare

#
# dependencies
#
mikmod_prepare_deps = \
	$(STATEDIR)/mikmod.extract \
	$(STATEDIR)/libmikmod.install \
	$(STATEDIR)/virtual-xchain.install

MIKMOD_PATH	=  PATH=$(CROSS_PATH)
MIKMOD_ENV 	=  $(CROSS_ENV)
MIKMOD_ENV	+= CFLAGS="$(TARGET_OPT_CFLAGS)"
MIKMOD_ENV	+= PKG_CONFIG_PATH=$(CROSS_LIB_DIR)/lib/pkgconfig:$(CROSS_LIB_DIR)/lib/pkgconfig
#ifdef PTXCONF_XFREE430
#MIKMOD_ENV	+= LDFLAGS=-Wl,-rpath-link,$(CROSS_LIB_DIR)/lib
#endif

#
# autoconf
#
MIKMOD_AUTOCONF = \
	--build=$(GNU_HOST) \
	--host=$(PTXCONF_GNU_TARGET) \
	--prefix=/usr

ifdef PTXCONF_XFREE430
MIKMOD_AUTOCONF += --x-includes=$(CROSS_LIB_DIR)/include
MIKMOD_AUTOCONF += --x-libraries=$(CROSS_LIB_DIR)/lib
endif

$(STATEDIR)/mikmod.prepare: $(mikmod_prepare_deps)
	@$(call targetinfo, $@)
	@$(call clean, $(MIKMOD_DIR)/config.cache)
	cd $(MIKMOD_DIR) && \
		$(MIKMOD_PATH) $(MIKMOD_ENV) \
		./configure $(MIKMOD_AUTOCONF)
	touch $@

# ----------------------------------------------------------------------------
# Compile
# ----------------------------------------------------------------------------

mikmod_compile: $(STATEDIR)/mikmod.compile

mikmod_compile_deps = $(STATEDIR)/mikmod.prepare

$(STATEDIR)/mikmod.compile: $(mikmod_compile_deps)
	@$(call targetinfo, $@)
	$(MIKMOD_PATH) $(MAKE) -C $(MIKMOD_DIR)
	touch $@

# ----------------------------------------------------------------------------
# Install
# ----------------------------------------------------------------------------

mikmod_install: $(STATEDIR)/mikmod.install

$(STATEDIR)/mikmod.install: $(STATEDIR)/mikmod.compile
	@$(call targetinfo, $@)
	touch $@

# ----------------------------------------------------------------------------
# Target-Install
# ----------------------------------------------------------------------------

mikmod_targetinstall: $(STATEDIR)/mikmod.targetinstall

mikmod_targetinstall_deps = $(STATEDIR)/mikmod.compile \
	$(STATEDIR)/libmikmod.targetinstall

$(STATEDIR)/mikmod.targetinstall: $(mikmod_targetinstall_deps)
	@$(call targetinfo, $@)
	$(MIKMOD_PATH) $(MAKE) -C $(MIKMOD_DIR) DESTDIR=$(MIKMOD_IPKG_TMP) install
	rm -rf $(MIKMOD_IPKG_TMP)/usr/man
	$(CROSSSTRIP) $(MIKMOD_IPKG_TMP)/usr/bin/*
	mkdir -p $(MIKMOD_IPKG_TMP)/CONTROL
	echo "Package: mikmod" 									>$(MIKMOD_IPKG_TMP)/CONTROL/control
	echo "Priority: optional" 								>>$(MIKMOD_IPKG_TMP)/CONTROL/control
	echo "Section: Multimedia" 								>>$(MIKMOD_IPKG_TMP)/CONTROL/control
	echo "Maintainer: Alexander Chukov <sash@pdaXrom.org>" 					>>$(MIKMOD_IPKG_TMP)/CONTROL/control
	echo "Architecture: $(SHORT_TARGET)" 							>>$(MIKMOD_IPKG_TMP)/CONTROL/control
	echo "Version: $(MIKMOD_VERSION)" 							>>$(MIKMOD_IPKG_TMP)/CONTROL/control
	echo "Depends: libmikmod" 								>>$(MIKMOD_IPKG_TMP)/CONTROL/control
	echo "Description: MOD, XM player"							>>$(MIKMOD_IPKG_TMP)/CONTROL/control
	cd $(FEEDDIR) && $(XMKIPKG) $(MIKMOD_IPKG_TMP)
	touch $@

# ----------------------------------------------------------------------------
# Image-Install
# ----------------------------------------------------------------------------

ifdef PTXCONF_MIKMOD_INSTALL
ROMPACKAGES += $(STATEDIR)/mikmod.imageinstall
endif

mikmod_imageinstall_deps = $(STATEDIR)/mikmod.targetinstall \
	$(STATEDIR)/virtual-image.install

$(STATEDIR)/mikmod.imageinstall: $(mikmod_imageinstall_deps)
	@$(call targetinfo, $@)
	cd $(FEEDDIR) && $(XIPKG) install mikmod
	touch $@

# ----------------------------------------------------------------------------
# Clean
# ----------------------------------------------------------------------------

mikmod_clean:
	rm -rf $(STATEDIR)/mikmod.*
	rm -rf $(MIKMOD_DIR)

# vim: syntax=make
