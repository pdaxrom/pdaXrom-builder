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
ifdef PTXCONF_FLEX
PACKAGES += flex
endif

#
# Paths and names
#
#FLEX_VERSION	= 2.5.4a
#FLEX		= flex-$(FLEX_VERSION)
#FLEX_SUFFIX	= tar.gz
#FLEX_URL	= ftp://ftp.gnu.org/non-gnu/flex/$(FLEX).$(FLEX_SUFFIX)
#FLEX_SOURCE	= $(XCHAIN_FLEX254_SOURCE)
FLEX_DIR	= $(BUILDDIR)/$(XCHAIN_FLEX254)
FLEX_IPKG_TMP	= $(FLEX_DIR)/ipkg_tmp

# ----------------------------------------------------------------------------
# Get
# ----------------------------------------------------------------------------

flex_get: $(STATEDIR)/flex.get

flex_get_deps = $(FLEX_SOURCE)

$(STATEDIR)/flex.get: $(flex_get_deps)
	@$(call targetinfo, $@)
	@$(call get_patches, $(XCHAIN_FLEX254))
	touch $@

$(FLEX_SOURCE):
	@$(call targetinfo, $@)
	@$(call get, $(XCHAIN_FLEX254_URL))

# ----------------------------------------------------------------------------
# Extract
# ----------------------------------------------------------------------------

flex_extract: $(STATEDIR)/flex.extract

flex_extract_deps = $(STATEDIR)/flex.get

$(STATEDIR)/flex.extract: $(flex_extract_deps)
	@$(call targetinfo, $@)
	@$(call clean, $(XCHAIN_FLEX254_DIR))
	@$(call extract, $(XCHAIN_FLEX254_SOURCE))
	@$(call patchin, $(XCHAIN_FLEX254))
	touch $@

# ----------------------------------------------------------------------------
# Prepare
# ----------------------------------------------------------------------------

flex_prepare: $(STATEDIR)/flex.prepare

#
# dependencies
#
flex_prepare_deps = \
	$(STATEDIR)/flex.extract \
	$(STATEDIR)/virtual-xchain.install

FLEX_PATH	=  PATH=$(CROSS_PATH)
FLEX_ENV 	=  $(CROSS_ENV)
#FLEX_ENV	+=
FLEX_ENV	+= PKG_CONFIG_PATH=$(CROSS_LIB_DIR)/lib/pkgconfig:$(CROSS_LIB_DIR)/lib/pkgconfig
#ifdef PTXCONF_XFREE430
#FLEX_ENV	+= LDFLAGS=-Wl,-rpath-link,$(CROSS_LIB_DIR)/lib
#endif

#
# autoconf
#
FLEX_AUTOCONF = \
	--build=$(GNU_HOST) \
	--host=$(PTXCONF_GNU_TARGET) \
	--prefix=$(PTXCONF_NATIVE_PREFIX)

ifdef PTXCONF_XFREE430
FLEX_AUTOCONF += --x-includes=$(CROSS_LIB_DIR)/include
FLEX_AUTOCONF += --x-libraries=$(CROSS_LIB_DIR)/lib
endif

$(STATEDIR)/flex.prepare: $(flex_prepare_deps)
	@$(call targetinfo, $@)
	@$(call clean, $(FLEX_DIR)/config.cache)
	cd $(FLEX_DIR) && \
		$(FLEX_PATH) $(FLEX_ENV) \
		./configure $(FLEX_AUTOCONF)
	touch $@

# ----------------------------------------------------------------------------
# Compile
# ----------------------------------------------------------------------------

flex_compile: $(STATEDIR)/flex.compile

flex_compile_deps = $(STATEDIR)/flex.prepare

$(STATEDIR)/flex.compile: $(flex_compile_deps)
	@$(call targetinfo, $@)
	$(FLEX_PATH) $(MAKE) -C $(FLEX_DIR)
	touch $@

# ----------------------------------------------------------------------------
# Install
# ----------------------------------------------------------------------------

flex_install: $(STATEDIR)/flex.install

$(STATEDIR)/flex.install: $(STATEDIR)/flex.compile
	@$(call targetinfo, $@)
	###$(FLEX_PATH) $(MAKE) -C $(FLEX_DIR) install
	cp -f $(FLEX_DIR)/FlexLexer.h 	$(CROSS_LIB_DIR)/include
	cp -f $(FLEX_DIR)/libfl.a 	$(CROSS_LIB_DIR)/lib
	touch $@

# ----------------------------------------------------------------------------
# Target-Install
# ----------------------------------------------------------------------------

flex_targetinstall: $(STATEDIR)/flex.targetinstall

flex_targetinstall_deps = $(STATEDIR)/flex.compile

$(STATEDIR)/flex.targetinstall: $(flex_targetinstall_deps)
	@$(call targetinfo, $@)
	$(FLEX_PATH) $(MAKE) -C $(FLEX_DIR) prefix=$(FLEX_IPKG_TMP)$(PTXCONF_NATIVE_PREFIX) install
	$(CROSSSTRIP) $(FLEX_IPKG_TMP)$(PTXCONF_NATIVE_PREFIX)/bin/flex
	rm -rf $(FLEX_IPKG_TMP)$(PTXCONF_NATIVE_PREFIX)/man
	mkdir -p $(FLEX_IPKG_TMP)/CONTROL
	echo "Package: flex" 				>$(FLEX_IPKG_TMP)/CONTROL/control
	echo "Priority: optional" 			>>$(FLEX_IPKG_TMP)/CONTROL/control
	echo "Section: Utils" 				>>$(FLEX_IPKG_TMP)/CONTROL/control
	echo "Maintainer: Alexander Chukov <sash@pdaXrom.org>">>$(FLEX_IPKG_TMP)/CONTROL/control
	echo "Architecture: $(SHORT_TARGET)" 		>>$(FLEX_IPKG_TMP)/CONTROL/control
	echo "Version: $(XCHAIN_FLEX254_VERSION)" 	>>$(FLEX_IPKG_TMP)/CONTROL/control
	echo "Depends: " 				>>$(FLEX_IPKG_TMP)/CONTROL/control
	echo "Description: fast lexical analyzer generator.">>$(FLEX_IPKG_TMP)/CONTROL/control
	cd $(FEEDDIR) && $(XMKIPKG) $(FLEX_IPKG_TMP)
	touch $@

# ----------------------------------------------------------------------------
# Image-Install
# ----------------------------------------------------------------------------

ifdef PTXCONF_FLEX_INSTALL
ROMPACKAGES += $(STATEDIR)/flex.imageinstall
endif

flex_imageinstall_deps = $(STATEDIR)/flex.targetinstall \
	$(STATEDIR)/virtual-image.install

$(STATEDIR)/flex.imageinstall: $(flex_imageinstall_deps)
	@$(call targetinfo, $@)
	cd $(FEEDDIR) && $(XIPKG) install flex
	touch $@

# ----------------------------------------------------------------------------
# Clean
# ----------------------------------------------------------------------------

flex_clean:
	rm -rf $(STATEDIR)/flex.*
	rm -rf $(FLEX_DIR)

# vim: syntax=make
