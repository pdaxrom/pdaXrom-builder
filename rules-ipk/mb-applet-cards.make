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
ifdef PTXCONF_MB-APPLET-CARDS
PACKAGES += mb-applet-cards
endif

#
# Paths and names
#
MB-APPLET-CARDS_VERSION		= 1.0.1
MB-APPLET-CARDS			= mb-applet-cards-$(MB-APPLET-CARDS_VERSION)
MB-APPLET-CARDS_SUFFIX		= tar.bz2
MB-APPLET-CARDS_URL		= http://www.pdaXrom.org/src/$(MB-APPLET-CARDS).$(MB-APPLET-CARDS_SUFFIX)
MB-APPLET-CARDS_SOURCE		= $(SRCDIR)/$(MB-APPLET-CARDS).$(MB-APPLET-CARDS_SUFFIX)
MB-APPLET-CARDS_DIR		= $(BUILDDIR)/$(MB-APPLET-CARDS)
MB-APPLET-CARDS_IPKG_TMP	= $(MB-APPLET-CARDS_DIR)/ipkg_tmp

# ----------------------------------------------------------------------------
# Get
# ----------------------------------------------------------------------------

mb-applet-cards_get: $(STATEDIR)/mb-applet-cards.get

mb-applet-cards_get_deps = $(MB-APPLET-CARDS_SOURCE)

$(STATEDIR)/mb-applet-cards.get: $(mb-applet-cards_get_deps)
	@$(call targetinfo, $@)
	@$(call get_patches, $(MB-APPLET-CARDS))
	touch $@

$(MB-APPLET-CARDS_SOURCE):
	@$(call targetinfo, $@)
	@$(call get, $(MB-APPLET-CARDS_URL))

# ----------------------------------------------------------------------------
# Extract
# ----------------------------------------------------------------------------

mb-applet-cards_extract: $(STATEDIR)/mb-applet-cards.extract

mb-applet-cards_extract_deps = $(STATEDIR)/mb-applet-cards.get

$(STATEDIR)/mb-applet-cards.extract: $(mb-applet-cards_extract_deps)
	@$(call targetinfo, $@)
	@$(call clean, $(MB-APPLET-CARDS_DIR))
	@$(call extract, $(MB-APPLET-CARDS_SOURCE))
	@$(call patchin, $(MB-APPLET-CARDS))
	touch $@

# ----------------------------------------------------------------------------
# Prepare
# ----------------------------------------------------------------------------

mb-applet-cards_prepare: $(STATEDIR)/mb-applet-cards.prepare

#
# dependencies
#
mb-applet-cards_prepare_deps = \
	$(STATEDIR)/mb-applet-cards.extract \
	$(STATEDIR)/libmatchbox.install \
	$(STATEDIR)/gtk22.install \
	$(STATEDIR)/virtual-xchain.install

MB-APPLET-CARDS_PATH	=  PATH=$(CROSS_PATH)
MB-APPLET-CARDS_ENV 	=  $(CROSS_ENV)
MB-APPLET-CARDS_ENV	+= CFLAGS="-O2 -fomit-frame-pointer"
MB-APPLET-CARDS_ENV	+= PKG_CONFIG_PATH=$(CROSS_LIB_DIR)/lib/pkgconfig:$(CROSS_LIB_DIR)/lib/pkgconfig
#ifdef PTXCONF_XFREE430
#MB-APPLET-CARDS_ENV	+= LDFLAGS=-Wl,-rpath-link,$(CROSS_LIB_DIR)/lib
#endif

#
# autoconf
#
MB-APPLET-CARDS_AUTOCONF = \
	--build=$(GNU_HOST) \
	--host=$(PTXCONF_GNU_TARGET) \
	--prefix=/usr

ifdef PTXCONF_XFREE430
MB-APPLET-CARDS_AUTOCONF += --x-includes=$(CROSS_LIB_DIR)/include
MB-APPLET-CARDS_AUTOCONF += --x-libraries=$(CROSS_LIB_DIR)/lib
endif

$(STATEDIR)/mb-applet-cards.prepare: $(mb-applet-cards_prepare_deps)
	@$(call targetinfo, $@)
	@$(call clean, $(MB-APPLET-CARDS_DIR)/config.cache)
	ln -sf $(PTXCONF_PREFIX)/share/automake-1.9/install-sh $(MB-APPLET-CARDS_DIR)/install-sh
	ln -sf $(PTXCONF_PREFIX)/share/automake-1.9/missing $(MB-APPLET-CARDS_DIR)/missing
	ln -sf $(PTXCONF_PREFIX)/share/automake-1.9/depcomp $(MB-APPLET-CARDS_DIR)/depcomp
	ln -sf $(PTXCONF_PREFIX)/share/automake-1.9/INSTALL $(MB-APPLET-CARDS_DIR)/INSTALL
	ln -sf $(PTXCONF_PREFIX)/share/automake-1.9/COPYING $(MB-APPLET-CARDS_DIR)/COPYING
	ln -sf $(PTXCONF_PREFIX)/share/automake-1.9/mkinstalldirs $(MB-APPLET-CARDS_DIR)/mkinstalldirs
	cd $(MB-APPLET-CARDS_DIR) && \
		$(MB-APPLET-CARDS_PATH) $(MB-APPLET-CARDS_ENV) \
		./configure $(MB-APPLET-CARDS_AUTOCONF)
	touch $@

# ----------------------------------------------------------------------------
# Compile
# ----------------------------------------------------------------------------

mb-applet-cards_compile: $(STATEDIR)/mb-applet-cards.compile

mb-applet-cards_compile_deps = $(STATEDIR)/mb-applet-cards.prepare

$(STATEDIR)/mb-applet-cards.compile: $(mb-applet-cards_compile_deps)
	@$(call targetinfo, $@)
	$(MB-APPLET-CARDS_PATH) $(MAKE) -C $(MB-APPLET-CARDS_DIR)
	touch $@

# ----------------------------------------------------------------------------
# Install
# ----------------------------------------------------------------------------

mb-applet-cards_install: $(STATEDIR)/mb-applet-cards.install

$(STATEDIR)/mb-applet-cards.install: $(STATEDIR)/mb-applet-cards.compile
	@$(call targetinfo, $@)
	$(MB-APPLET-CARDS_PATH) $(MAKE) -C $(MB-APPLET-CARDS_DIR) install
	touch $@

# ----------------------------------------------------------------------------
# Target-Install
# ----------------------------------------------------------------------------

mb-applet-cards_targetinstall: $(STATEDIR)/mb-applet-cards.targetinstall

mb-applet-cards_targetinstall_deps = $(STATEDIR)/mb-applet-cards.compile \
	$(STATEDIR)/gtk22.targetinstall \
	$(STATEDIR)/libmatchbox.targetinstall

$(STATEDIR)/mb-applet-cards.targetinstall: $(mb-applet-cards_targetinstall_deps)
	@$(call targetinfo, $@)
	$(MB-APPLET-CARDS_PATH) $(MAKE) -C $(MB-APPLET-CARDS_DIR) DESTDIR=$(MB-APPLET-CARDS_IPKG_TMP) install
	$(CROSSSTRIP) $(MB-APPLET-CARDS_IPKG_TMP)/usr/bin/*
	mkdir -p $(MB-APPLET-CARDS_IPKG_TMP)/CONTROL
	echo "Package: mb-applet-cards" 			>$(MB-APPLET-CARDS_IPKG_TMP)/CONTROL/control
	echo "Priority: optional" 				>>$(MB-APPLET-CARDS_IPKG_TMP)/CONTROL/control
	echo "Section: Matchbox" 				>>$(MB-APPLET-CARDS_IPKG_TMP)/CONTROL/control
	echo "Maintainer: Alexander Chukov <sash@pdaXrom.org>" 	>>$(MB-APPLET-CARDS_IPKG_TMP)/CONTROL/control
	echo "Architecture: $(SHORT_TARGET)" 			>>$(MB-APPLET-CARDS_IPKG_TMP)/CONTROL/control
	echo "Version: $(MB-APPLET-CARDS_VERSION)" 		>>$(MB-APPLET-CARDS_IPKG_TMP)/CONTROL/control
	echo "Depends: matchbox-panel" 				>>$(MB-APPLET-CARDS_IPKG_TMP)/CONTROL/control
	echo "Description: matchbox card monitor applet"	>>$(MB-APPLET-CARDS_IPKG_TMP)/CONTROL/control
	cd $(FEEDDIR) && $(XMKIPKG) $(MB-APPLET-CARDS_IPKG_TMP)
	touch $@

# ----------------------------------------------------------------------------
# Image-Install
# ----------------------------------------------------------------------------

ifdef PTXCONF_MB-APPLET-CARDS_INSTALL
ROMPACKAGES += $(STATEDIR)/mb-applet-cards.imageinstall
endif

mb-applet-cards_imageinstall_deps = $(STATEDIR)/mb-applet-cards.targetinstall \
	$(STATEDIR)/virtual-image.install

$(STATEDIR)/mb-applet-cards.imageinstall: $(mb-applet-cards_imageinstall_deps)
	@$(call targetinfo, $@)
	cd $(FEEDDIR) && $(XIPKG) install mb-applet-cards
	touch $@

# ----------------------------------------------------------------------------
# Clean
# ----------------------------------------------------------------------------

mb-applet-cards_clean:
	rm -rf $(STATEDIR)/mb-applet-cards.*
	rm -rf $(MB-APPLET-CARDS_DIR)

# vim: syntax=make
