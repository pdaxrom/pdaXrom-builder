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
ifdef PTXCONF_MATCHBOX-PANEL
PACKAGES += matchbox-panel
endif

#
# Paths and names
#
MATCHBOX-PANEL_VERSION		= 0.9.1
MATCHBOX-PANEL			= matchbox-panel-$(MATCHBOX-PANEL_VERSION)
MATCHBOX-PANEL_SUFFIX		= tar.bz2
###MATCHBOX-PANEL_URL		= http://matchbox.handhelds.org/sources/matchbox-panel/0.8/$(MATCHBOX-PANEL).$(MATCHBOX-PANEL_SUFFIX)
MATCHBOX-PANEL_URL		= http://projects.o-hand.com/matchbox/sources/matchbox-panel/0.9/$(MATCHBOX-PANEL).$(MATCHBOX-PANEL_SUFFIX)
MATCHBOX-PANEL_SOURCE		= $(SRCDIR)/$(MATCHBOX-PANEL).$(MATCHBOX-PANEL_SUFFIX)
MATCHBOX-PANEL_DIR		= $(BUILDDIR)/$(MATCHBOX-PANEL)
MATCHBOX-PANEL_ROOTDIR		= $(MATCHBOX-PANEL_DIR)/ipkg_tmp
MATCHBOX-PANEL_VENDOR-VERSION	= $(MATCHBOX-PANEL_VERSION)-1

# ----------------------------------------------------------------------------
# Get
# ----------------------------------------------------------------------------

matchbox-panel_get: $(STATEDIR)/matchbox-panel.get

matchbox-panel_get_deps = $(MATCHBOX-PANEL_SOURCE)

$(STATEDIR)/matchbox-panel.get: $(matchbox-panel_get_deps)
	@$(call targetinfo, $@)
	@$(call get_patches, $(MATCHBOX-PANEL))
	touch $@

$(MATCHBOX-PANEL_SOURCE):
	@$(call targetinfo, $@)
	@$(call get, $(MATCHBOX-PANEL_URL))

# ----------------------------------------------------------------------------
# Extract
# ----------------------------------------------------------------------------

matchbox-panel_extract: $(STATEDIR)/matchbox-panel.extract

matchbox-panel_extract_deps = $(STATEDIR)/matchbox-panel.get

$(STATEDIR)/matchbox-panel.extract: $(matchbox-panel_extract_deps)
	@$(call targetinfo, $@)
	@$(call clean, $(MATCHBOX-PANEL_DIR))
	@$(call extract, $(MATCHBOX-PANEL_SOURCE))
	@$(call patchin, $(MATCHBOX-PANEL))
	touch $@

# ----------------------------------------------------------------------------
# Prepare
# ----------------------------------------------------------------------------

matchbox-panel_prepare: $(STATEDIR)/matchbox-panel.prepare

#
# dependencies
#
matchbox-panel_prepare_deps = \
	$(STATEDIR)/matchbox-panel.extract \
	$(STATEDIR)/libmatchbox.install \
	$(STATEDIR)/virtual-xchain.install

MATCHBOX-PANEL_PATH	=  PATH=$(CROSS_PATH)
MATCHBOX-PANEL_ENV 	=  $(CROSS_ENV)
#MATCHBOX-PANEL_ENV	+=
MATCHBOX-PANEL_ENV	+= PKG_CONFIG_PATH=$(CROSS_LIB_DIR)/lib/pkgconfig:$(CROSS_LIB_DIR)/lib/pkgconfig
MATCHBOX-PANEL_ENV	+= LDFLAGS="-lm"

#
# autoconf
#
MATCHBOX-PANEL_AUTOCONF = \
	--build=$(GNU_HOST) \
	--host=$(PTXCONF_GNU_TARGET) \
	--prefix=/usr \
	--x-includes=$(CROSS_LIB_DIR)/include \
	--x-libraries=$(CROSS_LIB_DIR)/lib \
	--disable-debug \
	--enable-startup-notification \
	--sysconfdir=/etc \
	--enable-nls \
	--sysconfdir=/etc

$(STATEDIR)/matchbox-panel.prepare: $(matchbox-panel_prepare_deps)
	@$(call targetinfo, $@)
	@$(call clean, $(MATCHBOX-PANEL_DIR)/config.cache)
	cd $(MATCHBOX-PANEL_DIR) && \
		$(MATCHBOX-PANEL_PATH) $(MATCHBOX-PANEL_ENV) \
		./configure $(MATCHBOX-PANEL_AUTOCONF)
	touch $@

# ----------------------------------------------------------------------------
# Compile
# ----------------------------------------------------------------------------

matchbox-panel_compile: $(STATEDIR)/matchbox-panel.compile

matchbox-panel_compile_deps = $(STATEDIR)/matchbox-panel.prepare

$(STATEDIR)/matchbox-panel.compile: $(matchbox-panel_compile_deps)
	@$(call targetinfo, $@)
	$(MATCHBOX-PANEL_PATH) $(MAKE) -C $(MATCHBOX-PANEL_DIR)
	touch $@

# ----------------------------------------------------------------------------
# Install
# ----------------------------------------------------------------------------

matchbox-panel_install: $(STATEDIR)/matchbox-panel.install

$(STATEDIR)/matchbox-panel.install: $(STATEDIR)/matchbox-panel.compile
	@$(call targetinfo, $@)
	#$(MATCHBOX-PANEL_PATH) $(MAKE) -C $(MATCHBOX-PANEL_DIR) install
	touch $@

# ----------------------------------------------------------------------------
# Target-Install
# ----------------------------------------------------------------------------

matchbox-panel_targetinstall: $(STATEDIR)/matchbox-panel.targetinstall

matchbox-panel_targetinstall_deps = $(STATEDIR)/matchbox-panel.compile \
	$(STATEDIR)/matchbox-common.targetinstall \
	$(STATEDIR)/libmatchbox.targetinstall

$(STATEDIR)/matchbox-panel.targetinstall: $(matchbox-panel_targetinstall_deps)
	@$(call targetinfo, $@)
	$(MATCHBOX-PANEL_PATH) $(MAKE) -C $(MATCHBOX-PANEL_DIR) DESTDIR=$(MATCHBOX-PANEL_ROOTDIR) install mkdir_p="mkdir -p"
	$(CROSSSTRIP) $(MATCHBOX-PANEL_ROOTDIR)/usr/bin/matchbox-panel
	$(CROSSSTRIP) $(MATCHBOX-PANEL_ROOTDIR)/usr/bin/mb-applet-battery
	$(CROSSSTRIP) $(MATCHBOX-PANEL_ROOTDIR)/usr/bin/mb-applet-clock
	$(CROSSSTRIP) $(MATCHBOX-PANEL_ROOTDIR)/usr/bin/mb-applet-launcher
	$(CROSSSTRIP) $(MATCHBOX-PANEL_ROOTDIR)/usr/bin/mb-applet-menu-launcher
	$(CROSSSTRIP) $(MATCHBOX-PANEL_ROOTDIR)/usr/bin/mb-applet-system-monitor
	$(CROSSSTRIP) $(MATCHBOX-PANEL_ROOTDIR)/usr/bin/mb-applet-wireless
ifdef PTXCONF_MB-APPLET-POWER
	rm -f $(MATCHBOX-PANEL_ROOTDIR)/usr/bin/mb-applet-battery $(MATCHBOX-PANEL_ROOTDIR)/usr/share/applications/mb-applet-battery.desktop
endif
ifdef PTXCONF_MB-APPLET-CLOCK
	rm -f $(MATCHBOX-PANEL_ROOTDIR)/usr/bin/mb-applet-clock $(MATCHBOX-PANEL_ROOTDIR)/usr/share/applications/mb-applet-clock.desktop
endif
	cp -f $(TOPDIR)/config/pics/starticon.png 	  $(MATCHBOX-PANEL_ROOTDIR)/usr/share/pixmaps/mbmenu.png
	rm -rf $(MATCHBOX-PANEL_ROOTDIR)/usr/share/locale
	mkdir -p $(MATCHBOX-PANEL_ROOTDIR)/CONTROL
	echo "Package: matchbox-panel"	 							 >$(MATCHBOX-PANEL_ROOTDIR)/CONTROL/control
	echo "Priority: optional" 								>>$(MATCHBOX-PANEL_ROOTDIR)/CONTROL/control
	echo "Section: Matchbox" 								>>$(MATCHBOX-PANEL_ROOTDIR)/CONTROL/control
	echo "Maintainer: Alexander Chukov <sash@pdaXrom.org>"					>>$(MATCHBOX-PANEL_ROOTDIR)/CONTROL/control
	echo "Architecture: $(SHORT_TARGET)" 							>>$(MATCHBOX-PANEL_ROOTDIR)/CONTROL/control
	echo "Version: $(MATCHBOX-PANEL_VENDOR-VERSION)" 					>>$(MATCHBOX-PANEL_ROOTDIR)/CONTROL/control
	echo "Depends: matchbox-common, libmatchbox"						>>$(MATCHBOX-PANEL_ROOTDIR)/CONTROL/control
	echo "Description: Matchbox panel"							>>$(MATCHBOX-PANEL_ROOTDIR)/CONTROL/control
	cd $(FEEDDIR) && $(XMKIPKG) $(MATCHBOX-PANEL_ROOTDIR)
	touch $@

# ----------------------------------------------------------------------------
# Image-Install
# ----------------------------------------------------------------------------

ifdef PTXCONF_MATCHBOX-PANEL_INSTALL
ROMPACKAGES += $(STATEDIR)/matchbox-panel.imageinstall
endif

matchbox-panel_imageinstall_deps = $(STATEDIR)/matchbox-panel.targetinstall \
	$(STATEDIR)/virtual-image.install \
	$(STATEDIR)/matchbox-common.imageinstall \
	$(STATEDIR)/libmatchbox.imageinstall

$(STATEDIR)/matchbox-panel.imageinstall: $(matchbox-panel_imageinstall_deps)
	@$(call targetinfo, $@)
	cd $(FEEDDIR) && $(XIPKG) install matchbox-panel
	touch $@

# ----------------------------------------------------------------------------
# Clean
# ----------------------------------------------------------------------------

matchbox-panel_clean:
	rm -rf $(STATEDIR)/matchbox-panel.*
	rm -rf $(MATCHBOX-PANEL_DIR)

# vim: syntax=make
