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
ifdef PTXCONF_MB-APPLET-POWER
PACKAGES += mb-applet-power
endif

#
# Paths and names
#
MB-APPLET-POWER_VERSION		= 1.0.2
MB-APPLET-POWER			= mb-applet-power-$(MB-APPLET-POWER_VERSION)
MB-APPLET-POWER_SUFFIX		= tar.bz2
MB-APPLET-POWER_URL		= http://www.pdaXrom.org/src/$(MB-APPLET-POWER).$(MB-APPLET-POWER_SUFFIX)
MB-APPLET-POWER_SOURCE		= $(SRCDIR)/$(MB-APPLET-POWER).$(MB-APPLET-POWER_SUFFIX)
MB-APPLET-POWER_DIR		= $(BUILDDIR)/$(MB-APPLET-POWER)
MB-APPLET-POWER_IPKG_TMP	= $(MB-APPLET-POWER_DIR)/ipkg_tmp

# ----------------------------------------------------------------------------
# Get
# ----------------------------------------------------------------------------

mb-applet-power_get: $(STATEDIR)/mb-applet-power.get

mb-applet-power_get_deps = $(MB-APPLET-POWER_SOURCE)

$(STATEDIR)/mb-applet-power.get: $(mb-applet-power_get_deps)
	@$(call targetinfo, $@)
	@$(call get_patches, $(MB-APPLET-POWER))
	touch $@

$(MB-APPLET-POWER_SOURCE):
	@$(call targetinfo, $@)
	@$(call get, $(MB-APPLET-POWER_URL))

# ----------------------------------------------------------------------------
# Extract
# ----------------------------------------------------------------------------

mb-applet-power_extract: $(STATEDIR)/mb-applet-power.extract

mb-applet-power_extract_deps = $(STATEDIR)/mb-applet-power.get

$(STATEDIR)/mb-applet-power.extract: $(mb-applet-power_extract_deps)
	@$(call targetinfo, $@)
	@$(call clean, $(MB-APPLET-POWER_DIR))
	@$(call extract, $(MB-APPLET-POWER_SOURCE))
	@$(call patchin, $(MB-APPLET-POWER))
	touch $@

# ----------------------------------------------------------------------------
# Prepare
# ----------------------------------------------------------------------------

mb-applet-power_prepare: $(STATEDIR)/mb-applet-power.prepare

#
# dependencies
#
mb-applet-power_prepare_deps = \
	$(STATEDIR)/mb-applet-power.extract \
	$(STATEDIR)/apmd.install \
	$(STATEDIR)/libmatchbox.install \
	$(STATEDIR)/virtual-xchain.install

MB-APPLET-POWER_PATH	=  PATH=$(CROSS_PATH)
MB-APPLET-POWER_ENV 	=  $(CROSS_ENV)
#MB-APPLET-POWER_ENV	+=
MB-APPLET-POWER_ENV	+= PKG_CONFIG_PATH=$(CROSS_LIB_DIR)/lib/pkgconfig:$(CROSS_LIB_DIR)/lib/pkgconfig
#ifdef PTXCONF_XFREE430
MB-APPLET-POWER_ENV	+= LDFLAGS="-lm"
#endif

#
# autoconf
#
MB-APPLET-POWER_AUTOCONF = \
	--build=$(GNU_HOST) \
	--host=$(PTXCONF_GNU_TARGET) \
	--prefix=/usr \
	--enable-startup-notification

ifdef PTXCONF_XFREE430
MB-APPLET-POWER_AUTOCONF += --x-includes=$(CROSS_LIB_DIR)/include
MB-APPLET-POWER_AUTOCONF += --x-libraries=$(CROSS_LIB_DIR)/lib
endif

$(STATEDIR)/mb-applet-power.prepare: $(mb-applet-power_prepare_deps)
	@$(call targetinfo, $@)
	@$(call clean, $(MB-APPLET-POWER_DIR)/config.cache)
	ln -sf $(PTXCONF_PREFIX)/share/automake-1.9/install-sh $(MB-APPLET-POWER_DIR)/install-sh
	ln -sf $(PTXCONF_PREFIX)/share/automake-1.9/missing $(MB-APPLET-POWER_DIR)/missing
	ln -sf $(PTXCONF_PREFIX)/share/automake-1.9/depcomp $(MB-APPLET-POWER_DIR)/depcomp
	ln -sf $(PTXCONF_PREFIX)/share/automake-1.9/INSTALL $(MB-APPLET-POWER_DIR)/INSTALL
	ln -sf $(PTXCONF_PREFIX)/share/automake-1.9/COPYING $(MB-APPLET-POWER_DIR)/COPYING
	ln -sf $(PTXCONF_PREFIX)/share/automake-1.9/mkinstalldirs $(MB-APPLET-POWER_DIR)/mkinstalldirs
	cd $(MB-APPLET-POWER_DIR) && \
		$(MB-APPLET-POWER_PATH) $(MB-APPLET-POWER_ENV) \
		./configure $(MB-APPLET-POWER_AUTOCONF)
	touch $@

# ----------------------------------------------------------------------------
# Compile
# ----------------------------------------------------------------------------

mb-applet-power_compile: $(STATEDIR)/mb-applet-power.compile

mb-applet-power_compile_deps = $(STATEDIR)/mb-applet-power.prepare

$(STATEDIR)/mb-applet-power.compile: $(mb-applet-power_compile_deps)
	@$(call targetinfo, $@)
	$(MB-APPLET-POWER_PATH) $(MAKE) -C $(MB-APPLET-POWER_DIR)
	touch $@

# ----------------------------------------------------------------------------
# Install
# ----------------------------------------------------------------------------

mb-applet-power_install: $(STATEDIR)/mb-applet-power.install

$(STATEDIR)/mb-applet-power.install: $(STATEDIR)/mb-applet-power.compile
	@$(call targetinfo, $@)
	touch $@

# ----------------------------------------------------------------------------
# Target-Install
# ----------------------------------------------------------------------------

mb-applet-power_targetinstall: $(STATEDIR)/mb-applet-power.targetinstall

mb-applet-power_targetinstall_deps = $(STATEDIR)/mb-applet-power.compile \
	$(STATEDIR)/libmatchbox.targetinstall

$(STATEDIR)/mb-applet-power.targetinstall: $(mb-applet-power_targetinstall_deps)
	@$(call targetinfo, $@)
	$(MB-APPLET-POWER_PATH) $(MAKE) -C $(MB-APPLET-POWER_DIR) DESTDIR=$(MB-APPLET-POWER_IPKG_TMP) install
	$(CROSSSTRIP) $(MB-APPLET-POWER_IPKG_TMP)/usr/bin/*
	mkdir -p $(MB-APPLET-POWER_IPKG_TMP)/CONTROL
	echo "Package: mb-applet-power" 				 >$(MB-APPLET-POWER_IPKG_TMP)/CONTROL/control
	echo "Priority: optional" 					>>$(MB-APPLET-POWER_IPKG_TMP)/CONTROL/control
	echo "Section: Matchbox"			 		>>$(MB-APPLET-POWER_IPKG_TMP)/CONTROL/control
	echo "Maintainer: Alexander Chukov <sash@pdaXrom.org>" 		>>$(MB-APPLET-POWER_IPKG_TMP)/CONTROL/control
	echo "Architecture: $(SHORT_TARGET)" 				>>$(MB-APPLET-POWER_IPKG_TMP)/CONTROL/control
	echo "Version: $(MB-APPLET-POWER_VERSION)" 			>>$(MB-APPLET-POWER_IPKG_TMP)/CONTROL/control
	echo "Depends: libmatchbox" 					>>$(MB-APPLET-POWER_IPKG_TMP)/CONTROL/control
	echo "Description: matchbox power applet"			>>$(MB-APPLET-POWER_IPKG_TMP)/CONTROL/control
	cd $(FEEDDIR) && $(XMKIPKG) $(MB-APPLET-POWER_IPKG_TMP)
	touch $@

# ----------------------------------------------------------------------------
# Image-Install
# ----------------------------------------------------------------------------

ifdef PTXCONF_MB-APPLET-POWER_INSTALL
ROMPACKAGES += $(STATEDIR)/mb-applet-power.imageinstall
endif

mb-applet-power_imageinstall_deps = $(STATEDIR)/mb-applet-power.targetinstall \
	$(STATEDIR)/virtual-image.install

$(STATEDIR)/mb-applet-power.imageinstall: $(mb-applet-power_imageinstall_deps)
	@$(call targetinfo, $@)
	cd $(FEEDDIR) && $(XIPKG) install mb-applet-power
	touch $@

# ----------------------------------------------------------------------------
# Clean
# ----------------------------------------------------------------------------

mb-applet-power_clean:
	rm -rf $(STATEDIR)/mb-applet-power.*
	rm -rf $(MB-APPLET-POWER_DIR)

# vim: syntax=make
