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
ifdef PTXCONF_INPUTCONFIG
PACKAGES += inputconfig
endif

#
# Paths and names
#
INPUTCONFIG_VENDOR_VERSION	= 3
INPUTCONFIG_VERSION		= 1.0.4
INPUTCONFIG			= inputconfig-$(INPUTCONFIG_VERSION)
INPUTCONFIG_SUFFIX		= tar.bz2
INPUTCONFIG_URL			= http://www.pdaXrom.org/src/$(INPUTCONFIG).$(INPUTCONFIG_SUFFIX)
INPUTCONFIG_SOURCE		= $(SRCDIR)/$(INPUTCONFIG).$(INPUTCONFIG_SUFFIX)
INPUTCONFIG_DIR			= $(BUILDDIR)/$(INPUTCONFIG)
INPUTCONFIG_IPKG_TMP		= $(INPUTCONFIG_DIR)

# ----------------------------------------------------------------------------
# Get
# ----------------------------------------------------------------------------

inputconfig_get: $(STATEDIR)/inputconfig.get

inputconfig_get_deps = $(INPUTCONFIG_SOURCE)

$(STATEDIR)/inputconfig.get: $(inputconfig_get_deps)
	@$(call targetinfo, $@)
	@$(call get_patches, $(INPUTCONFIG))
	touch $@

$(INPUTCONFIG_SOURCE):
	@$(call targetinfo, $@)
	@$(call get, $(INPUTCONFIG_URL))

# ----------------------------------------------------------------------------
# Extract
# ----------------------------------------------------------------------------

inputconfig_extract: $(STATEDIR)/inputconfig.extract

inputconfig_extract_deps = $(STATEDIR)/inputconfig.get

$(STATEDIR)/inputconfig.extract: $(inputconfig_extract_deps)
	@$(call targetinfo, $@)
	@$(call clean, $(INPUTCONFIG_DIR))
	@$(call extract, $(INPUTCONFIG_SOURCE))
	@$(call patchin, $(INPUTCONFIG))
	touch $@

# ----------------------------------------------------------------------------
# Prepare
# ----------------------------------------------------------------------------

inputconfig_prepare: $(STATEDIR)/inputconfig.prepare

#
# dependencies
#
inputconfig_prepare_deps = \
	$(STATEDIR)/inputconfig.extract \
	$(STATEDIR)/virtual-xchain.install

INPUTCONFIG_PATH	=  PATH=$(CROSS_PATH)
INPUTCONFIG_ENV 	=  $(CROSS_ENV)
#INPUTCONFIG_ENV	+=
INPUTCONFIG_ENV	+= PKG_CONFIG_PATH=$(CROSS_LIB_DIR)/lib/pkgconfig:$(CROSS_LIB_DIR)/lib/pkgconfig
#ifdef PTXCONF_XFREE430
#INPUTCONFIG_ENV	+= LDFLAGS=-Wl,-rpath-link,$(CROSS_LIB_DIR)/lib
#endif

#
# autoconf
#
INPUTCONFIG_AUTOCONF = \
	--build=$(GNU_HOST) \
	--host=$(PTXCONF_GNU_TARGET) \
	--prefix=/usr

ifdef PTXCONF_XFREE430
INPUTCONFIG_AUTOCONF += --x-includes=$(CROSS_LIB_DIR)/include
INPUTCONFIG_AUTOCONF += --x-libraries=$(CROSS_LIB_DIR)/lib
endif

$(STATEDIR)/inputconfig.prepare: $(inputconfig_prepare_deps)
	@$(call targetinfo, $@)
	@$(call clean, $(INPUTCONFIG_DIR)/config.cache)
	#cd $(INPUTCONFIG_DIR) && \
	#	$(INPUTCONFIG_PATH) $(INPUTCONFIG_ENV) \
	#	./configure $(INPUTCONFIG_AUTOCONF)
	touch $@

# ----------------------------------------------------------------------------
# Compile
# ----------------------------------------------------------------------------

inputconfig_compile: $(STATEDIR)/inputconfig.compile

inputconfig_compile_deps = $(STATEDIR)/inputconfig.prepare

$(STATEDIR)/inputconfig.compile: $(inputconfig_compile_deps)
	@$(call targetinfo, $@)
	#$(INPUTCONFIG_PATH) $(MAKE) -C $(INPUTCONFIG_DIR)
	touch $@

# ----------------------------------------------------------------------------
# Install
# ----------------------------------------------------------------------------

inputconfig_install: $(STATEDIR)/inputconfig.install

$(STATEDIR)/inputconfig.install: $(STATEDIR)/inputconfig.compile
	@$(call targetinfo, $@)
	#$(INPUTCONFIG_PATH) $(MAKE) -C $(INPUTCONFIG_DIR) install
	touch $@

# ----------------------------------------------------------------------------
# Target-Install
# ----------------------------------------------------------------------------

inputconfig_targetinstall: $(STATEDIR)/inputconfig.targetinstall

inputconfig_targetinstall_deps = $(STATEDIR)/inputconfig.compile

$(STATEDIR)/inputconfig.targetinstall: $(inputconfig_targetinstall_deps)
	@$(call targetinfo, $@)
	#$(INPUTCONFIG_PATH) $(MAKE) -C $(INPUTCONFIG_DIR) DESTDIR=$(INPUTCONFIG_IPKG_TMP) install
	mkdir -p $(INPUTCONFIG_IPKG_TMP)/CONTROL
	echo "Package: inputconfig" 									 >$(INPUTCONFIG_IPKG_TMP)/CONTROL/control
	echo "Priority: optional" 									>>$(INPUTCONFIG_IPKG_TMP)/CONTROL/control
	echo "Section: X11"			 							>>$(INPUTCONFIG_IPKG_TMP)/CONTROL/control
	echo "Maintainer: Mikkel Skovgaard <laze@pdaxrom.org>" 						>>$(INPUTCONFIG_IPKG_TMP)/CONTROL/control
	echo "Architecture: $(SHORT_TARGET)" 								>>$(INPUTCONFIG_IPKG_TMP)/CONTROL/control
	echo "Version: $(INPUTCONFIG_VERSION)-$(INPUTCONFIG_VENDOR_VERSION)" 				>>$(INPUTCONFIG_IPKG_TMP)/CONTROL/control
	echo "Depends: pygtk, python-core, python-codecs, python-dbus, python-fcntl, python-io, python-math, python-stringold, python-xml" >>$(INPUTCONFIG_IPKG_TMP)/CONTROL/control
	echo "Description:  Keyboard settings"								>>$(INPUTCONFIG_IPKG_TMP)/CONTROL/control
	cd $(FEEDDIR) && $(XMKIPKG) $(INPUTCONFIG_IPKG_TMP)
	touch $@

# ----------------------------------------------------------------------------
# Image-Install
# ----------------------------------------------------------------------------

ifdef PTXCONF_INPUTCONFIG_INSTALL
ROMPACKAGES += $(STATEDIR)/inputconfig.imageinstall
endif

inputconfig_imageinstall_deps = $(STATEDIR)/inputconfig.targetinstall \
	$(STATEDIR)/virtual-image.install

$(STATEDIR)/inputconfig.imageinstall: $(inputconfig_imageinstall_deps)
	@$(call targetinfo, $@)
	cd $(FEEDDIR) && $(XIPKG) install inputconfig
	touch $@

# ----------------------------------------------------------------------------
# Clean
# ----------------------------------------------------------------------------

inputconfig_clean:
	rm -rf $(STATEDIR)/inputconfig.*
	rm -rf $(INPUTCONFIG_DIR)

# vim: syntax=make
