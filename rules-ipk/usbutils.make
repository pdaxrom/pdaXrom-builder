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
ifdef PTXCONF_USBUTILS
PACKAGES += usbutils
endif

#
# Paths and names
#
USBUTILS_VENDOR_VERSION	= 1
USBUTILS_VERSION	= 0.11
USBUTILS		= usbutils-$(USBUTILS_VERSION)
USBUTILS_SUFFIX		= tar.gz
USBUTILS_URL		= http://www.pdaXrom.org/src/$(USBUTILS).$(USBUTILS_SUFFIX)
USBUTILS_SOURCE		= $(SRCDIR)/$(USBUTILS).$(USBUTILS_SUFFIX)
USBUTILS_DIR		= $(BUILDDIR)/$(USBUTILS)
USBUTILS_IPKG_TMP	= $(USBUTILS_DIR)/ipkg_tmp

# ----------------------------------------------------------------------------
# Get
# ----------------------------------------------------------------------------

usbutils_get: $(STATEDIR)/usbutils.get

usbutils_get_deps = $(USBUTILS_SOURCE)

$(STATEDIR)/usbutils.get: $(usbutils_get_deps)
	@$(call targetinfo, $@)
	@$(call get_patches, $(USBUTILS))
	touch $@

$(USBUTILS_SOURCE):
	@$(call targetinfo, $@)
	@$(call get, $(USBUTILS_URL))

# ----------------------------------------------------------------------------
# Extract
# ----------------------------------------------------------------------------

usbutils_extract: $(STATEDIR)/usbutils.extract

usbutils_extract_deps = $(STATEDIR)/usbutils.get

$(STATEDIR)/usbutils.extract: $(usbutils_extract_deps)
	@$(call targetinfo, $@)
	@$(call clean, $(USBUTILS_DIR))
	@$(call extract, $(USBUTILS_SOURCE))
	@$(call patchin, $(USBUTILS))
	touch $@

# ----------------------------------------------------------------------------
# Prepare
# ----------------------------------------------------------------------------

usbutils_prepare: $(STATEDIR)/usbutils.prepare

#
# dependencies
#
usbutils_prepare_deps = \
	$(STATEDIR)/usbutils.extract \
	$(STATEDIR)/virtual-xchain.install

USBUTILS_PATH	=  PATH=$(CROSS_PATH)
USBUTILS_ENV 	=  $(CROSS_ENV)
#USBUTILS_ENV	+=
USBUTILS_ENV	+= PKG_CONFIG_PATH=$(CROSS_LIB_DIR)/lib/pkgconfig:$(CROSS_LIB_DIR)/lib/pkgconfig
#ifdef PTXCONF_XFREE430
#USBUTILS_ENV	+= LDFLAGS=-Wl,-rpath-link,$(CROSS_LIB_DIR)/lib
#endif

#
# autoconf
#
USBUTILS_AUTOCONF = \
	--build=$(GNU_HOST) \
	--host=$(PTXCONF_GNU_TARGET) \
	--prefix=/usr \
	--sysconfdir=/etc \
	--enable-shared \
	--disable-static

ifdef PTXCONF_XFREE430
USBUTILS_AUTOCONF += --x-includes=$(CROSS_LIB_DIR)/include
USBUTILS_AUTOCONF += --x-libraries=$(CROSS_LIB_DIR)/lib
endif

$(STATEDIR)/usbutils.prepare: $(usbutils_prepare_deps)
	@$(call targetinfo, $@)
	@$(call clean, $(USBUTILS_DIR)/config.cache)
	cd $(USBUTILS_DIR) && \
		$(USBUTILS_PATH) $(USBUTILS_ENV) \
		./configure $(USBUTILS_AUTOCONF)
	touch $@

# ----------------------------------------------------------------------------
# Compile
# ----------------------------------------------------------------------------

usbutils_compile: $(STATEDIR)/usbutils.compile

usbutils_compile_deps = $(STATEDIR)/usbutils.prepare

$(STATEDIR)/usbutils.compile: $(usbutils_compile_deps)
	@$(call targetinfo, $@)
	$(USBUTILS_PATH) $(MAKE) -C $(USBUTILS_DIR)
	touch $@

# ----------------------------------------------------------------------------
# Install
# ----------------------------------------------------------------------------

usbutils_install: $(STATEDIR)/usbutils.install

$(STATEDIR)/usbutils.install: $(STATEDIR)/usbutils.compile
	@$(call targetinfo, $@)
	asdasd
	touch $@

# ----------------------------------------------------------------------------
# Target-Install
# ----------------------------------------------------------------------------

usbutils_targetinstall: $(STATEDIR)/usbutils.targetinstall

usbutils_targetinstall_deps = $(STATEDIR)/usbutils.compile \
	$(STATEDIR)/hwdata.targetinstall

$(STATEDIR)/usbutils.targetinstall: $(usbutils_targetinstall_deps)
	@$(call targetinfo, $@)
	$(USBUTILS_PATH) $(MAKE) -C $(USBUTILS_DIR) DESTDIR=$(USBUTILS_IPKG_TMP) install
	rm -rf $(USBUTILS_IPKG_TMP)/usr/include
	rm -rf $(USBUTILS_IPKG_TMP)/usr/lib/*.*a
	rm -rf $(USBUTILS_IPKG_TMP)/usr/man
	rm -rf $(USBUTILS_IPKG_TMP)/usr/share/*.ids
	$(CROSSSTRIP) $(USBUTILS_IPKG_TMP)/usr/lib/*.so*
	$(CROSSSTRIP) $(USBUTILS_IPKG_TMP)/usr/sbin/*
	mkdir -p $(USBUTILS_IPKG_TMP)/CONTROL
	echo "Package: usbutils" 							 >$(USBUTILS_IPKG_TMP)/CONTROL/control
	echo "Priority: optional" 							>>$(USBUTILS_IPKG_TMP)/CONTROL/control
	echo "Section: Kernel" 								>>$(USBUTILS_IPKG_TMP)/CONTROL/control
	echo "Maintainer: Alexander Chukov <sash@pdaXrom.org>" 				>>$(USBUTILS_IPKG_TMP)/CONTROL/control
	echo "Architecture: $(SHORT_TARGET)" 						>>$(USBUTILS_IPKG_TMP)/CONTROL/control
	echo "Version: $(USBUTILS_VERSION)-$(USBUTILS_VENDOR_VERSION)" 			>>$(USBUTILS_IPKG_TMP)/CONTROL/control
	echo "Depends: hwdata" 								>>$(USBUTILS_IPKG_TMP)/CONTROL/control
	echo "Description: USB utilities"						>>$(USBUTILS_IPKG_TMP)/CONTROL/control
	cd $(FEEDDIR) && $(XMKIPKG) $(USBUTILS_IPKG_TMP)
	touch $@

# ----------------------------------------------------------------------------
# Image-Install
# ----------------------------------------------------------------------------

ifdef PTXCONF_USBUTILS_INSTALL
ROMPACKAGES += $(STATEDIR)/usbutils.imageinstall
endif

usbutils_imageinstall_deps = $(STATEDIR)/usbutils.targetinstall \
	$(STATEDIR)/virtual-image.install

$(STATEDIR)/usbutils.imageinstall: $(usbutils_imageinstall_deps)
	@$(call targetinfo, $@)
	cd $(FEEDDIR) && $(XIPKG) install usbutils
	touch $@

# ----------------------------------------------------------------------------
# Clean
# ----------------------------------------------------------------------------

usbutils_clean:
	rm -rf $(STATEDIR)/usbutils.*
	rm -rf $(USBUTILS_DIR)

# vim: syntax=make
