# -*-makefile-*-
# $Id: gtk22.make,v 1.3 2003/10/23 15:01:19 mkl Exp $
#
# Copyright (C) 2003 by Robert Schwebel <r.schwebel@pengutronix.de>
#                       Pengutronix <info@pengutronix.de>, Germany
#          
# See CREDITS for details about who has contributed to this project.
#
# For further information about the PTXdist project and license conditions
# see the README file.
#

#
# We provide this package
#
ifdef PTXCONF_GTK22
PACKAGES += gtk22
endif

#
# Paths and names
#
#GTK22_VERSION_MAJOR	= 2
#GTK22_VERSION_MINOR	= 4
#GTK22_VERSION_MICRO	= 10

GTK22_VERSION_MAJOR	= 2
GTK22_VERSION_MINOR	= 6
GTK22_VERSION_MICRO	= 2

GTK22_VERSION		= $(GTK22_VERSION_MAJOR).$(GTK22_VERSION_MINOR).$(GTK22_VERSION_MICRO)
GTK22			= gtk+-$(GTK22_VERSION)
GTK22_SUFFIX		= tar.bz2
GTK22_URL		= ftp://ftp.gtk.org/pub/gtk/v$(GTK22_VERSION_MAJOR).$(GTK22_VERSION_MINOR)/$(GTK22).$(GTK22_SUFFIX)
GTK22_SOURCE		= $(SRCDIR)/$(GTK22).$(GTK22_SUFFIX)
GTK22_DIR		= $(BUILDDIR)/$(GTK22)
GTK22_IPKG_TMP		= $(GTK22_DIR)/ipkg_tmp

# ----------------------------------------------------------------------------
# Get
# ----------------------------------------------------------------------------

gtk22_get: $(STATEDIR)/gtk22.get

gtk22_get_deps	=  $(GTK22_SOURCE)

$(STATEDIR)/gtk22.get: $(gtk22_get_deps)
	@$(call targetinfo, $@)
	@$(call get_patches, $(GTK22))
	touch $@

$(GTK22_SOURCE):
	@$(call targetinfo, $@)
	@$(call get, $(GTK22_URL))

# ----------------------------------------------------------------------------
# Extract
# ----------------------------------------------------------------------------

gtk22_extract: $(STATEDIR)/gtk22.extract

gtk22_extract_deps	=  $(STATEDIR)/gtk22.get

$(STATEDIR)/gtk22.extract: $(gtk22_extract_deps)
	@$(call targetinfo, $@)
	@$(call clean, $(GTK22_DIR))
	@$(call extract, $(GTK22_SOURCE))
	@$(call patchin, $(GTK22))
	touch $@

# ----------------------------------------------------------------------------
# Prepare
# ----------------------------------------------------------------------------

gtk22_prepare: $(STATEDIR)/gtk22.prepare

#
# dependencies
#
gtk22_prepare_deps =  \
	$(STATEDIR)/gtk22.extract \
	$(STATEDIR)/atk124.install \
	$(STATEDIR)/virtual-xchain.install

GTK22_PATH	=  PATH=$(CROSS_PATH)
GTK22_ENV 	=  $(CROSS_ENV)
GTK22_ENV	+= PKG_CONFIG_PATH=../$(GLIB22):../$(PANGO12):../$(ATK124):../$(GTK22):../$(FREETYPE214):../$(FONTCONFIG22)

# FIXME: gtk+ doesn't use pkg-config yet, so we have to do this. 
GTK22_ENV	+= ac_cv_path_FREETYPE_CONFIG=$(PTXCONF_PREFIX)/bin/freetype-config
GTK22_ENV	+= PKG_CONFIG_PATH=$(CROSS_LIB_DIR)/lib/pkgconfig:$(CROSS_LIB_DIR)/lib/pkgconfig
#GTK22_ENV	+= LDFLAGS=-Wl,-rpath-link,$(CROSS_LIB_DIR)/lib

GTK22_ENV	+= CFLAGS="-O2 -fomit-frame-pointer"
#
# autoconf
#
GTK22_AUTOCONF	=  --prefix=/usr
GTK22_AUTOCONF	+= --build=$(GNU_HOST)
GTK22_AUTOCONF	+= --host=$(PTXCONF_GNU_TARGET)
GTK22_AUTOCONF	+= --x-includes=$(CROSS_LIB_DIR)/include
GTK22_AUTOCONF	+= --x-libraries=$(CROSS_LIB_DIR)/lib

# FIXME
GTK22_AUTOCONF	+= --without-libtiff
GTK22_AUTOCONF	+= --with-libjpeg
GTK22_AUTOCONF	+= --with-libpng
GTK22_AUTOCONF	+= --enable-debug=no --sysconfdir=/etc

ifdef PTXCONF_GTK22_FOO
GTK22_AUTOCONF	+= --enable-foo
endif

$(STATEDIR)/gtk22.prepare: $(gtk22_prepare_deps)
	@$(call targetinfo, $@)
	@$(call clean, $(GTK22_BUILDDIR))
	cd $(GTK22_DIR) && \
		$(GTK22_PATH) $(GTK22_ENV) \
		./configure $(GTK22_AUTOCONF)
	cp -f $(PTXCONF_PREFIX)/bin/libtool $(GTK22_DIR)/
	touch $@

# ----------------------------------------------------------------------------
# Compile
# ----------------------------------------------------------------------------

gtk22_compile: $(STATEDIR)/gtk22.compile

gtk22_compile_deps =  $(STATEDIR)/gtk22.prepare

$(STATEDIR)/gtk22.compile: $(gtk22_compile_deps)
	@$(call targetinfo, $@)
	$(GTK22_PATH) $(GTK22_ENV) $(MAKE) -C $(GTK22_DIR)
	touch $@

# ----------------------------------------------------------------------------
# Install
# ----------------------------------------------------------------------------

gtk22_install: $(STATEDIR)/gtk22.install

$(STATEDIR)/gtk22.install: $(STATEDIR)/gtk22.compile
	@$(call targetinfo, $@)

	$(GTK22_PATH) $(GTK22_ENV) $(MAKE) -C $(GTK22_DIR) DESTDIR=$(CROSS_LIB_DIR) install
	cp -a  $(CROSS_LIB_DIR)/usr/include/* $(CROSS_LIB_DIR)/include/
	cp -a  $(CROSS_LIB_DIR)/usr/lib/*     $(CROSS_LIB_DIR)/lib/
	rm -rf $(CROSS_LIB_DIR)/lib/gtk-2.0/$(GTK22_VERSION_MAJOR).$(GTK22_VERSION_MINOR).0
	rm -rf $(CROSS_LIB_DIR)/usr/include
	rm -rf $(CROSS_LIB_DIR)/usr/lib

	perl -p -i -e "s/\/usr/`echo $(PTXCONF_PREFIX)/$(PTXCONF_GNU_TARGET) | sed -e '/\//s//\\\\\//g'`/g" $(PTXCONF_PREFIX)/$(PTXCONF_GNU_TARGET)/lib/pkgconfig/gdk-2.0.pc
	perl -p -i -e "s/\/usr/`echo $(PTXCONF_PREFIX)/$(PTXCONF_GNU_TARGET) | sed -e '/\//s//\\\\\//g'`/g" $(PTXCONF_PREFIX)/$(PTXCONF_GNU_TARGET)/lib/pkgconfig/gdk-pixbuf-2.0.pc
	perl -p -i -e "s/\/usr/`echo $(PTXCONF_PREFIX)/$(PTXCONF_GNU_TARGET) | sed -e '/\//s//\\\\\//g'`/g" $(PTXCONF_PREFIX)/$(PTXCONF_GNU_TARGET)/lib/pkgconfig/gdk-pixbuf-xlib-2.0.pc
	perl -p -i -e "s/\/usr/`echo $(PTXCONF_PREFIX)/$(PTXCONF_GNU_TARGET) | sed -e '/\//s//\\\\\//g'`/g" $(PTXCONF_PREFIX)/$(PTXCONF_GNU_TARGET)/lib/pkgconfig/gdk-x11-2.0.pc
	perl -p -i -e "s/\/usr/`echo $(PTXCONF_PREFIX)/$(PTXCONF_GNU_TARGET) | sed -e '/\//s//\\\\\//g'`/g" $(PTXCONF_PREFIX)/$(PTXCONF_GNU_TARGET)/lib/pkgconfig/gtk+-2.0.pc
	perl -p -i -e "s/\/usr/`echo $(PTXCONF_PREFIX)/$(PTXCONF_GNU_TARGET) | sed -e '/\//s//\\\\\//g'`/g" $(PTXCONF_PREFIX)/$(PTXCONF_GNU_TARGET)/lib/pkgconfig/gtk+-x11-2.0.pc

	perl -p -i -e "s/\/usr/`echo $(PTXCONF_PREFIX)/$(PTXCONF_GNU_TARGET) | sed -e '/\//s//\\\\\//g'`/g" $(PTXCONF_PREFIX)/$(PTXCONF_GNU_TARGET)/lib/libgdk-x11-2.0.la
	perl -p -i -e "s/\/usr/`echo $(PTXCONF_PREFIX)/$(PTXCONF_GNU_TARGET) | sed -e '/\//s//\\\\\//g'`/g" $(PTXCONF_PREFIX)/$(PTXCONF_GNU_TARGET)/lib/libgdk_pixbuf-2.0.la
	perl -p -i -e "s/\/usr/`echo $(PTXCONF_PREFIX)/$(PTXCONF_GNU_TARGET) | sed -e '/\//s//\\\\\//g'`/g" $(PTXCONF_PREFIX)/$(PTXCONF_GNU_TARGET)/lib/libgdk_pixbuf_xlib-2.0.la
	perl -p -i -e "s/\/usr/`echo $(PTXCONF_PREFIX)/$(PTXCONF_GNU_TARGET) | sed -e '/\//s//\\\\\//g'`/g" $(PTXCONF_PREFIX)/$(PTXCONF_GNU_TARGET)/lib/libgtk-x11-2.0.la

	cp -a $(GTK22_DIR)/m4macros/gtk-2.0.m4 $(PTXCONF_PREFIX)/share/aclocal/

	touch $@

# ----------------------------------------------------------------------------
# Target-Install
# ----------------------------------------------------------------------------

gtk22_targetinstall: $(STATEDIR)/gtk22.targetinstall

gtk22_targetinstall_deps	=  $(STATEDIR)/gtk22.compile \
	$(STATEDIR)/atk124.targetinstall \
	$(STATEDIR)/xfree430.targetinstall


$(STATEDIR)/gtk22.targetinstall: $(gtk22_targetinstall_deps)
	@$(call targetinfo, $@)
	$(GTK22_PATH) $(GTK22_ENV) $(MAKE) -C $(GTK22_DIR) DESTDIR=$(GTK22_IPKG_TMP) install
	rm -rf $(GTK22_IPKG_TMP)/usr/share/gtk-2.0
	rm -rf $(GTK22_IPKG_TMP)/usr/share/gtk-doc
	rm -rf $(GTK22_IPKG_TMP)/usr/share/aclocal
	rm -rf $(GTK22_IPKG_TMP)/usr/share/locale
	rm -rf $(GTK22_IPKG_TMP)/usr/include
	rm -rf $(GTK22_IPKG_TMP)/usr/man
	$(CROSSSTRIP) $(GTK22_IPKG_TMP)/usr/bin/gdk-*
	$(CROSSSTRIP) $(GTK22_IPKG_TMP)/usr/bin/gtk-*
	rm -f $(GTK22_IPKG_TMP)/usr/bin/gtk-demo
	rm -rf $(GTK22_IPKG_TMP)/usr/lib/pkgconfig
	rm -rf $(GTK22_IPKG_TMP)/usr/lib/gtk-2.0/include
	rm -rf $(GTK22_IPKG_TMP)/usr/lib/gtk-2.0/2.4.0/engines/*.a
	rm -rf $(GTK22_IPKG_TMP)/usr/lib/gtk-2.0/2.4.0/engines/*.la
	$(CROSSSTRIP) $(GTK22_IPKG_TMP)/usr/lib/gtk-2.0/2.4.0/engines/*.so
	rm -rf $(GTK22_IPKG_TMP)/usr/lib/gtk-2.0/2.4.0/immodules/*.a
	rm -rf $(GTK22_IPKG_TMP)/usr/lib/gtk-2.0/2.4.0/immodules/*.la
	$(CROSSSTRIP) $(GTK22_IPKG_TMP)/usr/lib/gtk-2.0/2.4.0/immodules/*.so
	rm -rf $(GTK22_IPKG_TMP)/usr/lib/gtk-2.0/2.4.0/loaders/*.a
	rm -rf $(GTK22_IPKG_TMP)/usr/lib/gtk-2.0/2.4.0/loaders/*.la
	$(CROSSSTRIP) $(GTK22_IPKG_TMP)/usr/lib/gtk-2.0/2.4.0/loaders/*.so
	rm -rf $(GTK22_IPKG_TMP)/usr/lib/*.a
	rm -rf $(GTK22_IPKG_TMP)/usr/lib/*.la
	$(CROSSSTRIP) $(GTK22_IPKG_TMP)/usr/lib/libgdk-x11-2.0.so.0.*
	$(CROSSSTRIP) $(GTK22_IPKG_TMP)/usr/lib/libgdk_pixbuf-2.0.so.0.*
	$(CROSSSTRIP) $(GTK22_IPKG_TMP)/usr/lib/libgdk_pixbuf_xlib-2.0.so.0.*
	$(CROSSSTRIP) $(GTK22_IPKG_TMP)/usr/lib/libgtk-x11-2.0.so.0.*
	mkdir -p      $(GTK22_IPKG_TMP)/etc/gtk-2.0
	mkdir -p      $(GTK22_IPKG_TMP)/CONTROL
	echo "Package: gtk2"	 				 >$(GTK22_IPKG_TMP)/CONTROL/control
	echo "Priority: optional" 				>>$(GTK22_IPKG_TMP)/CONTROL/control
	echo "Section: X11"	 				>>$(GTK22_IPKG_TMP)/CONTROL/control
	echo "Maintainer: Alexander Chukov <sash@pdaXrom.org>"	>>$(GTK22_IPKG_TMP)/CONTROL/control
	echo "Architecture: $(SHORT_TARGET)" 			>>$(GTK22_IPKG_TMP)/CONTROL/control
	echo "Version: $(GTK22_VERSION)" 			>>$(GTK22_IPKG_TMP)/CONTROL/control
	echo "Depends: glib2, atk, pango, xfree430, libjpeg, libpng">>$(GTK22_IPKG_TMP)/CONTROL/control
	echo "Description: GTK+ is a multi-platform toolkit for creating graphical user interfaces.">>$(GTK22_IPKG_TMP)/CONTROL/control
	echo "#!/bin/sh"								 >$(GTK22_IPKG_TMP)/CONTROL/postinst
	echo "/usr/bin/gtk-query-immodules-2.0 > /etc/gtk-2.0/gtk.immodules" 		>>$(GTK22_IPKG_TMP)/CONTROL/postinst
	echo "/usr/bin/gdk-pixbuf-query-loaders > /etc/gtk-2.0/gdk-pixbuf.loaders"	>>$(GTK22_IPKG_TMP)/CONTROL/postinst
	chmod 755 $(GTK22_IPKG_TMP)/CONTROL/postinst
	cd $(FEEDDIR) && $(XMKIPKG) $(GTK22_IPKG_TMP)
	touch $@

# ----------------------------------------------------------------------------
# Image-Install
# ----------------------------------------------------------------------------

ifdef PTXCONF_GTK22_INSTALL
ROMPACKAGES += $(STATEDIR)/gtk22.imageinstall
endif

gtk22_imageinstall_deps = $(STATEDIR)/gtk22.targetinstall \
	$(STATEDIR)/virtual-image.install

$(STATEDIR)/gtk22.imageinstall: $(gtk22_imageinstall_deps)
	@$(call targetinfo, $@)
	cd $(FEEDDIR) && $(XIPKG) install gtk2
	touch $@


# ----------------------------------------------------------------------------
# Clean
# ----------------------------------------------------------------------------

gtk22_clean:
	rm -rf $(STATEDIR)/gtk22.*
	rm -rf $(GTK22_DIR)

# vim: syntax=make
