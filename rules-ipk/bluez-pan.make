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
ifdef PTXCONF_BLUEZ-PAN
PACKAGES += bluez-pan
endif

#
# Paths and names
#
BLUEZ-PAN_VERSION	= 1.1
BLUEZ-PAN		= bluez-pan-$(BLUEZ-PAN_VERSION)
BLUEZ-PAN_SUFFIX	= tar.gz
BLUEZ-PAN_URL		= http://bluez.sourceforge.net/download/$(BLUEZ-PAN).$(BLUEZ-PAN_SUFFIX)
BLUEZ-PAN_SOURCE	= $(SRCDIR)/$(BLUEZ-PAN).$(BLUEZ-PAN_SUFFIX)
BLUEZ-PAN_DIR		= $(BUILDDIR)/$(BLUEZ-PAN)
BLUEZ-PAN_IPKG_TMP	= $(BLUEZ-PAN_DIR)/ipkg_tmp

# ----------------------------------------------------------------------------
# Get
# ----------------------------------------------------------------------------

bluez-pan_get: $(STATEDIR)/bluez-pan.get

bluez-pan_get_deps = $(BLUEZ-PAN_SOURCE)

$(STATEDIR)/bluez-pan.get: $(bluez-pan_get_deps)
	@$(call targetinfo, $@)
	@$(call get_patches, $(BLUEZ-PAN))
	touch $@

$(BLUEZ-PAN_SOURCE):
	@$(call targetinfo, $@)
	@$(call get, $(BLUEZ-PAN_URL))

# ----------------------------------------------------------------------------
# Extract
# ----------------------------------------------------------------------------

bluez-pan_extract: $(STATEDIR)/bluez-pan.extract

bluez-pan_extract_deps = $(STATEDIR)/bluez-pan.get

$(STATEDIR)/bluez-pan.extract: $(bluez-pan_extract_deps)
	@$(call targetinfo, $@)
	@$(call clean, $(BLUEZ-PAN_DIR))
	@$(call extract, $(BLUEZ-PAN_SOURCE))
	@$(call patchin, $(BLUEZ-PAN))
	touch $@

# ----------------------------------------------------------------------------
# Prepare
# ----------------------------------------------------------------------------

bluez-pan_prepare: $(STATEDIR)/bluez-pan.prepare

#
# dependencies
#
bluez-pan_prepare_deps = \
	$(STATEDIR)/bluez-pan.extract \
	$(STATEDIR)/bluez-libs.install \
	$(STATEDIR)/bluez-sdp.install \
	$(STATEDIR)/virtual-xchain.install

BLUEZ-PAN_PATH	=  PATH=$(CROSS_PATH)
BLUEZ-PAN_ENV 	=  $(CROSS_ENV)
#BLUEZ-PAN_ENV	+=
BLUEZ-PAN_ENV	+= PKG_CONFIG_PATH=$(CROSS_LIB_DIR)/lib/pkgconfig:$(CROSS_LIB_DIR)/lib/pkgconfig
#ifdef PTXCONF_XFREE430
#BLUEZ-PAN_ENV	+= LDFLAGS=-Wl,-rpath-link,$(CROSS_LIB_DIR)/lib
#endif

#
# autoconf
#
BLUEZ-PAN_AUTOCONF = \
	--build=$(GNU_HOST) \
	--host=$(PTXCONF_GNU_TARGET) \
	--prefix=/usr \
	--disable-static \
	--enable-shared \
	--sysconfdir=/etc \
	--enable-pcmcia \
	--with-bluez-includes=$(CROSS_LIB_DIR)/include \
	--with-bluez-libs=$(CROSS_LIB_DIR)/lib \
	--with-sdp-includes=$(CROSS_LIB_DIR)/include \
	--with-sdp-libs=$(CROSS_LIB_DIR)/lib \
	--disable-debug

ifdef PTXCONF_XFREE430
BLUEZ-PAN_AUTOCONF += --x-includes=$(CROSS_LIB_DIR)/include
BLUEZ-PAN_AUTOCONF += --x-libraries=$(CROSS_LIB_DIR)/lib
endif

$(STATEDIR)/bluez-pan.prepare: $(bluez-pan_prepare_deps)
	@$(call targetinfo, $@)
	@$(call clean, $(BLUEZ-PAN_DIR)/config.cache)
	cd $(BLUEZ-PAN_DIR) && \
		$(BLUEZ-PAN_PATH) $(BLUEZ-PAN_ENV) \
		./configure $(BLUEZ-PAN_AUTOCONF)
	touch $@

# ----------------------------------------------------------------------------
# Compile
# ----------------------------------------------------------------------------

bluez-pan_compile: $(STATEDIR)/bluez-pan.compile

bluez-pan_compile_deps = $(STATEDIR)/bluez-pan.prepare

$(STATEDIR)/bluez-pan.compile: $(bluez-pan_compile_deps)
	@$(call targetinfo, $@)
	$(BLUEZ-PAN_PATH) $(MAKE) -C $(BLUEZ-PAN_DIR) CC=$(PTXCONF_GNU_TARGET)-gcc
	touch $@

# ----------------------------------------------------------------------------
# Install
# ----------------------------------------------------------------------------

bluez-pan_install: $(STATEDIR)/bluez-pan.install

$(STATEDIR)/bluez-pan.install: $(STATEDIR)/bluez-pan.compile
	@$(call targetinfo, $@)
	$(BLUEZ-PAN_PATH) $(MAKE) -C $(BLUEZ-PAN_DIR) DESTDIR=$(BLUEZ-PAN_IPKG_TMP) CC=$(PTXCONF_GNU_TARGET)-gcc install
	cp -a  $(BLUEZ-PAN_IPKG_TMP)/usr/include/* $(CROSS_LIB_DIR)/include
	rm -rf $(BLUEZ-PAN_IPKG_TMP)
	touch $@

# ----------------------------------------------------------------------------
# Target-Install
# ----------------------------------------------------------------------------

bluez-pan_targetinstall: $(STATEDIR)/bluez-pan.targetinstall

bluez-pan_targetinstall_deps = $(STATEDIR)/bluez-pan.compile \
	$(STATEDIR)/bluez-libs.targetinstall \
	$(STATEDIR)/bluez-sdp.targetinstall

$(STATEDIR)/bluez-pan.targetinstall: $(bluez-pan_targetinstall_deps)
	@$(call targetinfo, $@)
	$(BLUEZ-PAN_PATH) $(MAKE) -C $(BLUEZ-PAN_DIR) DESTDIR=$(BLUEZ-PAN_IPKG_TMP) CC=$(PTXCONF_GNU_TARGET)-gcc install
	mkdir -p $(BLUEZ-PAN_IPKG_TMP)/CONTROL
	echo "Package: bluez-pan" 			>$(BLUEZ-PAN_IPKG_TMP)/CONTROL/control
	echo "Priority: optional" 			>>$(BLUEZ-PAN_IPKG_TMP)/CONTROL/control
	echo "Section: pdaXrom" 			>>$(BLUEZ-PAN_IPKG_TMP)/CONTROL/control
	echo "Maintainer: Alexander Chukov <sash@pdaXrom.org>" >>$(BLUEZ-PAN_IPKG_TMP)/CONTROL/control
	echo "Architecture: $(SHORT_TARGET)" 		>>$(BLUEZ-PAN_IPKG_TMP)/CONTROL/control
	echo "Version: $(BLUEZ-PAN_VERSION)" 		>>$(BLUEZ-PAN_IPKG_TMP)/CONTROL/control
	echo "Depends: bluez-libs, bluez-utils, bluez-sdp" >>$(BLUEZ-PAN_IPKG_TMP)/CONTROL/control
	echo "Description: generated with pdaXrom builder">>$(BLUEZ-PAN_IPKG_TMP)/CONTROL/control
	rm -rf $(BLUEZ-PAN_IPKG_TMP)/usr/include
	$(CROSSSTRIP) $(BLUEZ-PAN_IPKG_TMP)/usr/bin/dund
	$(CROSSSTRIP) $(BLUEZ-PAN_IPKG_TMP)/usr/bin/pand
	cd $(FEEDDIR) && $(XMKIPKG) $(BLUEZ-PAN_IPKG_TMP)
	touch $@

# ----------------------------------------------------------------------------
# Image-Install
# ----------------------------------------------------------------------------

ifdef PTXCONF_BLUEZ-PAN_INSTALL
ROMPACKAGES += $(STATEDIR)/bluez-pan.imageinstall
endif

bluez-pan_imageinstall_deps = $(STATEDIR)/bluez-pan.targetinstall \
	$(STATEDIR)/virtual-image.install

$(STATEDIR)/bluez-pan.imageinstall: $(bluez-pan_imageinstall_deps)
	@$(call targetinfo, $@)
	cd $(FEEDDIR) && $(XIPKG) install bluez-pan
	touch $@

# ----------------------------------------------------------------------------
# Clean
# ----------------------------------------------------------------------------

bluez-pan_clean:
	rm -rf $(STATEDIR)/bluez-pan.*
	rm -rf $(BLUEZ-PAN_DIR)

# vim: syntax=make
