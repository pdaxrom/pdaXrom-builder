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
ifdef PTXCONF_EJECT
PACKAGES += eject
endif

#
# Paths and names
#
EJECT_VENDOR_VERSION	= 1
EJECT_VERSION		= 2.0.13
EJECT			= eject-$(EJECT_VERSION)
EJECT_SUFFIX		= tar.gz
EJECT_URL		= http://www.ibiblio.org/pub/Linux/utils/disk-management/$(EJECT).$(EJECT_SUFFIX)
EJECT_SOURCE		= $(SRCDIR)/$(EJECT).$(EJECT_SUFFIX)
EJECT_DIR		= $(BUILDDIR)/$(EJECT)
EJECT_IPKG_TMP		= $(EJECT_DIR)/ipkg_tmp

# ----------------------------------------------------------------------------
# Get
# ----------------------------------------------------------------------------

eject_get: $(STATEDIR)/eject.get

eject_get_deps = $(EJECT_SOURCE)

$(STATEDIR)/eject.get: $(eject_get_deps)
	@$(call targetinfo, $@)
	@$(call get_patches, $(EJECT))
	touch $@

$(EJECT_SOURCE):
	@$(call targetinfo, $@)
	@$(call get, $(EJECT_URL))

# ----------------------------------------------------------------------------
# Extract
# ----------------------------------------------------------------------------

eject_extract: $(STATEDIR)/eject.extract

eject_extract_deps = $(STATEDIR)/eject.get

$(STATEDIR)/eject.extract: $(eject_extract_deps)
	@$(call targetinfo, $@)
	@$(call clean, $(EJECT_DIR))
	@$(call extract, $(EJECT_SOURCE))
	@$(call patchin, $(EJECT))
	touch $@

# ----------------------------------------------------------------------------
# Prepare
# ----------------------------------------------------------------------------

eject_prepare: $(STATEDIR)/eject.prepare

#
# dependencies
#
eject_prepare_deps = \
	$(STATEDIR)/eject.extract \
	$(STATEDIR)/virtual-xchain.install

EJECT_PATH	=  PATH=$(CROSS_PATH)
EJECT_ENV 	=  $(CROSS_ENV)
#EJECT_ENV	+=
EJECT_ENV	+= PKG_CONFIG_PATH=$(CROSS_LIB_DIR)/lib/pkgconfig:$(CROSS_LIB_DIR)/lib/pkgconfig
#ifdef PTXCONF_XFREE430
#EJECT_ENV	+= LDFLAGS=-Wl,-rpath-link,$(CROSS_LIB_DIR)/lib
#endif

#
# autoconf
#
EJECT_AUTOCONF = \
	--build=$(GNU_HOST) \
	--host=$(PTXCONF_GNU_TARGET) \
	--prefix=/usr

ifdef PTXCONF_XFREE430
EJECT_AUTOCONF += --x-includes=$(CROSS_LIB_DIR)/include
EJECT_AUTOCONF += --x-libraries=$(CROSS_LIB_DIR)/lib
endif

$(STATEDIR)/eject.prepare: $(eject_prepare_deps)
	@$(call targetinfo, $@)
	@$(call clean, $(EJECT_DIR)/config.cache)
	cd $(EJECT_DIR) && \
		$(EJECT_PATH) $(EJECT_ENV) \
		./configure $(EJECT_AUTOCONF)
	touch $@

# ----------------------------------------------------------------------------
# Compile
# ----------------------------------------------------------------------------

eject_compile: $(STATEDIR)/eject.compile

eject_compile_deps = $(STATEDIR)/eject.prepare

$(STATEDIR)/eject.compile: $(eject_compile_deps)
	@$(call targetinfo, $@)
	$(EJECT_PATH) $(MAKE) -C $(EJECT_DIR)
	touch $@

# ----------------------------------------------------------------------------
# Install
# ----------------------------------------------------------------------------

eject_install: $(STATEDIR)/eject.install

$(STATEDIR)/eject.install: $(STATEDIR)/eject.compile
	@$(call targetinfo, $@)
	touch $@

# ----------------------------------------------------------------------------
# Target-Install
# ----------------------------------------------------------------------------

eject_targetinstall: $(STATEDIR)/eject.targetinstall

eject_targetinstall_deps = $(STATEDIR)/eject.compile

$(STATEDIR)/eject.targetinstall: $(eject_targetinstall_deps)
	@$(call targetinfo, $@)
	$(EJECT_PATH) $(MAKE) -C $(EJECT_DIR) DESTDIR=$(EJECT_IPKG_TMP) install
	rm -rf $(EJECT_IPKG_TMP)/usr/man
	rm -rf $(EJECT_IPKG_TMP)/usr/share/locale
	$(CROSSSTRIP) $(EJECT_IPKG_TMP)/usr/bin/*
	mkdir -p $(EJECT_IPKG_TMP)/CONTROL
	echo "Package: eject" 								 >$(EJECT_IPKG_TMP)/CONTROL/control
	echo "Priority: optional" 							>>$(EJECT_IPKG_TMP)/CONTROL/control
	echo "Section: Utilities" 							>>$(EJECT_IPKG_TMP)/CONTROL/control
	echo "Maintainer: Alexander Chukov <sash@pdaXrom.org>" 				>>$(EJECT_IPKG_TMP)/CONTROL/control
	echo "Architecture: $(SHORT_TARGET)" 						>>$(EJECT_IPKG_TMP)/CONTROL/control
	echo "Version: $(EJECT_VERSION)-$(EJECT_VENDOR_VERSION)" 			>>$(EJECT_IPKG_TMP)/CONTROL/control
	echo "Depends: " 								>>$(EJECT_IPKG_TMP)/CONTROL/control
	echo "Description: CD insert/eject utility"					>>$(EJECT_IPKG_TMP)/CONTROL/control
	cd $(FEEDDIR) && $(XMKIPKG) $(EJECT_IPKG_TMP)
	touch $@

# ----------------------------------------------------------------------------
# Image-Install
# ----------------------------------------------------------------------------

ifdef PTXCONF_EJECT_INSTALL
ROMPACKAGES += $(STATEDIR)/eject.imageinstall
endif

eject_imageinstall_deps = $(STATEDIR)/eject.targetinstall \
	$(STATEDIR)/virtual-image.install

$(STATEDIR)/eject.imageinstall: $(eject_imageinstall_deps)
	@$(call targetinfo, $@)
	cd $(FEEDDIR) && $(XIPKG) install eject
	touch $@

# ----------------------------------------------------------------------------
# Clean
# ----------------------------------------------------------------------------

eject_clean:
	rm -rf $(STATEDIR)/eject.*
	rm -rf $(EJECT_DIR)

# vim: syntax=make
