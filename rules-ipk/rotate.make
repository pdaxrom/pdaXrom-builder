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
ifdef PTXCONF_ROTATE
PACKAGES += rotate
endif

#
# Paths and names
#
ROTATE_VERSION		= 1.0.0
ROTATE			= rotate-$(ROTATE_VERSION)
ROTATE_SUFFIX		= tar.bz2
ROTATE_URL		= http://www.pdaXrom.org/src/$(ROTATE).$(ROTATE_SUFFIX)
ROTATE_SOURCE		= $(SRCDIR)/$(ROTATE).$(ROTATE_SUFFIX)
ROTATE_DIR		= $(BUILDDIR)/$(ROTATE)
ROTATE_IPKG_TMP		= $(ROTATE_DIR)/ipkg_tmp

# ----------------------------------------------------------------------------
# Get
# ----------------------------------------------------------------------------

rotate_get: $(STATEDIR)/rotate.get

rotate_get_deps = $(ROTATE_SOURCE)

$(STATEDIR)/rotate.get: $(rotate_get_deps)
	@$(call targetinfo, $@)
	@$(call get_patches, $(ROTATE))
	touch $@

$(ROTATE_SOURCE):
	@$(call targetinfo, $@)
	@$(call get, $(ROTATE_URL))

# ----------------------------------------------------------------------------
# Extract
# ----------------------------------------------------------------------------

rotate_extract: $(STATEDIR)/rotate.extract

rotate_extract_deps = $(STATEDIR)/rotate.get

$(STATEDIR)/rotate.extract: $(rotate_extract_deps)
	@$(call targetinfo, $@)
	@$(call clean, $(ROTATE_DIR))
	@$(call extract, $(ROTATE_SOURCE))
	@$(call patchin, $(ROTATE))
	touch $@

# ----------------------------------------------------------------------------
# Prepare
# ----------------------------------------------------------------------------

rotate_prepare: $(STATEDIR)/rotate.prepare

#
# dependencies
#
rotate_prepare_deps = \
	$(STATEDIR)/rotate.extract \
	$(STATEDIR)/virtual-xchain.install

ROTATE_PATH	=  PATH=$(CROSS_PATH)
ROTATE_ENV 	=  $(CROSS_ENV)
#ROTATE_ENV	+=
ROTATE_ENV	+= PKG_CONFIG_PATH=$(CROSS_LIB_DIR)/lib/pkgconfig:$(CROSS_LIB_DIR)/lib/pkgconfig
#ifdef PTXCONF_XFREE430
#ROTATE_ENV	+= LDFLAGS=-Wl,-rpath-link,$(CROSS_LIB_DIR)/lib
#endif

#
# autoconf
#
ROTATE_AUTOCONF = \
	--build=$(GNU_HOST) \
	--host=$(PTXCONF_GNU_TARGET) \
	--prefix=/usr

ifdef PTXCONF_XFREE430
ROTATE_AUTOCONF += --x-includes=$(CROSS_LIB_DIR)/include
ROTATE_AUTOCONF += --x-libraries=$(CROSS_LIB_DIR)/lib
endif

$(STATEDIR)/rotate.prepare: $(rotate_prepare_deps)
	@$(call targetinfo, $@)
	@$(call clean, $(ROTATE_DIR)/config.cache)
	touch $@

# ----------------------------------------------------------------------------
# Compile
# ----------------------------------------------------------------------------

rotate_compile: $(STATEDIR)/rotate.compile

rotate_compile_deps = $(STATEDIR)/rotate.prepare

$(STATEDIR)/rotate.compile: $(rotate_compile_deps)
	@$(call targetinfo, $@)
	touch $@

# ----------------------------------------------------------------------------
# Install
# ----------------------------------------------------------------------------

rotate_install: $(STATEDIR)/rotate.install

$(STATEDIR)/rotate.install: $(STATEDIR)/rotate.compile
	@$(call targetinfo, $@)
	touch $@

# ----------------------------------------------------------------------------
# Target-Install
# ----------------------------------------------------------------------------

rotate_targetinstall: $(STATEDIR)/rotate.targetinstall

rotate_targetinstall_deps = $(STATEDIR)/rotate.compile

$(STATEDIR)/rotate.targetinstall: $(rotate_targetinstall_deps)
	@$(call targetinfo, $@)
	cd $(FEEDDIR) && $(XMKIPKG) $(ROTATE_DIR)
	touch $@

# ----------------------------------------------------------------------------
# Image-Install
# ----------------------------------------------------------------------------

ifdef PTXCONF_ROTATE_INSTALL
ROMPACKAGES += $(STATEDIR)/rotate.imageinstall
endif

rotate_imageinstall_deps = $(STATEDIR)/rotate.targetinstall \
	$(STATEDIR)/virtual-image.install

$(STATEDIR)/rotate.imageinstall: $(rotate_imageinstall_deps)
	@$(call targetinfo, $@)
	cd $(FEEDDIR) && $(XIPKG) install rotate
	touch $@

# ----------------------------------------------------------------------------
# Clean
# ----------------------------------------------------------------------------

rotate_clean:
	rm -rf $(STATEDIR)/rotate.*
	rm -rf $(ROTATE_DIR)

# vim: syntax=make
