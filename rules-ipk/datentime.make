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
ifdef PTXCONF_DATENTIME
PACKAGES += datentime
endif

#
# Paths and names
#
DATENTIME_VENDOR_VERSION	= 1
DATENTIME_VERSION		= 1.0.6
DATENTIME			= datentime-$(DATENTIME_VERSION)
DATENTIME_SUFFIX		= tar.bz2
DATENTIME_URL			= http://www.pdaXrom.org/src/$(DATENTIME).$(DATENTIME_SUFFIX)
DATENTIME_SOURCE		= $(SRCDIR)/$(DATENTIME).$(DATENTIME_SUFFIX)
DATENTIME_DIR			= $(BUILDDIR)/$(DATENTIME)
DATENTIME_IPKG_TMP		= $(DATENTIME_DIR)

# ----------------------------------------------------------------------------
# Get
# ----------------------------------------------------------------------------

datentime_get: $(STATEDIR)/datentime.get

datentime_get_deps = $(DATENTIME_SOURCE)

$(STATEDIR)/datentime.get: $(datentime_get_deps)
	@$(call targetinfo, $@)
	@$(call get_patches, $(DATENTIME))
	touch $@

$(DATENTIME_SOURCE):
	@$(call targetinfo, $@)
	@$(call get, $(DATENTIME_URL))

# ----------------------------------------------------------------------------
# Extract
# ----------------------------------------------------------------------------

datentime_extract: $(STATEDIR)/datentime.extract

datentime_extract_deps = $(STATEDIR)/datentime.get

$(STATEDIR)/datentime.extract: $(datentime_extract_deps)
	@$(call targetinfo, $@)
	@$(call clean, $(DATENTIME_DIR))
	@$(call extract, $(DATENTIME_SOURCE))
	@$(call patchin, $(DATENTIME))
	touch $@

# ----------------------------------------------------------------------------
# Prepare
# ----------------------------------------------------------------------------

datentime_prepare: $(STATEDIR)/datentime.prepare

#
# dependencies
#
datentime_prepare_deps = \
	$(STATEDIR)/datentime.extract \
	$(STATEDIR)/pygtk.install \
	$(STATEDIR)/virtual-xchain.install

DATENTIME_PATH	=  PATH=$(CROSS_PATH)
DATENTIME_ENV 	=  $(CROSS_ENV)
#DATENTIME_ENV	+=
DATENTIME_ENV	+= PKG_CONFIG_PATH=$(CROSS_LIB_DIR)/lib/pkgconfig:$(CROSS_LIB_DIR)/lib/pkgconfig
#ifdef PTXCONF_XFREE430
#DATENTIME_ENV	+= LDFLAGS=-Wl,-rpath-link,$(CROSS_LIB_DIR)/lib
#endif

#
# autoconf
#
DATENTIME_AUTOCONF = \
	--build=$(GNU_HOST) \
	--host=$(PTXCONF_GNU_TARGET) \
	--prefix=/usr

ifdef PTXCONF_XFREE430
DATENTIME_AUTOCONF += --x-includes=$(CROSS_LIB_DIR)/include
DATENTIME_AUTOCONF += --x-libraries=$(CROSS_LIB_DIR)/lib
endif

$(STATEDIR)/datentime.prepare: $(datentime_prepare_deps)
	@$(call targetinfo, $@)
	@$(call clean, $(DATENTIME_DIR)/config.cache)
	touch $@

# ----------------------------------------------------------------------------
# Compile
# ----------------------------------------------------------------------------

datentime_compile: $(STATEDIR)/datentime.compile

datentime_compile_deps = $(STATEDIR)/datentime.prepare

$(STATEDIR)/datentime.compile: $(datentime_compile_deps)
	@$(call targetinfo, $@)
	touch $@

# ----------------------------------------------------------------------------
# Install
# ----------------------------------------------------------------------------

datentime_install: $(STATEDIR)/datentime.install

$(STATEDIR)/datentime.install: $(STATEDIR)/datentime.compile
	@$(call targetinfo, $@)
	touch $@

# ----------------------------------------------------------------------------
# Target-Install
# ----------------------------------------------------------------------------

datentime_targetinstall: $(STATEDIR)/datentime.targetinstall

datentime_targetinstall_deps = $(STATEDIR)/datentime.compile \
	$(STATEDIR)/dbus.targetinstall \
	$(STATEDIR)/pygtk.targetinstall

$(STATEDIR)/datentime.targetinstall: $(datentime_targetinstall_deps)
	@$(call targetinfo, $@)
	mkdir -p $(DATENTIME_IPKG_TMP)/CONTROL
	echo "Package: datentime" 						>$(DATENTIME_IPKG_TMP)/CONTROL/control
	echo "Priority: optional" 						>>$(DATENTIME_IPKG_TMP)/CONTROL/control
	echo "Section: X11"				 			>>$(DATENTIME_IPKG_TMP)/CONTROL/control
	echo "Maintainer: Mikkel Skovgaard <laze@pdaxrom.org>" 			>>$(DATENTIME_IPKG_TMP)/CONTROL/control
	echo "Architecture: $(SHORT_TARGET)" 					>>$(DATENTIME_IPKG_TMP)/CONTROL/control
	echo "Version: $(DATENTIME_VERSION)-$(DATENTIME_VENDOR_VERSION)" 	>>$(DATENTIME_IPKG_TMP)/CONTROL/control
	echo "Depends: pygtk, python-core, python-codecs, python-dbus, python-fcntl, python-io, python-math, python-stringold, python-xml" >>$(DATENTIME_IPKG_TMP)/CONTROL/control
	echo "Description: Date & Time settings"				>>$(DATENTIME_IPKG_TMP)/CONTROL/control
	cd $(FEEDDIR) && $(XMKIPKG) $(DATENTIME_IPKG_TMP)
	touch $@

# ----------------------------------------------------------------------------
# Image-Install
# ----------------------------------------------------------------------------

ifdef PTXCONF_DATENTIME_INSTALL
ROMPACKAGES += $(STATEDIR)/datentime.imageinstall
endif

datentime_imageinstall_deps = $(STATEDIR)/datentime.targetinstall \
	$(STATEDIR)/virtual-image.install

$(STATEDIR)/datentime.imageinstall: $(datentime_imageinstall_deps)
	@$(call targetinfo, $@)
	cd $(FEEDDIR) && $(XIPKG) install datentime
	touch $@

# ----------------------------------------------------------------------------
# Clean
# ----------------------------------------------------------------------------

datentime_clean:
	rm -rf $(STATEDIR)/datentime.*
	rm -rf $(DATENTIME_DIR)

# vim: syntax=make
