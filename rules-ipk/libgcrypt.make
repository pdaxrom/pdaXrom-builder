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
ifdef PTXCONF_LIBGCRYPT
PACKAGES += libgcrypt
endif

#
# Paths and names
#
LIBGCRYPT_VERSION	= 1.2.0
LIBGCRYPT		= libgcrypt-$(LIBGCRYPT_VERSION)
LIBGCRYPT_SUFFIX	= tar.gz
LIBGCRYPT_URL		= ftp://ftp.gnupg.org/gcrypt/libgcrypt/$(LIBGCRYPT).$(LIBGCRYPT_SUFFIX)
LIBGCRYPT_SOURCE	= $(SRCDIR)/$(LIBGCRYPT).$(LIBGCRYPT_SUFFIX)
LIBGCRYPT_DIR		= $(BUILDDIR)/$(LIBGCRYPT)
LIBGCRYPT_IPKG_TMP	= $(LIBGCRYPT_DIR)/ipkg_tmp

# ----------------------------------------------------------------------------
# Get
# ----------------------------------------------------------------------------

libgcrypt_get: $(STATEDIR)/libgcrypt.get

libgcrypt_get_deps = $(LIBGCRYPT_SOURCE)

$(STATEDIR)/libgcrypt.get: $(libgcrypt_get_deps)
	@$(call targetinfo, $@)
	@$(call get_patches, $(LIBGCRYPT))
	touch $@

$(LIBGCRYPT_SOURCE):
	@$(call targetinfo, $@)
	@$(call get, $(LIBGCRYPT_URL))

# ----------------------------------------------------------------------------
# Extract
# ----------------------------------------------------------------------------

libgcrypt_extract: $(STATEDIR)/libgcrypt.extract

libgcrypt_extract_deps = $(STATEDIR)/libgcrypt.get

$(STATEDIR)/libgcrypt.extract: $(libgcrypt_extract_deps)
	@$(call targetinfo, $@)
	@$(call clean, $(LIBGCRYPT_DIR))
	@$(call extract, $(LIBGCRYPT_SOURCE))
	@$(call patchin, $(LIBGCRYPT))
	touch $@

# ----------------------------------------------------------------------------
# Prepare
# ----------------------------------------------------------------------------

libgcrypt_prepare: $(STATEDIR)/libgcrypt.prepare

#
# dependencies
#
libgcrypt_prepare_deps = \
	$(STATEDIR)/libgcrypt.extract \
	$(STATEDIR)/libgpg-error.install \
	$(STATEDIR)/virtual-xchain.install

LIBGCRYPT_PATH	=  PATH=$(CROSS_PATH)
LIBGCRYPT_ENV 	=  $(CROSS_ENV)
#LIBGCRYPT_ENV	+=
LIBGCRYPT_ENV	+= PKG_CONFIG_PATH=$(CROSS_LIB_DIR)/lib/pkgconfig:$(CROSS_LIB_DIR)/lib/pkgconfig
#ifdef PTXCONF_XFREE430
#LIBGCRYPT_ENV	+= LDFLAGS=-Wl,-rpath-link,$(CROSS_LIB_DIR)/lib
#endif

#
# autoconf
#
LIBGCRYPT_AUTOCONF = \
	--build=$(GNU_HOST) \
	--host=$(PTXCONF_GNU_TARGET) \
	--prefix=/usr \
	--enable-shared \
	--disable-static \
	--disable-asm

ifdef PTXCONF_XFREE430
LIBGCRYPT_AUTOCONF += --x-includes=$(CROSS_LIB_DIR)/include
LIBGCRYPT_AUTOCONF += --x-libraries=$(CROSS_LIB_DIR)/lib
endif

$(STATEDIR)/libgcrypt.prepare: $(libgcrypt_prepare_deps)
	@$(call targetinfo, $@)
	@$(call clean, $(LIBGCRYPT_DIR)/config.cache)
	cd $(LIBGCRYPT_DIR) && \
		$(LIBGCRYPT_PATH) $(LIBGCRYPT_ENV) \
		./configure $(LIBGCRYPT_AUTOCONF)
	touch $@

# ----------------------------------------------------------------------------
# Compile
# ----------------------------------------------------------------------------

libgcrypt_compile: $(STATEDIR)/libgcrypt.compile

libgcrypt_compile_deps = $(STATEDIR)/libgcrypt.prepare

$(STATEDIR)/libgcrypt.compile: $(libgcrypt_compile_deps)
	@$(call targetinfo, $@)
	$(LIBGCRYPT_PATH) $(MAKE) -C $(LIBGCRYPT_DIR)
	touch $@

# ----------------------------------------------------------------------------
# Install
# ----------------------------------------------------------------------------

libgcrypt_install: $(STATEDIR)/libgcrypt.install

$(STATEDIR)/libgcrypt.install: $(STATEDIR)/libgcrypt.compile
	@$(call targetinfo, $@)
	$(LIBGCRYPT_PATH) $(MAKE) -C $(LIBGCRYPT_DIR) DESTDIR=$(LIBGCRYPT_IPKG_TMP) install
	cp -a  $(LIBGCRYPT_IPKG_TMP)/usr/include/* $(CROSS_LIB_DIR)/include
	cp -a  $(LIBGCRYPT_IPKG_TMP)/usr/lib/*     $(CROSS_LIB_DIR)/lib
	cp -a  $(LIBGCRYPT_IPKG_TMP)/usr/share/aclocal/*      $(CROSS_LIB_DIR)/share/aclocal
	cp -a  $(LIBGCRYPT_IPKG_TMP)/usr/bin/* $(PTXCONF_PREFIX)/bin
	rm -rf $(LIBGCRYPT_IPKG_TMP)
	perl -p -i -e "s/\/usr/`echo $(PTXCONF_PREFIX)/$(PTXCONF_GNU_TARGET) | sed -e '/\//s//\\\\\//g'`/g" $(PTXCONF_PREFIX)/bin/libgcrypt-config
	perl -p -i -e "s/\/usr\/lib/`echo $(PTXCONF_PREFIX)/$(PTXCONF_GNU_TARGET)/lib | sed -e '/\//s//\\\\\//g'`/g" $(PTXCONF_PREFIX)/$(PTXCONF_GNU_TARGET)/lib/libgcrypt.la
	touch $@

# ----------------------------------------------------------------------------
# Target-Install
# ----------------------------------------------------------------------------

libgcrypt_targetinstall: $(STATEDIR)/libgcrypt.targetinstall

libgcrypt_targetinstall_deps = \
	$(STATEDIR)/libgpg-error.targetinstall \
	$(STATEDIR)/libgcrypt.compile

$(STATEDIR)/libgcrypt.targetinstall: $(libgcrypt_targetinstall_deps)
	@$(call targetinfo, $@)
	$(LIBGCRYPT_PATH) $(MAKE) -C $(LIBGCRYPT_DIR) DESTDIR=$(LIBGCRYPT_IPKG_TMP) install
	rm -rf $(LIBGCRYPT_IPKG_TMP)/usr/bin
	rm -rf $(LIBGCRYPT_IPKG_TMP)/usr/include
	rm -rf $(LIBGCRYPT_IPKG_TMP)/usr/info
	rm -rf $(LIBGCRYPT_IPKG_TMP)/usr/share
	rm -rf $(LIBGCRYPT_IPKG_TMP)/usr/lib/*.la
	$(CROSSSTRIP) $(LIBGCRYPT_IPKG_TMP)/usr/lib/*.so.11.1.1
	mkdir -p $(LIBGCRYPT_IPKG_TMP)/CONTROL
	echo "Package: libgcrypt" 			>$(LIBGCRYPT_IPKG_TMP)/CONTROL/control
	echo "Priority: optional" 			>>$(LIBGCRYPT_IPKG_TMP)/CONTROL/control
	echo "Section: Libraries" 			>>$(LIBGCRYPT_IPKG_TMP)/CONTROL/control
	echo "Maintainer: Alexander Chukov <sash@pdaXrom.org>">>$(LIBGCRYPT_IPKG_TMP)/CONTROL/control
	echo "Architecture: $(SHORT_TARGET)" 		>>$(LIBGCRYPT_IPKG_TMP)/CONTROL/control
	echo "Version: $(LIBGCRYPT_VERSION)" 		>>$(LIBGCRYPT_IPKG_TMP)/CONTROL/control
	echo "Depends: libgpg-error" 			>>$(LIBGCRYPT_IPKG_TMP)/CONTROL/control
	echo "Description: Libgcrypt is a general purpose crypto library based on the code used in GnuPG.">>$(LIBGCRYPT_IPKG_TMP)/CONTROL/control
	cd $(FEEDDIR) && $(XMKIPKG) $(LIBGCRYPT_IPKG_TMP)
	touch $@

# ----------------------------------------------------------------------------
# Image-Install
# ----------------------------------------------------------------------------

ifdef PTXCONF_LIBGCRYPT_INSTALL
ROMPACKAGES += $(STATEDIR)/libgcrypt.imageinstall
endif

libgcrypt_imageinstall_deps = $(STATEDIR)/libgcrypt.targetinstall \
	$(STATEDIR)/virtual-image.install

$(STATEDIR)/libgcrypt.imageinstall: $(libgcrypt_imageinstall_deps)
	@$(call targetinfo, $@)
	cd $(FEEDDIR) && $(XIPKG) install libgcrypt
	touch $@

# ----------------------------------------------------------------------------
# Clean
# ----------------------------------------------------------------------------

libgcrypt_clean:
	rm -rf $(STATEDIR)/libgcrypt.*
	rm -rf $(LIBGCRYPT_DIR)

# vim: syntax=make
