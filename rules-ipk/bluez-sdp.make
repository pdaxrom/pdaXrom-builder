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
ifdef PTXCONF_BLUEZ-SDP
PACKAGES += bluez-sdp
endif

#
# Paths and names
#
BLUEZ-SDP_VERSION	= 1.5
BLUEZ-SDP		= bluez-sdp-$(BLUEZ-SDP_VERSION)
BLUEZ-SDP_SUFFIX	= tar.gz
BLUEZ-SDP_URL		= http://bluez.sourceforge.net/download/$(BLUEZ-SDP).$(BLUEZ-SDP_SUFFIX)
BLUEZ-SDP_SOURCE	= $(SRCDIR)/$(BLUEZ-SDP).$(BLUEZ-SDP_SUFFIX)
BLUEZ-SDP_DIR		= $(BUILDDIR)/$(BLUEZ-SDP)
BLUEZ-SDP_IPKG_TMP	= $(BLUEZ-SDP_DIR)/ipkg_tmp

# ----------------------------------------------------------------------------
# Get
# ----------------------------------------------------------------------------

bluez-sdp_get: $(STATEDIR)/bluez-sdp.get

bluez-sdp_get_deps = $(BLUEZ-SDP_SOURCE)

$(STATEDIR)/bluez-sdp.get: $(bluez-sdp_get_deps)
	@$(call targetinfo, $@)
	@$(call get_patches, $(BLUEZ-SDP))
	touch $@

$(BLUEZ-SDP_SOURCE):
	@$(call targetinfo, $@)
	@$(call get, $(BLUEZ-SDP_URL))

# ----------------------------------------------------------------------------
# Extract
# ----------------------------------------------------------------------------

bluez-sdp_extract: $(STATEDIR)/bluez-sdp.extract

bluez-sdp_extract_deps = $(STATEDIR)/bluez-sdp.get

$(STATEDIR)/bluez-sdp.extract: $(bluez-sdp_extract_deps)
	@$(call targetinfo, $@)
	@$(call clean, $(BLUEZ-SDP_DIR))
	@$(call extract, $(BLUEZ-SDP_SOURCE))
	@$(call patchin, $(BLUEZ-SDP))
	touch $@

# ----------------------------------------------------------------------------
# Prepare
# ----------------------------------------------------------------------------

bluez-sdp_prepare: $(STATEDIR)/bluez-sdp.prepare

#
# dependencies
#
bluez-sdp_prepare_deps = \
	$(STATEDIR)/bluez-sdp.extract \
	$(STATEDIR)/bluez-libs.install \
	$(STATEDIR)/virtual-xchain.install

BLUEZ-SDP_PATH	=  PATH=$(CROSS_PATH)
BLUEZ-SDP_ENV 	=  $(CROSS_ENV)
#BLUEZ-SDP_ENV	+=
BLUEZ-SDP_ENV	+= PKG_CONFIG_PATH=$(CROSS_LIB_DIR)/lib/pkgconfig:$(CROSS_LIB_DIR)/lib/pkgconfig
#ifdef PTXCONF_XFREE430
#BLUEZ-SDP_ENV	+= LDFLAGS=-Wl,-rpath-link,$(CROSS_LIB_DIR)/lib
#endif

#
# autoconf
#
BLUEZ-SDP_AUTOCONF = \
	--build=$(GNU_HOST) \
	--host=$(PTXCONF_GNU_TARGET) \
	--prefix=/usr \
	--disable-static \
	--enable-shared \
	--sysconfdir=/etc \
	--enable-pcmcia \
	--with-bluez-includes=$(CROSS_LIB_DIR)/include \
	--with-bluez-libs=$(CROSS_LIB_DIR)/lib \
	--disable-debug

ifdef PTXCONF_XFREE430
BLUEZ-SDP_AUTOCONF += --x-includes=$(CROSS_LIB_DIR)/include
BLUEZ-SDP_AUTOCONF += --x-libraries=$(CROSS_LIB_DIR)/lib
endif

$(STATEDIR)/bluez-sdp.prepare: $(bluez-sdp_prepare_deps)
	@$(call targetinfo, $@)
	@$(call clean, $(BLUEZ-SDP_DIR)/config.cache)
	cd $(BLUEZ-SDP_DIR) && \
		$(BLUEZ-SDP_PATH) $(BLUEZ-SDP_ENV) \
		./configure $(BLUEZ-SDP_AUTOCONF)
	touch $@

# ----------------------------------------------------------------------------
# Compile
# ----------------------------------------------------------------------------

bluez-sdp_compile: $(STATEDIR)/bluez-sdp.compile

bluez-sdp_compile_deps = $(STATEDIR)/bluez-sdp.prepare

$(STATEDIR)/bluez-sdp.compile: $(bluez-sdp_compile_deps)
	@$(call targetinfo, $@)
	$(BLUEZ-SDP_PATH) $(MAKE) -C $(BLUEZ-SDP_DIR) CC=$(PTXCONF_GNU_TARGET)-gcc
	touch $@

# ----------------------------------------------------------------------------
# Install
# ----------------------------------------------------------------------------

bluez-sdp_install: $(STATEDIR)/bluez-sdp.install

$(STATEDIR)/bluez-sdp.install: $(STATEDIR)/bluez-sdp.compile
	@$(call targetinfo, $@)
	$(BLUEZ-SDP_PATH) $(MAKE) -C $(BLUEZ-SDP_DIR) DESTDIR=$(BLUEZ-SDP_IPKG_TMP) CC=$(PTXCONF_GNU_TARGET)-gcc install
	cp -a  $(BLUEZ-SDP_IPKG_TMP)/usr/include/* $(CROSS_LIB_DIR)/include
	cp -a  $(BLUEZ-SDP_IPKG_TMP)/usr/lib/*     $(CROSS_LIB_DIR)/lib
	rm -rf $(BLUEZ-SDP_IPKG_TMP)
	perl -p -i -e "s/\/usr\/lib/`echo $(PTXCONF_PREFIX)/$(PTXCONF_GNU_TARGET)/lib | sed -e '/\//s//\\\\\//g'`/g" $(PTXCONF_PREFIX)/$(PTXCONF_GNU_TARGET)/lib/libsdp.la
	touch $@

# ----------------------------------------------------------------------------
# Target-Install
# ----------------------------------------------------------------------------

bluez-sdp_targetinstall: $(STATEDIR)/bluez-sdp.targetinstall

bluez-sdp_targetinstall_deps = $(STATEDIR)/bluez-sdp.compile \
	$(STATEDIR)/bluez-libs.targetinstall

$(STATEDIR)/bluez-sdp.targetinstall: $(bluez-sdp_targetinstall_deps)
	@$(call targetinfo, $@)
	$(BLUEZ-SDP_PATH) $(MAKE) -C $(BLUEZ-SDP_DIR) DESTDIR=$(BLUEZ-SDP_IPKG_TMP) CC=$(PTXCONF_GNU_TARGET)-gcc install
	mkdir -p $(BLUEZ-SDP_IPKG_TMP)/CONTROL
	echo "Package: bluez-sdp" 			>$(BLUEZ-SDP_IPKG_TMP)/CONTROL/control
	echo "Priority: optional" 			>>$(BLUEZ-SDP_IPKG_TMP)/CONTROL/control
	echo "Section: pdaXrom" 			>>$(BLUEZ-SDP_IPKG_TMP)/CONTROL/control
	echo "Maintainer: Alexander Chukov <sash@pdaXrom.org>" >>$(BLUEZ-SDP_IPKG_TMP)/CONTROL/control
	echo "Architecture: $(SHORT_TARGET)" 		>>$(BLUEZ-SDP_IPKG_TMP)/CONTROL/control
	echo "Version: $(BLUEZ-SDP_VERSION)" 		>>$(BLUEZ-SDP_IPKG_TMP)/CONTROL/control
	echo "Depends: bluez-libs, bluez-utils"		>>$(BLUEZ-SDP_IPKG_TMP)/CONTROL/control
	echo "Description: generated with pdaXrom builder">>$(BLUEZ-SDP_IPKG_TMP)/CONTROL/control
	rm -rf $(BLUEZ-SDP_IPKG_TMP)/usr/include
	rm -rf $(BLUEZ-SDP_IPKG_TMP)/usr/lib/*.la
	rm -rf $(BLUEZ-SDP_IPKG_TMP)/usr/lib/*.a
	$(CROSSSTRIP) $(BLUEZ-SDP_IPKG_TMP)/usr/bin/sdptool
	$(CROSSSTRIP) $(BLUEZ-SDP_IPKG_TMP)/usr/lib/libsdp.so.2.0.1
	$(CROSSSTRIP) $(BLUEZ-SDP_IPKG_TMP)/usr/sbin/sdpd
	cd $(FEEDDIR) && $(XMKIPKG) $(BLUEZ-SDP_IPKG_TMP)
	touch $@

# ----------------------------------------------------------------------------
# Image-Install
# ----------------------------------------------------------------------------

ifdef PTXCONF_BLUEZ-SDP_INSTALL
ROMPACKAGES += $(STATEDIR)/bluez-sdp.imageinstall
endif

bluez-sdp_imageinstall_deps = $(STATEDIR)/bluez-sdp.targetinstall \
	$(STATEDIR)/virtual-image.install

$(STATEDIR)/bluez-sdp.imageinstall: $(bluez-sdp_imageinstall_deps)
	@$(call targetinfo, $@)
	cd $(FEEDDIR) && $(XIPKG) install bluez-sdp
	touch $@

# ----------------------------------------------------------------------------
# Clean
# ----------------------------------------------------------------------------

bluez-sdp_clean:
	rm -rf $(STATEDIR)/bluez-sdp.*
	rm -rf $(BLUEZ-SDP_DIR)

# vim: syntax=make
