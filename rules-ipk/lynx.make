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
ifdef PTXCONF_LYNX
PACKAGES += lynx
endif

#
# Paths and names
#
LYNX_VENDOR_VERSION	= 1
LYNX_VERSION		= 2.8.5
LYNX			= lynx$(LYNX_VERSION)
LYNX_SUFFIX		= tar.bz2
LYNX_URL		= http://lynx.isc.org/release/$(LYNX).$(LYNX_SUFFIX)
LYNX_SOURCE		= $(SRCDIR)/$(LYNX).$(LYNX_SUFFIX)
LYNX_DIR		= $(BUILDDIR)/lynx2-8-5
LYNX_IPKG_TMP		= $(LYNX_DIR)/ipkg_tmp

# ----------------------------------------------------------------------------
# Get
# ----------------------------------------------------------------------------

lynx_get: $(STATEDIR)/lynx.get

lynx_get_deps = $(LYNX_SOURCE)

$(STATEDIR)/lynx.get: $(lynx_get_deps)
	@$(call targetinfo, $@)
	@$(call get_patches, $(LYNX))
	touch $@

$(LYNX_SOURCE):
	@$(call targetinfo, $@)
	@$(call get, $(LYNX_URL))

# ----------------------------------------------------------------------------
# Extract
# ----------------------------------------------------------------------------

lynx_extract: $(STATEDIR)/lynx.extract

lynx_extract_deps = $(STATEDIR)/lynx.get

$(STATEDIR)/lynx.extract: $(lynx_extract_deps)
	@$(call targetinfo, $@)
	@$(call clean, $(LYNX_DIR))
	@$(call extract, $(LYNX_SOURCE))
	@$(call patchin, $(LYNX))
	touch $@

# ----------------------------------------------------------------------------
# Prepare
# ----------------------------------------------------------------------------

lynx_prepare: $(STATEDIR)/lynx.prepare

#
# dependencies
#
lynx_prepare_deps = \
	$(STATEDIR)/lynx.extract \
	$(STATEDIR)/openssl.install \
	$(STATEDIR)/ncurses.install \
	$(STATEDIR)/ubzip2.install \
	$(STATEDIR)/zlib.install \
	$(STATEDIR)/virtual-xchain.install

LYNX_PATH	=  PATH=$(CROSS_PATH)
LYNX_ENV 	=  $(CROSS_ENV)
LYNX_ENV	+= CFLAGS="-O2 -fomit-frame-pointer"
LYNX_ENV	+= PKG_CONFIG_PATH=$(CROSS_LIB_DIR)/lib/pkgconfig
#ifdef PTXCONF_XFREE430
#LYNX_ENV	+= LDFLAGS=-Wl,-rpath-link,$(CROSS_LIB_DIR)/X11R6/lib
#endif

#
# autoconf
#
LYNX_AUTOCONF = \
	--build=$(GNU_HOST) \
	--host=$(PTXCONF_GNU_TARGET) \
	--prefix=/usr \
	--with-bzlib \
	--with-zlib \
	--enable-color-style \
	--enable-default-colors \
	--enable-justify-elts \
	--enable-charset-choice \
	--with-ssl=$(CROSS_LIB_DIR) \
	--sysconfdir=/usr/lib/lynx

ifdef PTXCONF_XFREE430
LYNX_AUTOCONF += --x-includes=$(CROSS_LIB_DIR)/include
LYNX_AUTOCONF += --x-libraries=$(CROSS_LIB_DIR)/lib
endif

$(STATEDIR)/lynx.prepare: $(lynx_prepare_deps)
	@$(call targetinfo, $@)
	@$(call clean, $(LYNX_DIR)/config.cache)
	cd $(LYNX_DIR) && \
		$(LYNX_PATH) $(LYNX_ENV) \
		./configure $(LYNX_AUTOCONF)
	touch $@

# ----------------------------------------------------------------------------
# Compile
# ----------------------------------------------------------------------------

lynx_compile: $(STATEDIR)/lynx.compile

lynx_compile_deps = $(STATEDIR)/lynx.prepare

$(STATEDIR)/lynx.compile: $(lynx_compile_deps)
	@$(call targetinfo, $@)
	$(LYNX_PATH) $(MAKE) -C $(LYNX_DIR)/src/chrtrans CC=gcc CPP="gcc -E"
	$(LYNX_PATH) $(MAKE) -C $(LYNX_DIR)
	touch $@

# ----------------------------------------------------------------------------
# Install
# ----------------------------------------------------------------------------

lynx_install: $(STATEDIR)/lynx.install

$(STATEDIR)/lynx.install: $(STATEDIR)/lynx.compile
	@$(call targetinfo, $@)
	touch $@

# ----------------------------------------------------------------------------
# Target-Install
# ----------------------------------------------------------------------------

lynx_targetinstall: $(STATEDIR)/lynx.targetinstall

lynx_targetinstall_deps = $(STATEDIR)/lynx.compile \
	$(STATEDIR)/openssl.targetinstall \
	$(STATEDIR)/ncurses.targetinstall \
	$(STATEDIR)/ubzip2.targetinstall \
	$(STATEDIR)/zlib.targetinstall

$(STATEDIR)/lynx.targetinstall: $(lynx_targetinstall_deps)
	@$(call targetinfo, $@)
	$(LYNX_PATH) $(MAKE) -C $(LYNX_DIR) DESTDIR=$(LYNX_IPKG_TMP) install
	rm -rf $(LYNX_IPKG_TMP)/usr/man
	$(CROSSSTRIP) $(LYNX_IPKG_TMP)/usr/bin/*
	mkdir -p $(LYNX_IPKG_TMP)/CONTROL
	echo "Package: lynx" 								 >$(LYNX_IPKG_TMP)/CONTROL/control
	echo "Priority: optional" 							>>$(LYNX_IPKG_TMP)/CONTROL/control
	echo "Section: Internet" 							>>$(LYNX_IPKG_TMP)/CONTROL/control
	echo "Maintainer: Alexander Chukov <sash@pdaXrom.org>" 				>>$(LYNX_IPKG_TMP)/CONTROL/control
	echo "Architecture: $(SHORT_TARGET)" 						>>$(LYNX_IPKG_TMP)/CONTROL/control
	echo "Version: $(LYNX_VERSION)-$(LYNX_VENDOR_VERSION)" 				>>$(LYNX_IPKG_TMP)/CONTROL/control
	echo "Depends: ncurses, openssl, libz, bzip2" 					>>$(LYNX_IPKG_TMP)/CONTROL/control
	echo "Description: Lynx is a text browser for the World Wide Web."		>>$(LYNX_IPKG_TMP)/CONTROL/control
	cd $(FEEDDIR) && $(XMKIPKG) $(LYNX_IPKG_TMP)
	touch $@

# ----------------------------------------------------------------------------
# Image-Install
# ----------------------------------------------------------------------------

ifdef PTXCONF_LYNX_INSTALL
ROMPACKAGES += $(STATEDIR)/lynx.imageinstall
endif

lynx_imageinstall_deps = $(STATEDIR)/lynx.targetinstall \
	$(STATEDIR)/virtual-image.install

$(STATEDIR)/lynx.imageinstall: $(lynx_imageinstall_deps)
	@$(call targetinfo, $@)
	cd $(FEEDDIR) && $(XIPKG) install lynx
	touch $@

# ----------------------------------------------------------------------------
# Clean
# ----------------------------------------------------------------------------

lynx_clean:
	rm -rf $(STATEDIR)/lynx.*
	rm -rf $(LYNX_DIR)

# vim: syntax=make
