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
ifdef PTXCONF_DDD
PACKAGES += ddd
endif

#
# Paths and names
#
DDD_VENDOR_VERSION	= 1
DDD_VERSION		= 3.3.10
DDD			= ddd-$(DDD_VERSION)
DDD_SUFFIX		= tar.gz
DDD_URL			= http://unc.dl.sourceforge.net/sourceforge/ddd/$(DDD).$(DDD_SUFFIX)
DDD_SOURCE		= $(SRCDIR)/$(DDD).$(DDD_SUFFIX)
DDD_DIR			= $(BUILDDIR)/$(DDD)
DDD_IPKG_TMP		= $(DDD_DIR)/ipkg_tmp

# ----------------------------------------------------------------------------
# Get
# ----------------------------------------------------------------------------

ddd_get: $(STATEDIR)/ddd.get

ddd_get_deps = $(DDD_SOURCE)

$(STATEDIR)/ddd.get: $(ddd_get_deps)
	@$(call targetinfo, $@)
	@$(call get_patches, $(DDD))
	touch $@

$(DDD_SOURCE):
	@$(call targetinfo, $@)
	@$(call get, $(DDD_URL))

# ----------------------------------------------------------------------------
# Extract
# ----------------------------------------------------------------------------

ddd_extract: $(STATEDIR)/ddd.extract

ddd_extract_deps = $(STATEDIR)/ddd.get

$(STATEDIR)/ddd.extract: $(ddd_extract_deps)
	@$(call targetinfo, $@)
	@$(call clean, $(DDD_DIR))
	@$(call extract, $(DDD_SOURCE))
	@$(call patchin, $(DDD))
	touch $@

# ----------------------------------------------------------------------------
# Prepare
# ----------------------------------------------------------------------------

ddd_prepare: $(STATEDIR)/ddd.prepare

#
# dependencies
#
ddd_prepare_deps = \
	$(STATEDIR)/ddd.extract \
	$(STATEDIR)/xfree430.install \
	$(STATEDIR)/lesstif.install \
	$(STATEDIR)/virtual-xchain.install

DDD_PATH	=  PATH=$(CROSS_PATH)
DDD_ENV 	=  $(CROSS_ENV)
DDD_ENV		+= CFLAGS="$(TARGET_OPT_CFLAGS)"
DDD_ENV		+= CXXFLAGS="$(TARGET_OPT_CFLAGS)"
###" -fno-rtti -fno-exceptions"
DDD_ENV		+= PKG_CONFIG_PATH=$(CROSS_LIB_DIR)/lib/pkgconfig:$(CROSS_LIB_DIR)/lib/pkgconfig
#ifdef PTXCONF_XFREE430
#DDD_ENV		+= LDFLAGS=-Wl,-rpath-link,$(CROSS_LIB_DIR)/lib
#endif

#
# autoconf
#
DDD_AUTOCONF = \
	--build=$(GNU_HOST) \
	--host=$(PTXCONF_GNU_TARGET) \
	--prefix=/usr \
	--disable-debug

ifdef PTXCONF_XFREE430
DDD_AUTOCONF += --x-includes=$(CROSS_LIB_DIR)/include
DDD_AUTOCONF += --x-libraries=$(CROSS_LIB_DIR)/lib
endif

$(STATEDIR)/ddd.prepare: $(ddd_prepare_deps)
	@$(call targetinfo, $@)
	@$(call clean, $(DDD_DIR)/config.cache)
	cd $(DDD_DIR) && \
		$(DDD_PATH) $(DDD_ENV) \
		./configure $(DDD_AUTOCONF)
	touch $@

# ----------------------------------------------------------------------------
# Compile
# ----------------------------------------------------------------------------

ddd_compile: $(STATEDIR)/ddd.compile

ddd_compile_deps = $(STATEDIR)/ddd.prepare

$(STATEDIR)/ddd.compile: $(ddd_compile_deps)
	@$(call targetinfo, $@)
	$(DDD_PATH) $(MAKE) -C $(DDD_DIR)
	touch $@

# ----------------------------------------------------------------------------
# Install
# ----------------------------------------------------------------------------

ddd_install: $(STATEDIR)/ddd.install

$(STATEDIR)/ddd.install: $(STATEDIR)/ddd.compile
	@$(call targetinfo, $@)
	$(DDD_PATH) $(MAKE) -C $(DDD_DIR) install
	touch $@

# ----------------------------------------------------------------------------
# Target-Install
# ----------------------------------------------------------------------------

ddd_targetinstall: $(STATEDIR)/ddd.targetinstall

ddd_targetinstall_deps = $(STATEDIR)/ddd.compile \
	$(STATEDIR)/xfree430.targetinstall \
	$(STATEDIR)/lesstif.targetinstall

$(STATEDIR)/ddd.targetinstall: $(ddd_targetinstall_deps)
	@$(call targetinfo, $@)
	$(DDD_PATH) $(MAKE) -C $(DDD_DIR) DESTDIR=$(DDD_IPKG_TMP) install
	$(CROSSSTRIP) $(DDD_IPKG_TMP)/usr/bin/*
	rm -rf $(DDD_IPKG_TMP)/usr/info
	rm -rf $(DDD_IPKG_TMP)/usr/man
	mkdir -p $(DDD_IPKG_TMP)/usr/share/applications
	mkdir -p $(DDD_IPKG_TMP)/usr/share/pixmaps
	cp -f $(DDD_DIR)/icons/ddd.xpm		$(DDD_IPKG_TMP)/usr/share/pixmaps/
	cp -f $(TOPDIR)/config/pics/ddd.desktop	$(DDD_IPKG_TMP)/usr/share/applications/
	mkdir -p $(DDD_IPKG_TMP)/CONTROL
	echo "Package: ddd" 								 >$(DDD_IPKG_TMP)/CONTROL/control
	echo "Priority: optional" 							>>$(DDD_IPKG_TMP)/CONTROL/control
	echo "Section: Development" 							>>$(DDD_IPKG_TMP)/CONTROL/control
	echo "Maintainer: Alexander Chukov <sash@pdaXrom.org>" 				>>$(DDD_IPKG_TMP)/CONTROL/control
	echo "Architecture: $(SHORT_TARGET)" 						>>$(DDD_IPKG_TMP)/CONTROL/control
	echo "Version: $(DDD_VERSION)-$(DDD_VENDOR_VERSION)" 				>>$(DDD_IPKG_TMP)/CONTROL/control
	echo "Depends: lesstif" 							>>$(DDD_IPKG_TMP)/CONTROL/control
	echo "Description: Data display debugger"					>>$(DDD_IPKG_TMP)/CONTROL/control
	cd $(FEEDDIR) && $(XMKIPKG) $(DDD_IPKG_TMP)
	touch $@

# ----------------------------------------------------------------------------
# Image-Install
# ----------------------------------------------------------------------------

ifdef PTXCONF_DDD_INSTALL
ROMPACKAGES += $(STATEDIR)/ddd.imageinstall
endif

ddd_imageinstall_deps = $(STATEDIR)/ddd.targetinstall \
	$(STATEDIR)/virtual-image.install

$(STATEDIR)/ddd.imageinstall: $(ddd_imageinstall_deps)
	@$(call targetinfo, $@)
	cd $(FEEDDIR) && $(XIPKG) install ddd
	touch $@

# ----------------------------------------------------------------------------
# Clean
# ----------------------------------------------------------------------------

ddd_clean:
	rm -rf $(STATEDIR)/ddd.*
	rm -rf $(DDD_DIR)

# vim: syntax=make
