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
ifdef PTXCONF_PAGER
PACKAGES += Pager
endif

#
# Paths and names
#
PAGER_VERSION		= 1.0.0
PAGER			= pager-$(PAGER_VERSION)
PAGER_SUFFIX		= tgz
PAGER_URL		= http://heanet.dl.sourceforge.net/sourceforge/rox/$(PAGER).$(PAGER_SUFFIX)
PAGER_SOURCE		= $(SRCDIR)/$(PAGER).$(PAGER_SUFFIX)
PAGER_DIR		= $(BUILDDIR)/$(PAGER)
PAGER_IPKG_TMP		= $(PAGER_DIR)/ipkg_tmp

# ----------------------------------------------------------------------------
# Get
# ----------------------------------------------------------------------------

Pager_get: $(STATEDIR)/Pager.get

Pager_get_deps = $(PAGER_SOURCE)

$(STATEDIR)/Pager.get: $(Pager_get_deps)
	@$(call targetinfo, $@)
	@$(call get_patches, $(PAGER))
	touch $@

$(PAGER_SOURCE):
	@$(call targetinfo, $@)
	@$(call get, $(PAGER_URL))

# ----------------------------------------------------------------------------
# Extract
# ----------------------------------------------------------------------------

Pager_extract: $(STATEDIR)/Pager.extract

Pager_extract_deps = $(STATEDIR)/Pager.get

$(STATEDIR)/Pager.extract: $(Pager_extract_deps)
	@$(call targetinfo, $@)
	@$(call clean, $(PAGER_DIR))
	@$(call extract, $(PAGER_SOURCE))
	@$(call patchin, $(PAGER))
	touch $@

# ----------------------------------------------------------------------------
# Prepare
# ----------------------------------------------------------------------------

Pager_prepare: $(STATEDIR)/Pager.prepare

#
# dependencies
#
Pager_prepare_deps = \
	$(STATEDIR)/Pager.extract \
	$(STATEDIR)/virtual-xchain.install

PAGER_PATH	=  PATH=$(CROSS_PATH)
PAGER_ENV 	=  $(CROSS_ENV)
#PAGER_ENV	+=
PAGER_ENV	+= PKG_CONFIG_PATH=$(CROSS_LIB_DIR)/lib/pkgconfig:$(CROSS_LIB_DIR)/lib/pkgconfig
#ifdef PTXCONF_XFREE430
#PAGER_ENV	+= LDFLAGS=-Wl,-rpath-link,$(CROSS_LIB_DIR)/lib
#endif

#
# autoconf
#
PAGER_AUTOCONF = \
	--build=$(GNU_HOST) \
	--host=$(PTXCONF_GNU_TARGET) \
	--prefix=/usr

ifdef PTXCONF_XFREE430
PAGER_AUTOCONF += --x-includes=$(CROSS_LIB_DIR)/include
PAGER_AUTOCONF += --x-libraries=$(CROSS_LIB_DIR)/lib
endif

$(STATEDIR)/Pager.prepare: $(Pager_prepare_deps)
	@$(call targetinfo, $@)
	@$(call clean, $(PAGER_DIR)/config.cache)
	cd $(PAGER_DIR) && \
		$(PAGER_PATH) $(PAGER_ENV) \
		./configure $(PAGER_AUTOCONF)
	touch $@

# ----------------------------------------------------------------------------
# Compile
# ----------------------------------------------------------------------------

Pager_compile: $(STATEDIR)/Pager.compile

Pager_compile_deps = $(STATEDIR)/Pager.prepare

$(STATEDIR)/Pager.compile: $(Pager_compile_deps)
	@$(call targetinfo, $@)
	$(PAGER_PATH) $(MAKE) -C $(PAGER_DIR)
	touch $@

# ----------------------------------------------------------------------------
# Install
# ----------------------------------------------------------------------------

Pager_install: $(STATEDIR)/Pager.install

$(STATEDIR)/Pager.install: $(STATEDIR)/Pager.compile
	@$(call targetinfo, $@)
	$(PAGER_PATH) $(MAKE) -C $(PAGER_DIR) install
	touch $@

# ----------------------------------------------------------------------------
# Target-Install
# ----------------------------------------------------------------------------

Pager_targetinstall: $(STATEDIR)/Pager.targetinstall

Pager_targetinstall_deps = $(STATEDIR)/Pager.compile

$(STATEDIR)/Pager.targetinstall: $(Pager_targetinstall_deps)
	@$(call targetinfo, $@)
	$(PAGER_PATH) $(MAKE) -C $(PAGER_DIR) DESTDIR=$(PAGER_IPKG_TMP) install
	mkdir -p $(PAGER_IPKG_TMP)/CONTROL
	echo "Package: pager" 				>$(PAGER_IPKG_TMP)/CONTROL/control
	echo "Priority: optional" 			>>$(PAGER_IPKG_TMP)/CONTROL/control
	echo "Section: ROX"	 			>>$(PAGER_IPKG_TMP)/CONTROL/control
	echo "Maintainer: Alexander Chukov <sash@pdaXrom.org>">>$(PAGER_IPKG_TMP)/CONTROL/control
	echo "Architecture: $(SHORT_TARGET)" 		>>$(PAGER_IPKG_TMP)/CONTROL/control
	echo "Version: $(PAGER_VERSION)" 		>>$(PAGER_IPKG_TMP)/CONTROL/control
	echo "Depends: " 				>>$(PAGER_IPKG_TMP)/CONTROL/control
	echo "Description: ">>$(PAGER_IPKG_TMP)/CONTROL/control
	sdfsdf
	cd $(FEEDDIR) && $(XMKIPKG) $(PAGER_IPKG_TMP)
	touch $@

# ----------------------------------------------------------------------------
# Image-Install
# ----------------------------------------------------------------------------

ifdef PTXCONF_PAGER_INSTALL
ROMPACKAGES += $(STATEDIR)/Pager.imageinstall
endif

Pager_imageinstall_deps = $(STATEDIR)/Pager.targetinstall \
	$(STATEDIR)/virtual-image.install

$(STATEDIR)/Pager.imageinstall: $(Pager_imageinstall_deps)
	@$(call targetinfo, $@)
	cd $(FEEDDIR) && $(XIPKG) install pager
	touch $@

# ----------------------------------------------------------------------------
# Clean
# ----------------------------------------------------------------------------

Pager_clean:
	rm -rf $(STATEDIR)/Pager.*
	rm -rf $(PAGER_DIR)

# vim: syntax=make
