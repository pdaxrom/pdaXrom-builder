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
ifdef PTXCONF_LIBUNGIF
PACKAGES += libungif
endif

#
# Paths and names
#
LIBUNGIF_VENDOR_VERSION	= 1
LIBUNGIF_VERSION	= 4.1.3
LIBUNGIF		= libungif-$(LIBUNGIF_VERSION)
LIBUNGIF_SUFFIX		= tar.bz2
LIBUNGIF_URL		= http://belnet.dl.sourceforge.net/sourceforge/libungif/$(LIBUNGIF).$(LIBUNGIF_SUFFIX)
LIBUNGIF_SOURCE		= $(SRCDIR)/$(LIBUNGIF).$(LIBUNGIF_SUFFIX)
LIBUNGIF_DIR		= $(BUILDDIR)/$(LIBUNGIF)
LIBUNGIF_IPKG_TMP	= $(LIBUNGIF_DIR)/ipkg_tmp

# ----------------------------------------------------------------------------
# Get
# ----------------------------------------------------------------------------

libungif_get: $(STATEDIR)/libungif.get

libungif_get_deps = $(LIBUNGIF_SOURCE)

$(STATEDIR)/libungif.get: $(libungif_get_deps)
	@$(call targetinfo, $@)
	@$(call get_patches, $(LIBUNGIF))
	touch $@

$(LIBUNGIF_SOURCE):
	@$(call targetinfo, $@)
	@$(call get, $(LIBUNGIF_URL))

# ----------------------------------------------------------------------------
# Extract
# ----------------------------------------------------------------------------

libungif_extract: $(STATEDIR)/libungif.extract

libungif_extract_deps = $(STATEDIR)/libungif.get

$(STATEDIR)/libungif.extract: $(libungif_extract_deps)
	@$(call targetinfo, $@)
	@$(call clean, $(LIBUNGIF_DIR))
	@$(call extract, $(LIBUNGIF_SOURCE))
	@$(call patchin, $(LIBUNGIF))
	touch $@

# ----------------------------------------------------------------------------
# Prepare
# ----------------------------------------------------------------------------

libungif_prepare: $(STATEDIR)/libungif.prepare

#
# dependencies
#
libungif_prepare_deps = \
	$(STATEDIR)/libungif.extract \
	$(STATEDIR)/virtual-xchain.install

LIBUNGIF_PATH	=  PATH=$(CROSS_PATH)
LIBUNGIF_ENV 	=  $(CROSS_ENV)
LIBUNGIF_ENV	+= CFLAGS="-O2 -fomit-frame-pointer"
LIBUNGIF_ENV	+= PKG_CONFIG_PATH=$(CROSS_LIB_DIR)/lib/pkgconfig:$(CROSS_LIB_DIR)/lib/pkgconfig
#ifdef PTXCONF_XFREE430
#LIBUNGIF_ENV	+= LDFLAGS=-Wl,-rpath-link,$(CROSS_LIB_DIR)/lib
#endif

#
# autoconf
#
LIBUNGIF_AUTOCONF = \
	--build=$(GNU_HOST) \
	--host=$(PTXCONF_GNU_TARGET) \
	--prefix=/usr \
	--with-shared \
	--without-static

ifdef PTXCONF_XFREE430
LIBUNGIF_AUTOCONF += --x-includes=$(CROSS_LIB_DIR)/include
LIBUNGIF_AUTOCONF += --x-libraries=$(CROSS_LIB_DIR)/lib
endif

$(STATEDIR)/libungif.prepare: $(libungif_prepare_deps)
	@$(call targetinfo, $@)
	@$(call clean, $(LIBUNGIF_DIR)/config.cache)
	cd $(LIBUNGIF_DIR) && \
		$(LIBUNGIF_PATH) $(LIBUNGIF_ENV) \
		./configure $(LIBUNGIF_AUTOCONF)
	touch $@

# ----------------------------------------------------------------------------
# Compile
# ----------------------------------------------------------------------------

libungif_compile: $(STATEDIR)/libungif.compile

libungif_compile_deps = $(STATEDIR)/libungif.prepare

$(STATEDIR)/libungif.compile: $(libungif_compile_deps)
	@$(call targetinfo, $@)
	$(LIBUNGIF_PATH) $(MAKE) -C $(LIBUNGIF_DIR)
	touch $@

# ----------------------------------------------------------------------------
# Install
# ----------------------------------------------------------------------------

libungif_install: $(STATEDIR)/libungif.install

$(STATEDIR)/libungif.install: $(STATEDIR)/libungif.compile
	@$(call targetinfo, $@)
	rm -rf $(LIBUNGIF_IPKG_TMP)
	$(LIBUNGIF_PATH) $(MAKE) -C $(LIBUNGIF_DIR) DESTDIR=$(LIBUNGIF_IPKG_TMP) install
	cp -a $(LIBUNGIF_IPKG_TMP)/usr/include/*	$(CROSS_LIB_DIR)/include
	cp -a $(LIBUNGIF_IPKG_TMP)/usr/lib/*		$(CROSS_LIB_DIR)/lib
	perl -i -p -e "s,\/usr/lib,$(CROSS_LIB_DIR)/lib,g" $(CROSS_LIB_DIR)/lib/libungif.la
	rm -rf $(LIBUNGIF_IPKG_TMP)
	touch $@

# ----------------------------------------------------------------------------
# Target-Install
# ----------------------------------------------------------------------------

libungif_targetinstall: $(STATEDIR)/libungif.targetinstall

libungif_targetinstall_deps = $(STATEDIR)/libungif.compile

$(STATEDIR)/libungif.targetinstall: $(libungif_targetinstall_deps)
	@$(call targetinfo, $@)
	$(LIBUNGIF_PATH) $(MAKE) -C $(LIBUNGIF_DIR) DESTDIR=$(LIBUNGIF_IPKG_TMP) install
	rm -rf $(LIBUNGIF_IPKG_TMP)/usr/bin
	rm -rf $(LIBUNGIF_IPKG_TMP)/usr/include
	rm -rf $(LIBUNGIF_IPKG_TMP)/usr/lib/*.*a
	$(CROSSSTRIP) $(LIBUNGIF_IPKG_TMP)/usr/lib/*.so*
	mkdir -p $(LIBUNGIF_IPKG_TMP)/CONTROL
	echo "Package: libungif" 							 >$(LIBUNGIF_IPKG_TMP)/CONTROL/control
	echo "Priority: optional" 							>>$(LIBUNGIF_IPKG_TMP)/CONTROL/control
	echo "Section: Libraries" 							>>$(LIBUNGIF_IPKG_TMP)/CONTROL/control
	echo "Maintainer: Alexander Chukov <sash@pdaXrom.org>" 				>>$(LIBUNGIF_IPKG_TMP)/CONTROL/control
	echo "Architecture: $(SHORT_TARGET)" 						>>$(LIBUNGIF_IPKG_TMP)/CONTROL/control
	echo "Version: $(LIBUNGIF_VERSION)-$(LIBUNGIF_VENDOR_VERSION)" 			>>$(LIBUNGIF_IPKG_TMP)/CONTROL/control
	echo "Depends: xfree430" 							>>$(LIBUNGIF_IPKG_TMP)/CONTROL/control
	echo "Description: This is libungif, a library for manipulating gif files in a manner compatible with libgif, the gif library authored and maintainer by Eric S. Raymond." >>$(LIBUNGIF_IPKG_TMP)/CONTROL/control
	cd $(FEEDDIR) && $(XMKIPKG) $(LIBUNGIF_IPKG_TMP)
	touch $@

# ----------------------------------------------------------------------------
# Image-Install
# ----------------------------------------------------------------------------

ifdef PTXCONF_LIBUNGIF_INSTALL
ROMPACKAGES += $(STATEDIR)/libungif.imageinstall
endif

libungif_imageinstall_deps = $(STATEDIR)/libungif.targetinstall \
	$(STATEDIR)/virtual-image.install

$(STATEDIR)/libungif.imageinstall: $(libungif_imageinstall_deps)
	@$(call targetinfo, $@)
	cd $(FEEDDIR) && $(XIPKG) install libungif
	touch $@

# ----------------------------------------------------------------------------
# Clean
# ----------------------------------------------------------------------------

libungif_clean:
	rm -rf $(STATEDIR)/libungif.*
	rm -rf $(LIBUNGIF_DIR)

# vim: syntax=make
