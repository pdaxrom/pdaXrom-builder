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
ifdef PTXCONF_LIBDVBPSI3
PACKAGES += libdvbpsi3
endif

#
# Paths and names
#
LIBDVBPSI3_VERSION	= 0.1.4
LIBDVBPSI3		= libdvbpsi3-$(LIBDVBPSI3_VERSION)
LIBDVBPSI3_SUFFIX	= tar.bz2
LIBDVBPSI3_URL		= http://download.videolan.org/pub/libdvbpsi/0.1.4/$(LIBDVBPSI3).$(LIBDVBPSI3_SUFFIX)
LIBDVBPSI3_SOURCE	= $(SRCDIR)/$(LIBDVBPSI3).$(LIBDVBPSI3_SUFFIX)
LIBDVBPSI3_DIR		= $(BUILDDIR)/$(LIBDVBPSI3)
LIBDVBPSI3_IPKG_TMP	= $(LIBDVBPSI3_DIR)/ipkg_tmp

# ----------------------------------------------------------------------------
# Get
# ----------------------------------------------------------------------------

libdvbpsi3_get: $(STATEDIR)/libdvbpsi3.get

libdvbpsi3_get_deps = $(LIBDVBPSI3_SOURCE)

$(STATEDIR)/libdvbpsi3.get: $(libdvbpsi3_get_deps)
	@$(call targetinfo, $@)
	@$(call get_patches, $(LIBDVBPSI3))
	touch $@

$(LIBDVBPSI3_SOURCE):
	@$(call targetinfo, $@)
	@$(call get, $(LIBDVBPSI3_URL))

# ----------------------------------------------------------------------------
# Extract
# ----------------------------------------------------------------------------

libdvbpsi3_extract: $(STATEDIR)/libdvbpsi3.extract

libdvbpsi3_extract_deps = $(STATEDIR)/libdvbpsi3.get

$(STATEDIR)/libdvbpsi3.extract: $(libdvbpsi3_extract_deps)
	@$(call targetinfo, $@)
	@$(call clean, $(LIBDVBPSI3_DIR))
	@$(call extract, $(LIBDVBPSI3_SOURCE))
	@$(call patchin, $(LIBDVBPSI3))
	touch $@

# ----------------------------------------------------------------------------
# Prepare
# ----------------------------------------------------------------------------

libdvbpsi3_prepare: $(STATEDIR)/libdvbpsi3.prepare

#
# dependencies
#
libdvbpsi3_prepare_deps = \
	$(STATEDIR)/libdvbpsi3.extract \
	$(STATEDIR)/virtual-xchain.install

LIBDVBPSI3_PATH	=  PATH=$(CROSS_PATH)
LIBDVBPSI3_ENV 	=  $(CROSS_ENV)
LIBDVBPSI3_ENV	+= CFLAGS="$(TARGET_OPT_CFLAGS)"
LIBDVBPSI3_ENV	+= PKG_CONFIG_PATH=$(CROSS_LIB_DIR)/lib/pkgconfig:$(CROSS_LIB_DIR)/lib/pkgconfig
#ifdef PTXCONF_XFREE430
#LIBDVBPSI3_ENV	+= LDFLAGS=-Wl,-rpath-link,$(CROSS_LIB_DIR)/lib
#endif

#
# autoconf
#
LIBDVBPSI3_AUTOCONF = \
	--build=$(GNU_HOST) \
	--host=$(PTXCONF_GNU_TARGET) \
	--prefix=/usr \
	--disable-static \
	--enable-shared \
	--enable-release

ifdef PTXCONF_XFREE430
LIBDVBPSI3_AUTOCONF += --x-includes=$(CROSS_LIB_DIR)/include
LIBDVBPSI3_AUTOCONF += --x-libraries=$(CROSS_LIB_DIR)/lib
endif

$(STATEDIR)/libdvbpsi3.prepare: $(libdvbpsi3_prepare_deps)
	@$(call targetinfo, $@)
	@$(call clean, $(LIBDVBPSI3_DIR)/config.cache)
	cd $(LIBDVBPSI3_DIR) && \
		$(LIBDVBPSI3_PATH) $(LIBDVBPSI3_ENV) \
		./configure $(LIBDVBPSI3_AUTOCONF)
	touch $@

# ----------------------------------------------------------------------------
# Compile
# ----------------------------------------------------------------------------

libdvbpsi3_compile: $(STATEDIR)/libdvbpsi3.compile

libdvbpsi3_compile_deps = $(STATEDIR)/libdvbpsi3.prepare

$(STATEDIR)/libdvbpsi3.compile: $(libdvbpsi3_compile_deps)
	@$(call targetinfo, $@)
	$(LIBDVBPSI3_PATH) $(MAKE) -C $(LIBDVBPSI3_DIR)
	touch $@

# ----------------------------------------------------------------------------
# Install
# ----------------------------------------------------------------------------

libdvbpsi3_install: $(STATEDIR)/libdvbpsi3.install

$(STATEDIR)/libdvbpsi3.install: $(STATEDIR)/libdvbpsi3.compile
	@$(call targetinfo, $@)
	rm -rf $(LIBDVBPSI3_IPKG_TMP)
	$(LIBDVBPSI3_PATH) $(MAKE) -C $(LIBDVBPSI3_DIR) DESTDIR=$(LIBDVBPSI3_IPKG_TMP) install
	cp -a $(LIBDVBPSI3_IPKG_TMP)/usr/include/*	$(CROSS_LIB_DIR)/include
	cp -a $(LIBDVBPSI3_IPKG_TMP)/usr/lib/* 		$(CROSS_LIB_DIR)/lib
	perl -p -i -e "s/\/usr\/lib/`echo $(PTXCONF_PREFIX)/$(PTXCONF_GNU_TARGET)/lib | sed -e '/\//s//\\\\\//g'`/g" $(PTXCONF_PREFIX)/$(PTXCONF_GNU_TARGET)/lib/libdvbpsi.la
	rm -rf $(LIBDVBPSI3_IPKG_TMP)
	touch $@

# ----------------------------------------------------------------------------
# Target-Install
# ----------------------------------------------------------------------------

libdvbpsi3_targetinstall: $(STATEDIR)/libdvbpsi3.targetinstall

libdvbpsi3_targetinstall_deps = $(STATEDIR)/libdvbpsi3.compile

$(STATEDIR)/libdvbpsi3.targetinstall: $(libdvbpsi3_targetinstall_deps)
	@$(call targetinfo, $@)
	$(LIBDVBPSI3_PATH) $(MAKE) -C $(LIBDVBPSI3_DIR) DESTDIR=$(LIBDVBPSI3_IPKG_TMP) install
	rm -rf $(LIBDVBPSI3_IPKG_TMP)/usr/include
	rm  -f $(LIBDVBPSI3_IPKG_TMP)/usr/lib/*.*a
	$(CROSSSTRIP) $(LIBDVBPSI3_IPKG_TMP)/usr/lib/*
	mkdir -p $(LIBDVBPSI3_IPKG_TMP)/CONTROL
	echo "Package: libdvbpsi3" 						>$(LIBDVBPSI3_IPKG_TMP)/CONTROL/control
	echo "Priority: optional" 						>>$(LIBDVBPSI3_IPKG_TMP)/CONTROL/control
	echo "Section: Libraries" 						>>$(LIBDVBPSI3_IPKG_TMP)/CONTROL/control
	echo "Maintainer: Alexander Chukov <sash@pdaXrom.org>" 			>>$(LIBDVBPSI3_IPKG_TMP)/CONTROL/control
	echo "Architecture: $(SHORT_TARGET)" 					>>$(LIBDVBPSI3_IPKG_TMP)/CONTROL/control
	echo "Version: $(LIBDVBPSI3_VERSION)" 					>>$(LIBDVBPSI3_IPKG_TMP)/CONTROL/control
	echo "Depends: " 							>>$(LIBDVBPSI3_IPKG_TMP)/CONTROL/control
	echo "Description: simple library designed for decoding and generation MPEG TS and DVB PSI tables.">>$(LIBDVBPSI3_IPKG_TMP)/CONTROL/control
	cd $(FEEDDIR) && $(XMKIPKG) $(LIBDVBPSI3_IPKG_TMP)
	touch $@

# ----------------------------------------------------------------------------
# Image-Install
# ----------------------------------------------------------------------------

ifdef PTXCONF_LIBDVBPSI3_INSTALL
ROMPACKAGES += $(STATEDIR)/libdvbpsi3.imageinstall
endif

libdvbpsi3_imageinstall_deps = $(STATEDIR)/libdvbpsi3.targetinstall \
	$(STATEDIR)/virtual-image.install

$(STATEDIR)/libdvbpsi3.imageinstall: $(libdvbpsi3_imageinstall_deps)
	@$(call targetinfo, $@)
	cd $(FEEDDIR) && $(XIPKG) install libdvbpsi3
	touch $@

# ----------------------------------------------------------------------------
# Clean
# ----------------------------------------------------------------------------

libdvbpsi3_clean:
	rm -rf $(STATEDIR)/libdvbpsi3.*
	rm -rf $(LIBDVBPSI3_DIR)

# vim: syntax=make
