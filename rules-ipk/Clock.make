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
ifdef PTXCONF_CLOCK
PACKAGES += Clock
endif

#
# Paths and names
#
CLOCK_VERSION		= 2.1.0
CLOCK			= Clock-$(CLOCK_VERSION)
CLOCK_SUFFIX		= tar.gz
CLOCK_URL		= http://www.kerofin.demon.co.uk/rox/$(CLOCK).$(CLOCK_SUFFIX)
CLOCK_SOURCE		= $(SRCDIR)/$(CLOCK).$(CLOCK_SUFFIX)
CLOCK_DIR		= $(BUILDDIR)/Clock
CLOCK_IPKG_TMP		= $(CLOCK_DIR)-ipkg_tmp

# ----------------------------------------------------------------------------
# Get
# ----------------------------------------------------------------------------

Clock_get: $(STATEDIR)/Clock.get

Clock_get_deps = $(CLOCK_SOURCE)

$(STATEDIR)/Clock.get: $(Clock_get_deps)
	@$(call targetinfo, $@)
	@$(call get_patches, $(CLOCK))
	touch $@

$(CLOCK_SOURCE):
	@$(call targetinfo, $@)
	@$(call get, $(CLOCK_URL))

# ----------------------------------------------------------------------------
# Extract
# ----------------------------------------------------------------------------

Clock_extract: $(STATEDIR)/Clock.extract

Clock_extract_deps = $(STATEDIR)/Clock.get

$(STATEDIR)/Clock.extract: $(Clock_extract_deps)
	@$(call targetinfo, $@)
	@$(call clean, $(CLOCK_DIR))
	@$(call extract, $(CLOCK_SOURCE))
	@$(call patchin, $(CLOCK), $(CLOCK_DIR))
	touch $@

# ----------------------------------------------------------------------------
# Prepare
# ----------------------------------------------------------------------------

Clock_prepare: $(STATEDIR)/Clock.prepare

#
# dependencies
#
Clock_prepare_deps = \
	$(STATEDIR)/Clock.extract \
	$(STATEDIR)/ROX-CLib.install \
	$(STATEDIR)/virtual-xchain.install

CLOCK_PATH	=  PATH=$(CROSS_PATH)
CLOCK_ENV 	=  $(CROSS_ENV)
CLOCK_ENV	+= CFLAGS="-O2 -fomit-frame-pointer"
CLOCK_ENV	+= PKG_CONFIG_PATH=$(CROSS_LIB_DIR)/lib/pkgconfig:$(CROSS_LIB_DIR)/lib/pkgconfig
#ifdef PTXCONF_XFREE430
#CLOCK_ENV	+= LDFLAGS=-Wl,-rpath-link,$(CROSS_LIB_DIR)/lib
#endif

#
# autoconf
#
CLOCK_AUTOCONF = \
	--build=$(GNU_HOST) \
	--host=$(PTXCONF_GNU_TARGET) \
	--disable-debug \
	--with-platform=Linux-$(PTXCONF_ARCH)

ifdef PTXCONF_XFREE430
CLOCK_AUTOCONF += --x-includes=$(CROSS_LIB_DIR)/include
CLOCK_AUTOCONF += --x-libraries=$(CROSS_LIB_DIR)/lib
endif

$(STATEDIR)/Clock.prepare: $(Clock_prepare_deps)
	@$(call targetinfo, $@)
	@$(call clean, $(CLOCK_DIR)/config.cache)
	cd $(CLOCK_DIR)/src && $(PTXCONF_PREFIX)/bin/autoconf
	cd $(CLOCK_DIR)/src && \
		$(CLOCK_PATH) $(CLOCK_ENV) \
		./configure $(CLOCK_AUTOCONF)
	touch $@

# ----------------------------------------------------------------------------
# Compile
# ----------------------------------------------------------------------------

Clock_compile: $(STATEDIR)/Clock.compile

Clock_compile_deps = $(STATEDIR)/Clock.prepare

$(STATEDIR)/Clock.compile: $(Clock_compile_deps)
	@$(call targetinfo, $@)
	$(CLOCK_PATH) $(CLOCK_ENV) $(MAKE) -C $(CLOCK_DIR)/src
	touch $@

# ----------------------------------------------------------------------------
# Install
# ----------------------------------------------------------------------------

Clock_install: $(STATEDIR)/Clock.install

$(STATEDIR)/Clock.install: $(STATEDIR)/Clock.compile
	@$(call targetinfo, $@)
	touch $@

# ----------------------------------------------------------------------------
# Target-Install
# ----------------------------------------------------------------------------

Clock_targetinstall: $(STATEDIR)/Clock.targetinstall

Clock_targetinstall_deps = $(STATEDIR)/Clock.compile \
	$(STATEDIR)/ROX-CLib.targetinstall

$(STATEDIR)/Clock.targetinstall: $(Clock_targetinstall_deps)
	@$(call targetinfo, $@)
	rm -rf $(CLOCK_IPKG_TMP)
	mkdir -p $(CLOCK_IPKG_TMP)/usr/apps
	cp -a $(CLOCK_DIR) $(CLOCK_IPKG_TMP)/usr/apps
	rm -rf $(CLOCK_IPKG_TMP)/usr/apps/Clock/src
	$(CROSSSTRIP) $(CLOCK_IPKG_TMP)/usr/apps/Clock/Linux-$(PTXCONF_ARCH)/*
	mkdir -p $(CLOCK_IPKG_TMP)/CONTROL
	echo "Package: clock" 				>$(CLOCK_IPKG_TMP)/CONTROL/control
	echo "Priority: optional" 			>>$(CLOCK_IPKG_TMP)/CONTROL/control
	echo "Section: ROX" 				>>$(CLOCK_IPKG_TMP)/CONTROL/control
	echo "Maintainer: Alexander Chukov <sash@pdaXrom.org>">>$(CLOCK_IPKG_TMP)/CONTROL/control
	echo "Architecture: $(SHORT_TARGET)" 		>>$(CLOCK_IPKG_TMP)/CONTROL/control
	echo "Version: $(CLOCK_VERSION)" 		>>$(CLOCK_IPKG_TMP)/CONTROL/control
	echo "Depends: rox, rox-clib" 			>>$(CLOCK_IPKG_TMP)/CONTROL/control
	echo "Description: Display the time."		>>$(CLOCK_IPKG_TMP)/CONTROL/control
	cd $(FEEDDIR) && $(XMKIPKG) $(CLOCK_IPKG_TMP)
	rm -rf $(CLOCK_IPKG_TMP)
	touch $@

# ----------------------------------------------------------------------------
# Image-Install
# ----------------------------------------------------------------------------

ifdef PTXCONF_CLOCK_INSTALL
ROMPACKAGES += $(STATEDIR)/Clock.imageinstall
endif

Clock_imageinstall_deps = $(STATEDIR)/Clock.targetinstall \
	$(STATEDIR)/virtual-image.install

$(STATEDIR)/Clock.imageinstall: $(Clock_imageinstall_deps)
	@$(call targetinfo, $@)
	cd $(FEEDDIR) && $(XIPKG) install clock
	touch $@

# ----------------------------------------------------------------------------
# Clean
# ----------------------------------------------------------------------------

Clock_clean:
	rm -rf $(STATEDIR)/Clock.*
	rm -rf $(CLOCK_DIR)

# vim: syntax=make
