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
ifdef PTXCONF_LIBXML2
PACKAGES += libxml2
endif

#
# Paths and names
#
LIBXML2_VENDOR_VERSION	= 1
LIBXML2_VERSION		= 2.6.13
LIBXML2			= libxml2-$(LIBXML2_VERSION)
LIBXML2_SUFFIX		= tar.bz2
LIBXML2_URL		= ftp://ftp.gnome.org/pub/GNOME/sources/libxml2/2.6/$(LIBXML2).$(LIBXML2_SUFFIX)
LIBXML2_SOURCE		= $(SRCDIR)/$(LIBXML2).$(LIBXML2_SUFFIX)
LIBXML2_DIR		= $(BUILDDIR)/$(LIBXML2)
LIBXML2_IPKG_TMP	= $(LIBXML2_DIR)/ipkg_tmp

# ----------------------------------------------------------------------------
# Get
# ----------------------------------------------------------------------------

libxml2_get: $(STATEDIR)/libxml2.get

libxml2_get_deps = $(LIBXML2_SOURCE)

$(STATEDIR)/libxml2.get: $(libxml2_get_deps)
	@$(call targetinfo, $@)
	@$(call get_patches, $(LIBXML2))
	touch $@

$(LIBXML2_SOURCE):
	@$(call targetinfo, $@)
	@$(call get, $(LIBXML2_URL))

# ----------------------------------------------------------------------------
# Extract
# ----------------------------------------------------------------------------

libxml2_extract: $(STATEDIR)/libxml2.extract

libxml2_extract_deps = $(STATEDIR)/libxml2.get

$(STATEDIR)/libxml2.extract: $(libxml2_extract_deps)
	@$(call targetinfo, $@)
	@$(call clean, $(LIBXML2_DIR))
	@$(call extract, $(LIBXML2_SOURCE))
	@$(call patchin, $(LIBXML2))
	touch $@

# ----------------------------------------------------------------------------
# Prepare
# ----------------------------------------------------------------------------

libxml2_prepare: $(STATEDIR)/libxml2.prepare

#
# dependencies
#
libxml2_prepare_deps = \
	$(STATEDIR)/libxml2.extract \
	$(STATEDIR)/zlib.install \
	$(STATEDIR)/virtual-xchain.install

ifdef PTXCONF_LIBICONV
libxml2_prepare_deps += $(STATEDIR)/libiconv.install
endif

LIBXML2_PATH	=  PATH=$(CROSS_PATH)
LIBXML2_ENV 	=  $(CROSS_ENV)
LIBXML2_ENV	+= CFLAGS="-O2 -fomit-frame-pointer"
LIBXML2_ENV	+= CXXFLAGS="-O2 -fomit-frame-pointer"
LIBXML2_ENV	+= PKG_CONFIG_PATH=$(CROSS_LIB_DIR)/lib/pkgconfig
#ifdef PTXCONF_XFREE430
#LIBXML2_ENV	+= LDFLAGS=-Wl,-rpath-link,$(CROSS_LIB_DIR)/X11R6/lib
#endif

#
# autoconf
#
LIBXML2_AUTOCONF = \
	--build=$(GNU_HOST) \
	--host=$(PTXCONF_GNU_TARGET) \
	--prefix=/usr \
	--disable-debug \
	--enable-shared \
	--disable-static \
	--sysconfdir=/etc

ifdef PTXCONF_XFREE430
LIBXML2_AUTOCONF += --x-includes=$(CROSS_LIB_DIR)/include
LIBXML2_AUTOCONF += --x-libraries=$(CROSS_LIB_DIR)/lib
endif

$(STATEDIR)/libxml2.prepare: $(libxml2_prepare_deps)
	@$(call targetinfo, $@)
	@$(call clean, $(LIBXML2_DIR)/config.cache)
	cd $(LIBXML2_DIR) && \
		$(LIBXML2_PATH) $(LIBXML2_ENV) \
		./configure $(LIBXML2_AUTOCONF)
	touch $@

# ----------------------------------------------------------------------------
# Compile
# ----------------------------------------------------------------------------

libxml2_compile: $(STATEDIR)/libxml2.compile

libxml2_compile_deps = $(STATEDIR)/libxml2.prepare

$(STATEDIR)/libxml2.compile: $(libxml2_compile_deps)
	@$(call targetinfo, $@)
	$(LIBXML2_PATH) $(MAKE) -C $(LIBXML2_DIR)
	touch $@

# ----------------------------------------------------------------------------
# Install
# ----------------------------------------------------------------------------

libxml2_install: $(STATEDIR)/libxml2.install

$(STATEDIR)/libxml2.install: $(STATEDIR)/libxml2.compile
	@$(call targetinfo, $@)
	rm -rf $(LIBXML2_IPKG_TMP)
	$(LIBXML2_PATH) $(MAKE) -C $(LIBXML2_DIR) DESTDIR=$(LIBXML2_IPKG_TMP) install
	cp -a $(LIBXML2_IPKG_TMP)/usr/include/*		$(CROSS_LIB_DIR)/include/
	cp -a $(LIBXML2_IPKG_TMP)/usr/lib/*		$(CROSS_LIB_DIR)/lib/
	cp -a $(LIBXML2_IPKG_TMP)/usr/share/aclocal/*	$(PTXCONF_PREFIX)/share/aclocal/
	cp -a $(LIBXML2_IPKG_TMP)/usr/bin/xml2-config	$(PTXCONF_PREFIX)/bin/

	perl -i -p -e "s,\/usr,$(CROSS_LIB_DIR),g"	$(CROSS_LIB_DIR)/lib/pkgconfig/libxml-2.0.pc
	perl -i -p -e "s,\/usr,$(CROSS_LIB_DIR),g"	$(CROSS_LIB_DIR)/lib/libxml2.la
	perl -i -p -e "s,\/usr,$(CROSS_LIB_DIR),g"	$(CROSS_LIB_DIR)/lib/xml2Conf.sh
	perl -i -p -e "s,\/usr,$(CROSS_LIB_DIR),g"	$(PTXCONF_PREFIX)/bin/xml2-config
	rm -rf $(LIBXML2_IPKG_TMP)
	touch $@

# ----------------------------------------------------------------------------
# Target-Install
# ----------------------------------------------------------------------------

libxml2_targetinstall: $(STATEDIR)/libxml2.targetinstall

libxml2_targetinstall_deps = $(STATEDIR)/libxml2.compile \
	$(STATEDIR)/zlib.targetinstall

ifdef PTXCONF_LIBICONV
libxml2_targetinstall_deps += $(STATEDIR)/libiconv.targetinstall
endif

$(STATEDIR)/libxml2.targetinstall: $(libxml2_targetinstall_deps)
	@$(call targetinfo, $@)
	$(LIBXML2_PATH) $(MAKE) -C $(LIBXML2_DIR) DESTDIR=$(LIBXML2_IPKG_TMP) install
	rm -rf $(LIBXML2_IPKG_TMP)/usr/bin/xml2-config
	rm -rf $(LIBXML2_IPKG_TMP)/usr/include
	rm -rf $(LIBXML2_IPKG_TMP)/usr/lib/pkgconfig
	rm -rf $(LIBXML2_IPKG_TMP)/usr/lib/*.*a
	rm -rf $(LIBXML2_IPKG_TMP)/usr/lib/*.sh
	rm -rf $(LIBXML2_IPKG_TMP)/usr/man
	rm -rf $(LIBXML2_IPKG_TMP)/usr/share
	$(CROSSSTRIP) $(LIBXML2_IPKG_TMP)/usr/bin/*
	$(CROSSSTRIP) $(LIBXML2_IPKG_TMP)/usr/lib/*.so*
	mkdir -p $(LIBXML2_IPKG_TMP)/CONTROL
	echo "Package: libxml2" 							 >$(LIBXML2_IPKG_TMP)/CONTROL/control
	echo "Priority: optional" 							>>$(LIBXML2_IPKG_TMP)/CONTROL/control
	echo "Section: Libraries" 							>>$(LIBXML2_IPKG_TMP)/CONTROL/control
	echo "Maintainer: Alexander Chukov <sash@pdaXrom.org>" 				>>$(LIBXML2_IPKG_TMP)/CONTROL/control
	echo "Architecture: $(SHORT_TARGET)" 						>>$(LIBXML2_IPKG_TMP)/CONTROL/control
	echo "Version: $(LIBXML2_VERSION)-$(LIBXML2_VENDOR_VERSION)" 			>>$(LIBXML2_IPKG_TMP)/CONTROL/control
	echo "Depends: " 								>>$(LIBXML2_IPKG_TMP)/CONTROL/control
	echo "Description: XML toolkit from the GNOME project"				>>$(LIBXML2_IPKG_TMP)/CONTROL/control
	cd $(FEEDDIR) && $(XMKIPKG) $(LIBXML2_IPKG_TMP)
	touch $@

# ----------------------------------------------------------------------------
# Image-Install
# ----------------------------------------------------------------------------

ifdef PTXCONF_LIBXML2_INSTALL
ROMPACKAGES += $(STATEDIR)/libxml2.imageinstall
endif

libxml2_imageinstall_deps = $(STATEDIR)/libxml2.targetinstall \
	$(STATEDIR)/virtual-image.install

$(STATEDIR)/libxml2.imageinstall: $(libxml2_imageinstall_deps)
	@$(call targetinfo, $@)
	cd $(FEEDDIR) && $(XIPKG) install libxml2
	touch $@

# ----------------------------------------------------------------------------
# Clean
# ----------------------------------------------------------------------------

libxml2_clean:
	rm -rf $(STATEDIR)/libxml2.*
	rm -rf $(LIBXML2_DIR)

# vim: syntax=make
