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
ifdef PTXCONF_LIBGNOMEUI
PACKAGES += libgnomeui
endif

#
# Paths and names
#
LIBGNOMEUI_VERSION	= 2.4.0.1
###LIBGNOMEUI_VERSION	= 2.6.1.1
LIBGNOMEUI		= libgnomeui-$(LIBGNOMEUI_VERSION)
LIBGNOMEUI_SUFFIX	= tar.bz2
LIBGNOMEUI_URL		= ftp://ftp.gnome.org/pub/GNOME/sources/libgnomeui/2.6/$(LIBGNOMEUI).$(LIBGNOMEUI_SUFFIX)
LIBGNOMEUI_SOURCE	= $(SRCDIR)/$(LIBGNOMEUI).$(LIBGNOMEUI_SUFFIX)
LIBGNOMEUI_DIR		= $(BUILDDIR)/$(LIBGNOMEUI)
LIBGNOMEUI_IPKG_TMP	= $(LIBGNOMEUI_DIR)/ipkg_tmp

# ----------------------------------------------------------------------------
# Get
# ----------------------------------------------------------------------------

libgnomeui_get: $(STATEDIR)/libgnomeui.get

libgnomeui_get_deps = $(LIBGNOMEUI_SOURCE)

$(STATEDIR)/libgnomeui.get: $(libgnomeui_get_deps)
	@$(call targetinfo, $@)
	@$(call get_patches, $(LIBGNOMEUI))
	touch $@

$(LIBGNOMEUI_SOURCE):
	@$(call targetinfo, $@)
	@$(call get, $(LIBGNOMEUI_URL))

# ----------------------------------------------------------------------------
# Extract
# ----------------------------------------------------------------------------

libgnomeui_extract: $(STATEDIR)/libgnomeui.extract

libgnomeui_extract_deps = $(STATEDIR)/libgnomeui.get

$(STATEDIR)/libgnomeui.extract: $(libgnomeui_extract_deps)
	@$(call targetinfo, $@)
	@$(call clean, $(LIBGNOMEUI_DIR))
	@$(call extract, $(LIBGNOMEUI_SOURCE))
	@$(call patchin, $(LIBGNOMEUI))
	touch $@

# ----------------------------------------------------------------------------
# Prepare
# ----------------------------------------------------------------------------

libgnomeui_prepare: $(STATEDIR)/libgnomeui.prepare

#
# dependencies
#
libgnomeui_prepare_deps = \
	$(STATEDIR)/libgnomeui.extract \
	$(STATEDIR)/popt.install \
	$(STATEDIR)/libgnomecanvas.install \
	$(STATEDIR)/libbonoboui.install \
	$(STATEDIR)/virtual-xchain.install

ifdef PTXCONF_LIBICONV
libgnomeui_prepare_deps += $(STATEDIR)/libiconv.install
endif

###	$(STATEDIR)/gnome-keyring.install \

LIBGNOMEUI_PATH	=  PATH=$(CROSS_PATH)
LIBGNOMEUI_ENV 	=  $(CROSS_ENV)
LIBGNOMEUI_ENV	+= CFLAGS="-O2 -fomit-frame-pointer"
LIBGNOMEUI_ENV	+= PKG_CONFIG_PATH=$(CROSS_LIB_DIR)/lib/pkgconfig:$(CROSS_LIB_DIR)/lib/pkgconfig
#ifdef PTXCONF_XFREE430
#LIBGNOMEUI_ENV	+= LDFLAGS=-Wl,-rpath-link,$(CROSS_LIB_DIR)/lib
#endif

#
# autoconf
#
LIBGNOMEUI_AUTOCONF = \
	--build=$(GNU_HOST) \
	--host=$(PTXCONF_GNU_TARGET) \
	--prefix=/usr \
	--enable-shared \
	--disable-static \
	--sysconfdir=/etc \
	--libexecdir=/usr/bin \
	--disable-debug

ifdef PTXCONF_XFREE430
LIBGNOMEUI_AUTOCONF += --x-includes=$(CROSS_LIB_DIR)/include
LIBGNOMEUI_AUTOCONF += --x-libraries=$(CROSS_LIB_DIR)/lib
endif

$(STATEDIR)/libgnomeui.prepare: $(libgnomeui_prepare_deps)
	@$(call targetinfo, $@)
	@$(call clean, $(LIBGNOMEUI_DIR)/config.cache)
	cd $(LIBGNOMEUI_DIR) && \
		$(LIBGNOMEUI_PATH) $(LIBGNOMEUI_ENV) \
		./configure $(LIBGNOMEUI_AUTOCONF)
	touch $@

# ----------------------------------------------------------------------------
# Compile
# ----------------------------------------------------------------------------

libgnomeui_compile: $(STATEDIR)/libgnomeui.compile

libgnomeui_compile_deps = $(STATEDIR)/libgnomeui.prepare

$(STATEDIR)/libgnomeui.compile: $(libgnomeui_compile_deps)
	@$(call targetinfo, $@)
	$(LIBGNOMEUI_PATH) $(MAKE) -C $(LIBGNOMEUI_DIR)
	touch $@

# ----------------------------------------------------------------------------
# Install
# ----------------------------------------------------------------------------

libgnomeui_install: $(STATEDIR)/libgnomeui.install

$(STATEDIR)/libgnomeui.install: $(STATEDIR)/libgnomeui.compile
	@$(call targetinfo, $@)
	$(LIBGNOMEUI_PATH) $(MAKE) -C $(LIBGNOMEUI_DIR) DESTDIR=$(LIBGNOMEUI_IPKG_TMP) install
	cp -a  $(LIBGNOMEUI_IPKG_TMP)/usr/include/*          $(CROSS_LIB_DIR)/include
	cp -a  $(LIBGNOMEUI_IPKG_TMP)/usr/lib/*              $(CROSS_LIB_DIR)/lib
	perl -p -i -e "s/\/usr\/lib/`echo $(PTXCONF_PREFIX)/$(PTXCONF_GNU_TARGET)/lib | sed -e '/\//s//\\\\\//g'`/g" $(PTXCONF_PREFIX)/$(PTXCONF_GNU_TARGET)/lib/libgnomeui-2.la
	perl -p -i -e "s/\/usr/`echo $(PTXCONF_PREFIX)/$(PTXCONF_GNU_TARGET) | sed -e '/\//s//\\\\\//g'`/g" $(PTXCONF_PREFIX)/$(PTXCONF_GNU_TARGET)/lib/pkgconfig/libgnomeui-2.0.pc
	rm -rf $(LIBGNOMEUI_IPKG_TMP)
	touch $@

# ----------------------------------------------------------------------------
# Target-Install
# ----------------------------------------------------------------------------

libgnomeui_targetinstall: $(STATEDIR)/libgnomeui.targetinstall

libgnomeui_targetinstall_deps = \
	$(STATEDIR)/libgnomeui.compile \
	$(STATEDIR)/libgnomecanvas.targetinstall \
	$(STATEDIR)/libbonoboui.targetinstall

###	$(STATEDIR)/gnome-keyring.targetinstall \

$(STATEDIR)/libgnomeui.targetinstall: $(libgnomeui_targetinstall_deps)
	@$(call targetinfo, $@)
	$(LIBGNOMEUI_PATH) $(MAKE) -C $(LIBGNOMEUI_DIR) DESTDIR=$(LIBGNOMEUI_IPKG_TMP) install
	rm -rf $(LIBGNOMEUI_IPKG_TMP)/usr/include
	rm -rf $(LIBGNOMEUI_IPKG_TMP)/usr/lib/*.*a
	rm -rf $(LIBGNOMEUI_IPKG_TMP)/usr/lib/pkgconfig
	rm -rf $(LIBGNOMEUI_IPKG_TMP)/usr/lib/libglade/2.0/*.a
	###rm -rf $(LIBGNOMEUI_IPKG_TMP)/usr/lib/libglade/2.0/*.la
	rm -rf $(LIBGNOMEUI_IPKG_TMP)/usr/share/gtk-doc
	rm -rf $(LIBGNOMEUI_IPKG_TMP)/usr/share/locale
	for FILE in `find $(LIBGNOMEUI_IPKG_TMP)/usr/ -type f`; do	\
	    ZZZ=`file $$FILE | grep 'ELF 32-bit'`;			\
	    if [  "$$ZZZ" != "" ]; then					\
		$(CROSSSTRIP) $$FILE;					\
	    fi;								\
	done
	mkdir -p $(LIBGNOMEUI_IPKG_TMP)/CONTROL
	echo "Package: libgnomeui" 			>$(LIBGNOMEUI_IPKG_TMP)/CONTROL/control
	echo "Priority: optional" 			>>$(LIBGNOMEUI_IPKG_TMP)/CONTROL/control
	echo "Section: Gnome"	 			>>$(LIBGNOMEUI_IPKG_TMP)/CONTROL/control
	echo "Maintainer: Alexander Chukov <sash@pdaXrom.org>" >>$(LIBGNOMEUI_IPKG_TMP)/CONTROL/control
	echo "Architecture: $(SHORT_TARGET)" 		>>$(LIBGNOMEUI_IPKG_TMP)/CONTROL/control
	echo "Version: $(LIBGNOMEUI_VERSION)" 		>>$(LIBGNOMEUI_IPKG_TMP)/CONTROL/control
	echo "Depends: libgnome, libgnomecanvas, libbonoboui, gconf, libart-lgpl" >>$(LIBGNOMEUI_IPKG_TMP)/CONTROL/control
	echo "Description: This is the gui parts of what was previously gnome-libs">>$(LIBGNOMEUI_IPKG_TMP)/CONTROL/control
	cd $(FEEDDIR) && $(XMKIPKG) $(LIBGNOMEUI_IPKG_TMP)
	touch $@

# ----------------------------------------------------------------------------
# Clean
# ----------------------------------------------------------------------------

libgnomeui_clean:
	rm -rf $(STATEDIR)/libgnomeui.*
	rm -rf $(LIBGNOMEUI_DIR)

# vim: syntax=make
