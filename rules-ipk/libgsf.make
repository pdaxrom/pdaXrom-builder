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
ifdef PTXCONF_LIBGSF
PACKAGES += libgsf
endif

#
# Paths and names
#
#LIBGSF_VERSION		= 1.9.1
LIBGSF_VERSION		= 1.10.1
LIBGSF			= libgsf-$(LIBGSF_VERSION)
LIBGSF_SUFFIX		= tar.bz2
LIBGSF_URL		= http://ftp.acc.umu.se/pub/GNOME/sources/libgsf/1.10/$(LIBGSF).$(LIBGSF_SUFFIX)
LIBGSF_SOURCE		= $(SRCDIR)/$(LIBGSF).$(LIBGSF_SUFFIX)
LIBGSF_DIR		= $(BUILDDIR)/$(LIBGSF)
LIBGSF_IPKG_TMP		= $(LIBGSF_DIR)/ipkg_tmp

# ----------------------------------------------------------------------------
# Get
# ----------------------------------------------------------------------------

libgsf_get: $(STATEDIR)/libgsf.get

libgsf_get_deps = $(LIBGSF_SOURCE)

$(STATEDIR)/libgsf.get: $(libgsf_get_deps)
	@$(call targetinfo, $@)
	@$(call get_patches, $(LIBGSF))
	touch $@

$(LIBGSF_SOURCE):
	@$(call targetinfo, $@)
	@$(call get, $(LIBGSF_URL))

# ----------------------------------------------------------------------------
# Extract
# ----------------------------------------------------------------------------

libgsf_extract: $(STATEDIR)/libgsf.extract

libgsf_extract_deps = $(STATEDIR)/libgsf.get

$(STATEDIR)/libgsf.extract: $(libgsf_extract_deps)
	@$(call targetinfo, $@)
	@$(call clean, $(LIBGSF_DIR))
	@$(call extract, $(LIBGSF_SOURCE))
	@$(call patchin, $(LIBGSF))
	touch $@

# ----------------------------------------------------------------------------
# Prepare
# ----------------------------------------------------------------------------

libgsf_prepare: $(STATEDIR)/libgsf.prepare

#
# dependencies
#
libgsf_prepare_deps = \
	$(STATEDIR)/libgsf.extract \
	$(STATEDIR)/glib22.install \
	$(STATEDIR)/libxml2.install \
	$(STATEDIR)/zlib.install \
	$(STATEDIR)/libgnome.install \
	$(STATEDIR)/libgnomeprintui.install \
	$(STATEDIR)/virtual-xchain.install

ifdef PTXCONF_LIBICONV
libgsf_prepare_deps += $(STATEDIR)/libiconv.install
endif

LIBGSF_PATH	=  PATH=$(CROSS_PATH)
LIBGSF_ENV 	=  $(CROSS_ENV)
#LIBGSF_ENV	+=
LIBGSF_ENV	+= PKG_CONFIG_PATH=$(CROSS_LIB_DIR)/lib/pkgconfig:$(CROSS_LIB_DIR)/lib/pkgconfig
#ifdef PTXCONF_XFREE430
#LIBGSF_ENV	+= LDFLAGS=-Wl,-rpath-link,$(CROSS_LIB_DIR)/lib
#endif

#
# autoconf
#
LIBGSF_AUTOCONF = \
	--build=$(GNU_HOST) \
	--host=$(PTXCONF_GNU_TARGET) \
	--prefix=/usr \
	--enable-shared \
	--disable-static

ifdef PTXCONF_XFREE430
LIBGSF_AUTOCONF += --x-includes=$(CROSS_LIB_DIR)/include
LIBGSF_AUTOCONF += --x-libraries=$(CROSS_LIB_DIR)/lib
endif

$(STATEDIR)/libgsf.prepare: $(libgsf_prepare_deps)
	@$(call targetinfo, $@)
	@$(call clean, $(LIBGSF_DIR)/config.cache)
	cd $(LIBGSF_DIR) && \
		$(LIBGSF_PATH) $(LIBGSF_ENV) \
		./configure $(LIBGSF_AUTOCONF)
	cp -f $(PTXCONF_PREFIX)/bin/libtool $(LIBGSF_DIR)
	touch $@

# ----------------------------------------------------------------------------
# Compile
# ----------------------------------------------------------------------------

libgsf_compile: $(STATEDIR)/libgsf.compile

libgsf_compile_deps = $(STATEDIR)/libgsf.prepare

$(STATEDIR)/libgsf.compile: $(libgsf_compile_deps)
	@$(call targetinfo, $@)
	$(LIBGSF_PATH) $(MAKE) -C $(LIBGSF_DIR)
	touch $@

# ----------------------------------------------------------------------------
# Install
# ----------------------------------------------------------------------------

libgsf_install: $(STATEDIR)/libgsf.install

$(STATEDIR)/libgsf.install: $(STATEDIR)/libgsf.compile
	@$(call targetinfo, $@)
	$(LIBGSF_PATH) $(MAKE) -C $(LIBGSF_DIR) DESTDIR=$(LIBGSF_IPKG_TMP) install
	cp -a  $(LIBGSF_IPKG_TMP)/usr/include/* $(CROSS_LIB_DIR)/include
	cp -a  $(LIBGSF_IPKG_TMP)/usr/lib/*     $(CROSS_LIB_DIR)/lib
	perl -p -i -e "s/\/usr\/lib/`echo $(PTXCONF_PREFIX)/$(PTXCONF_GNU_TARGET)/lib | sed -e '/\//s//\\\\\//g'`/g" $(PTXCONF_PREFIX)/$(PTXCONF_GNU_TARGET)/lib/libgsf-1.la
	perl -p -i -e "s/\/usr/`echo $(PTXCONF_PREFIX)/$(PTXCONF_GNU_TARGET) | sed -e '/\//s//\\\\\//g'`/g" $(PTXCONF_PREFIX)/$(PTXCONF_GNU_TARGET)/lib/pkgconfig/libgsf-1.pc
	perl -p -i -e "s/\/usr\/lib/`echo $(PTXCONF_PREFIX)/$(PTXCONF_GNU_TARGET)/lib | sed -e '/\//s//\\\\\//g'`/g" $(PTXCONF_PREFIX)/$(PTXCONF_GNU_TARGET)/lib/libgsf-gnome-1.la
	perl -p -i -e "s/\/usr/`echo $(PTXCONF_PREFIX)/$(PTXCONF_GNU_TARGET) | sed -e '/\//s//\\\\\//g'`/g" $(PTXCONF_PREFIX)/$(PTXCONF_GNU_TARGET)/lib/pkgconfig/libgsf-gnome-1.pc
	rm -rf $(LIBGSF_IPKG_TMP)
	touch $@

# ----------------------------------------------------------------------------
# Target-Install
# ----------------------------------------------------------------------------

libgsf_targetinstall: $(STATEDIR)/libgsf.targetinstall

libgsf_targetinstall_deps = \
	$(STATEDIR)/libgsf.compile \
	$(STATEDIR)/libgnome.targetinstall \
	$(STATEDIR)/libgnomeprintui.targetinstall

$(STATEDIR)/libgsf.targetinstall: $(libgsf_targetinstall_deps)
	@$(call targetinfo, $@)
	$(LIBGSF_PATH) $(MAKE) -C $(LIBGSF_DIR) DESTDIR=$(LIBGSF_IPKG_TMP) install
	rm -rf $(LIBGSF_IPKG_TMP)/usr/include
	rm -rf $(LIBGSF_IPKG_TMP)/usr/lib/pkgconfig
	rm -rf $(LIBGSF_IPKG_TMP)/usr/lib/*.*a
	rm -rf $(LIBGSF_IPKG_TMP)/usr/share
	$(CROSSSTRIP) $(LIBGSF_IPKG_TMP)/usr/lib/*
	mkdir -p $(LIBGSF_IPKG_TMP)/CONTROL
	echo "Package: libgsf" 				>$(LIBGSF_IPKG_TMP)/CONTROL/control
	echo "Priority: optional" 			>>$(LIBGSF_IPKG_TMP)/CONTROL/control
	echo "Section: Gnome"	 			>>$(LIBGSF_IPKG_TMP)/CONTROL/control
	echo "Maintainer: Alexander Chukov <sash@pdaXrom.org>">>$(LIBGSF_IPKG_TMP)/CONTROL/control
	echo "Architecture: $(SHORT_TARGET)" 		>>$(LIBGSF_IPKG_TMP)/CONTROL/control
	echo "Version: $(LIBGSF_VERSION)" 		>>$(LIBGSF_IPKG_TMP)/CONTROL/control
	echo "Depends: gtk2" 				>>$(LIBGSF_IPKG_TMP)/CONTROL/control
	echo "Description: The G Structured File Library">>$(LIBGSF_IPKG_TMP)/CONTROL/control
	cd $(FEEDDIR) && $(XMKIPKG) $(LIBGSF_IPKG_TMP)
	touch $@

# ----------------------------------------------------------------------------
# Clean
# ----------------------------------------------------------------------------

libgsf_clean:
	rm -rf $(STATEDIR)/libgsf.*
	rm -rf $(LIBGSF_DIR)

# vim: syntax=make
