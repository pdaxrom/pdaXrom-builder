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
ifdef PTXCONF_WRAPPERS
PACKAGES += Wrappers
endif

#
# Paths and names
#
WRAPPERS_VERSION	= 1.0.3
WRAPPERS		= Wrappers-$(WRAPPERS_VERSION)
WRAPPERS_SUFFIX		= tgz
WRAPPERS_URL		= http://heanet.dl.sourceforge.net/sourceforge/rox/$(WRAPPERS).$(WRAPPERS_SUFFIX)
WRAPPERS_SOURCE		= $(SRCDIR)/$(WRAPPERS).$(WRAPPERS_SUFFIX)
WRAPPERS_DIR		= $(BUILDDIR)/$(WRAPPERS)
WRAPPERS_IPKG_TMP	= $(WRAPPERS_DIR)/ipkg_tmp

# ----------------------------------------------------------------------------
# Get
# ----------------------------------------------------------------------------

Wrappers_get: $(STATEDIR)/Wrappers.get

Wrappers_get_deps = $(WRAPPERS_SOURCE)

$(STATEDIR)/Wrappers.get: $(Wrappers_get_deps)
	@$(call targetinfo, $@)
	@$(call get_patches, $(WRAPPERS))
	touch $@

$(WRAPPERS_SOURCE):
	@$(call targetinfo, $@)
	@$(call get, $(WRAPPERS_URL))

# ----------------------------------------------------------------------------
# Extract
# ----------------------------------------------------------------------------

Wrappers_extract: $(STATEDIR)/Wrappers.extract

Wrappers_extract_deps = $(STATEDIR)/Wrappers.get

$(STATEDIR)/Wrappers.extract: $(Wrappers_extract_deps)
	@$(call targetinfo, $@)
	@$(call clean, $(WRAPPERS_DIR))
	@$(call extract, $(WRAPPERS_SOURCE))
	@$(call patchin, $(WRAPPERS))
	touch $@

# ----------------------------------------------------------------------------
# Prepare
# ----------------------------------------------------------------------------

Wrappers_prepare: $(STATEDIR)/Wrappers.prepare

#
# dependencies
#
Wrappers_prepare_deps = \
	$(STATEDIR)/Wrappers.extract \
	$(STATEDIR)/virtual-xchain.install

WRAPPERS_PATH	=  PATH=$(CROSS_PATH)
WRAPPERS_ENV 	=  $(CROSS_ENV)
#WRAPPERS_ENV	+=
WRAPPERS_ENV	+= PKG_CONFIG_PATH=$(CROSS_LIB_DIR)/lib/pkgconfig:$(CROSS_LIB_DIR)/lib/pkgconfig
#ifdef PTXCONF_XFREE430
#WRAPPERS_ENV	+= LDFLAGS=-Wl,-rpath-link,$(CROSS_LIB_DIR)/lib
#endif

#
# autoconf
#
WRAPPERS_AUTOCONF = \
	--build=$(GNU_HOST) \
	--host=$(PTXCONF_GNU_TARGET) \
	--prefix=/usr

ifdef PTXCONF_XFREE430
WRAPPERS_AUTOCONF += --x-includes=$(CROSS_LIB_DIR)/include
WRAPPERS_AUTOCONF += --x-libraries=$(CROSS_LIB_DIR)/lib
endif

$(STATEDIR)/Wrappers.prepare: $(Wrappers_prepare_deps)
	@$(call targetinfo, $@)
	@$(call clean, $(WRAPPERS_DIR)/config.cache)
	cd $(WRAPPERS_DIR) && \
		$(WRAPPERS_PATH) $(WRAPPERS_ENV) \
		./configure $(WRAPPERS_AUTOCONF)
	touch $@

# ----------------------------------------------------------------------------
# Compile
# ----------------------------------------------------------------------------

Wrappers_compile: $(STATEDIR)/Wrappers.compile

Wrappers_compile_deps = $(STATEDIR)/Wrappers.prepare

$(STATEDIR)/Wrappers.compile: $(Wrappers_compile_deps)
	@$(call targetinfo, $@)
	$(WRAPPERS_PATH) $(MAKE) -C $(WRAPPERS_DIR)
	touch $@

# ----------------------------------------------------------------------------
# Install
# ----------------------------------------------------------------------------

Wrappers_install: $(STATEDIR)/Wrappers.install

$(STATEDIR)/Wrappers.install: $(STATEDIR)/Wrappers.compile
	@$(call targetinfo, $@)
	$(WRAPPERS_PATH) $(MAKE) -C $(WRAPPERS_DIR) install
	touch $@

# ----------------------------------------------------------------------------
# Target-Install
# ----------------------------------------------------------------------------

Wrappers_targetinstall: $(STATEDIR)/Wrappers.targetinstall

Wrappers_targetinstall_deps = $(STATEDIR)/Wrappers.compile

$(STATEDIR)/Wrappers.targetinstall: $(Wrappers_targetinstall_deps)
	@$(call targetinfo, $@)
	$(WRAPPERS_PATH) $(MAKE) -C $(WRAPPERS_DIR) DESTDIR=$(WRAPPERS_IPKG_TMP) install
	mkdir -p $(WRAPPERS_IPKG_TMP)/CONTROL
	echo "Package: wrappers" 			>$(WRAPPERS_IPKG_TMP)/CONTROL/control
	echo "Priority: optional" 			>>$(WRAPPERS_IPKG_TMP)/CONTROL/control
	echo "Section: pdaXrom" 			>>$(WRAPPERS_IPKG_TMP)/CONTROL/control
	echo "Maintainer: Alexander Chukov <sash@pdaXrom.org>" 			>>$(WRAPPERS_IPKG_TMP)/CONTROL/control
	echo "Architecture: $(SHORT_TARGET)" 		>>$(WRAPPERS_IPKG_TMP)/CONTROL/control
	echo "Version: $(WRAPPERS_VERSION)" 		>>$(WRAPPERS_IPKG_TMP)/CONTROL/control
	echo "Depends: " 				>>$(WRAPPERS_IPKG_TMP)/CONTROL/control
	echo "Description: generated with pdaXrom builder">>$(WRAPPERS_IPKG_TMP)/CONTROL/control
	cd $(FEEDDIR) && $(XMKIPKG) $(WRAPPERS_IPKG_TMP)
	touch $@

# ----------------------------------------------------------------------------
# Image-Install
# ----------------------------------------------------------------------------

ifdef PTXCONF_WRAPPERS_INSTALL
ROMPACKAGES += $(STATEDIR)/Wrappers.imageinstall
endif

Wrappers_imageinstall_deps = $(STATEDIR)/Wrappers.targetinstall \
	$(STATEDIR)/virtual-image.install

$(STATEDIR)/Wrappers.imageinstall: $(Wrappers_imageinstall_deps)
	@$(call targetinfo, $@)
	cd $(FEEDDIR) && $(XIPKG) install wrappers
	touch $@

# ----------------------------------------------------------------------------
# Clean
# ----------------------------------------------------------------------------

Wrappers_clean:
	rm -rf $(STATEDIR)/Wrappers.*
	rm -rf $(WRAPPERS_DIR)

# vim: syntax=make
