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
ifdef PTXCONF_MATCHBOX-DESKTOP
PACKAGES += matchbox-desktop
endif

#
# Paths and names
#
MATCHBOX-DESKTOP_VERSION	= 0.9.1
MATCHBOX-DESKTOP		= matchbox-desktop-$(MATCHBOX-DESKTOP_VERSION)
MATCHBOX-DESKTOP_SUFFIX		= tar.bz2
###MATCHBOX-DESKTOP_URL		= http://matchbox.handhelds.org/sources/matchbox-desktop/$(MATCHBOX-DESKTOP_VERSION)/$(MATCHBOX-DESKTOP).$(MATCHBOX-DESKTOP_SUFFIX)
MATCHBOX-DESKTOP_URL		= http://projects.o-hand.com/matchbox/sources/matchbox-desktop/0.9/$(MATCHBOX-DESKTOP).$(MATCHBOX-DESKTOP_SUFFIX)
MATCHBOX-DESKTOP_SOURCE		= $(SRCDIR)/$(MATCHBOX-DESKTOP).$(MATCHBOX-DESKTOP_SUFFIX)
MATCHBOX-DESKTOP_DIR		= $(BUILDDIR)/$(MATCHBOX-DESKTOP)
MATCHBOX-DESKTOP_ROOTDIR	= $(MATCHBOX-DESKTOP_DIR)/ipkg_tmp
# ----------------------------------------------------------------------------
# Get
# ----------------------------------------------------------------------------

matchbox-desktop_get: $(STATEDIR)/matchbox-desktop.get

matchbox-desktop_get_deps = $(MATCHBOX-DESKTOP_SOURCE)

$(STATEDIR)/matchbox-desktop.get: $(matchbox-desktop_get_deps)
	@$(call targetinfo, $@)
	@$(call get_patches, $(MATCHBOX-DESKTOP))
	touch $@

$(MATCHBOX-DESKTOP_SOURCE):
	@$(call targetinfo, $@)
	@$(call get, $(MATCHBOX-DESKTOP_URL))

# ----------------------------------------------------------------------------
# Extract
# ----------------------------------------------------------------------------

matchbox-desktop_extract: $(STATEDIR)/matchbox-desktop.extract

matchbox-desktop_extract_deps = $(STATEDIR)/matchbox-desktop.get

$(STATEDIR)/matchbox-desktop.extract: $(matchbox-desktop_extract_deps)
	@$(call targetinfo, $@)
	@$(call clean, $(MATCHBOX-DESKTOP_DIR))
	@$(call extract, $(MATCHBOX-DESKTOP_SOURCE))
	@$(call patchin, $(MATCHBOX-DESKTOP))
	touch $@

# ----------------------------------------------------------------------------
# Prepare
# ----------------------------------------------------------------------------

matchbox-desktop_prepare: $(STATEDIR)/matchbox-desktop.prepare

#
# dependencies
#
matchbox-desktop_prepare_deps = \
	$(STATEDIR)/matchbox-desktop.extract \
	$(STATEDIR)/libmatchbox.install \
	$(STATEDIR)/virtual-xchain.install

MATCHBOX-DESKTOP_PATH	=  PATH=$(CROSS_PATH)
MATCHBOX-DESKTOP_ENV 	=  $(CROSS_ENV)
#MATCHBOX-DESKTOP_ENV	+=
MATCHBOX-DESKTOP_ENV	+= PKG_CONFIG_PATH=$(CROSS_LIB_DIR)/lib/pkgconfig:$(CROSS_LIB_DIR)/lib/pkgconfig
MATCHBOX-DESKTOP_ENV	+= LDFLAGS="-lm"

#
# autoconf
#
MATCHBOX-DESKTOP_AUTOCONF = \
	--build=$(GNU_HOST) \
	--host=$(PTXCONF_GNU_TARGET) \
	--prefix=/usr \
	--x-includes=$(CROSS_LIB_DIR)/include \
	--x-libraries=$(CROSS_LIB_DIR)/lib \
	--disable-debug \
	--enable-startup-notification \
	--sysconfdir=/etc
#	--enable-dnotify

$(STATEDIR)/matchbox-desktop.prepare: $(matchbox-desktop_prepare_deps)
	@$(call targetinfo, $@)
	@$(call clean, $(MATCHBOX-DESKTOP_DIR)/config.cache)
	cd $(MATCHBOX-DESKTOP_DIR) && \
		$(MATCHBOX-DESKTOP_PATH) $(MATCHBOX-DESKTOP_ENV) \
		./configure $(MATCHBOX-DESKTOP_AUTOCONF)
	touch $@

# ----------------------------------------------------------------------------
# Compile
# ----------------------------------------------------------------------------

matchbox-desktop_compile: $(STATEDIR)/matchbox-desktop.compile

matchbox-desktop_compile_deps = $(STATEDIR)/matchbox-desktop.prepare

$(STATEDIR)/matchbox-desktop.compile: $(matchbox-desktop_compile_deps)
	@$(call targetinfo, $@)
	$(MATCHBOX-DESKTOP_PATH) $(MAKE) -C $(MATCHBOX-DESKTOP_DIR)
	touch $@

# ----------------------------------------------------------------------------
# Install
# ----------------------------------------------------------------------------

matchbox-desktop_install: $(STATEDIR)/matchbox-desktop.install

$(STATEDIR)/matchbox-desktop.install: $(STATEDIR)/matchbox-desktop.compile
	@$(call targetinfo, $@)
	touch $@

# ----------------------------------------------------------------------------
# Target-Install
# ----------------------------------------------------------------------------

matchbox-desktop_targetinstall: $(STATEDIR)/matchbox-desktop.targetinstall

matchbox-desktop_targetinstall_deps = $(STATEDIR)/matchbox-desktop.compile \
	$(STATEDIR)/matchbox-common.targetinstall \
	$(STATEDIR)/libmatchbox.targetinstall


$(STATEDIR)/matchbox-desktop.targetinstall: $(matchbox-desktop_targetinstall_deps)
	@$(call targetinfo, $@)
	$(MATCHBOX-DESKTOP_PATH) $(MAKE) -C $(MATCHBOX-DESKTOP_DIR) DESTDIR=$(MATCHBOX-DESKTOP_ROOTDIR) install mkdir_p="mkdir -p"
	$(CROSSSTRIP) $(MATCHBOX-DESKTOP_ROOTDIR)/usr/bin/matchbox-desktop
	rm -rf $(MATCHBOX-DESKTOP_ROOTDIR)/usr/include
	rm -rf $(MATCHBOX-DESKTOP_ROOTDIR)/usr/lib/pkgconfig
	##rm -rf $(MATCHBOX-DESKTOP_ROOTDIR)/usr/share/matchbox/desktop/modules/*.a
	##rm -rf $(MATCHBOX-DESKTOP_ROOTDIR)/usr/share/matchbox/desktop/modules/*.la
	##$(CROSSSTRIP) $(MATCHBOX-DESKTOP_ROOTDIR)/usr/share/matchbox/desktop/modules/*.so

	rm -rf $(MATCHBOX-DESKTOP_ROOTDIR)/usr/lib/matchbox/desktop/*.a
	rm -rf $(MATCHBOX-DESKTOP_ROOTDIR)/usr/lib/matchbox/desktop/*.la
	$(CROSSSTRIP) $(MATCHBOX-DESKTOP_ROOTDIR)/usr/lib/matchbox/desktop/*.so

#ifdef PTXCONF_MATCHBOX-DESKTOP_INSTALL
	cp -f  $(TOPDIR)/config/pdaXrom/mbsession $(MATCHBOX-DESKTOP_ROOTDIR)/usr/bin
#endif
ifdef PTXCONF_MATCHBOX-PANEL_INSTALL
	rm -f $(MATCHBOX-DESKTOP_ROOTDIR)/usr/share/applications/mb-show-desktop.desktop
endif

	mkdir -p $(MATCHBOX-DESKTOP_ROOTDIR)/CONTROL
	echo "Package: matchbox-desktop" 		 >$(MATCHBOX-DESKTOP_ROOTDIR)/CONTROL/control
	echo "Priority: optional" 			>>$(MATCHBOX-DESKTOP_ROOTDIR)/CONTROL/control
	echo "Section: Matchbox" 			>>$(MATCHBOX-DESKTOP_ROOTDIR)/CONTROL/control
	echo "Maintainer: Alexander Chukov <sash@pdaXrom.org>">>$(MATCHBOX-DESKTOP_ROOTDIR)/CONTROL/control
	echo "Architecture: $(SHORT_TARGET)" 		>>$(MATCHBOX-DESKTOP_ROOTDIR)/CONTROL/control
	echo "Version: $(MATCHBOX-DESKTOP_VERSION)" 	>>$(MATCHBOX-DESKTOP_ROOTDIR)/CONTROL/control
	echo "Depends: matchbox-common, libmatchbox"	>>$(MATCHBOX-DESKTOP_ROOTDIR)/CONTROL/control
	echo "Description: Matchbox desktop"		>>$(MATCHBOX-DESKTOP_ROOTDIR)/CONTROL/control
	cd $(FEEDDIR) && $(XMKIPKG) $(MATCHBOX-DESKTOP_ROOTDIR)
	touch $@

# ----------------------------------------------------------------------------
# Image-Install
# ----------------------------------------------------------------------------

ifdef PTXCONF_MATCHBOX-DESKTOP_INSTALL
ROMPACKAGES += $(STATEDIR)/matchbox-desktop.imageinstall
endif

matchbox-desktop_imageinstall_deps = $(STATEDIR)/matchbox-desktop.targetinstall \
	$(STATEDIR)/virtual-image.install \
	$(STATEDIR)/matchbox-common.imageinstall \
	$(STATEDIR)/libmatchbox.imageinstall

$(STATEDIR)/matchbox-desktop.imageinstall: $(matchbox-desktop_imageinstall_deps)
	@$(call targetinfo, $@)
	cd $(FEEDDIR) && $(XIPKG) install matchbox-desktop
	touch $@

# ----------------------------------------------------------------------------
# Clean
# ----------------------------------------------------------------------------

matchbox-desktop_clean:
	rm -rf $(STATEDIR)/matchbox-desktop.*
	rm -rf $(MATCHBOX-DESKTOP_DIR)

# vim: syntax=make
