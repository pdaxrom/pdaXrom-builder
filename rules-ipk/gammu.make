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
ifdef PTXCONF_GAMMU
PACKAGES += gammu
endif

#
# Paths and names
#
GAMMU_VENDOR_VERSION	= 1
GAMMU_VERSION		= 0.99.0
GAMMU			= gammu-$(GAMMU_VERSION)
GAMMU_SUFFIX		= tar.gz
GAMMU_URL		= http://www.mwiacek.com/zips/gsm/gammu/stable/0_9x/$(GAMMU).$(GAMMU_SUFFIX)
GAMMU_SOURCE		= $(SRCDIR)/$(GAMMU).$(GAMMU_SUFFIX)
GAMMU_DIR		= $(BUILDDIR)/$(GAMMU)
GAMMU_IPKG_TMP		= $(GAMMU_DIR)/ipkg_tmp

# ----------------------------------------------------------------------------
# Get
# ----------------------------------------------------------------------------

gammu_get: $(STATEDIR)/gammu.get

gammu_get_deps = $(GAMMU_SOURCE)

$(STATEDIR)/gammu.get: $(gammu_get_deps)
	@$(call targetinfo, $@)
	@$(call get_patches, $(GAMMU))
	touch $@

$(GAMMU_SOURCE):
	@$(call targetinfo, $@)
	@$(call get, $(GAMMU_URL))

# ----------------------------------------------------------------------------
# Extract
# ----------------------------------------------------------------------------

gammu_extract: $(STATEDIR)/gammu.extract

gammu_extract_deps = $(STATEDIR)/gammu.get

$(STATEDIR)/gammu.extract: $(gammu_extract_deps)
	@$(call targetinfo, $@)
	@$(call clean, $(GAMMU_DIR))
	@$(call extract, $(GAMMU_SOURCE))
	@$(call patchin, $(GAMMU))
	touch $@

# ----------------------------------------------------------------------------
# Prepare
# ----------------------------------------------------------------------------

gammu_prepare: $(STATEDIR)/gammu.prepare

#
# dependencies
#
gammu_prepare_deps = \
	$(STATEDIR)/gammu.extract \
	$(STATEDIR)/bluez-sdp.install \
	$(STATEDIR)/virtual-xchain.install

GAMMU_PATH	=  PATH=$(CROSS_PATH)
GAMMU_ENV 	=  $(CROSS_ENV)
#GAMMU_ENV	+=
GAMMU_ENV	+= PKG_CONFIG_PATH=$(CROSS_LIB_DIR)/lib/pkgconfig:$(CROSS_LIB_DIR)/lib/pkgconfig
#ifdef PTXCONF_XFREE430
#GAMMU_ENV	+= LDFLAGS=-Wl,-rpath-link,$(CROSS_LIB_DIR)/lib
#endif

#
# autoconf
#
GAMMU_AUTOCONF = \
	--build=$(GNU_HOST) \
	--host=$(PTXCONF_GNU_TARGET) \
	--prefix=/usr

ifdef PTXCONF_XFREE430
GAMMU_AUTOCONF += --x-includes=$(CROSS_LIB_DIR)/include
GAMMU_AUTOCONF += --x-libraries=$(CROSS_LIB_DIR)/lib
endif

$(STATEDIR)/gammu.prepare: $(gammu_prepare_deps)
	@$(call targetinfo, $@)
	@$(call clean, $(GAMMU_DIR)/config.cache)
	cd $(GAMMU_DIR) && \
		$(GAMMU_PATH) $(GAMMU_ENV) \
		./configure $(GAMMU_AUTOCONF)
	touch $@

# ----------------------------------------------------------------------------
# Compile
# ----------------------------------------------------------------------------

gammu_compile: $(STATEDIR)/gammu.compile

gammu_compile_deps = $(STATEDIR)/gammu.prepare

$(STATEDIR)/gammu.compile: $(gammu_compile_deps)
	@$(call targetinfo, $@)
	$(GAMMU_PATH) $(MAKE) -C $(GAMMU_DIR) shared
	touch $@

# ----------------------------------------------------------------------------
# Install
# ----------------------------------------------------------------------------

gammu_install: $(STATEDIR)/gammu.install

$(STATEDIR)/gammu.install: $(STATEDIR)/gammu.compile
	@$(call targetinfo, $@)
	asdasd
	touch $@

# ----------------------------------------------------------------------------
# Target-Install
# ----------------------------------------------------------------------------

gammu_targetinstall: $(STATEDIR)/gammu.targetinstall

gammu_targetinstall_deps = $(STATEDIR)/gammu.compile \
	$(STATEDIR)/bluez-sdp.targetinstall

$(STATEDIR)/gammu.targetinstall: $(gammu_targetinstall_deps)
	@$(call targetinfo, $@)
	$(GAMMU_PATH) $(MAKE) -C $(GAMMU_DIR) DESTDIR=$(GAMMU_IPKG_TMP) installshared
	rm -rf $(GAMMU_IPKG_TMP)/usr/include
	rm -rf $(GAMMU_IPKG_TMP)/usr/lib/*.*a
	rm -rf $(GAMMU_IPKG_TMP)/usr/lib/pkgconfig
	rm -rf $(GAMMU_IPKG_TMP)/usr/man
	rm -rf $(GAMMU_IPKG_TMP)/usr/share/gammu
	rm -rf $(GAMMU_IPKG_TMP)/usr/share/doc/gammu/changelog
	rm -rf $(GAMMU_IPKG_TMP)/usr/share/doc/gammu/docs/italian
	$(CROSSSTRIP) $(GAMMU_IPKG_TMP)/usr/bin/*
	$(CROSSSTRIP) $(GAMMU_IPKG_TMP)/usr/lib/*.so*
	mkdir -p $(GAMMU_IPKG_TMP)/CONTROL
	echo "Package: gammu" 								 >$(GAMMU_IPKG_TMP)/CONTROL/control
	echo "Priority: optional" 							>>$(GAMMU_IPKG_TMP)/CONTROL/control
	echo "Section: Utilities" 							>>$(GAMMU_IPKG_TMP)/CONTROL/control
	echo "Maintainer: Alexander Chukov <sash@pdaXrom.org>" 				>>$(GAMMU_IPKG_TMP)/CONTROL/control
	echo "Architecture: $(SHORT_TARGET)" 						>>$(GAMMU_IPKG_TMP)/CONTROL/control
	echo "Version: $(GAMMU_VERSION)-$(GAMMU_VENDOR_VERSION)" 			>>$(GAMMU_IPKG_TMP)/CONTROL/control
	echo "Depends: bluez-sdp" 							>>$(GAMMU_IPKG_TMP)/CONTROL/control
	echo "Description: This is package with different tools and drivers for Nokia and other mobile phones released under GNU GPL/LGPL license (see /copying file)."	>>$(GAMMU_IPKG_TMP)/CONTROL/control
	cd $(FEEDDIR) && $(XMKIPKG) $(GAMMU_IPKG_TMP)
	touch $@

# ----------------------------------------------------------------------------
# Image-Install
# ----------------------------------------------------------------------------

ifdef PTXCONF_GAMMU_INSTALL
ROMPACKAGES += $(STATEDIR)/gammu.imageinstall
endif

gammu_imageinstall_deps = $(STATEDIR)/gammu.targetinstall \
	$(STATEDIR)/virtual-image.install

$(STATEDIR)/gammu.imageinstall: $(gammu_imageinstall_deps)
	@$(call targetinfo, $@)
	cd $(FEEDDIR) && $(XIPKG) install gammu
	touch $@

# ----------------------------------------------------------------------------
# Clean
# ----------------------------------------------------------------------------

gammu_clean:
	rm -rf $(STATEDIR)/gammu.*
	rm -rf $(GAMMU_DIR)

# vim: syntax=make
