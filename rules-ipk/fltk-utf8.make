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
ifdef PTXCONF_FLTK-UTF8
PACKAGES += fltk-utf8
endif

#
# Paths and names
#
FLTK-UTF8_VERSION	= 1.1.4
FLTK-UTF8		= fltk-utf8_$(FLTK-UTF8_VERSION)-3
FLTK-UTF8_SUFFIX	= tar.gz
FLTK-UTF8_URL		= http://www.oksid.ch/xd640/$(FLTK-UTF8).$(FLTK-UTF8_SUFFIX)
FLTK-UTF8_SOURCE	= $(SRCDIR)/$(FLTK-UTF8).$(FLTK-UTF8_SUFFIX)
FLTK-UTF8_DIR		= $(BUILDDIR)/fltk-utf8-$(FLTK-UTF8_VERSION)
FLTK-UTF8_IPKG_TMP	= $(FLTK-UTF8_DIR)/ipkg_tmp

# ----------------------------------------------------------------------------
# Get
# ----------------------------------------------------------------------------

fltk-utf8_get: $(STATEDIR)/fltk-utf8.get

fltk-utf8_get_deps = $(FLTK-UTF8_SOURCE)

$(STATEDIR)/fltk-utf8.get: $(fltk-utf8_get_deps)
	@$(call targetinfo, $@)
	@$(call get_patches, $(FLTK-UTF8))
	touch $@

$(FLTK-UTF8_SOURCE):
	@$(call targetinfo, $@)
	@$(call get, $(FLTK-UTF8_URL))

# ----------------------------------------------------------------------------
# Extract
# ----------------------------------------------------------------------------

fltk-utf8_extract: $(STATEDIR)/fltk-utf8.extract

fltk-utf8_extract_deps = $(STATEDIR)/fltk-utf8.get

$(STATEDIR)/fltk-utf8.extract: $(fltk-utf8_extract_deps)
	@$(call targetinfo, $@)
	@$(call clean, $(FLTK-UTF8_DIR))
	@$(call extract, $(FLTK-UTF8_SOURCE))
	@$(call patchin, $(FLTK-UTF8))
	touch $@

# ----------------------------------------------------------------------------
# Prepare
# ----------------------------------------------------------------------------

fltk-utf8_prepare: $(STATEDIR)/fltk-utf8.prepare

#
# dependencies
#
fltk-utf8_prepare_deps = \
	$(STATEDIR)/fltk-utf8.extract \
	$(STATEDIR)/xfree430.install \
	$(STATEDIR)/xutf8.install \
	$(STATEDIR)/virtual-xchain.install

FLTK-UTF8_PATH	=  PATH=$(CROSS_PATH)
FLTK-UTF8_ENV 	=  $(CROSS_ENV)
FLTK-UTF8_ENV	+= CFLAGS="$(TARGET_OPT_CFLAGS)"
FLTK-UTF8_ENV	+= CXXFLAGS="$(TARGET_OPT_CFLAGS)"
FLTK-UTF8_ENV	+= CPPFLAGS=-I$(CROSS_LIB_DIR)/include/freetype2
FLTK-UTF8_ENV	+= PKG_CONFIG_PATH=$(CROSS_LIB_DIR)/lib/pkgconfig:$(CROSS_LIB_DIR)/lib/pkgconfig
FLTK-UTF8_ENV	+= LDFLAGS="-liconv"

#
# autoconf
#
FLTK-UTF8_AUTOCONF = \
	--build=$(GNU_HOST) \
	--host=$(PTXCONF_GNU_TARGET) \
	--prefix=/usr \
	--disable-static \
	--enable-shared \
	--disable-gl \
	--enable-threads \
	--enable-xft \
	--disable-xdbe \
	--with-optim="$(TARGET_OPT_CFLAGS)"

ifdef PTXCONF_XFREE430
FLTK-UTF8_AUTOCONF += --x-includes=$(CROSS_LIB_DIR)/include
FLTK-UTF8_AUTOCONF += --x-libraries=$(CROSS_LIB_DIR)/lib
endif

$(STATEDIR)/fltk-utf8.prepare: $(fltk-utf8_prepare_deps)
	@$(call targetinfo, $@)
	@$(call clean, $(FLTK-UTF8_DIR)/config.cache)
	cd $(FLTK-UTF8_DIR) && \
		$(FLTK-UTF8_PATH) $(FLTK-UTF8_ENV) \
		./configure $(FLTK-UTF8_AUTOCONF)
	touch $@

# ----------------------------------------------------------------------------
# Compile
# ----------------------------------------------------------------------------

fltk-utf8_compile: $(STATEDIR)/fltk-utf8.compile

fltk-utf8_compile_deps = $(STATEDIR)/fltk-utf8.prepare

$(STATEDIR)/fltk-utf8.compile: $(fltk-utf8_compile_deps)
	@$(call targetinfo, $@)
	$(FLTK-UTF8_PATH) $(MAKE) -C $(FLTK-UTF8_DIR)
	touch $@

# ----------------------------------------------------------------------------
# Install
# ----------------------------------------------------------------------------

fltk-utf8_install: $(STATEDIR)/fltk-utf8.install

$(STATEDIR)/fltk-utf8.install: $(STATEDIR)/fltk-utf8.compile
	@$(call targetinfo, $@)
	$(FLTK-UTF8_PATH) $(MAKE) -C $(FLTK-UTF8_DIR) prefix=$(FLTK-UTF8_IPKG_TMP)/usr install
	rm -rf $(FLTK-UTF8_IPKG_TMP)/usr/lib/*.a
	rm  -f $(FLTK-UTF8_IPKG_TMP)/usr/bin/fluid
	cp -a  $(FLTK-UTF8_IPKG_TMP)/usr/include/*        $(CROSS_LIB_DIR)/include
	cp -a  $(FLTK-UTF8_IPKG_TMP)/usr/lib/*            $(CROSS_LIB_DIR)/lib
	cp -a  $(FLTK-UTF8_IPKG_TMP)/usr/bin/*-config     $(PTXCONF_PREFIX)/bin
	perl -p -i -e "s/\/usr/`echo $(PTXCONF_PREFIX)/$(PTXCONF_GNU_TARGET) | sed -e '/\//s//\\\\\//g'`/g" $(PTXCONF_PREFIX)/bin/fltk-config
	rm -rf $(FLTK-UTF8_IPKG_TMP)
	touch $@

# ----------------------------------------------------------------------------
# Target-Install
# ----------------------------------------------------------------------------

fltk-utf8_targetinstall: $(STATEDIR)/fltk-utf8.targetinstall

fltk-utf8_targetinstall_deps = $(STATEDIR)/fltk-utf8.compile \
	$(STATEDIR)/xfree430.targetinstall \
	$(STATEDIR)/xutf8.targetinstall

$(STATEDIR)/fltk-utf8.targetinstall: $(fltk-utf8_targetinstall_deps)
	@$(call targetinfo, $@)
	$(FLTK-UTF8_PATH) $(MAKE) -C $(FLTK-UTF8_DIR) prefix=$(FLTK-UTF8_IPKG_TMP)/usr install
	rm -rf $(FLTK-UTF8_IPKG_TMP)/usr/bin
	rm -rf $(FLTK-UTF8_IPKG_TMP)/usr/include
	rm -rf $(FLTK-UTF8_IPKG_TMP)/usr/lib/*.*a
	rm -rf $(FLTK-UTF8_IPKG_TMP)/usr/share
	$(CROSSSTRIP) $(FLTK-UTF8_IPKG_TMP)/usr/lib/*.so*
	mkdir -p $(FLTK-UTF8_IPKG_TMP)/CONTROL
	echo "Package: fltk-utf8" 				 >$(FLTK-UTF8_IPKG_TMP)/CONTROL/control
	echo "Priority: optional" 				>>$(FLTK-UTF8_IPKG_TMP)/CONTROL/control
	echo "Section: FLTK"	 				>>$(FLTK-UTF8_IPKG_TMP)/CONTROL/control
	echo "Maintainer: Alexander Chukov <sash@pdaXrom.org>" 	>>$(FLTK-UTF8_IPKG_TMP)/CONTROL/control
	echo "Architecture: $(SHORT_TARGET)" 			>>$(FLTK-UTF8_IPKG_TMP)/CONTROL/control
	echo "Version: $(FLTK-UTF8_VERSION)" 			>>$(FLTK-UTF8_IPKG_TMP)/CONTROL/control
	echo "Depends: xutf8, xfree430" 			>>$(FLTK-UTF8_IPKG_TMP)/CONTROL/control
	echo "Description: The Fast Light Toolkit, UTF-8 patched">>$(FLTK-UTF8_IPKG_TMP)/CONTROL/control
	cd $(FEEDDIR) && $(XMKIPKG) $(FLTK-UTF8_IPKG_TMP)
	touch $@

# ----------------------------------------------------------------------------
# Image-Install
# ----------------------------------------------------------------------------

ifdef PTXCONF_FLTK-UTF8_INSTALL
ROMPACKAGES += $(STATEDIR)/fltk-utf8.imageinstall
endif

fltk-utf8_imageinstall_deps = $(STATEDIR)/fltk-utf8.targetinstall \
	$(STATEDIR)/virtual-image.install

$(STATEDIR)/fltk-utf8.imageinstall: $(fltk-utf8_imageinstall_deps)
	@$(call targetinfo, $@)
	cd $(FEEDDIR) && $(XIPKG) install fltk-utf8
	touch $@

# ----------------------------------------------------------------------------
# Clean
# ----------------------------------------------------------------------------

fltk-utf8_clean:
	rm -rf $(STATEDIR)/fltk-utf8.*
	rm -rf $(FLTK-UTF8_DIR)

# vim: syntax=make
