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
ifdef PTXCONF_LIBGLADE
PACKAGES += libglade
endif

#
# Paths and names
#
#LIBGLADE_VERSION	= 2.0.1
LIBGLADE_VERSION	= 2.5.0
LIBGLADE		= libglade-$(LIBGLADE_VERSION)
LIBGLADE_SUFFIX		= tar.bz2
LIBGLADE_URL		= ftp://ftp.gnome.org/pub/GNOME/sources/libglade/2.5/$(LIBGLADE).$(LIBGLADE_SUFFIX)
LIBGLADE_SOURCE		= $(SRCDIR)/$(LIBGLADE).$(LIBGLADE_SUFFIX)
LIBGLADE_DIR		= $(BUILDDIR)/$(LIBGLADE)
LIBGLADE_IPKG_TMP	= $(LIBGLADE_DIR)/ipkg_tmp

# ----------------------------------------------------------------------------
# Get
# ----------------------------------------------------------------------------

libglade_get: $(STATEDIR)/libglade.get

libglade_get_deps = $(LIBGLADE_SOURCE)

$(STATEDIR)/libglade.get: $(libglade_get_deps)
	@$(call targetinfo, $@)
	@$(call get_patches, $(LIBGLADE))
	touch $@

$(LIBGLADE_SOURCE):
	@$(call targetinfo, $@)
	@$(call get, $(LIBGLADE_URL))

# ----------------------------------------------------------------------------
# Extract
# ----------------------------------------------------------------------------

libglade_extract: $(STATEDIR)/libglade.extract

libglade_extract_deps = $(STATEDIR)/libglade.get

$(STATEDIR)/libglade.extract: $(libglade_extract_deps)
	@$(call targetinfo, $@)
	@$(call clean, $(LIBGLADE_DIR))
	@$(call extract, $(LIBGLADE_SOURCE))
	@$(call patchin, $(LIBGLADE))
	touch $@

# ----------------------------------------------------------------------------
# Prepare
# ----------------------------------------------------------------------------

libglade_prepare: $(STATEDIR)/libglade.prepare

#
# dependencies
#
libglade_prepare_deps = \
	$(STATEDIR)/libglade.extract \
	$(STATEDIR)/gtk22.install \
	$(STATEDIR)/libxml2.install \
	$(STATEDIR)/virtual-xchain.install

LIBGLADE_PATH	=  PATH=$(CROSS_PATH)
LIBGLADE_ENV 	=  $(CROSS_ENV)
#LIBGLADE_ENV	+=
LIBGLADE_ENV	+= PKG_CONFIG_PATH=$(CROSS_LIB_DIR)/lib/pkgconfig:$(CROSS_LIB_DIR)/lib/pkgconfig
#ifdef PTXCONF_XFREE430
#LIBGLADE_ENV	+= LDFLAGS=-Wl,-rpath-link,$(CROSS_LIB_DIR)/lib
#endif

#
# autoconf
#
LIBGLADE_AUTOCONF = \
	--build=$(GNU_HOST) \
	--host=$(PTXCONF_GNU_TARGET) \
	--prefix=/usr

ifdef PTXCONF_XFREE430
LIBGLADE_AUTOCONF += --x-includes=$(CROSS_LIB_DIR)/include
LIBGLADE_AUTOCONF += --x-libraries=$(CROSS_LIB_DIR)/lib
endif

$(STATEDIR)/libglade.prepare: $(libglade_prepare_deps)
	@$(call targetinfo, $@)
	@$(call clean, $(LIBGLADE_DIR)/config.cache)
	cd $(LIBGLADE_DIR) && \
		$(LIBGLADE_PATH) $(LIBGLADE_ENV) \
		./configure $(LIBGLADE_AUTOCONF)
	cp -f $(PTXCONF_PREFIX)/bin/libtool $(LIBGLADE_DIR)/
	touch $@

# ----------------------------------------------------------------------------
# Compile
# ----------------------------------------------------------------------------

libglade_compile: $(STATEDIR)/libglade.compile

libglade_compile_deps = $(STATEDIR)/libglade.prepare

$(STATEDIR)/libglade.compile: $(libglade_compile_deps)
	@$(call targetinfo, $@)
	$(LIBGLADE_PATH) $(MAKE) -C $(LIBGLADE_DIR)
	touch $@

# ----------------------------------------------------------------------------
# Install
# ----------------------------------------------------------------------------

libglade_install: $(STATEDIR)/libglade.install

$(STATEDIR)/libglade.install: $(STATEDIR)/libglade.compile
	@$(call targetinfo, $@)
	$(LIBGLADE_PATH) $(MAKE) -C $(LIBGLADE_DIR) DESTDIR=$(LIBGLADE_IPKG_TMP) install
	cp -a  $(LIBGLADE_IPKG_TMP)/usr/include/* $(CROSS_LIB_DIR)/include
	cp -a  $(LIBGLADE_IPKG_TMP)/usr/lib/*     $(CROSS_LIB_DIR)/lib
	perl -p -i -e "s/\/usr\/lib/`echo $(PTXCONF_PREFIX)/$(PTXCONF_GNU_TARGET)/lib | sed -e '/\//s//\\\\\//g'`/g" $(PTXCONF_PREFIX)/$(PTXCONF_GNU_TARGET)/lib/libglade-2.0.la
	perl -p -i -e "s/\/usr/`echo $(PTXCONF_PREFIX)/$(PTXCONF_GNU_TARGET) | sed -e '/\//s//\\\\\//g'`/g" $(PTXCONF_PREFIX)/$(PTXCONF_GNU_TARGET)/lib/pkgconfig/libglade-2.0.pc
	rm -rf $(LIBGLADE_IPKG_TMP)
	touch $@

# ----------------------------------------------------------------------------
# Target-Install
# ----------------------------------------------------------------------------

libglade_targetinstall: $(STATEDIR)/libglade.targetinstall

libglade_targetinstall_deps = \
	$(STATEDIR)/libglade.compile \
	$(STATEDIR)/libxml2.targetinstall \
	$(STATEDIR)/gtk22.targetinstall

$(STATEDIR)/libglade.targetinstall: $(libglade_targetinstall_deps)
	@$(call targetinfo, $@)
	$(LIBGLADE_PATH) $(MAKE) -C $(LIBGLADE_DIR) DESTDIR=$(LIBGLADE_IPKG_TMP) install
	rm -rf $(LIBGLADE_IPKG_TMP)/usr/include
	rm -rf $(LIBGLADE_IPKG_TMP)/usr/lib/pkgconfig
	rm  -f $(LIBGLADE_IPKG_TMP)/usr/lib/*.*a
	rm -rf $(LIBGLADE_IPKG_TMP)/usr/share/gtk-doc
	$(CROSSSTRIP) $(LIBGLADE_IPKG_TMP)/usr/lib/*
	mkdir -p $(LIBGLADE_IPKG_TMP)/CONTROL
	echo "Package: libglade" 			>$(LIBGLADE_IPKG_TMP)/CONTROL/control
	echo "Priority: optional" 			>>$(LIBGLADE_IPKG_TMP)/CONTROL/control
	echo "Section: Libraries" 			>>$(LIBGLADE_IPKG_TMP)/CONTROL/control
	echo "Maintainer: Alexander Chukov <sash@pdaXrom.org>" >>$(LIBGLADE_IPKG_TMP)/CONTROL/control
	echo "Architecture: $(SHORT_TARGET)" 		>>$(LIBGLADE_IPKG_TMP)/CONTROL/control
	echo "Version: $(LIBGLADE_VERSION)" 		>>$(LIBGLADE_IPKG_TMP)/CONTROL/control
	echo "Depends: gtk2" 				>>$(LIBGLADE_IPKG_TMP)/CONTROL/control
	echo "Description: This library allows you to load glade interface files in a program at runtime.">>$(LIBGLADE_IPKG_TMP)/CONTROL/control
	cd $(FEEDDIR) && $(XMKIPKG) $(LIBGLADE_IPKG_TMP)
	touch $@

# ----------------------------------------------------------------------------
# Clean
# ----------------------------------------------------------------------------

libglade_clean:
	rm -rf $(STATEDIR)/libglade.*
	rm -rf $(LIBGLADE_DIR)

# vim: syntax=make
