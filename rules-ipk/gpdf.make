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
ifdef PTXCONF_GPDF
PACKAGES += gpdf
endif

#
# Paths and names
#
GPDF_VENDOR_VERSION	= 1
GPDF_VERSION		= 2.8.1
GPDF			= gpdf-$(GPDF_VERSION)
GPDF_SUFFIX		= tar.bz2
GPDF_URL		= http://ftp.gnome.org/pub/GNOME/sources/gpdf/2.8/$(GPDF).$(GPDF_SUFFIX)
GPDF_SOURCE		= $(SRCDIR)/$(GPDF).$(GPDF_SUFFIX)
GPDF_DIR		= $(BUILDDIR)/$(GPDF)
GPDF_IPKG_TMP		= $(GPDF_DIR)/ipkg_tmp

# ----------------------------------------------------------------------------
# Get
# ----------------------------------------------------------------------------

gpdf_get: $(STATEDIR)/gpdf.get

gpdf_get_deps = $(GPDF_SOURCE)

$(STATEDIR)/gpdf.get: $(gpdf_get_deps)
	@$(call targetinfo, $@)
	@$(call get_patches, $(GPDF))
	touch $@

$(GPDF_SOURCE):
	@$(call targetinfo, $@)
	@$(call get, $(GPDF_URL))

# ----------------------------------------------------------------------------
# Extract
# ----------------------------------------------------------------------------

gpdf_extract: $(STATEDIR)/gpdf.extract

gpdf_extract_deps = $(STATEDIR)/gpdf.get

$(STATEDIR)/gpdf.extract: $(gpdf_extract_deps)
	@$(call targetinfo, $@)
	@$(call clean, $(GPDF_DIR))
	@$(call extract, $(GPDF_SOURCE))
	@$(call patchin, $(GPDF))
	touch $@

# ----------------------------------------------------------------------------
# Prepare
# ----------------------------------------------------------------------------

gpdf_prepare: $(STATEDIR)/gpdf.prepare

#
# dependencies
#
gpdf_prepare_deps = \
	$(STATEDIR)/gpdf.extract \
	$(STATEDIR)/gtk22.install \
	$(STATEDIR)/libbonobo.install \
	$(STATEDIR)/libgnomecanvas.install \
	$(STATEDIR)/libgnomeprint.install \
	$(STATEDIR)/virtual-xchain.install

GPDF_PATH	=  PATH=$(CROSS_PATH)
GPDF_ENV 	=  $(CROSS_ENV)
GPDF_ENV	+= CFLAGS="$(TARGET_OPT_CFLAGS)"
GPDF_ENV	+= CXXFLAGS="$(TARGET_OPT_CFLAGS)"
GPDF_ENV	+= PKG_CONFIG_PATH=$(CROSS_LIB_DIR)/lib/pkgconfig:$(CROSS_LIB_DIR)/lib/pkgconfig
#ifdef PTXCONF_XFREE430
#GPDF_ENV	+= LDFLAGS=-Wl,-rpath-link,$(CROSS_LIB_DIR)/lib
#endif

#
# autoconf
#
GPDF_AUTOCONF = \
	--build=$(GNU_HOST) \
	--host=$(PTXCONF_GNU_TARGET) \
	--prefix=/usr \
	--sysconfdir=/etc \
	--libexecdir=/usr/bin

ifdef PTXCONF_XFREE430
GPDF_AUTOCONF += --x-includes=$(CROSS_LIB_DIR)/include
GPDF_AUTOCONF += --x-libraries=$(CROSS_LIB_DIR)/lib
endif

$(STATEDIR)/gpdf.prepare: $(gpdf_prepare_deps)
	@$(call targetinfo, $@)
	@$(call clean, $(GPDF_DIR)/config.cache)
	cd $(GPDF_DIR) && \
		$(GPDF_PATH) $(GPDF_ENV) \
		./configure $(GPDF_AUTOCONF)
	touch $@

# ----------------------------------------------------------------------------
# Compile
# ----------------------------------------------------------------------------

gpdf_compile: $(STATEDIR)/gpdf.compile

gpdf_compile_deps = $(STATEDIR)/gpdf.prepare

$(STATEDIR)/gpdf.compile: $(gpdf_compile_deps)
	@$(call targetinfo, $@)
	$(GPDF_PATH) $(MAKE) -C $(GPDF_DIR)
	touch $@

# ----------------------------------------------------------------------------
# Install
# ----------------------------------------------------------------------------

gpdf_install: $(STATEDIR)/gpdf.install

$(STATEDIR)/gpdf.install: $(STATEDIR)/gpdf.compile
	@$(call targetinfo, $@)
	$(GPDF_PATH) $(MAKE) -C $(GPDF_DIR) install
	touch $@

# ----------------------------------------------------------------------------
# Target-Install
# ----------------------------------------------------------------------------

gpdf_targetinstall: $(STATEDIR)/gpdf.targetinstall

gpdf_targetinstall_deps = $(STATEDIR)/gpdf.compile \
	$(STATEDIR)/gtk22.targetinstall \
	$(STATEDIR)/libbonobo.targetinstall \
	$(STATEDIR)/libgnomecanvas.targetinstall \
	$(STATEDIR)/libgnomeprint.targetinstall

$(STATEDIR)/gpdf.targetinstall: $(gpdf_targetinstall_deps)
	@$(call targetinfo, $@)
	$(GPDF_PATH) $(MAKE) -C $(GPDF_DIR) DESTDIR=$(GPDF_IPKG_TMP) install
	$(CROSSSTRIP) $(GPDF_IPKG_TMP)/usr/bin/*
	mkdir -p $(GPDF_IPKG_TMP)/CONTROL
	echo "Package: gpdf"	 							 >$(GPDF_IPKG_TMP)/CONTROL/control
	echo "Priority: optional" 							>>$(GPDF_IPKG_TMP)/CONTROL/control
	echo "Section: X11" 								>>$(GPDF_IPKG_TMP)/CONTROL/control
	echo "Maintainer: Alexander Chukov <sash@pdaXrom.org>" 				>>$(GPDF_IPKG_TMP)/CONTROL/control
	echo "Architecture: $(SHORT_TARGET)" 						>>$(GPDF_IPKG_TMP)/CONTROL/control
	echo "Version: $(GPDF_VERSION)-$(GPDF_VENDOR_VERSION)" 				>>$(GPDF_IPKG_TMP)/CONTROL/control
	echo "Depends: gtk2, libbonobo, libgnomecanvas, libgnomeprintui, libgnomeui" 	>>$(GPDF_IPKG_TMP)/CONTROL/control
	echo "Description: GNOME PDF viewer"						>>$(GPDF_IPKG_TMP)/CONTROL/control
	cd $(FEEDDIR) && $(XMKIPKG) $(GPDF_IPKG_TMP)
	touch $@

# ----------------------------------------------------------------------------
# Image-Install
# ----------------------------------------------------------------------------

ifdef PTXCONF_GPDF_INSTALL
ROMPACKAGES += $(STATEDIR)/gpdf.imageinstall
endif

gpdf_imageinstall_deps = $(STATEDIR)/gpdf.targetinstall \
	$(STATEDIR)/virtual-image.install

$(STATEDIR)/gpdf.imageinstall: $(gpdf_imageinstall_deps)
	@$(call targetinfo, $@)
	cd $(FEEDDIR) && $(XIPKG) install gpdf
	touch $@

# ----------------------------------------------------------------------------
# Clean
# ----------------------------------------------------------------------------

gpdf_clean:
	rm -rf $(STATEDIR)/gpdf.*
	rm -rf $(GPDF_DIR)

# vim: syntax=make
