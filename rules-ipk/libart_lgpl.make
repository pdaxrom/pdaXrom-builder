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
ifdef PTXCONF_LIBART_LGPL
PACKAGES += libart_lgpl
endif

#
# Paths and names
#
LIBART_LGPL_VERSION	= 2.3.16
LIBART_LGPL		= libart_lgpl-$(LIBART_LGPL_VERSION)
LIBART_LGPL_SUFFIX	= tar.bz2
LIBART_LGPL_URL		= ftp://ftp.gnome.org/pub/GNOME/sources/libart_lgpl/2.3/$(LIBART_LGPL).$(LIBART_LGPL_SUFFIX)
LIBART_LGPL_SOURCE	= $(SRCDIR)/$(LIBART_LGPL).$(LIBART_LGPL_SUFFIX)
LIBART_LGPL_DIR		= $(BUILDDIR)/$(LIBART_LGPL)
LIBART_LGPL_IPKG_TMP	= $(LIBART_LGPL_DIR)/ipkg_tmp

# ----------------------------------------------------------------------------
# Get
# ----------------------------------------------------------------------------

libart_lgpl_get: $(STATEDIR)/libart_lgpl.get

libart_lgpl_get_deps = $(LIBART_LGPL_SOURCE)

$(STATEDIR)/libart_lgpl.get: $(libart_lgpl_get_deps)
	@$(call targetinfo, $@)
	@$(call get_patches, $(LIBART_LGPL))
	touch $@

$(LIBART_LGPL_SOURCE):
	@$(call targetinfo, $@)
	@$(call get, $(LIBART_LGPL_URL))

# ----------------------------------------------------------------------------
# Extract
# ----------------------------------------------------------------------------

libart_lgpl_extract: $(STATEDIR)/libart_lgpl.extract

libart_lgpl_extract_deps = $(STATEDIR)/libart_lgpl.get

$(STATEDIR)/libart_lgpl.extract: $(libart_lgpl_extract_deps)
	@$(call targetinfo, $@)
	@$(call clean, $(LIBART_LGPL_DIR))
	@$(call extract, $(LIBART_LGPL_SOURCE))
	@$(call patchin, $(LIBART_LGPL))
	touch $@

# ----------------------------------------------------------------------------
# Prepare
# ----------------------------------------------------------------------------

libart_lgpl_prepare: $(STATEDIR)/libart_lgpl.prepare

#
# dependencies
#
libart_lgpl_prepare_deps = \
	$(STATEDIR)/libart_lgpl.extract \
	$(STATEDIR)/virtual-xchain.install

LIBART_LGPL_PATH = PATH=$(CROSS_PATH)
LIBART_LGPL_ENV  = $(CROSS_ENV)
LIBART_LGPL_ENV	+= CFLAGS="-O2 -fomit-frame-pointer"
LIBART_LGPL_ENV	+= PKG_CONFIG_PATH=$(CROSS_LIB_DIR)/lib/pkgconfig:$(CROSS_LIB_DIR)/lib/pkgconfig
#ifdef PTXCONF_XFREE430
#LIBART_LGPL_ENV	+= LDFLAGS=-Wl,-rpath-link,$(CROSS_LIB_DIR)/lib
#endif

#
# autoconf
#
LIBART_LGPL_AUTOCONF = \
	--build=$(GNU_HOST) \
	--host=$(PTXCONF_GNU_TARGET) \
	--prefix=/usr \
	--enable-shared \
	--disable-static \
	--sysconfdir=/etc \
	--libexecdir=/usr/bin \
	--disable-debug

ifdef PTXCONF_XFREE430
LIBART_LGPL_AUTOCONF += --x-includes=$(CROSS_LIB_DIR)/include
LIBART_LGPL_AUTOCONF += --x-libraries=$(CROSS_LIB_DIR)/lib
endif

$(STATEDIR)/libart_lgpl.prepare: $(libart_lgpl_prepare_deps)
	@$(call targetinfo, $@)
	@$(call clean, $(LIBART_LGPL_DIR)/config.cache)
	cd $(LIBART_LGPL_DIR) && \
		$(LIBART_LGPL_PATH) $(LIBART_LGPL_ENV) \
		./configure $(LIBART_LGPL_AUTOCONF)
	touch $@

# ----------------------------------------------------------------------------
# Compile
# ----------------------------------------------------------------------------

libart_lgpl_compile: $(STATEDIR)/libart_lgpl.compile

libart_lgpl_compile_deps = $(STATEDIR)/libart_lgpl.prepare

$(STATEDIR)/libart_lgpl.compile: $(libart_lgpl_compile_deps)
	@$(call targetinfo, $@)
	$(LIBART_LGPL_PATH) $(MAKE) -C $(LIBART_LGPL_DIR)
	touch $@

# ----------------------------------------------------------------------------
# Install
# ----------------------------------------------------------------------------

libart_lgpl_install: $(STATEDIR)/libart_lgpl.install

$(STATEDIR)/libart_lgpl.install: $(STATEDIR)/libart_lgpl.compile
	@$(call targetinfo, $@)
	$(LIBART_LGPL_PATH) $(MAKE) -C $(LIBART_LGPL_DIR) DESTDIR=$(LIBART_LGPL_IPKG_TMP) install
	cp -a  $(LIBART_LGPL_IPKG_TMP)/usr/include/*          $(CROSS_LIB_DIR)/include
	cp -a  $(LIBART_LGPL_IPKG_TMP)/usr/lib/*              $(CROSS_LIB_DIR)/lib
	cp -a  $(LIBART_LGPL_IPKG_TMP)/usr/bin/libart2-config $(PTXCONF_PREFIX)/bin
	perl -p -i -e "s/\/usr/`echo $(PTXCONF_PREFIX)/$(PTXCONF_GNU_TARGET) | sed -e '/\//s//\\\\\//g'`/g" $(PTXCONF_PREFIX)/bin/libart2-config
	perl -p -i -e "s/\/usr\/lib/`echo $(PTXCONF_PREFIX)/$(PTXCONF_GNU_TARGET)/lib | sed -e '/\//s//\\\\\//g'`/g" $(PTXCONF_PREFIX)/$(PTXCONF_GNU_TARGET)/lib/libart_lgpl_2.la
	perl -p -i -e "s/\/usr/`echo $(PTXCONF_PREFIX)/$(PTXCONF_GNU_TARGET) | sed -e '/\//s//\\\\\//g'`/g" $(PTXCONF_PREFIX)/$(PTXCONF_GNU_TARGET)/lib/pkgconfig/libart-2.0.pc
	rm -rf $(LIBART_LGPL_IPKG_TMP)
	touch $@

# ----------------------------------------------------------------------------
# Target-Install
# ----------------------------------------------------------------------------

libart_lgpl_targetinstall: $(STATEDIR)/libart_lgpl.targetinstall

libart_lgpl_targetinstall_deps = $(STATEDIR)/libart_lgpl.compile

$(STATEDIR)/libart_lgpl.targetinstall: $(libart_lgpl_targetinstall_deps)
	@$(call targetinfo, $@)
	$(LIBART_LGPL_PATH) $(MAKE) -C $(LIBART_LGPL_DIR) DESTDIR=$(LIBART_LGPL_IPKG_TMP) install
	rm -rf $(LIBART_LGPL_IPKG_TMP)/usr/bin
	rm -rf $(LIBART_LGPL_IPKG_TMP)/usr/include
	rm -rf $(LIBART_LGPL_IPKG_TMP)/usr/lib/pkgconfig
	rm -rf $(LIBART_LGPL_IPKG_TMP)/usr/lib/*.*a
	$(CROSSSTRIP) $(LIBART_LGPL_IPKG_TMP)/usr/lib/*
	mkdir -p $(LIBART_LGPL_IPKG_TMP)/CONTROL
	echo "Package: libart-lgpl" 			>$(LIBART_LGPL_IPKG_TMP)/CONTROL/control
	echo "Priority: optional" 			>>$(LIBART_LGPL_IPKG_TMP)/CONTROL/control
	echo "Section: Gnome"	 			>>$(LIBART_LGPL_IPKG_TMP)/CONTROL/control
	echo "Maintainer: Alexander Chukov <sash@pdaXrom.org>" >>$(LIBART_LGPL_IPKG_TMP)/CONTROL/control
	echo "Architecture: $(SHORT_TARGET)" 		>>$(LIBART_LGPL_IPKG_TMP)/CONTROL/control
	echo "Version: $(LIBART_LGPL_VERSION)" 		>>$(LIBART_LGPL_IPKG_TMP)/CONTROL/control
	echo "Depends: " 				>>$(LIBART_LGPL_IPKG_TMP)/CONTROL/control
	echo "Description: This is the LGPL'd component of libart. All functions needed for running the Gnome canvas, and for printing support, will be going in here. The GPL'd component will be getting various enhanced functions for specific applications.">>$(LIBART_LGPL_IPKG_TMP)/CONTROL/control
	cd $(FEEDDIR) && $(XMKIPKG) $(LIBART_LGPL_IPKG_TMP)
	touch $@

# ----------------------------------------------------------------------------
# Clean
# ----------------------------------------------------------------------------

libart_lgpl_clean:
	rm -rf $(STATEDIR)/libart_lgpl.*
	rm -rf $(LIBART_LGPL_DIR)

# vim: syntax=make
