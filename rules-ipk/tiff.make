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
ifdef PTXCONF_TIFF
PACKAGES += tiff
endif

#
# Paths and names
#
TIFF_VENDOR_VERSION	= 1
TIFF_VERSION		= 3.7.1
TIFF			= tiff-$(TIFF_VERSION)
TIFF_SUFFIX		= tar.gz
TIFF_URL		= http://dl.maptools.org/dl/libtiff/$(TIFF).$(TIFF_SUFFIX)
TIFF_SOURCE		= $(SRCDIR)/$(TIFF).$(TIFF_SUFFIX)
TIFF_DIR		= $(BUILDDIR)/$(TIFF)
TIFF_IPKG_TMP		= $(TIFF_DIR)/ipkg_tmp

# ----------------------------------------------------------------------------
# Get
# ----------------------------------------------------------------------------

tiff_get: $(STATEDIR)/tiff.get

tiff_get_deps = $(TIFF_SOURCE)

$(STATEDIR)/tiff.get: $(tiff_get_deps)
	@$(call targetinfo, $@)
	@$(call get_patches, $(TIFF))
	touch $@

$(TIFF_SOURCE):
	@$(call targetinfo, $@)
	@$(call get, $(TIFF_URL))

# ----------------------------------------------------------------------------
# Extract
# ----------------------------------------------------------------------------

tiff_extract: $(STATEDIR)/tiff.extract

tiff_extract_deps = $(STATEDIR)/tiff.get

$(STATEDIR)/tiff.extract: $(tiff_extract_deps)
	@$(call targetinfo, $@)
	@$(call clean, $(TIFF_DIR))
	@$(call extract, $(TIFF_SOURCE))
	@$(call patchin, $(TIFF))
	touch $@

# ----------------------------------------------------------------------------
# Prepare
# ----------------------------------------------------------------------------

tiff_prepare: $(STATEDIR)/tiff.prepare

#
# dependencies
#
tiff_prepare_deps = \
	$(STATEDIR)/tiff.extract \
	$(STATEDIR)/jpeg.install \
	$(STATEDIR)/zlib.install \
	$(STATEDIR)/virtual-xchain.install

TIFF_PATH	=  PATH=$(CROSS_PATH)
TIFF_ENV 	=  $(CROSS_ENV)
TIFF_ENV	+= CFLAGS="$(TARGET_OPT_CFLAGS)"
TIFF_ENV	+= CXXFLAGS="$(TARGET_OPT_CFLAGS)"
TIFF_ENV	+= PKG_CONFIG_PATH=$(CROSS_LIB_DIR)/lib/pkgconfig:$(CROSS_LIB_DIR)/lib/pkgconfig
#ifdef PTXCONF_XFREE430
#TIFF_ENV	+= LDFLAGS=-Wl,-rpath-link,$(CROSS_LIB_DIR)/lib
#endif

#
# autoconf
#
TIFF_AUTOCONF = \
	--build=$(GNU_HOST) \
	--host=$(PTXCONF_GNU_TARGET) \
	--prefix=/usr \
	--enable-shared \
	--disable-static

ifdef PTXCONF_XFREE430
TIFF_AUTOCONF += --x-includes=$(CROSS_LIB_DIR)/include
TIFF_AUTOCONF += --x-libraries=$(CROSS_LIB_DIR)/lib
endif

$(STATEDIR)/tiff.prepare: $(tiff_prepare_deps)
	@$(call targetinfo, $@)
	@$(call clean, $(TIFF_DIR)/config.cache)
	cd $(TIFF_DIR) && \
		$(TIFF_PATH) $(TIFF_ENV) \
		./configure $(TIFF_AUTOCONF)
	touch $@

# ----------------------------------------------------------------------------
# Compile
# ----------------------------------------------------------------------------

tiff_compile: $(STATEDIR)/tiff.compile

tiff_compile_deps = $(STATEDIR)/tiff.prepare

$(STATEDIR)/tiff.compile: $(tiff_compile_deps)
	@$(call targetinfo, $@)
	$(TIFF_PATH) $(MAKE) -C $(TIFF_DIR)
	touch $@

# ----------------------------------------------------------------------------
# Install
# ----------------------------------------------------------------------------

tiff_install: $(STATEDIR)/tiff.install

$(STATEDIR)/tiff.install: $(STATEDIR)/tiff.compile
	@$(call targetinfo, $@)
	rm -rf $(TIFF_IPKG_TMP)
	$(TIFF_PATH) $(MAKE) -C $(TIFF_DIR) DESTDIR=$(TIFF_IPKG_TMP) install
	cp -a $(TIFF_IPKG_TMP)/usr/include/*	$(CROSS_LIB_DIR)/include
	cp -a $(TIFF_IPKG_TMP)/usr/lib/*	$(CROSS_LIB_DIR)/lib
	perl -i -p -e "s,\/usr/lib,$(CROSS_LIB_DIR)/lib,g" $(CROSS_LIB_DIR)/lib/libtiff.la
	rm -rf $(TIFF_IPKG_TMP)
	touch $@

# ----------------------------------------------------------------------------
# Target-Install
# ----------------------------------------------------------------------------

tiff_targetinstall: $(STATEDIR)/tiff.targetinstall

tiff_targetinstall_deps = $(STATEDIR)/tiff.compile \
	$(STATEDIR)/jpeg.targetinstall \
	$(STATEDIR)/zlib.targetinstall

$(STATEDIR)/tiff.targetinstall: $(tiff_targetinstall_deps)
	@$(call targetinfo, $@)
	$(TIFF_PATH) $(MAKE) -C $(TIFF_DIR) DESTDIR=$(TIFF_IPKG_TMP) install
	rm -rf $(TIFF_IPKG_TMP)/usr/bin
	rm -rf $(TIFF_IPKG_TMP)/usr/include
	rm -rf $(TIFF_IPKG_TMP)/usr/lib/*.*a
	rm -rf $(TIFF_IPKG_TMP)/usr/man
	rm -rf $(TIFF_IPKG_TMP)/usr/share
	$(CROSSSTRIP) $(TIFF_IPKG_TMP)/usr/bin/*
	$(CROSSSTRIP) $(TIFF_IPKG_TMP)/usr/lib/*.so*
	mkdir -p $(TIFF_IPKG_TMP)/CONTROL
	echo "Package: libtiff" 							 >$(TIFF_IPKG_TMP)/CONTROL/control
	echo "Priority: optional" 							>>$(TIFF_IPKG_TMP)/CONTROL/control
	echo "Section: Libraries" 							>>$(TIFF_IPKG_TMP)/CONTROL/control
	echo "Maintainer: Alexander Chukov <sash@pdaXrom.org>" 				>>$(TIFF_IPKG_TMP)/CONTROL/control
	echo "Architecture: $(SHORT_TARGET)" 						>>$(TIFF_IPKG_TMP)/CONTROL/control
	echo "Version: $(TIFF_VERSION)-$(TIFF_VENDOR_VERSION)" 				>>$(TIFF_IPKG_TMP)/CONTROL/control
	echo "Depends: libz, libjpeg" 							>>$(TIFF_IPKG_TMP)/CONTROL/control
	echo "Description: libtiff is a set of C functions (a library) that support the manipulation of TIFF image files." >>$(TIFF_IPKG_TMP)/CONTROL/control
	cd $(FEEDDIR) && $(XMKIPKG) $(TIFF_IPKG_TMP)
	touch $@

# ----------------------------------------------------------------------------
# Image-Install
# ----------------------------------------------------------------------------

ifdef PTXCONF_TIFF_INSTALL
ROMPACKAGES += $(STATEDIR)/tiff.imageinstall
endif

tiff_imageinstall_deps = $(STATEDIR)/tiff.targetinstall \
	$(STATEDIR)/virtual-image.install

$(STATEDIR)/tiff.imageinstall: $(tiff_imageinstall_deps)
	@$(call targetinfo, $@)
	cd $(FEEDDIR) && $(XIPKG) install tiff
	touch $@

# ----------------------------------------------------------------------------
# Clean
# ----------------------------------------------------------------------------

tiff_clean:
	rm -rf $(STATEDIR)/tiff.*
	rm -rf $(TIFF_DIR)

# vim: syntax=make
