# -*-makefile-*-
# $Id: template,v 1.10 2004/01/24 15:50:34 mkl Exp $
#
# Copyright (C) 2004 by Alexander Chukov <sash@cacko.biz>
#          
# See CREDITS for details about who has contributed to this project.
#
# For further information about the PTXdist project and license conditions
# see the README file.
#

#
# We provide this package
#
ifdef PTXCONF_X11ROM-SETTINGS
PACKAGES += x11rom-settings
endif

#
# Paths and names
#
X11ROM-SETTINGS_VERSION		= 1.0.1
X11ROM-SETTINGS			= x11rom-settings-$(X11ROM-SETTINGS_VERSION)
X11ROM-SETTINGS_SUFFIX		= tar.bz2
X11ROM-SETTINGS_URL		= http://www.cacko.biz/src/$(X11ROM-SETTINGS).$(X11ROM-SETTINGS_SUFFIX)
X11ROM-SETTINGS_SOURCE		= $(SRCDIR)/$(X11ROM-SETTINGS).$(X11ROM-SETTINGS_SUFFIX)
X11ROM-SETTINGS_DIR		= $(BUILDDIR)/$(X11ROM-SETTINGS)
X11ROM-SETTINGS_IPKG_TMP	= $(X11ROM-SETTINGS_DIR)/ipkg_tmp

# ----------------------------------------------------------------------------
# Get
# ----------------------------------------------------------------------------

x11rom-settings_get: $(STATEDIR)/x11rom-settings.get

x11rom-settings_get_deps = $(X11ROM-SETTINGS_SOURCE)

$(STATEDIR)/x11rom-settings.get: $(x11rom-settings_get_deps)
	@$(call targetinfo, $@)
	@$(call get_patches, $(X11ROM-SETTINGS))
	touch $@

$(X11ROM-SETTINGS_SOURCE):
	@$(call targetinfo, $@)
	@$(call get, $(X11ROM-SETTINGS_URL))

# ----------------------------------------------------------------------------
# Extract
# ----------------------------------------------------------------------------

x11rom-settings_extract: $(STATEDIR)/x11rom-settings.extract

x11rom-settings_extract_deps = $(STATEDIR)/x11rom-settings.get

$(STATEDIR)/x11rom-settings.extract: $(x11rom-settings_extract_deps)
	@$(call targetinfo, $@)
	@$(call clean, $(X11ROM-SETTINGS_DIR))
	@$(call extract, $(X11ROM-SETTINGS_SOURCE))
	@$(call patchin, $(X11ROM-SETTINGS))
	touch $@

# ----------------------------------------------------------------------------
# Prepare
# ----------------------------------------------------------------------------

x11rom-settings_prepare: $(STATEDIR)/x11rom-settings.prepare

#
# dependencies
#
x11rom-settings_prepare_deps = \
	$(STATEDIR)/x11rom-settings.extract \
	$(STATEDIR)/qt-x11-free.install \
	$(STATEDIR)/virtual-xchain.install

X11ROM-SETTINGS_PATH	=  PATH=$(QT-X11-FREE_DIR)/bin:$(CROSS_PATH)
X11ROM-SETTINGS_ENV 	=  $(CROSS_ENV)
X11ROM-SETTINGS_ENV	+= QTDIR=$(QT-X11-FREE_DIR)
X11ROM-SETTINGS_ENV	+= PKG_CONFIG_PATH=$(CROSS_LIB_DIR)/lib/pkgconfig:$(CROSS_LIB_DIR)/lib/pkgconfig

#
# autoconf
#
X11ROM-SETTINGS_AUTOCONF = \
	--build=$(GNU_HOST) \
	--host=$(PTXCONF_GNU_TARGET) \
	--prefix=$(CROSS_LIB_DIR)

$(STATEDIR)/x11rom-settings.prepare: $(x11rom-settings_prepare_deps)
	@$(call targetinfo, $@)
	@$(call clean, $(X11ROM-SETTINGS_DIR)/config.cache)
	cd $(X11ROM-SETTINGS_DIR)/datetime && \
		$(X11ROM-SETTINGS_PATH) $(X11ROM-SETTINGS_ENV) \
		qmake
	cd $(X11ROM-SETTINGS_DIR)/netconfig && \
		$(X11ROM-SETTINGS_PATH) $(X11ROM-SETTINGS_ENV) \
		qmake
	cd $(X11ROM-SETTINGS_DIR)/power && \
		$(X11ROM-SETTINGS_PATH) $(X11ROM-SETTINGS_ENV) \
		qmake
	cd $(X11ROM-SETTINGS_DIR)/pppconfig && \
		$(X11ROM-SETTINGS_PATH) $(X11ROM-SETTINGS_ENV) \
		qmake
	cd $(X11ROM-SETTINGS_DIR)/pppdealer && \
		$(X11ROM-SETTINGS_PATH) $(X11ROM-SETTINGS_ENV) \
		qmake
	cd $(X11ROM-SETTINGS_DIR)/qclockchange && \
		$(X11ROM-SETTINGS_PATH) $(X11ROM-SETTINGS_ENV) \
		qmake
	cd $(X11ROM-SETTINGS_DIR)/qipkg && \
		$(X11ROM-SETTINGS_PATH) $(X11ROM-SETTINGS_ENV) \
		qmake
	cd $(X11ROM-SETTINGS_DIR)/usbdconfig && \
		$(X11ROM-SETTINGS_PATH) $(X11ROM-SETTINGS_ENV) \
		qmake
	cd $(X11ROM-SETTINGS_DIR)/looknfeel && \
		$(X11ROM-SETTINGS_PATH) $(X11ROM-SETTINGS_ENV) \
		qmake
	touch $@

# ----------------------------------------------------------------------------
# Compile
# ----------------------------------------------------------------------------

x11rom-settings_compile: $(STATEDIR)/x11rom-settings.compile

x11rom-settings_compile_deps = $(STATEDIR)/x11rom-settings.prepare

$(STATEDIR)/x11rom-settings.compile: $(x11rom-settings_compile_deps)
	@$(call targetinfo, $@)
	cd $(X11ROM-SETTINGS_DIR)/datetime && \
		$(X11ROM-SETTINGS_PATH) $(X11ROM-SETTINGS_ENV) \
		make MOC=moc UIC=uic
	cd $(X11ROM-SETTINGS_DIR)/netconfig && \
		$(X11ROM-SETTINGS_PATH) $(X11ROM-SETTINGS_ENV) \
		make MOC=moc UIC=uic
	cd $(X11ROM-SETTINGS_DIR)/power && \
		$(X11ROM-SETTINGS_PATH) $(X11ROM-SETTINGS_ENV) \
		make MOC=moc UIC=uic
	cd $(X11ROM-SETTINGS_DIR)/pppconfig && \
		$(X11ROM-SETTINGS_PATH) $(X11ROM-SETTINGS_ENV) \
		make MOC=moc UIC=uic
	cd $(X11ROM-SETTINGS_DIR)/pppdealer && \
		$(X11ROM-SETTINGS_PATH) $(X11ROM-SETTINGS_ENV) \
		make MOC=moc UIC=uic
	cd $(X11ROM-SETTINGS_DIR)/qclockchange && \
		$(X11ROM-SETTINGS_PATH) $(X11ROM-SETTINGS_ENV) \
		make MOC=moc UIC=uic
	cd $(X11ROM-SETTINGS_DIR)/qipkg && \
		$(X11ROM-SETTINGS_PATH) $(X11ROM-SETTINGS_ENV) \
		make MOC=moc UIC=uic
	cd $(X11ROM-SETTINGS_DIR)/usbdconfig && \
		$(X11ROM-SETTINGS_PATH) $(X11ROM-SETTINGS_ENV) \
		make MOC=moc UIC=uic
	cd $(X11ROM-SETTINGS_DIR)/looknfeel && \
		$(X11ROM-SETTINGS_PATH) $(X11ROM-SETTINGS_ENV) \
		make MOC=moc UIC=uic
	cd $(X11ROM-SETTINGS_DIR)/xcardinfo && \
		$(X11ROM-SETTINGS_PATH) $(X11ROM-SETTINGS_ENV) \
		CFLAGS="-O2" \
		LDFLAGS="-lX11 -lXaw -lXmu" \
		make
		#make CFLAGS=-O2 -I$(CROSS_LIB_DIR)/include LDFLAGS="-lX11 -lXaw -lXmu -L$(CROSS_LIB_DIR)/lib -Wl,-rpath-link,$(CROSS_LIB_DIR)/lib"
	touch $@

# ----------------------------------------------------------------------------
# Install
# ----------------------------------------------------------------------------

x11rom-settings_install: $(STATEDIR)/x11rom-settings.install

$(STATEDIR)/x11rom-settings.install: $(STATEDIR)/x11rom-settings.compile
	@$(call targetinfo, $@)
	touch $@

# ----------------------------------------------------------------------------
# Target-Install
# ----------------------------------------------------------------------------

x11rom-settings_targetinstall: $(STATEDIR)/x11rom-settings.targetinstall

x11rom-settings_targetinstall_deps = $(STATEDIR)/x11rom-settings.compile

$(STATEDIR)/x11rom-settings.targetinstall: $(x11rom-settings_targetinstall_deps)
	@$(call targetinfo, $@)

	mkdir -p $(X11ROM-SETTINGS_IPKG_TMP)/usr/bin
	mkdir -p $(X11ROM-SETTINGS_IPKG_TMP)/usr/lib/qt/bin
	mkdir -p $(X11ROM-SETTINGS_IPKG_TMP)/usr/share/pixmaps
	mkdir -p $(X11ROM-SETTINGS_IPKG_TMP)/usr/share/applications

	$(INSTALL) -m 755 $(X11ROM-SETTINGS_DIR)/datetime/datetime $(X11ROM-SETTINGS_IPKG_TMP)/usr/lib/qt/bin
	$(CROSSSTRIP) $(X11ROM-SETTINGS_IPKG_TMP)/usr/lib/qt/bin/datetime
	$(INSTALL) -m 644 $(X11ROM-SETTINGS_DIR)/datetime/date.png $(X11ROM-SETTINGS_IPKG_TMP)/usr/share/pixmaps
	$(INSTALL) -m 644 $(X11ROM-SETTINGS_DIR)/datetime/datetime.desktop $(X11ROM-SETTINGS_IPKG_TMP)/usr/share/applications
#ifdef PTXCONF_ROX_INSTALL
#	$(DESK2ROX) $(X11ROM-SETTINGS_DIR)/datetime/datetime.desktop $(X11ROM-SETTINGS_IPKG_TMP)/usr/apps
#endif	
	$(INSTALL) -m 755 $(X11ROM-SETTINGS_DIR)/netconfig/lanconfig $(X11ROM-SETTINGS_IPKG_TMP)/usr/lib/qt/bin
	$(CROSSSTRIP) $(X11ROM-SETTINGS_IPKG_TMP)/usr/lib/qt/bin/lanconfig
	$(INSTALL) -m 644 $(X11ROM-SETTINGS_DIR)/netconfig/lanconfig.png $(X11ROM-SETTINGS_IPKG_TMP)/usr/share/pixmaps
	$(INSTALL) -m 644 $(X11ROM-SETTINGS_DIR)/netconfig/lanconfig.desktop $(X11ROM-SETTINGS_IPKG_TMP)/usr/share/applications
#ifdef PTXCONF_ROX_INSTALL
#	$(DESK2ROX) $(X11ROM-SETTINGS_DIR)/netconfig/lanconfig.desktop $(X11ROM-SETTINGS_IPKG_TMP)/usr/apps
#endif	
	
	$(INSTALL) -m 755 $(X11ROM-SETTINGS_DIR)/power/backlight $(X11ROM-SETTINGS_IPKG_TMP)/usr/lib/qt/bin
	$(CROSSSTRIP) $(X11ROM-SETTINGS_IPKG_TMP)/usr/lib/qt/bin/backlight
	$(INSTALL) -m 644 $(X11ROM-SETTINGS_DIR)/power/laptop_battery.png $(X11ROM-SETTINGS_IPKG_TMP)/usr/share/pixmaps
	$(INSTALL) -m 644 $(X11ROM-SETTINGS_DIR)/power/backlight.desktop $(X11ROM-SETTINGS_IPKG_TMP)/usr/share/applications
#ifdef PTXCONF_ROX_INSTALL
#	$(DESK2ROX) $(X11ROM-SETTINGS_DIR)/power/backlight.desktop $(X11ROM-SETTINGS_IPKG_TMP)/usr/apps
#endif	
	
	$(INSTALL) -m 755 $(X11ROM-SETTINGS_DIR)/pppconfig/pppconfig $(X11ROM-SETTINGS_IPKG_TMP)/usr/lib/qt/bin
	$(CROSSSTRIP) $(X11ROM-SETTINGS_IPKG_TMP)/usr/lib/qt/bin/pppconfig
	#$(INSTALL) -m 644 $(X11ROM-SETTINGS_DIR)/pppconfig/date.png $(X11ROM-SETTINGS_IPKG_TMP)/usr/share/pixmaps
	$(INSTALL) -m 644 $(X11ROM-SETTINGS_DIR)/pppconfig/pppconfig.desktop $(X11ROM-SETTINGS_IPKG_TMP)/usr/share/applications
#ifdef PTXCONF_ROX_INSTALL
#	$(DESK2ROX) $(X11ROM-SETTINGS_DIR)/pppconfig/pppconfig.desktop $(X11ROM-SETTINGS_IPKG_TMP)/usr/apps
#endif	
	
	$(INSTALL) -m 755 $(X11ROM-SETTINGS_DIR)/pppdealer/pppdealer $(X11ROM-SETTINGS_IPKG_TMP)/usr/lib/qt/bin
	$(CROSSSTRIP) $(X11ROM-SETTINGS_IPKG_TMP)/usr/lib/qt/bin/pppdealer
	$(INSTALL) -m 644 $(X11ROM-SETTINGS_DIR)/pppdealer/kppp.png $(X11ROM-SETTINGS_IPKG_TMP)/usr/share/pixmaps
	$(INSTALL) -m 644 $(X11ROM-SETTINGS_DIR)/pppdealer/pppdialer.desktop $(X11ROM-SETTINGS_IPKG_TMP)/usr/share/applications
#ifdef PTXCONF_ROX_INSTALL
#	$(DESK2ROX) $(X11ROM-SETTINGS_DIR)/pppdealer/pppdialer.desktop $(X11ROM-SETTINGS_IPKG_TMP)/usr/apps
#endif	
	
	$(INSTALL) -m 755 $(X11ROM-SETTINGS_DIR)/qclockchange/qclockchange $(X11ROM-SETTINGS_IPKG_TMP)/usr/lib/qt/bin
	$(CROSSSTRIP) $(X11ROM-SETTINGS_IPKG_TMP)/usr/lib/qt/bin/qclockchange
	$(INSTALL) -m 644 $(X11ROM-SETTINGS_DIR)/qclockchange/qclockchange.png $(X11ROM-SETTINGS_IPKG_TMP)/usr/share/pixmaps
	$(INSTALL) -m 644 $(X11ROM-SETTINGS_DIR)/qclockchange/qclockchange.desktop $(X11ROM-SETTINGS_IPKG_TMP)/usr/share/applications
#ifdef PTXCONF_ROX_INSTALL
#	$(DESK2ROX) $(X11ROM-SETTINGS_DIR)/qclockchange/qclockchange.desktop $(X11ROM-SETTINGS_IPKG_TMP)/usr/apps
#endif	
	
	$(INSTALL) -m 755 $(X11ROM-SETTINGS_DIR)/qipkg/qpkg $(X11ROM-SETTINGS_IPKG_TMP)/usr/lib/qt/bin
	$(CROSSSTRIP) $(X11ROM-SETTINGS_IPKG_TMP)/usr/lib/qt/bin/qpkg
	$(INSTALL) -m 644 $(X11ROM-SETTINGS_DIR)/qipkg/kpackage.png $(X11ROM-SETTINGS_IPKG_TMP)/usr/share/pixmaps
	$(INSTALL) -m 644 $(X11ROM-SETTINGS_DIR)/qipkg/qpkg.desktop $(X11ROM-SETTINGS_IPKG_TMP)/usr/share/applications
#ifdef PTXCONF_ROX_INSTALL
#	$(DESK2ROX) $(X11ROM-SETTINGS_DIR)/qipkg/qpkg.desktop $(X11ROM-SETTINGS_IPKG_TMP)/usr/apps
#endif	
	
	$(INSTALL) -m 755 $(X11ROM-SETTINGS_DIR)/usbdconfig/usbdconfig $(X11ROM-SETTINGS_IPKG_TMP)/usr/lib/qt/bin
	$(CROSSSTRIP) $(X11ROM-SETTINGS_IPKG_TMP)/usr/lib/qt/bin/usbdconfig
	$(INSTALL) -m 644 $(X11ROM-SETTINGS_DIR)/usbdconfig/usb.png $(X11ROM-SETTINGS_IPKG_TMP)/usr/share/pixmaps
	$(INSTALL) -m 644 $(X11ROM-SETTINGS_DIR)/usbdconfig/usbdconfig.desktop $(X11ROM-SETTINGS_IPKG_TMP)/usr/share/applications
#ifdef PTXCONF_ROX_INSTALL
#	$(DESK2ROX) $(X11ROM-SETTINGS_DIR)/usbdconfig/usbdconfig.desktop $(X11ROM-SETTINGS_IPKG_TMP)/usr/apps
#endif	

#ifdef PTXCONF_MATCHBOX-DESKTOP_INSTALL
	$(INSTALL) -m 755 $(X11ROM-SETTINGS_DIR)/looknfeel/looknfeel $(X11ROM-SETTINGS_IPKG_TMP)/usr/lib/qt/bin
	$(CROSSSTRIP) $(X11ROM-SETTINGS_IPKG_TMP)/usr/lib/qt/bin/looknfeel
	$(INSTALL) -m 644 $(X11ROM-SETTINGS_DIR)/looknfeel/looknfeel.png $(X11ROM-SETTINGS_IPKG_TMP)/usr/share/pixmaps
	$(INSTALL) -m 644 $(X11ROM-SETTINGS_DIR)/looknfeel/looknfeel.desktop $(X11ROM-SETTINGS_IPKG_TMP)/usr/share/applications
#endif

	$(INSTALL) -m 755 $(X11ROM-SETTINGS_DIR)/xcardinfo/xcardinfo $(X11ROM-SETTINGS_IPKG_TMP)/usr/bin
	$(CROSSSTRIP) $(X11ROM-SETTINGS_IPKG_TMP)/usr/bin/xcardinfo
	$(INSTALL) -m 644 $(X11ROM-SETTINGS_DIR)/xcardinfo/laptop_pcmcia.png $(X11ROM-SETTINGS_IPKG_TMP)/usr/share/pixmaps
	$(INSTALL) -m 644 $(X11ROM-SETTINGS_DIR)/xcardinfo/xcardinfo.desktop $(X11ROM-SETTINGS_IPKG_TMP)/usr/share/applications
#ifdef PTXCONF_ROX_INSTALL
#	$(DESK2ROX) $(X11ROM-SETTINGS_DIR)/xcardinfo/xcardinfo.desktop $(X11ROM-SETTINGS_IPKG_TMP)/usr/apps
#endif	

	mkdir -p $(X11ROM-SETTINGS_IPKG_TMP)/CONTROL
	echo "Package: x11rom-settings" 		 >$(X11ROM-SETTINGS_IPKG_TMP)/CONTROL/control
	echo "Priority: optional" 			>>$(X11ROM-SETTINGS_IPKG_TMP)/CONTROL/control
	echo "Section: X11"	 			>>$(X11ROM-SETTINGS_IPKG_TMP)/CONTROL/control
	echo "Maintainer: Alexander Chukov <sash@pdaXrom.org>">>$(X11ROM-SETTINGS_IPKG_TMP)/CONTROL/control
	echo "Architecture: $(SHORT_TARGET)" 		>>$(X11ROM-SETTINGS_IPKG_TMP)/CONTROL/control
	echo "Version: $(X11ROM-SETTINGS_VERSION)" 	>>$(X11ROM-SETTINGS_IPKG_TMP)/CONTROL/control
	echo "Depends: qt-mt"	 			>>$(X11ROM-SETTINGS_IPKG_TMP)/CONTROL/control
	echo "Description: pdaXrom settings tools"	>>$(X11ROM-SETTINGS_IPKG_TMP)/CONTROL/control
	cd $(FEEDDIR) && $(XMKIPKG) $(X11ROM-SETTINGS_IPKG_TMP)

	touch $@

# ----------------------------------------------------------------------------
# Image-Install
# ----------------------------------------------------------------------------

ifdef PTXCONF_X11ROM-SETTINGS_INSTALL
ROMPACKAGES += $(STATEDIR)/x11rom-settings.imageinstall
endif

x11rom-settings_imageinstall_deps = $(STATEDIR)/x11rom-settings.targetinstall \
	$(STATEDIR)/virtual-image.install

$(STATEDIR)/x11rom-settings.imageinstall: $(x11rom-settings_imageinstall_deps)
	@$(call targetinfo, $@)
	cd $(FEEDDIR) && $(XIPKG) install x11rom-settings
	touch $@


# ----------------------------------------------------------------------------
# Clean
# ----------------------------------------------------------------------------

x11rom-settings_clean:
	rm -rf $(STATEDIR)/x11rom-settings.*
	rm -rf $(X11ROM-SETTINGS_DIR)

# vim: syntax=make
