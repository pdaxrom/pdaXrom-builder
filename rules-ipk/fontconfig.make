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
ifdef PTXCONF_FONTCONFIG
PACKAGES += fontconfig
endif

#
# Paths and names
#
FONTCONFIG_VERSION		= 2.2.96
FONTCONFIG			= fontconfig-$(FONTCONFIG_VERSION)
FONTCONFIG_SUFFIX		= tar.gz
FONTCONFIG_URL			= http://freedesktop.org/~fontconfig/release/$(FONTCONFIG).$(FONTCONFIG_SUFFIX)
FONTCONFIG_SOURCE		= $(SRCDIR)/$(FONTCONFIG).$(FONTCONFIG_SUFFIX)
FONTCONFIG_DIR			= $(BUILDDIR)/$(FONTCONFIG)
FONTCONFIG_IPKG_TMP		= $(FONTCONFIG_DIR)/ipkg_tmp

# ----------------------------------------------------------------------------
# Get
# ----------------------------------------------------------------------------

fontconfig_get: $(STATEDIR)/fontconfig.get

fontconfig_get_deps = $(FONTCONFIG_SOURCE)

$(STATEDIR)/fontconfig.get: $(fontconfig_get_deps)
	@$(call targetinfo, $@)
	@$(call get_patches, $(FONTCONFIG))
	touch $@

$(FONTCONFIG_SOURCE):
	@$(call targetinfo, $@)
	@$(call get, $(FONTCONFIG_URL))

# ----------------------------------------------------------------------------
# Extract
# ----------------------------------------------------------------------------

fontconfig_extract: $(STATEDIR)/fontconfig.extract

fontconfig_extract_deps = $(STATEDIR)/fontconfig.get

$(STATEDIR)/fontconfig.extract: $(fontconfig_extract_deps)
	@$(call targetinfo, $@)
	@$(call clean, $(FONTCONFIG_DIR))
	@$(call extract, $(FONTCONFIG_SOURCE))
	@$(call patchin, $(FONTCONFIG))
	touch $@

# ----------------------------------------------------------------------------
# Prepare
# ----------------------------------------------------------------------------

fontconfig_prepare: $(STATEDIR)/fontconfig.prepare

#
# dependencies
#
fontconfig_prepare_deps = \
	$(STATEDIR)/fontconfig.extract \
	$(STATEDIR)/expat.install \
	$(STATEDIR)/freetype.install \
	$(STATEDIR)/virtual-xchain.install

FONTCONFIG_PATH	=  PATH=$(CROSS_PATH)
FONTCONFIG_ENV 	=  $(CROSS_ENV)
FONTCONFIG_ENV	+= CFLAGS="$(TARGET_OPT_CFLAGS)"
FONTCONFIG_ENV	+= PKG_CONFIG_PATH=$(CROSS_LIB_DIR)/lib/pkgconfig:$(CROSS_LIB_DIR)/lib/pkgconfig
#ifdef PTXCONF_XFREE430
#FONTCONFIG_ENV	+= LDFLAGS=-Wl,-rpath-link,$(CROSS_LIB_DIR)/lib
#endif

#
# autoconf
#
FONTCONFIG_AUTOCONF = \
	--build=$(GNU_HOST) \
	--host=$(PTXCONF_GNU_TARGET) \
	--prefix=/usr \
	--enable-shared \
	--disable-static \
	--sysconfdir=/etc

FONTCONFIG_AUTOCONF	+= --disable-docs
FONTCONFIG_AUTOCONF	+= --with-expat-lib=$(PTXCONF_PREFIX)/$(PTXCONF_GNU_TARGET)/lib
FONTCONFIG_AUTOCONF	+= --with-expat-include=$(PTXCONF_PREFIX)/$(PTXCONF_GNU_TARGET)/include

#ifdef PTXCONF_XFREE430
#FONTCONFIG_AUTOCONF += --x-includes=$(CROSS_LIB_DIR)/include
#FONTCONFIG_AUTOCONF += --x-libraries=$(CROSS_LIB_DIR)/lib
#endif

$(STATEDIR)/fontconfig.prepare: $(fontconfig_prepare_deps)
	@$(call targetinfo, $@)
	@$(call clean, $(FONTCONFIG_DIR)/config.cache)
	cd $(FONTCONFIG_DIR) && \
		$(FONTCONFIG_PATH) $(FONTCONFIG_ENV) \
		./configure $(FONTCONFIG_AUTOCONF)
	touch $@

# ----------------------------------------------------------------------------
# Compile
# ----------------------------------------------------------------------------

fontconfig_compile: $(STATEDIR)/fontconfig.compile

fontconfig_compile_deps = $(STATEDIR)/fontconfig.prepare

$(STATEDIR)/fontconfig.compile: $(fontconfig_compile_deps)
	@$(call targetinfo, $@)
	cd $(FONTCONFIG_DIR)/fc-lang && $(FONTCONFIG_PATH) gcc fc-lang.c -o fc-lang.host -I. -I.. -I../src `freetype-config --cflags`
	cd $(FONTCONFIG_DIR)/fc-glyphname && $(FONTCONFIG_PATH) gcc fc-glyphname.c -o fc-glyphname.host -I. -I.. -I../src `freetype-config --cflags`
	$(FONTCONFIG_PATH) $(MAKE) -C $(FONTCONFIG_DIR)
	touch $@

# ----------------------------------------------------------------------------
# Install
# ----------------------------------------------------------------------------

fontconfig_install: $(STATEDIR)/fontconfig.install

$(STATEDIR)/fontconfig.install: $(STATEDIR)/fontconfig.compile
	@$(call targetinfo, $@)
	$(FONTCONFIG_PATH) $(MAKE) -C $(FONTCONFIG_DIR) DESTDIR=$(FONTCONFIG_IPKG_TMP) install
	cp -a  $(FONTCONFIG_IPKG_TMP)/usr/include/*           $(CROSS_LIB_DIR)/include
	cp -a  $(FONTCONFIG_IPKG_TMP)/usr/lib/*               $(CROSS_LIB_DIR)/lib
	perl -p -i -e "s/\/usr\/lib/`echo $(PTXCONF_PREFIX)/$(PTXCONF_GNU_TARGET)/lib | sed -e '/\//s//\\\\\//g'`/g" $(PTXCONF_PREFIX)/$(PTXCONF_GNU_TARGET)/lib/libfontconfig.la
	perl -p -i -e "s/\/usr/`echo $(PTXCONF_PREFIX)/$(PTXCONF_GNU_TARGET) | sed -e '/\//s//\\\\\//g'`/g"          $(PTXCONF_PREFIX)/$(PTXCONF_GNU_TARGET)/lib/pkgconfig/fontconfig.pc
	rm -rf $(FONTCONFIG_IPKG_TMP)
	touch $@

# ----------------------------------------------------------------------------
# Target-Install
# ----------------------------------------------------------------------------

fontconfig_targetinstall: $(STATEDIR)/fontconfig.targetinstall

fontconfig_targetinstall_deps = $(STATEDIR)/fontconfig.compile

$(STATEDIR)/fontconfig.targetinstall: $(fontconfig_targetinstall_deps)
	@$(call targetinfo, $@)
	$(FONTCONFIG_PATH) $(MAKE) -C $(FONTCONFIG_DIR) DESTDIR=$(FONTCONFIG_IPKG_TMP) install
	rm -rf $(FONTCONFIG_IPKG_TMP)/usr/include
	rm -rf $(FONTCONFIG_IPKG_TMP)/usr/lib/pkgconfig
	rm -rf $(FONTCONFIG_IPKG_TMP)/usr/lib/*.*a
	rm -rf $(FONTCONFIG_IPKG_TMP)/usr/man
	$(CROSSSTRIP) $(FONTCONFIG_IPKG_TMP)/usr/bin/*
	$(CROSSSTRIP) $(FONTCONFIG_IPKG_TMP)/usr/lib/*
	mkdir -p $(FONTCONFIG_IPKG_TMP)/CONTROL
	echo "Package: fontconfig" 					>$(FONTCONFIG_IPKG_TMP)/CONTROL/control
	echo "Priority: optional" 					>>$(FONTCONFIG_IPKG_TMP)/CONTROL/control
	echo "Section: X11"		 				>>$(FONTCONFIG_IPKG_TMP)/CONTROL/control
	echo "Maintainer: Alexander Chukov <sash@pdaXrom.org>" 		>>$(FONTCONFIG_IPKG_TMP)/CONTROL/control
	echo "Architecture: $(SHORT_TARGET)" 				>>$(FONTCONFIG_IPKG_TMP)/CONTROL/control
	echo "Version: $(FONTCONFIG_VERSION)" 				>>$(FONTCONFIG_IPKG_TMP)/CONTROL/control
	echo "Depends: expat, freetype" 				>>$(FONTCONFIG_IPKG_TMP)/CONTROL/control
	echo "Description: Font configuration and customization library">>$(FONTCONFIG_IPKG_TMP)/CONTROL/control
	cd $(FEEDDIR) && $(XMKIPKG) $(FONTCONFIG_IPKG_TMP)
	touch $@

# ----------------------------------------------------------------------------
# Image-Install
# ----------------------------------------------------------------------------

ifdef PTXCONF_FONTCONFIG_INSTALL
ROMPACKAGES += $(STATEDIR)/fontconfig.imageinstall
endif

fontconfig_imageinstall_deps = $(STATEDIR)/fontconfig.targetinstall \
	$(STATEDIR)/virtual-image.install

$(STATEDIR)/fontconfig.imageinstall: $(fontconfig_imageinstall_deps)
	@$(call targetinfo, $@)
	cd $(FEEDDIR) && $(XIPKG) install fontconfig
	touch $@

# ----------------------------------------------------------------------------
# Clean
# ----------------------------------------------------------------------------

fontconfig_clean:
	rm -rf $(STATEDIR)/fontconfig.*
	rm -rf $(FONTCONFIG_DIR)

# vim: syntax=make
