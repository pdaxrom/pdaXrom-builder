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
ifdef PTXCONF_LIBGNOME
PACKAGES += libgnome
endif

#
# Paths and names
#
LIBGNOME_VERSION	= 2.4.0
###LIBGNOME_VERSION	= 2.6.1.1
LIBGNOME		= libgnome-$(LIBGNOME_VERSION)
LIBGNOME_SUFFIX		= tar.bz2
LIBGNOME_URL		= ftp://ftp.acc.umu.se/pub/GNOME/sources/libgnome/2.6/$(LIBGNOME).$(LIBGNOME_SUFFIX)
LIBGNOME_SOURCE		= $(SRCDIR)/$(LIBGNOME).$(LIBGNOME_SUFFIX)
LIBGNOME_DIR		= $(BUILDDIR)/$(LIBGNOME)
LIBGNOME_IPKG_TMP	= $(LIBGNOME_DIR)/ipkg_tmp

# ----------------------------------------------------------------------------
# Get
# ----------------------------------------------------------------------------

libgnome_get: $(STATEDIR)/libgnome.get

libgnome_get_deps = $(LIBGNOME_SOURCE)

$(STATEDIR)/libgnome.get: $(libgnome_get_deps)
	@$(call targetinfo, $@)
	@$(call get_patches, $(LIBGNOME))
	touch $@

$(LIBGNOME_SOURCE):
	@$(call targetinfo, $@)
	@$(call get, $(LIBGNOME_URL))

# ----------------------------------------------------------------------------
# Extract
# ----------------------------------------------------------------------------

libgnome_extract: $(STATEDIR)/libgnome.extract

libgnome_extract_deps = $(STATEDIR)/libgnome.get

$(STATEDIR)/libgnome.extract: $(libgnome_extract_deps)
	@$(call targetinfo, $@)
	@$(call clean, $(LIBGNOME_DIR))
	@$(call extract, $(LIBGNOME_SOURCE))
	@$(call patchin, $(LIBGNOME))
	touch $@

# ----------------------------------------------------------------------------
# Prepare
# ----------------------------------------------------------------------------

libgnome_prepare: $(STATEDIR)/libgnome.prepare

#
# dependencies
#
libgnome_prepare_deps = \
	$(STATEDIR)/libgnome.extract \
	$(STATEDIR)/esound.install \
	$(STATEDIR)/GConf.install \
	$(STATEDIR)/libbonobo.install \
	$(STATEDIR)/gnome-vfs.install \
	$(STATEDIR)/virtual-xchain.install

LIBGNOME_PATH	=  PATH=$(CROSS_PATH)
LIBGNOME_ENV 	=  $(CROSS_ENV)
LIBGNOME_ENV	+= CFLAGS="-O2 -fomit-frame-pointer"
LIBGNOME_ENV	+= PKG_CONFIG_PATH=$(CROSS_LIB_DIR)/lib/pkgconfig:$(CROSS_LIB_DIR)/lib/pkgconfig
#ifdef PTXCONF_XFREE430
#LIBGNOME_ENV	+= LDFLAGS=-Wl,-rpath-link,$(CROSS_LIB_DIR)/lib
#endif

#
# autoconf
#
LIBGNOME_AUTOCONF = \
	--build=$(GNU_HOST) \
	--host=$(PTXCONF_GNU_TARGET) \
	--prefix=/usr \
	--enable-shared \
	--disable-static \
	--sysconfdir=/etc \
	--libexecdir=/usr/bin \
	--disable-debug

ifdef PTXCONF_XFREE430
LIBGNOME_AUTOCONF += --x-includes=$(CROSS_LIB_DIR)/include
LIBGNOME_AUTOCONF += --x-libraries=$(CROSS_LIB_DIR)/lib
endif

$(STATEDIR)/libgnome.prepare: $(libgnome_prepare_deps)
	@$(call targetinfo, $@)
	@$(call clean, $(LIBGNOME_DIR)/config.cache)
	cd $(LIBGNOME_DIR) && \
		$(LIBGNOME_PATH) $(LIBGNOME_ENV) \
		./configure $(LIBGNOME_AUTOCONF)
	touch $@

# ----------------------------------------------------------------------------
# Compile
# ----------------------------------------------------------------------------

libgnome_compile: $(STATEDIR)/libgnome.compile

libgnome_compile_deps = $(STATEDIR)/libgnome.prepare

$(STATEDIR)/libgnome.compile: $(libgnome_compile_deps)
	@$(call targetinfo, $@)
	$(LIBGNOME_PATH) $(MAKE) -C $(LIBGNOME_DIR)
	touch $@

# ----------------------------------------------------------------------------
# Install
# ----------------------------------------------------------------------------

libgnome_install: $(STATEDIR)/libgnome.install

$(STATEDIR)/libgnome.install: $(STATEDIR)/libgnome.compile
	@$(call targetinfo, $@)
	$(LIBGNOME_PATH) $(MAKE) -C $(LIBGNOME_DIR) DESTDIR=$(LIBGNOME_IPKG_TMP) install
	cp -a  $(LIBGNOME_IPKG_TMP)/usr/include/*          $(CROSS_LIB_DIR)/include
	cp -a  $(LIBGNOME_IPKG_TMP)/usr/lib/*              $(CROSS_LIB_DIR)/lib
	perl -p -i -e "s/\/usr\/lib/`echo $(PTXCONF_PREFIX)/$(PTXCONF_GNU_TARGET)/lib | sed -e '/\//s//\\\\\//g'`/g" $(PTXCONF_PREFIX)/$(PTXCONF_GNU_TARGET)/lib/libgnome-2.la
	perl -p -i -e "s/\/usr/`echo $(PTXCONF_PREFIX)/$(PTXCONF_GNU_TARGET) | sed -e '/\//s//\\\\\//g'`/g" $(PTXCONF_PREFIX)/$(PTXCONF_GNU_TARGET)/lib/pkgconfig/libgnome-2.0.pc
	rm -rf $(LIBGNOME_IPKG_TMP)
	touch $@

# ----------------------------------------------------------------------------
# Target-Install
# ----------------------------------------------------------------------------

libgnome_targetinstall: $(STATEDIR)/libgnome.targetinstall

libgnome_targetinstall_deps = \
	$(STATEDIR)/libgnome.compile \
	$(STATEDIR)/esound.targetinstall \
	$(STATEDIR)/GConf.targetinstall \
	$(STATEDIR)/libbonobo.targetinstall \
	$(STATEDIR)/gnome-vfs.targetinstall

$(STATEDIR)/libgnome.targetinstall: $(libgnome_targetinstall_deps)
	@$(call targetinfo, $@)
	$(LIBGNOME_PATH) $(MAKE) -C $(LIBGNOME_DIR) DESTDIR=$(LIBGNOME_IPKG_TMP) install
	rm -rf $(LIBGNOME_IPKG_TMP)/usr/include
	rm -rf $(LIBGNOME_IPKG_TMP)/usr/lib/pkgconfig
	rm -rf $(LIBGNOME_IPKG_TMP)/usr/lib/*.*a
	rm -rf $(LIBGNOME_IPKG_TMP)/usr/lib/bonobo/monikers/*.a
	###rm -rf $(LIBGNOME_IPKG_TMP)/usr/lib/bonobo/monikers/*.la
	rm -rf $(LIBGNOME_IPKG_TMP)/usr/share
	for FILE in `find $(LIBGNOME_IPKG_TMP)/usr/ -type f`; do	\
	    ZZZ=`file $$FILE | grep 'ELF 32-bit'`;			\
	    if [  "$$ZZZ" != "" ]; then					\
		$(CROSSSTRIP) $$FILE;					\
	    fi;								\
	done
	mkdir -p $(LIBGNOME_IPKG_TMP)/CONTROL
	echo "Package: libgnome" 			>$(LIBGNOME_IPKG_TMP)/CONTROL/control
	echo "Priority: optional" 			>>$(LIBGNOME_IPKG_TMP)/CONTROL/control
	echo "Section: Gnome"	 			>>$(LIBGNOME_IPKG_TMP)/CONTROL/control
	echo "Maintainer: Alexander Chukov <sash@pdaXrom.org>" >>$(LIBGNOME_IPKG_TMP)/CONTROL/control
	echo "Architecture: $(SHORT_TARGET)" 		>>$(LIBGNOME_IPKG_TMP)/CONTROL/control
	echo "Version: $(LIBGNOME_VERSION)" 		>>$(LIBGNOME_IPKG_TMP)/CONTROL/control
	echo "Depends: esound, gconf, libbonobo, gnome-vfs" >>$(LIBGNOME_IPKG_TMP)/CONTROL/control
	echo "Description: This is the non-gui part of the library formerly known as gnome-libs.">>$(LIBGNOME_IPKG_TMP)/CONTROL/control
	cd $(FEEDDIR) && $(XMKIPKG) $(LIBGNOME_IPKG_TMP)
	touch $@

# ----------------------------------------------------------------------------
# Clean
# ----------------------------------------------------------------------------

libgnome_clean:
	rm -rf $(STATEDIR)/libgnome.*
	rm -rf $(LIBGNOME_DIR)

# vim: syntax=make
