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
ifdef PTXCONF_KDEPIM
PACKAGES += kdepim
endif

#
# Paths and names
#
KDEPIM_VERSION		= 1.9.5
KDEPIM			= kdepim.$(KDEPIM_VERSION)
###KDEPIM_VERSION		= 1.9.4
###KDEPIM			= kdepim_$(KDEPIM_VERSION)
KDEPIM_SUFFIX		= src.tar.gz
KDEPIM_URL		= http://heanet.dl.sourceforge.net/sourceforge/kdepim/$(KDEPIM).$(KDEPIM_SUFFIX)
KDEPIM_SOURCE		= $(SRCDIR)/$(KDEPIM).$(KDEPIM_SUFFIX)
KDEPIM_DIR		= $(BUILDDIR)/kdepim
KDEPIM_IPKG_TMP		= $(KDEPIM_DIR)/ipkg_tmp

# ----------------------------------------------------------------------------
# Get
# ----------------------------------------------------------------------------

kdepim_get: $(STATEDIR)/kdepim.get

kdepim_get_deps = $(KDEPIM_SOURCE)

$(STATEDIR)/kdepim.get: $(kdepim_get_deps)
	@$(call targetinfo, $@)
	@$(call get_patches, $(KDEPIM))
	touch $@

$(KDEPIM_SOURCE):
	@$(call targetinfo, $@)
	@$(call get, $(KDEPIM_URL))

# ----------------------------------------------------------------------------
# Extract
# ----------------------------------------------------------------------------

kdepim_extract: $(STATEDIR)/kdepim.extract

kdepim_extract_deps = $(STATEDIR)/kdepim.get

$(STATEDIR)/kdepim.extract: $(kdepim_extract_deps)
	@$(call targetinfo, $@)
	@$(call clean, $(KDEPIM_DIR))
	@$(call extract, $(KDEPIM_SOURCE))
	@$(call patchin, $(KDEPIM), $(KDEPIM_DIR))
	touch $@

# ----------------------------------------------------------------------------
# Prepare
# ----------------------------------------------------------------------------

kdepim_prepare: $(STATEDIR)/kdepim.prepare

#
# dependencies
#
kdepim_prepare_deps = \
	$(STATEDIR)/kdepim.extract \
	$(STATEDIR)/qt-x11-free.install \
	$(STATEDIR)/bluez-sdp.install \
	$(STATEDIR)/startup-notification.install \
	$(STATEDIR)/virtual-xchain.install

KDEPIM_PATH	=  PATH=$(QT-X11-FREE_DIR)/bin:$(CROSS_PATH)
KDEPIM_ENV 	=  $(CROSS_ENV)
KDEPIM_ENV	+= QTDIR=$(QT-X11-FREE_DIR)
KDEPIM_ENV	+= PKG_CONFIG_PATH=$(CROSS_LIB_DIR)/lib/pkgconfig:$(CROSS_LIB_DIR)/lib/pkgconfig
#
# autoconf
#
KDEPIM_AUTOCONF = \
	--build=$(GNU_HOST) \
	--host=$(PTXCONF_GNU_TARGET) \
	--prefix=/usr

ifdef PTXCONF_XFREE430
KDEPIM_AUTOCONF += --x-includes=$(CROSS_LIB_DIR)/include
KDEPIM_AUTOCONF += --x-libraries=$(CROSS_LIB_DIR)/lib
endif

$(STATEDIR)/kdepim.prepare: $(kdepim_prepare_deps)
	@$(call targetinfo, $@)
	@$(call clean, $(KDEPIM_DIR)/config.cache)
	cd $(KDEPIM_DIR) && \
		$(KDEPIM_PATH) $(KDEPIM_ENV) \
		qmake kdepim-desktop.pro
	$(KDEPIM_PATH) $(KDEPIM_ENV) make -C $(KDEPIM_DIR) clean
	touch $@

# ----------------------------------------------------------------------------
# Compile
# ----------------------------------------------------------------------------

kdepim_compile: $(STATEDIR)/kdepim.compile

kdepim_compile_deps = $(STATEDIR)/kdepim.prepare

$(STATEDIR)/kdepim.compile: $(kdepim_compile_deps)
	@$(call targetinfo, $@)
	$(KDEPIM_PATH) $(KDEPIM_ENV) make -C $(KDEPIM_DIR) UIC=uic
	touch $@

# ----------------------------------------------------------------------------
# Install
# ----------------------------------------------------------------------------

kdepim_install: $(STATEDIR)/kdepim.install

$(STATEDIR)/kdepim.install: $(STATEDIR)/kdepim.compile
	@$(call targetinfo, $@)
	touch $@

# ----------------------------------------------------------------------------
# Target-Install
# ----------------------------------------------------------------------------

kdepim_targetinstall: $(STATEDIR)/kdepim.targetinstall

kdepim_targetinstall_deps = $(STATEDIR)/kdepim.compile \
	$(STATEDIR)/bluez-sdp.targetinstall \
	$(STATEDIR)/startup-notification.targetinstall \
	$(STATEDIR)/qt-x11-free.targetinstall


$(STATEDIR)/kdepim.targetinstall: $(kdepim_targetinstall_deps)
	@$(call targetinfo, $@)
	mkdir -p $(KDEPIM_IPKG_TMP)/usr/lib/qt/bin
	mkdir -p $(KDEPIM_IPKG_TMP)/usr/lib/qt/lib
	mkdir -p $(KDEPIM_IPKG_TMP)/usr/share/applications
	cp -a $(KDEPIM_DIR)/bin/{kammu,kapi,kopi}	$(KDEPIM_IPKG_TMP)/usr/lib/qt/lib
	ln -sf /usr/lib/qt/lib/kammu $(KDEPIM_IPKG_TMP)/usr/lib/qt/bin/kammu
	ln -sf /usr/lib/qt/lib/kapi  $(KDEPIM_IPKG_TMP)/usr/lib/qt/bin/kapi
	ln -sf /usr/lib/qt/lib/kopi  $(KDEPIM_IPKG_TMP)/usr/lib/qt/bin/kopi
	cp -a $(KDEPIM_DIR)/bin/*.so* 			$(KDEPIM_IPKG_TMP)/usr/lib/qt/lib
	$(CROSSSTRIP) $(KDEPIM_IPKG_TMP)/usr/lib/qt/lib/*
	cp -a $(KDEPIM_DIR)/bin/kdepim			$(KDEPIM_IPKG_TMP)/usr/lib/qt/lib/
	rm -f $(KDEPIM_IPKG_TMP)/usr/lib/qt/lib/kdepim/Makefile*
	cp -a $(TOPDIR)/config/pics/kaddressbook.desktop	$(KDEPIM_IPKG_TMP)/usr/share/applications
	cp -a $(TOPDIR)/config/pics/korganizer.desktop		$(KDEPIM_IPKG_TMP)/usr/share/applications
	mkdir -p $(KDEPIM_IPKG_TMP)/CONTROL
	echo "Package: kdepim" 							 >$(KDEPIM_IPKG_TMP)/CONTROL/control
	echo "Priority: optional" 						>>$(KDEPIM_IPKG_TMP)/CONTROL/control
	echo "Section: Office"	 						>>$(KDEPIM_IPKG_TMP)/CONTROL/control
	echo "Maintainer: Alexander Chukov <sash@pdaXrom.org>" 			>>$(KDEPIM_IPKG_TMP)/CONTROL/control
	echo "Architecture: $(SHORT_TARGET)" 					>>$(KDEPIM_IPKG_TMP)/CONTROL/control
	echo "Version: $(KDEPIM_VERSION)" 					>>$(KDEPIM_IPKG_TMP)/CONTROL/control
	echo "Depends: qt-mt, bluez-libs, startup-notification"			>>$(KDEPIM_IPKG_TMP)/CONTROL/control
	echo "Description: KOrganizer/Pi and Kaddressbook/Pi"			>>$(KDEPIM_IPKG_TMP)/CONTROL/control
	cd $(FEEDDIR) && $(XMKIPKG) $(KDEPIM_IPKG_TMP)
	touch $@

# ----------------------------------------------------------------------------
# Image-Install
# ----------------------------------------------------------------------------

ifdef PTXCONF_KDEPIM_INSTALL
ROMPACKAGES += $(STATEDIR)/kdepim.imageinstall
endif

kdepim_imageinstall_deps = $(STATEDIR)/kdepim.targetinstall \
	$(STATEDIR)/virtual-image.install

$(STATEDIR)/kdepim.imageinstall: $(kdepim_imageinstall_deps)
	@$(call targetinfo, $@)
	cd $(FEEDDIR) && $(XIPKG) install kdepim
	touch $@

# ----------------------------------------------------------------------------
# Clean
# ----------------------------------------------------------------------------

kdepim_clean:
	rm -rf $(STATEDIR)/kdepim.*
	rm -rf $(KDEPIM_DIR)

# vim: syntax=make
