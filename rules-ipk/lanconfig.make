# -*-makefile-*-
# $Id: template,v 1.10 2004/01/24 15:50:34 mkl Exp $
#
# Copyright (C) 2004 by Mikkel Skovgaard <laze@pdaxrom.org>
#          
# See CREDITS for details about who has contributed to this project.
#
# For further information about the PTXdist project and license conditions
# see the README file.
#

#
# We provide this package
#
ifdef PTXCONF_LANCONFIG
PACKAGES += lanconfig
endif

#
# Paths and names
#
LANCONFIG_VENDOR_VERSION	= 2
LANCONFIG_VERSION		= 1.0.7
LANCONFIG			= lanconfig-$(LANCONFIG_VERSION)
LANCONFIG_SUFFIX		= tar.bz2
LANCONFIG_URL			= http://www.pdaXrom.org/src/$(LANCONFIG).$(LANCONFIG_SUFFIX)
LANCONFIG_SOURCE		= $(SRCDIR)/$(LANCONFIG).$(LANCONFIG_SUFFIX)
LANCONFIG_DIR			= $(BUILDDIR)/$(LANCONFIG)
LANCONFIG_IPKG_TMP		= $(LANCONFIG_DIR)

# ----------------------------------------------------------------------------
# Get
# ----------------------------------------------------------------------------

lanconfig_get: $(STATEDIR)/lanconfig.get

lanconfig_get_deps = $(LANCONFIG_SOURCE)

$(STATEDIR)/lanconfig.get: $(lanconfig_get_deps)
	@$(call targetinfo, $@)
	@$(call get_patches, $(LANCONFIG))
	touch $@

$(LANCONFIG_SOURCE):
	@$(call targetinfo, $@)
	@$(call get, $(LANCONFIG_URL))

# ----------------------------------------------------------------------------
# Extract
# ----------------------------------------------------------------------------

lanconfig_extract: $(STATEDIR)/lanconfig.extract

lanconfig_extract_deps = $(STATEDIR)/lanconfig.get

$(STATEDIR)/lanconfig.extract: $(lanconfig_extract_deps)
	@$(call targetinfo, $@)
	@$(call clean, $(LANCONFIG_DIR))
	@$(call extract, $(LANCONFIG_SOURCE))
	@$(call patchin, $(LANCONFIG))
	touch $@

# ----------------------------------------------------------------------------
# Prepare
# ----------------------------------------------------------------------------

lanconfig_prepare: $(STATEDIR)/lanconfig.prepare

#
# dependencies
#
lanconfig_prepare_deps = \
	$(STATEDIR)/lanconfig.extract \
	$(STATEDIR)/pygtk.install \
	$(STATEDIR)/virtual-xchain.install

LANCONFIG_PATH	=  PATH=$(CROSS_PATH)
LANCONFIG_ENV 	=  $(CROSS_ENV)
#LANCONFIG_ENV	+=
LANCONFIG_ENV	+= PKG_CONFIG_PATH=$(CROSS_LIB_DIR)/lib/pkgconfig:$(CROSS_LIB_DIR)/lib/pkgconfig
#ifdef PTXCONF_XFREE430
#LANCONFIG_ENV	+= LDFLAGS=-Wl,-rpath-link,$(CROSS_LIB_DIR)/lib
#endif

#
# autoconf
#
LANCONFIG_AUTOCONF = \
	--build=$(GNU_HOST) \
	--host=$(PTXCONF_GNU_TARGET) \
	--prefix=/usr

ifdef PTXCONF_XFREE430
LANCONFIG_AUTOCONF += --x-includes=$(CROSS_LIB_DIR)/include
LANCONFIG_AUTOCONF += --x-libraries=$(CROSS_LIB_DIR)/lib
endif

$(STATEDIR)/lanconfig.prepare: $(lanconfig_prepare_deps)
	@$(call targetinfo, $@)
	@$(call clean, $(LANCONFIG_DIR)/config.cache)
	touch $@

# ----------------------------------------------------------------------------
# Compile
# ----------------------------------------------------------------------------

lanconfig_compile: $(STATEDIR)/lanconfig.compile

lanconfig_compile_deps = $(STATEDIR)/lanconfig.prepare

$(STATEDIR)/lanconfig.compile: $(lanconfig_compile_deps)
	@$(call targetinfo, $@)
	touch $@

# ----------------------------------------------------------------------------
# Install
# ----------------------------------------------------------------------------

lanconfig_install: $(STATEDIR)/lanconfig.install

$(STATEDIR)/lanconfig.install: $(STATEDIR)/lanconfig.compile
	@$(call targetinfo, $@)
	touch $@

# ----------------------------------------------------------------------------
# Target-Install
# ----------------------------------------------------------------------------

lanconfig_targetinstall: $(STATEDIR)/lanconfig.targetinstall

lanconfig_targetinstall_deps = $(STATEDIR)/lanconfig.compile \
	$(STATEDIR)/dbus.targetinstall \
	$(STATEDIR)/pygtk.targetinstall

$(STATEDIR)/lanconfig.targetinstall: $(lanconfig_targetinstall_deps)
	@$(call targetinfo, $@)
	mkdir -p $(LANCONFIG_IPKG_TMP)/CONTROL
	echo "Package: lanconfig" 						>$(LANCONFIG_IPKG_TMP)/CONTROL/control
	echo "Priority: optional" 						>>$(LANCONFIG_IPKG_TMP)/CONTROL/control
	echo "Section: X11"				 			>>$(LANCONFIG_IPKG_TMP)/CONTROL/control
	echo "Maintainer: Mikkel Skovgaard <laze@pdaxrom.org>" 			>>$(LANCONFIG_IPKG_TMP)/CONTROL/control
	echo "Architecture: $(SHORT_TARGET)" 					>>$(LANCONFIG_IPKG_TMP)/CONTROL/control
	echo "Version: $(LANCONFIG_VERSION)-$(LANCONFIG_VENDOR_VERSION)" 	>>$(LANCONFIG_IPKG_TMP)/CONTROL/control
	echo "Depends: pygtk, python-core, python-codecs, python-re, python-dbus, python-fcntl, python-io, python-math, python-stringold, python-xml" >>$(LANCONFIG_IPKG_TMP)/CONTROL/control
	echo "Description: NIC & WiFi settings tool"				>>$(LANCONFIG_IPKG_TMP)/CONTROL/control
	cd $(FEEDDIR) && $(XMKIPKG) $(LANCONFIG_IPKG_TMP)
	touch $@

# ----------------------------------------------------------------------------
# Image-Install
# ----------------------------------------------------------------------------

ifdef PTXCONF_LANCONFIG_INSTALL
ROMPACKAGES += $(STATEDIR)/lanconfig.imageinstall
endif

lanconfig_imageinstall_deps = $(STATEDIR)/lanconfig.targetinstall \
	$(STATEDIR)/virtual-image.install

$(STATEDIR)/lanconfig.imageinstall: $(lanconfig_imageinstall_deps)
	@$(call targetinfo, $@)
	cd $(FEEDDIR) && $(XIPKG) install lanconfig
	touch $@

# ----------------------------------------------------------------------------
# Clean
# ----------------------------------------------------------------------------

lanconfig_clean:
	rm -rf $(STATEDIR)/lanconfig.*
	rm -rf $(LANCONFIG_DIR)

# vim: syntax=make
