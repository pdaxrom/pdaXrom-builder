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
ifdef PTXCONF_XKEYMOUSE
PACKAGES += xkeymouse
endif

#
# Paths and names
#
XKEYMOUSE_VERSION	= 0.1
XKEYMOUSE		= xkeymouse-$(XKEYMOUSE_VERSION)
XKEYMOUSE_SUFFIX	= tar.gz
XKEYMOUSE_URL		= http://keihanna.dl.sourceforge.net/sourceforge/xkeymouse/$(XKEYMOUSE).$(XKEYMOUSE_SUFFIX)
XKEYMOUSE_SOURCE	= $(SRCDIR)/$(XKEYMOUSE).$(XKEYMOUSE_SUFFIX)
XKEYMOUSE_DIR		= $(BUILDDIR)/$(XKEYMOUSE)
XKEYMOUSE_IPKG_TMP	= $(XKEYMOUSE_DIR)/ipkg_tmp

# ----------------------------------------------------------------------------
# Get
# ----------------------------------------------------------------------------

xkeymouse_get: $(STATEDIR)/xkeymouse.get

xkeymouse_get_deps = $(XKEYMOUSE_SOURCE)

$(STATEDIR)/xkeymouse.get: $(xkeymouse_get_deps)
	@$(call targetinfo, $@)
	@$(call get_patches, $(XKEYMOUSE))
	touch $@

$(XKEYMOUSE_SOURCE):
	@$(call targetinfo, $@)
	@$(call get, $(XKEYMOUSE_URL))

# ----------------------------------------------------------------------------
# Extract
# ----------------------------------------------------------------------------

xkeymouse_extract: $(STATEDIR)/xkeymouse.extract

xkeymouse_extract_deps = $(STATEDIR)/xkeymouse.get

$(STATEDIR)/xkeymouse.extract: $(xkeymouse_extract_deps)
	@$(call targetinfo, $@)
	@$(call clean, $(XKEYMOUSE_DIR))
	@$(call extract, $(XKEYMOUSE_SOURCE))
	@$(call patchin, $(XKEYMOUSE))
	touch $@

# ----------------------------------------------------------------------------
# Prepare
# ----------------------------------------------------------------------------

xkeymouse_prepare: $(STATEDIR)/xkeymouse.prepare

#
# dependencies
#
xkeymouse_prepare_deps = \
	$(STATEDIR)/xkeymouse.extract \
	$(STATEDIR)/xfree430.install \
	$(STATEDIR)/virtual-xchain.install

XKEYMOUSE_PATH	=  PATH=$(CROSS_PATH)
XKEYMOUSE_ENV 	=  $(CROSS_ENV)
XKEYMOUSE_ENV	+= CFLAGS="-O2 -fomit-frame-pointer"
XKEYMOUSE_ENV	+= PKG_CONFIG_PATH=$(CROSS_LIB_DIR)/lib/pkgconfig:$(CROSS_LIB_DIR)/lib/pkgconfig
#ifdef PTXCONF_XFREE430
#XKEYMOUSE_ENV	+= LDFLAGS=-Wl,-rpath-link,$(CROSS_LIB_DIR)/lib
#endif

#
# autoconf
#
XKEYMOUSE_AUTOCONF = \
	--build=$(GNU_HOST) \
	--host=$(PTXCONF_GNU_TARGET) \
	--prefix=/usr \
	--sysconfdir=/etc \
	--disable-debug

ifdef PTXCONF_XFREE430
XKEYMOUSE_AUTOCONF += --x-includes=$(CROSS_LIB_DIR)/include
XKEYMOUSE_AUTOCONF += --x-libraries=$(CROSS_LIB_DIR)/lib
endif

$(STATEDIR)/xkeymouse.prepare: $(xkeymouse_prepare_deps)
	@$(call targetinfo, $@)
	@$(call clean, $(XKEYMOUSE_DIR)/config.cache)
	cd $(XKEYMOUSE_DIR) && \
		$(XKEYMOUSE_PATH) $(XKEYMOUSE_ENV) \
		./configure $(XKEYMOUSE_AUTOCONF)
	touch $@

# ----------------------------------------------------------------------------
# Compile
# ----------------------------------------------------------------------------

xkeymouse_compile: $(STATEDIR)/xkeymouse.compile

xkeymouse_compile_deps = $(STATEDIR)/xkeymouse.prepare

$(STATEDIR)/xkeymouse.compile: $(xkeymouse_compile_deps)
	@$(call targetinfo, $@)
	$(XKEYMOUSE_PATH) $(MAKE) -C $(XKEYMOUSE_DIR) CFLAGS="-O2 -fomit-frame-pointer"
	touch $@

# ----------------------------------------------------------------------------
# Install
# ----------------------------------------------------------------------------

xkeymouse_install: $(STATEDIR)/xkeymouse.install

$(STATEDIR)/xkeymouse.install: $(STATEDIR)/xkeymouse.compile
	@$(call targetinfo, $@)
	touch $@

# ----------------------------------------------------------------------------
# Target-Install
# ----------------------------------------------------------------------------

xkeymouse_targetinstall: $(STATEDIR)/xkeymouse.targetinstall

xkeymouse_targetinstall_deps = $(STATEDIR)/xkeymouse.compile

$(STATEDIR)/xkeymouse.targetinstall: $(xkeymouse_targetinstall_deps)
	@$(call targetinfo, $@)
	$(XKEYMOUSE_PATH) $(MAKE) -C $(XKEYMOUSE_DIR) DESTDIR=$(XKEYMOUSE_IPKG_TMP) install
	$(CROSSSTRIP) $(XKEYMOUSE_IPKG_TMP)/usr/bin/*
	mkdir -p $(XKEYMOUSE_IPKG_TMP)/etc
	cp -a $(TOPDIR)/config/pdaXrom/xkmc $(XKEYMOUSE_IPKG_TMP)/etc
	mkdir -p $(XKEYMOUSE_IPKG_TMP)/CONTROL
	echo "Package: xkeymouse" 			>$(XKEYMOUSE_IPKG_TMP)/CONTROL/control
	echo "Priority: optional" 			>>$(XKEYMOUSE_IPKG_TMP)/CONTROL/control
	echo "Section: X11"	 			>>$(XKEYMOUSE_IPKG_TMP)/CONTROL/control
	echo "Maintainer: Alexander Chukov <sash@pdaXrom.org>">>$(XKEYMOUSE_IPKG_TMP)/CONTROL/control
	echo "Architecture: $(SHORT_TARGET)" 		>>$(XKEYMOUSE_IPKG_TMP)/CONTROL/control
	echo "Version: $(XKEYMOUSE_VERSION)" 		>>$(XKEYMOUSE_IPKG_TMP)/CONTROL/control
	echo "Depends: xfree430" 			>>$(XKEYMOUSE_IPKG_TMP)/CONTROL/control
	echo "Description:  xkeymouse maps keyboard events">>$(XKEYMOUSE_IPKG_TMP)/CONTROL/control
	cd $(FEEDDIR) && $(XMKIPKG) $(XKEYMOUSE_IPKG_TMP)
	touch $@

# ----------------------------------------------------------------------------
# Image-Install
# ----------------------------------------------------------------------------

ifdef PTXCONF_XKEYMOUSE_INSTALL
ROMPACKAGES += $(STATEDIR)/xkeymouse.imageinstall
endif

xkeymouse_imageinstall_deps = $(STATEDIR)/xkeymouse.targetinstall \
	$(STATEDIR)/virtual-image.install

$(STATEDIR)/xkeymouse.imageinstall: $(xkeymouse_imageinstall_deps)
	@$(call targetinfo, $@)
	cd $(FEEDDIR) && $(XIPKG) install xkeymouse
	touch $@

# ----------------------------------------------------------------------------
# Clean
# ----------------------------------------------------------------------------

xkeymouse_clean:
	rm -rf $(STATEDIR)/xkeymouse.*
	rm -rf $(XKEYMOUSE_DIR)

# vim: syntax=make
