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
ifdef PTXCONF_GD
PACKAGES += gd
endif

#
# Paths and names
#
GD_VENDOR_VERSION	= 1
GD_VERSION		= 2.0.33
GD			= gd-$(GD_VERSION)
GD_SUFFIX		= tar.gz
GD_URL			= http://www.boutell.com/gd/http/$(GD).$(GD_SUFFIX)
GD_SOURCE		= $(SRCDIR)/$(GD).$(GD_SUFFIX)
GD_DIR			= $(BUILDDIR)/$(GD)
GD_IPKG_TMP		= $(GD_DIR)/ipkg_tmp

# ----------------------------------------------------------------------------
# Get
# ----------------------------------------------------------------------------

gd_get: $(STATEDIR)/gd.get

gd_get_deps = $(GD_SOURCE)

$(STATEDIR)/gd.get: $(gd_get_deps)
	@$(call targetinfo, $@)
	@$(call get_patches, $(GD))
	touch $@

$(GD_SOURCE):
	@$(call targetinfo, $@)
	@$(call get, $(GD_URL))

# ----------------------------------------------------------------------------
# Extract
# ----------------------------------------------------------------------------

gd_extract: $(STATEDIR)/gd.extract

gd_extract_deps = $(STATEDIR)/gd.get

$(STATEDIR)/gd.extract: $(gd_extract_deps)
	@$(call targetinfo, $@)
	@$(call clean, $(GD_DIR))
	@$(call extract, $(GD_SOURCE))
	@$(call patchin, $(GD))
	touch $@

# ----------------------------------------------------------------------------
# Prepare
# ----------------------------------------------------------------------------

gd_prepare: $(STATEDIR)/gd.prepare

#
# dependencies
#
gd_prepare_deps = \
	$(STATEDIR)/gd.extract \
	$(STATEDIR)/virtual-xchain.install

GD_PATH	=  PATH=$(CROSS_PATH)
GD_ENV 	=  $(CROSS_ENV)
GD_ENV	+= CFLAGS="$(TARGET_OPT_CFLAGS)"
GD_ENV	+= PKG_CONFIG_PATH=$(CROSS_LIB_DIR)/lib/pkgconfig:$(CROSS_LIB_DIR)/lib/pkgconfig
#ifdef PTXCONF_XFREE430
#GD_ENV	+= LDFLAGS=-Wl,-rpath-link,$(CROSS_LIB_DIR)/lib
#endif

#
# autoconf
#
GD_AUTOCONF = \
	--build=$(GNU_HOST) \
	--host=$(PTXCONF_GNU_TARGET) \
	--prefix=/usr \
	--enable-shared \
	--disable-static

ifdef PTXCONF_XFREE430
GD_AUTOCONF += --x-includes=$(CROSS_LIB_DIR)/include
GD_AUTOCONF += --x-libraries=$(CROSS_LIB_DIR)/lib
endif

$(STATEDIR)/gd.prepare: $(gd_prepare_deps)
	@$(call targetinfo, $@)
	@$(call clean, $(GD_DIR)/config.cache)
	cd $(GD_DIR) && \
		$(GD_PATH) $(GD_ENV) \
		./configure $(GD_AUTOCONF)
	touch $@

# ----------------------------------------------------------------------------
# Compile
# ----------------------------------------------------------------------------

gd_compile: $(STATEDIR)/gd.compile

gd_compile_deps = $(STATEDIR)/gd.prepare

$(STATEDIR)/gd.compile: $(gd_compile_deps)
	@$(call targetinfo, $@)
	$(GD_PATH) $(MAKE) -C $(GD_DIR)
	touch $@

# ----------------------------------------------------------------------------
# Install
# ----------------------------------------------------------------------------

gd_install: $(STATEDIR)/gd.install

$(STATEDIR)/gd.install: $(STATEDIR)/gd.compile
	@$(call targetinfo, $@)
	rm -rf $(GD_IPKG_TMP)
	$(GD_PATH) $(MAKE) -C $(GD_DIR) DESTDIR=$(GD_IPKG_TMP) install
	cp -a  $(GD_IPKG_TMP)/usr/bin/gdlib-config		$(PTXCONF_PREFIX)/bin
	cp -a  $(GD_IPKG_TMP)/usr/include/* 			$(CROSS_LIB_DIR)/include
	cp -a  $(GD_IPKG_TMP)/usr/lib/*     			$(CROSS_LIB_DIR)/lib
	perl -p -i -e "s/\/usr/`echo $(PTXCONF_PREFIX)/$(PTXCONF_GNU_TARGET) | sed -e '/\//s//\\\\\//g'`/g" $(PTXCONF_PREFIX)/bin/gdlib-config
	perl -p -i -e "s/\/usr\/lib/`echo $(PTXCONF_PREFIX)/$(PTXCONF_GNU_TARGET)/lib | sed -e '/\//s//\\\\\//g'`/g" $(PTXCONF_PREFIX)/$(PTXCONF_GNU_TARGET)/lib/libgd.la
	rm -rf $(GD_IPKG_TMP)
	touch $@

# ----------------------------------------------------------------------------
# Target-Install
# ----------------------------------------------------------------------------

gd_targetinstall: $(STATEDIR)/gd.targetinstall

gd_targetinstall_deps = $(STATEDIR)/gd.compile

$(STATEDIR)/gd.targetinstall: $(gd_targetinstall_deps)
	@$(call targetinfo, $@)
	$(GD_PATH) $(MAKE) -C $(GD_DIR) DESTDIR=$(GD_IPKG_TMP) install
	rm -rf $(GD_IPKG_TMP)/usr/bin
	rm -rf $(GD_IPKG_TMP)/usr/include
	rm -rf $(GD_IPKG_TMP)/usr/lib/*.*a
	$(CROSSSTRIP) $(GD_IPKG_TMP)/usr/lib/*
	mkdir -p $(GD_IPKG_TMP)/CONTROL
	echo "Package: libgd" 											 >$(GD_IPKG_TMP)/CONTROL/control
	echo "Priority: optional" 										>>$(GD_IPKG_TMP)/CONTROL/control
	echo "Section: X11"	 										>>$(GD_IPKG_TMP)/CONTROL/control
	echo "Maintainer: Alexander Chukov <sash@pdaXrom.org>" 							>>$(GD_IPKG_TMP)/CONTROL/control
	echo "Architecture: $(SHORT_TARGET)" 									>>$(GD_IPKG_TMP)/CONTROL/control
	echo "Version: $(GD_VERSION)-$(GD_VENDOR_VERSION)"			 				>>$(GD_IPKG_TMP)/CONTROL/control
	echo "Depends: xfree430" 										>>$(GD_IPKG_TMP)/CONTROL/control
	echo "Description: An ANSI C library for the dynamic creation of images. GD creates PNG, JPEG and GIF images, among other formats.">>$(GD_IPKG_TMP)/CONTROL/control
	cd $(FEEDDIR) && $(XMKIPKG) $(GD_IPKG_TMP)
	touch $@

# ----------------------------------------------------------------------------
# Image-Install
# ----------------------------------------------------------------------------

ifdef PTXCONF_GD_INSTALL
ROMPACKAGES += $(STATEDIR)/gd.imageinstall
endif

gd_imageinstall_deps = $(STATEDIR)/gd.targetinstall \
	$(STATEDIR)/virtual-image.install

$(STATEDIR)/gd.imageinstall: $(gd_imageinstall_deps)
	@$(call targetinfo, $@)
	cd $(FEEDDIR) && $(XIPKG) install gd
	touch $@

# ----------------------------------------------------------------------------
# Clean
# ----------------------------------------------------------------------------

gd_clean:
	rm -rf $(STATEDIR)/gd.*
	rm -rf $(GD_DIR)

# vim: syntax=make
