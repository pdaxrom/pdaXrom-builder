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
ifdef PTXCONF_MB-APPLET-KEYRUS
PACKAGES += mb-applet-keyrus
endif

#
# Paths and names
#
MB-APPLET-KEYRUS_VERSION	= 1.0.2
MB-APPLET-KEYRUS		= mb-applet-keyrus-$(MB-APPLET-KEYRUS_VERSION)
MB-APPLET-KEYRUS_SUFFIX		= tar.bz2
MB-APPLET-KEYRUS_URL		= http://www.pdaXrom.org/src/$(MB-APPLET-KEYRUS).$(MB-APPLET-KEYRUS_SUFFIX)
MB-APPLET-KEYRUS_SOURCE		= $(SRCDIR)/$(MB-APPLET-KEYRUS).$(MB-APPLET-KEYRUS_SUFFIX)
MB-APPLET-KEYRUS_DIR		= $(BUILDDIR)/$(MB-APPLET-KEYRUS)
MB-APPLET-KEYRUS_IPKG_TMP	= $(MB-APPLET-KEYRUS_DIR)/ipkg_tmp

# ----------------------------------------------------------------------------
# Get
# ----------------------------------------------------------------------------

mb-applet-keyrus_get: $(STATEDIR)/mb-applet-keyrus.get

mb-applet-keyrus_get_deps = $(MB-APPLET-KEYRUS_SOURCE)

$(STATEDIR)/mb-applet-keyrus.get: $(mb-applet-keyrus_get_deps)
	@$(call targetinfo, $@)
	@$(call get_patches, $(MB-APPLET-KEYRUS))
	touch $@

$(MB-APPLET-KEYRUS_SOURCE):
	@$(call targetinfo, $@)
	@$(call get, $(MB-APPLET-KEYRUS_URL))

# ----------------------------------------------------------------------------
# Extract
# ----------------------------------------------------------------------------

mb-applet-keyrus_extract: $(STATEDIR)/mb-applet-keyrus.extract

mb-applet-keyrus_extract_deps = $(STATEDIR)/mb-applet-keyrus.get

$(STATEDIR)/mb-applet-keyrus.extract: $(mb-applet-keyrus_extract_deps)
	@$(call targetinfo, $@)
	@$(call clean, $(MB-APPLET-KEYRUS_DIR))
	@$(call extract, $(MB-APPLET-KEYRUS_SOURCE))
	@$(call patchin, $(MB-APPLET-KEYRUS))
	touch $@

# ----------------------------------------------------------------------------
# Prepare
# ----------------------------------------------------------------------------

mb-applet-keyrus_prepare: $(STATEDIR)/mb-applet-keyrus.prepare

#
# dependencies
#
mb-applet-keyrus_prepare_deps = \
	$(STATEDIR)/mb-applet-keyrus.extract \
	$(STATEDIR)/virtual-xchain.install

MB-APPLET-KEYRUS_PATH	=  PATH=$(CROSS_PATH)
MB-APPLET-KEYRUS_ENV 	=  $(CROSS_ENV)
#MB-APPLET-KEYRUS_ENV	+=
MB-APPLET-KEYRUS_ENV	+= PKG_CONFIG_PATH=$(CROSS_LIB_DIR)/lib/pkgconfig:$(CROSS_LIB_DIR)/lib/pkgconfig
ifdef PTXCONF_XFREE430
MB-APPLET-KEYRUS_ENV	+= LDFLAGS="-lm"
endif

#
# autoconf
#
MB-APPLET-KEYRUS_AUTOCONF = \
	--build=$(GNU_HOST) \
	--host=$(PTXCONF_GNU_TARGET) \
	--prefix=/usr \
	--sysconfdir=/etc

ifdef PTXCONF_XFREE430
MB-APPLET-KEYRUS_AUTOCONF += --x-includes=$(CROSS_LIB_DIR)/include
MB-APPLET-KEYRUS_AUTOCONF += --x-libraries=$(CROSS_LIB_DIR)/lib
endif

$(STATEDIR)/mb-applet-keyrus.prepare: $(mb-applet-keyrus_prepare_deps)
	@$(call targetinfo, $@)
	@$(call clean, $(MB-APPLET-KEYRUS_DIR)/config.cache)
	ln -sf $(PTXCONF_PREFIX)/share/automake-1.9/install-sh $(MB-APPLET-KEYRUS_DIR)/install-sh
	ln -sf $(PTXCONF_PREFIX)/share/automake-1.9/missing $(MB-APPLET-KEYRUS_DIR)/missing
	ln -sf $(PTXCONF_PREFIX)/share/automake-1.9/depcomp $(MB-APPLET-KEYRUS_DIR)/depcomp
	ln -sf $(PTXCONF_PREFIX)/share/automake-1.9/INSTALL $(MB-APPLET-KEYRUS_DIR)/INSTALL
	ln -sf $(PTXCONF_PREFIX)/share/automake-1.9/COPYING $(MB-APPLET-KEYRUS_DIR)/COPYING
	ln -sf $(PTXCONF_PREFIX)/share/automake-1.9/mkinstalldirs $(MB-APPLET-KEYRUS_DIR)/mkinstalldirs
	cd $(MB-APPLET-KEYRUS_DIR) && \
		$(MB-APPLET-KEYRUS_PATH) $(MB-APPLET-KEYRUS_ENV) \
		./configure $(MB-APPLET-KEYRUS_AUTOCONF)
	touch $@

# ----------------------------------------------------------------------------
# Compile
# ----------------------------------------------------------------------------

mb-applet-keyrus_compile: $(STATEDIR)/mb-applet-keyrus.compile

mb-applet-keyrus_compile_deps = $(STATEDIR)/mb-applet-keyrus.prepare

$(STATEDIR)/mb-applet-keyrus.compile: $(mb-applet-keyrus_compile_deps)
	@$(call targetinfo, $@)
	$(MB-APPLET-KEYRUS_PATH) $(MAKE) -C $(MB-APPLET-KEYRUS_DIR)
	touch $@

# ----------------------------------------------------------------------------
# Install
# ----------------------------------------------------------------------------

mb-applet-keyrus_install: $(STATEDIR)/mb-applet-keyrus.install

$(STATEDIR)/mb-applet-keyrus.install: $(STATEDIR)/mb-applet-keyrus.compile
	@$(call targetinfo, $@)
	$(MB-APPLET-KEYRUS_PATH) $(MAKE) -C $(MB-APPLET-KEYRUS_DIR) install
	touch $@

# ----------------------------------------------------------------------------
# Target-Install
# ----------------------------------------------------------------------------

mb-applet-keyrus_targetinstall: $(STATEDIR)/mb-applet-keyrus.targetinstall

mb-applet-keyrus_targetinstall_deps = $(STATEDIR)/mb-applet-keyrus.compile

$(STATEDIR)/mb-applet-keyrus.targetinstall: $(mb-applet-keyrus_targetinstall_deps)
	@$(call targetinfo, $@)
	$(MB-APPLET-KEYRUS_PATH) $(MAKE) -C $(MB-APPLET-KEYRUS_DIR) DESTDIR=$(MB-APPLET-KEYRUS_IPKG_TMP) install mkdir_p="mkdir -p"
	$(CROSSSTRIP) $(MB-APPLET-KEYRUS_IPKG_TMP)/usr/bin/*
	mkdir -p $(MB-APPLET-KEYRUS_IPKG_TMP)/CONTROL
	echo "Package: mb-applet-keymap" 				 >$(MB-APPLET-KEYRUS_IPKG_TMP)/CONTROL/control
	echo "Priority: optional" 					>>$(MB-APPLET-KEYRUS_IPKG_TMP)/CONTROL/control
	echo "Section: Matchbox" 					>>$(MB-APPLET-KEYRUS_IPKG_TMP)/CONTROL/control
	echo "Maintainer: Alexander Chukov <sash@pdaXrom.org>" 		>>$(MB-APPLET-KEYRUS_IPKG_TMP)/CONTROL/control
	echo "Architecture: $(SHORT_TARGET)" 				>>$(MB-APPLET-KEYRUS_IPKG_TMP)/CONTROL/control
	echo "Version: $(MB-APPLET-KEYRUS_VERSION)" 			>>$(MB-APPLET-KEYRUS_IPKG_TMP)/CONTROL/control
	echo "Depends: libmatchbox" 					>>$(MB-APPLET-KEYRUS_IPKG_TMP)/CONTROL/control
	echo "Description: keymap layout switcher"			>>$(MB-APPLET-KEYRUS_IPKG_TMP)/CONTROL/control
	cd $(FEEDDIR) && $(XMKIPKG) $(MB-APPLET-KEYRUS_IPKG_TMP)
	#hack hack
	cp -a $(TOPDIR)/config/pdaXrom/x11-keymaps/* $(TOPDIR)/bootdisk/feed/
	touch $@

# ----------------------------------------------------------------------------
# Image-Install
# ----------------------------------------------------------------------------

ifdef PTXCONF_MB-APPLET-KEYRUS_INSTALL
ROMPACKAGES += $(STATEDIR)/mb-applet-keyrus.imageinstall
endif

mb-applet-keyrus_imageinstall_deps = $(STATEDIR)/mb-applet-keyrus.targetinstall \
	$(STATEDIR)/virtual-image.install

$(STATEDIR)/mb-applet-keyrus.imageinstall: $(mb-applet-keyrus_imageinstall_deps)
	@$(call targetinfo, $@)
	cd $(FEEDDIR) && $(XIPKG) install mb-applet-keymap
	touch $@

# ----------------------------------------------------------------------------
# Clean
# ----------------------------------------------------------------------------

mb-applet-keyrus_clean:
	rm -rf $(STATEDIR)/mb-applet-keyrus.*
	rm -rf $(MB-APPLET-KEYRUS_DIR)

# vim: syntax=make
