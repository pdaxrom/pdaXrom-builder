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
ifdef PTXCONF_PXA-OVERCLOCK
PACKAGES += pxa-overclock
endif

#
# Paths and names
#
PXA-OVERCLOCK_VERSION		= 1.0.0
PXA-OVERCLOCK			= pxa-overclock-$(PXA-OVERCLOCK_VERSION)
PXA-OVERCLOCK_SUFFIX		= tar.bz2
PXA-OVERCLOCK_URL		= http://www.pdaXrom.org/src/$(PXA-OVERCLOCK).$(PXA-OVERCLOCK_SUFFIX)
PXA-OVERCLOCK_SOURCE		= $(SRCDIR)/$(PXA-OVERCLOCK).$(PXA-OVERCLOCK_SUFFIX)
PXA-OVERCLOCK_DIR		= $(BUILDDIR)/$(PXA-OVERCLOCK)
PXA-OVERCLOCK_IPKG_TMP		= $(PXA-OVERCLOCK_DIR)/ipkg_root

# ----------------------------------------------------------------------------
# Get
# ----------------------------------------------------------------------------

pxa-overclock_get: $(STATEDIR)/pxa-overclock.get

pxa-overclock_get_deps = $(PXA-OVERCLOCK_SOURCE)

$(STATEDIR)/pxa-overclock.get: $(pxa-overclock_get_deps)
	@$(call targetinfo, $@)
	@$(call get_patches, $(PXA-OVERCLOCK))
	touch $@

$(PXA-OVERCLOCK_SOURCE):
	@$(call targetinfo, $@)
	@$(call get, $(PXA-OVERCLOCK_URL))

# ----------------------------------------------------------------------------
# Extract
# ----------------------------------------------------------------------------

pxa-overclock_extract: $(STATEDIR)/pxa-overclock.extract

pxa-overclock_extract_deps = $(STATEDIR)/pxa-overclock.get

$(STATEDIR)/pxa-overclock.extract: $(pxa-overclock_extract_deps)
	@$(call targetinfo, $@)
	@$(call clean, $(PXA-OVERCLOCK_DIR))
	@$(call extract, $(PXA-OVERCLOCK_SOURCE))
	@$(call patchin, $(PXA-OVERCLOCK))
	touch $@

# ----------------------------------------------------------------------------
# Prepare
# ----------------------------------------------------------------------------

pxa-overclock_prepare: $(STATEDIR)/pxa-overclock.prepare

#
# dependencies
#
pxa-overclock_prepare_deps = \
	$(STATEDIR)/pxa-overclock.extract \
	$(STATEDIR)/startup-notification.install \
	$(STATEDIR)/qt-x11-free.install \
	$(STATEDIR)/virtual-xchain.install

PXA-OVERCLOCK_PATH	=  PATH=$(QT-X11-FREE_DIR)/bin:$(CROSS_PATH)
PXA-OVERCLOCK_ENV 	=  $(CROSS_ENV)
PXA-OVERCLOCK_ENV	+= QTDIR=$(QT-X11-FREE_DIR)
PXA-OVERCLOCK_ENV	+= PKG_CONFIG_PATH=$(CROSS_LIB_DIR)/lib/pkgconfig:$(CROSS_LIB_DIR)/lib/pkgconfig
#ifdef PTXCONF_XFREE430
#PXA-OVERCLOCK_ENV	+= LDFLAGS=-Wl,-rpath-link,$(CROSS_LIB_DIR)/lib
#endif

#
# autoconf
#
PXA-OVERCLOCK_AUTOCONF = \
	--build=$(GNU_HOST) \
	--host=$(PTXCONF_GNU_TARGET) \
	--prefix=/usr

ifdef PTXCONF_XFREE430
PXA-OVERCLOCK_AUTOCONF += --x-includes=$(CROSS_LIB_DIR)/include
PXA-OVERCLOCK_AUTOCONF += --x-libraries=$(CROSS_LIB_DIR)/lib
endif

$(STATEDIR)/pxa-overclock.prepare: $(pxa-overclock_prepare_deps)
	@$(call targetinfo, $@)
	@$(call clean, $(PXA-OVERCLOCK_DIR)/config.cache)
	cd $(PXA-OVERCLOCK_DIR) && \
		$(PXA-OVERCLOCK_PATH) $(PXA-OVERCLOCK_ENV) \
		qmake pxa-overclock.pro
	touch $@

# ----------------------------------------------------------------------------
# Compile
# ----------------------------------------------------------------------------

pxa-overclock_compile: $(STATEDIR)/pxa-overclock.compile

pxa-overclock_compile_deps = $(STATEDIR)/pxa-overclock.prepare

$(STATEDIR)/pxa-overclock.compile: $(pxa-overclock_compile_deps)
	@$(call targetinfo, $@)
	$(PXA-OVERCLOCK_PATH) $(PXA-OVERCLOCK_ENV) $(MAKE) -C $(PXA-OVERCLOCK_DIR) UIC=uic
	touch $@

# ----------------------------------------------------------------------------
# Install
# ----------------------------------------------------------------------------

pxa-overclock_install: $(STATEDIR)/pxa-overclock.install

$(STATEDIR)/pxa-overclock.install: $(STATEDIR)/pxa-overclock.compile
	@$(call targetinfo, $@)
	touch $@

# ----------------------------------------------------------------------------
# Target-Install
# ----------------------------------------------------------------------------

pxa-overclock_targetinstall: $(STATEDIR)/pxa-overclock.targetinstall

pxa-overclock_targetinstall_deps = $(STATEDIR)/pxa-overclock.compile \
	$(STATEDIR)/qt-x11-free.targetinstall \
	$(STATEDIR)/startup-notification.targetinstall

$(STATEDIR)/pxa-overclock.targetinstall: $(pxa-overclock_targetinstall_deps)
	@$(call targetinfo, $@)
	$(CROSSSTRIP) $(PXA-OVERCLOCK_IPKG_TMP)/usr/lib/qt/bin/*
	mkdir -p $(PXA-OVERCLOCK_IPKG_TMP)/CONTROL
	echo "Package: pxa-overclock" 						 >$(PXA-OVERCLOCK_IPKG_TMP)/CONTROL/control
	echo "Priority: optional" 						>>$(PXA-OVERCLOCK_IPKG_TMP)/CONTROL/control
	echo "Section: X11"				 			>>$(PXA-OVERCLOCK_IPKG_TMP)/CONTROL/control
	echo "Maintainer: Alexander Chukov <sash@pdaXrom.org>" 			>>$(PXA-OVERCLOCK_IPKG_TMP)/CONTROL/control
	echo "Architecture: $(SHORT_TARGET)" 					>>$(PXA-OVERCLOCK_IPKG_TMP)/CONTROL/control
	echo "Version: $(PXA-OVERCLOCK_VERSION)" 				>>$(PXA-OVERCLOCK_IPKG_TMP)/CONTROL/control
	echo "Depends: qt-mt, startup-notification" 				>>$(PXA-OVERCLOCK_IPKG_TMP)/CONTROL/control
	echo "Description: PXA overclock tool"					>>$(PXA-OVERCLOCK_IPKG_TMP)/CONTROL/control
	cd $(FEEDDIR) && $(XMKIPKG) $(PXA-OVERCLOCK_IPKG_TMP)
	touch $@

# ----------------------------------------------------------------------------
# Image-Install
# ----------------------------------------------------------------------------

ifdef PTXCONF_PXA-OVERCLOCK_INSTALL
ROMPACKAGES += $(STATEDIR)/pxa-overclock.imageinstall
endif

pxa-overclock_imageinstall_deps = $(STATEDIR)/pxa-overclock.targetinstall \
	$(STATEDIR)/virtual-image.install

$(STATEDIR)/pxa-overclock.imageinstall: $(pxa-overclock_imageinstall_deps)
	@$(call targetinfo, $@)
	cd $(FEEDDIR) && $(XIPKG) install pxa-overclock
	touch $@

# ----------------------------------------------------------------------------
# Clean
# ----------------------------------------------------------------------------

pxa-overclock_clean:
	rm -rf $(STATEDIR)/pxa-overclock.*
	rm -rf $(PXA-OVERCLOCK_DIR)

# vim: syntax=make
