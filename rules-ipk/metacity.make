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
ifdef PTXCONF_METACITY
PACKAGES += metacity
endif

#
# Paths and names
#
METACITY_VERSION	= 2.8.6
METACITY		= metacity-$(METACITY_VERSION)
METACITY_SUFFIX		= tar.bz2
METACITY_URL		= http://ftp.acc.umu.se/pub/gnome/sources/metacity/2.8/$(METACITY).$(METACITY_SUFFIX)
METACITY_SOURCE		= $(SRCDIR)/$(METACITY).$(METACITY_SUFFIX)
METACITY_DIR		= $(BUILDDIR)/$(METACITY)
METACITY_IPKG_TMP	= $(METACITY_DIR)/ipkg_tmp

# ----------------------------------------------------------------------------
# Get
# ----------------------------------------------------------------------------

metacity_get: $(STATEDIR)/metacity.get

metacity_get_deps = $(METACITY_SOURCE)

$(STATEDIR)/metacity.get: $(metacity_get_deps)
	@$(call targetinfo, $@)
	@$(call get_patches, $(METACITY))
	touch $@

$(METACITY_SOURCE):
	@$(call targetinfo, $@)
	@$(call get, $(METACITY_URL))

# ----------------------------------------------------------------------------
# Extract
# ----------------------------------------------------------------------------

metacity_extract: $(STATEDIR)/metacity.extract

metacity_extract_deps = $(STATEDIR)/metacity.get

$(STATEDIR)/metacity.extract: $(metacity_extract_deps)
	@$(call targetinfo, $@)
	@$(call clean, $(METACITY_DIR))
	@$(call extract, $(METACITY_SOURCE))
	@$(call patchin, $(METACITY))
	touch $@

# ----------------------------------------------------------------------------
# Prepare
# ----------------------------------------------------------------------------

metacity_prepare: $(STATEDIR)/metacity.prepare

#
# dependencies
#
metacity_prepare_deps = \
	$(STATEDIR)/metacity.extract \
	$(STATEDIR)/gtk22.targetinstall \
	$(STATEDIR)/startup-notification.install \
	$(STATEDIR)/libxml2.install \
	$(STATEDIR)/GConf.install \
	$(STATEDIR)/virtual-xchain.install

METACITY_PATH	=  PATH=$(CROSS_PATH)
METACITY_ENV 	=  $(CROSS_ENV)
METACITY_ENV	+= CFLAGS="$(TARGET_OPT_CFLAGS)"
METACITY_ENV	+= CXXFLAGS="$(TARGET_OPT_CFLAGS)"
METACITY_ENV	+= PKG_CONFIG_PATH=$(CROSS_LIB_DIR)/lib/pkgconfig:$(CROSS_LIB_DIR)/lib/pkgconfig
#ifdef PTXCONF_XFREE430
#METACITY_ENV	+= LDFLAGS=-Wl,-rpath-link,$(CROSS_LIB_DIR)/lib
#endif

#
# autoconf
#
METACITY_AUTOCONF = \
	--build=$(GNU_HOST) \
	--host=$(PTXCONF_GNU_TARGET) \
	--prefix=/usr \
	--disable-debug \
	--sysconfdir=/etc \
	--libexecdir=/usr/bin
#	--disable-gconf

ifdef PTXCONF_XFREE430
METACITY_AUTOCONF += --x-includes=$(CROSS_LIB_DIR)/include
METACITY_AUTOCONF += --x-libraries=$(CROSS_LIB_DIR)/lib
endif

$(STATEDIR)/metacity.prepare: $(metacity_prepare_deps)
	@$(call targetinfo, $@)
	@$(call clean, $(METACITY_DIR)/config.cache)
	cd $(METACITY_DIR) && \
		$(METACITY_PATH) $(METACITY_ENV) \
		./configure $(METACITY_AUTOCONF)
	touch $@

# ----------------------------------------------------------------------------
# Compile
# ----------------------------------------------------------------------------

metacity_compile: $(STATEDIR)/metacity.compile

metacity_compile_deps = $(STATEDIR)/metacity.prepare

$(STATEDIR)/metacity.compile: $(metacity_compile_deps)
	@$(call targetinfo, $@)
	$(METACITY_PATH) $(MAKE) -C $(METACITY_DIR)
	touch $@

# ----------------------------------------------------------------------------
# Install
# ----------------------------------------------------------------------------

metacity_install: $(STATEDIR)/metacity.install

$(STATEDIR)/metacity.install: $(STATEDIR)/metacity.compile
	@$(call targetinfo, $@)
	touch $@

# ----------------------------------------------------------------------------
# Target-Install
# ----------------------------------------------------------------------------

metacity_targetinstall: $(STATEDIR)/metacity.targetinstall

metacity_targetinstall_deps = $(STATEDIR)/metacity.compile

$(STATEDIR)/metacity.targetinstall: $(metacity_targetinstall_deps)
	@$(call targetinfo, $@)
	$(METACITY_PATH) $(MAKE) -C $(METACITY_DIR) DESTDIR=$(METACITY_IPKG_TMP) install
	rm -rf $(METACITY_IPKG_TMP)/usr/include
	rm -rf $(METACITY_IPKG_TMP)/usr/lib/pkgconfig
	rm -f  $(METACITY_IPKG_TMP)/usr/lib/*.*a
	rm -rf $(METACITY_IPKG_TMP)/usr/share/locale
	$(CROSSSTRIP) $(METACITY_IPKG_TMP)/usr/bin/*
	$(CROSSSTRIP) $(METACITY_IPKG_TMP)/usr/lib/*.so*
	mkdir -p $(METACITY_IPKG_TMP)/CONTROL
	echo "Package: metacity" 						>$(METACITY_IPKG_TMP)/CONTROL/control
	echo "Priority: optional" 						>>$(METACITY_IPKG_TMP)/CONTROL/control
	echo "Section: X11"	 						>>$(METACITY_IPKG_TMP)/CONTROL/control
	echo "Maintainer: Alexander Chukov <sash@pdaXrom.org>" 			>>$(METACITY_IPKG_TMP)/CONTROL/control
	echo "Architecture: $(SHORT_TARGET)" 					>>$(METACITY_IPKG_TMP)/CONTROL/control
	echo "Version: $(METACITY_VERSION)" 					>>$(METACITY_IPKG_TMP)/CONTROL/control
	echo "Depends: gtk2, startup-notification, gconf" 			>>$(METACITY_IPKG_TMP)/CONTROL/control
	echo "Description: GNOME windows manager"				>>$(METACITY_IPKG_TMP)/CONTROL/control
	cd $(FEEDDIR) && $(XMKIPKG) $(METACITY_IPKG_TMP)
	touch $@

# ----------------------------------------------------------------------------
# Image-Install
# ----------------------------------------------------------------------------

ifdef PTXCONF_METACITY_INSTALL
ROMPACKAGES += $(STATEDIR)/metacity.imageinstall
endif

metacity_imageinstall_deps = $(STATEDIR)/metacity.targetinstall \
	$(STATEDIR)/virtual-image.install

$(STATEDIR)/metacity.imageinstall: $(metacity_imageinstall_deps)
	@$(call targetinfo, $@)
	cd $(FEEDDIR) && $(XIPKG) install metacity
	touch $@

# ----------------------------------------------------------------------------
# Clean
# ----------------------------------------------------------------------------

metacity_clean:
	rm -rf $(STATEDIR)/metacity.*
	rm -rf $(METACITY_DIR)

# vim: syntax=make
