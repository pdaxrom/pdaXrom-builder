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
ifdef PTXCONF_XPDF
PACKAGES += xpdf
endif

#
# Paths and names
#
XPDF_VENDOR_VERSION	= 1
XPDF_VERSION		= 3.00
XPDF			= xpdf-$(XPDF_VERSION)
XPDF_SUFFIX		= tar.gz
XPDF_URL		= ftp://ftp.foolabs.com/pub/xpdf/$(XPDF).$(XPDF_SUFFIX)
XPDF_SOURCE		= $(SRCDIR)/$(XPDF).$(XPDF_SUFFIX)
XPDF_DIR		= $(BUILDDIR)/$(XPDF)
XPDF_IPKG_TMP		= $(XPDF_DIR)/ipkg_tmp

# ----------------------------------------------------------------------------
# Get
# ----------------------------------------------------------------------------

xpdf_get: $(STATEDIR)/xpdf.get

xpdf_get_deps = $(XPDF_SOURCE)

$(STATEDIR)/xpdf.get: $(xpdf_get_deps)
	@$(call targetinfo, $@)
	@$(call get_patches, $(XPDF))
	touch $@

$(XPDF_SOURCE):
	@$(call targetinfo, $@)
	@$(call get, $(XPDF_URL))

# ----------------------------------------------------------------------------
# Extract
# ----------------------------------------------------------------------------

xpdf_extract: $(STATEDIR)/xpdf.extract

xpdf_extract_deps = $(STATEDIR)/xpdf.get

$(STATEDIR)/xpdf.extract: $(xpdf_extract_deps)
	@$(call targetinfo, $@)
	@$(call clean, $(XPDF_DIR))
	@$(call extract, $(XPDF_SOURCE))
	@$(call patchin, $(XPDF))
	touch $@

# ----------------------------------------------------------------------------
# Prepare
# ----------------------------------------------------------------------------

xpdf_prepare: $(STATEDIR)/xpdf.prepare

#
# dependencies
#
xpdf_prepare_deps = \
	$(STATEDIR)/xpdf.extract \
	$(STATEDIR)/xfree430.install \
	$(STATEDIR)/lesstif.install \
	$(STATEDIR)/virtual-xchain.install

XPDF_PATH	=  PATH=$(CROSS_PATH)
XPDF_ENV 	=  $(CROSS_ENV)
XPDF_ENV	+= CFLAGS="-O3 -fomit-frame-pointer"
XPDF_ENV	+= CXXFLAGS="-O3 -fomit-frame-pointer"
XPDF_ENV	+= PKG_CONFIG_PATH=$(CROSS_LIB_DIR)/lib/pkgconfig:$(CROSS_LIB_DIR)/lib/pkgconfig
#ifdef PTXCONF_XFREE430
#XPDF_ENV	+= LDFLAGS=-Wl,-rpath-link,$(CROSS_LIB_DIR)/lib
#endif

XPDF_ENV	+= ac_cv_header_freetype_freetype_h=yes

#
# autoconf
#
XPDF_AUTOCONF = \
	--build=$(GNU_HOST) \
	--host=$(PTXCONF_GNU_TARGET) \
	--prefix=/usr \
	--sysconfdir=/etc \
	--enable-multithreaded \
	--with-Xpm-library=$(CROSS_LIB_DIR)/lib \
	--with-Xpm-includes=$(CROSS_LIB_DIR)/include \
	--with-Xext-library=$(CROSS_LIB_DIR)/lib \
	--with-Xext-includes=$(CROSS_LIB_DIR)/include \
	--with-Xt-library=$(CROSS_LIB_DIR)/lib \
	--with-Xt-includes=$(CROSS_LIB_DIR)/include \
	--with-Xm-library=$(CROSS_LIB_DIR)/lib \
	--with-Xm-includes=$(CROSS_LIB_DIR)/include \
	--with-x \
	--with-freetype2-library=$(CROSS_LIB_DIR)/lib \
	--with-freetype2-includes=$(CROSS_LIB_DIR)/include/freetype2

ifdef PTXCONF_XFREE430
XPDF_AUTOCONF += --x-includes=$(CROSS_LIB_DIR)/include
XPDF_AUTOCONF += --x-libraries=$(CROSS_LIB_DIR)/lib
endif

$(STATEDIR)/xpdf.prepare: $(xpdf_prepare_deps)
	@$(call targetinfo, $@)
	@$(call clean, $(XPDF_DIR)/config.cache)
	cd $(XPDF_DIR) && \
		$(XPDF_PATH) $(XPDF_ENV) \
		./configure $(XPDF_AUTOCONF)
	touch $@

# ----------------------------------------------------------------------------
# Compile
# ----------------------------------------------------------------------------

xpdf_compile: $(STATEDIR)/xpdf.compile

xpdf_compile_deps = $(STATEDIR)/xpdf.prepare

$(STATEDIR)/xpdf.compile: $(xpdf_compile_deps)
	@$(call targetinfo, $@)
	$(XPDF_PATH) $(MAKE) -C $(XPDF_DIR)
	touch $@

# ----------------------------------------------------------------------------
# Install
# ----------------------------------------------------------------------------

xpdf_install: $(STATEDIR)/xpdf.install

$(STATEDIR)/xpdf.install: $(STATEDIR)/xpdf.compile
	@$(call targetinfo, $@)
	$(XPDF_PATH) $(MAKE) -C $(XPDF_DIR) install
	touch $@

# ----------------------------------------------------------------------------
# Target-Install
# ----------------------------------------------------------------------------

xpdf_targetinstall: $(STATEDIR)/xpdf.targetinstall

xpdf_targetinstall_deps = $(STATEDIR)/xpdf.compile \
	$(STATEDIR)/xfree430.targetinstall \
	$(STATEDIR)/lesstif.targetinstall

$(STATEDIR)/xpdf.targetinstall: $(xpdf_targetinstall_deps)
	@$(call targetinfo, $@)
	$(XPDF_PATH) $(MAKE) -C $(XPDF_DIR) DESTDIR=$(XPDF_IPKG_TMP) install
	rm -rf        $(XPDF_IPKG_TMP)/usr/man
	rm -rf        $(XPDF_IPKG_TMP)/usr/bin/pdf*
	$(CROSSSTRIP) $(XPDF_IPKG_TMP)/usr/bin/*
	mkdir -p $(XPDF_IPKG_TMP)/usr/share/pixmaps
	mkdir -p $(XPDF_IPKG_TMP)/usr/share/applications
	cp -a $(TOPDIR)/config/pics/xpdf.desktop $(XPDF_IPKG_TMP)/usr/share/applications
	cp -a $(TOPDIR)/config/pics/xpdf.png     $(XPDF_IPKG_TMP)/usr/share/pixmaps
	cp -a $(TOPDIR)/config/pics/xpdf/*	 $(XPDF_IPKG_TMP)/
	mkdir -p $(XPDF_IPKG_TMP)/CONTROL
	echo "Package: xpdf" 						 >$(XPDF_IPKG_TMP)/CONTROL/control
	echo "Priority: optional" 					>>$(XPDF_IPKG_TMP)/CONTROL/control
	echo "Section: X11"	 					>>$(XPDF_IPKG_TMP)/CONTROL/control
	echo "Maintainer: Alexander Chukov <sash@pdaXrom.org>" 		>>$(XPDF_IPKG_TMP)/CONTROL/control
	echo "Architecture: $(SHORT_TARGET)" 				>>$(XPDF_IPKG_TMP)/CONTROL/control
	echo "Version: $(XPDF_VERSION)-$(XPDF_VENDOR_VERSION)" 		>>$(XPDF_IPKG_TMP)/CONTROL/control
	echo "Depends: lesstif" 					>>$(XPDF_IPKG_TMP)/CONTROL/control
	echo "Description: Xpdf is an open source viewer for Portable Document Format (PDF) files.">>$(XPDF_IPKG_TMP)/CONTROL/control
	cd $(FEEDDIR) && $(XMKIPKG) $(XPDF_IPKG_TMP)
	touch $@

# ----------------------------------------------------------------------------
# Image-Install
# ----------------------------------------------------------------------------

ifdef PTXCONF_XPDF_INSTALL
ROMPACKAGES += $(STATEDIR)/xpdf.imageinstall
endif

xpdf_imageinstall_deps = $(STATEDIR)/xpdf.targetinstall \
	$(STATEDIR)/virtual-image.install

$(STATEDIR)/xpdf.imageinstall: $(xpdf_imageinstall_deps)
	@$(call targetinfo, $@)
	cd $(FEEDDIR) && $(XIPKG) install xpdf
	touch $@

# ----------------------------------------------------------------------------
# Clean
# ----------------------------------------------------------------------------

xpdf_clean:
	rm -rf $(STATEDIR)/xpdf.*
	rm -rf $(XPDF_DIR)

# vim: syntax=make
