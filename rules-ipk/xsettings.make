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
ifdef PTXCONF_XSETTINGS
PACKAGES += xsettings
endif

#
# Paths and names
#
XSETTINGS_VENDOR_VERSION	= 1
XSETTINGS_VERSION		= 0.2
XSETTINGS			= xsettings-$(XSETTINGS_VERSION)
XSETTINGS_SUFFIX		= tar.gz
XSETTINGS_URL			= http://www.freedesktop.org/software/xsettings/releases/$(XSETTINGS).$(XSETTINGS_SUFFIX)
XSETTINGS_SOURCE		= $(SRCDIR)/$(XSETTINGS).$(XSETTINGS_SUFFIX)
XSETTINGS_DIR			= $(BUILDDIR)/$(XSETTINGS)
XSETTINGS_IPKG_TMP		= $(XSETTINGS_DIR)/ipkg_tmp

# ----------------------------------------------------------------------------
# Get
# ----------------------------------------------------------------------------

xsettings_get: $(STATEDIR)/xsettings.get

xsettings_get_deps = $(XSETTINGS_SOURCE)

$(STATEDIR)/xsettings.get: $(xsettings_get_deps)
	@$(call targetinfo, $@)
	@$(call get_patches, $(XSETTINGS))
	touch $@

$(XSETTINGS_SOURCE):
	@$(call targetinfo, $@)
	@$(call get, $(XSETTINGS_URL))

# ----------------------------------------------------------------------------
# Extract
# ----------------------------------------------------------------------------

xsettings_extract: $(STATEDIR)/xsettings.extract

xsettings_extract_deps = $(STATEDIR)/xsettings.get

$(STATEDIR)/xsettings.extract: $(xsettings_extract_deps)
	@$(call targetinfo, $@)
	@$(call clean, $(XSETTINGS_DIR))
	@$(call extract, $(XSETTINGS_SOURCE))
	@$(call patchin, $(XSETTINGS))
	touch $@

# ----------------------------------------------------------------------------
# Prepare
# ----------------------------------------------------------------------------

xsettings_prepare: $(STATEDIR)/xsettings.prepare

#
# dependencies
#
xsettings_prepare_deps = \
	$(STATEDIR)/xsettings.extract \
	$(STATEDIR)/virtual-xchain.install

XSETTINGS_PATH	=  PATH=$(CROSS_PATH)
XSETTINGS_ENV 	=  $(CROSS_ENV)
#XSETTINGS_ENV	+=
XSETTINGS_ENV	+= PKG_CONFIG_PATH=$(CROSS_LIB_DIR)/lib/pkgconfig
#ifdef PTXCONF_XFREE430
#XSETTINGS_ENV	+= LDFLAGS=-Wl,-rpath-link,$(CROSS_LIB_DIR)/X11R6/lib
#endif

#
# autoconf
#
XSETTINGS_AUTOCONF = \
	--build=$(GNU_HOST) \
	--host=$(PTXCONF_GNU_TARGET) \
	--prefix=/usr

ifdef PTXCONF_XFREE430
XSETTINGS_AUTOCONF += --x-includes=$(CROSS_LIB_DIR)/include
XSETTINGS_AUTOCONF += --x-libraries=$(CROSS_LIB_DIR)/lib
endif

$(STATEDIR)/xsettings.prepare: $(xsettings_prepare_deps)
	@$(call targetinfo, $@)
	@$(call clean, $(XSETTINGS_DIR)/config.cache)
	cd $(XSETTINGS_DIR) && \
		$(XSETTINGS_PATH) $(XSETTINGS_ENV) \
		./configure $(XSETTINGS_AUTOCONF)
	touch $@

# ----------------------------------------------------------------------------
# Compile
# ----------------------------------------------------------------------------

xsettings_compile: $(STATEDIR)/xsettings.compile

xsettings_compile_deps = $(STATEDIR)/xsettings.prepare

$(STATEDIR)/xsettings.compile: $(xsettings_compile_deps)
	@$(call targetinfo, $@)
	$(XSETTINGS_PATH) $(MAKE) -C $(XSETTINGS_DIR)
	touch $@

# ----------------------------------------------------------------------------
# Install
# ----------------------------------------------------------------------------

xsettings_install: $(STATEDIR)/xsettings.install

$(STATEDIR)/xsettings.install: $(STATEDIR)/xsettings.compile
	@$(call targetinfo, $@)
	rm -rf $(XSETTINGS_IPKG_TMP)
	$(XSETTINGS_PATH) $(MAKE) -C $(XSETTINGS_DIR) DESTDIR=$(XSETTINGS_IPKG_TMP) install
	asasd
	rm -rf $(XSETTINGS_IPKG_TMP)
	touch $@

# ----------------------------------------------------------------------------
# Target-Install
# ----------------------------------------------------------------------------

xsettings_targetinstall: $(STATEDIR)/xsettings.targetinstall

xsettings_targetinstall_deps = $(STATEDIR)/xsettings.compile

$(STATEDIR)/xsettings.targetinstall: $(xsettings_targetinstall_deps)
	@$(call targetinfo, $@)
	$(XSETTINGS_PATH) $(MAKE) -C $(XSETTINGS_DIR) DESTDIR=$(XSETTINGS_IPKG_TMP) install
	mkdir -p $(XSETTINGS_IPKG_TMP)/CONTROL
	echo "Package: xsettings" 										 >$(XSETTINGS_IPKG_TMP)/CONTROL/control
	echo "Priority: optional" 										>>$(XSETTINGS_IPKG_TMP)/CONTROL/control
	echo "Section: X11"	 										>>$(XSETTINGS_IPKG_TMP)/CONTROL/control
	echo "Maintainer: Alexander Chukov <sash@pdaXrom.org>" 							>>$(XSETTINGS_IPKG_TMP)/CONTROL/control
	echo "Architecture: $(SHORT_TARGET)" 									>>$(XSETTINGS_IPKG_TMP)/CONTROL/control
	echo "Version: $(XSETTINGS_VERSION)-$(XSETTINGS_VENDOR_VERSION)" 					>>$(XSETTINGS_IPKG_TMP)/CONTROL/control
	echo "Depends: xfree430" 										>>$(XSETTINGS_IPKG_TMP)/CONTROL/control
	echo "Description: xsettings contains a reference implementation of the xsettings specification."	>>$(XSETTINGS_IPKG_TMP)/CONTROL/control
	asdasd
	cd $(FEEDDIR) && $(XMKIPKG) $(XSETTINGS_IPKG_TMP)
	touch $@

# ----------------------------------------------------------------------------
# Image-Install
# ----------------------------------------------------------------------------

ifdef PTXCONF_XSETTINGS_INSTALL
ROMPACKAGES += $(STATEDIR)/xsettings.imageinstall
endif

xsettings_imageinstall_deps = $(STATEDIR)/xsettings.targetinstall \
	$(STATEDIR)/virtual-image.install

$(STATEDIR)/xsettings.imageinstall: $(xsettings_imageinstall_deps)
	@$(call targetinfo, $@)
	cd $(FEEDDIR) && $(XIPKG) install xsettings
	touch $@

# ----------------------------------------------------------------------------
# Clean
# ----------------------------------------------------------------------------

xsettings_clean:
	rm -rf $(STATEDIR)/xsettings.*
	rm -rf $(XSETTINGS_DIR)

# vim: syntax=make
