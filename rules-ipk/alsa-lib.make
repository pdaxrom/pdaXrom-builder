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
ifdef PTXCONF_ALSA-LIB
PACKAGES += alsa-lib
endif

#
# Paths and names
#
ALSA-LIB_VENDOR_VERSION	= 1
ALSA-LIB_VERSION	= 1.0.8
ALSA-LIB		= alsa-lib-$(ALSA-LIB_VERSION)
ALSA-LIB_SUFFIX		= tar.bz2
ALSA-LIB_URL		= ftp://ftp.alsa-project.org/pub/lib/$(ALSA-LIB).$(ALSA-LIB_SUFFIX)
ALSA-LIB_SOURCE		= $(SRCDIR)/$(ALSA-LIB).$(ALSA-LIB_SUFFIX)
ALSA-LIB_DIR		= $(BUILDDIR)/$(ALSA-LIB)
ALSA-LIB_IPKG_TMP	= $(ALSA-LIB_DIR)/ipkg_tmp

# ----------------------------------------------------------------------------
# Get
# ----------------------------------------------------------------------------

alsa-lib_get: $(STATEDIR)/alsa-lib.get

alsa-lib_get_deps = $(ALSA-LIB_SOURCE)

$(STATEDIR)/alsa-lib.get: $(alsa-lib_get_deps)
	@$(call targetinfo, $@)
	@$(call get_patches, $(ALSA-LIB))
	touch $@

$(ALSA-LIB_SOURCE):
	@$(call targetinfo, $@)
	@$(call get, $(ALSA-LIB_URL))

# ----------------------------------------------------------------------------
# Extract
# ----------------------------------------------------------------------------

alsa-lib_extract: $(STATEDIR)/alsa-lib.extract

alsa-lib_extract_deps = $(STATEDIR)/alsa-lib.get

$(STATEDIR)/alsa-lib.extract: $(alsa-lib_extract_deps)
	@$(call targetinfo, $@)
	@$(call clean, $(ALSA-LIB_DIR))
	@$(call extract, $(ALSA-LIB_SOURCE))
	@$(call patchin, $(ALSA-LIB))
	touch $@

# ----------------------------------------------------------------------------
# Prepare
# ----------------------------------------------------------------------------

alsa-lib_prepare: $(STATEDIR)/alsa-lib.prepare

#
# dependencies
#
alsa-lib_prepare_deps = \
	$(STATEDIR)/alsa-lib.extract \
	$(STATEDIR)/virtual-xchain.install

ALSA-LIB_PATH	=  PATH=$(CROSS_PATH)
ALSA-LIB_ENV 	=  $(CROSS_ENV)
#ALSA-LIB_ENV	+=
ALSA-LIB_ENV	+= PKG_CONFIG_PATH=$(CROSS_LIB_DIR)/lib/pkgconfig:$(CROSS_LIB_DIR)/lib/pkgconfig
#ifdef PTXCONF_XFREE430
#ALSA-LIB_ENV	+= LDFLAGS=-Wl,-rpath-link,$(CROSS_LIB_DIR)/lib
#endif

#
# autoconf
#
ALSA-LIB_AUTOCONF = \
	--build=$(GNU_HOST) \
	--host=$(PTXCONF_GNU_TARGET) \
	--prefix=/usr \
	--disable-debug \
	--disable-static \
	--enable-shared \
	--sysconfdir=/etc

ifdef PTXCONF_XFREE430
ALSA-LIB_AUTOCONF += --x-includes=$(CROSS_LIB_DIR)/include
ALSA-LIB_AUTOCONF += --x-libraries=$(CROSS_LIB_DIR)/lib
endif

$(STATEDIR)/alsa-lib.prepare: $(alsa-lib_prepare_deps)
	@$(call targetinfo, $@)
	@$(call clean, $(ALSA-LIB_DIR)/config.cache)
	cd $(ALSA-LIB_DIR) && \
		$(ALSA-LIB_PATH) $(ALSA-LIB_ENV) \
		./configure $(ALSA-LIB_AUTOCONF)
	touch $@

# ----------------------------------------------------------------------------
# Compile
# ----------------------------------------------------------------------------

alsa-lib_compile: $(STATEDIR)/alsa-lib.compile

alsa-lib_compile_deps = $(STATEDIR)/alsa-lib.prepare

$(STATEDIR)/alsa-lib.compile: $(alsa-lib_compile_deps)
	@$(call targetinfo, $@)
	$(ALSA-LIB_PATH) $(MAKE) -C $(ALSA-LIB_DIR)
	touch $@

# ----------------------------------------------------------------------------
# Install
# ----------------------------------------------------------------------------

alsa-lib_install: $(STATEDIR)/alsa-lib.install

$(STATEDIR)/alsa-lib.install: $(STATEDIR)/alsa-lib.compile
	@$(call targetinfo, $@)
	rm -rf $(ALSA-LIB_IPKG_TMP)
	$(ALSA-LIB_PATH) $(MAKE) -C $(ALSA-LIB_DIR) DESTDIR=$(ALSA-LIB_IPKG_TMP) install
	cp -a $(ALSA-LIB_IPKG_TMP)/usr/include/* 	$(CROSS_LIB_DIR)/include
	cp -a $(ALSA-LIB_IPKG_TMP)/usr/lib/*     	$(CROSS_LIB_DIR)/lib
	cp -a $(ALSA-LIB_IPKG_TMP)/usr/share/aclocal/*	$(PTXCONF_PREFIX)/share/aclocal/
	perl -i -p -e "s,\/usr/lib,$(CROSS_LIB_DIR)/lib,g" $(CROSS_LIB_DIR)/lib/libasound.la
	perl -i -p -e "s,\/usr,$(CROSS_LIB_DIR),g" 	$(CROSS_LIB_DIR)/lib/pkgconfig/alsa.pc
	rm -rf $(ALSA-LIB_IPKG_TMP)
	touch $@

# ----------------------------------------------------------------------------
# Target-Install
# ----------------------------------------------------------------------------

alsa-lib_targetinstall: $(STATEDIR)/alsa-lib.targetinstall

alsa-lib_targetinstall_deps = $(STATEDIR)/alsa-lib.compile

$(STATEDIR)/alsa-lib.targetinstall: $(alsa-lib_targetinstall_deps)
	@$(call targetinfo, $@)
	$(ALSA-LIB_PATH) $(MAKE) -C $(ALSA-LIB_DIR) DESTDIR=$(ALSA-LIB_IPKG_TMP) install
	rm -rf $(ALSA-LIB_IPKG_TMP)/usr/include
	rm -rf $(ALSA-LIB_IPKG_TMP)/usr/lib/*.*a
	rm -rf $(ALSA-LIB_IPKG_TMP)/usr/lib/pkgconfig
	rm -rf $(ALSA-LIB_IPKG_TMP)/usr/share/aclocal
	$(CROSSSTRIP) $(ALSA-LIB_IPKG_TMP)/usr/bin/*
	$(CROSSSTRIP) $(ALSA-LIB_IPKG_TMP)/usr/lib/*.so*
	mkdir -p $(ALSA-LIB_IPKG_TMP)/CONTROL
	echo "Package: alsa-lib" 							 >$(ALSA-LIB_IPKG_TMP)/CONTROL/control
	echo "Priority: optional" 							>>$(ALSA-LIB_IPKG_TMP)/CONTROL/control
	echo "Section: Multimedia" 							>>$(ALSA-LIB_IPKG_TMP)/CONTROL/control
	echo "Maintainer: Alexander Chukov <sash@pdaXrom.org>" 				>>$(ALSA-LIB_IPKG_TMP)/CONTROL/control
	echo "Architecture: $(SHORT_TARGET)" 						>>$(ALSA-LIB_IPKG_TMP)/CONTROL/control
	echo "Version: $(ALSA-LIB_VERSION)-$(ALSA-LIB_VENDOR_VERSION)" 			>>$(ALSA-LIB_IPKG_TMP)/CONTROL/control
	echo "Depends: " 								>>$(ALSA-LIB_IPKG_TMP)/CONTROL/control
	echo "Description: ALSA library"						>>$(ALSA-LIB_IPKG_TMP)/CONTROL/control
	cd $(FEEDDIR) && $(XMKIPKG) $(ALSA-LIB_IPKG_TMP)
	touch $@

# ----------------------------------------------------------------------------
# Image-Install
# ----------------------------------------------------------------------------

ifdef PTXCONF_ALSA-LIB_INSTALL
ROMPACKAGES += $(STATEDIR)/alsa-lib.imageinstall
endif

alsa-lib_imageinstall_deps = $(STATEDIR)/alsa-lib.targetinstall \
	$(STATEDIR)/virtual-image.install

$(STATEDIR)/alsa-lib.imageinstall: $(alsa-lib_imageinstall_deps)
	@$(call targetinfo, $@)
	cd $(FEEDDIR) && $(XIPKG) install alsa-lib
	touch $@

# ----------------------------------------------------------------------------
# Clean
# ----------------------------------------------------------------------------

alsa-lib_clean:
	rm -rf $(STATEDIR)/alsa-lib.*
	rm -rf $(ALSA-LIB_DIR)

# vim: syntax=make
