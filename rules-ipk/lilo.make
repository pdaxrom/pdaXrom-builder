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
ifdef PTXCONF_LILO
PACKAGES += lilo
endif

#
# Paths and names
#
LILO_VERSION		= 22.6
LILO			= lilo-$(LILO_VERSION)
LILO_SUFFIX		= tar.gz
LILO_URL		= http://home.san.rr.com/johninsd/pub/linux/lilo/$(LILO).$(LILO_SUFFIX)
LILO_SOURCE		= $(SRCDIR)/$(LILO).$(LILO_SUFFIX)
LILO_DIR		= $(BUILDDIR)/$(LILO)
LILO_IPKG_TMP		= $(LILO_DIR)/ipkg_tmp

# ----------------------------------------------------------------------------
# Get
# ----------------------------------------------------------------------------

lilo_get: $(STATEDIR)/lilo.get

lilo_get_deps = $(LILO_SOURCE)

$(STATEDIR)/lilo.get: $(lilo_get_deps)
	@$(call targetinfo, $@)
	@$(call get_patches, $(LILO))
	touch $@

$(LILO_SOURCE):
	@$(call targetinfo, $@)
	@$(call get, $(LILO_URL))

# ----------------------------------------------------------------------------
# Extract
# ----------------------------------------------------------------------------

lilo_extract: $(STATEDIR)/lilo.extract

lilo_extract_deps = $(STATEDIR)/lilo.get

$(STATEDIR)/lilo.extract: $(lilo_extract_deps)
	@$(call targetinfo, $@)
	@$(call clean, $(LILO_DIR))
	@$(call extract, $(LILO_SOURCE))
	@$(call patchin, $(LILO))
	touch $@

# ----------------------------------------------------------------------------
# Prepare
# ----------------------------------------------------------------------------

lilo_prepare: $(STATEDIR)/lilo.prepare

#
# dependencies
#
lilo_prepare_deps = \
	$(STATEDIR)/lilo.extract \
	$(STATEDIR)/xchain-Dev86src.install \
	$(STATEDIR)/virtual-xchain.install

LILO_PATH	=  PATH=$(CROSS_PATH)
LILO_ENV 	=  $(CROSS_ENV)
#LILO_ENV	+=
LILO_ENV	+= PKG_CONFIG_PATH=$(CROSS_LIB_DIR)/lib/pkgconfig:$(CROSS_LIB_DIR)/lib/pkgconfig
#ifdef PTXCONF_XFREE430
#LILO_ENV	+= LDFLAGS=-Wl,-rpath-link,$(CROSS_LIB_DIR)/lib
#endif

#
# autoconf
#
LILO_AUTOCONF = \
	--build=$(GNU_HOST) \
	--host=$(PTXCONF_GNU_TARGET) \
	--prefix=/usr

ifdef PTXCONF_XFREE430
LILO_AUTOCONF += --x-includes=$(CROSS_LIB_DIR)/include
LILO_AUTOCONF += --x-libraries=$(CROSS_LIB_DIR)/lib
endif

$(STATEDIR)/lilo.prepare: $(lilo_prepare_deps)
	@$(call targetinfo, $@)
	@$(call clean, $(LILO_DIR)/config.cache)
	#cd $(LILO_DIR) && \
	#	$(LILO_PATH) $(LILO_ENV) \
	#	./configure $(LILO_AUTOCONF)
	touch $@

# ----------------------------------------------------------------------------
# Compile
# ----------------------------------------------------------------------------

lilo_compile: $(STATEDIR)/lilo.compile

lilo_compile_deps = $(STATEDIR)/lilo.prepare

$(STATEDIR)/lilo.compile: $(lilo_compile_deps)
	@$(call targetinfo, $@)
	$(LILO_PATH) $(MAKE) -C $(LILO_DIR) $(CROSS_ENV_CC)
	touch $@

# ----------------------------------------------------------------------------
# Install
# ----------------------------------------------------------------------------

lilo_install: $(STATEDIR)/lilo.install

$(STATEDIR)/lilo.install: $(STATEDIR)/lilo.compile
	@$(call targetinfo, $@)
	touch $@

# ----------------------------------------------------------------------------
# Target-Install
# ----------------------------------------------------------------------------

lilo_targetinstall: $(STATEDIR)/lilo.targetinstall

lilo_targetinstall_deps = $(STATEDIR)/lilo.compile

$(STATEDIR)/lilo.targetinstall: $(lilo_targetinstall_deps)
	@$(call targetinfo, $@)
	mkdir -p $(LILO_IPKG_TMP)/etc
	mkdir -p $(LILO_IPKG_TMP)/sbin
	$(LILO_PATH) $(MAKE) -C $(LILO_DIR) ROOT=$(LILO_IPKG_TMP) install
	rm -rf $(LILO_IPKG_TMP)/usr/man
	cp $(TOPDIR)/config/pdaXrom-x86/lilo.conf $(LILO_IPKG_TMP)/etc
	$(CROSSSTRIP) $(LILO_IPKG_TMP)/sbin/lilo
	mkdir -p $(LILO_IPKG_TMP)/CONTROL
	echo "Package: lilo" 							>$(LILO_IPKG_TMP)/CONTROL/control
	echo "Priority: optional" 						>>$(LILO_IPKG_TMP)/CONTROL/control
	echo "Section: Utilities" 						>>$(LILO_IPKG_TMP)/CONTROL/control
	echo "Maintainer: Alexander Chukov <sash@pdaXrom.org>" 			>>$(LILO_IPKG_TMP)/CONTROL/control
	echo "Architecture: $(SHORT_TARGET)" 					>>$(LILO_IPKG_TMP)/CONTROL/control
	echo "Version: $(LILO_VERSION)" 					>>$(LILO_IPKG_TMP)/CONTROL/control
	echo "Depends: " 							>>$(LILO_IPKG_TMP)/CONTROL/control
	echo "Description: linux loader"					>>$(LILO_IPKG_TMP)/CONTROL/control
	cd $(FEEDDIR) && $(XMKIPKG) $(LILO_IPKG_TMP)
	touch $@

# ----------------------------------------------------------------------------
# Image-Install
# ----------------------------------------------------------------------------

ifdef PTXCONF_LILO_INSTALL
ROMPACKAGES += $(STATEDIR)/lilo.imageinstall
endif

lilo_imageinstall_deps = $(STATEDIR)/lilo.targetinstall \
	$(STATEDIR)/virtual-image.install

$(STATEDIR)/lilo.imageinstall: $(lilo_imageinstall_deps)
	@$(call targetinfo, $@)
	cd $(FEEDDIR) && $(XIPKG) install lilo
	touch $@

# ----------------------------------------------------------------------------
# Clean
# ----------------------------------------------------------------------------

lilo_clean:
	rm -rf $(STATEDIR)/lilo.*
	rm -rf $(LILO_DIR)

# vim: syntax=make
