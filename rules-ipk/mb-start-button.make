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
ifdef PTXCONF_MB-START-BUTTON
PACKAGES += mb-start-button
endif

#
# Paths and names
#
MB-START-BUTTON_VERSION		= 0.0.1
MB-START-BUTTON			= mb-start-button-$(MB-START-BUTTON_VERSION)
MB-START-BUTTON_SUFFIX		= tar.bz2
MB-START-BUTTON_URL		= http://www.pdaXrom.org/src/$(MB-START-BUTTON).$(MB-START-BUTTON_SUFFIX)
MB-START-BUTTON_SOURCE		= $(SRCDIR)/$(MB-START-BUTTON).$(MB-START-BUTTON_SUFFIX)
MB-START-BUTTON_DIR		= $(BUILDDIR)/$(MB-START-BUTTON)
MB-START-BUTTON_IPKG_TMP	= $(MB-START-BUTTON_DIR)/ipkg_tmp

# ----------------------------------------------------------------------------
# Get
# ----------------------------------------------------------------------------

mb-start-button_get: $(STATEDIR)/mb-start-button.get

mb-start-button_get_deps = $(MB-START-BUTTON_SOURCE)

$(STATEDIR)/mb-start-button.get: $(mb-start-button_get_deps)
	@$(call targetinfo, $@)
	@$(call get_patches, $(MB-START-BUTTON))
	touch $@

$(MB-START-BUTTON_SOURCE):
	@$(call targetinfo, $@)
	@$(call get, $(MB-START-BUTTON_URL))

# ----------------------------------------------------------------------------
# Extract
# ----------------------------------------------------------------------------

mb-start-button_extract: $(STATEDIR)/mb-start-button.extract

mb-start-button_extract_deps = $(STATEDIR)/mb-start-button.get

$(STATEDIR)/mb-start-button.extract: $(mb-start-button_extract_deps)
	@$(call targetinfo, $@)
	@$(call clean, $(MB-START-BUTTON_DIR))
	@$(call extract, $(MB-START-BUTTON_SOURCE))
	@$(call patchin, $(MB-START-BUTTON))
	touch $@

# ----------------------------------------------------------------------------
# Prepare
# ----------------------------------------------------------------------------

mb-start-button_prepare: $(STATEDIR)/mb-start-button.prepare

#
# dependencies
#
mb-start-button_prepare_deps = \
	$(STATEDIR)/mb-start-button.extract \
	$(STATEDIR)/xfree430.install \
	$(STATEDIR)/virtual-xchain.install

MB-START-BUTTON_PATH	=  PATH=$(CROSS_PATH)
MB-START-BUTTON_ENV 	=  $(CROSS_ENV)
#MB-START-BUTTON_ENV	+=
MB-START-BUTTON_ENV	+= PKG_CONFIG_PATH=$(CROSS_LIB_DIR)/lib/pkgconfig:$(CROSS_LIB_DIR)/lib/pkgconfig
ifdef PTXCONF_XFREE430
MB-START-BUTTON_ENV	+= CFLAGS="-O2 -s"
#MB-START-BUTTON_ENV	+= LDFLAGS="-L$(CROSS_LIB_DIR)/lib -Wl,-rpath-link,$(CROSS_LIB_DIR)/lib"
endif

#
# autoconf
#
MB-START-BUTTON_AUTOCONF = \
	--build=$(GNU_HOST) \
	--host=$(PTXCONF_GNU_TARGET) \
	--prefix=/usr

ifdef PTXCONF_XFREE430
MB-START-BUTTON_AUTOCONF += --x-includes=$(CROSS_LIB_DIR)/include
MB-START-BUTTON_AUTOCONF += --x-libraries=$(CROSS_LIB_DIR)/lib
endif

$(STATEDIR)/mb-start-button.prepare: $(mb-start-button_prepare_deps)
	@$(call targetinfo, $@)
	@$(call clean, $(MB-START-BUTTON_DIR)/config.cache)
	#cd $(MB-START-BUTTON_DIR) && \
	#	$(MB-START-BUTTON_PATH) $(MB-START-BUTTON_ENV) \
	#	./configure $(MB-START-BUTTON_AUTOCONF)
	touch $@

# ----------------------------------------------------------------------------
# Compile
# ----------------------------------------------------------------------------

mb-start-button_compile: $(STATEDIR)/mb-start-button.compile

mb-start-button_compile_deps = $(STATEDIR)/mb-start-button.prepare

$(STATEDIR)/mb-start-button.compile: $(mb-start-button_compile_deps)
	@$(call targetinfo, $@)
	$(MB-START-BUTTON_PATH) $(MB-START-BUTTON_ENV) $(MAKE) -C $(MB-START-BUTTON_DIR)
	touch $@

# ----------------------------------------------------------------------------
# Install
# ----------------------------------------------------------------------------

mb-start-button_install: $(STATEDIR)/mb-start-button.install

$(STATEDIR)/mb-start-button.install: $(STATEDIR)/mb-start-button.compile
	@$(call targetinfo, $@)
	touch $@

# ----------------------------------------------------------------------------
# Target-Install
# ----------------------------------------------------------------------------

mb-start-button_targetinstall: $(STATEDIR)/mb-start-button.targetinstall

mb-start-button_targetinstall_deps = $(STATEDIR)/mb-start-button.compile

$(STATEDIR)/mb-start-button.targetinstall: $(mb-start-button_targetinstall_deps)
	@$(call targetinfo, $@)
	mkdir -p $(MB-START-BUTTON_IPKG_TMP)/usr/bin
	cp -a $(MB-START-BUTTON_DIR)/mb-start-button $(MB-START-BUTTON_IPKG_TMP)/usr/bin
	mkdir -p $(MB-START-BUTTON_IPKG_TMP)/CONTROL
	echo "Package: mb-start-button" 					>$(MB-START-BUTTON_IPKG_TMP)/CONTROL/control
	echo "Priority: optional" 						>>$(MB-START-BUTTON_IPKG_TMP)/CONTROL/control
	echo "Section: Matchbox" 						>>$(MB-START-BUTTON_IPKG_TMP)/CONTROL/control
	echo "Maintainer: Alexander Chukov <sash@pdaXrom.org>" 			>>$(MB-START-BUTTON_IPKG_TMP)/CONTROL/control
	echo "Architecture: $(SHORT_TARGET)" 					>>$(MB-START-BUTTON_IPKG_TMP)/CONTROL/control
	echo "Version: $(MB-START-BUTTON_VERSION)" 				>>$(MB-START-BUTTON_IPKG_TMP)/CONTROL/control
	echo "Depends: xfree430" 						>>$(MB-START-BUTTON_IPKG_TMP)/CONTROL/control
	echo "Description: Send SHOW_MENU event to matchbox-panel"		>>$(MB-START-BUTTON_IPKG_TMP)/CONTROL/control
	cd $(FEEDDIR) && $(XMKIPKG) $(MB-START-BUTTON_IPKG_TMP)
	touch $@

# ----------------------------------------------------------------------------
# Image-Install
# ----------------------------------------------------------------------------

ifdef PTXCONF_MB-START-BUTTON_INSTALL
ROMPACKAGES += $(STATEDIR)/mb-start-button.imageinstall
endif

mb-start-button_imageinstall_deps = $(STATEDIR)/mb-start-button.targetinstall \
	$(STATEDIR)/virtual-image.install

$(STATEDIR)/mb-start-button.imageinstall: $(mb-start-button_imageinstall_deps)
	@$(call targetinfo, $@)
	cd $(FEEDDIR) && $(XIPKG) install mb-start-button
	touch $@

# ----------------------------------------------------------------------------
# Clean
# ----------------------------------------------------------------------------

mb-start-button_clean:
	rm -rf $(STATEDIR)/mb-start-button.*
	rm -rf $(MB-START-BUTTON_DIR)

# vim: syntax=make
