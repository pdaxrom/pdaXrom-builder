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
ifdef PTXCONF_MB-APPLET-CLOCK
PACKAGES += mb-applet-clock
endif

#
# Paths and names
#
MB-APPLET-CLOCK_VERSION		= 1.0.1
MB-APPLET-CLOCK			= mb-applet-clock-$(MB-APPLET-CLOCK_VERSION)
MB-APPLET-CLOCK_SUFFIX		= tar.bz2
MB-APPLET-CLOCK_URL		= http://www.pdaXrom.org/src/$(MB-APPLET-CLOCK).$(MB-APPLET-CLOCK_SUFFIX)
MB-APPLET-CLOCK_SOURCE		= $(SRCDIR)/$(MB-APPLET-CLOCK).$(MB-APPLET-CLOCK_SUFFIX)
MB-APPLET-CLOCK_DIR		= $(BUILDDIR)/$(MB-APPLET-CLOCK)
MB-APPLET-CLOCK_IPKG_TMP	= $(MB-APPLET-CLOCK_DIR)/ipkg_tmp

# ----------------------------------------------------------------------------
# Get
# ----------------------------------------------------------------------------

mb-applet-clock_get: $(STATEDIR)/mb-applet-clock.get

mb-applet-clock_get_deps = $(MB-APPLET-CLOCK_SOURCE)

$(STATEDIR)/mb-applet-clock.get: $(mb-applet-clock_get_deps)
	@$(call targetinfo, $@)
	@$(call get_patches, $(MB-APPLET-CLOCK))
	touch $@

$(MB-APPLET-CLOCK_SOURCE):
	@$(call targetinfo, $@)
	@$(call get, $(MB-APPLET-CLOCK_URL))

# ----------------------------------------------------------------------------
# Extract
# ----------------------------------------------------------------------------

mb-applet-clock_extract: $(STATEDIR)/mb-applet-clock.extract

mb-applet-clock_extract_deps = $(STATEDIR)/mb-applet-clock.get

$(STATEDIR)/mb-applet-clock.extract: $(mb-applet-clock_extract_deps)
	@$(call targetinfo, $@)
	@$(call clean, $(MB-APPLET-CLOCK_DIR))
	@$(call extract, $(MB-APPLET-CLOCK_SOURCE))
	@$(call patchin, $(MB-APPLET-CLOCK))
	touch $@

# ----------------------------------------------------------------------------
# Prepare
# ----------------------------------------------------------------------------

mb-applet-clock_prepare: $(STATEDIR)/mb-applet-clock.prepare

#
# dependencies
#
mb-applet-clock_prepare_deps = \
	$(STATEDIR)/mb-applet-clock.extract \
	$(STATEDIR)/libmatchbox.install \
	$(STATEDIR)/virtual-xchain.install

MB-APPLET-CLOCK_PATH	=  PATH=$(CROSS_PATH)
MB-APPLET-CLOCK_ENV 	=  $(CROSS_ENV)
MB-APPLET-CLOCK_ENV	+= CFLAGS="-O2 -fomit-frame-pointer"
MB-APPLET-CLOCK_ENV	+= PKG_CONFIG_PATH=$(CROSS_LIB_DIR)/lib/pkgconfig:$(CROSS_LIB_DIR)/lib/pkgconfig
#ifdef PTXCONF_XFREE430
MB-APPLET-CLOCK_ENV	+= LDFLAGS="-lm"
#endif

#
# autoconf
#
MB-APPLET-CLOCK_AUTOCONF = \
	--build=$(GNU_HOST) \
	--host=$(PTXCONF_GNU_TARGET) \
	--prefix=/usr \
	--enable-startup-notification

ifdef PTXCONF_XFREE430
MB-APPLET-CLOCK_AUTOCONF += --x-includes=$(CROSS_LIB_DIR)/include
MB-APPLET-CLOCK_AUTOCONF += --x-libraries=$(CROSS_LIB_DIR)/lib
endif

$(STATEDIR)/mb-applet-clock.prepare: $(mb-applet-clock_prepare_deps)
	@$(call targetinfo, $@)
	@$(call clean, $(MB-APPLET-CLOCK_DIR)/config.cache)
	#cd $(MB-APPLET-CLOCK_DIR) && $(MB-APPLET-CLOCK_PATH) aclocal
	#cd $(MB-APPLET-CLOCK_DIR) && $(MB-APPLET-CLOCK_PATH) automake --add-missing
	#cd $(MB-APPLET-CLOCK_DIR) && $(MB-APPLET-CLOCK_PATH) autoconf
	ln -sf $(PTXCONF_PREFIX)/share/automake-1.9/install-sh $(MB-APPLET-CLOCK_DIR)/install-sh
	ln -sf $(PTXCONF_PREFIX)/share/automake-1.9/missing $(MB-APPLET-CLOCK_DIR)/missing
	ln -sf $(PTXCONF_PREFIX)/share/automake-1.9/depcomp $(MB-APPLET-CLOCK_DIR)/depcomp
	ln -sf $(PTXCONF_PREFIX)/share/automake-1.9/INSTALL $(MB-APPLET-CLOCK_DIR)/INSTALL
	ln -sf $(PTXCONF_PREFIX)/share/automake-1.9/COPYING $(MB-APPLET-CLOCK_DIR)/COPYING
	ln -sf $(PTXCONF_PREFIX)/share/automake-1.9/mkinstalldirs $(MB-APPLET-CLOCK_DIR)/mkinstalldirs
	cd $(MB-APPLET-CLOCK_DIR) && \
		$(MB-APPLET-CLOCK_PATH) $(MB-APPLET-CLOCK_ENV) \
		./configure $(MB-APPLET-CLOCK_AUTOCONF)
	touch $@

# ----------------------------------------------------------------------------
# Compile
# ----------------------------------------------------------------------------

mb-applet-clock_compile: $(STATEDIR)/mb-applet-clock.compile

mb-applet-clock_compile_deps = $(STATEDIR)/mb-applet-clock.prepare

$(STATEDIR)/mb-applet-clock.compile: $(mb-applet-clock_compile_deps)
	@$(call targetinfo, $@)
	$(MB-APPLET-CLOCK_PATH) $(MAKE) -C $(MB-APPLET-CLOCK_DIR)
	touch $@

# ----------------------------------------------------------------------------
# Install
# ----------------------------------------------------------------------------

mb-applet-clock_install: $(STATEDIR)/mb-applet-clock.install

$(STATEDIR)/mb-applet-clock.install: $(STATEDIR)/mb-applet-clock.compile
	@$(call targetinfo, $@)
	touch $@

# ----------------------------------------------------------------------------
# Target-Install
# ----------------------------------------------------------------------------

mb-applet-clock_targetinstall: $(STATEDIR)/mb-applet-clock.targetinstall

mb-applet-clock_targetinstall_deps = $(STATEDIR)/mb-applet-clock.compile \
	$(STATEDIR)/libmatchbox.targetinstall

$(STATEDIR)/mb-applet-clock.targetinstall: $(mb-applet-clock_targetinstall_deps)
	@$(call targetinfo, $@)
	$(MB-APPLET-CLOCK_PATH) $(MAKE) -C $(MB-APPLET-CLOCK_DIR) DESTDIR=$(MB-APPLET-CLOCK_IPKG_TMP) install
	$(CROSSSTRIP) $(MB-APPLET-CLOCK_IPKG_TMP)/usr/bin/*
	mkdir -p $(MB-APPLET-CLOCK_IPKG_TMP)/CONTROL
	echo "Package: mb-applet-clock" 			 >$(MB-APPLET-CLOCK_IPKG_TMP)/CONTROL/control
	echo "Priority: optional" 				>>$(MB-APPLET-CLOCK_IPKG_TMP)/CONTROL/control
	echo "Section: Matchbox" 				>>$(MB-APPLET-CLOCK_IPKG_TMP)/CONTROL/control
	echo "Maintainer: Alexander Chukov <sash@pdaXrom.org>" 	>>$(MB-APPLET-CLOCK_IPKG_TMP)/CONTROL/control
	echo "Architecture: $(SHORT_TARGET)" 			>>$(MB-APPLET-CLOCK_IPKG_TMP)/CONTROL/control
	echo "Version: $(MB-APPLET-CLOCK_VERSION)" 		>>$(MB-APPLET-CLOCK_IPKG_TMP)/CONTROL/control
	echo "Depends: matchbox-panel" 				>>$(MB-APPLET-CLOCK_IPKG_TMP)/CONTROL/control
	echo "Description: Matchbox datetime applet"		>>$(MB-APPLET-CLOCK_IPKG_TMP)/CONTROL/control
	cd $(FEEDDIR) && $(XMKIPKG) $(MB-APPLET-CLOCK_IPKG_TMP)
	touch $@

# ----------------------------------------------------------------------------
# Image-Install
# ----------------------------------------------------------------------------

ifdef PTXCONF_MB-APPLET-CLOCK_INSTALL
ROMPACKAGES += $(STATEDIR)/mb-applet-clock.imageinstall
endif

mb-applet-clock_imageinstall_deps = $(STATEDIR)/mb-applet-clock.targetinstall \
	$(STATEDIR)/virtual-image.install

$(STATEDIR)/mb-applet-clock.imageinstall: $(mb-applet-clock_imageinstall_deps)
	@$(call targetinfo, $@)
	cd $(FEEDDIR) && $(XIPKG) install mb-applet-clock
	touch $@

# ----------------------------------------------------------------------------
# Clean
# ----------------------------------------------------------------------------

mb-applet-clock_clean:
	rm -rf $(STATEDIR)/mb-applet-clock.*
	rm -rf $(MB-APPLET-CLOCK_DIR)

# vim: syntax=make
