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
ifdef PTXCONF_XCHAT
PACKAGES += xchat
endif

#
# Paths and names
#
XCHAT_VERSION		= 2.0.10
XCHAT			= xchat-$(XCHAT_VERSION)
XCHAT_SUFFIX		= tar.bz2
XCHAT_URL		= http://www.xchat.org/files/source/2.0/$(XCHAT).$(XCHAT_SUFFIX)
XCHAT_SOURCE		= $(SRCDIR)/$(XCHAT).$(XCHAT_SUFFIX)
XCHAT_DIR		= $(BUILDDIR)/$(XCHAT)
XCHAT_IPKG_TMP		= $(XCHAT_DIR)/ipkg_tmp

# ----------------------------------------------------------------------------
# Get
# ----------------------------------------------------------------------------

xchat_get: $(STATEDIR)/xchat.get

xchat_get_deps = $(XCHAT_SOURCE)

$(STATEDIR)/xchat.get: $(xchat_get_deps)
	@$(call targetinfo, $@)
	@$(call get_patches, $(XCHAT))
	touch $@

$(XCHAT_SOURCE):
	@$(call targetinfo, $@)
	@$(call get, $(XCHAT_URL))

# ----------------------------------------------------------------------------
# Extract
# ----------------------------------------------------------------------------

xchat_extract: $(STATEDIR)/xchat.extract

xchat_extract_deps = $(STATEDIR)/xchat.get

$(STATEDIR)/xchat.extract: $(xchat_extract_deps)
	@$(call targetinfo, $@)
	@$(call clean, $(XCHAT_DIR))
	@$(call extract, $(XCHAT_SOURCE))
	@$(call patchin, $(XCHAT))
	touch $@

# ----------------------------------------------------------------------------
# Prepare
# ----------------------------------------------------------------------------

xchat_prepare: $(STATEDIR)/xchat.prepare

#
# dependencies
#
xchat_prepare_deps = \
	$(STATEDIR)/xchat.extract \
	$(STATEDIR)/openssl.install \
	$(STATEDIR)/gtk22.install \
	$(STATEDIR)/virtual-xchain.install

XCHAT_PATH	=  PATH=$(CROSS_PATH)
XCHAT_ENV 	=  $(CROSS_ENV)
XCHAT_ENV	+= CFLAGS="-O2 -fomit-frame-pointer"
XCHAT_ENV	+= PKG_CONFIG_PATH=$(CROSS_LIB_DIR)/lib/pkgconfig:$(CROSS_LIB_DIR)/lib/pkgconfig
#ifdef PTXCONF_XFREE430
#XCHAT_ENV	+= LDFLAGS=-Wl,-rpath-link,$(CROSS_LIB_DIR)/lib
#endif

#
# autoconf
#
XCHAT_AUTOCONF = \
	--build=$(GNU_HOST) \
	--host=$(PTXCONF_GNU_TARGET) \
	--prefix=/usr \
	--disable-python \
	--disable-perl \
	--disable-tcl

ifdef PTXCONF_XFREE430
XCHAT_AUTOCONF += --x-includes=$(CROSS_LIB_DIR)/include
XCHAT_AUTOCONF += --x-libraries=$(CROSS_LIB_DIR)/lib
endif

$(STATEDIR)/xchat.prepare: $(xchat_prepare_deps)
	@$(call targetinfo, $@)
	@$(call clean, $(XCHAT_DIR)/config.cache)
	cd $(XCHAT_DIR) && \
		$(XCHAT_PATH) $(XCHAT_ENV) \
		./configure $(XCHAT_AUTOCONF)
	touch $@

# ----------------------------------------------------------------------------
# Compile
# ----------------------------------------------------------------------------

xchat_compile: $(STATEDIR)/xchat.compile

xchat_compile_deps = $(STATEDIR)/xchat.prepare

$(STATEDIR)/xchat.compile: $(xchat_compile_deps)
	@$(call targetinfo, $@)
	$(XCHAT_PATH) $(MAKE) -C $(XCHAT_DIR)
	touch $@

# ----------------------------------------------------------------------------
# Install
# ----------------------------------------------------------------------------

xchat_install: $(STATEDIR)/xchat.install

$(STATEDIR)/xchat.install: $(STATEDIR)/xchat.compile
	@$(call targetinfo, $@)
	$(XCHAT_PATH) $(MAKE) -C $(XCHAT_DIR) install
	touch $@

# ----------------------------------------------------------------------------
# Target-Install
# ----------------------------------------------------------------------------

xchat_targetinstall: $(STATEDIR)/xchat.targetinstall

xchat_targetinstall_deps = $(STATEDIR)/xchat.compile \
	$(STATEDIR)/openssl.targetinstall

$(STATEDIR)/xchat.targetinstall: $(xchat_targetinstall_deps)
	@$(call targetinfo, $@)
	$(XCHAT_PATH) $(MAKE) -C $(XCHAT_DIR) DESTDIR=$(XCHAT_IPKG_TMP) install
	$(CROSSSTRIP) $(XCHAT_IPKG_TMP)/usr/bin/*
	rm -rf $(XCHAT_IPKG_TMP)/usr/share/locale
	mkdir -p $(XCHAT_IPKG_TMP)/CONTROL
	echo "Package: xchat" 						>$(XCHAT_IPKG_TMP)/CONTROL/control
	echo "Priority: optional" 					>>$(XCHAT_IPKG_TMP)/CONTROL/control
	echo "Section: X11"			 			>>$(XCHAT_IPKG_TMP)/CONTROL/control
	echo "Maintainer: Alexander Chukov <sash@pdaXrom.org>" 		>>$(XCHAT_IPKG_TMP)/CONTROL/control
	echo "Architecture: $(SHORT_TARGET)" 				>>$(XCHAT_IPKG_TMP)/CONTROL/control
	echo "Version: $(XCHAT_VERSION)" 				>>$(XCHAT_IPKG_TMP)/CONTROL/control
	echo "Depends: gtk2, openssl" 					>>$(XCHAT_IPKG_TMP)/CONTROL/control
	echo "Description: X-Chat is an IRC client for UNIX operating systems.">>$(XCHAT_IPKG_TMP)/CONTROL/control
	cd $(FEEDDIR) && $(XMKIPKG) $(XCHAT_IPKG_TMP)
	touch $@

# ----------------------------------------------------------------------------
# Image-Install
# ----------------------------------------------------------------------------

ifdef PTXCONF_XCHAT_INSTALL
ROMPACKAGES += $(STATEDIR)/xchat.imageinstall
endif

xchat_imageinstall_deps = $(STATEDIR)/xchat.targetinstall \
	$(STATEDIR)/virtual-image.install

$(STATEDIR)/xchat.imageinstall: $(xchat_imageinstall_deps)
	@$(call targetinfo, $@)
	cd $(FEEDDIR) && $(XIPKG) install xchat
	touch $@

# ----------------------------------------------------------------------------
# Clean
# ----------------------------------------------------------------------------

xchat_clean:
	rm -rf $(STATEDIR)/xchat.*
	rm -rf $(XCHAT_DIR)

# vim: syntax=make
