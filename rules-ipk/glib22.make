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
ifdef PTXCONF_GLIB22
PACKAGES += glib22
endif

#
# Paths and names
#
GLIB22_VENDOR_VERSION	= 1
GLIB22_VERSION		= 2.6.2
GLIB22			= glib-$(GLIB22_VERSION)
GLIB22_SUFFIX		= tar.bz2
GLIB22_URL		= ftp://ftp.gtk.org/pub/gtk/v2.6/$(GLIB22).$(GLIB22_SUFFIX)
GLIB22_SOURCE		= $(SRCDIR)/$(GLIB22).$(GLIB22_SUFFIX)
GLIB22_DIR		= $(BUILDDIR)/$(GLIB22)
GLIB22_IPKG_TMP		= $(GLIB22_DIR)/ipkg_tmp

# ----------------------------------------------------------------------------
# Get
# ----------------------------------------------------------------------------

glib22_get: $(STATEDIR)/glib22.get

glib22_get_deps = $(GLIB22_SOURCE)

$(STATEDIR)/glib22.get: $(glib22_get_deps)
	@$(call targetinfo, $@)
	@$(call get_patches, $(GLIB22))
	touch $@

$(GLIB22_SOURCE):
	@$(call targetinfo, $@)
	@$(call get, $(GLIB22_URL))

# ----------------------------------------------------------------------------
# Extract
# ----------------------------------------------------------------------------

glib22_extract: $(STATEDIR)/glib22.extract

glib22_extract_deps = $(STATEDIR)/glib22.get

$(STATEDIR)/glib22.extract: $(glib22_extract_deps)
	@$(call targetinfo, $@)
	@$(call clean, $(GLIB22_DIR))
	@$(call extract, $(GLIB22_SOURCE))
	@$(call patchin, $(GLIB22))
	touch $@

# ----------------------------------------------------------------------------
# Prepare
# ----------------------------------------------------------------------------

glib22_prepare: $(STATEDIR)/glib22.prepare

#
# dependencies
#
glib22_prepare_deps = \
	$(STATEDIR)/glib22.extract \
	$(STATEDIR)/xchain-libtool.install \
	$(STATEDIR)/xchain-glib22.install \
	$(STATEDIR)/virtual-xchain.install

ifdef PTXCONF_LIBICONV
glib22_prepare_deps += $(STATEDIR)/libiconv.install
endif

GLIB22_PATH	=  PATH=$(CROSS_PATH)
GLIB22_ENV 	=  $(CROSS_ENV)
#GLIB22_ENV	+=
GLIB22_ENV	+= PKG_CONFIG_PATH=$(CROSS_LIB_DIR)/lib/pkgconfig:$(CROSS_LIB_DIR)/lib/pkgconfig
#ifdef PTXCONF_XFREE430
#GLIB22_ENV	+= LDFLAGS=-Wl,-rpath-link,$(CROSS_LIB_DIR)/lib
#endif

ifeq (y, $G(PTXCONF_GLIBC_DL))
GLIB22_ENV	+= glib_cv_uscore=yes
else
GLIB22_ENV	+= glib_cv_uscore=no
endif

GLIB22_ENV	+= CFLAGS="-O2 -fomit-frame-pointer"

#
# autoconf
#
GLIB22_AUTOCONF = \
	--build=$(GNU_HOST) \
	--host=$(PTXCONF_GNU_TARGET) \
	--prefix=/usr \
	--disable-included-printf \
	--disable-debug \
	--enable-shared \
	--disable-static \
	--sysconfdir=/etc

ifdef PTXCONF_LIBICONV
GLIB22_AUTOCONF += --with-libiconv=gnu
#else
#GLIB22_AUTOCONF += --without-libiconv
endif

ifdef PTXCONF_XFREE430
GLIB22_AUTOCONF += --x-includes=$(CROSS_LIB_DIR)/include
GLIB22_AUTOCONF += --x-libraries=$(CROSS_LIB_DIR)/lib
endif

$(STATEDIR)/glib22.prepare: $(glib22_prepare_deps)
	@$(call targetinfo, $@)
	@$(call clean, $(GLIB22_DIR)/config.cache)
	cd $(GLIB22_DIR) && \
		$(GLIB22_PATH) $(GLIB22_ENV) \
		./configure $(GLIB22_AUTOCONF)
	cp -f $(PTXCONF_PREFIX)/bin/libtool $(GLIB22_DIR)/bin
	touch $@

# ----------------------------------------------------------------------------
# Compile
# ----------------------------------------------------------------------------

glib22_compile: $(STATEDIR)/glib22.compile

glib22_compile_deps = $(STATEDIR)/glib22.prepare

$(STATEDIR)/glib22.compile: $(glib22_compile_deps)
	@$(call targetinfo, $@)
	$(GLIB22_PATH) $(MAKE) -C $(GLIB22_DIR)
	touch $@

# ----------------------------------------------------------------------------
# Install
# ----------------------------------------------------------------------------

glib22_install: $(STATEDIR)/glib22.install

$(STATEDIR)/glib22.install: $(STATEDIR)/glib22.compile
	@$(call targetinfo, $@)
	rm -rf $(GLIB22_IPKG_TMP)
	$(GLIB22_PATH) $(MAKE) -C $(GLIB22_DIR) DESTDIR=$(GLIB22_IPKG_TMP) install
	cp -a $(GLIB22_IPKG_TMP)/usr/include/*			$(CROSS_LIB_DIR)/include/
	cp -a $(GLIB22_IPKG_TMP)/usr/lib/*			$(CROSS_LIB_DIR)/lib/
	cp -a $(GLIB22_IPKG_TMP)/usr/share/aclocal/*		$(PTXCONF_PREFIX)/share/aclocal/
	perl -i -p -e "s,\/usr/lib,$(CROSS_LIB_DIR)/lib,g" 	$(CROSS_LIB_DIR)/lib/libglib-2.0.la
	perl -i -p -e "s,\/usr/lib,$(CROSS_LIB_DIR)/lib,g" 	$(CROSS_LIB_DIR)/lib/libgmodule-2.0.la
	perl -i -p -e "s,\/usr/lib,$(CROSS_LIB_DIR)/lib,g" 	$(CROSS_LIB_DIR)/lib/libgobject-2.0.la
	perl -i -p -e "s,\/usr/lib,$(CROSS_LIB_DIR)/lib,g" 	$(CROSS_LIB_DIR)/lib/libgthread-2.0.la

	perl -i -p -e "s,\/usr,$(CROSS_LIB_DIR),g" 		$(CROSS_LIB_DIR)/lib/pkgconfig/glib-2.0.pc
	perl -i -p -e "s,\/usr,$(CROSS_LIB_DIR),g" 		$(CROSS_LIB_DIR)/lib/pkgconfig/gmodule-2.0.pc
	perl -i -p -e "s,\/usr,$(CROSS_LIB_DIR),g" 		$(CROSS_LIB_DIR)/lib/pkgconfig/gmodule-no-export-2.0.pc
	perl -i -p -e "s,\/usr,$(CROSS_LIB_DIR),g" 		$(CROSS_LIB_DIR)/lib/pkgconfig/gobject-2.0.pc
	perl -i -p -e "s,\/usr,$(CROSS_LIB_DIR),g" 		$(CROSS_LIB_DIR)/lib/pkgconfig/gthread-2.0.pc

	rm -rf $(GLIB22_IPKG_TMP)
	touch $@

# ----------------------------------------------------------------------------
# Target-Install
# ----------------------------------------------------------------------------

glib22_targetinstall: $(STATEDIR)/glib22.targetinstall

glib22_targetinstall_deps = $(STATEDIR)/glib22.compile

$(STATEDIR)/glib22.targetinstall: $(glib22_targetinstall_deps)
	@$(call targetinfo, $@)
	$(GLIB22_PATH) $(MAKE) -C $(GLIB22_DIR) DESTDIR=$(GLIB22_IPKG_TMP) install
	rm -rf $(GLIB22_IPKG_TMP)/usr/bin
	rm -rf $(GLIB22_IPKG_TMP)/usr/include
	rm -rf $(GLIB22_IPKG_TMP)/usr/man
	rm -rf $(GLIB22_IPKG_TMP)/usr/share
	rm -rf $(GLIB22_IPKG_TMP)/usr/lib/*.*a
	rm -rf $(GLIB22_IPKG_TMP)/usr/lib/glib-2.0
	rm -rf $(GLIB22_IPKG_TMP)/usr/lib/pkgconfig
	$(CROSSSTRIP) $(GLIB22_IPKG_TMP)/usr/lib/*.so*
	mkdir -p $(GLIB22_IPKG_TMP)/CONTROL
	echo "Package: glib2" 											 >$(GLIB22_IPKG_TMP)/CONTROL/control
	echo "Priority: optional" 										>>$(GLIB22_IPKG_TMP)/CONTROL/control
	echo "Section: Libraries" 										>>$(GLIB22_IPKG_TMP)/CONTROL/control
	echo "Maintainer: Alexander Chukov <sash@pdaXrom.org>" 							>>$(GLIB22_IPKG_TMP)/CONTROL/control
	echo "Architecture: $(SHORT_TARGET)" 									>>$(GLIB22_IPKG_TMP)/CONTROL/control
	echo "Version: $(GLIB22_VERSION)-$(GLIB22_VENDOR_VERSION)" 						>>$(GLIB22_IPKG_TMP)/CONTROL/control
ifdef PTXCONF_LIBICONV
	echo "Depends: libiconv" 										>>$(GLIB22_IPKG_TMP)/CONTROL/control
else
	echo "Depends: " 											>>$(GLIB22_IPKG_TMP)/CONTROL/control
endif
	echo "Description: GLib is the low-level core library that forms the basis for projects such as GTK+ and GNOME.">>$(GLIB22_IPKG_TMP)/CONTROL/control
	cd $(FEEDDIR) && $(XMKIPKG) $(GLIB22_IPKG_TMP)
	touch $@

# ----------------------------------------------------------------------------
# Image-Install
# ----------------------------------------------------------------------------

ifdef PTXCONF_GLIB22_INSTALL
ROMPACKAGES += $(STATEDIR)/glib22.imageinstall
endif

glib22_imageinstall_deps = $(STATEDIR)/glib22.targetinstall \
	$(STATEDIR)/virtual-image.install

$(STATEDIR)/glib22.imageinstall: $(glib22_imageinstall_deps)
	@$(call targetinfo, $@)
	cd $(FEEDDIR) && $(XIPKG) install glib2
	touch $@

# ----------------------------------------------------------------------------
# Clean
# ----------------------------------------------------------------------------

glib22_clean:
	rm -rf $(STATEDIR)/glib22.*
	rm -rf $(GLIB22_DIR)

# vim: syntax=make
