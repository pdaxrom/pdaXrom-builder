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
ifdef PTXCONF_HDPARM
PACKAGES += hdparm
endif

#
# Paths and names
#
HDPARM_VENDOR_VERSION	= 1
HDPARM_VERSION		= 5.8
HDPARM			= hdparm-$(HDPARM_VERSION)
HDPARM_SUFFIX		= tar.gz
HDPARM_URL		= http://www.pdaXrom.org/src/$(HDPARM).$(HDPARM_SUFFIX)
HDPARM_SOURCE		= $(SRCDIR)/$(HDPARM).$(HDPARM_SUFFIX)
HDPARM_DIR		= $(BUILDDIR)/$(HDPARM)
HDPARM_IPKG_TMP		= $(HDPARM_DIR)/ipkg_tmp

# ----------------------------------------------------------------------------
# Get
# ----------------------------------------------------------------------------

hdparm_get: $(STATEDIR)/hdparm.get

hdparm_get_deps = $(HDPARM_SOURCE)

$(STATEDIR)/hdparm.get: $(hdparm_get_deps)
	@$(call targetinfo, $@)
	@$(call get_patches, $(HDPARM))
	touch $@

$(HDPARM_SOURCE):
	@$(call targetinfo, $@)
	@$(call get, $(HDPARM_URL))

# ----------------------------------------------------------------------------
# Extract
# ----------------------------------------------------------------------------

hdparm_extract: $(STATEDIR)/hdparm.extract

hdparm_extract_deps = $(STATEDIR)/hdparm.get

$(STATEDIR)/hdparm.extract: $(hdparm_extract_deps)
	@$(call targetinfo, $@)
	@$(call clean, $(HDPARM_DIR))
	@$(call extract, $(HDPARM_SOURCE))
	@$(call patchin, $(HDPARM))
	touch $@

# ----------------------------------------------------------------------------
# Prepare
# ----------------------------------------------------------------------------

hdparm_prepare: $(STATEDIR)/hdparm.prepare

#
# dependencies
#
hdparm_prepare_deps = \
	$(STATEDIR)/hdparm.extract \
	$(STATEDIR)/virtual-xchain.install

HDPARM_PATH	=  PATH=$(CROSS_PATH)
HDPARM_ENV 	=  $(CROSS_ENV)
#HDPARM_ENV	+=
HDPARM_ENV	+= PKG_CONFIG_PATH=$(CROSS_LIB_DIR)/lib/pkgconfig:$(CROSS_LIB_DIR)/lib/pkgconfig
#ifdef PTXCONF_XFREE430
#HDPARM_ENV	+= LDFLAGS=-Wl,-rpath-link,$(CROSS_LIB_DIR)/lib
#endif

#
# autoconf
#
HDPARM_AUTOCONF = \
	--build=$(GNU_HOST) \
	--host=$(PTXCONF_GNU_TARGET) \
	--prefix=/usr

ifdef PTXCONF_XFREE430
HDPARM_AUTOCONF += --x-includes=$(CROSS_LIB_DIR)/include
HDPARM_AUTOCONF += --x-libraries=$(CROSS_LIB_DIR)/lib
endif

$(STATEDIR)/hdparm.prepare: $(hdparm_prepare_deps)
	@$(call targetinfo, $@)
	@$(call clean, $(HDPARM_DIR)/config.cache)
	#cd $(HDPARM_DIR) && \
	#	$(HDPARM_PATH) $(HDPARM_ENV) \
	#	./configure $(HDPARM_AUTOCONF)
	touch $@

# ----------------------------------------------------------------------------
# Compile
# ----------------------------------------------------------------------------

hdparm_compile: $(STATEDIR)/hdparm.compile

hdparm_compile_deps = $(STATEDIR)/hdparm.prepare

$(STATEDIR)/hdparm.compile: $(hdparm_compile_deps)
	@$(call targetinfo, $@)
	$(HDPARM_PATH) $(MAKE) -C $(HDPARM_DIR) $(HDPARM_ENV)
	touch $@

# ----------------------------------------------------------------------------
# Install
# ----------------------------------------------------------------------------

hdparm_install: $(STATEDIR)/hdparm.install

$(STATEDIR)/hdparm.install: $(STATEDIR)/hdparm.compile
	@$(call targetinfo, $@)
	touch $@

# ----------------------------------------------------------------------------
# Target-Install
# ----------------------------------------------------------------------------

hdparm_targetinstall: $(STATEDIR)/hdparm.targetinstall

hdparm_targetinstall_deps = $(STATEDIR)/hdparm.compile

$(STATEDIR)/hdparm.targetinstall: $(hdparm_targetinstall_deps)
	@$(call targetinfo, $@)
	$(HDPARM_PATH) $(MAKE) -C $(HDPARM_DIR) DESTDIR=$(HDPARM_IPKG_TMP) install
	$(CROSSSTRIP) $(HDPARM_IPKG_TMP)/sbin/*
	mkdir -p $(HDPARM_IPKG_TMP)/CONTROL
	echo "Package: hdparm" 										 >$(HDPARM_IPKG_TMP)/CONTROL/control
	echo "Priority: optional" 									>>$(HDPARM_IPKG_TMP)/CONTROL/control
	echo "Section: Utilities" 									>>$(HDPARM_IPKG_TMP)/CONTROL/control
	echo "Maintainer: Alexander Chukov <sash@pdaXrom.org>" 						>>$(HDPARM_IPKG_TMP)/CONTROL/control
	echo "Architecture: $(SHORT_TARGET)" 								>>$(HDPARM_IPKG_TMP)/CONTROL/control
	echo "Version: $(HDPARM_VERSION)-$(HDPARM_VENDOR_VERSION)" 					>>$(HDPARM_IPKG_TMP)/CONTROL/control
	echo "Depends: " 										>>$(HDPARM_IPKG_TMP)/CONTROL/control
	echo "Description: get/set hard disk parameters for Linux IDE drives."				>>$(HDPARM_IPKG_TMP)/CONTROL/control
	cd $(FEEDDIR) && $(XMKIPKG) $(HDPARM_IPKG_TMP)
	touch $@

# ----------------------------------------------------------------------------
# Image-Install
# ----------------------------------------------------------------------------

ifdef PTXCONF_HDPARM_INSTALL
ROMPACKAGES += $(STATEDIR)/hdparm.imageinstall
endif

hdparm_imageinstall_deps = $(STATEDIR)/hdparm.targetinstall \
	$(STATEDIR)/virtual-image.install

$(STATEDIR)/hdparm.imageinstall: $(hdparm_imageinstall_deps)
	@$(call targetinfo, $@)
	cd $(FEEDDIR) && $(XIPKG) install hdparm
	touch $@

# ----------------------------------------------------------------------------
# Clean
# ----------------------------------------------------------------------------

hdparm_clean:
	rm -rf $(STATEDIR)/hdparm.*
	rm -rf $(HDPARM_DIR)

# vim: syntax=make
