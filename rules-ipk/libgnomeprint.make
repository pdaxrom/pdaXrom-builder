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
ifdef PTXCONF_LIBGNOMEPRINT
PACKAGES += libgnomeprint
endif

#
# Paths and names
#
#LIBGNOMEPRINT_VERSION	= 2.4.2
LIBGNOMEPRINT_VERSION	= 2.6.2
#LIBGNOMEPRINT_VERSION	= 2.8.0.1
LIBGNOMEPRINT		= libgnomeprint-$(LIBGNOMEPRINT_VERSION)
LIBGNOMEPRINT_SUFFIX	= tar.bz2
LIBGNOMEPRINT_URL	= http://ftp.acc.umu.se/pub/GNOME/sources/libgnomeprint/2.6/$(LIBGNOMEPRINT).$(LIBGNOMEPRINT_SUFFIX)
LIBGNOMEPRINT_SOURCE	= $(SRCDIR)/$(LIBGNOMEPRINT).$(LIBGNOMEPRINT_SUFFIX)
LIBGNOMEPRINT_DIR	= $(BUILDDIR)/$(LIBGNOMEPRINT)
LIBGNOMEPRINT_IPKG_TMP	= $(LIBGNOMEPRINT_DIR)/ipkg_tmp

# ----------------------------------------------------------------------------
# Get
# ----------------------------------------------------------------------------

libgnomeprint_get: $(STATEDIR)/libgnomeprint.get

libgnomeprint_get_deps = $(LIBGNOMEPRINT_SOURCE)

$(STATEDIR)/libgnomeprint.get: $(libgnomeprint_get_deps)
	@$(call targetinfo, $@)
	@$(call get_patches, $(LIBGNOMEPRINT))
	touch $@

$(LIBGNOMEPRINT_SOURCE):
	@$(call targetinfo, $@)
	@$(call get, $(LIBGNOMEPRINT_URL))

# ----------------------------------------------------------------------------
# Extract
# ----------------------------------------------------------------------------

libgnomeprint_extract: $(STATEDIR)/libgnomeprint.extract

libgnomeprint_extract_deps = $(STATEDIR)/libgnomeprint.get

$(STATEDIR)/libgnomeprint.extract: $(libgnomeprint_extract_deps)
	@$(call targetinfo, $@)
	@$(call clean, $(LIBGNOMEPRINT_DIR))
	@$(call extract, $(LIBGNOMEPRINT_SOURCE))
	@$(call patchin, $(LIBGNOMEPRINT))
	touch $@

# ----------------------------------------------------------------------------
# Prepare
# ----------------------------------------------------------------------------

libgnomeprint_prepare: $(STATEDIR)/libgnomeprint.prepare

#
# dependencies
#
libgnomeprint_prepare_deps = \
	$(STATEDIR)/libgnomeprint.extract \
	$(STATEDIR)/libxml2.install \
	$(STATEDIR)/glib22.install \
	$(STATEDIR)/virtual-xchain.install

LIBGNOMEPRINT_PATH	=  PATH=$(CROSS_PATH)
LIBGNOMEPRINT_ENV 	=  $(CROSS_ENV)
LIBGNOMEPRINT_ENV	+= CFLAGS="-O2 -fomit-frame-pointer"
LIBGNOMEPRINT_ENV	+= PKG_CONFIG_PATH=$(CROSS_LIB_DIR)/lib/pkgconfig:$(CROSS_LIB_DIR)/lib/pkgconfig
#ifdef PTXCONF_XFREE430
#LIBGNOMEPRINT_ENV	+= LDFLAGS=-Wl,-rpath-link,$(CROSS_LIB_DIR)/lib
#endif

#
# autoconf
#
LIBGNOMEPRINT_AUTOCONF = \
	--build=$(GNU_HOST) \
	--host=$(PTXCONF_GNU_TARGET) \
	--prefix=/usr \
	--enable-shared \
	--disable-static \
	--sysconfdir=/etc \
	--libexecdir=/usr/bin \
	--disable-debug

ifdef PTXCONF_XFREE430
LIBGNOMEPRINT_AUTOCONF += --x-includes=$(CROSS_LIB_DIR)/include
LIBGNOMEPRINT_AUTOCONF += --x-libraries=$(CROSS_LIB_DIR)/lib
endif

$(STATEDIR)/libgnomeprint.prepare: $(libgnomeprint_prepare_deps)
	@$(call targetinfo, $@)
	@$(call clean, $(LIBGNOMEPRINT_DIR)/config.cache)
	cd $(LIBGNOMEPRINT_DIR) && \
		$(LIBGNOMEPRINT_PATH) $(LIBGNOMEPRINT_ENV) \
		./configure $(LIBGNOMEPRINT_AUTOCONF)
	cp -f $(PTXCONF_PREFIX)/bin/libtool $(LIBGNOMEPRINT_DIR)
	touch $@

# ----------------------------------------------------------------------------
# Compile
# ----------------------------------------------------------------------------

libgnomeprint_compile: $(STATEDIR)/libgnomeprint.compile

libgnomeprint_compile_deps = $(STATEDIR)/libgnomeprint.prepare

$(STATEDIR)/libgnomeprint.compile: $(libgnomeprint_compile_deps)
	@$(call targetinfo, $@)
	$(LIBGNOMEPRINT_PATH) $(MAKE) -C $(LIBGNOMEPRINT_DIR)
	touch $@

# ----------------------------------------------------------------------------
# Install
# ----------------------------------------------------------------------------

libgnomeprint_install: $(STATEDIR)/libgnomeprint.install

$(STATEDIR)/libgnomeprint.install: $(STATEDIR)/libgnomeprint.compile
	@$(call targetinfo, $@)
	$(LIBGNOMEPRINT_PATH) $(MAKE) -C $(LIBGNOMEPRINT_DIR) DESTDIR=$(LIBGNOMEPRINT_IPKG_TMP) install
	cp -a  $(LIBGNOMEPRINT_IPKG_TMP)/usr/include/*          $(CROSS_LIB_DIR)/include
	cp -a  $(LIBGNOMEPRINT_IPKG_TMP)/usr/lib/*              $(CROSS_LIB_DIR)/lib
	perl -p -i -e "s/\/usr\/lib/`echo $(PTXCONF_PREFIX)/$(PTXCONF_GNU_TARGET)/lib | sed -e '/\//s//\\\\\//g'`/g" $(PTXCONF_PREFIX)/$(PTXCONF_GNU_TARGET)/lib/libgnomeprint-2-2.la
	perl -p -i -e "s/\/usr/`echo $(PTXCONF_PREFIX)/$(PTXCONF_GNU_TARGET) | sed -e '/\//s//\\\\\//g'`/g" $(PTXCONF_PREFIX)/$(PTXCONF_GNU_TARGET)/lib/pkgconfig/libgnomeprint-2.2.pc
	rm -rf $(LIBGNOMEPRINT_IPKG_TMP)
	touch $@

# ----------------------------------------------------------------------------
# Target-Install
# ----------------------------------------------------------------------------

libgnomeprint_targetinstall: $(STATEDIR)/libgnomeprint.targetinstall

libgnomeprint_targetinstall_deps = $(STATEDIR)/libgnomeprint.compile

$(STATEDIR)/libgnomeprint.targetinstall: $(libgnomeprint_targetinstall_deps)
	@$(call targetinfo, $@)
	$(LIBGNOMEPRINT_PATH) $(MAKE) -C $(LIBGNOMEPRINT_DIR) DESTDIR=$(LIBGNOMEPRINT_IPKG_TMP) install
	rm -rf $(LIBGNOMEPRINT_IPKG_TMP)/usr/include
	rm -rf $(LIBGNOMEPRINT_IPKG_TMP)/usr/lib/*.*a
	rm -rf $(LIBGNOMEPRINT_IPKG_TMP)/usr/lib/libgnomeprint/$(LIBGNOMEPRINT_VERSION)/modules/transports/*.a
	###rm -rf $(LIBGNOMEPRINT_IPKG_TMP)/usr/lib/libgnomeprint/$(LIBGNOMEPRINT_VERSION)/modules/transports/*.la
	rm -rf $(LIBGNOMEPRINT_IPKG_TMP)/usr/lib/pkgconfig
	rm -rf $(LIBGNOMEPRINT_IPKG_TMP)/usr/share/gtk-doc
	rm -rf $(LIBGNOMEPRINT_IPKG_TMP)/usr/share/locale
	for FILE in `find $(LIBGNOMEPRINT_IPKG_TMP)/usr/ -type f`; do	\
	    ZZZ=`file $$FILE | grep 'ELF 32-bit'`;			\
	    if [  "$$ZZZ" != "" ]; then					\
		$(CROSSSTRIP) $$FILE;					\
	    fi;								\
	done
	mkdir -p $(LIBGNOMEPRINT_IPKG_TMP)/CONTROL
	echo "Package: libgnomeprint" 			>$(LIBGNOMEPRINT_IPKG_TMP)/CONTROL/control
	echo "Priority: optional" 			>>$(LIBGNOMEPRINT_IPKG_TMP)/CONTROL/control
	echo "Section: Gnome"	 			>>$(LIBGNOMEPRINT_IPKG_TMP)/CONTROL/control
	echo "Maintainer: Alexander Chukov <sash@pdaXrom.org>" >>$(LIBGNOMEPRINT_IPKG_TMP)/CONTROL/control
	echo "Architecture: $(SHORT_TARGET)" 		>>$(LIBGNOMEPRINT_IPKG_TMP)/CONTROL/control
	echo "Version: $(LIBGNOMEPRINT_VERSION)" 	>>$(LIBGNOMEPRINT_IPKG_TMP)/CONTROL/control
	echo "Depends: glib2, libxml2, libart-lgpl" 	>>$(LIBGNOMEPRINT_IPKG_TMP)/CONTROL/control
	echo "Description: Gnome Printing Library">>$(LIBGNOMEPRINT_IPKG_TMP)/CONTROL/control
	cd $(FEEDDIR) && $(XMKIPKG) $(LIBGNOMEPRINT_IPKG_TMP)
	touch $@

# ----------------------------------------------------------------------------
# Clean
# ----------------------------------------------------------------------------

libgnomeprint_clean:
	rm -rf $(STATEDIR)/libgnomeprint.*
	rm -rf $(LIBGNOMEPRINT_DIR)

# vim: syntax=make
