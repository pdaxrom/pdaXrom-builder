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
ifdef PTXCONF_LIBWNCK
PACKAGES += libwnck
endif

#
# Paths and names
#
LIBWNCK_VERSION		= 2.8.0
LIBWNCK			= libwnck-$(LIBWNCK_VERSION)
LIBWNCK_SUFFIX		= tar.bz2
LIBWNCK_URL		= http://ftp.gnome.org/pub/GNOME/sources/libwnck/2.8/$(LIBWNCK).$(LIBWNCK_SUFFIX)
LIBWNCK_SOURCE		= $(SRCDIR)/$(LIBWNCK).$(LIBWNCK_SUFFIX)
LIBWNCK_DIR		= $(BUILDDIR)/$(LIBWNCK)
LIBWNCK_IPKG_TMP	= $(LIBWNCK_DIR)/ipkg_tmp

# ----------------------------------------------------------------------------
# Get
# ----------------------------------------------------------------------------

libwnck_get: $(STATEDIR)/libwnck.get

libwnck_get_deps = $(LIBWNCK_SOURCE)

$(STATEDIR)/libwnck.get: $(libwnck_get_deps)
	@$(call targetinfo, $@)
	@$(call get_patches, $(LIBWNCK))
	touch $@

$(LIBWNCK_SOURCE):
	@$(call targetinfo, $@)
	@$(call get, $(LIBWNCK_URL))

# ----------------------------------------------------------------------------
# Extract
# ----------------------------------------------------------------------------

libwnck_extract: $(STATEDIR)/libwnck.extract

libwnck_extract_deps = $(STATEDIR)/libwnck.get

$(STATEDIR)/libwnck.extract: $(libwnck_extract_deps)
	@$(call targetinfo, $@)
	@$(call clean, $(LIBWNCK_DIR))
	@$(call extract, $(LIBWNCK_SOURCE))
	@$(call patchin, $(LIBWNCK))
	touch $@

# ----------------------------------------------------------------------------
# Prepare
# ----------------------------------------------------------------------------

libwnck_prepare: $(STATEDIR)/libwnck.prepare

#
# dependencies
#
libwnck_prepare_deps = \
	$(STATEDIR)/libwnck.extract \
	$(STATEDIR)/gtk22.install \
	$(STATEDIR)/startup-notification.install \
	$(STATEDIR)/virtual-xchain.install

LIBWNCK_PATH	=  PATH=$(CROSS_PATH)
LIBWNCK_ENV 	=  $(CROSS_ENV)
LIBWNCK_ENV	+= CFLAGS="-O2 -fomit-frame-pointer"
LIBWNCK_ENV	+= PKG_CONFIG_PATH=$(CROSS_LIB_DIR)/lib/pkgconfig:$(CROSS_LIB_DIR)/lib/pkgconfig
#ifdef PTXCONF_XFREE430
#LIBWNCK_ENV	+= LDFLAGS=-Wl,-rpath-link,$(CROSS_LIB_DIR)/lib
#endif

#
# autoconf
#
LIBWNCK_AUTOCONF = \
	--build=$(GNU_HOST) \
	--host=$(PTXCONF_GNU_TARGET) \
	--prefix=/usr \
	--disable-debug \
	--disable-static \
	--enable-shared

ifdef PTXCONF_XFREE430
LIBWNCK_AUTOCONF += --x-includes=$(CROSS_LIB_DIR)/include
LIBWNCK_AUTOCONF += --x-libraries=$(CROSS_LIB_DIR)/lib
endif

$(STATEDIR)/libwnck.prepare: $(libwnck_prepare_deps)
	@$(call targetinfo, $@)
	@$(call clean, $(LIBWNCK_DIR)/config.cache)
	cd $(LIBWNCK_DIR) && \
		$(LIBWNCK_PATH) $(LIBWNCK_ENV) \
		./configure $(LIBWNCK_AUTOCONF)
	touch $@

# ----------------------------------------------------------------------------
# Compile
# ----------------------------------------------------------------------------

libwnck_compile: $(STATEDIR)/libwnck.compile

libwnck_compile_deps = $(STATEDIR)/libwnck.prepare

$(STATEDIR)/libwnck.compile: $(libwnck_compile_deps)
	@$(call targetinfo, $@)
	$(LIBWNCK_PATH) $(MAKE) -C $(LIBWNCK_DIR)
	touch $@

# ----------------------------------------------------------------------------
# Install
# ----------------------------------------------------------------------------

libwnck_install: $(STATEDIR)/libwnck.install

$(STATEDIR)/libwnck.install: $(STATEDIR)/libwnck.compile
	@$(call targetinfo, $@)
	$(LIBWNCK_PATH) $(MAKE) -C $(LIBWNCK_DIR) DESTDIR=$(LIBWNCK_IPKG_TMP) install
	cp -a  $(LIBWNCK_IPKG_TMP)/usr/include/*          $(CROSS_LIB_DIR)/include
	cp -a  $(LIBWNCK_IPKG_TMP)/usr/lib/*              $(CROSS_LIB_DIR)/lib
	perl -p -i -e "s/\/usr\/lib/`echo $(PTXCONF_PREFIX)/$(PTXCONF_GNU_TARGET)/lib | sed -e '/\//s//\\\\\//g'`/g" $(PTXCONF_PREFIX)/$(PTXCONF_GNU_TARGET)/lib/libwnck-1.la
	perl -p -i -e "s/\/usr/`echo $(PTXCONF_PREFIX)/$(PTXCONF_GNU_TARGET) | sed -e '/\//s//\\\\\//g'`/g" $(PTXCONF_PREFIX)/$(PTXCONF_GNU_TARGET)/lib/pkgconfig/libwnck-1.0.pc
	rm -rf $(LIBWNCK_IPKG_TMP)
	touch $@

# ----------------------------------------------------------------------------
# Target-Install
# ----------------------------------------------------------------------------

libwnck_targetinstall: $(STATEDIR)/libwnck.targetinstall

libwnck_targetinstall_deps = $(STATEDIR)/libwnck.install \
	$(STATEDIR)/gtk22.targetinstall \
	$(STATEDIR)/startup-notification.targetinstall

$(STATEDIR)/libwnck.targetinstall: $(libwnck_targetinstall_deps)
	@$(call targetinfo, $@)
	$(LIBWNCK_PATH) $(MAKE) -C $(LIBWNCK_DIR) DESTDIR=$(LIBWNCK_IPKG_TMP) install
	rm -rf $(LIBWNCK_IPKG_TMP)/usr/include
	rm -rf $(LIBWNCK_IPKG_TMP)/usr/lib/pkgconfig
	rm -rf $(LIBWNCK_IPKG_TMP)/usr/lib/*.*a
	rm -rf $(LIBWNCK_IPKG_TMP)/usr/share
	$(CROSSSTRIP) $(LIBWNCK_IPKG_TMP)/usr/lib/*.so*
	mkdir -p $(LIBWNCK_IPKG_TMP)/CONTROL
	echo "Package: libwnck" 							>$(LIBWNCK_IPKG_TMP)/CONTROL/control
	echo "Priority: optional" 							>>$(LIBWNCK_IPKG_TMP)/CONTROL/control
	echo "Section: Libraries" 							>>$(LIBWNCK_IPKG_TMP)/CONTROL/control
	echo "Maintainer: Alexander Chukov <sash@pdaXrom.org>" 				>>$(LIBWNCK_IPKG_TMP)/CONTROL/control
	echo "Architecture: $(SHORT_TARGET)" 						>>$(LIBWNCK_IPKG_TMP)/CONTROL/control
	echo "Version: $(LIBWNCK_VERSION)" 						>>$(LIBWNCK_IPKG_TMP)/CONTROL/control
	echo "Depends: gtk2, startup-notification" 					>>$(LIBWNCK_IPKG_TMP)/CONTROL/control
	echo "Description: Window Navigator Construction Kit, i.e. a library to use for writing pagers and taskslists and stuff.">>$(LIBWNCK_IPKG_TMP)/CONTROL/control
	cd $(FEEDDIR) && $(XMKIPKG) $(LIBWNCK_IPKG_TMP)
	touch $@

# ----------------------------------------------------------------------------
# Image-Install
# ----------------------------------------------------------------------------

ifdef PTXCONF_LIBWNCK_INSTALL
ROMPACKAGES += $(STATEDIR)/libwnck.imageinstall
endif

libwnck_imageinstall_deps = $(STATEDIR)/libwnck.targetinstall \
	$(STATEDIR)/virtual-image.install

$(STATEDIR)/libwnck.imageinstall: $(libwnck_imageinstall_deps)
	@$(call targetinfo, $@)
	cd $(FEEDDIR) && $(XIPKG) install libwnck
	touch $@

# ----------------------------------------------------------------------------
# Clean
# ----------------------------------------------------------------------------

libwnck_clean:
	rm -rf $(STATEDIR)/libwnck.*
	rm -rf $(LIBWNCK_DIR)

# vim: syntax=make
