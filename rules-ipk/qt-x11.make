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
ifdef PTXCONF_QT-X11
PACKAGES += qt-x11
endif

#
# Paths and names
#
QT-X11_VERSION		= 2.3.2
QT-X11			= qt-x11-$(QT-X11_VERSION)
QT-X11_SUFFIX		= tar.gz
QT-X11_URL		= ftp://ftp.trolltech.com/qt/source/$(QT-X11).$(QT-X11_SUFFIX)
QT-X11_SOURCE		= $(SRCDIR)/$(QT-X11).$(QT-X11_SUFFIX)
QT-X11_DIR		= $(BUILDDIR)/qt-$(QT-X11_VERSION)
QT-X11_IPKG_TMP		= $(QT-X11_DIR)/ipkg_tmp

# ----------------------------------------------------------------------------
# Get
# ----------------------------------------------------------------------------

qt-x11_get: $(STATEDIR)/qt-x11.get

qt-x11_get_deps = $(QT-X11_SOURCE)

$(STATEDIR)/qt-x11.get: $(qt-x11_get_deps)
	@$(call targetinfo, $@)
	@$(call get_patches, $(QT-X11))
	touch $@

$(QT-X11_SOURCE):
	@$(call targetinfo, $@)
	@$(call get, $(QT-X11_URL))

# ----------------------------------------------------------------------------
# Extract
# ----------------------------------------------------------------------------

qt-x11_extract: $(STATEDIR)/qt-x11.extract

qt-x11_extract_deps = $(STATEDIR)/qt-x11.get

$(STATEDIR)/qt-x11.extract: $(qt-x11_extract_deps)
	@$(call targetinfo, $@)
	@$(call clean, $(QT-X11_DIR))
	@$(call extract, $(QT-X11_SOURCE))
	@$(call patchin, $(QT-X11))
	touch $@

# ----------------------------------------------------------------------------
# Prepare
# ----------------------------------------------------------------------------

qt-x11_prepare: $(STATEDIR)/qt-x11.prepare

#
# dependencies
#
qt-x11_prepare_deps = \
	$(STATEDIR)/qt-x11.extract \
	$(STATEDIR)/virtual-xchain.install

QT-X11_PATH	=  PATH=$(CROSS_PATH)
QT-X11_ENV 	=  $(CROSS_ENV)
#QT-X11_ENV	+=
QT-X11_ENV	+= PKG_CONFIG_PATH=$(CROSS_LIB_DIR)/lib/pkgconfig:$(CROSS_LIB_DIR)/lib/pkgconfig
#ifdef PTXCONF_XFREE430
#QT-X11_ENV	+= LDFLAGS=-Wl,-rpath-link,$(CROSS_LIB_DIR)/lib
#endif

#
# autoconf
#
QT-X11_AUTOCONF = \
	--build=$(GNU_HOST) \
	--host=$(PTXCONF_GNU_TARGET) \
	--prefix=/usr

ifdef PTXCONF_XFREE430
QT-X11_AUTOCONF += --x-includes=$(CROSS_LIB_DIR)/include
QT-X11_AUTOCONF += --x-libraries=$(CROSS_LIB_DIR)/lib
endif

$(STATEDIR)/qt-x11.prepare: $(qt-x11_prepare_deps)
	@$(call targetinfo, $@)
	@$(call clean, $(QT-X11_DIR)/config.cache)
	cd $(QT-X11_DIR) && \
		$(QT-X11_PATH) $(QT-X11_ENV) \
		./configure $(QT-X11_AUTOCONF)
	touch $@

# ----------------------------------------------------------------------------
# Compile
# ----------------------------------------------------------------------------

qt-x11_compile: $(STATEDIR)/qt-x11.compile

qt-x11_compile_deps = $(STATEDIR)/qt-x11.prepare

$(STATEDIR)/qt-x11.compile: $(qt-x11_compile_deps)
	@$(call targetinfo, $@)
	$(QT-X11_PATH) $(MAKE) -C $(QT-X11_DIR)
	touch $@

# ----------------------------------------------------------------------------
# Install
# ----------------------------------------------------------------------------

qt-x11_install: $(STATEDIR)/qt-x11.install

$(STATEDIR)/qt-x11.install: $(STATEDIR)/qt-x11.compile
	@$(call targetinfo, $@)
	$(QT-X11_PATH) $(MAKE) -C $(QT-X11_DIR) install
	touch $@

# ----------------------------------------------------------------------------
# Target-Install
# ----------------------------------------------------------------------------

qt-x11_targetinstall: $(STATEDIR)/qt-x11.targetinstall

qt-x11_targetinstall_deps = $(STATEDIR)/qt-x11.compile

$(STATEDIR)/qt-x11.targetinstall: $(qt-x11_targetinstall_deps)
	@$(call targetinfo, $@)
	$(QT-X11_PATH) $(MAKE) -C $(QT-X11_DIR) DESTDIR=$(QT-X11_IPKG_TMP) install
	mkdir -p $(QT-X11_IPKG_TMP)/CONTROL
	echo "Package: qt-x11" 			>$(QT-X11_IPKG_TMP)/CONTROL/control
	echo "Priority: optional" 			>>$(QT-X11_IPKG_TMP)/CONTROL/control
	echo "Section: pdaXrom" 			>>$(QT-X11_IPKG_TMP)/CONTROL/control
	echo "Maintainer: Alexander Chukov <sash@pdaXrom.org>" 			>>$(QT-X11_IPKG_TMP)/CONTROL/control
	echo "Architecture: $(SHORT_TARGET)" 		>>$(QT-X11_IPKG_TMP)/CONTROL/control
	echo "Version: $(QT-X11_VERSION)" 		>>$(QT-X11_IPKG_TMP)/CONTROL/control
	echo "Depends: " 				>>$(QT-X11_IPKG_TMP)/CONTROL/control
	echo "Description: generated with pdaXrom builder">>$(QT-X11_IPKG_TMP)/CONTROL/control
	cd $(FEEDDIR) && $(XMKIPKG) $(QT-X11_IPKG_TMP)
	touch $@

# ----------------------------------------------------------------------------
# Image-Install
# ----------------------------------------------------------------------------

ifdef PTXCONF_QT-X11_INSTALL
ROMPACKAGES += $(STATEDIR)/qt-x11.imageinstall
endif

qt-x11_imageinstall_deps = $(STATEDIR)/qt-x11.targetinstall \
	$(STATEDIR)/virtual-image.install

$(STATEDIR)/qt-x11.imageinstall: $(qt-x11_imageinstall_deps)
	@$(call targetinfo, $@)
	cd $(FEEDDIR) && $(XIPKG) install qt-x11
	touch $@

# ----------------------------------------------------------------------------
# Clean
# ----------------------------------------------------------------------------

qt-x11_clean:
	rm -rf $(STATEDIR)/qt-x11.*
	rm -rf $(QT-X11_DIR)

# vim: syntax=make
