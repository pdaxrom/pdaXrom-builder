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
ifdef PTXCONF_SDCARD
PACKAGES += sdcard
endif

#
# Paths and names
#
SDCARD_VENDOR_VERSION	= 2
SDCARD_VERSION		= 0.0.3
SDCARD			= sdcard-$(SDCARD_VERSION)
SDCARD_SUFFIX		= tar.bz2
SDCARD_URL		= http://www.pdaXrom.org/src/$(SDCARD).$(SDCARD_SUFFIX)
SDCARD_SOURCE		= $(SRCDIR)/$(SDCARD).$(SDCARD_SUFFIX)
SDCARD_DIR		= $(BUILDDIR)/$(SDCARD)
SDCARD_IPKG_TMP		= $(SDCARD_DIR)/root

# ----------------------------------------------------------------------------
# Get
# ----------------------------------------------------------------------------

sdcard_get: $(STATEDIR)/sdcard.get

sdcard_get_deps = $(SDCARD_SOURCE)

$(STATEDIR)/sdcard.get: $(sdcard_get_deps)
	@$(call targetinfo, $@)
	@$(call get_patches, $(SDCARD))
	touch $@

$(SDCARD_SOURCE):
	@$(call targetinfo, $@)
	@$(call get, $(SDCARD_URL))

# ----------------------------------------------------------------------------
# Extract
# ----------------------------------------------------------------------------

sdcard_extract: $(STATEDIR)/sdcard.extract

sdcard_extract_deps = $(STATEDIR)/sdcard.get

$(STATEDIR)/sdcard.extract: $(sdcard_extract_deps)
	@$(call targetinfo, $@)
	@$(call clean, $(SDCARD_DIR))
	@$(call extract, $(SDCARD_SOURCE))
	@$(call patchin, $(SDCARD))
	touch $@

# ----------------------------------------------------------------------------
# Prepare
# ----------------------------------------------------------------------------

sdcard_prepare: $(STATEDIR)/sdcard.prepare

#
# dependencies
#
sdcard_prepare_deps = \
	$(STATEDIR)/sdcard.extract \
	$(STATEDIR)/virtual-xchain.install

SDCARD_PATH	=  PATH=$(CROSS_PATH)
SDCARD_ENV 	=  $(CROSS_ENV)
#SDCARD_ENV	+=
SDCARD_ENV	+= PKG_CONFIG_PATH=$(CROSS_LIB_DIR)/lib/pkgconfig:$(CROSS_LIB_DIR)/lib/pkgconfig
#ifdef PTXCONF_XFREE430
#SDCARD_ENV	+= LDFLAGS=-Wl,-rpath-link,$(CROSS_LIB_DIR)/lib
#endif

#
# autoconf
#
SDCARD_AUTOCONF = \
	--build=$(GNU_HOST) \
	--host=$(PTXCONF_GNU_TARGET) \
	--prefix=/usr

ifdef PTXCONF_XFREE430
SDCARD_AUTOCONF += --x-includes=$(CROSS_LIB_DIR)/include
SDCARD_AUTOCONF += --x-libraries=$(CROSS_LIB_DIR)/lib
endif

ifdef PTXCONF_ARM_ARCH_PXA
SDCARD_TARGET=corgi
endif
ifdef PTXCONF_ARM_ARCH_SA1100
SDCARD_TARGET=collie
endif

$(STATEDIR)/sdcard.prepare: $(sdcard_prepare_deps)
	@$(call targetinfo, $@)
	@$(call clean, $(SDCARD_DIR)/config.cache)
	cd $(SDCARD_DIR) && \
		$(SDCARD_PATH) $(SDCARD_ENV) \
		./Configure --kernel=$(KERNEL_DIR)
	touch $@

# ----------------------------------------------------------------------------
# Compile
# ----------------------------------------------------------------------------

sdcard_compile: $(STATEDIR)/sdcard.compile

sdcard_compile_deps = $(STATEDIR)/sdcard.prepare

$(STATEDIR)/sdcard.compile: $(sdcard_compile_deps)
	@$(call targetinfo, $@)
ifdef PTXCONF_KERNEL_EXTERNAL_GCC
	$(SDCARD_PATH) $(MAKE) -C $(SDCARD_DIR) \
	    CC=$(PTXCONF_KERNEL_EXTERNAL_GCC_PATH)/arm-linux-gcc \
	    LD=$(PTXCONF_KERNEL_EXTERNAL_GCC_PATH)/arm-linux-ld \
	    all-$(SDCARD_TARGET)
else
	$(SDCARD_PATH) $(MAKE) -C $(SDCARD_DIR) \
	    CC=$(PTXCONF_GNU_TARGET)-gcc \
	    LD=$(PTXCONF_GNU_TARGET)-ld \
	    all-$(SDCARD_TARGET)
endif
	touch $@

# ----------------------------------------------------------------------------
# Install
# ----------------------------------------------------------------------------

sdcard_install: $(STATEDIR)/sdcard.install

$(STATEDIR)/sdcard.install: $(STATEDIR)/sdcard.compile
	@$(call targetinfo, $@)
	$(SDCARD_PATH) $(MAKE) -C $(SDCARD_DIR) install
	touch $@

# ----------------------------------------------------------------------------
# Target-Install
# ----------------------------------------------------------------------------

sdcard_targetinstall: $(STATEDIR)/sdcard.targetinstall

sdcard_targetinstall_deps = $(STATEDIR)/sdcard.compile

$(STATEDIR)/sdcard.targetinstall: $(sdcard_targetinstall_deps)
	@$(call targetinfo, $@)
	mkdir -p $(SDCARD_IPKG_TMP)/CONTROL
	echo "Package: sdcard" 							>$(SDCARD_IPKG_TMP)/CONTROL/control
	echo "Priority: optional" 						>>$(SDCARD_IPKG_TMP)/CONTROL/control
	echo "Section: Utilities" 						>>$(SDCARD_IPKG_TMP)/CONTROL/control
	echo "Maintainer: Alexander Chukov <sash@pdaXrom.org>" 			>>$(SDCARD_IPKG_TMP)/CONTROL/control
	echo "Architecture: $(SHORT_TARGET)" 					>>$(SDCARD_IPKG_TMP)/CONTROL/control
	echo "Version: $(SDCARD_VERSION)-$(SDCARD_VENDOR_VERSION)" 		>>$(SDCARD_IPKG_TMP)/CONTROL/control
	echo "Depends: " 							>>$(SDCARD_IPKG_TMP)/CONTROL/control
	echo "Description: SD card drivers and utils"				>>$(SDCARD_IPKG_TMP)/CONTROL/control
	cd $(FEEDDIR) && $(XMKIPKG) $(SDCARD_IPKG_TMP)
	touch $@

# ----------------------------------------------------------------------------
# Image-Install
# ----------------------------------------------------------------------------

ifdef PTXCONF_SDCARD_INSTALL
ROMPACKAGES += $(STATEDIR)/sdcard.imageinstall
endif

sdcard_imageinstall_deps = $(STATEDIR)/sdcard.targetinstall \
	$(STATEDIR)/virtual-image.install

$(STATEDIR)/sdcard.imageinstall: $(sdcard_imageinstall_deps)
	@$(call targetinfo, $@)
	cd $(FEEDDIR) && $(XIPKG) install sdcard
	touch $@

# ----------------------------------------------------------------------------
# Clean
# ----------------------------------------------------------------------------

sdcard_clean:
	rm -rf $(STATEDIR)/sdcard.*
	rm -rf $(SDCARD_DIR)

# vim: syntax=make
