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
ifdef PTXCONF_ROX-LIB
PACKAGES += rox-lib
endif

#
# Paths and names
#
ROX-LIB_VERSION		= 1.9.15
ROX-LIB			= rox-lib-$(ROX-LIB_VERSION)
ROX-LIB_SUFFIX		= tgz
ROX-LIB_URL		= http://heanet.dl.sourceforge.net/sourceforge/rox/$(ROX-LIB).$(ROX-LIB_SUFFIX)
ROX-LIB_SOURCE		= $(SRCDIR)/$(ROX-LIB).$(ROX-LIB_SUFFIX)
ROX-LIB_DIR		= $(BUILDDIR)/$(ROX-LIB)
ROX-LIB_IPKG_TMP	= $(ROX-LIB_DIR)/ipkg_tmp

# ----------------------------------------------------------------------------
# Get
# ----------------------------------------------------------------------------

rox-lib_get: $(STATEDIR)/rox-lib.get

rox-lib_get_deps = $(ROX-LIB_SOURCE)

$(STATEDIR)/rox-lib.get: $(rox-lib_get_deps)
	@$(call targetinfo, $@)
	@$(call get_patches, $(ROX-LIB))
	touch $@

$(ROX-LIB_SOURCE):
	@$(call targetinfo, $@)
	@$(call get, $(ROX-LIB_URL))

# ----------------------------------------------------------------------------
# Extract
# ----------------------------------------------------------------------------

rox-lib_extract: $(STATEDIR)/rox-lib.extract

rox-lib_extract_deps = $(STATEDIR)/rox-lib.get

$(STATEDIR)/rox-lib.extract: $(rox-lib_extract_deps)
	@$(call targetinfo, $@)
	@$(call clean, $(ROX-LIB_DIR))
	@$(call extract, $(ROX-LIB_SOURCE))
	@$(call patchin, $(ROX-LIB))
	touch $@

# ----------------------------------------------------------------------------
# Prepare
# ----------------------------------------------------------------------------

rox-lib_prepare: $(STATEDIR)/rox-lib.prepare

#
# dependencies
#
rox-lib_prepare_deps = \
	$(STATEDIR)/rox-lib.extract \
	$(STATEDIR)/virtual-xchain.install

ROX-LIB_PATH	=  PATH=$(CROSS_PATH)
ROX-LIB_ENV 	=  $(CROSS_ENV)
#ROX-LIB_ENV	+=
ROX-LIB_ENV	+= PKG_CONFIG_PATH=$(CROSS_LIB_DIR)/lib/pkgconfig:$(CROSS_LIB_DIR)/lib/pkgconfig
#ifdef PTXCONF_XFREE430
#ROX-LIB_ENV	+= LDFLAGS=-Wl,-rpath-link,$(CROSS_LIB_DIR)/lib
#endif

#
# autoconf
#
ROX-LIB_AUTOCONF = \
	--build=$(GNU_HOST) \
	--host=$(PTXCONF_GNU_TARGET)

ifdef PTXCONF_XFREE430
ROX-LIB_AUTOCONF += --x-includes=$(CROSS_LIB_DIR)/include
ROX-LIB_AUTOCONF += --x-libraries=$(CROSS_LIB_DIR)/lib
endif

$(STATEDIR)/rox-lib.prepare: $(rox-lib_prepare_deps)
	@$(call targetinfo, $@)
	@$(call clean, $(ROX-LIB_DIR)/config.cache)
	touch $@

# ----------------------------------------------------------------------------
# Compile
# ----------------------------------------------------------------------------

rox-lib_compile: $(STATEDIR)/rox-lib.compile

rox-lib_compile_deps = $(STATEDIR)/rox-lib.prepare

$(STATEDIR)/rox-lib.compile: $(rox-lib_compile_deps)
	@$(call targetinfo, $@)
	touch $@

# ----------------------------------------------------------------------------
# Install
# ----------------------------------------------------------------------------

rox-lib_install: $(STATEDIR)/rox-lib.install

$(STATEDIR)/rox-lib.install: $(STATEDIR)/rox-lib.compile
	@$(call targetinfo, $@)
	touch $@

# ----------------------------------------------------------------------------
# Target-Install
# ----------------------------------------------------------------------------

rox-lib_targetinstall: $(STATEDIR)/rox-lib.targetinstall

rox-lib_targetinstall_deps = $(STATEDIR)/rox-lib.compile

$(STATEDIR)/rox-lib.targetinstall: $(rox-lib_targetinstall_deps)
	@$(call targetinfo, $@)
	mkdir -p $(ROX-LIB_IPKG_TMP)/usr/lib
	cp -a $(ROX-LIB_DIR)/ROX-Lib2 $(ROX-LIB_IPKG_TMP)/usr/lib
	rm -rf $(ROX-LIB_IPKG_TMP)/usr/lib/ROX-Lib2/Messages/*
	mkdir -p $(ROX-LIB_IPKG_TMP)/CONTROL
	echo "Package: rox-lib" 			>$(ROX-LIB_IPKG_TMP)/CONTROL/control
	echo "Priority: optional" 			>>$(ROX-LIB_IPKG_TMP)/CONTROL/control
	echo "Section: ROX"	 			>>$(ROX-LIB_IPKG_TMP)/CONTROL/control
	echo "Maintainer: Alexander Chukov <sash@pdaXrom.org>">>$(ROX-LIB_IPKG_TMP)/CONTROL/control
	echo "Architecture: $(SHORT_TARGET)" 		>>$(ROX-LIB_IPKG_TMP)/CONTROL/control
	echo "Version: $(ROX-LIB_VERSION)" 		>>$(ROX-LIB_IPKG_TMP)/CONTROL/control
	echo "Depends: " 				>>$(ROX-LIB_IPKG_TMP)/CONTROL/control
	echo "Description: Shared library for ROX"	>>$(ROX-LIB_IPKG_TMP)/CONTROL/control
	cd $(FEEDDIR) && $(XMKIPKG) $(ROX-LIB_IPKG_TMP)
	touch $@

# ----------------------------------------------------------------------------
# Image-Install
# ----------------------------------------------------------------------------

ifdef PTXCONF_ROX-LIB_INSTALL
ROMPACKAGES += $(STATEDIR)/rox-lib.imageinstall
endif

rox-lib_imageinstall_deps = $(STATEDIR)/rox-lib.targetinstall \
	$(STATEDIR)/virtual-image.install

$(STATEDIR)/rox-lib.imageinstall: $(rox-lib_imageinstall_deps)
	@$(call targetinfo, $@)
	cd $(FEEDDIR) && $(XIPKG) install rox-lib
	touch $@

# ----------------------------------------------------------------------------
# Clean
# ----------------------------------------------------------------------------

rox-lib_clean:
	rm -rf $(STATEDIR)/rox-lib.*
	rm -rf $(ROX-LIB_DIR)

# vim: syntax=make
