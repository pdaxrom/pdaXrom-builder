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
ifdef PTXCONF_LIBXSLT
PACKAGES += libxslt
endif

#
# Paths and names
#
LIBXSLT_VERSION		= 1.1.0
LIBXSLT			= libxslt-$(LIBXSLT_VERSION)
LIBXSLT_SUFFIX		= tar.bz2
LIBXSLT_URL		= http://ftp.gnome.org/pub/GNOME/sources/libxslt/1.1/$(LIBXSLT).$(LIBXSLT_SUFFIX)
LIBXSLT_SOURCE		= $(SRCDIR)/$(LIBXSLT).$(LIBXSLT_SUFFIX)
LIBXSLT_DIR		= $(BUILDDIR)/$(LIBXSLT)
LIBXSLT_IPKG_TMP	= $(LIBXSLT_DIR)/ipkg_tmp

# ----------------------------------------------------------------------------
# Get
# ----------------------------------------------------------------------------

libxslt_get: $(STATEDIR)/libxslt.get

libxslt_get_deps = $(LIBXSLT_SOURCE)

$(STATEDIR)/libxslt.get: $(libxslt_get_deps)
	@$(call targetinfo, $@)
	@$(call get_patches, $(LIBXSLT))
	touch $@

$(LIBXSLT_SOURCE):
	@$(call targetinfo, $@)
	@$(call get, $(LIBXSLT_URL))

# ----------------------------------------------------------------------------
# Extract
# ----------------------------------------------------------------------------

libxslt_extract: $(STATEDIR)/libxslt.extract

libxslt_extract_deps = $(STATEDIR)/libxslt.get

$(STATEDIR)/libxslt.extract: $(libxslt_extract_deps)
	@$(call targetinfo, $@)
	@$(call clean, $(LIBXSLT_DIR))
	@$(call extract, $(LIBXSLT_SOURCE))
	@$(call patchin, $(LIBXSLT))
	touch $@

# ----------------------------------------------------------------------------
# Prepare
# ----------------------------------------------------------------------------

libxslt_prepare: $(STATEDIR)/libxslt.prepare

#
# dependencies
#
libxslt_prepare_deps = \
	$(STATEDIR)/libxslt.extract \
	$(STATEDIR)/libxml2.install \
	$(STATEDIR)/virtual-xchain.install

LIBXSLT_PATH	=  PATH=$(CROSS_PATH)
LIBXSLT_ENV 	=  $(CROSS_ENV)
LIBXSLT_ENV	+= CFLAGS="-O2 -fomit-frame-pointer"
LIBXSLT_ENV	+= PKG_CONFIG_PATH=$(CROSS_LIB_DIR)/lib/pkgconfig:$(CROSS_LIB_DIR)/lib/pkgconfig
#ifdef PTXCONF_XFREE430
#LIBXSLT_ENV	+= LDFLAGS=-Wl,-rpath-link,$(CROSS_LIB_DIR)/lib
#endif

#
# autoconf
#
LIBXSLT_AUTOCONF = \
	--build=$(GNU_HOST) \
	--host=$(PTXCONF_GNU_TARGET) \
	--prefix=/usr \
	--disable-debug \
	--enable-shared \
	--disable-static

ifdef PTXCONF_XFREE430
LIBXSLT_AUTOCONF += --x-includes=$(CROSS_LIB_DIR)/include
LIBXSLT_AUTOCONF += --x-libraries=$(CROSS_LIB_DIR)/lib
endif

$(STATEDIR)/libxslt.prepare: $(libxslt_prepare_deps)
	@$(call targetinfo, $@)
	@$(call clean, $(LIBXSLT_DIR)/config.cache)
	cd $(LIBXSLT_DIR) && \
		$(LIBXSLT_PATH) $(LIBXSLT_ENV) \
		./configure $(LIBXSLT_AUTOCONF)
	touch $@

# ----------------------------------------------------------------------------
# Compile
# ----------------------------------------------------------------------------

libxslt_compile: $(STATEDIR)/libxslt.compile

libxslt_compile_deps = $(STATEDIR)/libxslt.prepare

$(STATEDIR)/libxslt.compile: $(libxslt_compile_deps)
	@$(call targetinfo, $@)
	$(LIBXSLT_PATH) $(MAKE) -C $(LIBXSLT_DIR)
	touch $@

# ----------------------------------------------------------------------------
# Install
# ----------------------------------------------------------------------------

libxslt_install: $(STATEDIR)/libxslt.install

$(STATEDIR)/libxslt.install: $(STATEDIR)/libxslt.compile
	@$(call targetinfo, $@)
	$(LIBXSLT_PATH) $(MAKE) -C $(LIBXSLT_DIR) DESTDIR=$(LIBXSLT_IPKG_TMP) install
	asdasd
	rm -rf $(LIBXSLT_IPKG_TMP)
	touch $@

# ----------------------------------------------------------------------------
# Target-Install
# ----------------------------------------------------------------------------

libxslt_targetinstall: $(STATEDIR)/libxslt.targetinstall

libxslt_targetinstall_deps = $(STATEDIR)/libxslt.compile \
	$(STATEDIR)/libxml2.targetinstall

$(STATEDIR)/libxslt.targetinstall: $(libxslt_targetinstall_deps)
	@$(call targetinfo, $@)
	$(LIBXSLT_PATH) $(MAKE) -C $(LIBXSLT_DIR) DESTDIR=$(LIBXSLT_IPKG_TMP) install
	rm  -f $(LIBXSLT_IPKG_TMP)/usr/bin/xslt-config
	rm -rf $(LIBXSLT_IPKG_TMP)/usr/include
	rm -rf $(LIBXSLT_IPKG_TMP)/usr/lib/*.*a
	rm -rf $(LIBXSLT_IPKG_TMP)/usr/lib/*.sh
	rm -rf $(LIBXSLT_IPKG_TMP)/usr/lib/pkgconfig
	rm -rf $(LIBXSLT_IPKG_TMP)/usr/lib/python2.2
	rm -rf $(LIBXSLT_IPKG_TMP)/usr/man
	rm -rf $(LIBXSLT_IPKG_TMP)/usr/share
	$(CROSSSTRIP) $(LIBXSLT_IPKG_TMP)/usr/bin/*
	$(CROSSSTRIP) $(LIBXSLT_IPKG_TMP)/usr/lib/*
	mkdir -p $(LIBXSLT_IPKG_TMP)/CONTROL
	echo "Package: libxslt" 						 >$(LIBXSLT_IPKG_TMP)/CONTROL/control
	echo "Priority: optional" 						>>$(LIBXSLT_IPKG_TMP)/CONTROL/control
	echo "Section: Libraries" 						>>$(LIBXSLT_IPKG_TMP)/CONTROL/control
	echo "Maintainer: Alexander Chukov <sash@pdaXrom.org>" 			>>$(LIBXSLT_IPKG_TMP)/CONTROL/control
	echo "Architecture: $(SHORT_TARGET)" 					>>$(LIBXSLT_IPKG_TMP)/CONTROL/control
	echo "Version: $(LIBXSLT_VERSION)" 					>>$(LIBXSLT_IPKG_TMP)/CONTROL/control
	echo "Depends: libxml2" 						>>$(LIBXSLT_IPKG_TMP)/CONTROL/control
	echo "Description: XSLT support for libxml2"				>>$(LIBXSLT_IPKG_TMP)/CONTROL/control
	cd $(FEEDDIR) && $(XMKIPKG) $(LIBXSLT_IPKG_TMP)
	touch $@

# ----------------------------------------------------------------------------
# Image-Install
# ----------------------------------------------------------------------------

ifdef PTXCONF_LIBXSLT_INSTALL
ROMPACKAGES += $(STATEDIR)/libxslt.imageinstall
endif

libxslt_imageinstall_deps = $(STATEDIR)/libxslt.targetinstall \
	$(STATEDIR)/virtual-image.install

$(STATEDIR)/libxslt.imageinstall: $(libxslt_imageinstall_deps)
	@$(call targetinfo, $@)
	cd $(FEEDDIR) && $(XIPKG) install libxslt
	touch $@

# ----------------------------------------------------------------------------
# Clean
# ----------------------------------------------------------------------------

libxslt_clean:
	rm -rf $(STATEDIR)/libxslt.*
	rm -rf $(LIBXSLT_DIR)

# vim: syntax=make
