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
ifdef PTXCONF_IMLIB
PACKAGES += imlib
endif

#
# Paths and names
#
IMLIB_VENDOR_VERSION	= 1
IMLIB_VERSION		= 1.9.15
IMLIB			= imlib-$(IMLIB_VERSION)
IMLIB_SUFFIX		= tar.bz2
IMLIB_URL		= http://ftp.gnome.org/pub/GNOME/sources/imlib/1.9/$(IMLIB).$(IMLIB_SUFFIX)
IMLIB_SOURCE		= $(SRCDIR)/$(IMLIB).$(IMLIB_SUFFIX)
IMLIB_DIR		= $(BUILDDIR)/$(IMLIB)
IMLIB_IPKG_TMP		= $(IMLIB_DIR)/ipkg_tmp

# ----------------------------------------------------------------------------
# Get
# ----------------------------------------------------------------------------

imlib_get: $(STATEDIR)/imlib.get

imlib_get_deps = $(IMLIB_SOURCE)

$(STATEDIR)/imlib.get: $(imlib_get_deps)
	@$(call targetinfo, $@)
	@$(call get_patches, $(IMLIB))
	touch $@

$(IMLIB_SOURCE):
	@$(call targetinfo, $@)
	@$(call get, $(IMLIB_URL))

# ----------------------------------------------------------------------------
# Extract
# ----------------------------------------------------------------------------

imlib_extract: $(STATEDIR)/imlib.extract

imlib_extract_deps = $(STATEDIR)/imlib.get

$(STATEDIR)/imlib.extract: $(imlib_extract_deps)
	@$(call targetinfo, $@)
	@$(call clean, $(IMLIB_DIR))
	@$(call extract, $(IMLIB_SOURCE))
	@$(call patchin, $(IMLIB))
	touch $@

# ----------------------------------------------------------------------------
# Prepare
# ----------------------------------------------------------------------------

imlib_prepare: $(STATEDIR)/imlib.prepare

#
# dependencies
#
imlib_prepare_deps = \
	$(STATEDIR)/imlib.extract \
	$(STATEDIR)/gtk1210.install \
	$(STATEDIR)/libpng125.install \
	$(STATEDIR)/jpeg.install \
	$(STATEDIR)/tiff.install \
	$(STATEDIR)/libungif.install \
	$(STATEDIR)/virtual-xchain.install

IMLIB_PATH	=  PATH=$(CROSS_PATH)
IMLIB_ENV 	=  $(CROSS_ENV)
IMLIB_ENV	+= CFLAGS="-O2 -fomit-frame-pointer"
IMLIB_ENV	+= PKG_CONFIG_PATH=$(CROSS_LIB_DIR)/lib/pkgconfig:$(CROSS_LIB_DIR)/lib/pkgconfig
#ifdef PTXCONF_XFREE430
#IMLIB_ENV	+= LDFLAGS=-Wl,-rpath-link,$(CROSS_LIB_DIR)/lib
#endif

#
# autoconf
#
IMLIB_AUTOCONF = \
	--build=$(GNU_HOST) \
	--host=$(PTXCONF_GNU_TARGET) \
	--prefix=/usr \
	--sysconfdir=/etc/imlib \
	--enable-shared \
	--disable-static

ifdef PTXCONF_XFREE430
IMLIB_AUTOCONF += --x-includes=$(CROSS_LIB_DIR)/include
IMLIB_AUTOCONF += --x-libraries=$(CROSS_LIB_DIR)/lib
endif

$(STATEDIR)/imlib.prepare: $(imlib_prepare_deps)
	@$(call targetinfo, $@)
	@$(call clean, $(IMLIB_DIR)/config.cache)
	cd $(IMLIB_DIR) && \
		$(IMLIB_PATH) $(IMLIB_ENV) \
		./configure $(IMLIB_AUTOCONF)
	touch $@

# ----------------------------------------------------------------------------
# Compile
# ----------------------------------------------------------------------------

imlib_compile: $(STATEDIR)/imlib.compile

imlib_compile_deps = $(STATEDIR)/imlib.prepare

$(STATEDIR)/imlib.compile: $(imlib_compile_deps)
	@$(call targetinfo, $@)
	$(IMLIB_PATH) $(MAKE) -C $(IMLIB_DIR)
	touch $@

# ----------------------------------------------------------------------------
# Install
# ----------------------------------------------------------------------------

imlib_install: $(STATEDIR)/imlib.install

$(STATEDIR)/imlib.install: $(STATEDIR)/imlib.compile
	@$(call targetinfo, $@)
	rm -rf $(IMLIB_IPKG_TMP)
	$(IMLIB_PATH) $(MAKE) -C $(IMLIB_DIR) DESTDIR=$(IMLIB_IPKG_TMP) install
	cp -a $(IMLIB_IPKG_TMP)/usr/bin/imlib-config	$(PTXCONF_PREFIX)/bin/
	cp -a $(IMLIB_IPKG_TMP)/usr/include/*		$(CROSS_LIB_DIR)/include/
	cp -a $(IMLIB_IPKG_TMP)/usr/lib/libImlib.*	$(CROSS_LIB_DIR)/lib/
	cp -a $(IMLIB_IPKG_TMP)/usr/lib/libgdk_imlib.*	$(CROSS_LIB_DIR)/lib/
	cp -a $(IMLIB_IPKG_TMP)/usr/lib/pkgconfig/*	$(CROSS_LIB_DIR)/lib/pkgconfig/
	cp -a $(IMLIB_IPKG_TMP)/usr/share/aclocal/*	$(PTXCONF_PREFIX)/share/aclocal/
	
	perl -i -p -e "s,\/usr,$(CROSS_LIB_DIR)/lib,g"		$(PTXCONF_PREFIX)/bin/imlib-config
	perl -i -p -e "s,\/usr/lib,$(CROSS_LIB_DIR)/lib,g" 	$(CROSS_LIB_DIR)/lib/libImlib.la
	perl -i -p -e "s,\/usr/lib,$(CROSS_LIB_DIR)/lib,g" 	$(CROSS_LIB_DIR)/lib/libgdk_imlib.la
	perl -i -p -e "s,\/usr,$(CROSS_LIB_DIR)/lib,g"		$(CROSS_LIB_DIR)/lib/pkgconfig/imlib.pc
	perl -i -p -e "s,\/usr,$(CROSS_LIB_DIR)/lib,g"		$(CROSS_LIB_DIR)/lib/pkgconfig/imlibgdk.pc
	rm -rf $(IMLIB_IPKG_TMP)
	touch $@

# ----------------------------------------------------------------------------
# Target-Install
# ----------------------------------------------------------------------------

imlib_targetinstall: $(STATEDIR)/imlib.targetinstall

imlib_targetinstall_deps = $(STATEDIR)/imlib.compile \
	$(STATEDIR)/gtk1210.targetinstall \
	$(STATEDIR)/jpeg.targetinstall \
	$(STATEDIR)/libpng125.targetinstall \
	$(STATEDIR)/tiff.targetinstall \
	$(STATEDIR)/libungif.targetinstall

$(STATEDIR)/imlib.targetinstall: $(imlib_targetinstall_deps)
	@$(call targetinfo, $@)
	$(IMLIB_PATH) $(MAKE) -C $(IMLIB_DIR) DESTDIR=$(IMLIB_IPKG_TMP) install
	rm -rf $(IMLIB_IPKG_TMP)/usr/bin/imlib-config
	rm -rf $(IMLIB_IPKG_TMP)/usr/include
	rm -rf $(IMLIB_IPKG_TMP)/usr/lib/pkgconfig
	rm -rf $(IMLIB_IPKG_TMP)/usr/lib/*.*a
	rm -rf $(IMLIB_IPKG_TMP)/usr/man
	rm -rf $(IMLIB_IPKG_TMP)/usr/share
	$(CROSSSTRIP) $(IMLIB_IPKG_TMP)/usr/bin/*
	$(CROSSSTRIP) $(IMLIB_IPKG_TMP)/usr/lib/*.so*
	mkdir -p $(IMLIB_IPKG_TMP)/CONTROL
	echo "Package: imlib" 											 >$(IMLIB_IPKG_TMP)/CONTROL/control
	echo "Priority: optional" 										>>$(IMLIB_IPKG_TMP)/CONTROL/control
	echo "Section: Libraries" 										>>$(IMLIB_IPKG_TMP)/CONTROL/control
	echo "Maintainer: Alexander Chukov <sash@pdaXrom.org>" 							>>$(IMLIB_IPKG_TMP)/CONTROL/control
	echo "Architecture: $(SHORT_TARGET)" 									>>$(IMLIB_IPKG_TMP)/CONTROL/control
	echo "Version: $(IMLIB_VERSION)-$(IMLIB_VENDOR_VERSION)" 						>>$(IMLIB_IPKG_TMP)/CONTROL/control
	echo "Depends: libjpeg, libtiff, libungif, libpng, libz" 						>>$(IMLIB_IPKG_TMP)/CONTROL/control
	echo "Description: Imlib is a general Image loading and rendering library designed to make the task of loading images, and obtaining X-Windows drawables a simple task, as well as a quick one. " >>$(IMLIB_IPKG_TMP)/CONTROL/control
	cd $(FEEDDIR) && $(XMKIPKG) $(IMLIB_IPKG_TMP)
	touch $@

# ----------------------------------------------------------------------------
# Image-Install
# ----------------------------------------------------------------------------

ifdef PTXCONF_IMLIB_INSTALL
ROMPACKAGES += $(STATEDIR)/imlib.imageinstall
endif

imlib_imageinstall_deps = $(STATEDIR)/imlib.targetinstall \
	$(STATEDIR)/virtual-image.install

$(STATEDIR)/imlib.imageinstall: $(imlib_imageinstall_deps)
	@$(call targetinfo, $@)
	cd $(FEEDDIR) && $(XIPKG) install imlib
	touch $@

# ----------------------------------------------------------------------------
# Clean
# ----------------------------------------------------------------------------

imlib_clean:
	rm -rf $(STATEDIR)/imlib.*
	rm -rf $(IMLIB_DIR)

# vim: syntax=make
