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
ifdef PTXCONF_RXVT-UNICODE
PACKAGES += rxvt-unicode
endif

#
# Paths and names
#
RXVT-UNICODE_VENDOR_VERSION	= 1
RXVT-UNICODE_VERSION		= 4.8
RXVT-UNICODE			= rxvt-unicode-$(RXVT-UNICODE_VERSION)
RXVT-UNICODE_SUFFIX		= tar.bz2
RXVT-UNICODE_URL		= http://dist.schmorp.de/rxvt-unicode/$(RXVT-UNICODE).$(RXVT-UNICODE_SUFFIX)
RXVT-UNICODE_SOURCE		= $(SRCDIR)/$(RXVT-UNICODE).$(RXVT-UNICODE_SUFFIX)
RXVT-UNICODE_DIR		= $(BUILDDIR)/$(RXVT-UNICODE)
RXVT-UNICODE_IPKG_TMP		= $(RXVT-UNICODE_DIR)/ipkg_tmp

# ----------------------------------------------------------------------------
# Get
# ----------------------------------------------------------------------------

rxvt-unicode_get: $(STATEDIR)/rxvt-unicode.get

rxvt-unicode_get_deps = $(RXVT-UNICODE_SOURCE)

$(STATEDIR)/rxvt-unicode.get: $(rxvt-unicode_get_deps)
	@$(call targetinfo, $@)
	@$(call get_patches, $(RXVT-UNICODE))
	touch $@

$(RXVT-UNICODE_SOURCE):
	@$(call targetinfo, $@)
	@$(call get, $(RXVT-UNICODE_URL))

# ----------------------------------------------------------------------------
# Extract
# ----------------------------------------------------------------------------

rxvt-unicode_extract: $(STATEDIR)/rxvt-unicode.extract

rxvt-unicode_extract_deps = $(STATEDIR)/rxvt-unicode.get

$(STATEDIR)/rxvt-unicode.extract: $(rxvt-unicode_extract_deps)
	@$(call targetinfo, $@)
	@$(call clean, $(RXVT-UNICODE_DIR))
	@$(call extract, $(RXVT-UNICODE_SOURCE))
	@$(call patchin, $(RXVT-UNICODE))
	touch $@

# ----------------------------------------------------------------------------
# Prepare
# ----------------------------------------------------------------------------

rxvt-unicode_prepare: $(STATEDIR)/rxvt-unicode.prepare

#
# dependencies
#
rxvt-unicode_prepare_deps = \
	$(STATEDIR)/rxvt-unicode.extract \
	$(STATEDIR)/virtual-xchain.install

RXVT-UNICODE_PATH	=  PATH=$(CROSS_PATH)
RXVT-UNICODE_ENV 	=  $(CROSS_ENV)
RXVT-UNICODE_ENV	+= CFLAGS="$(TARGET_OPT_CFLAGS)"
RXVT-UNICODE_ENV	+= PKG_CONFIG_PATH=$(CROSS_LIB_DIR)/lib/pkgconfig:$(CROSS_LIB_DIR)/lib/pkgconfig
#ifdef PTXCONF_XFREE430
#RXVT-UNICODE_ENV	+= LDFLAGS=-Wl,-rpath-link,$(CROSS_LIB_DIR)/lib
#endif

#
# autoconf
#
RXVT-UNICODE_AUTOCONF = \
	--build=$(GNU_HOST) \
	--host=$(PTXCONF_GNU_TARGET) \
	--prefix=/usr \
	--enable-xft \
	--enable-menubar \
	--enable-xim \
	--disable-strings \
	--with-term=rxvt \
	--enable-keepscrolling \
	--with-name=rxvt \
	--enable-frills \
	--enable-swapscreen \
	--enable-transparency \
	--with-codesets=eu \
	--enable-cursor-blink \
	--enable-pointer-blank \
	--enable-text-blink \
	--enable-plain-scroll \
	--enable-combining \
	--enable-shared \
	--disable-static \
	--enable-xgetdefault \
	--disable-debug \
	--sysconfdir=/etc

ifdef PTXCONF_XFREE430
RXVT-UNICODE_AUTOCONF += --x-includes=$(CROSS_LIB_DIR)/include
RXVT-UNICODE_AUTOCONF += --x-libraries=$(CROSS_LIB_DIR)/lib
endif

$(STATEDIR)/rxvt-unicode.prepare: $(rxvt-unicode_prepare_deps)
	@$(call targetinfo, $@)
	@$(call clean, $(RXVT-UNICODE_DIR)/config.cache)
	cd $(RXVT-UNICODE_DIR) && \
		$(RXVT-UNICODE_PATH) $(RXVT-UNICODE_ENV) \
		./configure $(RXVT-UNICODE_AUTOCONF)
	touch $@

# ----------------------------------------------------------------------------
# Compile
# ----------------------------------------------------------------------------

rxvt-unicode_compile: $(STATEDIR)/rxvt-unicode.compile

rxvt-unicode_compile_deps = $(STATEDIR)/rxvt-unicode.prepare

$(STATEDIR)/rxvt-unicode.compile: $(rxvt-unicode_compile_deps)
	@$(call targetinfo, $@)
	$(RXVT-UNICODE_PATH) $(MAKE) -C $(RXVT-UNICODE_DIR)
	touch $@

# ----------------------------------------------------------------------------
# Install
# ----------------------------------------------------------------------------

rxvt-unicode_install: $(STATEDIR)/rxvt-unicode.install

$(STATEDIR)/rxvt-unicode.install: $(STATEDIR)/rxvt-unicode.compile
	@$(call targetinfo, $@)
	touch $@

# ----------------------------------------------------------------------------
# Target-Install
# ----------------------------------------------------------------------------

rxvt-unicode_targetinstall: $(STATEDIR)/rxvt-unicode.targetinstall

rxvt-unicode_targetinstall_deps = $(STATEDIR)/rxvt-unicode.compile

$(STATEDIR)/rxvt-unicode.targetinstall: $(rxvt-unicode_targetinstall_deps)
	@$(call targetinfo, $@)
	$(RXVT-UNICODE_PATH) $(MAKE) -C $(RXVT-UNICODE_DIR) DESTDIR=$(RXVT-UNICODE_IPKG_TMP) install
	rm -rf $(RXVT-UNICODE_IPKG_TMP)/usr/include
	rm -rf $(RXVT-UNICODE_IPKG_TMP)/usr/man
	rm  -f $(RXVT-UNICODE_IPKG_TMP)/usr/lib/*.*a
	$(CROSSSTRIP) $(RXVT-UNICODE_IPKG_TMP)/usr/bin/*
	$(CROSSSTRIP) $(RXVT-UNICODE_IPKG_TMP)/usr/lib/*.so*
	mkdir -p $(RXVT-UNICODE_IPKG_TMP)/usr/share/
	tic -o $(RXVT-UNICODE_IPKG_TMP)/usr/share/terminfo $(RXVT-UNICODE_DIR)/doc/etc/rxvt.termcap
	mkdir -p $(RXVT-UNICODE_IPKG_TMP)/usr/share/applications/
	cp -a $(TOPDIR)/config/pics/rxvt-unicode.desktop $(RXVT-UNICODE_IPKG_TMP)/usr/share/applications/
	mkdir -p $(RXVT-UNICODE_IPKG_TMP)/usr/share/pixmaps/
	cp -a $(TOPDIR)/config/pics/rxvt-unicode.png $(RXVT-UNICODE_IPKG_TMP)/usr/share/pixmaps/
	mkdir -p $(RXVT-UNICODE_IPKG_TMP)/etc/X11/app-defaults/
	cp -a $(TOPDIR)/config/pics/URxvt $(RXVT-UNICODE_IPKG_TMP)/etc/X11/app-defaults/
	mkdir -p $(RXVT-UNICODE_IPKG_TMP)/CONTROL
	echo "Package: rxvt-unicode" 									 >$(RXVT-UNICODE_IPKG_TMP)/CONTROL/control
	echo "Priority: optional" 									>>$(RXVT-UNICODE_IPKG_TMP)/CONTROL/control
	echo "Section: X11" 										>>$(RXVT-UNICODE_IPKG_TMP)/CONTROL/control
	echo "Maintainer: Alexander Chukov <sash@pdaXrom.org>" 						>>$(RXVT-UNICODE_IPKG_TMP)/CONTROL/control
	echo "Architecture: $(SHORT_TARGET)" 								>>$(RXVT-UNICODE_IPKG_TMP)/CONTROL/control
	echo "Version: $(RXVT-UNICODE_VERSION)-$(RXVT-UNICODE_VENDOR_VERSION)" 				>>$(RXVT-UNICODE_IPKG_TMP)/CONTROL/control
	echo "Depends: xfree430, webfonts-lucon" 							>>$(RXVT-UNICODE_IPKG_TMP)/CONTROL/control
	echo "Description: rxvt-unicode is a clone of the well known terminal emulator rxvt."		>>$(RXVT-UNICODE_IPKG_TMP)/CONTROL/control
	cd $(FEEDDIR) && $(XMKIPKG) $(RXVT-UNICODE_IPKG_TMP)
	touch $@

# ----------------------------------------------------------------------------
# Image-Install
# ----------------------------------------------------------------------------

ifdef PTXCONF_RXVT-UNICODE_INSTALL
ROMPACKAGES += $(STATEDIR)/rxvt-unicode.imageinstall
endif

rxvt-unicode_imageinstall_deps = $(STATEDIR)/rxvt-unicode.targetinstall \
	$(STATEDIR)/virtual-image.install

$(STATEDIR)/rxvt-unicode.imageinstall: $(rxvt-unicode_imageinstall_deps)
	@$(call targetinfo, $@)
	cd $(FEEDDIR) && $(XIPKG) install rxvt-unicode
	touch $@

# ----------------------------------------------------------------------------
# Clean
# ----------------------------------------------------------------------------

rxvt-unicode_clean:
	rm -rf $(STATEDIR)/rxvt-unicode.*
	rm -rf $(RXVT-UNICODE_DIR)

# vim: syntax=make
