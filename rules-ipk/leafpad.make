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
ifdef PTXCONF_LEAFPAD
PACKAGES += leafpad
endif

#
# Paths and names
#
LEAFPAD_VENDOR_VERSION	= 1
LEAFPAD_VERSION		= 0.7.9
LEAFPAD			= leafpad-$(LEAFPAD_VERSION)
LEAFPAD_SUFFIX		= tar.gz
LEAFPAD_URL		= http://savannah.nongnu.org/download/leafpad/$(LEAFPAD).$(LEAFPAD_SUFFIX)
LEAFPAD_SOURCE		= $(SRCDIR)/$(LEAFPAD).$(LEAFPAD_SUFFIX)
LEAFPAD_DIR		= $(BUILDDIR)/$(LEAFPAD)
LEAFPAD_IPKG_TMP	= $(LEAFPAD_DIR)/ipkg_tmp

# ----------------------------------------------------------------------------
# Get
# ----------------------------------------------------------------------------

leafpad_get: $(STATEDIR)/leafpad.get

leafpad_get_deps = $(LEAFPAD_SOURCE)

$(STATEDIR)/leafpad.get: $(leafpad_get_deps)
	@$(call targetinfo, $@)
	@$(call get_patches, $(LEAFPAD))
	touch $@

$(LEAFPAD_SOURCE):
	@$(call targetinfo, $@)
	@$(call get, $(LEAFPAD_URL))

# ----------------------------------------------------------------------------
# Extract
# ----------------------------------------------------------------------------

leafpad_extract: $(STATEDIR)/leafpad.extract

leafpad_extract_deps = $(STATEDIR)/leafpad.get

$(STATEDIR)/leafpad.extract: $(leafpad_extract_deps)
	@$(call targetinfo, $@)
	@$(call clean, $(LEAFPAD_DIR))
	@$(call extract, $(LEAFPAD_SOURCE))
	@$(call patchin, $(LEAFPAD))
	touch $@

# ----------------------------------------------------------------------------
# Prepare
# ----------------------------------------------------------------------------

leafpad_prepare: $(STATEDIR)/leafpad.prepare

#
# dependencies
#
leafpad_prepare_deps = \
	$(STATEDIR)/leafpad.extract \
	$(STATEDIR)/gtk22.install \
	$(STATEDIR)/virtual-xchain.install

LEAFPAD_PATH	=  PATH=$(CROSS_PATH)
LEAFPAD_ENV 	=  $(CROSS_ENV)
LEAFPAD_ENV	+= CFLAGS="-O2 -fomit-frame-pointer"
LEAFPAD_ENV	+= PKG_CONFIG_PATH=$(CROSS_LIB_DIR)/lib/pkgconfig
#ifdef PTXCONF_XFREE430
#LEAFPAD_ENV	+= LDFLAGS=-Wl,-rpath-link,$(CROSS_LIB_DIR)/X11R6/lib
#endif

#
# autoconf
#
LEAFPAD_AUTOCONF = \
	--build=$(GNU_HOST) \
	--host=$(PTXCONF_GNU_TARGET) \
	--prefix=/usr

ifdef PTXCONF_XFREE430
LEAFPAD_AUTOCONF += --x-includes=$(CROSS_LIB_DIR)/include
LEAFPAD_AUTOCONF += --x-libraries=$(CROSS_LIB_DIR)/lib
endif

$(STATEDIR)/leafpad.prepare: $(leafpad_prepare_deps)
	@$(call targetinfo, $@)
	@$(call clean, $(LEAFPAD_DIR)/config.cache)
	cd $(LEAFPAD_DIR) && \
		$(LEAFPAD_PATH) $(LEAFPAD_ENV) \
		./configure $(LEAFPAD_AUTOCONF)
	touch $@

# ----------------------------------------------------------------------------
# Compile
# ----------------------------------------------------------------------------

leafpad_compile: $(STATEDIR)/leafpad.compile

leafpad_compile_deps = $(STATEDIR)/leafpad.prepare

$(STATEDIR)/leafpad.compile: $(leafpad_compile_deps)
	@$(call targetinfo, $@)
	$(LEAFPAD_PATH) $(MAKE) -C $(LEAFPAD_DIR)
	touch $@

# ----------------------------------------------------------------------------
# Install
# ----------------------------------------------------------------------------

leafpad_install: $(STATEDIR)/leafpad.install

$(STATEDIR)/leafpad.install: $(STATEDIR)/leafpad.compile
	@$(call targetinfo, $@)
	touch $@

# ----------------------------------------------------------------------------
# Target-Install
# ----------------------------------------------------------------------------

leafpad_targetinstall: $(STATEDIR)/leafpad.targetinstall

leafpad_targetinstall_deps = $(STATEDIR)/leafpad.compile \
	$(STATEDIR)/gtk22.targetinstall

$(STATEDIR)/leafpad.targetinstall: $(leafpad_targetinstall_deps)
	@$(call targetinfo, $@)
	$(LEAFPAD_PATH) $(MAKE) -C $(LEAFPAD_DIR) DESTDIR=$(LEAFPAD_IPKG_TMP) install
	$(CROSSSTRIP) $(LEAFPAD_IPKG_TMP)/usr/bin/*
	rm -rf $(LEAFPAD_IPKG_TMP)/usr/share/locale
	mkdir -p $(LEAFPAD_IPKG_TMP)/CONTROL
	echo "Package: leafpad" 											 >$(LEAFPAD_IPKG_TMP)/CONTROL/control
	echo "Priority: optional" 											>>$(LEAFPAD_IPKG_TMP)/CONTROL/control
	echo "Section: X11"	 											>>$(LEAFPAD_IPKG_TMP)/CONTROL/control
	echo "Maintainer: Alexander Chukov <sash@pdaXrom.org>" 								>>$(LEAFPAD_IPKG_TMP)/CONTROL/control
	echo "Architecture: $(SHORT_TARGET)" 										>>$(LEAFPAD_IPKG_TMP)/CONTROL/control
	echo "Version: $(LEAFPAD_VERSION)-$(LEAFPAD_VENDOR_VERSION)" 							>>$(LEAFPAD_IPKG_TMP)/CONTROL/control
	echo "Depends: gtk2" 												>>$(LEAFPAD_IPKG_TMP)/CONTROL/control
	echo "Description: Leafpad is a GTK+ based simple text editor. The user interface is similar to Notepad."	>>$(LEAFPAD_IPKG_TMP)/CONTROL/control
	cd $(FEEDDIR) && $(XMKIPKG) $(LEAFPAD_IPKG_TMP)
	touch $@

# ----------------------------------------------------------------------------
# Image-Install
# ----------------------------------------------------------------------------

ifdef PTXCONF_LEAFPAD_INSTALL
ROMPACKAGES += $(STATEDIR)/leafpad.imageinstall
endif

leafpad_imageinstall_deps = $(STATEDIR)/leafpad.targetinstall \
	$(STATEDIR)/virtual-image.install

$(STATEDIR)/leafpad.imageinstall: $(leafpad_imageinstall_deps)
	@$(call targetinfo, $@)
	cd $(FEEDDIR) && $(XIPKG) install leafpad
	touch $@

# ----------------------------------------------------------------------------
# Clean
# ----------------------------------------------------------------------------

leafpad_clean:
	rm -rf $(STATEDIR)/leafpad.*
	rm -rf $(LEAFPAD_DIR)

# vim: syntax=make
