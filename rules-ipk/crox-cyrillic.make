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
ifdef PTXCONF_CROX-CYRILLIC
PACKAGES += crox-cyrillic
endif

#
# Paths and names
#
CROX-CYRILLIC_VERSION		= 1.0.0
CROX-CYRILLIC			= crox-cyrillic
CROX-CYRILLIC_SUFFIX		= tar.bz2
CROX-CYRILLIC_URL		= http://www.pdaXrom.org/src/$(CROX-CYRILLIC).$(CROX-CYRILLIC_SUFFIX)
CROX-CYRILLIC_SOURCE		= $(SRCDIR)/$(CROX-CYRILLIC).$(CROX-CYRILLIC_SUFFIX)
CROX-CYRILLIC_DIR		= $(BUILDDIR)/$(CROX-CYRILLIC)
CROX-CYRILLIC_IPKG_TMP		= $(CROX-CYRILLIC_DIR)

# ----------------------------------------------------------------------------
# Get
# ----------------------------------------------------------------------------

crox-cyrillic_get: $(STATEDIR)/crox-cyrillic.get

crox-cyrillic_get_deps = $(CROX-CYRILLIC_SOURCE)

$(STATEDIR)/crox-cyrillic.get: $(crox-cyrillic_get_deps)
	@$(call targetinfo, $@)
	@$(call get_patches, $(CROX-CYRILLIC))
	touch $@

$(CROX-CYRILLIC_SOURCE):
	@$(call targetinfo, $@)
	@$(call get, $(CROX-CYRILLIC_URL))

# ----------------------------------------------------------------------------
# Extract
# ----------------------------------------------------------------------------

crox-cyrillic_extract: $(STATEDIR)/crox-cyrillic.extract

crox-cyrillic_extract_deps = $(STATEDIR)/crox-cyrillic.get

$(STATEDIR)/crox-cyrillic.extract: $(crox-cyrillic_extract_deps)
	@$(call targetinfo, $@)
	@$(call clean, $(CROX-CYRILLIC_DIR))
	@$(call extract, $(CROX-CYRILLIC_SOURCE))
	@$(call patchin, $(CROX-CYRILLIC))
	touch $@

# ----------------------------------------------------------------------------
# Prepare
# ----------------------------------------------------------------------------

crox-cyrillic_prepare: $(STATEDIR)/crox-cyrillic.prepare

#
# dependencies
#
crox-cyrillic_prepare_deps = \
	$(STATEDIR)/crox-cyrillic.extract \
	$(STATEDIR)/virtual-xchain.install

CROX-CYRILLIC_PATH	=  PATH=$(CROSS_PATH)
CROX-CYRILLIC_ENV 	=  $(CROSS_ENV)
#CROX-CYRILLIC_ENV	+=
CROX-CYRILLIC_ENV	+= PKG_CONFIG_PATH=$(CROSS_LIB_DIR)/lib/pkgconfig:$(CROSS_LIB_DIR)/lib/pkgconfig
#ifdef PTXCONF_XFREE430
#CROX-CYRILLIC_ENV	+= LDFLAGS=-Wl,-rpath-link,$(CROSS_LIB_DIR)/lib
#endif

#
# autoconf
#
CROX-CYRILLIC_AUTOCONF = \
	--build=$(GNU_HOST) \
	--host=$(PTXCONF_GNU_TARGET) \
	--prefix=/usr

ifdef PTXCONF_XFREE430
CROX-CYRILLIC_AUTOCONF += --x-includes=$(CROSS_LIB_DIR)/include
CROX-CYRILLIC_AUTOCONF += --x-libraries=$(CROSS_LIB_DIR)/lib
endif

$(STATEDIR)/crox-cyrillic.prepare: $(crox-cyrillic_prepare_deps)
	@$(call targetinfo, $@)
	@$(call clean, $(CROX-CYRILLIC_DIR)/config.cache)
	touch $@

# ----------------------------------------------------------------------------
# Compile
# ----------------------------------------------------------------------------

crox-cyrillic_compile: $(STATEDIR)/crox-cyrillic.compile

crox-cyrillic_compile_deps = $(STATEDIR)/crox-cyrillic.prepare

$(STATEDIR)/crox-cyrillic.compile: $(crox-cyrillic_compile_deps)
	@$(call targetinfo, $@)
	touch $@

# ----------------------------------------------------------------------------
# Install
# ----------------------------------------------------------------------------

crox-cyrillic_install: $(STATEDIR)/crox-cyrillic.install

$(STATEDIR)/crox-cyrillic.install: $(STATEDIR)/crox-cyrillic.compile
	@$(call targetinfo, $@)
	touch $@

# ----------------------------------------------------------------------------
# Target-Install
# ----------------------------------------------------------------------------

crox-cyrillic_targetinstall: $(STATEDIR)/crox-cyrillic.targetinstall

crox-cyrillic_targetinstall_deps = $(STATEDIR)/crox-cyrillic.compile

$(STATEDIR)/crox-cyrillic.targetinstall: $(crox-cyrillic_targetinstall_deps)
	@$(call targetinfo, $@)
	mkdir -p $(CROX-CYRILLIC_IPKG_TMP)/CONTROL
	echo "Package: crox-cyrillic" 				>$(CROX-CYRILLIC_IPKG_TMP)/CONTROL/control
	echo "Priority: optional" 				>>$(CROX-CYRILLIC_IPKG_TMP)/CONTROL/control
	echo "Section: X11"	 				>>$(CROX-CYRILLIC_IPKG_TMP)/CONTROL/control
	echo "Maintainer: Alexander Chukov <sash@pdaXrom.org>" 	>>$(CROX-CYRILLIC_IPKG_TMP)/CONTROL/control
	echo "Architecture: $(SHORT_TARGET)" 			>>$(CROX-CYRILLIC_IPKG_TMP)/CONTROL/control
	echo "Version: $(CROX-CYRILLIC_VERSION)" 		>>$(CROX-CYRILLIC_IPKG_TMP)/CONTROL/control
	echo "Depends: xfree430" 				>>$(CROX-CYRILLIC_IPKG_TMP)/CONTROL/control
	echo "Description: X11 Crox KOI-8R fonts"		>>$(CROX-CYRILLIC_IPKG_TMP)/CONTROL/control
	echo "#!/bin/sh"					 >$(CROX-CYRILLIC_IPKG_TMP)/CONTROL/postinst
	echo "if [ \$$DISPLAY ]; then"				>>$(CROX-CYRILLIC_IPKG_TMP)/CONTROL/postinst
	echo " xset fp+ /usr/X11R6/lib/X11/fonts/misc"		>>$(CROX-CYRILLIC_IPKG_TMP)/CONTROL/postinst
	echo "fi"						>>$(CROX-CYRILLIC_IPKG_TMP)/CONTROL/postinst
	chmod 755 $(CROX-CYRILLIC_IPKG_TMP)/CONTROL/postinst
	cd $(FEEDDIR) && $(XMKIPKG) $(CROX-CYRILLIC_IPKG_TMP)
	touch $@

# ----------------------------------------------------------------------------
# Image-Install
# ----------------------------------------------------------------------------

ifdef PTXCONF_CROX-CYRILLIC_INSTALL
ROMPACKAGES += $(STATEDIR)/crox-cyrillic.imageinstall
endif

crox-cyrillic_imageinstall_deps = $(STATEDIR)/crox-cyrillic.targetinstall \
	$(STATEDIR)/virtual-image.install

$(STATEDIR)/crox-cyrillic.imageinstall: $(crox-cyrillic_imageinstall_deps)
	@$(call targetinfo, $@)
	cd $(FEEDDIR) && $(XIPKG) install crox-cyrillic
	touch $@

# ----------------------------------------------------------------------------
# Clean
# ----------------------------------------------------------------------------

crox-cyrillic_clean:
	rm -rf $(STATEDIR)/crox-cyrillic.*
	rm -rf $(CROX-CYRILLIC_DIR)

# vim: syntax=make
