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
ifdef PTXCONF_OPENOBEX-APPS
PACKAGES += openobex-apps
endif

#
# Paths and names
#
OPENOBEX-APPS_VERSION		= 1.0.0
OPENOBEX-APPS			= openobex-apps-$(OPENOBEX-APPS_VERSION)
OPENOBEX-APPS_SUFFIX		= tar.gz
OPENOBEX-APPS_URL		= http://heanet.dl.sourceforge.net/sourceforge/openobex/$(OPENOBEX-APPS).$(OPENOBEX-APPS_SUFFIX)
OPENOBEX-APPS_SOURCE		= $(SRCDIR)/$(OPENOBEX-APPS).$(OPENOBEX-APPS_SUFFIX)
OPENOBEX-APPS_DIR		= $(BUILDDIR)/$(OPENOBEX-APPS)
OPENOBEX-APPS_IPKG_TMP		= $(OPENOBEX-APPS_DIR)/ipkg_tmp

# ----------------------------------------------------------------------------
# Get
# ----------------------------------------------------------------------------

openobex-apps_get: $(STATEDIR)/openobex-apps.get

openobex-apps_get_deps = $(OPENOBEX-APPS_SOURCE)

$(STATEDIR)/openobex-apps.get: $(openobex-apps_get_deps)
	@$(call targetinfo, $@)
	@$(call get_patches, $(OPENOBEX-APPS))
	touch $@

$(OPENOBEX-APPS_SOURCE):
	@$(call targetinfo, $@)
	@$(call get, $(OPENOBEX-APPS_URL))

# ----------------------------------------------------------------------------
# Extract
# ----------------------------------------------------------------------------

openobex-apps_extract: $(STATEDIR)/openobex-apps.extract

openobex-apps_extract_deps = $(STATEDIR)/openobex-apps.get

$(STATEDIR)/openobex-apps.extract: $(openobex-apps_extract_deps)
	@$(call targetinfo, $@)
	@$(call clean, $(OPENOBEX-APPS_DIR))
	@$(call extract, $(OPENOBEX-APPS_SOURCE))
	@$(call patchin, $(OPENOBEX-APPS))
	touch $@

# ----------------------------------------------------------------------------
# Prepare
# ----------------------------------------------------------------------------

openobex-apps_prepare: $(STATEDIR)/openobex-apps.prepare

#
# dependencies
#
openobex-apps_prepare_deps = \
	$(STATEDIR)/openobex-apps.extract \
	$(STATEDIR)/openobex.install \
	$(STATEDIR)/virtual-xchain.install

OPENOBEX-APPS_PATH	=  PATH=$(CROSS_PATH)
OPENOBEX-APPS_ENV 	=  $(CROSS_ENV)
OPENOBEX-APPS_ENV	+= CFLAGS="-O2 -fomit-frame-pointer"
OPENOBEX-APPS_ENV	+= PKG_CONFIG_PATH=$(CROSS_LIB_DIR)/lib/pkgconfig:$(CROSS_LIB_DIR)/lib/pkgconfig
#ifdef PTXCONF_XFREE430
#OPENOBEX-APPS_ENV	+= LDFLAGS=-Wl,-rpath-link,$(CROSS_LIB_DIR)/lib
#endif

#
# autoconf
#
OPENOBEX-APPS_AUTOCONF = \
	--build=$(GNU_HOST) \
	--host=$(PTXCONF_GNU_TARGET) \
	--prefix=/usr

ifdef PTXCONF_XFREE430
OPENOBEX-APPS_AUTOCONF += --x-includes=$(CROSS_LIB_DIR)/include
OPENOBEX-APPS_AUTOCONF += --x-libraries=$(CROSS_LIB_DIR)/lib
endif

$(STATEDIR)/openobex-apps.prepare: $(openobex-apps_prepare_deps)
	@$(call targetinfo, $@)
	@$(call clean, $(OPENOBEX-APPS_DIR)/config.cache)
	cd $(OPENOBEX-APPS_DIR) && \
		$(OPENOBEX-APPS_PATH) $(OPENOBEX-APPS_ENV) \
		./configure $(OPENOBEX-APPS_AUTOCONF)
	touch $@

# ----------------------------------------------------------------------------
# Compile
# ----------------------------------------------------------------------------

openobex-apps_compile: $(STATEDIR)/openobex-apps.compile

openobex-apps_compile_deps = $(STATEDIR)/openobex-apps.prepare

$(STATEDIR)/openobex-apps.compile: $(openobex-apps_compile_deps)
	@$(call targetinfo, $@)
	$(OPENOBEX-APPS_PATH) $(MAKE) -C $(OPENOBEX-APPS_DIR)
	touch $@

# ----------------------------------------------------------------------------
# Install
# ----------------------------------------------------------------------------

openobex-apps_install: $(STATEDIR)/openobex-apps.install

$(STATEDIR)/openobex-apps.install: $(STATEDIR)/openobex-apps.compile
	@$(call targetinfo, $@)
	touch $@

# ----------------------------------------------------------------------------
# Target-Install
# ----------------------------------------------------------------------------

openobex-apps_targetinstall: $(STATEDIR)/openobex-apps.targetinstall

openobex-apps_targetinstall_deps = $(STATEDIR)/openobex-apps.compile \
	$(STATEDIR)/openobex.targetinstall

$(STATEDIR)/openobex-apps.targetinstall: $(openobex-apps_targetinstall_deps)
	@$(call targetinfo, $@)
	$(OPENOBEX-APPS_PATH) $(MAKE) -C $(OPENOBEX-APPS_DIR) DESTDIR=$(OPENOBEX-APPS_IPKG_TMP) install
	$(CROSSSTRIP) $(OPENOBEX-APPS_IPKG_TMP)/usr/bin/*
	mkdir -p $(OPENOBEX-APPS_IPKG_TMP)/CONTROL
	echo "Package: openobex-apps" 				>$(OPENOBEX-APPS_IPKG_TMP)/CONTROL/control
	echo "Priority: optional" 				>>$(OPENOBEX-APPS_IPKG_TMP)/CONTROL/control
	echo "Section: IrDA" 					>>$(OPENOBEX-APPS_IPKG_TMP)/CONTROL/control
	echo "Maintainer: Alexander Chukov <sash@pdaXrom.org>" 	>>$(OPENOBEX-APPS_IPKG_TMP)/CONTROL/control
	echo "Architecture: $(SHORT_TARGET)" 			>>$(OPENOBEX-APPS_IPKG_TMP)/CONTROL/control
	echo "Version: $(OPENOBEX-APPS_VERSION)" 		>>$(OPENOBEX-APPS_IPKG_TMP)/CONTROL/control
	echo "Depends: openobex" 				>>$(OPENOBEX-APPS_IPKG_TMP)/CONTROL/control
	echo "Description: This is the apps that comes with the Open OBEX c-library. These are not meant to be more than test-programs to look at if you want to see how use the library itself.">>$(OPENOBEX-APPS_IPKG_TMP)/CONTROL/control
	cd $(FEEDDIR) && $(XMKIPKG) $(OPENOBEX-APPS_IPKG_TMP)
	touch $@

# ----------------------------------------------------------------------------
# Image-Install
# ----------------------------------------------------------------------------

ifdef PTXCONF_OPENOBEX-APPS_INSTALL
ROMPACKAGES += $(STATEDIR)/openobex-apps.imageinstall
endif

openobex-apps_imageinstall_deps = $(STATEDIR)/openobex-apps.targetinstall \
	$(STATEDIR)/virtual-image.install

$(STATEDIR)/openobex-apps.imageinstall: $(openobex-apps_imageinstall_deps)
	@$(call targetinfo, $@)
	cd $(FEEDDIR) && $(XIPKG) install openobex-apps
	touch $@

# ----------------------------------------------------------------------------
# Clean
# ----------------------------------------------------------------------------

openobex-apps_clean:
	rm -rf $(STATEDIR)/openobex-apps.*
	rm -rf $(OPENOBEX-APPS_DIR)

# vim: syntax=make
