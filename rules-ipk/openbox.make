# -*-makefile-*-
# $Id: template,v 1.10 2004/01/24 15:50:34 mkl Exp $
#
# Copyright (C) 2004 by Alexander Chukov <sash@cacko.biz>
#          
# See CREDITS for details about who has contributed to this project.
#
# For further information about the PTXdist project and license conditions
# see the README file.
#

#
# We provide this package
#
ifdef PTXCONF_OPENBOX
PACKAGES += openbox
endif

#
# Paths and names
#
OPENBOX_VENDOR_VERSION	= 4
OPENBOX_VERSION		= 3.2
OPENBOX			= openbox-$(OPENBOX_VERSION)
OPENBOX_SUFFIX		= tar.gz
OPENBOX_URL		= http://icculus.org/openbox/releases/$(OPENBOX).$(OPENBOX_SUFFIX)
OPENBOX_SOURCE		= $(SRCDIR)/$(OPENBOX).$(OPENBOX_SUFFIX)
OPENBOX_DIR		= $(BUILDDIR)/$(OPENBOX)
OPENBOX_IPKG_TMP	= $(OPENBOX_DIR)/ipkg_tmp

# ----------------------------------------------------------------------------
# Get
# ----------------------------------------------------------------------------

openbox_get: $(STATEDIR)/openbox.get

openbox_get_deps = $(OPENBOX_SOURCE)

$(STATEDIR)/openbox.get: $(openbox_get_deps)
	@$(call targetinfo, $@)
	@$(call get_patches, $(OPENBOX))
	touch $@

$(OPENBOX_SOURCE):
	@$(call targetinfo, $@)
	@$(call get, $(OPENBOX_URL))

# ----------------------------------------------------------------------------
# Extract
# ----------------------------------------------------------------------------

openbox_extract: $(STATEDIR)/openbox.extract

openbox_extract_deps = $(STATEDIR)/openbox.get

$(STATEDIR)/openbox.extract: $(openbox_extract_deps)
	@$(call targetinfo, $@)
	@$(call clean, $(OPENBOX_DIR))
	@$(call extract, $(OPENBOX_SOURCE))
	@$(call patchin, $(OPENBOX))
	touch $@

# ----------------------------------------------------------------------------
# Prepare
# ----------------------------------------------------------------------------

openbox_prepare: $(STATEDIR)/openbox.prepare

#
# dependencies
#
openbox_prepare_deps = \
	$(STATEDIR)/openbox.extract \
	$(STATEDIR)/xfree430.install \
	$(STATEDIR)/glib22.install \
	$(STATEDIR)/startup-notification.install \
	$(STATEDIR)/libxml2.install \
	$(STATEDIR)/virtual-xchain.install

OPENBOX_PATH	=  PATH=$(CROSS_PATH)
OPENBOX_ENV 	=  $(CROSS_ENV)
OPENBOX_ENV	+= PKG_CONFIG_PATH=$(CROSS_LIB_DIR)/lib/pkgconfig:$(CROSS_LIB_DIR)/lib/pkgconfig
#OPENBOX_ENV	+= LDFLAGS="-Wl,-rpath,$(CROSS_LIB_DIR)/lib -Wl,-rpath,$(CROSS_LIB_DIR)/lib"
#OPENBOX_ENV	+= LDFLAGS=-Wl,-rpath-link,$(CROSS_LIB_DIR)/lib
#OPENBOX_ENV	+=

#
# autoconf
#
OPENBOX_AUTOCONF = \
	--build=$(GNU_HOST) \
	--host=$(PTXCONF_GNU_TARGET) \
	--x-includes=$(CROSS_LIB_DIR)/include \
	--x-libraries=$(CROSS_LIB_DIR)/lib \
	--prefix=/usr \
	--disable-debug \
	--sysconfdir=/etc

$(STATEDIR)/openbox.prepare: $(openbox_prepare_deps)
	@$(call targetinfo, $@)
	@$(call clean, $(OPENBOX_DIR)/config.cache)
	cd $(OPENBOX_DIR) && \
		$(OPENBOX_PATH) $(OPENBOX_ENV) \
		./configure $(OPENBOX_AUTOCONF)
	cp -f $(PTXCONF_PREFIX)/bin/libtool $(OPENBOX_DIR)
	touch $@

# ----------------------------------------------------------------------------
# Compile
# ----------------------------------------------------------------------------

openbox_compile: $(STATEDIR)/openbox.compile

openbox_compile_deps = $(STATEDIR)/openbox.prepare

$(STATEDIR)/openbox.compile: $(openbox_compile_deps)
	@$(call targetinfo, $@)
	$(OPENBOX_PATH) $(MAKE) -C $(OPENBOX_DIR)
	touch $@

# ----------------------------------------------------------------------------
# Install
# ----------------------------------------------------------------------------

openbox_install: $(STATEDIR)/openbox.install

$(STATEDIR)/openbox.install: $(STATEDIR)/openbox.compile
	@$(call targetinfo, $@)
	#$(OPENBOX_PATH) $(MAKE) -C $(OPENBOX_DIR) install
	touch $@

# ----------------------------------------------------------------------------
# Target-Install
# ----------------------------------------------------------------------------

openbox_targetinstall: $(STATEDIR)/openbox.targetinstall

openbox_targetinstall_deps = $(STATEDIR)/openbox.compile \
	$(STATEDIR)/libxml2.targetinstall \
	$(STATEDIR)/startup-notification.targetinstall \
	$(STATEDIR)/glib22.targetinstall

$(STATEDIR)/openbox.targetinstall: $(openbox_targetinstall_deps)
	@$(call targetinfo, $@)
	$(OPENBOX_PATH) $(MAKE) -C $(OPENBOX_DIR) DESTDIR=$(OPENBOX_IPKG_TMP) install
	$(CROSSSTRIP) $(OPENBOX_IPKG_TMP)/usr/bin/gnome-panel-control
	$(CROSSSTRIP) $(OPENBOX_IPKG_TMP)/usr/bin/kdetrayproxy
	$(CROSSSTRIP) $(OPENBOX_IPKG_TMP)/usr/bin/openbox
	$(CROSSSTRIP) $(OPENBOX_IPKG_TMP)/usr/lib/libobparser.so.1.1.0
	$(CROSSSTRIP) $(OPENBOX_IPKG_TMP)/usr/lib/libobrender.so.1.1.0
	rm -f $(OPENBOX_IPKG_TMP)/usr/lib/libobparser.a
	rm -f $(OPENBOX_IPKG_TMP)/usr/lib/libobparser.la
	rm -f $(OPENBOX_IPKG_TMP)/usr/lib/libobrender.a
	rm -f $(OPENBOX_IPKG_TMP)/usr/lib/libobrender.la
	rm -rf $(OPENBOX_IPKG_TMP)/usr/lib/pkgconfig
	rm -rf $(OPENBOX_IPKG_TMP)/usr/include
	rm -rf $(OPENBOX_IPKG_TMP)/usr/share/locale
	rm -rf $(OPENBOX_IPKG_TMP)/usr/share/gnome
ifdef PTXCONF_ARCH_ARM
	cp -af $(TOPDIR)/config/pdaXrom/openbox/*  	  $(OPENBOX_IPKG_TMP)
endif
	mkdir -p $(OPENBOX_IPKG_TMP)/CONTROL
	echo "Package: openbox" 						 >$(OPENBOX_IPKG_TMP)/CONTROL/control
	echo "Priority: optional" 						>>$(OPENBOX_IPKG_TMP)/CONTROL/control
	echo "Section: X11"	 						>>$(OPENBOX_IPKG_TMP)/CONTROL/control
	echo "Maintainer: Alexander Chukov <sash@pdaXrom.org>"			>>$(OPENBOX_IPKG_TMP)/CONTROL/control
	echo "Architecture: $(SHORT_TARGET)"			 		>>$(OPENBOX_IPKG_TMP)/CONTROL/control
	echo "Version: $(OPENBOX_VERSION)-$(OPENBOX_VENDOR_VERSION)" 		>>$(OPENBOX_IPKG_TMP)/CONTROL/control
	echo "Depends: xfree430, glib2, startup-notification, libxml2"		>>$(OPENBOX_IPKG_TMP)/CONTROL/control
	echo "Description: Window manager"					>>$(OPENBOX_IPKG_TMP)/CONTROL/control
	cd $(FEEDDIR) && $(XMKIPKG) $(OPENBOX_IPKG_TMP)
	touch $@

# ----------------------------------------------------------------------------
# Image-Install
# ----------------------------------------------------------------------------

ifdef PTXCONF_OPENBOX_INSTALL
ROMPACKAGES += $(STATEDIR)/openbox.imageinstall
endif

openbox_imageinstall_deps = $(STATEDIR)/openbox.targetinstall \
	$(STATEDIR)/virtual-image.install

$(STATEDIR)/openbox.imageinstall: $(openbox_imageinstall_deps)
	@$(call targetinfo, $@)
	cd $(FEEDDIR) && $(XIPKG) install openbox
	touch $@

# ----------------------------------------------------------------------------
# Clean
# ----------------------------------------------------------------------------

openbox_clean:
	rm -rf $(STATEDIR)/openbox.*
	rm -rf $(OPENBOX_DIR)

# vim: syntax=make
