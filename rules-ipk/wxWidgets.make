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
ifdef PTXCONF_WXWIDGETS
PACKAGES += wxWidgets
endif

#
# Paths and names
#
WXWIDGETS_VENDOR_VERSION	= 1
WXWIDGETS_VERSION		= 2.5.3
WXWIDGETS			= wxAll-$(WXWIDGETS_VERSION)
WXWIDGETS_SUFFIX		= tar.gz
WXWIDGETS_URL			= http://heanet.dl.sourceforge.net/sourceforge/wxwindows/$(WXWIDGETS).$(WXWIDGETS_SUFFIX)
WXWIDGETS_SOURCE		= $(SRCDIR)/$(WXWIDGETS).$(WXWIDGETS_SUFFIX)
WXWIDGETS_DIR			= $(BUILDDIR)/wxWidgets-$(WXWIDGETS_VERSION)
WXWIDGETS_IPKG_TMP		= $(WXWIDGETS_DIR)/ipkg_tmp

# ----------------------------------------------------------------------------
# Get
# ----------------------------------------------------------------------------

wxWidgets_get: $(STATEDIR)/wxWidgets.get

wxWidgets_get_deps = $(WXWIDGETS_SOURCE)

$(STATEDIR)/wxWidgets.get: $(wxWidgets_get_deps)
	@$(call targetinfo, $@)
	@$(call get_patches, $(WXWIDGETS))
	touch $@

$(WXWIDGETS_SOURCE):
	@$(call targetinfo, $@)
	@$(call get, $(WXWIDGETS_URL))

# ----------------------------------------------------------------------------
# Extract
# ----------------------------------------------------------------------------

wxWidgets_extract: $(STATEDIR)/wxWidgets.extract

wxWidgets_extract_deps = $(STATEDIR)/wxWidgets.get

$(STATEDIR)/wxWidgets.extract: $(wxWidgets_extract_deps)
	@$(call targetinfo, $@)
	@$(call clean, $(WXWIDGETS_DIR))
	@$(call extract, $(WXWIDGETS_SOURCE))
	@$(call patchin, $(WXWIDGETS), $(WXWIDGETS_DIR))
	touch $@

# ----------------------------------------------------------------------------
# Prepare
# ----------------------------------------------------------------------------

wxWidgets_prepare: $(STATEDIR)/wxWidgets.prepare

#
# dependencies
#
wxWidgets_prepare_deps = \
	$(STATEDIR)/wxWidgets.extract \
	$(STATEDIR)/virtual-xchain.install

WXWIDGETS_PATH	=  PATH=$(CROSS_PATH)
WXWIDGETS_ENV 	=  $(CROSS_ENV)
WXWIDGETS_ENV	+= CFLAGS="$(TARGET_OPT_CFLAGS)"
WXWIDGETS_ENV	+= CXXFLAGS="$(TARGET_OPT_CFLAGS)"
WXWIDGETS_ENV	+= PKG_CONFIG_PATH=$(CROSS_LIB_DIR)/lib/pkgconfig:$(CROSS_LIB_DIR)/lib/pkgconfig
#ifdef PTXCONF_XFREE430
#WXWIDGETS_ENV	+= LDFLAGS=-Wl,-rpath-link,$(CROSS_LIB_DIR)/lib
#endif

#
# autoconf
#
WXWIDGETS_AUTOCONF = \
	--build=$(GNU_HOST) \
	--host=$(PTXCONF_GNU_TARGET) \
	--prefix=/usr \
	--enable-unicode \
	--enable-gtk2 \
	--enable-optimise

#	--enable-no_rtti
#	--enable-no_exceptions

ifdef PTXCONF_XFREE430
WXWIDGETS_AUTOCONF += --x-includes=$(CROSS_LIB_DIR)/include
WXWIDGETS_AUTOCONF += --x-libraries=$(CROSS_LIB_DIR)/lib
endif

$(STATEDIR)/wxWidgets.prepare: $(wxWidgets_prepare_deps)
	@$(call targetinfo, $@)
	@$(call clean, $(WXWIDGETS_DIR)/config.cache)
	cd $(WXWIDGETS_DIR) && \
		$(WXWIDGETS_PATH) $(WXWIDGETS_ENV) \
		./configure $(WXWIDGETS_AUTOCONF)
	touch $@

# ----------------------------------------------------------------------------
# Compile
# ----------------------------------------------------------------------------

wxWidgets_compile: $(STATEDIR)/wxWidgets.compile

wxWidgets_compile_deps = $(STATEDIR)/wxWidgets.prepare

$(STATEDIR)/wxWidgets.compile: $(wxWidgets_compile_deps)
	@$(call targetinfo, $@)
	$(WXWIDGETS_PATH) $(MAKE) -C $(WXWIDGETS_DIR)
	touch $@

# ----------------------------------------------------------------------------
# Install
# ----------------------------------------------------------------------------

wxWidgets_install: $(STATEDIR)/wxWidgets.install

$(STATEDIR)/wxWidgets.install: $(STATEDIR)/wxWidgets.compile
	@$(call targetinfo, $@)
	rm -rf $(WXWIDGETS_IPKG_TMP)/usr
	$(WXWIDGETS_PATH) $(MAKE) -C $(WXWIDGETS_DIR) prefix=$(WXWIDGETS_IPKG_TMP)/usr install
	cp -a  $(WXWIDGETS_IPKG_TMP)/usr/include/*		$(CROSS_LIB_DIR)/include
	cp -a  $(WXWIDGETS_IPKG_TMP)/usr/lib/*			$(CROSS_LIB_DIR)/lib
	cp -a  $(WXWIDGETS_IPKG_TMP)/usr/share/aclocal/*	$(PTXCONF_PREFIX)/share/aclocal
	ln -sf $(CROSS_LIB_DIR)/lib/wx/config/$(PTXCONF_GNU_TARGET)-gtk2-unicode-release-2.5 $(PTXCONF_PREFIX)/bin/wx-config
	perl -p -i -e "s/\/usr/`echo $(PTXCONF_PREFIX)/$(PTXCONF_GNU_TARGET) | sed -e '/\//s//\\\\\//g'`/g" $(CROSS_LIB_DIR)/lib/wx/config/$(PTXCONF_GNU_TARGET)-gtk2-unicode-release-2.5
	rm -rf $(WXWIDGETS_IPKG_TMP)/usr
	touch $@

# ----------------------------------------------------------------------------
# Target-Install
# ----------------------------------------------------------------------------

wxWidgets_targetinstall: $(STATEDIR)/wxWidgets.targetinstall

wxWidgets_targetinstall_deps = $(STATEDIR)/wxWidgets.compile

$(STATEDIR)/wxWidgets.targetinstall: $(wxWidgets_targetinstall_deps)
	@$(call targetinfo, $@)
	$(WXWIDGETS_PATH) $(MAKE) -C $(WXWIDGETS_DIR) prefix=$(WXWIDGETS_IPKG_TMP)/usr install
	rm -rf $(WXWIDGETS_IPKG_TMP)/usr/bin
	rm -rf $(WXWIDGETS_IPKG_TMP)/usr/include
	rm -rf $(WXWIDGETS_IPKG_TMP)/usr/lib/wx
	rm -rf $(WXWIDGETS_IPKG_TMP)/usr/share/aclocal
	rm -rf $(WXWIDGETS_IPKG_TMP)/usr/share/locale
	$(CROSSSTRIP) $(WXWIDGETS_IPKG_TMP)/usr/lib/*
	mkdir -p $(WXWIDGETS_IPKG_TMP)/CONTROL
	echo "Package: wxwidgets" 									 >$(WXWIDGETS_IPKG_TMP)/CONTROL/control
	echo "Priority: optional" 									>>$(WXWIDGETS_IPKG_TMP)/CONTROL/control
	echo "Section: X11"	 									>>$(WXWIDGETS_IPKG_TMP)/CONTROL/control
	echo "Maintainer: Alexander Chukov <sash@pdaXrom.org>" 						>>$(WXWIDGETS_IPKG_TMP)/CONTROL/control
	echo "Architecture: $(SHORT_TARGET)" 								>>$(WXWIDGETS_IPKG_TMP)/CONTROL/control
	echo "Version: $(WXWIDGETS_VERSION)-$(WXWIDGETS_VENDOR_VERSION)" 				>>$(WXWIDGETS_IPKG_TMP)/CONTROL/control
	echo "Depends: gtk2" 										>>$(WXWIDGETS_IPKG_TMP)/CONTROL/control
	echo "Description: generated with pdaXrom builder"						>>$(WXWIDGETS_IPKG_TMP)/CONTROL/control
	cd $(FEEDDIR) && $(XMKIPKG) $(WXWIDGETS_IPKG_TMP)
	touch $@

# ----------------------------------------------------------------------------
# Image-Install
# ----------------------------------------------------------------------------

ifdef PTXCONF_WXWIDGETS_INSTALL
ROMPACKAGES += $(STATEDIR)/wxWidgets.imageinstall
endif

wxWidgets_imageinstall_deps = $(STATEDIR)/wxWidgets.targetinstall \
	$(STATEDIR)/virtual-image.install

$(STATEDIR)/wxWidgets.imageinstall: $(wxWidgets_imageinstall_deps)
	@$(call targetinfo, $@)
	cd $(FEEDDIR) && $(XIPKG) install wxwidgets
	touch $@

# ----------------------------------------------------------------------------
# Clean
# ----------------------------------------------------------------------------

wxWidgets_clean:
	rm -rf $(STATEDIR)/wxWidgets.*
	rm -rf $(WXWIDGETS_DIR)

# vim: syntax=make
