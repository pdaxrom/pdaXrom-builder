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
ifdef PTXCONF_PACKAGEMANAGER
PACKAGES += packagemanager
endif

#
# Paths and names
#
PACKAGEMANAGER_VENDOR_VERSION	= 1
PACKAGEMANAGER_VERSION		= 1.0.6
PACKAGEMANAGER			= packagemanager-$(PACKAGEMANAGER_VERSION)
PACKAGEMANAGER_SUFFIX		= tar.bz2
PACKAGEMANAGER_URL		= http://www.pdaXrom.org/src/$(PACKAGEMANAGER).$(PACKAGEMANAGER_SUFFIX)
PACKAGEMANAGER_SOURCE		= $(SRCDIR)/$(PACKAGEMANAGER).$(PACKAGEMANAGER_SUFFIX)
PACKAGEMANAGER_DIR		= $(BUILDDIR)/$(PACKAGEMANAGER)
PACKAGEMANAGER_IPKG_TMP		= $(PACKAGEMANAGER_DIR)/ipkg_root

# ----------------------------------------------------------------------------
# Get
# ----------------------------------------------------------------------------

packagemanager_get: $(STATEDIR)/packagemanager.get

packagemanager_get_deps = $(PACKAGEMANAGER_SOURCE)

$(STATEDIR)/packagemanager.get: $(packagemanager_get_deps)
	@$(call targetinfo, $@)
	@$(call get_patches, $(PACKAGEMANAGER))
	touch $@

$(PACKAGEMANAGER_SOURCE):
	@$(call targetinfo, $@)
	@$(call get, $(PACKAGEMANAGER_URL))

# ----------------------------------------------------------------------------
# Extract
# ----------------------------------------------------------------------------

packagemanager_extract: $(STATEDIR)/packagemanager.extract

packagemanager_extract_deps = $(STATEDIR)/packagemanager.get

$(STATEDIR)/packagemanager.extract: $(packagemanager_extract_deps)
	@$(call targetinfo, $@)
	@$(call clean, $(PACKAGEMANAGER_DIR))
	@$(call extract, $(PACKAGEMANAGER_SOURCE))
	@$(call patchin, $(PACKAGEMANAGER))
	touch $@

# ----------------------------------------------------------------------------
# Prepare
# ----------------------------------------------------------------------------

packagemanager_prepare: $(STATEDIR)/packagemanager.prepare

#
# dependencies
#
packagemanager_prepare_deps = \
	$(STATEDIR)/packagemanager.extract

ifndef PTXCONF_PACKAGEMANAGER_QTOPIA-FREE2
packagemanager_prepare_deps += \
	$(STATEDIR)/startup-notification.install \
	$(STATEDIR)/qt-x11-free.install \
	$(STATEDIR)/virtual-xchain.install

PACKAGEMANAGER_PATH	=  PATH=$(QT-X11-FREE_DIR)/bin:$(CROSS_PATH)
PACKAGEMANAGER_ENV 	=  $(CROSS_ENV)
PACKAGEMANAGER_ENV	+= QTDIR=$(QT-X11-FREE_DIR)
PACKAGEMANAGER_ENV	+= PKG_CONFIG_PATH=$(CROSS_LIB_DIR)/lib/pkgconfig:$(CROSS_LIB_DIR)/lib/pkgconfig
#ifdef PTXCONF_XFREE430
#PACKAGEMANAGER_ENV	+= LDFLAGS=-Wl,-rpath-link,$(CROSS_LIB_DIR)/lib
#endif

else
packagemanager_prepare_deps += \
	$(STATEDIR)/qtopia-free.install

PACKAGEMANAGER_PATH	=  PATH=$(QTOPIA-FREE_DIR)/bin:$(CROSS_PATH)
PACKAGEMANAGER_ENV 	=  $(CROSS_ENV)
PACKAGEMANAGER_ENV	+= QPEDIR=$(QTOPIA-FREE_DIR)
PACKAGEMANAGER_ENV	+= QTDIR=$(QT-EMBEDDED_DIR)
PACKAGEMANAGER_ENV	+= QTEDIR=$(QT-EMBEDDED_DIR)
PACKAGEMANAGER_ENV	+= QMAKESPEC=$(QTOPIA-FREE_QMAKESPEC)
endif


#
# autoconf
#
PACKAGEMANAGER_AUTOCONF = \
	--build=$(GNU_HOST) \
	--host=$(PTXCONF_GNU_TARGET) \
	--prefix=/usr

ifdef PTXCONF_XFREE430
PACKAGEMANAGER_AUTOCONF += --x-includes=$(CROSS_LIB_DIR)/include
PACKAGEMANAGER_AUTOCONF += --x-libraries=$(CROSS_LIB_DIR)/lib
endif

$(STATEDIR)/packagemanager.prepare: $(packagemanager_prepare_deps)
	@$(call targetinfo, $@)
	@$(call clean, $(PACKAGEMANAGER_DIR)/config.cache)
ifndef PTXCONF_PACKAGEMANAGER_QTOPIA-FREE2
	cd $(PACKAGEMANAGER_DIR)/src && \
		$(PACKAGEMANAGER_PATH) $(PACKAGEMANAGER_ENV) \
		qmake src.pro
else
	cd $(PACKAGEMANAGER_DIR)/src && \
		$(PACKAGEMANAGER_PATH) $(PACKAGEMANAGER_ENV) \
		qmake srcE.pro
endif
	touch $@

# ----------------------------------------------------------------------------
# Compile
# ----------------------------------------------------------------------------

packagemanager_compile: $(STATEDIR)/packagemanager.compile

packagemanager_compile_deps = $(STATEDIR)/packagemanager.prepare

$(STATEDIR)/packagemanager.compile: $(packagemanager_compile_deps)
	@$(call targetinfo, $@)
ifndef PTXCONF_PACKAGEMANAGER_QTOPIA-FREE2
	$(PACKAGEMANAGER_PATH) $(PACKAGEMANAGER_ENV) $(MAKE) -C $(PACKAGEMANAGER_DIR)/src UIC=uic
else
	$(PACKAGEMANAGER_PATH) $(PACKAGEMANAGER_ENV) $(MAKE) -C $(PACKAGEMANAGER_DIR)/src
endif
	touch $@

# ----------------------------------------------------------------------------
# Install
# ----------------------------------------------------------------------------

packagemanager_install: $(STATEDIR)/packagemanager.install

$(STATEDIR)/packagemanager.install: $(STATEDIR)/packagemanager.compile
	@$(call targetinfo, $@)
	touch $@

# ----------------------------------------------------------------------------
# Target-Install
# ----------------------------------------------------------------------------

packagemanager_targetinstall: $(STATEDIR)/packagemanager.targetinstall

packagemanager_targetinstall_deps = $(STATEDIR)/packagemanager.compile

ifndef PTXCONF_PACKAGEMANAGER_QTOPIA-FREE2
packagemanager_targetinstall_deps += \
	$(STATEDIR)/qt-x11-free.targetinstall \
	$(STATEDIR)/startup-notification.targetinstall
else
packagemanager_targetinstall_deps += \
	$(STATEDIR)/qtopia-free.targetinstall
endif

$(STATEDIR)/packagemanager.targetinstall: $(packagemanager_targetinstall_deps)
	@$(call targetinfo, $@)
	mkdir -p $(PACKAGEMANAGER_IPKG_TMP)/CONTROL
ifndef PTXCONF_PACKAGEMANAGER_QTOPIA-FREE2
	$(CROSSSTRIP) $(PACKAGEMANAGER_IPKG_TMP)/usr/lib/qt/bin/*
	echo "Package: packagemanager"			 			 >$(PACKAGEMANAGER_IPKG_TMP)/CONTROL/control
	echo "Priority: optional" 						>>$(PACKAGEMANAGER_IPKG_TMP)/CONTROL/control
	echo "Section: X11"	 						>>$(PACKAGEMANAGER_IPKG_TMP)/CONTROL/control
	echo "Maintainer: Alexander Chukov <sash@pdaXrom.org>" 			>>$(PACKAGEMANAGER_IPKG_TMP)/CONTROL/control
	echo "Architecture: $(SHORT_TARGET)" 					>>$(PACKAGEMANAGER_IPKG_TMP)/CONTROL/control
	echo "Version: $(PACKAGEMANAGER_VERSION)-$(PACKAGEMANAGER_VENDOR_VERSION)" >>$(PACKAGEMANAGER_IPKG_TMP)/CONTROL/control
	echo "Depends: qt-mt, startup-notification" 				>>$(PACKAGEMANAGER_IPKG_TMP)/CONTROL/control
	echo "Description: ipkg QT X11 frontend"				>>$(PACKAGEMANAGER_IPKG_TMP)/CONTROL/control
	cd $(FEEDDIR) && $(XMKIPKG) $(PACKAGEMANAGER_IPKG_TMP)
else
	$(CROSSSTRIP) $(PACKAGEMANAGER_IPKG_TMP)_qtopia/opt/Qtopia/bin/*
	echo "Package: qpe-packagemanager"		 			 >$(PACKAGEMANAGER_IPKG_TMP)_qtopia/CONTROL/control
	echo "Priority: optional" 						>>$(PACKAGEMANAGER_IPKG_TMP)_qtopia/CONTROL/control
	echo "Maintainer: Alexander Chukov <sash@pdaXrom.org>" 			>>$(PACKAGEMANAGER_IPKG_TMP)_qtopia/CONTROL/control
	echo "Architecture: $(SHORT_TARGET)" 					>>$(PACKAGEMANAGER_IPKG_TMP)_qtopia/CONTROL/control
	echo "Version: $(PACKAGEMANAGER_VERSION)-$(PACKAGEMANAGER_VENDOR_VERSION)" >>$(PACKAGEMANAGER_IPKG_TMP)_qtopia/CONTROL/control
	echo "Depends: qpe-libqtopia2" 						>>$(PACKAGEMANAGER_IPKG_TMP)_qtopia/CONTROL/control
	echo "Description: ipkg QT frontend"					>>$(PACKAGEMANAGER_IPKG_TMP)_qtopia/CONTROL/control
	cd $(FEEDDIR) && $(XMKIPKG) $(PACKAGEMANAGER_IPKG_TMP)_qtopia
endif
	touch $@

# ----------------------------------------------------------------------------
# Image-Install
# ----------------------------------------------------------------------------

ifdef PTXCONF_PACKAGEMANAGER_INSTALL
ROMPACKAGES += $(STATEDIR)/packagemanager.imageinstall
endif

packagemanager_imageinstall_deps = $(STATEDIR)/packagemanager.targetinstall \
	$(STATEDIR)/virtual-image.install

$(STATEDIR)/packagemanager.imageinstall: $(packagemanager_imageinstall_deps)
	@$(call targetinfo, $@)
ifndef PTXCONF_PACKAGEMANAGER_QTOPIA-FREE2
	cd $(FEEDDIR) && $(XIPKG) install packagemanager
else
	cd $(FEEDDIR) && $(XIPKG) install qpe-packagemanager
endif
	touch $@

# ----------------------------------------------------------------------------
# Clean
# ----------------------------------------------------------------------------

packagemanager_clean:
	rm -rf $(STATEDIR)/packagemanager.*
	rm -rf $(PACKAGEMANAGER_DIR)

# vim: syntax=make
