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
ifdef PTXCONF_GTK1210
PACKAGES += gtk1210
endif

#
# Paths and names
#
GTK1210_VERSION		= 1.2.10
GTK1210			= gtk+-$(GTK1210_VERSION)
GTK1210_SUFFIX		= tar.gz
GTK1210_URL		= ftp://ftp.gtk.org/pub/gtk/v1.2/$(GTK1210).$(GTK1210_SUFFIX)
GTK1210_SOURCE		= $(SRCDIR)/$(GTK1210).$(GTK1210_SUFFIX)
GTK1210_DIR		= $(BUILDDIR)/$(GTK1210)
GTK1210_IPKG_TMP	= $(GTK1210_DIR)/ipkg_tmp

# ----------------------------------------------------------------------------
# Get
# ----------------------------------------------------------------------------

gtk1210_get: $(STATEDIR)/gtk1210.get

gtk1210_get_deps = $(GTK1210_SOURCE)

$(STATEDIR)/gtk1210.get: $(gtk1210_get_deps)
	@$(call targetinfo, $@)
	@$(call get_patches, $(GTK1210))
	touch $@

$(GTK1210_SOURCE):
	@$(call targetinfo, $@)
	@$(call get, $(GTK1210_URL))

# ----------------------------------------------------------------------------
# Extract
# ----------------------------------------------------------------------------

gtk1210_extract: $(STATEDIR)/gtk1210.extract

gtk1210_extract_deps = $(STATEDIR)/gtk1210.get

$(STATEDIR)/gtk1210.extract: $(gtk1210_extract_deps)
	@$(call targetinfo, $@)
	@$(call clean, $(GTK1210_DIR))
	@$(call extract, $(GTK1210_SOURCE))
	@$(call patchin, $(GTK1210))
	touch $@

# ----------------------------------------------------------------------------
# Prepare
# ----------------------------------------------------------------------------

gtk1210_prepare: $(STATEDIR)/gtk1210.prepare

#
# dependencies
#
gtk1210_prepare_deps = \
	$(STATEDIR)/gtk1210.extract \
	$(STATEDIR)/xfree430.install \
	$(STATEDIR)/glib1210.install \
	$(STATEDIR)/startup-notification.install \
	$(STATEDIR)/virtual-xchain.install

GTK1210_PATH	=  PATH=$(CROSS_PATH)
GTK1210_ENV 	=  $(CROSS_ENV)
GTK1210_ENV	+= CFLAGS="-O2 -fomit-frame-pointer"
GTK1210_ENV	+= PKG_CONFIG_PATH=$(CROSS_LIB_DIR)/lib/pkgconfig:$(CROSS_LIB_DIR)/lib/pkgconfig
#ifdef PTXCONF_XFREE430
#GTK1210_ENV	+= LDFLAGS=-Wl,-rpath-link,$(CROSS_LIB_DIR)/lib
#endif

#
# autoconf
#
GTK1210_AUTOCONF = \
	--build=$(GNU_HOST) \
	--host=$(PTXCONF_GNU_TARGET) \
	--prefix=/usr \
	--enable-shared \
	--disable-static \
	--sysconfdir=/etc

ifdef PTXCONF_XFREE430
GTK1210_AUTOCONF += --x-includes=$(CROSS_LIB_DIR)/include
GTK1210_AUTOCONF += --x-libraries=$(CROSS_LIB_DIR)/lib
endif

$(STATEDIR)/gtk1210.prepare: $(gtk1210_prepare_deps)
	@$(call targetinfo, $@)
	@$(call clean, $(GTK1210_DIR)/config.cache)
	cp -f $(PTXCONF_PREFIX)/bin/libtool $(GTK1210_DIR)
	#cd $(GTK1210_DIR) && $(GTK1210_PATH) aclocal
	#cd $(GTK1210_DIR) && $(GTK1210_PATH) automake --add-missing
	#cd $(GTK1210_DIR) && $(GTK1210_PATH) autoconf
	#cd $(GTK1210_DIR) && $(GTK1210_PATH) autoheader
ifdef PTXCONF_ARCH_ARM
	cp -a $(TOPDIR)/rules/arm-linux $(GLIB1210_DIR)/config.cache
endif
	cd $(GTK1210_DIR) && \
		$(GTK1210_PATH) $(GTK1210_ENV) \
		./configure $(GTK1210_AUTOCONF)
	touch $@

# ----------------------------------------------------------------------------
# Compile
# ----------------------------------------------------------------------------

gtk1210_compile: $(STATEDIR)/gtk1210.compile

gtk1210_compile_deps = $(STATEDIR)/gtk1210.prepare

$(STATEDIR)/gtk1210.compile: $(gtk1210_compile_deps)
	@$(call targetinfo, $@)
	$(GTK1210_PATH) $(MAKE) -C $(GTK1210_DIR)
	touch $@

# ----------------------------------------------------------------------------
# Install
# ----------------------------------------------------------------------------

gtk1210_install: $(STATEDIR)/gtk1210.install

$(STATEDIR)/gtk1210.install: $(STATEDIR)/gtk1210.compile
	@$(call targetinfo, $@)
	$(GTK1210_PATH) $(MAKE) -C $(GTK1210_DIR) DESTDIR=$(GTK1210_IPKG_TMP) install
	cp -a  $(GTK1210_IPKG_TMP)/usr/include/* $(CROSS_LIB_DIR)/include
	cp -a  $(GTK1210_IPKG_TMP)/usr/lib/*     $(CROSS_LIB_DIR)/lib
	cp -a  $(GTK1210_IPKG_TMP)/usr/share/aclocal/*   $(CROSS_LIB_DIR)/share/aclocal
	cp -a  $(GTK1210_IPKG_TMP)/usr/bin/*     $(PTXCONF_PREFIX)/bin
	rm -rf $(GTK1210_IPKG_TMP)
	perl -p -i -e "s/\/usr/`echo $(PTXCONF_PREFIX)/$(PTXCONF_GNU_TARGET) | sed -e '/\//s//\\\\\//g'`/g" $(PTXCONF_PREFIX)/bin/gtk-config
	perl -p -i -e "s/\/usr\/lib/`echo $(PTXCONF_PREFIX)/$(PTXCONF_GNU_TARGET)/lib | sed -e '/\//s//\\\\\//g'`/g" $(PTXCONF_PREFIX)/$(PTXCONF_GNU_TARGET)/lib/libgdk.la
	perl -p -i -e "s/\/usr\/lib/`echo $(PTXCONF_PREFIX)/$(PTXCONF_GNU_TARGET)/lib | sed -e '/\//s//\\\\\//g'`/g" $(PTXCONF_PREFIX)/$(PTXCONF_GNU_TARGET)/lib/libgtk.la
	perl -p -i -e "s/\/usr/`echo $(PTXCONF_PREFIX)/$(PTXCONF_GNU_TARGET) | sed -e '/\//s//\\\\\//g'`/g" $(PTXCONF_PREFIX)/$(PTXCONF_GNU_TARGET)/lib/pkgconfig/gdk.pc
	perl -p -i -e "s/\/usr/`echo $(PTXCONF_PREFIX)/$(PTXCONF_GNU_TARGET) | sed -e '/\//s//\\\\\//g'`/g" $(PTXCONF_PREFIX)/$(PTXCONF_GNU_TARGET)/lib/pkgconfig/gtk+.pc
	touch $@

# ----------------------------------------------------------------------------
# Target-Install
# ----------------------------------------------------------------------------

gtk1210_targetinstall: $(STATEDIR)/gtk1210.targetinstall

gtk1210_targetinstall_deps = \
	$(STATEDIR)/gtk1210.compile \
	$(STATEDIR)/startup-notification.targetinstall \
	$(STATEDIR)/glib1210.targetinstall

$(STATEDIR)/gtk1210.targetinstall: $(gtk1210_targetinstall_deps)
	@$(call targetinfo, $@)
	$(GTK1210_PATH) $(MAKE) -C $(GTK1210_DIR) DESTDIR=$(GTK1210_IPKG_TMP) install
	rm -rf $(GTK1210_IPKG_TMP)/usr/bin
	rm -rf $(GTK1210_IPKG_TMP)/usr/include
	rm -rf $(GTK1210_IPKG_TMP)/usr/info
	rm -rf $(GTK1210_IPKG_TMP)/usr/man
	rm -rf $(GTK1210_IPKG_TMP)/usr/share/aclocal
	rm -rf $(GTK1210_IPKG_TMP)/usr/share/locale
	rm -rf $(GTK1210_IPKG_TMP)/usr/lib/glib
	rm -rf $(GTK1210_IPKG_TMP)/usr/lib/pkgconfig
	rm -f  $(GTK1210_IPKG_TMP)/usr/lib/*.*a
	$(CROSSSTRIP) $(GTK1210_IPKG_TMP)/usr/lib/*.so
	mkdir -p $(GTK1210_IPKG_TMP)/CONTROL
	echo "Package: gtk"	 						 >$(GTK1210_IPKG_TMP)/CONTROL/control
	echo "Priority: optional" 						>>$(GTK1210_IPKG_TMP)/CONTROL/control
	echo "Section: Libraries" 						>>$(GTK1210_IPKG_TMP)/CONTROL/control
	echo "Maintainer: Alexander Chukov <sash@pdaXrom.org>"			>>$(GTK1210_IPKG_TMP)/CONTROL/control
	echo "Architecture: $(SHORT_TARGET)" 					>>$(GTK1210_IPKG_TMP)/CONTROL/control
	echo "Version: $(GTK1210_VERSION)" 					>>$(GTK1210_IPKG_TMP)/CONTROL/control
	echo "Depends: glib, xfree430, startup-notification" 			>>$(GTK1210_IPKG_TMP)/CONTROL/control
	echo "Description: generated with pdaXrom builder"			>>$(GTK1210_IPKG_TMP)/CONTROL/control
	cd $(FEEDDIR) && $(XMKIPKG) $(GTK1210_IPKG_TMP)
	touch $@

# ----------------------------------------------------------------------------
# Image-Install
# ----------------------------------------------------------------------------

ifdef PTXCONF_GTK1210_INSTALL
ROMPACKAGES += $(STATEDIR)/gtk1210.imageinstall
endif

gtk1210_imageinstall_deps = $(STATEDIR)/gtk1210.targetinstall \
	$(STATEDIR)/virtual-image.install

$(STATEDIR)/gtk1210.imageinstall: $(gtk1210_imageinstall_deps)
	@$(call targetinfo, $@)
	cd $(FEEDDIR) && $(XIPKG) install gtk
	touch $@

# ----------------------------------------------------------------------------
# Clean
# ----------------------------------------------------------------------------

gtk1210_clean:
	rm -rf $(STATEDIR)/gtk1210.*
	rm -rf $(GTK1210_DIR)

# vim: syntax=make
