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
ifdef PTXCONF_LICQ
PACKAGES += licq
endif

#
# Paths and names
#
LICQ_VERSION		= 1.3.0
#LICQ_VERSION		= 1.3.0-PRE
###LICQ_VERSION		= 1.2.7
LICQ			= licq-$(LICQ_VERSION)
LICQ_SUFFIX		= tar.bz2
LICQ_URL		= http://heanet.dl.sourceforge.net/sourceforge/licq/$(LICQ).$(LICQ_SUFFIX)
LICQ_SOURCE		= $(SRCDIR)/$(LICQ).$(LICQ_SUFFIX)
LICQ_DIR		= $(BUILDDIR)/$(LICQ)
LICQ_IPKG_TMP		= $(LICQ_DIR)/ipkg_tmp

# ----------------------------------------------------------------------------
# Get
# ----------------------------------------------------------------------------

licq_get: $(STATEDIR)/licq.get

licq_get_deps = $(LICQ_SOURCE)

$(STATEDIR)/licq.get: $(licq_get_deps)
	@$(call targetinfo, $@)
	@$(call get_patches, $(LICQ))
	touch $@

$(LICQ_SOURCE):
	@$(call targetinfo, $@)
	@$(call get, $(LICQ_URL))

# ----------------------------------------------------------------------------
# Extract
# ----------------------------------------------------------------------------

licq_extract: $(STATEDIR)/licq.extract

licq_extract_deps = $(STATEDIR)/licq.get

$(STATEDIR)/licq.extract: $(licq_extract_deps)
	@$(call targetinfo, $@)
	@$(call clean, $(LICQ_DIR))
	@$(call extract, $(LICQ_SOURCE))
	@$(call patchin, $(LICQ))
	touch $@

# ----------------------------------------------------------------------------
# Prepare
# ----------------------------------------------------------------------------

licq_prepare: $(STATEDIR)/licq.prepare

#
# dependencies
#
licq_prepare_deps = \
	$(STATEDIR)/licq.extract \
	$(STATEDIR)/qt-x11-free.install \
	$(STATEDIR)/startup-notification.install \
	$(STATEDIR)/openssl.install \
	$(STATEDIR)/virtual-xchain.install

LICQ_PATH	=  PATH=$(CROSS_PATH)
LICQ_ENV 	=  $(CROSS_ENV)
LICQ_ENV	+= QTDIR=$(QT-X11-FREE_DIR)
LICQ_ENV	+= PKG_CONFIG_PATH=$(CROSS_LIB_DIR)/lib/pkgconfig:$(CROSS_LIB_DIR)/lib/pkgconfig
#ifdef PTXCONF_XFREE430
#LICQ_ENV	+= LDFLAGS=-Wl,-rpath-link,$(CROSS_LIB_DIR)/lib
#endif

#
# autoconf
#
LICQ_AUTOCONF = \
	--build=$(GNU_HOST) \
	--host=$(PTXCONF_GNU_TARGET) \
	--prefix=/usr

ifdef PTXCONF_XFREE430
LICQ_AUTOCONF += --x-includes=$(CROSS_LIB_DIR)/include
LICQ_AUTOCONF += --x-libraries=$(CROSS_LIB_DIR)/lib
endif

$(STATEDIR)/licq.prepare: $(licq_prepare_deps)
	@$(call targetinfo, $@)
	@$(call clean, $(LICQ_DIR)/config.cache)
	cd $(LICQ_DIR) && \
		$(LICQ_PATH) $(LICQ_ENV) \
		CFLAGS="-O2 -fomit-frame-pointer" CXXFLAGS="-O2 -fomit-frame-pointer -fno-exceptions -fno-rtti" \
		./configure $(LICQ_AUTOCONF)

	#cd $(LICQ_DIR)/plugins/qt-gui && aclocal
	#cd $(LICQ_DIR)/plugins/qt-gui && automake --add-missing
	#cd $(LICQ_DIR)/plugins/qt-gui && autoconf
	#cd $(LICQ_DIR)/plugins/qt-gui && autoheader

	cd $(LICQ_DIR)/plugins/qt-gui && \
		$(LICQ_PATH) $(LICQ_ENV) \
		CFLAGS="$(TARGET_OPT_CFLAGS)" CXXFLAGS="$(TARGET_OPT_CFLAGS) -fno-exceptions -fno-rtti" \
		./configure $(LICQ_AUTOCONF) --with-licq-includes=$(LICQ_DIR)/include

	touch $@

# ----------------------------------------------------------------------------
# Compile
# ----------------------------------------------------------------------------

licq_compile: $(STATEDIR)/licq.compile

licq_compile_deps = $(STATEDIR)/licq.prepare

$(STATEDIR)/licq.compile: $(licq_compile_deps)
	@$(call targetinfo, $@)
	$(LICQ_PATH) $(MAKE) -C $(LICQ_DIR)
	$(LICQ_PATH) $(MAKE) -C $(LICQ_DIR)/plugins/qt-gui
	touch $@

# ----------------------------------------------------------------------------
# Install
# ----------------------------------------------------------------------------

licq_install: $(STATEDIR)/licq.install

$(STATEDIR)/licq.install: $(STATEDIR)/licq.compile
	@$(call targetinfo, $@)
	touch $@

# ----------------------------------------------------------------------------
# Target-Install
# ----------------------------------------------------------------------------

licq_targetinstall: $(STATEDIR)/licq.targetinstall

licq_targetinstall_deps = $(STATEDIR)/licq.compile \
	$(STATEDIR)/openssl.targetinstall \
	$(STATEDIR)/startup-notification.targetinstall

$(STATEDIR)/licq.targetinstall: $(licq_targetinstall_deps)
	@$(call targetinfo, $@)
	$(LICQ_PATH) $(MAKE) -C $(LICQ_DIR)                DESTDIR=$(LICQ_IPKG_TMP) install
	$(LICQ_PATH) $(MAKE) -C $(LICQ_DIR)/plugins/qt-gui DESTDIR=$(LICQ_IPKG_TMP) install
	rm -rf $(LICQ_IPKG_TMP)/home
	rm -rf $(LICQ_IPKG_TMP)/usr/include
	rm -rf $(LICQ_IPKG_TMP)/usr/lib/licq/*.la
	rm -rf $(LICQ_IPKG_TMP)/usr/share/locale
	$(CROSSSTRIP) $(LICQ_IPKG_TMP)/usr/bin/licq
	$(CROSSSTRIP) $(LICQ_IPKG_TMP)/usr/lib/licq/*.so
	mkdir -p $(LICQ_IPKG_TMP)/usr/share/applications
	mkdir -p $(LICQ_IPKG_TMP)/usr/share/pixmaps
	cp -f $(TOPDIR)/config/pics/licq.desktop $(LICQ_IPKG_TMP)/usr/share/applications
	cp -f $(TOPDIR)/config/pics/licq.png     $(LICQ_IPKG_TMP)/usr/share/pixmaps
	mkdir -p $(LICQ_IPKG_TMP)/CONTROL
	echo "Package: licq" 						>$(LICQ_IPKG_TMP)/CONTROL/control
	echo "Priority: optional" 					>>$(LICQ_IPKG_TMP)/CONTROL/control
	echo "Section: X11"			 			>>$(LICQ_IPKG_TMP)/CONTROL/control
	echo "Maintainer: Alexander Chukov <sash@pdaXrom.org>" 		>>$(LICQ_IPKG_TMP)/CONTROL/control
	echo "Architecture: $(SHORT_TARGET)" 				>>$(LICQ_IPKG_TMP)/CONTROL/control
	echo "Version: $(LICQ_VERSION)" 				>>$(LICQ_IPKG_TMP)/CONTROL/control
	echo "Depends: qt-mt, startup-notification, openssl" 		>>$(LICQ_IPKG_TMP)/CONTROL/control
	echo "Description: An ICQ clone written in C and C++ using a plugin system to allow for many possible interfaces.">>$(LICQ_IPKG_TMP)/CONTROL/control
	cd $(FEEDDIR) && $(XMKIPKG) $(LICQ_IPKG_TMP)
	touch $@

# ----------------------------------------------------------------------------
# Image-Install
# ----------------------------------------------------------------------------

ifdef PTXCONF_LICQ_INSTALL
ROMPACKAGES += $(STATEDIR)/licq.imageinstall
endif

licq_imageinstall_deps = $(STATEDIR)/licq.targetinstall \
	$(STATEDIR)/virtual-image.install

$(STATEDIR)/licq.imageinstall: $(licq_imageinstall_deps)
	@$(call targetinfo, $@)
	cd $(FEEDDIR) && $(XIPKG) install licq
	touch $@

# ----------------------------------------------------------------------------
# Clean
# ----------------------------------------------------------------------------

licq_clean:
	rm -rf $(STATEDIR)/licq.*
	rm -rf $(LICQ_DIR)

# vim: syntax=make
