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
ifdef PTXCONF_HWDATA
PACKAGES += hwdata
endif

#
# Paths and names
#
HWDATA_VENDOR_VERSION	= 1
HWDATA_VERSION		= 0.148
HWDATA			= hwdata-$(HWDATA_VERSION)
HWDATA_SUFFIX		= tar.gz
HWDATA_URL		= http://www.pdaXrom.org/src/$(HWDATA).$(HWDATA_SUFFIX)
HWDATA_SOURCE		= $(SRCDIR)/$(HWDATA).$(HWDATA_SUFFIX)
HWDATA_DIR		= $(BUILDDIR)/$(HWDATA)
HWDATA_IPKG_TMP		= $(HWDATA_DIR)/ipkg_tmp

# ----------------------------------------------------------------------------
# Get
# ----------------------------------------------------------------------------

hwdata_get: $(STATEDIR)/hwdata.get

hwdata_get_deps = $(HWDATA_SOURCE)

$(STATEDIR)/hwdata.get: $(hwdata_get_deps)
	@$(call targetinfo, $@)
	@$(call get_patches, $(HWDATA))
	touch $@

$(HWDATA_SOURCE):
	@$(call targetinfo, $@)
	@$(call get, $(HWDATA_URL))

# ----------------------------------------------------------------------------
# Extract
# ----------------------------------------------------------------------------

hwdata_extract: $(STATEDIR)/hwdata.extract

hwdata_extract_deps = $(STATEDIR)/hwdata.get

$(STATEDIR)/hwdata.extract: $(hwdata_extract_deps)
	@$(call targetinfo, $@)
	@$(call clean, $(HWDATA_DIR))
	@$(call extract, $(HWDATA_SOURCE))
	@$(call patchin, $(HWDATA))
	touch $@

# ----------------------------------------------------------------------------
# Prepare
# ----------------------------------------------------------------------------

hwdata_prepare: $(STATEDIR)/hwdata.prepare

#
# dependencies
#
hwdata_prepare_deps = \
	$(STATEDIR)/hwdata.extract \
	$(STATEDIR)/virtual-xchain.install

HWDATA_PATH	=  PATH=$(CROSS_PATH)
HWDATA_ENV 	=  $(CROSS_ENV)
#HWDATA_ENV	+=
HWDATA_ENV	+= PKG_CONFIG_PATH=$(CROSS_LIB_DIR)/lib/pkgconfig:$(CROSS_LIB_DIR)/lib/pkgconfig
#ifdef PTXCONF_XFREE430
#HWDATA_ENV	+= LDFLAGS=-Wl,-rpath-link,$(CROSS_LIB_DIR)/lib
#endif

#
# autoconf
#
HWDATA_AUTOCONF = \
	--build=$(GNU_HOST) \
	--host=$(PTXCONF_GNU_TARGET) \
	--prefix=/usr

ifdef PTXCONF_XFREE430
HWDATA_AUTOCONF += --x-includes=$(CROSS_LIB_DIR)/include
HWDATA_AUTOCONF += --x-libraries=$(CROSS_LIB_DIR)/lib
endif

$(STATEDIR)/hwdata.prepare: $(hwdata_prepare_deps)
	@$(call targetinfo, $@)
	@$(call clean, $(HWDATA_DIR)/config.cache)
	#cd $(HWDATA_DIR) && \
	#	$(HWDATA_PATH) $(HWDATA_ENV) \
	#	./configure $(HWDATA_AUTOCONF)
	touch $@

# ----------------------------------------------------------------------------
# Compile
# ----------------------------------------------------------------------------

hwdata_compile: $(STATEDIR)/hwdata.compile

hwdata_compile_deps = $(STATEDIR)/hwdata.prepare

$(STATEDIR)/hwdata.compile: $(hwdata_compile_deps)
	@$(call targetinfo, $@)
	#$(HWDATA_PATH) $(MAKE) -C $(HWDATA_DIR)
	touch $@

# ----------------------------------------------------------------------------
# Install
# ----------------------------------------------------------------------------

hwdata_install: $(STATEDIR)/hwdata.install

$(STATEDIR)/hwdata.install: $(STATEDIR)/hwdata.compile
	@$(call targetinfo, $@)
	#$(HWDATA_PATH) $(MAKE) -C $(HWDATA_DIR) install
	touch $@

# ----------------------------------------------------------------------------
# Target-Install
# ----------------------------------------------------------------------------

hwdata_targetinstall: $(STATEDIR)/hwdata.targetinstall

hwdata_targetinstall_deps = $(STATEDIR)/hwdata.compile

$(STATEDIR)/hwdata.targetinstall: $(hwdata_targetinstall_deps)
	@$(call targetinfo, $@)
	$(HWDATA_PATH) $(MAKE) -C $(HWDATA_DIR) DESTDIR=$(HWDATA_IPKG_TMP) install
	rm -rf $(HWDATA_IPKG_TMP)/etc/hotplug
	rm -rf $(HWDATA_IPKG_TMP)/etc/pcmcia
	rm -rf $(HWDATA_IPKG_TMP)/usr/X11R6
	mkdir -p $(HWDATA_IPKG_TMP)/CONTROL
	echo "Package: hwdata" 								 >$(HWDATA_IPKG_TMP)/CONTROL/control
	echo "Priority: optional" 							>>$(HWDATA_IPKG_TMP)/CONTROL/control
	echo "Section: Kernel" 								>>$(HWDATA_IPKG_TMP)/CONTROL/control
	echo "Maintainer: Alexander Chukov <sash@pdaXrom.org>" 				>>$(HWDATA_IPKG_TMP)/CONTROL/control
	echo "Architecture: $(SHORT_TARGET)" 						>>$(HWDATA_IPKG_TMP)/CONTROL/control
	echo "Version: $(HWDATA_VERSION)-$(HWDATA_VENDOR_VERSION)" 			>>$(HWDATA_IPKG_TMP)/CONTROL/control
	echo "Depends: " 								>>$(HWDATA_IPKG_TMP)/CONTROL/control
	echo "Description: generated with pdaXrom builder"				>>$(HWDATA_IPKG_TMP)/CONTROL/control
	cd $(FEEDDIR) && $(XMKIPKG) $(HWDATA_IPKG_TMP)
	touch $@

# ----------------------------------------------------------------------------
# Image-Install
# ----------------------------------------------------------------------------

ifdef PTXCONF_HWDATA_INSTALL
ROMPACKAGES += $(STATEDIR)/hwdata.imageinstall
endif

hwdata_imageinstall_deps = $(STATEDIR)/hwdata.targetinstall \
	$(STATEDIR)/virtual-image.install

$(STATEDIR)/hwdata.imageinstall: $(hwdata_imageinstall_deps)
	@$(call targetinfo, $@)
	cd $(FEEDDIR) && $(XIPKG) install hwdata
	touch $@

# ----------------------------------------------------------------------------
# Clean
# ----------------------------------------------------------------------------

hwdata_clean:
	rm -rf $(STATEDIR)/hwdata.*
	rm -rf $(HWDATA_DIR)

# vim: syntax=make
