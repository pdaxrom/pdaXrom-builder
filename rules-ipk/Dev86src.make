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
ifdef PTXCONF_DEV86SRC
PACKAGES += Dev86src
endif

#
# Paths and names
#
DEV86SRC_VERSION	= 0.16.16
DEV86SRC		= Dev86src-$(DEV86SRC_VERSION)
DEV86SRC_SUFFIX		= tar.gz
DEV86SRC_URL		= http://www.cix.co.uk/~mayday/dev86/$(DEV86SRC).$(DEV86SRC_SUFFIX)
DEV86SRC_SOURCE		= $(SRCDIR)/$(DEV86SRC).$(DEV86SRC_SUFFIX)
DEV86SRC_DIR		= $(BUILDDIR)/$(DEV86SRC)
DEV86SRC_IPKG_TMP	= $(DEV86SRC_DIR)/ipkg_tmp

# ----------------------------------------------------------------------------
# Get
# ----------------------------------------------------------------------------

Dev86src_get: $(STATEDIR)/Dev86src.get

Dev86src_get_deps = $(DEV86SRC_SOURCE)

$(STATEDIR)/Dev86src.get: $(Dev86src_get_deps)
	@$(call targetinfo, $@)
	@$(call get_patches, $(DEV86SRC))
	touch $@

$(DEV86SRC_SOURCE):
	@$(call targetinfo, $@)
	@$(call get, $(DEV86SRC_URL))

# ----------------------------------------------------------------------------
# Extract
# ----------------------------------------------------------------------------

Dev86src_extract: $(STATEDIR)/Dev86src.extract

Dev86src_extract_deps = $(STATEDIR)/Dev86src.get

$(STATEDIR)/Dev86src.extract: $(Dev86src_extract_deps)
	@$(call targetinfo, $@)
	@$(call clean, $(DEV86SRC_DIR))
	@$(call extract, $(DEV86SRC_SOURCE))
	@$(call patchin, $(DEV86SRC))
	touch $@

# ----------------------------------------------------------------------------
# Prepare
# ----------------------------------------------------------------------------

Dev86src_prepare: $(STATEDIR)/Dev86src.prepare

#
# dependencies
#
Dev86src_prepare_deps = \
	$(STATEDIR)/Dev86src.extract \
	$(STATEDIR)/virtual-xchain.install

DEV86SRC_PATH	=  PATH=$(CROSS_PATH)
DEV86SRC_ENV 	=  $(CROSS_ENV)
#DEV86SRC_ENV	+=
DEV86SRC_ENV	+= PKG_CONFIG_PATH=$(CROSS_LIB_DIR)/lib/pkgconfig:$(CROSS_LIB_DIR)/lib/pkgconfig
#ifdef PTXCONF_XFREE430
#DEV86SRC_ENV	+= LDFLAGS=-Wl,-rpath-link,$(CROSS_LIB_DIR)/lib
#endif

#
# autoconf
#
DEV86SRC_AUTOCONF = \
	--build=$(GNU_HOST) \
	--host=$(PTXCONF_GNU_TARGET) \
	--prefix=/usr

ifdef PTXCONF_XFREE430
DEV86SRC_AUTOCONF += --x-includes=$(CROSS_LIB_DIR)/include
DEV86SRC_AUTOCONF += --x-libraries=$(CROSS_LIB_DIR)/lib
endif

$(STATEDIR)/Dev86src.prepare: $(Dev86src_prepare_deps)
	@$(call targetinfo, $@)
	@$(call clean, $(DEV86SRC_DIR)/config.cache)
	cd $(DEV86SRC_DIR) && \
		$(DEV86SRC_PATH) $(DEV86SRC_ENV) \
		./configure $(DEV86SRC_AUTOCONF)
	touch $@

# ----------------------------------------------------------------------------
# Compile
# ----------------------------------------------------------------------------

Dev86src_compile: $(STATEDIR)/Dev86src.compile

Dev86src_compile_deps = $(STATEDIR)/Dev86src.prepare

$(STATEDIR)/Dev86src.compile: $(Dev86src_compile_deps)
	@$(call targetinfo, $@)
	$(DEV86SRC_PATH) $(MAKE) -C $(DEV86SRC_DIR)
	touch $@

# ----------------------------------------------------------------------------
# Install
# ----------------------------------------------------------------------------

Dev86src_install: $(STATEDIR)/Dev86src.install

$(STATEDIR)/Dev86src.install: $(STATEDIR)/Dev86src.compile
	@$(call targetinfo, $@)
	$(DEV86SRC_PATH) $(MAKE) -C $(DEV86SRC_DIR) install
	touch $@

# ----------------------------------------------------------------------------
# Target-Install
# ----------------------------------------------------------------------------

Dev86src_targetinstall: $(STATEDIR)/Dev86src.targetinstall

Dev86src_targetinstall_deps = $(STATEDIR)/Dev86src.compile

$(STATEDIR)/Dev86src.targetinstall: $(Dev86src_targetinstall_deps)
	@$(call targetinfo, $@)
	$(DEV86SRC_PATH) $(MAKE) -C $(DEV86SRC_DIR) DESTDIR=$(DEV86SRC_IPKG_TMP) install
	mkdir -p $(DEV86SRC_IPKG_TMP)/CONTROL
	echo "Package: dev86src" 			>$(DEV86SRC_IPKG_TMP)/CONTROL/control
	echo "Priority: optional" 			>>$(DEV86SRC_IPKG_TMP)/CONTROL/control
	echo "Section: pdaXrom" 			>>$(DEV86SRC_IPKG_TMP)/CONTROL/control
	echo "Maintainer: Alexander Chukov <sash@pdaXrom.org>" 			>>$(DEV86SRC_IPKG_TMP)/CONTROL/control
	echo "Architecture: $(SHORT_TARGET)" 		>>$(DEV86SRC_IPKG_TMP)/CONTROL/control
	echo "Version: $(DEV86SRC_VERSION)" 		>>$(DEV86SRC_IPKG_TMP)/CONTROL/control
	echo "Depends: " 				>>$(DEV86SRC_IPKG_TMP)/CONTROL/control
	echo "Description: generated with pdaXrom builder">>$(DEV86SRC_IPKG_TMP)/CONTROL/control
	cd $(FEEDDIR) && $(XMKIPKG) $(DEV86SRC_IPKG_TMP)
	touch $@

# ----------------------------------------------------------------------------
# Image-Install
# ----------------------------------------------------------------------------

ifdef PTXCONF_DEV86SRC_INSTALL
ROMPACKAGES += $(STATEDIR)/Dev86src.imageinstall
endif

Dev86src_imageinstall_deps = $(STATEDIR)/Dev86src.targetinstall \
	$(STATEDIR)/virtual-image.install

$(STATEDIR)/Dev86src.imageinstall: $(Dev86src_imageinstall_deps)
	@$(call targetinfo, $@)
	cd $(FEEDDIR) && $(XIPKG) install dev86src
	touch $@

# ----------------------------------------------------------------------------
# Clean
# ----------------------------------------------------------------------------

Dev86src_clean:
	rm -rf $(STATEDIR)/Dev86src.*
	rm -rf $(DEV86SRC_DIR)

# vim: syntax=make
