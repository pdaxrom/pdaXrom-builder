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
ifdef PTXCONF_LIBGNOMECANVAS
PACKAGES += libgnomecanvas
endif

#
# Paths and names
#
###LIBGNOMECANVAS_VERSION		= 2.5.92
LIBGNOMECANVAS_VERSION		= 2.6.1.1
LIBGNOMECANVAS			= libgnomecanvas-$(LIBGNOMECANVAS_VERSION)
LIBGNOMECANVAS_SUFFIX		= tar.bz2
LIBGNOMECANVAS_URL		= ftp://ftp.gnome.org/pub/GNOME/sources/libgnomecanvas/2.6/$(LIBGNOMECANVAS).$(LIBGNOMECANVAS_SUFFIX)
LIBGNOMECANVAS_SOURCE		= $(SRCDIR)/$(LIBGNOMECANVAS).$(LIBGNOMECANVAS_SUFFIX)
LIBGNOMECANVAS_DIR		= $(BUILDDIR)/$(LIBGNOMECANVAS)
LIBGNOMECANVAS_IPKG_TMP		= $(LIBGNOMECANVAS_DIR)/ipkg_tmp

# ----------------------------------------------------------------------------
# Get
# ----------------------------------------------------------------------------

libgnomecanvas_get: $(STATEDIR)/libgnomecanvas.get

libgnomecanvas_get_deps = $(LIBGNOMECANVAS_SOURCE)

$(STATEDIR)/libgnomecanvas.get: $(libgnomecanvas_get_deps)
	@$(call targetinfo, $@)
	@$(call get_patches, $(LIBGNOMECANVAS))
	touch $@

$(LIBGNOMECANVAS_SOURCE):
	@$(call targetinfo, $@)
	@$(call get, $(LIBGNOMECANVAS_URL))

# ----------------------------------------------------------------------------
# Extract
# ----------------------------------------------------------------------------

libgnomecanvas_extract: $(STATEDIR)/libgnomecanvas.extract

libgnomecanvas_extract_deps = $(STATEDIR)/libgnomecanvas.get

$(STATEDIR)/libgnomecanvas.extract: $(libgnomecanvas_extract_deps)
	@$(call targetinfo, $@)
	@$(call clean, $(LIBGNOMECANVAS_DIR))
	@$(call extract, $(LIBGNOMECANVAS_SOURCE))
	@$(call patchin, $(LIBGNOMECANVAS))
	touch $@

# ----------------------------------------------------------------------------
# Prepare
# ----------------------------------------------------------------------------

libgnomecanvas_prepare: $(STATEDIR)/libgnomecanvas.prepare

#
# dependencies
#
libgnomecanvas_prepare_deps = \
	$(STATEDIR)/libgnomecanvas.extract \
	$(STATEDIR)/libart_lgpl.install \
	$(STATEDIR)/virtual-xchain.install

LIBGNOMECANVAS_PATH	=  PATH=$(CROSS_PATH)
LIBGNOMECANVAS_ENV 	=  $(CROSS_ENV)
LIBGNOMECANVAS_ENV	+= CFLAGS="-O2 -fomit-frame-pointer"
LIBGNOMECANVAS_ENV	+= PKG_CONFIG_PATH=$(CROSS_LIB_DIR)/lib/pkgconfig:$(CROSS_LIB_DIR)/lib/pkgconfig
#ifdef PTXCONF_XFREE430
#LIBGNOMECANVAS_ENV	+= LDFLAGS=-Wl,-rpath-link,$(CROSS_LIB_DIR)/lib
#endif

#
# autoconf
#
LIBGNOMECANVAS_AUTOCONF = \
	--build=$(GNU_HOST) \
	--host=$(PTXCONF_GNU_TARGET) \
	--prefix=/usr \
	--enable-shared \
	--disable-static \
	--sysconfdir=/etc \
	--libexecdir=/usr/bin \
	--disable-debug

ifdef PTXCONF_XFREE430
LIBGNOMECANVAS_AUTOCONF += --x-includes=$(CROSS_LIB_DIR)/include
LIBGNOMECANVAS_AUTOCONF += --x-libraries=$(CROSS_LIB_DIR)/lib
endif

$(STATEDIR)/libgnomecanvas.prepare: $(libgnomecanvas_prepare_deps)
	@$(call targetinfo, $@)
	@$(call clean, $(LIBGNOMECANVAS_DIR)/config.cache)
	cd $(LIBGNOMECANVAS_DIR) && \
		$(LIBGNOMECANVAS_PATH) $(LIBGNOMECANVAS_ENV) \
		./configure $(LIBGNOMECANVAS_AUTOCONF)
	cp -f $(PTXCONF_PREFIX)/bin/libtool $(LIBGNOMECANVAS_DIR)
	touch $@

# ----------------------------------------------------------------------------
# Compile
# ----------------------------------------------------------------------------

libgnomecanvas_compile: $(STATEDIR)/libgnomecanvas.compile

libgnomecanvas_compile_deps = $(STATEDIR)/libgnomecanvas.prepare

$(STATEDIR)/libgnomecanvas.compile: $(libgnomecanvas_compile_deps)
	@$(call targetinfo, $@)
	$(LIBGNOMECANVAS_PATH) $(MAKE) -C $(LIBGNOMECANVAS_DIR)
	touch $@

# ----------------------------------------------------------------------------
# Install
# ----------------------------------------------------------------------------

libgnomecanvas_install: $(STATEDIR)/libgnomecanvas.install

$(STATEDIR)/libgnomecanvas.install: $(STATEDIR)/libgnomecanvas.compile
	@$(call targetinfo, $@)
	$(LIBGNOMECANVAS_PATH) $(MAKE) -C $(LIBGNOMECANVAS_DIR) DESTDIR=$(LIBGNOMECANVAS_IPKG_TMP) install
	cp -a  $(LIBGNOMECANVAS_IPKG_TMP)/usr/include/*          $(CROSS_LIB_DIR)/include
	cp -a  $(LIBGNOMECANVAS_IPKG_TMP)/usr/lib/*              $(CROSS_LIB_DIR)/lib
	perl -p -i -e "s/\/usr\/lib/`echo $(PTXCONF_PREFIX)/$(PTXCONF_GNU_TARGET)/lib | sed -e '/\//s//\\\\\//g'`/g" $(PTXCONF_PREFIX)/$(PTXCONF_GNU_TARGET)/lib/libgnomecanvas-2.la
	perl -p -i -e "s/\/usr/`echo $(PTXCONF_PREFIX)/$(PTXCONF_GNU_TARGET) | sed -e '/\//s//\\\\\//g'`/g" $(PTXCONF_PREFIX)/$(PTXCONF_GNU_TARGET)/lib/pkgconfig/libgnomecanvas-2.0.pc
	rm -rf $(LIBGNOMECANVAS_IPKG_TMP)
	touch $@

# ----------------------------------------------------------------------------
# Target-Install
# ----------------------------------------------------------------------------

libgnomecanvas_targetinstall: $(STATEDIR)/libgnomecanvas.targetinstall

libgnomecanvas_targetinstall_deps = \
	$(STATEDIR)/libgnomecanvas.compile \
	$(STATEDIR)/libart_lgpl.targetinstall

$(STATEDIR)/libgnomecanvas.targetinstall: $(libgnomecanvas_targetinstall_deps)
	@$(call targetinfo, $@)
	$(LIBGNOMECANVAS_PATH) $(MAKE) -C $(LIBGNOMECANVAS_DIR) DESTDIR=$(LIBGNOMECANVAS_IPKG_TMP) install
	rm -rf $(LIBGNOMECANVAS_IPKG_TMP)/usr/include
	rm -rf $(LIBGNOMECANVAS_IPKG_TMP)/usr/share
	rm -rf $(LIBGNOMECANVAS_IPKG_TMP)/usr/lib/pkgconfig
	rm -rf $(LIBGNOMECANVAS_IPKG_TMP)/usr/lib/*.*a
	rm -rf $(LIBGNOMECANVAS_IPKG_TMP)/usr/lib/libglade/2.0/*.a
	###rm -rf $(LIBGNOMECANVAS_IPKG_TMP)/usr/lib/libglade/2.0/*.la
	$(CROSSSTRIP) $(LIBGNOMECANVAS_IPKG_TMP)/usr/lib/libglade/2.0/*.so*
	$(CROSSSTRIP) $(LIBGNOMECANVAS_IPKG_TMP)/usr/lib/*.so*
	mkdir -p $(LIBGNOMECANVAS_IPKG_TMP)/CONTROL
	echo "Package: libgnomecanvas" 			>$(LIBGNOMECANVAS_IPKG_TMP)/CONTROL/control
	echo "Priority: optional" 			>>$(LIBGNOMECANVAS_IPKG_TMP)/CONTROL/control
	echo "Section: Gnome"	 			>>$(LIBGNOMECANVAS_IPKG_TMP)/CONTROL/control
	echo "Maintainer: Alexander Chukov <sash@pdaXrom.org>">>$(LIBGNOMECANVAS_IPKG_TMP)/CONTROL/control
	echo "Architecture: $(SHORT_TARGET)" 		>>$(LIBGNOMECANVAS_IPKG_TMP)/CONTROL/control
	echo "Version: $(LIBGNOMECANVAS_VERSION)" 	>>$(LIBGNOMECANVAS_IPKG_TMP)/CONTROL/control
	echo "Depends: libart-lgpl" 			>>$(LIBGNOMECANVAS_IPKG_TMP)/CONTROL/control
	echo "Description: The GNOME canvas is an engine for structured graphics that offers a rich imaging model, high performance rendering, and a powerful, high-level API.">>$(LIBGNOMECANVAS_IPKG_TMP)/CONTROL/control
	cd $(FEEDDIR) && $(XMKIPKG) $(LIBGNOMECANVAS_IPKG_TMP)
	touch $@

# ----------------------------------------------------------------------------
# Clean
# ----------------------------------------------------------------------------

libgnomecanvas_clean:
	rm -rf $(STATEDIR)/libgnomecanvas.*
	rm -rf $(LIBGNOMECANVAS_DIR)

# vim: syntax=make
