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
ifdef PTXCONF_NXDESKTOP
PACKAGES += nxdesktop
endif

#
# Paths and names
#
NXDESKTOP_VERSION	= 1.3.2-21
NXDESKTOP		= nxdesktop-$(NXDESKTOP_VERSION)
NXDESKTOP_SUFFIX	= tar.gz
NXDESKTOP_URL		= http://www.nomachine.com/source/$(NXDESKTOP).$(NXDESKTOP_SUFFIX)
NXDESKTOP_SOURCE	= $(SRCDIR)/$(NXDESKTOP).$(NXDESKTOP_SUFFIX)
NXDESKTOP_DIR		= $(BUILDDIR)/nxdesktop
NXDESKTOP_IPKG_TMP	= $(NXDESKTOP_DIR)/ipkg_tmp

# ----------------------------------------------------------------------------
# Get
# ----------------------------------------------------------------------------

nxdesktop_get: $(STATEDIR)/nxdesktop.get

nxdesktop_get_deps = $(NXDESKTOP_SOURCE)

$(STATEDIR)/nxdesktop.get: $(nxdesktop_get_deps)
	@$(call targetinfo, $@)
	@$(call get_patches, $(NXDESKTOP))
	touch $@

$(NXDESKTOP_SOURCE):
	@$(call targetinfo, $@)
	@$(call get, $(NXDESKTOP_URL))

# ----------------------------------------------------------------------------
# Extract
# ----------------------------------------------------------------------------

nxdesktop_extract: $(STATEDIR)/nxdesktop.extract

nxdesktop_extract_deps = $(STATEDIR)/nxdesktop.get

$(STATEDIR)/nxdesktop.extract: $(nxdesktop_extract_deps)
	@$(call targetinfo, $@)
	@$(call clean, $(NXDESKTOP_DIR))
	@$(call extract, $(NXDESKTOP_SOURCE))
	@$(call patchin, $(NXDESKTOP), $(NXDESKTOP_DIR))
	touch $@

# ----------------------------------------------------------------------------
# Prepare
# ----------------------------------------------------------------------------

nxdesktop_prepare: $(STATEDIR)/nxdesktop.prepare

#
# dependencies
#
nxdesktop_prepare_deps = \
	$(STATEDIR)/nxdesktop.extract \
	$(STATEDIR)/openssl.install \
	$(STATEDIR)/nx-X11.compile \
	$(STATEDIR)/virtual-xchain.install

NXDESKTOP_PATH	=  PATH=$(CROSS_PATH)
NXDESKTOP_ENV 	=  $(CROSS_ENV)
NXDESKTOP_ENV	+= CFLAGS="$(TARGET_OPT_CFLAGS)"
NXDESKTOP_ENV	+= PKG_CONFIG_PATH=$(CROSS_LIB_DIR)/lib/pkgconfig:$(CROSS_LIB_DIR)/lib/pkgconfig
#ifdef PTXCONF_XFREE430
#NXDESKTOP_ENV	+= LDFLAGS=-Wl,-rpath-link,$(CROSS_LIB_DIR)/lib
#endif

#
# autoconf
#
NXDESKTOP_AUTOCONF = \
	--prefix=/usr/NX \
	--with-sysinc=$(CROSS_LIB_DIR)/include \
	--with-openssl=$(CROSS_LIB_DIR) \
	--with-x=$(NX-X11)/exports \
	--with-sound=oss

$(STATEDIR)/nxdesktop.prepare: $(nxdesktop_prepare_deps)
	@$(call targetinfo, $@)
	@$(call clean, $(NXDESKTOP_DIR)/config.cache)
	cd $(NXDESKTOP_DIR) && \
		$(NXDESKTOP_PATH) $(NXDESKTOP_ENV) \
		./configure $(NXDESKTOP_AUTOCONF)
	touch $@

# ----------------------------------------------------------------------------
# Compile
# ----------------------------------------------------------------------------

nxdesktop_compile: $(STATEDIR)/nxdesktop.compile

nxdesktop_compile_deps = $(STATEDIR)/nxdesktop.prepare

$(STATEDIR)/nxdesktop.compile: $(nxdesktop_compile_deps)
	@$(call targetinfo, $@)
	$(NXDESKTOP_PATH) $(MAKE) -C $(NXDESKTOP_DIR)
	touch $@

# ----------------------------------------------------------------------------
# Install
# ----------------------------------------------------------------------------

nxdesktop_install: $(STATEDIR)/nxdesktop.install

$(STATEDIR)/nxdesktop.install: $(STATEDIR)/nxdesktop.compile
	@$(call targetinfo, $@)
	touch $@

# ----------------------------------------------------------------------------
# Target-Install
# ----------------------------------------------------------------------------

nxdesktop_targetinstall: $(STATEDIR)/nxdesktop.targetinstall

nxdesktop_targetinstall_deps = $(STATEDIR)/nxdesktop.compile \
	$(STATEDIR)/openssl.targetinstall

$(STATEDIR)/nxdesktop.targetinstall: $(nxdesktop_targetinstall_deps)
	@$(call targetinfo, $@)
	$(NXDESKTOP_PATH) $(MAKE) -C $(NXDESKTOP_DIR) DESTDIR=$(NXDESKTOP_IPKG_TMP) install
	mkdir -p $(NXDESKTOP_IPKG_TMP)/CONTROL
	echo "Package: nxdesktop" 			>$(NXDESKTOP_IPKG_TMP)/CONTROL/control
	echo "Priority: optional" 			>>$(NXDESKTOP_IPKG_TMP)/CONTROL/control
	echo "Section: pdaXrom" 			>>$(NXDESKTOP_IPKG_TMP)/CONTROL/control
	echo "Maintainer: Alexander Chukov <sash@pdaXrom.org>" 			>>$(NXDESKTOP_IPKG_TMP)/CONTROL/control
	echo "Architecture: $(SHORT_TARGET)" 		>>$(NXDESKTOP_IPKG_TMP)/CONTROL/control
	echo "Version: $(NXDESKTOP_VERSION)" 		>>$(NXDESKTOP_IPKG_TMP)/CONTROL/control
	echo "Depends: " 				>>$(NXDESKTOP_IPKG_TMP)/CONTROL/control
	echo "Description: generated with pdaXrom builder">>$(NXDESKTOP_IPKG_TMP)/CONTROL/control
	asdasd
	cd $(FEEDDIR) && $(XMKIPKG) $(NXDESKTOP_IPKG_TMP)
	touch $@

# ----------------------------------------------------------------------------
# Image-Install
# ----------------------------------------------------------------------------

ifdef PTXCONF_NXDESKTOP_INSTALL
ROMPACKAGES += $(STATEDIR)/nxdesktop.imageinstall
endif

nxdesktop_imageinstall_deps = $(STATEDIR)/nxdesktop.targetinstall \
	$(STATEDIR)/virtual-image.install

$(STATEDIR)/nxdesktop.imageinstall: $(nxdesktop_imageinstall_deps)
	@$(call targetinfo, $@)
	cd $(FEEDDIR) && $(XIPKG) install nxdesktop
	touch $@

# ----------------------------------------------------------------------------
# Clean
# ----------------------------------------------------------------------------

nxdesktop_clean:
	rm -rf $(STATEDIR)/nxdesktop.*
	rm -rf $(NXDESKTOP_DIR)

# vim: syntax=make
