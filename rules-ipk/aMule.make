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
ifdef PTXCONF_AMULE
PACKAGES += aMule
endif

#
# Paths and names
#
AMULE_VENDOR_VERSION	= 1
AMULE_VERSION		= 2.0.0rc7
AMULE			= aMule-$(AMULE_VERSION)
AMULE_SUFFIX		= tar.bz2
AMULE_URL		= http://download.berlios.de/amule/$(AMULE).$(AMULE_SUFFIX)
AMULE_SOURCE		= $(SRCDIR)/$(AMULE).$(AMULE_SUFFIX)
AMULE_DIR		= $(BUILDDIR)/$(AMULE)
AMULE_IPKG_TMP		= $(AMULE_DIR)/ipkg_tmp

# ----------------------------------------------------------------------------
# Get
# ----------------------------------------------------------------------------

aMule_get: $(STATEDIR)/aMule.get

aMule_get_deps = $(AMULE_SOURCE)

$(STATEDIR)/aMule.get: $(aMule_get_deps)
	@$(call targetinfo, $@)
	@$(call get_patches, $(AMULE))
	touch $@

$(AMULE_SOURCE):
	@$(call targetinfo, $@)
	@$(call get, $(AMULE_URL))

# ----------------------------------------------------------------------------
# Extract
# ----------------------------------------------------------------------------

aMule_extract: $(STATEDIR)/aMule.extract

aMule_extract_deps = $(STATEDIR)/aMule.get

$(STATEDIR)/aMule.extract: $(aMule_extract_deps)
	@$(call targetinfo, $@)
	@$(call clean, $(AMULE_DIR))
	@$(call extract, $(AMULE_SOURCE))
	@$(call patchin, $(AMULE))
	touch $@

# ----------------------------------------------------------------------------
# Prepare
# ----------------------------------------------------------------------------

aMule_prepare: $(STATEDIR)/aMule.prepare

#
# dependencies
#
aMule_prepare_deps = \
	$(STATEDIR)/aMule.extract \
	$(STATEDIR)/gd.install \
	$(STATEDIR)/wxWidgets.install \
	$(STATEDIR)/curl.install \
	$(STATEDIR)/virtual-xchain.install

AMULE_PATH	=  PATH=$(CROSS_PATH)
AMULE_ENV 	=  $(CROSS_ENV)
#AMULE_ENV	+=
AMULE_ENV	+= PKG_CONFIG_PATH=$(CROSS_LIB_DIR)/lib/pkgconfig:$(CROSS_LIB_DIR)/lib/pkgconfig
#ifdef PTXCONF_XFREE430
#AMULE_ENV	+= LDFLAGS=-Wl,-rpath-link,$(CROSS_LIB_DIR)/lib
#endif

#
# autoconf
#
AMULE_AUTOCONF = \
	--build=$(GNU_HOST) \
	--host=$(PTXCONF_GNU_TARGET) \
	--prefix=/usr \
	--disable-debug \
	--enable-optimise

ifdef PTXCONF_XFREE430
AMULE_AUTOCONF += --x-includes=$(CROSS_LIB_DIR)/include
AMULE_AUTOCONF += --x-libraries=$(CROSS_LIB_DIR)/lib
endif

$(STATEDIR)/aMule.prepare: $(aMule_prepare_deps)
	@$(call targetinfo, $@)
	@$(call clean, $(AMULE_DIR)/config.cache)
	cd $(AMULE_DIR) && \
		$(AMULE_PATH) $(AMULE_ENV) \
		./configure $(AMULE_AUTOCONF)
	touch $@

# ----------------------------------------------------------------------------
# Compile
# ----------------------------------------------------------------------------

aMule_compile: $(STATEDIR)/aMule.compile

aMule_compile_deps = $(STATEDIR)/aMule.prepare

$(STATEDIR)/aMule.compile: $(aMule_compile_deps)
	@$(call targetinfo, $@)
	$(AMULE_PATH) $(MAKE) -C $(AMULE_DIR)
	touch $@

# ----------------------------------------------------------------------------
# Install
# ----------------------------------------------------------------------------

aMule_install: $(STATEDIR)/aMule.install

$(STATEDIR)/aMule.install: $(STATEDIR)/aMule.compile
	@$(call targetinfo, $@)
	touch $@

# ----------------------------------------------------------------------------
# Target-Install
# ----------------------------------------------------------------------------

aMule_targetinstall: $(STATEDIR)/aMule.targetinstall

aMule_targetinstall_deps = $(STATEDIR)/aMule.compile \
	$(STATEDIR)/gd.targetinstall \
	$(STATEDIR)/wxWidgets.targetinstall \
	$(STATEDIR)/curl.targetinstall

$(STATEDIR)/aMule.targetinstall: $(aMule_targetinstall_deps)
	@$(call targetinfo, $@)
	$(AMULE_PATH) $(MAKE) -C $(AMULE_DIR) DESTDIR=$(AMULE_IPKG_TMP) install
	rm -rf $(AMULE_IPKG_TMP)/usr/share/locale
	rm -rf $(AMULE_IPKG_TMP)/usr/share/doc
	$(CROSSSTRIP) $(AMULE_IPKG_TMP)/usr/bin/*
	mkdir -p $(AMULE_IPKG_TMP)/CONTROL
	echo "Package: amule" 											 >$(AMULE_IPKG_TMP)/CONTROL/control
	echo "Priority: optional" 										>>$(AMULE_IPKG_TMP)/CONTROL/control
	echo "Section: Internet" 										>>$(AMULE_IPKG_TMP)/CONTROL/control
	echo "Maintainer: Alexander Chukov <sash@pdaXrom.org>" 							>>$(AMULE_IPKG_TMP)/CONTROL/control
	echo "Architecture: $(SHORT_TARGET)" 									>>$(AMULE_IPKG_TMP)/CONTROL/control
	echo "Version: $(AMULE_VERSION)-$(AMULE_VENDOR_VERSION)" 						>>$(AMULE_IPKG_TMP)/CONTROL/control
	echo "Depends: libgd, wxwidgets, libcurl" 								>>$(AMULE_IPKG_TMP)/CONTROL/control
	echo "Description: eMule p2p client"									>>$(AMULE_IPKG_TMP)/CONTROL/control
	cd $(FEEDDIR) && $(XMKIPKG) $(AMULE_IPKG_TMP)
	touch $@

# ----------------------------------------------------------------------------
# Image-Install
# ----------------------------------------------------------------------------

ifdef PTXCONF_AMULE_INSTALL
ROMPACKAGES += $(STATEDIR)/aMule.imageinstall
endif

aMule_imageinstall_deps = $(STATEDIR)/aMule.targetinstall \
	$(STATEDIR)/virtual-image.install

$(STATEDIR)/aMule.imageinstall: $(aMule_imageinstall_deps)
	@$(call targetinfo, $@)
	cd $(FEEDDIR) && $(XIPKG) install amule
	touch $@

# ----------------------------------------------------------------------------
# Clean
# ----------------------------------------------------------------------------

aMule_clean:
	rm -rf $(STATEDIR)/aMule.*
	rm -rf $(AMULE_DIR)

# vim: syntax=make
