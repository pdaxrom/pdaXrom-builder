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
ifdef PTXCONF_JUSTREADER
PACKAGES += JustReader
endif

#
# Paths and names
#
JUSTREADER_VERSION		= 2.0k
JUSTREADER			= JustReader-$(JUSTREADER_VERSION)
JUSTREADER_SUFFIX		= tar.bz2
JUSTREADER_URL			= http://www.pdaXrom.org/src/$(JUSTREADER).$(JUSTREADER_SUFFIX)
JUSTREADER_SOURCE		= $(SRCDIR)/$(JUSTREADER).$(JUSTREADER_SUFFIX)
JUSTREADER_DIR			= $(BUILDDIR)/$(JUSTREADER)
JUSTREADER_IPKG_TMP		= $(JUSTREADER_DIR)/dist

# ----------------------------------------------------------------------------
# Get
# ----------------------------------------------------------------------------

JustReader_get: $(STATEDIR)/JustReader.get

JustReader_get_deps = $(JUSTREADER_SOURCE)

$(STATEDIR)/JustReader.get: $(JustReader_get_deps)
	@$(call targetinfo, $@)
	@$(call get_patches, $(JUSTREADER))
	touch $@

$(JUSTREADER_SOURCE):
	@$(call targetinfo, $@)
	@$(call get, $(JUSTREADER_URL))

# ----------------------------------------------------------------------------
# Extract
# ----------------------------------------------------------------------------

JustReader_extract: $(STATEDIR)/JustReader.extract

JustReader_extract_deps = $(STATEDIR)/JustReader.get

$(STATEDIR)/JustReader.extract: $(JustReader_extract_deps)
	@$(call targetinfo, $@)
	@$(call clean, $(JUSTREADER_DIR))
	@$(call extract, $(JUSTREADER_SOURCE))
	@$(call patchin, $(JUSTREADER))
	touch $@

# ----------------------------------------------------------------------------
# Prepare
# ----------------------------------------------------------------------------

JustReader_prepare: $(STATEDIR)/JustReader.prepare

#
# dependencies
#
JustReader_prepare_deps = \
	$(STATEDIR)/JustReader.extract \
	$(STATEDIR)/qt-x11-free.install \
	$(STATEDIR)/startup-notification.install \
	$(STATEDIR)/virtual-xchain.install

JUSTREADER_PATH	=  PATH=$(QT-X11-FREE_DIR)/bin:$(CROSS_PATH)
JUSTREADER_ENV 	=  $(CROSS_ENV)
JUSTREADER_ENV	+= QTDIR=$(QT-X11-FREE_DIR)
JUSTREADER_ENV	+= PKG_CONFIG_PATH=$(CROSS_LIB_DIR)/lib/pkgconfig:$(CROSS_LIB_DIR)/lib/pkgconfig
#
# autoconf
#
JUSTREADER_AUTOCONF = \
	--build=$(GNU_HOST) \
	--host=$(PTXCONF_GNU_TARGET) \
	--prefix=/usr

ifdef PTXCONF_XFREE430
JUSTREADER_AUTOCONF += --x-includes=$(CROSS_LIB_DIR)/include
JUSTREADER_AUTOCONF += --x-libraries=$(CROSS_LIB_DIR)/lib
endif

$(STATEDIR)/JustReader.prepare: $(JustReader_prepare_deps)
	@$(call targetinfo, $@)
	@$(call clean, $(JUSTREADER_DIR)/config.cache)
	cd $(JUSTREADER_DIR) && \
		$(JUSTREADER_PATH) $(JUSTREADER_ENV) \
		qmake JustReader.pro
	touch $@

# ----------------------------------------------------------------------------
# Compile
# ----------------------------------------------------------------------------

JustReader_compile: $(STATEDIR)/JustReader.compile

JustReader_compile_deps = $(STATEDIR)/JustReader.prepare

$(STATEDIR)/JustReader.compile: $(JustReader_compile_deps)
	@$(call targetinfo, $@)
	$(JUSTREADER_PATH) $(JUSTREADER_ENV) $(MAKE) -C $(JUSTREADER_DIR) UIC=uic
	touch $@

# ----------------------------------------------------------------------------
# Install
# ----------------------------------------------------------------------------

JustReader_install: $(STATEDIR)/JustReader.install

$(STATEDIR)/JustReader.install: $(STATEDIR)/JustReader.compile
	@$(call targetinfo, $@)
	touch $@

# ----------------------------------------------------------------------------
# Target-Install
# ----------------------------------------------------------------------------

JustReader_targetinstall: $(STATEDIR)/JustReader.targetinstall

JustReader_targetinstall_deps = $(STATEDIR)/JustReader.compile \
	$(STATEDIR)/startup-notification.targetinstall \
	$(STATEDIR)/qt-x11-free.targetinstall

$(STATEDIR)/JustReader.targetinstall: $(JustReader_targetinstall_deps)
	@$(call targetinfo, $@)
	$(CROSSSTRIP) $(JUSTREADER_IPKG_TMP)/usr/lib/qt/bin/*
	echo "Package: justreader" 						 >$(JUSTREADER_IPKG_TMP)/CONTROL/control
	echo "Priority: optional" 						>>$(JUSTREADER_IPKG_TMP)/CONTROL/control
	echo "Section: Office"				 			>>$(JUSTREADER_IPKG_TMP)/CONTROL/control
	echo "Maintainer: Alexander Chukov <sash@pdaXrom.org>" 			>>$(JUSTREADER_IPKG_TMP)/CONTROL/control
	echo "Architecture: $(SHORT_TARGET)" 					>>$(JUSTREADER_IPKG_TMP)/CONTROL/control
	echo "Version: $(JUSTREADER_VERSION)" 					>>$(JUSTREADER_IPKG_TMP)/CONTROL/control
	echo "Depends: qt-mt, startup-notification" 				>>$(JUSTREADER_IPKG_TMP)/CONTROL/control
	echo "Description: E-Books Reader"					>>$(JUSTREADER_IPKG_TMP)/CONTROL/control
	cd $(FEEDDIR) && $(XMKIPKG) $(JUSTREADER_IPKG_TMP)
	touch $@

# ----------------------------------------------------------------------------
# Image-Install
# ----------------------------------------------------------------------------

ifdef PTXCONF_JUSTREADER_INSTALL
ROMPACKAGES += $(STATEDIR)/JustReader.imageinstall
endif

JustReader_imageinstall_deps = $(STATEDIR)/JustReader.targetinstall \
	$(STATEDIR)/virtual-image.install

$(STATEDIR)/JustReader.imageinstall: $(JustReader_imageinstall_deps)
	@$(call targetinfo, $@)
	cd $(FEEDDIR) && $(XIPKG) install justreader
	touch $@

# ----------------------------------------------------------------------------
# Clean
# ----------------------------------------------------------------------------

JustReader_clean:
	rm -rf $(STATEDIR)/JustReader.*
	rm -rf $(JUSTREADER_DIR)

# vim: syntax=make
