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
ifdef PTXCONF_QTOPIA-FREE
PACKAGES += qtopia-free
endif

#
# Paths and names
#
ifndef PTXCONF_QTOPIA-FREE2
QTOPIA-FREE_VERSION	= 1.7.1
QTOPIA-FREE		= qtopia-free-$(QTOPIA-FREE_VERSION)-snapshot-20041024
###QTOPIA-FREE_VERSION	= 1.7.0
###QTOPIA-FREE		= qtopia-free-$(QTOPIA-FREE_VERSION)
QTOPIA-FREE_DIR		= $(BUILDDIR)/$(QTOPIA-FREE)
else
QTOPIA-FREE_VERSION	= 2.1.0
QTOPIA-FREE		= qtopia-free-source-$(QTOPIA-FREE_VERSION)
QTOPIA-FREE_DIR		= $(BUILDDIR)/qtopia-free-$(QTOPIA-FREE_VERSION)
endif
QTOPIA-FREE_SUFFIX	= tar.bz2
QTOPIA-FREE_URL		= ftp://ftp.trolltech.com/qtopia/source/$(QTOPIA-FREE).$(QTOPIA-FREE_SUFFIX)
QTOPIA-FREE_SOURCE	= $(SRCDIR)/$(QTOPIA-FREE).$(QTOPIA-FREE_SUFFIX)
QTOPIA-FREE_IPKG_TMP	= $(QTOPIA-FREE_DIR)/ipkg_tmp

# ----------------------------------------------------------------------------
# Get
# ----------------------------------------------------------------------------

qtopia-free_get: $(STATEDIR)/qtopia-free.get

qtopia-free_get_deps = $(QTOPIA-FREE_SOURCE)

$(STATEDIR)/qtopia-free.get: $(qtopia-free_get_deps)
	@$(call targetinfo, $@)
	@$(call get_patches, $(QTOPIA-FREE))
	touch $@

$(QTOPIA-FREE_SOURCE):
	@$(call targetinfo, $@)
	@$(call get, $(QTOPIA-FREE_URL))

# ----------------------------------------------------------------------------
# Extract
# ----------------------------------------------------------------------------

qtopia-free_extract: $(STATEDIR)/qtopia-free.extract

qtopia-free_extract_deps = $(STATEDIR)/qtopia-free.get

$(STATEDIR)/qtopia-free.extract: $(qtopia-free_extract_deps)
	@$(call targetinfo, $@)
	@$(call clean,   $(QTOPIA-FREE_DIR))
	@$(call extract, $(QTOPIA-FREE_SOURCE))
	@$(call patchin, $(QTOPIA-FREE), $(QTOPIA-FREE_DIR))
	touch $@

# ----------------------------------------------------------------------------
# Prepare
# ----------------------------------------------------------------------------

qtopia-free_prepare: $(STATEDIR)/qtopia-free.prepare

#
# dependencies
#
qtopia-free_prepare_deps = \
	$(STATEDIR)/qtopia-free.extract \
	$(STATEDIR)/e2fsprogs.install \
	$(STATEDIR)/jpeg.install \
	$(STATEDIR)/libpng125.install \
	$(STATEDIR)/qt-embedded.install \
	$(STATEDIR)/xchain-qt-x11.install \
	$(STATEDIR)/xchain-tmake.install \
	$(STATEDIR)/virtual-xchain.install

QTOPIA-FREE_PATH	=  PATH=$(PTXCONF_PREFIX)/tmake/bin:$(QT-EMBEDDED_DIR)/bin:$(QTOPIA-FREE_DIR)/bin:$(CROSS_PATH)
QTOPIA-FREE_ENV 	=  $(CROSS_ENV)
###QTOPIA-FREE_ENV		+= QTDIR=$(QTOPIA-FREE_DIR)
QTOPIA-FREE_ENV		+= QPEDIR=$(QTOPIA-FREE_DIR)
QTOPIA-FREE_ENV		+= QTDIR=$(QT-EMBEDDED_DIR)
QTOPIA-FREE_ENV		+= QTEDIR=$(QT-EMBEDDED_DIR)

QTOPIA-FREE_ENV		+= PKG_CONFIG_PATH=$(CROSS_LIB_DIR)/lib/pkgconfig:$(CROSS_LIB_DIR)/lib/pkgconfig

#
# autoconf
#
QTOPIA-FREE_AUTOCONF	= -shared -release
#QTOPIA-FREE_AUTOCONF	+= -noquicklaunch 

ifdef PTXCONF_QTOPIA-FREE-SL5500
ifndef PTXCONF_QTOPIA-FREE2
QTOPIA-FREE_AUTOCONF	+= -platform linux-sharp-g++
else
QTOPIA-FREE_AUTOCONF	+= -xplatform linux-sharp-g++ -with-libmad -with-libffmpeg -with-libamr
QTOPIA-FREE_QMAKESPEC	= $(QTOPIA-FREE_DIR)/mkspecs/qws/linux-sharp-g++
endif
QTOPIA-FREE_ENV		+= TMAKEPATH=$(PTXCONF_PREFIX)/tmake/lib/qws/linux-sharp-g++
endif

ifdef PTXCONF_QTOPIA-FREE-IPAQ
ifndef PTXCONF_QTOPIA-FREE2
QTOPIA-FREE_AUTOCONF	+= -platform linux-ipaq-g++
else
QTOPIA-FREE_AUTOCONF	+= -xplatform linux-ipaq-g++ -with-libmad -with-libffmpeg -with-libamr
QTOPIA-FREE_QMAKESPEC	= $(QTOPIA-FREE_DIR)/mkspecs/qws/linux-ipaq-g++
endif
QTOPIA-FREE_ENV		+= TMAKEPATH=$(PTXCONF_PREFIX)/tmake/lib/qws/linux-ipaq-g++
endif

$(STATEDIR)/qtopia-free.prepare: $(qtopia-free_prepare_deps)
	@$(call targetinfo, $@)
	@$(call clean, $(QTOPIA-FREE_DIR)/config.cache)
	install -s -m 755 $(XCHAIN_QT-X11_DIR)/bin/uic $(QT-EMBEDDED_DIR)/bin
	install -m 644 $(KERNEL_DIR)/include/asm/mach-types.h $(CROSS_LIB_DIR)/include/asm/
	install -m 644 $(KERNEL_DIR)/include/linux/autoconf.h $(CROSS_LIB_DIR)/include/linux/
	###ln -sf $(QTOPIA-FREE_DIR)/include/qtopia/qwizard.h $(QT-EMBEDDED_DIR)/include/qwizard.h
	#ln -sf qtopia/qwizard.h $(QTOPIA-FREE_DIR)/include/qwizard.h
ifndef PTXCONF_QTOPIA-FREE2
	cd $(QTOPIA-FREE_DIR)/src && \
		$(QTOPIA-FREE_PATH) $(QTOPIA-FREE_ENV) \
		./configure $(QTOPIA-FREE_AUTOCONF)
else
	cd $(QTOPIA-FREE_DIR) && \
		$(QTOPIA-FREE_PATH) $(QTOPIA-FREE_ENV) \
		./configure $(QTOPIA-FREE_AUTOCONF)
endif
	touch $@

# ----------------------------------------------------------------------------
# Compile
# ----------------------------------------------------------------------------

qtopia-free_compile: $(STATEDIR)/qtopia-free.compile

qtopia-free_compile_deps = $(STATEDIR)/qtopia-free.prepare

$(STATEDIR)/qtopia-free.compile: $(qtopia-free_compile_deps)
	@$(call targetinfo, $@)
	$(QTOPIA-FREE_PATH) $(QTOPIA-FREE_ENV) $(MAKE) -C $(QTOPIA-FREE_DIR)/src
	touch $@

# ----------------------------------------------------------------------------
# Install
# ----------------------------------------------------------------------------

qtopia-free_install: $(STATEDIR)/qtopia-free.install

$(STATEDIR)/qtopia-free.install: $(STATEDIR)/qtopia-free.compile
	@$(call targetinfo, $@)
	touch $@

# ----------------------------------------------------------------------------
# Target-Install
# ----------------------------------------------------------------------------

qtopia-free_targetinstall: $(STATEDIR)/qtopia-free.targetinstall

qtopia-free_targetinstall_deps = $(STATEDIR)/qtopia-free.compile \
	$(STATEDIR)/libpng125.targetinstall \
	$(STATEDIR)/zlib.targetinstall \
	$(STATEDIR)/jpeg.targetinstall \
	$(STATEDIR)/zoneinfo.targetinstall \
	$(STATEDIR)/jpeg.targetinstall

$(STATEDIR)/qtopia-free.targetinstall: $(qtopia-free_targetinstall_deps)
	@$(call targetinfo, $@)
	rm -f $(QTOPIA-FREE_DIR)/lib/fonts
	ln -sf $(QT-EMBEDDED_DIR)/lib/fonts $(QTOPIA-FREE_DIR)/lib/fonts
	rm -f $(QTOPIA-FREE_DIR)/lib/libqte.*
	cp -a $(QT-EMBEDDED_DIR)/lib/libqte.* $(QTOPIA-FREE_DIR)/lib/
	$(CROSSSTRIP) $(QTOPIA-FREE_DIR)/lib/libqte.*
	$(CROSSSTRIP) $(QT-EMBEDDED_DIR)/lib/libqte.so.*
	###$(QTOPIA-FREE_PATH) $(QTOPIA-FREE_ENV) QTE_VERSION=$(QT-EMBEDDED_VERSION) QPE_VERSION=$(QTOPIA-FREE_VERSION) $(MAKE) -C $(QTOPIA-FREE_DIR)/src install
	$(QTOPIA-FREE_PATH) $(QTOPIA-FREE_ENV) QTE_VERSION=$(QT-EMBEDDED_VERSION) QPE_VERSION=$(QTOPIA-FREE_VERSION) $(MAKE) -C $(QTOPIA-FREE_DIR)/src packages
	###$(QTOPIA-FREE_PATH) $(MAKE) -C $(QTOPIA-FREE_DIR) DESTDIR=$(QTOPIA-FREE_IPKG_TMP) install
	cp -a $(QTOPIA-FREE_DIR)/ipkg/*.ipk $(TOPDIR)/bootdisk/feed/
	###$(INSTALL) -D -m 755 $(TOPDIR)/config/pdaXrom/runqpe.sh $(QTOPIA-FREE_IPKG_TMP)/opt/Qtopia/runqpe.sh
	mkdir -p $(QTOPIA-FREE_IPKG_TMP)/opt
	ln -sf /opt/Qtopia $(QTOPIA-FREE_IPKG_TMP)/opt/QtPalmtop
	mkdir -p $(QTOPIA-FREE_IPKG_TMP)/CONTROL
	echo "Package: qtopia-free" 								>$(QTOPIA-FREE_IPKG_TMP)/CONTROL/control
	echo "Priority: optional" 								>>$(QTOPIA-FREE_IPKG_TMP)/CONTROL/control
	echo "Section: Qtopia" 									>>$(QTOPIA-FREE_IPKG_TMP)/CONTROL/control
	echo "Maintainer: Alexander Chukov <sash@pdaXrom.org>" 					>>$(QTOPIA-FREE_IPKG_TMP)/CONTROL/control
	echo "Architecture: $(SHORT_TARGET)" 							>>$(QTOPIA-FREE_IPKG_TMP)/CONTROL/control
	echo "Version: $(QTOPIA-FREE_VERSION)" 							>>$(QTOPIA-FREE_IPKG_TMP)/CONTROL/control
	echo "Depends: qpe-base, qpe-quicklauncher, qpe-taskbar, qt-embedded-fonts-t10, libpng, libjpeg, libz" >>$(QTOPIA-FREE_IPKG_TMP)/CONTROL/control
	echo "Description: generated with pdaXrom builder"					>>$(QTOPIA-FREE_IPKG_TMP)/CONTROL/control
	cd $(FEEDDIR) && $(XMKIPKG) $(QTOPIA-FREE_IPKG_TMP)
	touch $@

# ----------------------------------------------------------------------------
# Image-Install
# ----------------------------------------------------------------------------

ifdef PTXCONF_QTOPIA-FREE_INSTALL
ROMPACKAGES += $(STATEDIR)/qtopia-free.imageinstall
endif

qtopia-free_imageinstall_deps = $(STATEDIR)/qtopia-free.targetinstall \
	$(STATEDIR)/virtual-image.install

$(STATEDIR)/qtopia-free.imageinstall: $(qtopia-free_imageinstall_deps)
	@$(call targetinfo, $@)
ifdef PTXCONF_QTOPIA-FREE2
	cd $(FEEDDIR) && $(XIPKG) install qtopia-free
	cd $(FEEDDIR) && $(XIPKG) install qpe-netsetup
	cd $(FEEDDIR) && $(XIPKG) install qpe-embeddedkonsole
	cd $(FEEDDIR) && $(XIPKG) install qpe-systemtime
	cd $(FEEDDIR) && $(XIPKG) install qpe-sysinfo
	cd $(FEEDDIR) && $(XIPKG) install qpe-worldtime
	cd $(FEEDDIR) && $(XIPKG) install qpe-textedit
else
	cd $(FEEDDIR) && $(XIPKG) install qtopia-free
ifdef PTXCONF_QTOPIA-FREE_INSTALL_ADDRESSBOOK
	cd $(FEEDDIR) && $(XIPKG) install qpe-addressbook
endif
ifdef PTXCONF_QTOPIA-FREE_INSTALL_APPEARANCE
	cd $(FEEDDIR) && $(XIPKG) install qpe-appearance
endif
ifdef PTXCONF_QTOPIA-FREE_INSTALL_APPSERVICES
	cd $(FEEDDIR) && $(XIPKG) install qpe-appservices
endif
ifdef PTXCONF_QTOPIA-FREE_INSTALL_BATTERYAPPLET
	cd $(FEEDDIR) && $(XIPKG) install qpe-batteryapplet
endif
ifdef PTXCONF_QTOPIA-FREE_INSTALL_BRIGHTNESSAPPLET
	cd $(FEEDDIR) && $(XIPKG) install qpe-brightnessapplet
endif
ifdef PTXCONF_QTOPIA-FREE_INSTALL_CALCULATOR-ADVANCED
	cd $(FEEDDIR) && $(XIPKG) install qpe-calculator-advanced
endif
ifdef PTXCONF_QTOPIA-FREE_INSTALL_CALCULATOR
	cd $(FEEDDIR) && $(XIPKG) install qpe-calculator
endif
ifdef PTXCONF_QTOPIA-FREE_INSTALL_CARDMON
	cd $(FEEDDIR) && $(XIPKG) install qpe-cardmon
endif
ifdef PTXCONF_QTOPIA-FREE_INSTALL_CLIPBOARDAPPLET
	cd $(FEEDDIR) && $(XIPKG) install qpe-clipboardapplet
endif
ifdef PTXCONF_QTOPIA-FREE_INSTALL_CLOCK
	cd $(FEEDDIR) && $(XIPKG) install qpe-clock
endif
ifdef PTXCONF_QTOPIA-FREE_INSTALL_CLOCKAPPLET
	cd $(FEEDDIR) && $(XIPKG) install qpe-clockapplet
endif
ifdef PTXCONF_QTOPIA-FREE_INSTALL_DATEBOOK
	cd $(FEEDDIR) && $(XIPKG) install qpe-datebook
endif
ifdef PTXCONF_QTOPIA-FREE_INSTALL_EMBEDDEDKONSOLE
	cd $(FEEDDIR) && $(XIPKG) install qpe-embeddedkonsole
endif
ifdef PTXCONF_QTOPIA-FREE_INSTALL_FIFTEEN
	cd $(FEEDDIR) && $(XIPKG) install qpe-fifteen
endif
ifdef PTXCONF_QTOPIA-FREE_INSTALL_FILEBROWSER
	cd $(FEEDDIR) && $(XIPKG) install qpe-filebrowser
endif
ifdef PTXCONF_QTOPIA-FREE_INSTALL_FLAT
	cd $(FEEDDIR) && $(XIPKG) install qpe-flat
endif
ifdef PTXCONF_QTOPIA-FREE_INSTALL_FLATSTYLE
	cd $(FEEDDIR) && $(XIPKG) install qpe-flatstyle
endif
ifdef PTXCONF_QTOPIA-FREE_INSTALL_FREETYPE
	cd $(FEEDDIR) && $(XIPKG) install qpe-freetype
endif
ifdef PTXCONF_QTOPIA-FREE_INSTALL_FRESH
	cd $(FEEDDIR) && $(XIPKG) install qpe-fresh
endif
ifdef PTXCONF_QTOPIA-FREE_INSTALL_HANDWRITING
	cd $(FEEDDIR) && $(XIPKG) install qpe-handwriting
endif
ifdef PTXCONF_QTOPIA-FREE_INSTALL_HELP-EN
	cd $(FEEDDIR) && $(XIPKG) install qpe-help-en
endif
ifdef PTXCONF_QTOPIA-FREE_INSTALL_HELPBROWSER
	cd $(FEEDDIR) && $(XIPKG) install qpe-helpbrowser
endif
ifdef PTXCONF_QTOPIA-FREE_INSTALL_I18N-EN
	cd $(FEEDDIR) && $(XIPKG) install qpe-i18n-en
endif
ifdef PTXCONF_QTOPIA-FREE_INSTALL_IRRECEIVERAPPLET
	cd $(FEEDDIR) && $(XIPKG) install qpe-irreceiverapplet
endif
ifdef PTXCONF_QTOPIA-FREE_INSTALL_JP-TEXTCODEC
	cd $(FEEDDIR) && $(XIPKG) install qpe-jp-textcodec
endif
ifdef PTXCONF_QTOPIA-FREE_INSTALL_KEYBOARD
	cd $(FEEDDIR) && $(XIPKG) install qpe-keyboard
endif
ifdef PTXCONF_QTOPIA-FREE_INSTALL_KEYPEBBLE
	cd $(FEEDDIR) && $(XIPKG) install qpe-keypebble
endif
ifdef PTXCONF_QTOPIA-FREE_INSTALL_LANGUAGE
	cd $(FEEDDIR) && $(XIPKG) install qpe-language
endif
ifdef PTXCONF_QTOPIA-FREE_INSTALL_LAUNCHER-SETTINGS
	cd $(FEEDDIR) && $(XIPKG) install qpe-launcher-settings
endif
ifdef PTXCONF_QTOPIA-FREE_INSTALL_LIGHT-AND-POWER
	cd $(FEEDDIR) && $(XIPKG) install qpe-light-and-power
endif
ifdef PTXCONF_QTOPIA-FREE_INSTALL_MEDIAPLAYER-TECHNO-SKIN
	cd $(FEEDDIR) && $(XIPKG) install qpe-mediaplayer-techno-skin
endif
ifdef PTXCONF_QTOPIA-FREE_INSTALL_MEDIARECORDER
	cd $(FEEDDIR) && $(XIPKG) install qpe-mediarecorder
endif
ifdef PTXCONF_QTOPIA-FREE_INSTALL_MINDBREAKER
	cd $(FEEDDIR) && $(XIPKG) install qpe-mindbreaker
endif
ifdef PTXCONF_QTOPIA-FREE_INSTALL_MINESWEEP
	cd $(FEEDDIR) && $(XIPKG) install qpe-minesweep
endif
ifdef PTXCONF_QTOPIA-FREE_INSTALL_MPEGPLAYER
	cd $(FEEDDIR) && $(XIPKG) install qpe-mpegplayer
endif
ifdef PTXCONF_QTOPIA-FREE_INSTALL_NETMONAPPLET
	cd $(FEEDDIR) && $(XIPKG) install qpe-netmonapplet
endif
ifdef PTXCONF_QTOPIA-FREE_INSTALL_NETSETUP
	cd $(FEEDDIR) && $(XIPKG) install qpe-netsetup
endif
ifdef PTXCONF_QTOPIA-FREE_INSTALL_NOTEPAD-IMAGECODEC
	cd $(FEEDDIR) && $(XIPKG) install qpe-notepad-imagecodec
endif
ifdef PTXCONF_QTOPIA-FREE_INSTALL_OBEX
	cd $(FEEDDIR) && $(XIPKG) install qpe-obex
endif
ifdef PTXCONF_QTOPIA-FREE_INSTALL_PARASHOOT
	cd $(FEEDDIR) && $(XIPKG) install qpe-parashoot
endif
ifdef PTXCONF_QTOPIA-FREE_INSTALL_PICKBOARD
	cd $(FEEDDIR) && $(XIPKG) install qpe-pickboard
endif
ifdef PTXCONF_QTOPIA-FREE_INSTALL_PIM
	cd $(FEEDDIR) && $(XIPKG) install qpe-pim
endif
ifdef PTXCONF_QTOPIA-FREE_INSTALL_PLUGINMANAGER
	cd $(FEEDDIR) && $(XIPKG) install qpe-pluginmanager
endif
ifdef PTXCONF_QTOPIA-FREE_INSTALL_POLISHED
	cd $(FEEDDIR) && $(XIPKG) install qpe-polished
endif
ifdef PTXCONF_QTOPIA-FREE_INSTALL_QASTEROIDS
	cd $(FEEDDIR) && $(XIPKG) install qpe-qasteroids
endif
ifdef PTXCONF_QTOPIA-FREE_INSTALL_QIPKG
	cd $(FEEDDIR) && $(XIPKG) install qpe-qipkg
endif
ifdef PTXCONF_QTOPIA-FREE_INSTALL_ROTATION
	cd $(FEEDDIR) && $(XIPKG) install qpe-rotation
endif
ifdef PTXCONF_QTOPIA-FREE_INSTALL_SECURITY
	cd $(FEEDDIR) && $(XIPKG) install qpe-security
endif
ifdef PTXCONF_QTOPIA-FREE_INSTALL_SERVICE-CALENDAR
	cd $(FEEDDIR) && $(XIPKG) install qpe-service-calendar
endif
ifdef PTXCONF_QTOPIA-FREE_INSTALL_SERVICE-CONTACTS
	cd $(FEEDDIR) && $(XIPKG) install qpe-service-contacts
endif
ifdef PTXCONF_QTOPIA-FREE_INSTALL_SERVICE-EMAIL
	cd $(FEEDDIR) && $(XIPKG) install qpe-service-email
endif
ifdef PTXCONF_QTOPIA-FREE_INSTALL_SERVICE-TASKS
	cd $(FEEDDIR) && $(XIPKG) install qpe-service-tasks
endif
ifdef PTXCONF_QTOPIA-FREE_INSTALL_SERVICE-TIMEMONITOR
	cd $(FEEDDIR) && $(XIPKG) install qpe-service-timemonitor
endif
ifdef PTXCONF_QTOPIA-FREE_INSTALL_SHOWIMG
	cd $(FEEDDIR) && $(XIPKG) install qpe-showimg
endif
ifdef PTXCONF_QTOPIA-FREE_INSTALL_SIMPLE8-TEXTCODEC
	cd $(FEEDDIR) && $(XIPKG) install qpe-simple8-textcodec
endif
ifdef PTXCONF_QTOPIA-FREE_INSTALL_SNAKE
	cd $(FEEDDIR) && $(XIPKG) install qpe-snake
endif
ifdef PTXCONF_QTOPIA-FREE_INSTALL_SOLITAIRE
	cd $(FEEDDIR) && $(XIPKG) install qpe-solitaire
endif
ifdef PTXCONF_QTOPIA-FREE_INSTALL_SOUND
	cd $(FEEDDIR) && $(XIPKG) install qpe-sound
endif
ifdef PTXCONF_QTOPIA-FREE_INSTALL_SOUNDS
	cd $(FEEDDIR) && $(XIPKG) install qpe-sounds
endif
ifdef PTXCONF_QTOPIA-FREE_INSTALL_SYSINFO
	cd $(FEEDDIR) && $(XIPKG) install qpe-sysinfo
endif
ifdef PTXCONF_QTOPIA-FREE_INSTALL_SYSTEMTIME
	cd $(FEEDDIR) && $(XIPKG) install qpe-systemtime
endif
ifdef PTXCONF_QTOPIA-FREE_INSTALL_TEXTEDIT
	cd $(FEEDDIR) && $(XIPKG) install qpe-textedit
endif
ifdef PTXCONF_QTOPIA-FREE_INSTALL_TODAY-DATEBOOKPLUGIN
	cd $(FEEDDIR) && $(XIPKG) install qpe-today-datebookplugin
endif
ifdef PTXCONF_QTOPIA-FREE_INSTALL_TODAY-TODOPLUGIN
	cd $(FEEDDIR) && $(XIPKG) install qpe-today-todoplugin
endif
ifdef PTXCONF_QTOPIA-FREE_INSTALL_TODAY
	cd $(FEEDDIR) && $(XIPKG) install qpe-today
endif
ifdef PTXCONF_QTOPIA-FREE_INSTALL_TODO
	cd $(FEEDDIR) && $(XIPKG) install qpe-todo
endif
ifdef PTXCONF_QTOPIA-FREE_INSTALL_UNIKEYBOARD
	cd $(FEEDDIR) && $(XIPKG) install qpe-unikeyboard
endif
ifdef PTXCONF_QTOPIA-FREE_INSTALL_VOLUMEAPPLET
	cd $(FEEDDIR) && $(XIPKG) install qpe-volumeapplet
endif
ifdef PTXCONF_QTOPIA-FREE_INSTALL_WAVPLUGIN
	cd $(FEEDDIR) && $(XIPKG) install qpe-wavplugin
endif
ifdef PTXCONF_QTOPIA-FREE_INSTALL_WAVRECORD
	cd $(FEEDDIR) && $(XIPKG) install qpe-wavrecord
endif
ifdef PTXCONF_QTOPIA-FREE_INSTALL_WORDGAME
	cd $(FEEDDIR) && $(XIPKG) install qpe-wordgame
endif
ifdef PTXCONF_QTOPIA-FREE_INSTALL_WORLDTIME
	cd $(FEEDDIR) && $(XIPKG) install qpe-worldtime
endif
endif
	touch $@

# ----------------------------------------------------------------------------
# Clean
# ----------------------------------------------------------------------------

qtopia-free_clean:
	rm -rf $(STATEDIR)/qtopia-free.*
	rm -rf $(QTOPIA-FREE_DIR)

# vim: syntax=make
