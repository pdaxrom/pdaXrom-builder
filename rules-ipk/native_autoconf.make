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
ifdef PTXCONF_NATIVE_AUTOCONF
PACKAGES += native_autoconf
endif

#
# Paths and names
#
NATIVE_AUTOCONF_VENDOR_VERSION	= 1
NATIVE_AUTOCONF_VERSION		= 2.59
NATIVE_AUTOCONF			= $(AUTOCONF257)
NATIVE_AUTOCONF_DIR		= $(BUILDDIR)/$(NATIVE_AUTOCONF)
NATIVE_AUTOCONF_IPKG_TMP	= $(NATIVE_AUTOCONF_DIR)/ipkg_tmp

# ----------------------------------------------------------------------------
# Get
# ----------------------------------------------------------------------------

native_autoconf_get: $(STATEDIR)/native_autoconf.get

native_autoconf_get_deps = $(NATIVE_AUTOCONF_SOURCE)

$(STATEDIR)/native_autoconf.get: $(native_autoconf_get_deps)
	@$(call targetinfo, $@)
	@$(call get_patches, $(AUTOCONF257))
	touch $@

$(NATIVE_AUTOCONF_SOURCE):
	@$(call targetinfo, $@)
	@$(call get, $(AUTOCONF257_URL))

# ----------------------------------------------------------------------------
# Extract
# ----------------------------------------------------------------------------

native_autoconf_extract: $(STATEDIR)/native_autoconf.extract

native_autoconf_extract_deps = $(STATEDIR)/native_autoconf.get

$(STATEDIR)/native_autoconf.extract: $(native_autoconf_extract_deps)
	@$(call targetinfo, $@)
	@$(call clean,   $(NATIVE_AUTOCONF_DIR))
	@$(call extract, $(AUTOCONF257_SOURCE))
	@$(call patchin, $(AUTOCONF257))
	touch $@

# ----------------------------------------------------------------------------
# Prepare
# ----------------------------------------------------------------------------

native_autoconf_prepare: $(STATEDIR)/native_autoconf.prepare

#
# dependencies
#
native_autoconf_prepare_deps = \
	$(STATEDIR)/native_autoconf.extract \
	$(STATEDIR)/virtual-xchain.install

NATIVE_AUTOCONF_PATH	=  PATH=$(CROSS_PATH)
NATIVE_AUTOCONF_ENV 	=  $(CROSS_ENV)
#NATIVE_AUTOCONF_ENV	+=
NATIVE_AUTOCONF_ENV	+= PKG_CONFIG_PATH=$(CROSS_LIB_DIR)/lib/pkgconfig:$(CROSS_LIB_DIR)/lib/pkgconfig
#ifdef PTXCONF_XFREE430
#NATIVE_AUTOCONF_ENV	+= LDFLAGS=-Wl,-rpath-link,$(CROSS_LIB_DIR)/lib
#endif

#
# autoconf
#
NATIVE_AUTOCONF_AUTOCONF = \
	--prefix=$(PTXCONF_NATIVE_PREFIX)

ifdef PTXCONF_XFREE430
NATIVE_AUTOCONF_AUTOCONF += --x-includes=$(CROSS_LIB_DIR)/include
NATIVE_AUTOCONF_AUTOCONF += --x-libraries=$(CROSS_LIB_DIR)/lib
endif

$(STATEDIR)/native_autoconf.prepare: $(native_autoconf_prepare_deps)
	@$(call targetinfo, $@)
	@$(call clean, $(NATIVE_AUTOCONF_DIR)/config.cache)
	cd $(NATIVE_AUTOCONF_DIR) && \
		$(NATIVE_AUTOCONF_PATH) $(NATIVE_AUTOCONF_ENV) \
		./configure $(NATIVE_AUTOCONF_AUTOCONF)
	touch $@

# ----------------------------------------------------------------------------
# Compile
# ----------------------------------------------------------------------------

native_autoconf_compile: $(STATEDIR)/native_autoconf.compile

native_autoconf_compile_deps = $(STATEDIR)/native_autoconf.prepare

$(STATEDIR)/native_autoconf.compile: $(native_autoconf_compile_deps)
	@$(call targetinfo, $@)
	$(NATIVE_AUTOCONF_PATH) $(MAKE) -C $(NATIVE_AUTOCONF_DIR)
	touch $@

# ----------------------------------------------------------------------------
# Install
# ----------------------------------------------------------------------------

native_autoconf_install: $(STATEDIR)/native_autoconf.install

$(STATEDIR)/native_autoconf.install: $(STATEDIR)/native_autoconf.compile
	@$(call targetinfo, $@)
	touch $@

# ----------------------------------------------------------------------------
# Target-Install
# ----------------------------------------------------------------------------

native_autoconf_targetinstall: $(STATEDIR)/native_autoconf.targetinstall

native_autoconf_targetinstall_deps = $(STATEDIR)/native_autoconf.compile

$(STATEDIR)/native_autoconf.targetinstall: $(native_autoconf_targetinstall_deps)
	@$(call targetinfo, $@)
	$(NATIVE_AUTOCONF_PATH) $(MAKE) -C $(NATIVE_AUTOCONF_DIR) DESTDIR=$(NATIVE_AUTOCONF_IPKG_TMP) install
	rm -rf $(NATIVE_AUTOCONF_IPKG_TMP)/$(PTXCONF_NATIVE_PREFIX)/{info,man}
	mkdir -p $(NATIVE_AUTOCONF_IPKG_TMP)/CONTROL
	echo "Package: autoconf" 								 >$(NATIVE_AUTOCONF_IPKG_TMP)/CONTROL/control
	echo "Priority: optional" 								>>$(NATIVE_AUTOCONF_IPKG_TMP)/CONTROL/control
	echo "Section: Development" 								>>$(NATIVE_AUTOCONF_IPKG_TMP)/CONTROL/control
	echo "Maintainer: Alexander Chukov <sash@pdaXrom.org>" 					>>$(NATIVE_AUTOCONF_IPKG_TMP)/CONTROL/control
	echo "Architecture: $(SHORT_TARGET)" 							>>$(NATIVE_AUTOCONF_IPKG_TMP)/CONTROL/control
	echo "Version: $(NATIVE_AUTOCONF_VERSION)-$(NATIVE_AUTOCONF_VENDOR_VERSION)" 		>>$(NATIVE_AUTOCONF_IPKG_TMP)/CONTROL/control
	echo "Depends: perl" 									>>$(NATIVE_AUTOCONF_IPKG_TMP)/CONTROL/control
	echo "Description: Autoconf is an extensible package of M4 macros that produce shell scripts to automatically configure software source code packages."	>>$(NATIVE_AUTOCONF_IPKG_TMP)/CONTROL/control
	cd $(FEEDDIR) && $(XMKIPKG) $(NATIVE_AUTOCONF_IPKG_TMP)
	touch $@

# ----------------------------------------------------------------------------
# Image-Install
# ----------------------------------------------------------------------------

ifdef PTXCONF_NATIVE_AUTOCONF_INSTALL
ROMPACKAGES += $(STATEDIR)/native_autoconf.imageinstall
endif

native_autoconf_imageinstall_deps = $(STATEDIR)/native_autoconf.targetinstall \
	$(STATEDIR)/virtual-image.install

$(STATEDIR)/native_autoconf.imageinstall: $(native_autoconf_imageinstall_deps)
	@$(call targetinfo, $@)
	cd $(FEEDDIR) && $(XIPKG) install autoconf
	touch $@

# ----------------------------------------------------------------------------
# Clean
# ----------------------------------------------------------------------------

native_autoconf_clean:
	rm -rf $(STATEDIR)/native_autoconf.*
	rm -rf $(NATIVE_AUTOCONF_DIR)

# vim: syntax=make
