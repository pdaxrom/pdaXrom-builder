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
ifdef PTXCONF_BTSCANNER
PACKAGES += btscanner
endif

#
# Paths and names
#
BTSCANNER_VERSION		= 1.0
BTSCANNER			= btscanner-$(BTSCANNER_VERSION)
BTSCANNER_SUFFIX		= tar.gz
BTSCANNER_URL			= http://www.pentest.co.uk/src/$(BTSCANNER).$(BTSCANNER_SUFFIX)
BTSCANNER_SOURCE		= $(SRCDIR)/$(BTSCANNER).$(BTSCANNER_SUFFIX)
BTSCANNER_DIR			= $(BUILDDIR)/$(BTSCANNER)
BTSCANNER_IPKG_TMP		= $(BTSCANNER_DIR)/ipkg_tmp

# ----------------------------------------------------------------------------
# Get
# ----------------------------------------------------------------------------

btscanner_get: $(STATEDIR)/btscanner.get

btscanner_get_deps = $(BTSCANNER_SOURCE)

$(STATEDIR)/btscanner.get: $(btscanner_get_deps)
	@$(call targetinfo, $@)
	@$(call get_patches, $(BTSCANNER))
	touch $@

$(BTSCANNER_SOURCE):
	@$(call targetinfo, $@)
	@$(call get, $(BTSCANNER_URL))

# ----------------------------------------------------------------------------
# Extract
# ----------------------------------------------------------------------------

btscanner_extract: $(STATEDIR)/btscanner.extract

btscanner_extract_deps = $(STATEDIR)/btscanner.get

$(STATEDIR)/btscanner.extract: $(btscanner_extract_deps)
	@$(call targetinfo, $@)
	@$(call clean, $(BTSCANNER_DIR))
	@$(call extract, $(BTSCANNER_SOURCE))
	@$(call patchin, $(BTSCANNER))
	touch $@

# ----------------------------------------------------------------------------
# Prepare
# ----------------------------------------------------------------------------

btscanner_prepare: $(STATEDIR)/btscanner.prepare

#
# dependencies
#
btscanner_prepare_deps = \
	$(STATEDIR)/btscanner.extract \
	$(STATEDIR)/ncurses.install \
	$(STATEDIR)/bluez-libs.install \
	$(STATEDIR)/bluez-sdp.install \
	$(STATEDIR)/gdbm.install \
	$(STATEDIR)/virtual-xchain.install

BTSCANNER_PATH	=  PATH=$(CROSS_PATH)
BTSCANNER_ENV 	=  $(CROSS_ENV)
BTSCANNER_ENV	+= CFLAGS="-O2 -fomit-frame-pointer"
BTSCANNER_ENV	+= PKG_CONFIG_PATH=$(CROSS_LIB_DIR)/lib/pkgconfig:$(CROSS_LIB_DIR)/lib/pkgconfig
#ifdef PTXCONF_XFREE430
#BTSCANNER_ENV	+= LDFLAGS=-Wl,-rpath-link,$(CROSS_LIB_DIR)/lib
#endif

#
# autoconf
#
BTSCANNER_AUTOCONF = \
	--build=$(GNU_HOST) \
	--host=$(PTXCONF_GNU_TARGET) \
	--prefix=/usr

ifdef PTXCONF_XFREE430
BTSCANNER_AUTOCONF += --x-includes=$(CROSS_LIB_DIR)/include
BTSCANNER_AUTOCONF += --x-libraries=$(CROSS_LIB_DIR)/lib
endif

$(STATEDIR)/btscanner.prepare: $(btscanner_prepare_deps)
	@$(call targetinfo, $@)
	@$(call clean, $(BTSCANNER_DIR)/config.cache)
	cd $(BTSCANNER_DIR) && \
		$(BTSCANNER_PATH) $(BTSCANNER_ENV) \
		./configure $(BTSCANNER_AUTOCONF)
	touch $@

# ----------------------------------------------------------------------------
# Compile
# ----------------------------------------------------------------------------

btscanner_compile: $(STATEDIR)/btscanner.compile

btscanner_compile_deps = $(STATEDIR)/btscanner.prepare

$(STATEDIR)/btscanner.compile: $(btscanner_compile_deps)
	@$(call targetinfo, $@)
	$(BTSCANNER_PATH) $(MAKE) -C $(BTSCANNER_DIR)
	touch $@

# ----------------------------------------------------------------------------
# Install
# ----------------------------------------------------------------------------

btscanner_install: $(STATEDIR)/btscanner.install

$(STATEDIR)/btscanner.install: $(STATEDIR)/btscanner.compile
	@$(call targetinfo, $@)
	touch $@

# ----------------------------------------------------------------------------
# Target-Install
# ----------------------------------------------------------------------------

btscanner_targetinstall: $(STATEDIR)/btscanner.targetinstall

btscanner_targetinstall_deps = $(STATEDIR)/btscanner.compile \
	$(STATEDIR)/ncurses.targetinstall \
	$(STATEDIR)/bluez-libs.targetinstall \
	$(STATEDIR)/bluez-sdp.targetinstall \
	$(STATEDIR)/gdbm.targetinstall

$(STATEDIR)/btscanner.targetinstall: $(btscanner_targetinstall_deps)
	@$(call targetinfo, $@)
	$(BTSCANNER_PATH) $(MAKE) -C $(BTSCANNER_DIR) DESTDIR=$(BTSCANNER_IPKG_TMP) install
	$(CROSSSTRIP) $(BTSCANNER_IPKG_TMP)/usr/bin/*
	mkdir -p $(BTSCANNER_IPKG_TMP)/CONTROL
	echo "Package: btscanner" 					>$(BTSCANNER_IPKG_TMP)/CONTROL/control
	echo "Priority: optional" 					>>$(BTSCANNER_IPKG_TMP)/CONTROL/control
	echo "Section: pdaXrom" 					>>$(BTSCANNER_IPKG_TMP)/CONTROL/control
	echo "Maintainer: Alexander Chukov <sash@pdaXrom.org>" 		>>$(BTSCANNER_IPKG_TMP)/CONTROL/control
	echo "Architecture: $(SHORT_TARGET)" 				>>$(BTSCANNER_IPKG_TMP)/CONTROL/control
	echo "Version: $(BTSCANNER_VERSION)" 				>>$(BTSCANNER_IPKG_TMP)/CONTROL/control
	echo "Depends: bluez-libs, bluez-sdp, gdbm, ncurses" 		>>$(BTSCANNER_IPKG_TMP)/CONTROL/control
	echo "Description: Displays the output of Bluetooth scans"	>>$(BTSCANNER_IPKG_TMP)/CONTROL/control
	cd $(FEEDDIR) && $(XMKIPKG) $(BTSCANNER_IPKG_TMP)
	touch $@

# ----------------------------------------------------------------------------
# Image-Install
# ----------------------------------------------------------------------------

ifdef PTXCONF_BTSCANNER_INSTALL
ROMPACKAGES += $(STATEDIR)/btscanner.imageinstall
endif

btscanner_imageinstall_deps = $(STATEDIR)/btscanner.targetinstall \
	$(STATEDIR)/virtual-image.install

$(STATEDIR)/btscanner.imageinstall: $(btscanner_imageinstall_deps)
	@$(call targetinfo, $@)
	cd $(FEEDDIR) && $(XIPKG) install btscanner
	touch $@

# ----------------------------------------------------------------------------
# Clean
# ----------------------------------------------------------------------------

btscanner_clean:
	rm -rf $(STATEDIR)/btscanner.*
	rm -rf $(BTSCANNER_DIR)

# vim: syntax=make
