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
ifdef PTXCONF_GNOME-ICON-THEME
PACKAGES += gnome-icon-theme
endif

#
# Paths and names
#
#GNOME-ICON-THEME_VERSION	= 1.2.1
GNOME-ICON-THEME_VERSION	= 2.9.0
GNOME-ICON-THEME		= gnome-icon-theme-$(GNOME-ICON-THEME_VERSION)
GNOME-ICON-THEME_SUFFIX		= tar.bz2
GNOME-ICON-THEME_URL		= http://ftp.gnome.org/pub/GNOME/sources/gnome-icon-theme/2.9/$(GNOME-ICON-THEME).$(GNOME-ICON-THEME_SUFFIX)
GNOME-ICON-THEME_SOURCE		= $(SRCDIR)/$(GNOME-ICON-THEME).$(GNOME-ICON-THEME_SUFFIX)
GNOME-ICON-THEME_DIR		= $(BUILDDIR)/$(GNOME-ICON-THEME)
GNOME-ICON-THEME_IPKG_TMP	= $(GNOME-ICON-THEME_DIR)/ipkg_tmp

# ----------------------------------------------------------------------------
# Get
# ----------------------------------------------------------------------------

gnome-icon-theme_get: $(STATEDIR)/gnome-icon-theme.get

gnome-icon-theme_get_deps = $(GNOME-ICON-THEME_SOURCE)

$(STATEDIR)/gnome-icon-theme.get: $(gnome-icon-theme_get_deps)
	@$(call targetinfo, $@)
	@$(call get_patches, $(GNOME-ICON-THEME))
	touch $@

$(GNOME-ICON-THEME_SOURCE):
	@$(call targetinfo, $@)
	@$(call get, $(GNOME-ICON-THEME_URL))

# ----------------------------------------------------------------------------
# Extract
# ----------------------------------------------------------------------------

gnome-icon-theme_extract: $(STATEDIR)/gnome-icon-theme.extract

gnome-icon-theme_extract_deps = $(STATEDIR)/gnome-icon-theme.get

$(STATEDIR)/gnome-icon-theme.extract: $(gnome-icon-theme_extract_deps)
	@$(call targetinfo, $@)
	@$(call clean, $(GNOME-ICON-THEME_DIR))
	@$(call extract, $(GNOME-ICON-THEME_SOURCE))
	@$(call patchin, $(GNOME-ICON-THEME))
	touch $@

# ----------------------------------------------------------------------------
# Prepare
# ----------------------------------------------------------------------------

gnome-icon-theme_prepare: $(STATEDIR)/gnome-icon-theme.prepare

#
# dependencies
#
gnome-icon-theme_prepare_deps = \
	$(STATEDIR)/gnome-icon-theme.extract \
	$(STATEDIR)/virtual-xchain.install

GNOME-ICON-THEME_PATH	=  PATH=$(CROSS_PATH)
GNOME-ICON-THEME_ENV 	=  $(CROSS_ENV)
#GNOME-ICON-THEME_ENV	+=
GNOME-ICON-THEME_ENV	+= PKG_CONFIG_PATH=$(CROSS_LIB_DIR)/lib/pkgconfig:$(CROSS_LIB_DIR)/lib/pkgconfig
#ifdef PTXCONF_XFREE430
#GNOME-ICON-THEME_ENV	+= LDFLAGS=-Wl,-rpath-link,$(CROSS_LIB_DIR)/lib
#endif

#
# autoconf
#
GNOME-ICON-THEME_AUTOCONF = \
	--build=$(GNU_HOST) \
	--host=$(PTXCONF_GNU_TARGET) \
	--prefix=/usr

ifdef PTXCONF_XFREE430
GNOME-ICON-THEME_AUTOCONF += --x-includes=$(CROSS_LIB_DIR)/include
GNOME-ICON-THEME_AUTOCONF += --x-libraries=$(CROSS_LIB_DIR)/lib
endif

$(STATEDIR)/gnome-icon-theme.prepare: $(gnome-icon-theme_prepare_deps)
	@$(call targetinfo, $@)
	@$(call clean, $(GNOME-ICON-THEME_DIR)/config.cache)
	cd $(GNOME-ICON-THEME_DIR) && \
		$(GNOME-ICON-THEME_PATH) $(GNOME-ICON-THEME_ENV) \
		./configure $(GNOME-ICON-THEME_AUTOCONF)
	touch $@

# ----------------------------------------------------------------------------
# Compile
# ----------------------------------------------------------------------------

gnome-icon-theme_compile: $(STATEDIR)/gnome-icon-theme.compile

gnome-icon-theme_compile_deps = $(STATEDIR)/gnome-icon-theme.prepare

$(STATEDIR)/gnome-icon-theme.compile: $(gnome-icon-theme_compile_deps)
	@$(call targetinfo, $@)
	$(GNOME-ICON-THEME_PATH) $(MAKE) -C $(GNOME-ICON-THEME_DIR)
	touch $@

# ----------------------------------------------------------------------------
# Install
# ----------------------------------------------------------------------------

gnome-icon-theme_install: $(STATEDIR)/gnome-icon-theme.install

$(STATEDIR)/gnome-icon-theme.install: $(STATEDIR)/gnome-icon-theme.compile
	@$(call targetinfo, $@)
	$(GNOME-ICON-THEME_PATH) $(MAKE) -C $(GNOME-ICON-THEME_DIR) DESTDIR=$(GNOME-ICON-THEME_IPKG_TMP) install
	cp -a  $(GNOME-ICON-THEME_IPKG_TMP)/usr/lib/* $(CROSS_LIB_DIR)/lib
	rm -rf $(GNOME-ICON-THEME_IPKG_TMP)
	touch $@

# ----------------------------------------------------------------------------
# Target-Install
# ----------------------------------------------------------------------------

gnome-icon-theme_targetinstall: $(STATEDIR)/gnome-icon-theme.targetinstall

gnome-icon-theme_targetinstall_deps = $(STATEDIR)/gnome-icon-theme.compile

$(STATEDIR)/gnome-icon-theme.targetinstall: $(gnome-icon-theme_targetinstall_deps)
	@$(call targetinfo, $@)
	$(GNOME-ICON-THEME_PATH) $(MAKE) -C $(GNOME-ICON-THEME_DIR) DESTDIR=$(GNOME-ICON-THEME_IPKG_TMP) install
	rm -rf $(GNOME-ICON-THEME_IPKG_TMP)/usr/lib
	rm -rf $(GNOME-ICON-THEME_IPKG_TMP)/usr/share/locale
	rm -rf $(GNOME-ICON-THEME_IPKG_TMP)/usr/share/icons/hicolor/1*
	rm -rf $(GNOME-ICON-THEME_IPKG_TMP)/usr/share/icons/hicolor/2*
	rm -rf $(GNOME-ICON-THEME_IPKG_TMP)/usr/share/icons/hicolor/3*
	rm -rf $(GNOME-ICON-THEME_IPKG_TMP)/usr/share/icons/hicolor/7*
	rm -rf $(GNOME-ICON-THEME_IPKG_TMP)/usr/share/icons/hicolor/9*
	rm -rf $(GNOME-ICON-THEME_IPKG_TMP)/usr/share/icons/gnome/1*
	rm -rf $(GNOME-ICON-THEME_IPKG_TMP)/usr/share/icons/gnome/2*
	rm -rf $(GNOME-ICON-THEME_IPKG_TMP)/usr/share/icons/gnome/3*
	rm -rf $(GNOME-ICON-THEME_IPKG_TMP)/usr/share/icons/gnome/7*
	rm -rf $(GNOME-ICON-THEME_IPKG_TMP)/usr/share/icons/gnome/9*
	mkdir -p $(GNOME-ICON-THEME_IPKG_TMP)/CONTROL
	echo "Package: gnome-icon-theme" 			 >$(GNOME-ICON-THEME_IPKG_TMP)/CONTROL/control
	echo "Priority: optional" 				>>$(GNOME-ICON-THEME_IPKG_TMP)/CONTROL/control
	echo "Section: Gnome" 					>>$(GNOME-ICON-THEME_IPKG_TMP)/CONTROL/control
	echo "Maintainer: Alexander Chukov <sash@pdaXrom.org>" 	>>$(GNOME-ICON-THEME_IPKG_TMP)/CONTROL/control
	echo "Architecture: $(SHORT_TARGET)" 			>>$(GNOME-ICON-THEME_IPKG_TMP)/CONTROL/control
	echo "Version: $(GNOME-ICON-THEME_VERSION)" 		>>$(GNOME-ICON-THEME_IPKG_TMP)/CONTROL/control
	echo "Depends: " 					>>$(GNOME-ICON-THEME_IPKG_TMP)/CONTROL/control
	echo "Description: The base GNOME icon theme"		>>$(GNOME-ICON-THEME_IPKG_TMP)/CONTROL/control
	cd $(FEEDDIR) && $(XMKIPKG) $(GNOME-ICON-THEME_IPKG_TMP)
	touch $@

# ----------------------------------------------------------------------------
# Clean
# ----------------------------------------------------------------------------

gnome-icon-theme_clean:
	rm -rf $(STATEDIR)/gnome-icon-theme.*
	rm -rf $(GNOME-ICON-THEME_DIR)

# vim: syntax=make
