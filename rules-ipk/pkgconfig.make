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
ifdef PTXCONF_PKGCONFIG
PACKAGES += pkgconfig
endif

#
# Paths and names
#
PKGCONFIG_VERSION	= 0.15.0
PKGCONFIG		= pkgconfig-$(PKGCONFIG_VERSION)
PKGCONFIG_SUFFIX	= tar.gz
PKGCONFIG_URL		= http://www.freedesktop.org/software/pkgconfig/releases/$(PKGCONFIG).$(PKGCONFIG_SUFFIX)
PKGCONFIG_SOURCE	= $(SRCDIR)/$(PKGCONFIG).$(PKGCONFIG_SUFFIX)
PKGCONFIG_DIR		= $(BUILDDIR)/$(PKGCONFIG)
PKGCONFIG_IPKG_TMP	= $(PKGCONFIG_DIR)/ipkg_tmp

# ----------------------------------------------------------------------------
# Get
# ----------------------------------------------------------------------------

pkgconfig_get: $(STATEDIR)/pkgconfig.get

pkgconfig_get_deps = $(PKGCONFIG_SOURCE)

$(STATEDIR)/pkgconfig.get: $(pkgconfig_get_deps)
	@$(call targetinfo, $@)
	@$(call get_patches, $(PKGCONFIG))
	touch $@

$(PKGCONFIG_SOURCE):
	@$(call targetinfo, $@)
	@$(call get, $(PKGCONFIG_URL))

# ----------------------------------------------------------------------------
# Extract
# ----------------------------------------------------------------------------

pkgconfig_extract: $(STATEDIR)/pkgconfig.extract

pkgconfig_extract_deps = $(STATEDIR)/pkgconfig.get

$(STATEDIR)/pkgconfig.extract: $(pkgconfig_extract_deps)
	@$(call targetinfo, $@)
	@$(call clean, $(PKGCONFIG_DIR))
	@$(call extract, $(PKGCONFIG_SOURCE))
	@$(call patchin, $(PKGCONFIG))
	touch $@

# ----------------------------------------------------------------------------
# Prepare
# ----------------------------------------------------------------------------

pkgconfig_prepare: $(STATEDIR)/pkgconfig.prepare

#
# dependencies
#
pkgconfig_prepare_deps = \
	$(STATEDIR)/pkgconfig.extract \
	$(STATEDIR)/virtual-xchain.install

PKGCONFIG_PATH	=  PATH=$(CROSS_PATH)
PKGCONFIG_ENV 	=  $(CROSS_ENV)
#PKGCONFIG_ENV	+=
PKGCONFIG_ENV	+= PKG_CONFIG_PATH=$(CROSS_LIB_DIR)/lib/pkgconfig:$(CROSS_LIB_DIR)/lib/pkgconfig
#ifdef PTXCONF_XFREE430
#PKGCONFIG_ENV	+= LDFLAGS=-Wl,-rpath-link,$(CROSS_LIB_DIR)/lib
#endif

#
# autoconf
#
PKGCONFIG_AUTOCONF = \
	--build=$(GNU_HOST) \
	--host=$(PTXCONF_GNU_TARGET) \
	--prefix=$(PTXCONF_NATIVE_PREFIX)

ifdef PTXCONF_XFREE430
PKGCONFIG_AUTOCONF += --x-includes=$(CROSS_LIB_DIR)/include
PKGCONFIG_AUTOCONF += --x-libraries=$(CROSS_LIB_DIR)/lib
endif

$(STATEDIR)/pkgconfig.prepare: $(pkgconfig_prepare_deps)
	@$(call targetinfo, $@)
	@$(call clean, $(PKGCONFIG_DIR)/config.cache)
	cd $(PKGCONFIG_DIR) && \
		$(PKGCONFIG_PATH) $(PKGCONFIG_ENV) \
		./configure $(PKGCONFIG_AUTOCONF)
	touch $@

# ----------------------------------------------------------------------------
# Compile
# ----------------------------------------------------------------------------

pkgconfig_compile: $(STATEDIR)/pkgconfig.compile

pkgconfig_compile_deps = $(STATEDIR)/pkgconfig.prepare

$(STATEDIR)/pkgconfig.compile: $(pkgconfig_compile_deps)
	@$(call targetinfo, $@)
	$(PKGCONFIG_PATH) $(MAKE) -C $(PKGCONFIG_DIR)
	touch $@

# ----------------------------------------------------------------------------
# Install
# ----------------------------------------------------------------------------

pkgconfig_install: $(STATEDIR)/pkgconfig.install

$(STATEDIR)/pkgconfig.install: $(STATEDIR)/pkgconfig.compile
	@$(call targetinfo, $@)
	#####$(PKGCONFIG_PATH) $(MAKE) -C $(PKGCONFIG_DIR) install
	touch $@

# ----------------------------------------------------------------------------
# Target-Install
# ----------------------------------------------------------------------------

pkgconfig_targetinstall: $(STATEDIR)/pkgconfig.targetinstall

pkgconfig_targetinstall_deps = $(STATEDIR)/pkgconfig.compile

$(STATEDIR)/pkgconfig.targetinstall: $(pkgconfig_targetinstall_deps)
	@$(call targetinfo, $@)
	$(PKGCONFIG_PATH) $(MAKE) -C $(PKGCONFIG_DIR) DESTDIR=$(PKGCONFIG_IPKG_TMP) install
	$(CROSSSTRIP) $(PKGCONFIG_IPKG_TMP)$(PTXCONF_NATIVE_PREFIX)/bin/pkg-config
	#####$(INSTALL) -D -m 644 $(PKGCONFIG_DIR)/pkg.m4 $(PKGCONFIG_IPKG_TMP)$(PTXCONF_NATIVE_PREFIX)/share/aclocal/pkg.m4
	rm -rf $(PKGCONFIG_IPKG_TMP)$(PTXCONF_NATIVE_PREFIX)/man
	mkdir -p $(PKGCONFIG_IPKG_TMP)/CONTROL
	echo "Package: pkgconfig" 			>$(PKGCONFIG_IPKG_TMP)/CONTROL/control
	echo "Priority: optional" 			>>$(PKGCONFIG_IPKG_TMP)/CONTROL/control
	echo "Section: Utils"	 			>>$(PKGCONFIG_IPKG_TMP)/CONTROL/control
	echo "Maintainer: Alexander Chukov <sash@pdaXrom.org>">>$(PKGCONFIG_IPKG_TMP)/CONTROL/control
	echo "Architecture: $(SHORT_TARGET)" 		>>$(PKGCONFIG_IPKG_TMP)/CONTROL/control
	echo "Version: $(PKGCONFIG_VERSION)" 		>>$(PKGCONFIG_IPKG_TMP)/CONTROL/control
	echo "Depends: " 				>>$(PKGCONFIG_IPKG_TMP)/CONTROL/control
	echo "Description: pkg-config is a script to make putting together all the build flags when compiling/linking a lot easier.">>$(PKGCONFIG_IPKG_TMP)/CONTROL/control
	cd $(FEEDDIR) && $(XMKIPKG) $(PKGCONFIG_IPKG_TMP)
	cp -a $(PKGCONFIG_DIR)/pkg.m4 $(PTXCONF_PREFIX)/share/aclocal/
	touch $@

# ----------------------------------------------------------------------------
# Image-Install
# ----------------------------------------------------------------------------

ifdef PTXCONF_PKGCONFIG_INSTALL
ROMPACKAGES += $(STATEDIR)/pkgconfig.imageinstall
endif

pkgconfig_imageinstall_deps = $(STATEDIR)/pkgconfig.targetinstall \
	$(STATEDIR)/virtual-image.install

$(STATEDIR)/pkgconfig.imageinstall: $(pkgconfig_imageinstall_deps)
	@$(call targetinfo, $@)
	cd $(FEEDDIR) && $(XIPKG) install pkgconfig
	touch $@

# ----------------------------------------------------------------------------
# Clean
# ----------------------------------------------------------------------------

pkgconfig_clean:
	rm -rf $(STATEDIR)/pkgconfig.*
	rm -rf $(PKGCONFIG_DIR)

# vim: syntax=make
