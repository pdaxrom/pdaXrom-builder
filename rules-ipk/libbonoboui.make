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
ifdef PTXCONF_LIBBONOBOUI
PACKAGES += libbonoboui
endif

#
# Paths and names
#
LIBBONOBOUI_VERSION	= 2.4.4
###LIBBONOBOUI_VERSION	= 2.6.1
LIBBONOBOUI		= libbonoboui-$(LIBBONOBOUI_VERSION)
LIBBONOBOUI_SUFFIX	= tar.bz2
LIBBONOBOUI_URL		= ftp://ftp.gnome.org/pub/GNOME/sources/libbonoboui/2.6/$(LIBBONOBOUI).$(LIBBONOBOUI_SUFFIX)
LIBBONOBOUI_SOURCE	= $(SRCDIR)/$(LIBBONOBOUI).$(LIBBONOBOUI_SUFFIX)
LIBBONOBOUI_DIR		= $(BUILDDIR)/$(LIBBONOBOUI)
LIBBONOBOUI_IPKG_TMP	= $(LIBBONOBOUI_DIR)/ipkg_tmp

# ----------------------------------------------------------------------------
# Get
# ----------------------------------------------------------------------------

libbonoboui_get: $(STATEDIR)/libbonoboui.get

libbonoboui_get_deps = $(LIBBONOBOUI_SOURCE)

$(STATEDIR)/libbonoboui.get: $(libbonoboui_get_deps)
	@$(call targetinfo, $@)
	@$(call get_patches, $(LIBBONOBOUI))
	touch $@

$(LIBBONOBOUI_SOURCE):
	@$(call targetinfo, $@)
	@$(call get, $(LIBBONOBOUI_URL))

# ----------------------------------------------------------------------------
# Extract
# ----------------------------------------------------------------------------

libbonoboui_extract: $(STATEDIR)/libbonoboui.extract

libbonoboui_extract_deps = $(STATEDIR)/libbonoboui.get

$(STATEDIR)/libbonoboui.extract: $(libbonoboui_extract_deps)
	@$(call targetinfo, $@)
	@$(call clean, $(LIBBONOBOUI_DIR))
	@$(call extract, $(LIBBONOBOUI_SOURCE))
	@$(call patchin, $(LIBBONOBOUI))
	touch $@

# ----------------------------------------------------------------------------
# Prepare
# ----------------------------------------------------------------------------

libbonoboui_prepare: $(STATEDIR)/libbonoboui.prepare

#
# dependencies
#
libbonoboui_prepare_deps = \
	$(STATEDIR)/libbonoboui.extract \
	$(STATEDIR)/libbonobo.install \
	$(STATEDIR)/virtual-xchain.install

LIBBONOBOUI_PATH	=  PATH=$(CROSS_PATH)
LIBBONOBOUI_ENV  =  $(CROSS_ENV)
LIBBONOBOUI_ENV	+= CFLAGS="-O2 -fomit-frame-pointer"
LIBBONOBOUI_ENV	+= PKG_CONFIG_PATH=$(CROSS_LIB_DIR)/lib/pkgconfig:$(CROSS_LIB_DIR)/lib/pkgconfig
#ifdef PTXCONF_XFREE430
#LIBBONOBOUI_ENV	+= LDFLAGS=-Wl,-rpath-link,$(CROSS_LIB_DIR)/lib
#endif

#
# autoconf
#
LIBBONOBOUI_AUTOCONF = \
	--build=$(GNU_HOST) \
	--host=$(PTXCONF_GNU_TARGET) \
	--prefix=/usr \
	--enable-shared \
	--disable-static \
	--sysconfdir=/etc \
	--libexecdir=/usr/bin \
	--disable-debug

ifdef PTXCONF_XFREE430
LIBBONOBOUI_AUTOCONF += --x-includes=$(CROSS_LIB_DIR)/include
LIBBONOBOUI_AUTOCONF += --x-libraries=$(CROSS_LIB_DIR)/lib
endif

$(STATEDIR)/libbonoboui.prepare: $(libbonoboui_prepare_deps)
	@$(call targetinfo, $@)
	@$(call clean, $(LIBBONOBOUI_DIR)/config.cache)
	cd $(LIBBONOBOUI_DIR) && \
		$(LIBBONOBOUI_PATH) $(LIBBONOBOUI_ENV) \
		./configure $(LIBBONOBOUI_AUTOCONF)
	touch $@

# ----------------------------------------------------------------------------
# Compile
# ----------------------------------------------------------------------------

libbonoboui_compile: $(STATEDIR)/libbonoboui.compile

libbonoboui_compile_deps = $(STATEDIR)/libbonoboui.prepare

$(STATEDIR)/libbonoboui.compile: $(libbonoboui_compile_deps)
	@$(call targetinfo, $@)
	$(LIBBONOBOUI_PATH) $(MAKE) -C $(LIBBONOBOUI_DIR)
	touch $@

# ----------------------------------------------------------------------------
# Install
# ----------------------------------------------------------------------------

libbonoboui_install: $(STATEDIR)/libbonoboui.install

$(STATEDIR)/libbonoboui.install: $(STATEDIR)/libbonoboui.compile
	@$(call targetinfo, $@)
	$(LIBBONOBOUI_PATH) $(MAKE) -C $(LIBBONOBOUI_DIR) DESTDIR=$(LIBBONOBOUI_IPKG_TMP) install
	cp -a  $(LIBBONOBOUI_IPKG_TMP)/usr/include/*          $(CROSS_LIB_DIR)/include
	cp -a  $(LIBBONOBOUI_IPKG_TMP)/usr/lib/*              $(CROSS_LIB_DIR)/lib
	perl -p -i -e "s/\/usr\/lib/`echo $(PTXCONF_PREFIX)/$(PTXCONF_GNU_TARGET)/lib | sed -e '/\//s//\\\\\//g'`/g" $(PTXCONF_PREFIX)/$(PTXCONF_GNU_TARGET)/lib/libbonoboui-2.la
	perl -p -i -e "s/\/usr/`echo $(PTXCONF_PREFIX)/$(PTXCONF_GNU_TARGET) | sed -e '/\//s//\\\\\//g'`/g" $(PTXCONF_PREFIX)/$(PTXCONF_GNU_TARGET)/lib/pkgconfig/libbonoboui-2.0.pc
	rm -rf $(LIBBONOBOUI_IPKG_TMP)
	touch $@

# ----------------------------------------------------------------------------
# Target-Install
# ----------------------------------------------------------------------------

libbonoboui_targetinstall: $(STATEDIR)/libbonoboui.targetinstall

libbonoboui_targetinstall_deps = \
	$(STATEDIR)/libbonoboui.compile \
	$(STATEDIR)/libbonobo.targetinstall

$(STATEDIR)/libbonoboui.targetinstall: $(libbonoboui_targetinstall_deps)
	@$(call targetinfo, $@)
	$(LIBBONOBOUI_PATH) $(MAKE) -C $(LIBBONOBOUI_DIR) DESTDIR=$(LIBBONOBOUI_IPKG_TMP) install
	rm -rf $(LIBBONOBOUI_IPKG_TMP)/usr/include
	rm -rf $(LIBBONOBOUI_IPKG_TMP)/usr/lib/*.*a
	rm -rf $(LIBBONOBOUI_IPKG_TMP)/usr/lib/pkgconfig
	rm -rf $(LIBBONOBOUI_IPKG_TMP)/usr/lib/libglade/2.0/*.a
	###rm -rf $(LIBBONOBOUI_IPKG_TMP)/usr/lib/libglade/2.0/*.la
	rm -rf $(LIBBONOBOUI_IPKG_TMP)/usr/share/gtk-doc
	rm -rf $(LIBBONOBOUI_IPKG_TMP)/usr/share/locale
	for FILE in `find $(LIBBONOBOUI_IPKG_TMP)/usr/ -type f`; do	\
	    ZZZ=`file $$FILE | grep 'ELF 32-bit'`;			\
	    if [  "$$ZZZ" != "" ]; then					\
		$(CROSSSTRIP) $$FILE;					\
	    fi;								\
	done
	mkdir -p $(LIBBONOBOUI_IPKG_TMP)/CONTROL
	echo "Package: libbonoboui" 			>$(LIBBONOBOUI_IPKG_TMP)/CONTROL/control
	echo "Priority: optional" 			>>$(LIBBONOBOUI_IPKG_TMP)/CONTROL/control
	echo "Section: Gnome"	 			>>$(LIBBONOBOUI_IPKG_TMP)/CONTROL/control
	echo "Maintainer: Alexander Chukov <sash@pdaXrom.org>">>$(LIBBONOBOUI_IPKG_TMP)/CONTROL/control
	echo "Architecture: $(SHORT_TARGET)" 		>>$(LIBBONOBOUI_IPKG_TMP)/CONTROL/control
	echo "Version: $(LIBBONOBOUI_VERSION)" 		>>$(LIBBONOBOUI_IPKG_TMP)/CONTROL/control
	echo "Depends: orbit2, libbonobo, libgnomecanvas, libgnome" >>$(LIBBONOBOUI_IPKG_TMP)/CONTROL/control
	echo "Description: UI for libbonobo">>$(LIBBONOBOUI_IPKG_TMP)/CONTROL/control
	cd $(FEEDDIR) && $(XMKIPKG) $(LIBBONOBOUI_IPKG_TMP)
	touch $@

# ----------------------------------------------------------------------------
# Clean
# ----------------------------------------------------------------------------

libbonoboui_clean:
	rm -rf $(STATEDIR)/libbonoboui.*
	rm -rf $(LIBBONOBOUI_DIR)

# vim: syntax=make
