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
ifdef PTXCONF_KOPI
PACKAGES += kopi
endif

#
# Paths and names
#
KOPI_VENDOR_VERSION	= 1
KOPI_VERSION		= 178
KOPI			= kopi$(KOPI_VERSION)_standalone
KOPI_SUFFIX		= tar.gz
KOPI_URL		= http://www.pdaXrom.org/src/$(KOPI).$(KOPI_SUFFIX)
KOPI_SOURCE		= $(SRCDIR)/$(KOPI).$(KOPI_SUFFIX)
KOPI_DIR		= $(BUILDDIR)/kopi
KOPI_IPKG_TMP		= $(KOPI_DIR)/ipkg_tmp

# ----------------------------------------------------------------------------
# Get
# ----------------------------------------------------------------------------

kopi_get: $(STATEDIR)/kopi.get

kopi_get_deps = $(KOPI_SOURCE)

$(STATEDIR)/kopi.get: $(kopi_get_deps)
	@$(call targetinfo, $@)
	@$(call get_patches, $(KOPI))
	touch $@

$(KOPI_SOURCE):
	@$(call targetinfo, $@)
	@$(call get, $(KOPI_URL))

# ----------------------------------------------------------------------------
# Extract
# ----------------------------------------------------------------------------

kopi_extract: $(STATEDIR)/kopi.extract

kopi_extract_deps = $(STATEDIR)/kopi.get

$(STATEDIR)/kopi.extract: $(kopi_extract_deps)
	@$(call targetinfo, $@)
	@$(call clean, $(KOPI_DIR))
	@$(call extract, $(KOPI_SOURCE))
	@$(call patchin, $(KOPI))
	touch $@

# ----------------------------------------------------------------------------
# Prepare
# ----------------------------------------------------------------------------

kopi_prepare: $(STATEDIR)/kopi.prepare

#
# dependencies
#
kopi_prepare_deps = \
	$(STATEDIR)/kopi.extract \
	$(STATEDIR)/qt-x11-free.install \
	$(STATEDIR)/bluez-libs.install \
	$(STATEDIR)/startup-notification.install \
	$(STATEDIR)/virtual-xchain.install

KOPI_PATH	=  PATH=$(QT-X11-FREE_DIR)/bin:$(CROSS_PATH)
KOPI_ENV 	=  $(CROSS_ENV)
KOPI_ENV	+= QTDIR=$(QT-X11-FREE_DIR)
KOPI_ENV	+= PKG_CONFIG_PATH=$(CROSS_LIB_DIR)/lib/pkgconfig:$(CROSS_LIB_DIR)/lib/pkgconfig
#ifdef PTXCONF_XFREE430
#KOPI_ENV	+= LDFLAGS=-Wl,-rpath-link,$(CROSS_LIB_DIR)/lib
#endif

#
# autoconf
#
KOPI_AUTOCONF = \
	--build=$(GNU_HOST) \
	--host=$(PTXCONF_GNU_TARGET) \
	--prefix=/usr

ifdef PTXCONF_XFREE430
KOPI_AUTOCONF += --x-includes=$(CROSS_LIB_DIR)/include
KOPI_AUTOCONF += --x-libraries=$(CROSS_LIB_DIR)/lib
endif

$(STATEDIR)/kopi.prepare: $(kopi_prepare_deps)
	@$(call targetinfo, $@)
	@$(call clean, $(KOPI_DIR)/config.cache)
	cd $(KOPI_DIR) && \
		$(KOPI_PATH) $(KOPI_ENV) \
		qmake kopi-desktop.pro
	$(KOPI_PATH) $(KOPI_ENV) make -C $(KOPI_DIR) clean
	touch $@

# ----------------------------------------------------------------------------
# Compile
# ----------------------------------------------------------------------------

kopi_compile: $(STATEDIR)/kopi.compile

kopi_compile_deps = $(STATEDIR)/kopi.prepare

$(STATEDIR)/kopi.compile: $(kopi_compile_deps)
	@$(call targetinfo, $@)
	$(KOPI_PATH) $(KOPI_ENV) $(MAKE) -C $(KOPI_DIR) UIC=uic MOC=moc
	###$(KOPI_PATH) $(KOPI_ENV) $(MAKE) -C $(KOPI_DIR) UIC=uic MOC=$(PTXCONF_PREFIX)/bin/moc
	touch $@

# ----------------------------------------------------------------------------
# Install
# ----------------------------------------------------------------------------

kopi_install: $(STATEDIR)/kopi.install

$(STATEDIR)/kopi.install: $(STATEDIR)/kopi.compile
	@$(call targetinfo, $@)
	touch $@

# ----------------------------------------------------------------------------
# Target-Install
# ----------------------------------------------------------------------------

kopi_targetinstall: $(STATEDIR)/kopi.targetinstall

kopi_targetinstall_deps = $(STATEDIR)/kopi.compile \
	$(STATEDIR)/bluez-libs.targetinstall \
	$(STATEDIR)/startup-notification.targetinstall \
	$(STATEDIR)/qt-x11-free.targetinstall

$(STATEDIR)/kopi.targetinstall: $(kopi_targetinstall_deps)
	@$(call targetinfo, $@)
	mkdir -p $(KOPI_IPKG_TMP)/usr/lib/qt/bin
	mkdir -p $(KOPI_IPKG_TMP)/usr/lib/qt/lib
	mkdir -p $(KOPI_IPKG_TMP)/usr/share/applications
	cp -a $(KOPI_DIR)/bin/kopi	$(KOPI_IPKG_TMP)/usr/lib/qt/lib/
	ln -sf /usr/lib/qt/lib/kopi	$(KOPI_IPKG_TMP)/usr/lib/qt/bin/kopi
	cp -a $(KOPI_DIR)/bin/*.so* 	$(KOPI_IPKG_TMP)/usr/lib/qt/lib/
	cp -a $(KOPI_DIR)/bin/pics 	$(KOPI_IPKG_TMP)/usr/lib/qt/lib/
	$(CROSSSTRIP) 			$(KOPI_IPKG_TMP)/usr/lib/qt/lib/*.so*
	cp -a $(TOPDIR)/config/pics/kopi.desktop	$(KOPI_IPKG_TMP)/usr/share/applications	
	##$(KOPI_PATH) $(MAKE) -C $(KOPI_DIR) DESTDIR=$(KOPI_IPKG_TMP) install
	mkdir -p $(KOPI_IPKG_TMP)/CONTROL
	echo "Package: kopi" 								 >$(KOPI_IPKG_TMP)/CONTROL/control
	echo "Priority: optional" 							>>$(KOPI_IPKG_TMP)/CONTROL/control
	echo "Section: Office"	 							>>$(KOPI_IPKG_TMP)/CONTROL/control
	echo "Maintainer: Alexander Chukov <sash@pdaXrom.org>" 				>>$(KOPI_IPKG_TMP)/CONTROL/control
	echo "Architecture: $(SHORT_TARGET)" 						>>$(KOPI_IPKG_TMP)/CONTROL/control
	echo "Version: $(KOPI_VERSION)-$(KOPI_VENDOR_VERSION)" 				>>$(KOPI_IPKG_TMP)/CONTROL/control
	echo "Depends: qt-mt" 								>>$(KOPI_IPKG_TMP)/CONTROL/control
	echo "Description: KOrganizer"							>>$(KOPI_IPKG_TMP)/CONTROL/control
	cd $(FEEDDIR) && $(XMKIPKG) $(KOPI_IPKG_TMP)
	touch $@

# ----------------------------------------------------------------------------
# Image-Install
# ----------------------------------------------------------------------------

ifdef PTXCONF_KOPI_INSTALL
ROMPACKAGES += $(STATEDIR)/kopi.imageinstall
endif

kopi_imageinstall_deps = $(STATEDIR)/kopi.targetinstall \
	$(STATEDIR)/virtual-image.install

$(STATEDIR)/kopi.imageinstall: $(kopi_imageinstall_deps)
	@$(call targetinfo, $@)
	cd $(FEEDDIR) && $(XIPKG) install kopi
	touch $@

# ----------------------------------------------------------------------------
# Clean
# ----------------------------------------------------------------------------

kopi_clean:
	rm -rf $(STATEDIR)/kopi.*
	rm -rf $(KOPI_DIR)

# vim: syntax=make
