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
ifdef PTXCONF_ZONEINFO
PACKAGES += zoneinfo
endif

#
# Paths and names
#
ZONEINFO_VERSION	= 1.0.0
ZONEINFO		= zoneinfo-$(ZONEINFO_VERSION)
ZONEINFO_SUFFIX		= tar.bz2
ZONEINFO_URL		= http://www.pdaXrom.org/src/$(ZONEINFO).$(ZONEINFO_SUFFIX)
ZONEINFO_SOURCE		= $(SRCDIR)/$(ZONEINFO).$(ZONEINFO_SUFFIX)
ZONEINFO_DIR		= $(BUILDDIR)/$(ZONEINFO)
ZONEINFO_IPKG_TMP	= $(ZONEINFO_DIR)

# ----------------------------------------------------------------------------
# Get
# ----------------------------------------------------------------------------

zoneinfo_get: $(STATEDIR)/zoneinfo.get

zoneinfo_get_deps = $(ZONEINFO_SOURCE)

$(STATEDIR)/zoneinfo.get: $(zoneinfo_get_deps)
	@$(call targetinfo, $@)
	@$(call get_patches, $(ZONEINFO))
	touch $@

$(ZONEINFO_SOURCE):
	@$(call targetinfo, $@)
	@$(call get, $(ZONEINFO_URL))

# ----------------------------------------------------------------------------
# Extract
# ----------------------------------------------------------------------------

zoneinfo_extract: $(STATEDIR)/zoneinfo.extract

zoneinfo_extract_deps = $(STATEDIR)/zoneinfo.get

$(STATEDIR)/zoneinfo.extract: $(zoneinfo_extract_deps)
	@$(call targetinfo, $@)
	@$(call clean, $(ZONEINFO_DIR))
	@$(call extract, $(ZONEINFO_SOURCE))
	@$(call patchin, $(ZONEINFO))
	touch $@

# ----------------------------------------------------------------------------
# Prepare
# ----------------------------------------------------------------------------

zoneinfo_prepare: $(STATEDIR)/zoneinfo.prepare

#
# dependencies
#
zoneinfo_prepare_deps = \
	$(STATEDIR)/zoneinfo.extract \
	$(STATEDIR)/virtual-xchain.install

ZONEINFO_PATH	=  PATH=$(CROSS_PATH)
ZONEINFO_ENV 	=  $(CROSS_ENV)
#ZONEINFO_ENV	+=
ZONEINFO_ENV	+= PKG_CONFIG_PATH=$(CROSS_LIB_DIR)/lib/pkgconfig:$(CROSS_LIB_DIR)/lib/pkgconfig
#ifdef PTXCONF_XFREE430
#ZONEINFO_ENV	+= LDFLAGS=-Wl,-rpath-link,$(CROSS_LIB_DIR)/lib
#endif

#
# autoconf
#
ZONEINFO_AUTOCONF = \
	--build=$(GNU_HOST) \
	--host=$(PTXCONF_GNU_TARGET) \
	--prefix=/usr

ifdef PTXCONF_XFREE430
ZONEINFO_AUTOCONF += --x-includes=$(CROSS_LIB_DIR)/include
ZONEINFO_AUTOCONF += --x-libraries=$(CROSS_LIB_DIR)/lib
endif

$(STATEDIR)/zoneinfo.prepare: $(zoneinfo_prepare_deps)
	@$(call targetinfo, $@)
	@$(call clean, $(ZONEINFO_DIR)/config.cache)
	#cd $(ZONEINFO_DIR) && \
	#	$(ZONEINFO_PATH) $(ZONEINFO_ENV) \
	#	./configure $(ZONEINFO_AUTOCONF)
	touch $@

# ----------------------------------------------------------------------------
# Compile
# ----------------------------------------------------------------------------

zoneinfo_compile: $(STATEDIR)/zoneinfo.compile

zoneinfo_compile_deps = $(STATEDIR)/zoneinfo.prepare

$(STATEDIR)/zoneinfo.compile: $(zoneinfo_compile_deps)
	@$(call targetinfo, $@)
	#$(ZONEINFO_PATH) $(MAKE) -C $(ZONEINFO_DIR)
	touch $@

# ----------------------------------------------------------------------------
# Install
# ----------------------------------------------------------------------------

zoneinfo_install: $(STATEDIR)/zoneinfo.install

$(STATEDIR)/zoneinfo.install: $(STATEDIR)/zoneinfo.compile
	@$(call targetinfo, $@)
	#$(ZONEINFO_PATH) $(MAKE) -C $(ZONEINFO_DIR) install
	touch $@

# ----------------------------------------------------------------------------
# Target-Install
# ----------------------------------------------------------------------------

zoneinfo_targetinstall: $(STATEDIR)/zoneinfo.targetinstall

zoneinfo_targetinstall_deps = $(STATEDIR)/zoneinfo.compile

$(STATEDIR)/zoneinfo.targetinstall: $(zoneinfo_targetinstall_deps)
	@$(call targetinfo, $@)
	#$(ZONEINFO_PATH) $(MAKE) -C $(ZONEINFO_DIR) DESTDIR=$(ZONEINFO_IPKG_TMP) install
	mkdir -p $(ZONEINFO_IPKG_TMP)/CONTROL
	echo "Package: timezones" 						>$(ZONEINFO_IPKG_TMP)/CONTROL/control
	echo "Priority: optional" 						>>$(ZONEINFO_IPKG_TMP)/CONTROL/control
	echo "Section: Utilities"	 					>>$(ZONEINFO_IPKG_TMP)/CONTROL/control
	echo "Maintainer: Alexander Chukov <sash@pdaXrom.org>" 			>>$(ZONEINFO_IPKG_TMP)/CONTROL/control
	echo "Architecture: $(SHORT_TARGET)" 					>>$(ZONEINFO_IPKG_TMP)/CONTROL/control
	echo "Version: $(ZONEINFO_VERSION)" 					>>$(ZONEINFO_IPKG_TMP)/CONTROL/control
	echo "Depends: " 							>>$(ZONEINFO_IPKG_TMP)/CONTROL/control
	echo "Description: time zones"						>>$(ZONEINFO_IPKG_TMP)/CONTROL/control
	cd $(FEEDDIR) && $(XMKIPKG) $(ZONEINFO_IPKG_TMP)
	touch $@

# ----------------------------------------------------------------------------
# Image-Install
# ----------------------------------------------------------------------------

ifdef PTXCONF_ZONEINFO_INSTALL
ROMPACKAGES += $(STATEDIR)/zoneinfo.imageinstall
endif

zoneinfo_imageinstall_deps = $(STATEDIR)/zoneinfo.targetinstall \
	$(STATEDIR)/virtual-image.install

$(STATEDIR)/zoneinfo.imageinstall: $(zoneinfo_imageinstall_deps)
	@$(call targetinfo, $@)
	cd $(FEEDDIR) && $(XIPKG) install timezones
	touch $@

# ----------------------------------------------------------------------------
# Clean
# ----------------------------------------------------------------------------

zoneinfo_clean:
	rm -rf $(STATEDIR)/zoneinfo.*
	rm -rf $(ZONEINFO_DIR)

# vim: syntax=make
