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
ifdef PTXCONF_LIBGNOMEPRINTUI
PACKAGES += libgnomeprintui
endif

#
# Paths and names
#
#LIBGNOMEPRINTUI_VERSION		= 2.4.2
LIBGNOMEPRINTUI_VERSION		= 2.6.2
#LIBGNOMEPRINTUI_VERSION		= 2.8.0
LIBGNOMEPRINTUI			= libgnomeprintui-$(LIBGNOMEPRINTUI_VERSION)
LIBGNOMEPRINTUI_SUFFIX		= tar.bz2
LIBGNOMEPRINTUI_URL		= http://ftp.gnome.org/pub/GNOME/sources/libgnomeprintui/2.6/$(LIBGNOMEPRINTUI).$(LIBGNOMEPRINTUI_SUFFIX)
LIBGNOMEPRINTUI_SOURCE		= $(SRCDIR)/$(LIBGNOMEPRINTUI).$(LIBGNOMEPRINTUI_SUFFIX)
LIBGNOMEPRINTUI_DIR		= $(BUILDDIR)/$(LIBGNOMEPRINTUI)
LIBGNOMEPRINTUI_IPKG_TMP	= $(LIBGNOMEPRINTUI_DIR)/ipkg_tmp

# ----------------------------------------------------------------------------
# Get
# ----------------------------------------------------------------------------

libgnomeprintui_get: $(STATEDIR)/libgnomeprintui.get

libgnomeprintui_get_deps = $(LIBGNOMEPRINTUI_SOURCE)

$(STATEDIR)/libgnomeprintui.get: $(libgnomeprintui_get_deps)
	@$(call targetinfo, $@)
	@$(call get_patches, $(LIBGNOMEPRINTUI))
	touch $@

$(LIBGNOMEPRINTUI_SOURCE):
	@$(call targetinfo, $@)
	@$(call get, $(LIBGNOMEPRINTUI_URL))

# ----------------------------------------------------------------------------
# Extract
# ----------------------------------------------------------------------------

libgnomeprintui_extract: $(STATEDIR)/libgnomeprintui.extract

libgnomeprintui_extract_deps = $(STATEDIR)/libgnomeprintui.get

$(STATEDIR)/libgnomeprintui.extract: $(libgnomeprintui_extract_deps)
	@$(call targetinfo, $@)
	@$(call clean, $(LIBGNOMEPRINTUI_DIR))
	@$(call extract, $(LIBGNOMEPRINTUI_SOURCE))
	@$(call patchin, $(LIBGNOMEPRINTUI))
	touch $@

# ----------------------------------------------------------------------------
# Prepare
# ----------------------------------------------------------------------------

libgnomeprintui_prepare: $(STATEDIR)/libgnomeprintui.prepare

#
# dependencies
#
libgnomeprintui_prepare_deps = \
	$(STATEDIR)/libgnomeprintui.extract \
	$(STATEDIR)/libgnomecanvas.install \
	$(STATEDIR)/libgnomeprint.install \
	$(STATEDIR)/virtual-xchain.install \
	$(STATEDIR)/gnome-icon-theme.install

LIBGNOMEPRINTUI_PATH	=  PATH=$(CROSS_PATH)
LIBGNOMEPRINTUI_ENV 	=  $(CROSS_ENV)
LIBGNOMEPRINTUI_ENV	+= CFLAGS="-O2 -fomit-frame-pointer"
LIBGNOMEPRINTUI_ENV	+= PKG_CONFIG_PATH=$(CROSS_LIB_DIR)/lib/pkgconfig:$(CROSS_LIB_DIR)/lib/pkgconfig
#ifdef PTXCONF_XFREE430
#LIBGNOMEPRINTUI_ENV	+= LDFLAGS=-Wl,-rpath-link,$(CROSS_LIB_DIR)/lib
#endif
LIBGNOMEPRINTUI_ENV	+= ac_cv_file____libgnomeprint_libgnomeprint_libgnomeprint_2_2_la=no

#
# autoconf
#
LIBGNOMEPRINTUI_AUTOCONF = \
	--build=$(GNU_HOST) \
	--host=$(PTXCONF_GNU_TARGET) \
	--prefix=/usr \
	--enable-shared \
	--disable-static \
	--sysconfdir=/etc \
	--libexecdir=/usr/bin \
	--disable-debug

ifdef PTXCONF_XFREE430
LIBGNOMEPRINTUI_AUTOCONF += --x-includes=$(CROSS_LIB_DIR)/include
LIBGNOMEPRINTUI_AUTOCONF += --x-libraries=$(CROSS_LIB_DIR)/lib
endif

$(STATEDIR)/libgnomeprintui.prepare: $(libgnomeprintui_prepare_deps)
	@$(call targetinfo, $@)
	@$(call clean, $(LIBGNOMEPRINTUI_DIR)/config.cache)
	cd $(LIBGNOMEPRINTUI_DIR) && \
		$(LIBGNOMEPRINTUI_PATH) $(LIBGNOMEPRINTUI_ENV) \
		./configure $(LIBGNOMEPRINTUI_AUTOCONF)
	touch $@

# ----------------------------------------------------------------------------
# Compile
# ----------------------------------------------------------------------------

libgnomeprintui_compile: $(STATEDIR)/libgnomeprintui.compile

libgnomeprintui_compile_deps = $(STATEDIR)/libgnomeprintui.prepare

$(STATEDIR)/libgnomeprintui.compile: $(libgnomeprintui_compile_deps)
	@$(call targetinfo, $@)
	$(LIBGNOMEPRINTUI_PATH) $(MAKE) -C $(LIBGNOMEPRINTUI_DIR)
	touch $@

# ----------------------------------------------------------------------------
# Install
# ----------------------------------------------------------------------------

libgnomeprintui_install: $(STATEDIR)/libgnomeprintui.install

$(STATEDIR)/libgnomeprintui.install: $(STATEDIR)/libgnomeprintui.compile
	@$(call targetinfo, $@)
	$(LIBGNOMEPRINTUI_PATH) $(MAKE) -C $(LIBGNOMEPRINTUI_DIR) DESTDIR=$(LIBGNOMEPRINTUI_IPKG_TMP) install
	cp -a  $(LIBGNOMEPRINTUI_IPKG_TMP)/usr/include/*          $(CROSS_LIB_DIR)/include
	cp -a  $(LIBGNOMEPRINTUI_IPKG_TMP)/usr/lib/*              $(CROSS_LIB_DIR)/lib
	perl -p -i -e "s/\/usr\/lib/`echo $(PTXCONF_PREFIX)/$(PTXCONF_GNU_TARGET)/lib | sed -e '/\//s//\\\\\//g'`/g" $(PTXCONF_PREFIX)/$(PTXCONF_GNU_TARGET)/lib/libgnomeprintui-2-2.la
	perl -p -i -e "s/\/usr/`echo $(PTXCONF_PREFIX)/$(PTXCONF_GNU_TARGET) | sed -e '/\//s//\\\\\//g'`/g" $(PTXCONF_PREFIX)/$(PTXCONF_GNU_TARGET)/lib/pkgconfig/libgnomeprintui-2.2.pc
	rm -rf $(LIBGNOMEPRINTUI_IPKG_TMP)
	touch $@

# ----------------------------------------------------------------------------
# Target-Install
# ----------------------------------------------------------------------------

libgnomeprintui_targetinstall: $(STATEDIR)/libgnomeprintui.targetinstall

libgnomeprintui_targetinstall_deps = \
	$(STATEDIR)/libgnomeprintui.compile \
	$(STATEDIR)/libgnomecanvas.targetinstall \
	$(STATEDIR)/libgnomeprint.targetinstall \
	$(STATEDIR)/gnome-icon-theme.targetinstall

$(STATEDIR)/libgnomeprintui.targetinstall: $(libgnomeprintui_targetinstall_deps)
	@$(call targetinfo, $@)
	$(LIBGNOMEPRINTUI_PATH) $(MAKE) -C $(LIBGNOMEPRINTUI_DIR) DESTDIR=$(LIBGNOMEPRINTUI_IPKG_TMP) install
	rm -rf $(LIBGNOMEPRINTUI_IPKG_TMP)/usr/include
	rm -rf $(LIBGNOMEPRINTUI_IPKG_TMP)/usr/lib/pkgconfig
	rm -rf $(LIBGNOMEPRINTUI_IPKG_TMP)/usr/lib/*.*a
	rm -rf $(LIBGNOMEPRINTUI_IPKG_TMP)/usr/share
	$(CROSSSTRIP) $(LIBGNOMEPRINTUI_IPKG_TMP)/usr/lib/*
	mkdir -p $(LIBGNOMEPRINTUI_IPKG_TMP)/CONTROL
	echo "Package: libgnomeprintui" 			>$(LIBGNOMEPRINTUI_IPKG_TMP)/CONTROL/control
	echo "Priority: optional" 				>>$(LIBGNOMEPRINTUI_IPKG_TMP)/CONTROL/control
	echo "Section: Gnome" 					>>$(LIBGNOMEPRINTUI_IPKG_TMP)/CONTROL/control
	echo "Maintainer: Alexander Chukov <sash@pdaXrom.org>" 	>>$(LIBGNOMEPRINTUI_IPKG_TMP)/CONTROL/control
	echo "Architecture: $(SHORT_TARGET)" 			>>$(LIBGNOMEPRINTUI_IPKG_TMP)/CONTROL/control
	echo "Version: $(LIBGNOMEPRINTUI_VERSION)" 		>>$(LIBGNOMEPRINTUI_IPKG_TMP)/CONTROL/control
	echo "Depends: libgnomeprint, libgnomecanvas" >>$(LIBGNOMEPRINTUI_IPKG_TMP)/CONTROL/control
	echo "Description: UI for gnomeprint">>$(LIBGNOMEPRINTUI_IPKG_TMP)/CONTROL/control
	cd $(FEEDDIR) && $(XMKIPKG) $(LIBGNOMEPRINTUI_IPKG_TMP)
	touch $@

# ----------------------------------------------------------------------------
# Clean
# ----------------------------------------------------------------------------

libgnomeprintui_clean:
	rm -rf $(STATEDIR)/libgnomeprintui.*
	rm -rf $(LIBGNOMEPRINTUI_DIR)

# vim: syntax=make
