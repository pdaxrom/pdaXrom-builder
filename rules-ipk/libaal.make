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
ifdef PTXCONF_LIBAAL
PACKAGES += libaal
endif

#
# Paths and names
#
LIBAAL_VENDOR_VERSION	= 1
LIBAAL_VERSION		= 1.0.3
LIBAAL			= libaal-$(LIBAAL_VERSION)
LIBAAL_SUFFIX		= tar.gz
LIBAAL_URL		= ftp://ftp.namesys.com/pub/reiser4progs/$(LIBAAL).$(LIBAAL_SUFFIX)
LIBAAL_SOURCE		= $(SRCDIR)/$(LIBAAL).$(LIBAAL_SUFFIX)
LIBAAL_DIR		= $(BUILDDIR)/$(LIBAAL)
LIBAAL_IPKG_TMP		= $(LIBAAL_DIR)/ipkg_tmp

# ----------------------------------------------------------------------------
# Get
# ----------------------------------------------------------------------------

libaal_get: $(STATEDIR)/libaal.get

libaal_get_deps = $(LIBAAL_SOURCE)

$(STATEDIR)/libaal.get: $(libaal_get_deps)
	@$(call targetinfo, $@)
	@$(call get_patches, $(LIBAAL))
	touch $@

$(LIBAAL_SOURCE):
	@$(call targetinfo, $@)
	@$(call get, $(LIBAAL_URL))

# ----------------------------------------------------------------------------
# Extract
# ----------------------------------------------------------------------------

libaal_extract: $(STATEDIR)/libaal.extract

libaal_extract_deps = $(STATEDIR)/libaal.get

$(STATEDIR)/libaal.extract: $(libaal_extract_deps)
	@$(call targetinfo, $@)
	@$(call clean, $(LIBAAL_DIR))
	@$(call extract, $(LIBAAL_SOURCE))
	@$(call patchin, $(LIBAAL))
	touch $@

# ----------------------------------------------------------------------------
# Prepare
# ----------------------------------------------------------------------------

libaal_prepare: $(STATEDIR)/libaal.prepare

#
# dependencies
#
libaal_prepare_deps = \
	$(STATEDIR)/libaal.extract \
	$(STATEDIR)/virtual-xchain.install

LIBAAL_PATH	=  PATH=$(CROSS_PATH)
LIBAAL_ENV 	=  $(CROSS_ENV)
#LIBAAL_ENV	+=
LIBAAL_ENV	+= PKG_CONFIG_PATH=$(CROSS_LIB_DIR)/lib/pkgconfig:$(CROSS_LIB_DIR)/lib/pkgconfig
#ifdef PTXCONF_XFREE430
#LIBAAL_ENV	+= LDFLAGS=-Wl,-rpath-link,$(CROSS_LIB_DIR)/lib
#endif

#
# autoconf
#
LIBAAL_AUTOCONF = \
	--build=$(GNU_HOST) \
	--host=$(PTXCONF_GNU_TARGET) \
	--prefix=/usr \
	--enable-shared \
	--disable-static

ifdef PTXCONF_XFREE430
LIBAAL_AUTOCONF += --x-includes=$(CROSS_LIB_DIR)/include
LIBAAL_AUTOCONF += --x-libraries=$(CROSS_LIB_DIR)/lib
endif

$(STATEDIR)/libaal.prepare: $(libaal_prepare_deps)
	@$(call targetinfo, $@)
	@$(call clean, $(LIBAAL_DIR)/config.cache)
	cd $(LIBAAL_DIR) && \
		$(LIBAAL_PATH) $(LIBAAL_ENV) \
		./configure $(LIBAAL_AUTOCONF)
	touch $@

# ----------------------------------------------------------------------------
# Compile
# ----------------------------------------------------------------------------

libaal_compile: $(STATEDIR)/libaal.compile

libaal_compile_deps = $(STATEDIR)/libaal.prepare

$(STATEDIR)/libaal.compile: $(libaal_compile_deps)
	@$(call targetinfo, $@)
	$(LIBAAL_PATH) $(MAKE) -C $(LIBAAL_DIR)
	touch $@

# ----------------------------------------------------------------------------
# Install
# ----------------------------------------------------------------------------

libaal_install: $(STATEDIR)/libaal.install

$(STATEDIR)/libaal.install: $(STATEDIR)/libaal.compile
	@$(call targetinfo, $@)
	rm -rf $(LIBAAL_IPKG_TMP)
	$(LIBAAL_PATH) $(MAKE) -C $(LIBAAL_DIR) DESTDIR=$(LIBAAL_IPKG_TMP) install
	cp -a $(LIBAAL_IPKG_TMP)/usr/include/*	$(CROSS_LIB_DIR)/include/
	cp -a $(LIBAAL_IPKG_TMP)/usr/lib/*	$(CROSS_LIB_DIR)/lib/
	cp -a $(LIBAAL_IPKG_TMP)/usr/share/*	$(PTXCONF_PREFIX)/share/
	perl -i -p -e "s,\/usr/lib,$(CROSS_LIB_DIR)/lib,g" $(CROSS_LIB_DIR)/lib/libaal.la
	rm -rf $(LIBAAL_IPKG_TMP)
	touch $@

# ----------------------------------------------------------------------------
# Target-Install
# ----------------------------------------------------------------------------

libaal_targetinstall: $(STATEDIR)/libaal.targetinstall

libaal_targetinstall_deps = $(STATEDIR)/libaal.compile

$(STATEDIR)/libaal.targetinstall: $(libaal_targetinstall_deps)
	@$(call targetinfo, $@)
	$(LIBAAL_PATH) $(MAKE) -C $(LIBAAL_DIR) DESTDIR=$(LIBAAL_IPKG_TMP) install
	rm -rf $(LIBAAL_IPKG_TMP)/usr/include
	rm -rf $(LIBAAL_IPKG_TMP)/usr/lib/*.*a
	rm -rf $(LIBAAL_IPKG_TMP)/usr/share
	$(CROSSSTRIP) $(LIBAAL_IPKG_TMP)/usr/lib/*.so*
	mkdir -p $(LIBAAL_IPKG_TMP)/CONTROL
	echo "Package: libaal" 								 >$(LIBAAL_IPKG_TMP)/CONTROL/control
	echo "Priority: optional" 							>>$(LIBAAL_IPKG_TMP)/CONTROL/control
	echo "Section: Kernel" 								>>$(LIBAAL_IPKG_TMP)/CONTROL/control
	echo "Maintainer: Alexander Chukov <sash@pdaXrom.org>" 				>>$(LIBAAL_IPKG_TMP)/CONTROL/control
	echo "Architecture: $(SHORT_TARGET)" 						>>$(LIBAAL_IPKG_TMP)/CONTROL/control
	echo "Version: $(LIBAAL_VERSION)-$(LIBAAL_VENDOR_VERSION)" 			>>$(LIBAAL_IPKG_TMP)/CONTROL/control
	echo "Depends: " 								>>$(LIBAAL_IPKG_TMP)/CONTROL/control
	echo "Description: This is a library, that provides application abstraction mechanism.">>$(LIBAAL_IPKG_TMP)/CONTROL/control
	cd $(FEEDDIR) && $(XMKIPKG) $(LIBAAL_IPKG_TMP)
	touch $@

# ----------------------------------------------------------------------------
# Image-Install
# ----------------------------------------------------------------------------

ifdef PTXCONF_LIBAAL_INSTALL
ROMPACKAGES += $(STATEDIR)/libaal.imageinstall
endif

libaal_imageinstall_deps = $(STATEDIR)/libaal.targetinstall \
	$(STATEDIR)/virtual-image.install

$(STATEDIR)/libaal.imageinstall: $(libaal_imageinstall_deps)
	@$(call targetinfo, $@)
	cd $(FEEDDIR) && $(XIPKG) install libaal
	touch $@

# ----------------------------------------------------------------------------
# Clean
# ----------------------------------------------------------------------------

libaal_clean:
	rm -rf $(STATEDIR)/libaal.*
	rm -rf $(LIBAAL_DIR)

# vim: syntax=make
