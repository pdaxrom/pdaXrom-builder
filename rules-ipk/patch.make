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
ifdef PTXCONF_UPATCH
PACKAGES += upatch
endif

#
# Paths and names
#
UPATCH_VERSION	= 2.5.4
UPATCH		= patch-$(UPATCH_VERSION)
UPATCH_SUFFIX	= tar.gz
UPATCH_URL	= ftp://ftp.gnu.org/gnu/patch/$(UPATCH).$(UPATCH_SUFFIX)
UPATCH_SOURCE	= $(SRCDIR)/$(UPATCH).$(UPATCH_SUFFIX)
UPATCH_DIR	= $(BUILDDIR)/$(UPATCH)
UPATCH_IPKG_TMP	= $(UPATCH_DIR)/ipkg_tmp

# ----------------------------------------------------------------------------
# Get
# ----------------------------------------------------------------------------

upatch_get: $(STATEDIR)/upatch.get

upatch_get_deps = $(UPATCH_SOURCE)

$(STATEDIR)/upatch.get: $(upatch_get_deps)
	@$(call targetinfo, $@)
	@$(call get_upatches, $(UPATCH))
	touch $@

$(UPATCH_SOURCE):
	@$(call targetinfo, $@)
	@$(call get, $(UPATCH_URL))

# ----------------------------------------------------------------------------
# Extract
# ----------------------------------------------------------------------------

upatch_extract: $(STATEDIR)/upatch.extract

upatch_extract_deps = $(STATEDIR)/upatch.get

$(STATEDIR)/upatch.extract: $(upatch_extract_deps)
	@$(call targetinfo, $@)
	@$(call clean, $(UPATCH_DIR))
	@$(call extract, $(UPATCH_SOURCE))
	@$(call upatchin, $(UPATCH))
	touch $@

# ----------------------------------------------------------------------------
# Prepare
# ----------------------------------------------------------------------------

upatch_prepare: $(STATEDIR)/upatch.prepare

#
# dependencies
#
upatch_prepare_deps = \
	$(STATEDIR)/upatch.extract \
	$(STATEDIR)/virtual-xchain.install

UPATCH_PATH	=  PATH=$(CROSS_PATH)
UPATCH_ENV 	=  $(CROSS_ENV)
#UPATCH_ENV	+=
UPATCH_ENV	+= PKG_CONFIG_PATH=$(CROSS_LIB_DIR)/lib/pkgconfig:$(CROSS_LIB_DIR)/lib/pkgconfig
#ifdef PTXCONF_XFREE430
#UPATCH_ENV	+= LDFLAGS=-Wl,-rpath-link,$(CROSS_LIB_DIR)/lib
#endif

#
# autoconf
#
UPATCH_AUTOCONF = \
	--build=$(GNU_HOST) \
	--host=$(PTXCONF_GNU_TARGET) \
	--prefix=$(PTXCONF_NATIVE_PREFIX)

ifdef PTXCONF_XFREE430
UPATCH_AUTOCONF += --x-includes=$(CROSS_LIB_DIR)/include
UPATCH_AUTOCONF += --x-libraries=$(CROSS_LIB_DIR)/lib
endif

$(STATEDIR)/upatch.prepare: $(upatch_prepare_deps)
	@$(call targetinfo, $@)
	@$(call clean, $(UPATCH_DIR)/config.cache)
	cd $(UPATCH_DIR) && \
		$(UPATCH_PATH) $(UPATCH_ENV) \
		./configure $(UPATCH_AUTOCONF)
	touch $@

# ----------------------------------------------------------------------------
# Compile
# ----------------------------------------------------------------------------

upatch_compile: $(STATEDIR)/upatch.compile

upatch_compile_deps = $(STATEDIR)/upatch.prepare

$(STATEDIR)/upatch.compile: $(upatch_compile_deps)
	@$(call targetinfo, $@)
	$(UPATCH_PATH) $(MAKE) -C $(UPATCH_DIR)
	touch $@

# ----------------------------------------------------------------------------
# Install
# ----------------------------------------------------------------------------

upatch_install: $(STATEDIR)/upatch.install

$(STATEDIR)/upatch.install: $(STATEDIR)/upatch.compile
	@$(call targetinfo, $@)
	###$(UPATCH_PATH) $(MAKE) -C $(UPATCH_DIR) install
	touch $@

# ----------------------------------------------------------------------------
# Target-Install
# ----------------------------------------------------------------------------

upatch_targetinstall: $(STATEDIR)/upatch.targetinstall

upatch_targetinstall_deps = $(STATEDIR)/upatch.compile

$(STATEDIR)/upatch.targetinstall: $(upatch_targetinstall_deps)
	@$(call targetinfo, $@)
	$(UPATCH_PATH) $(MAKE) -C $(UPATCH_DIR) prefix=$(UPATCH_IPKG_TMP)$(PTXCONF_NATIVE_PREFIX) install
	$(CROSSSTRIP) $(UPATCH_IPKG_TMP)$(PTXCONF_NATIVE_PREFIX)/bin/patch
	rm -rf $(UPATCH_IPKG_TMP)$(PTXCONF_NATIVE_PREFIX)/man
	mkdir -p $(UPATCH_IPKG_TMP)/CONTROL
	echo "Package: patch" 				>$(UPATCH_IPKG_TMP)/CONTROL/control
	echo "Priority: optional" 			>>$(UPATCH_IPKG_TMP)/CONTROL/control
	echo "Section: Utils" 				>>$(UPATCH_IPKG_TMP)/CONTROL/control
	echo "Maintainer: Alexander Chukov <sash@pdaXrom.org>">>$(UPATCH_IPKG_TMP)/CONTROL/control
	echo "Architecture: $(SHORT_TARGET)" 		>>$(UPATCH_IPKG_TMP)/CONTROL/control
	echo "Version: $(UPATCH_VERSION)" 		>>$(UPATCH_IPKG_TMP)/CONTROL/control
	echo "Depends: " 				>>$(UPATCH_IPKG_TMP)/CONTROL/control
	echo "Description: apply a diff file to an original.">>$(UPATCH_IPKG_TMP)/CONTROL/control
	cd $(FEEDDIR) && $(XMKIPKG) $(UPATCH_IPKG_TMP)
	touch $@

# ----------------------------------------------------------------------------
# Image-Install
# ----------------------------------------------------------------------------

ifdef PTXCONF_UPATCH_INSTALL
ROMPACKAGES += $(STATEDIR)/upatch.imageinstall
endif

upatch_imageinstall_deps = $(STATEDIR)/upatch.targetinstall \
	$(STATEDIR)/virtual-image.install

$(STATEDIR)/upatch.imageinstall: $(upatch_imageinstall_deps)
	@$(call targetinfo, $@)
	cd $(FEEDDIR) && $(XIPKG) install patch
	touch $@

# ----------------------------------------------------------------------------
# Clean
# ----------------------------------------------------------------------------

upatch_clean:
	rm -rf $(STATEDIR)/upatch.*
	rm -rf $(UPATCH_DIR)

# vim: syntax=make
