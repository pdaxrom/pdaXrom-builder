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
ifdef PTXCONF_ZIP
PACKAGES += zip
endif

#
# Paths and names
#
ZIP_VERSION	= 2.3
ZIP		= zip23
ZIP_SUFFIX	= tar.gz
ZIP_URL		= http://www.mirror.ac.uk/sites/ftp.info-zip.org/pub/infozip/src/$(ZIP).$(ZIP_SUFFIX)
ZIP_SOURCE	= $(SRCDIR)/$(ZIP).$(ZIP_SUFFIX)
ZIP_DIR		= $(BUILDDIR)/zip-$(ZIP_VERSION)
ZIP_IPKG_TMP	= $(ZIP_DIR)/ipkg_tmp

# ----------------------------------------------------------------------------
# Get
# ----------------------------------------------------------------------------

zip_get: $(STATEDIR)/zip.get

zip_get_deps = $(ZIP_SOURCE)

$(STATEDIR)/zip.get: $(zip_get_deps)
	@$(call targetinfo, $@)
	@$(call get_patches, $(ZIP))
	touch $@

$(ZIP_SOURCE):
	@$(call targetinfo, $@)
	@$(call get, $(ZIP_URL))

# ----------------------------------------------------------------------------
# Extract
# ----------------------------------------------------------------------------

zip_extract: $(STATEDIR)/zip.extract

zip_extract_deps = $(STATEDIR)/zip.get

$(STATEDIR)/zip.extract: $(zip_extract_deps)
	@$(call targetinfo, $@)
	@$(call clean, $(ZIP_DIR))
	@$(call extract, $(ZIP_SOURCE))
	@$(call patchin, $(ZIP))
	touch $@

# ----------------------------------------------------------------------------
# Prepare
# ----------------------------------------------------------------------------

zip_prepare: $(STATEDIR)/zip.prepare

#
# dependencies
#
zip_prepare_deps = \
	$(STATEDIR)/zip.extract \
	$(STATEDIR)/virtual-xchain.install

ZIP_PATH	=  PATH=$(CROSS_PATH)
ZIP_ENV 	=  $(CROSS_ENV)
#ZIP_ENV	+=
ZIP_ENV	+= PKG_CONFIG_PATH=$(CROSS_LIB_DIR)/lib/pkgconfig:$(CROSS_LIB_DIR)/lib/pkgconfig
#ifdef PTXCONF_XFREE430
#ZIP_ENV	+= LDFLAGS=-Wl,-rpath-link,$(CROSS_LIB_DIR)/lib
#endif

#
# autoconf
#
ZIP_AUTOCONF = \
	--build=$(GNU_HOST) \
	--host=$(PTXCONF_GNU_TARGET) \
	--prefix=/usr

ifdef PTXCONF_XFREE430
ZIP_AUTOCONF += --x-includes=$(CROSS_LIB_DIR)/include
ZIP_AUTOCONF += --x-libraries=$(CROSS_LIB_DIR)/lib
endif

$(STATEDIR)/zip.prepare: $(zip_prepare_deps)
	@$(call targetinfo, $@)
	@$(call clean, $(ZIP_DIR)/config.cache)
	#cd $(ZIP_DIR) && \
	#	$(ZIP_PATH) $(ZIP_ENV) \
	#	./configure $(ZIP_AUTOCONF)
	touch $@

# ----------------------------------------------------------------------------
# Compile
# ----------------------------------------------------------------------------

zip_compile: $(STATEDIR)/zip.compile

zip_compile_deps = $(STATEDIR)/zip.prepare

$(STATEDIR)/zip.compile: $(zip_compile_deps)
	@$(call targetinfo, $@)
	$(ZIP_PATH) $(MAKE) $(ZIP_ENV) -C $(ZIP_DIR) -f unix/Makefile CFLAGS="$(TARGET_OPT_CFLAGS) -DUNIX -I." generic AS="$(PTXCONF_GNU_TARGET)-gcc -c"
	touch $@

# ----------------------------------------------------------------------------
# Install
# ----------------------------------------------------------------------------

zip_install: $(STATEDIR)/zip.install

$(STATEDIR)/zip.install: $(STATEDIR)/zip.compile
	@$(call targetinfo, $@)
	touch $@

# ----------------------------------------------------------------------------
# Target-Install
# ----------------------------------------------------------------------------

zip_targetinstall: $(STATEDIR)/zip.targetinstall

zip_targetinstall_deps = $(STATEDIR)/zip.compile

$(STATEDIR)/zip.targetinstall: $(zip_targetinstall_deps)
	@$(call targetinfo, $@)
	$(ZIP_PATH) $(MAKE) $(ZIP_ENV) -C $(ZIP_DIR) -f unix/Makefile CFLAGS="$(TARGET_OPT_CFLAGS) -DUNIX -I." prefix=$(ZIP_IPKG_TMP)/usr install	
	rm -rf $(ZIP_IPKG_TMP)/usr/man
	mkdir -p $(ZIP_IPKG_TMP)/CONTROL
	echo "Package: zip" 							 >$(ZIP_IPKG_TMP)/CONTROL/control
	echo "Priority: optional" 						>>$(ZIP_IPKG_TMP)/CONTROL/control
	echo "Section: Utilities" 						>>$(ZIP_IPKG_TMP)/CONTROL/control
	echo "Maintainer: Alexander Chukov <sash@pdaXrom.org>" 			>>$(ZIP_IPKG_TMP)/CONTROL/control
	echo "Architecture: $(SHORT_TARGET)" 					>>$(ZIP_IPKG_TMP)/CONTROL/control
	echo "Version: $(ZIP_VERSION)" 						>>$(ZIP_IPKG_TMP)/CONTROL/control
	echo "Depends: " 							>>$(ZIP_IPKG_TMP)/CONTROL/control
	echo "Description: compression and file packaging utility."		>>$(ZIP_IPKG_TMP)/CONTROL/control
	cd $(FEEDDIR) && $(XMKIPKG) $(ZIP_IPKG_TMP)
	touch $@

# ----------------------------------------------------------------------------
# Image-Install
# ----------------------------------------------------------------------------

ifdef PTXCONF_ZIP_INSTALL
ROMPACKAGES += $(STATEDIR)/zip.imageinstall
endif

zip_imageinstall_deps = $(STATEDIR)/zip.targetinstall \
	$(STATEDIR)/virtual-image.install

$(STATEDIR)/zip.imageinstall: $(zip_imageinstall_deps)
	@$(call targetinfo, $@)
	cd $(FEEDDIR) && $(XIPKG) install zip
	touch $@

# ----------------------------------------------------------------------------
# Clean
# ----------------------------------------------------------------------------

zip_clean:
	rm -rf $(STATEDIR)/zip.*
	rm -rf $(ZIP_DIR)

# vim: syntax=make
