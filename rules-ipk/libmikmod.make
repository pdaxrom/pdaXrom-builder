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
ifdef PTXCONF_LIBMIKMOD
PACKAGES += libmikmod
endif

#
# Paths and names
#
LIBMIKMOD_VERSION	= 3.2.0-beta2
LIBMIKMOD		= libmikmod-$(LIBMIKMOD_VERSION)
LIBMIKMOD_SUFFIX	= tar.bz2
LIBMIKMOD_URL		= http://mikmod.raphnet.net/files/$(LIBMIKMOD).$(LIBMIKMOD_SUFFIX)
LIBMIKMOD_SOURCE	= $(SRCDIR)/$(LIBMIKMOD).$(LIBMIKMOD_SUFFIX)
LIBMIKMOD_DIR		= $(BUILDDIR)/$(LIBMIKMOD)
LIBMIKMOD_IPKG_TMP	= $(LIBMIKMOD_DIR)/ipkg_tmp

# ----------------------------------------------------------------------------
# Get
# ----------------------------------------------------------------------------

libmikmod_get: $(STATEDIR)/libmikmod.get

libmikmod_get_deps = $(LIBMIKMOD_SOURCE)

$(STATEDIR)/libmikmod.get: $(libmikmod_get_deps)
	@$(call targetinfo, $@)
	@$(call get_patches, $(LIBMIKMOD))
	touch $@

$(LIBMIKMOD_SOURCE):
	@$(call targetinfo, $@)
	@$(call get, $(LIBMIKMOD_URL))

# ----------------------------------------------------------------------------
# Extract
# ----------------------------------------------------------------------------

libmikmod_extract: $(STATEDIR)/libmikmod.extract

libmikmod_extract_deps = $(STATEDIR)/libmikmod.get

$(STATEDIR)/libmikmod.extract: $(libmikmod_extract_deps)
	@$(call targetinfo, $@)
	@$(call clean, $(LIBMIKMOD_DIR))
	@$(call extract, $(LIBMIKMOD_SOURCE))
	@$(call patchin, $(LIBMIKMOD))
	touch $@

# ----------------------------------------------------------------------------
# Prepare
# ----------------------------------------------------------------------------

libmikmod_prepare: $(STATEDIR)/libmikmod.prepare

#
# dependencies
#
libmikmod_prepare_deps = \
	$(STATEDIR)/libmikmod.extract \
	$(STATEDIR)/esound.install \
	$(STATEDIR)/virtual-xchain.install

ifdef PTXCONF_ALSA-UTILS
libmikmod_prepare_deps += $(STATEDIR)/alsa-lib.install
endif

LIBMIKMOD_PATH	=  PATH=$(CROSS_PATH)
LIBMIKMOD_ENV 	=  $(CROSS_ENV)
LIBMIKMOD_ENV	+= CFLAGS="$(TARGET_OPT_CFLAGS)"
LIBMIKMOD_ENV	+= PKG_CONFIG_PATH=$(CROSS_LIB_DIR)/lib/pkgconfig:$(CROSS_LIB_DIR)/lib/pkgconfig
#ifdef PTXCONF_XFREE430
#LIBMIKMOD_ENV	+= LDFLAGS=-Wl,-rpath-link,$(CROSS_LIB_DIR)/lib
#endif

#
# autoconf
#
LIBMIKMOD_AUTOCONF = \
	--build=$(GNU_HOST) \
	--host=$(PTXCONF_GNU_TARGET) \
	--prefix=/usr \
	--disable-af \
	--disable-sam9407 \
	--disable-ultra \
	--enable-oss \
	--enable-esd \
	--enable-threads \
	--enable-shared \
	--disable-static

ifndef PTXCONF_ALSA-UTILS
LIBMIKMOD_AUTOCONF += --disable-alsa
else
LIBMIKMOD_AUTOCONF += --enable-alsa
endif

ifdef PTXCONF_XFREE430
LIBMIKMOD_AUTOCONF += --x-includes=$(CROSS_LIB_DIR)/include
LIBMIKMOD_AUTOCONF += --x-libraries=$(CROSS_LIB_DIR)/lib
endif

$(STATEDIR)/libmikmod.prepare: $(libmikmod_prepare_deps)
	@$(call targetinfo, $@)
	@$(call clean, $(LIBMIKMOD_DIR)/config.cache)
	cd $(LIBMIKMOD_DIR) && \
		$(LIBMIKMOD_PATH) $(LIBMIKMOD_ENV) \
		./configure $(LIBMIKMOD_AUTOCONF)
	touch $@

# ----------------------------------------------------------------------------
# Compile
# ----------------------------------------------------------------------------

libmikmod_compile: $(STATEDIR)/libmikmod.compile

libmikmod_compile_deps = $(STATEDIR)/libmikmod.prepare

$(STATEDIR)/libmikmod.compile: $(libmikmod_compile_deps)
	@$(call targetinfo, $@)
	$(LIBMIKMOD_PATH) $(MAKE) -C $(LIBMIKMOD_DIR)
	touch $@

# ----------------------------------------------------------------------------
# Install
# ----------------------------------------------------------------------------

libmikmod_install: $(STATEDIR)/libmikmod.install

$(STATEDIR)/libmikmod.install: $(STATEDIR)/libmikmod.compile
	@$(call targetinfo, $@)
	$(LIBMIKMOD_PATH) $(MAKE) -C $(LIBMIKMOD_DIR) DESTDIR=$(LIBMIKMOD_IPKG_TMP) install
	cp -a  $(LIBMIKMOD_IPKG_TMP)/usr/bin/libmikmod-config   $(PTXCONF_PREFIX)/bin/
	cp -a  $(LIBMIKMOD_IPKG_TMP)/usr/include/*              $(CROSS_LIB_DIR)/include/
	cp -a  $(LIBMIKMOD_IPKG_TMP)/usr/lib/*.so*              $(CROSS_LIB_DIR)/lib/
	perl -p -i -e "s/\/usr/`echo $(PTXCONF_PREFIX)/$(PTXCONF_GNU_TARGET) | sed -e '/\//s//\\\\\//g'`/g" $(PTXCONF_PREFIX)/bin/libmikmod-config
	rm -rf $(LIBMIKMOD_IPKG_TMP)
	touch $@

# ----------------------------------------------------------------------------
# Target-Install
# ----------------------------------------------------------------------------

libmikmod_targetinstall: $(STATEDIR)/libmikmod.targetinstall

libmikmod_targetinstall_deps = $(STATEDIR)/libmikmod.compile \
	$(STATEDIR)/esound.targetinstall

$(STATEDIR)/libmikmod.targetinstall: $(libmikmod_targetinstall_deps)
	@$(call targetinfo, $@)
	$(LIBMIKMOD_PATH) $(MAKE) -C $(LIBMIKMOD_DIR) DESTDIR=$(LIBMIKMOD_IPKG_TMP) install
	rm -rf $(LIBMIKMOD_IPKG_TMP)/usr/bin
	rm -rf $(LIBMIKMOD_IPKG_TMP)/usr/include
	rm -rf $(LIBMIKMOD_IPKG_TMP)/usr/lib/*.*a
	rm -rf $(LIBMIKMOD_IPKG_TMP)/usr/info
	rm -rf $(LIBMIKMOD_IPKG_TMP)/usr/man
	rm -rf $(LIBMIKMOD_IPKG_TMP)/usr/share
	$(CROSSSTRIP) $(LIBMIKMOD_IPKG_TMP)/usr/lib/*
	mkdir -p $(LIBMIKMOD_IPKG_TMP)/CONTROL
	echo "Package: libmikmod" 							>$(LIBMIKMOD_IPKG_TMP)/CONTROL/control
	echo "Priority: optional" 							>>$(LIBMIKMOD_IPKG_TMP)/CONTROL/control
	echo "Section: Multimedia" 							>>$(LIBMIKMOD_IPKG_TMP)/CONTROL/control
	echo "Maintainer: Alexander Chukov <sash@pdaXrom.org>" 				>>$(LIBMIKMOD_IPKG_TMP)/CONTROL/control
	echo "Architecture: $(SHORT_TARGET)" 						>>$(LIBMIKMOD_IPKG_TMP)/CONTROL/control
	echo "Version: $(LIBMIKMOD_VERSION)" 						>>$(LIBMIKMOD_IPKG_TMP)/CONTROL/control
	echo "Depends: esound" 								>>$(LIBMIKMOD_IPKG_TMP)/CONTROL/control
	echo "Description: MOD, XM player library"					>>$(LIBMIKMOD_IPKG_TMP)/CONTROL/control
	cd $(FEEDDIR) && $(XMKIPKG) $(LIBMIKMOD_IPKG_TMP)
	touch $@

# ----------------------------------------------------------------------------
# Image-Install
# ----------------------------------------------------------------------------

ifdef PTXCONF_LIBMIKMOD_INSTALL
ROMPACKAGES += $(STATEDIR)/libmikmod.imageinstall
endif

libmikmod_imageinstall_deps = $(STATEDIR)/libmikmod.targetinstall \
	$(STATEDIR)/virtual-image.install

$(STATEDIR)/libmikmod.imageinstall: $(libmikmod_imageinstall_deps)
	@$(call targetinfo, $@)
	cd $(FEEDDIR) && $(XIPKG) install libmikmod
	touch $@

# ----------------------------------------------------------------------------
# Clean
# ----------------------------------------------------------------------------

libmikmod_clean:
	rm -rf $(STATEDIR)/libmikmod.*
	rm -rf $(LIBMIKMOD_DIR)

# vim: syntax=make
