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
ifdef PTXCONF_GIMAGEVIEW
PACKAGES += gimageview
endif

#
# Paths and names
#
GIMAGEVIEW_VENDOR_VERSION	= 1
GIMAGEVIEW_VERSION		= 0.2.27
GIMAGEVIEW			= gimageview-$(GIMAGEVIEW_VERSION)
GIMAGEVIEW_SUFFIX		= tar.gz
GIMAGEVIEW_URL			= http://unc.dl.sourceforge.net/sourceforge/gtkmmviewer/$(GIMAGEVIEW).$(GIMAGEVIEW_SUFFIX)
GIMAGEVIEW_SOURCE		= $(SRCDIR)/$(GIMAGEVIEW).$(GIMAGEVIEW_SUFFIX)
GIMAGEVIEW_DIR			= $(BUILDDIR)/$(GIMAGEVIEW)
GIMAGEVIEW_IPKG_TMP		= $(GIMAGEVIEW_DIR)/ipkg_tmp

# ----------------------------------------------------------------------------
# Get
# ----------------------------------------------------------------------------

gimageview_get: $(STATEDIR)/gimageview.get

gimageview_get_deps = $(GIMAGEVIEW_SOURCE)

$(STATEDIR)/gimageview.get: $(gimageview_get_deps)
	@$(call targetinfo, $@)
	@$(call get_patches, $(GIMAGEVIEW))
	touch $@

$(GIMAGEVIEW_SOURCE):
	@$(call targetinfo, $@)
	@$(call get, $(GIMAGEVIEW_URL))

# ----------------------------------------------------------------------------
# Extract
# ----------------------------------------------------------------------------

gimageview_extract: $(STATEDIR)/gimageview.extract

gimageview_extract_deps = $(STATEDIR)/gimageview.get

$(STATEDIR)/gimageview.extract: $(gimageview_extract_deps)
	@$(call targetinfo, $@)
	@$(call clean, $(GIMAGEVIEW_DIR))
	@$(call extract, $(GIMAGEVIEW_SOURCE))
	@$(call patchin, $(GIMAGEVIEW))
	touch $@

# ----------------------------------------------------------------------------
# Prepare
# ----------------------------------------------------------------------------

gimageview_prepare: $(STATEDIR)/gimageview.prepare

#
# dependencies
#
gimageview_prepare_deps = \
	$(STATEDIR)/gimageview.extract \
	$(STATEDIR)/zlib.install \
	$(STATEDIR)/libpng125.install \
	$(STATEDIR)/gtk22.install \
	$(STATEDIR)/virtual-xchain.install

GIMAGEVIEW_PATH	=  PATH=$(CROSS_PATH)
GIMAGEVIEW_ENV 	=  $(CROSS_ENV)
GIMAGEVIEW_ENV	+= CFLAGS="-O2 -fomit-frame-pointer"
GIMAGEVIEW_ENV	+= PKG_CONFIG_PATH=$(CROSS_LIB_DIR)/lib/pkgconfig
#ifdef PTXCONF_XFREE430
#GIMAGEVIEW_ENV	+= LDFLAGS=-Wl,-rpath-link,$(CROSS_LIB_DIR)/X11R6/lib
#endif

#
# autoconf
#
GIMAGEVIEW_AUTOCONF = \
	--build=$(GNU_HOST) \
	--host=$(PTXCONF_GNU_TARGET) \
	--prefix=/usr \
	--sysconfdir=/etc \
	--with-gtk2 \
	--disable-imlib \
	--without-libmng \
	--without-librsvg \
	--without-libwmf \
	--without-xine

ifdef PTXCONF_XFREE430
GIMAGEVIEW_AUTOCONF += --x-includes=$(CROSS_LIB_DIR)/include
GIMAGEVIEW_AUTOCONF += --x-libraries=$(CROSS_LIB_DIR)/lib
endif

$(STATEDIR)/gimageview.prepare: $(gimageview_prepare_deps)
	@$(call targetinfo, $@)
	@$(call clean, $(GIMAGEVIEW_DIR)/config.cache)
	cd $(GIMAGEVIEW_DIR) && \
		$(GIMAGEVIEW_PATH) $(GIMAGEVIEW_ENV) \
		./configure $(GIMAGEVIEW_AUTOCONF)
	touch $@

# ----------------------------------------------------------------------------
# Compile
# ----------------------------------------------------------------------------

gimageview_compile: $(STATEDIR)/gimageview.compile

gimageview_compile_deps = $(STATEDIR)/gimageview.prepare

$(STATEDIR)/gimageview.compile: $(gimageview_compile_deps)
	@$(call targetinfo, $@)
	$(GIMAGEVIEW_PATH) $(MAKE) -C $(GIMAGEVIEW_DIR)
	touch $@

# ----------------------------------------------------------------------------
# Install
# ----------------------------------------------------------------------------

gimageview_install: $(STATEDIR)/gimageview.install

$(STATEDIR)/gimageview.install: $(STATEDIR)/gimageview.compile
	@$(call targetinfo, $@)
	$(GIMAGEVIEW_PATH) $(MAKE) -C $(GIMAGEVIEW_DIR) install
	touch $@

# ----------------------------------------------------------------------------
# Target-Install
# ----------------------------------------------------------------------------

gimageview_targetinstall: $(STATEDIR)/gimageview.targetinstall

gimageview_targetinstall_deps = $(STATEDIR)/gimageview.compile \
	$(STATEDIR)/zlib.targetinstall \
	$(STATEDIR)/libpng125.targetinstall \
	$(STATEDIR)/gtk22.targetinstall

$(STATEDIR)/gimageview.targetinstall: $(gimageview_targetinstall_deps)
	@$(call targetinfo, $@)
	$(GIMAGEVIEW_PATH) $(MAKE) -C $(GIMAGEVIEW_DIR) DESTDIR=$(GIMAGEVIEW_IPKG_TMP) install
	mkdir -p $(GIMAGEVIEW_IPKG_TMP)/CONTROL
	echo "Package: gimageview" 										 >$(GIMAGEVIEW_IPKG_TMP)/CONTROL/control
	echo "Priority: optional" 										>>$(GIMAGEVIEW_IPKG_TMP)/CONTROL/control
	echo "Section: Graphics" 										>>$(GIMAGEVIEW_IPKG_TMP)/CONTROL/control
	echo "Maintainer: Alexander Chukov <sash@pdaXrom.org>" 							>>$(GIMAGEVIEW_IPKG_TMP)/CONTROL/control
	echo "Architecture: $(SHORT_TARGET)" 									>>$(GIMAGEVIEW_IPKG_TMP)/CONTROL/control
	echo "Version: $(GIMAGEVIEW_VERSION)-$(GIMAGEVIEW_VENDOR_VERSION)" 					>>$(GIMAGEVIEW_IPKG_TMP)/CONTROL/control
	echo "Depends: gtk2, libz, libpng" 									>>$(GIMAGEVIEW_IPKG_TMP)/CONTROL/control
	echo "Description: GImageView is a yet another image viewer which solves hopless situation under displaying a lot of images." >>$(GIMAGEVIEW_IPKG_TMP)/CONTROL/control
	sasdads
	cd $(FEEDDIR) && $(XMKIPKG) $(GIMAGEVIEW_IPKG_TMP)
	touch $@

# ----------------------------------------------------------------------------
# Image-Install
# ----------------------------------------------------------------------------

ifdef PTXCONF_GIMAGEVIEW_INSTALL
ROMPACKAGES += $(STATEDIR)/gimageview.imageinstall
endif

gimageview_imageinstall_deps = $(STATEDIR)/gimageview.targetinstall \
	$(STATEDIR)/virtual-image.install

$(STATEDIR)/gimageview.imageinstall: $(gimageview_imageinstall_deps)
	@$(call targetinfo, $@)
	cd $(FEEDDIR) && $(XIPKG) install gimageview
	touch $@

# ----------------------------------------------------------------------------
# Clean
# ----------------------------------------------------------------------------

gimageview_clean:
	rm -rf $(STATEDIR)/gimageview.*
	rm -rf $(GIMAGEVIEW_DIR)

# vim: syntax=make
