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
ifdef PTXCONF_XUTF8
PACKAGES += xutf8
endif

#
# Paths and names
#
XUTF8_VERSION		= 0.1.1
XUTF8			= xutf8_$(XUTF8_VERSION)-1
XUTF8_SUFFIX		= tar.gz
XUTF8_URL		= http://www.oksid.ch/xd640/$(XUTF8).$(XUTF8_SUFFIX)
XUTF8_SOURCE		= $(SRCDIR)/$(XUTF8).$(XUTF8_SUFFIX)
XUTF8_DIR		= $(BUILDDIR)/xutf8-$(XUTF8_VERSION)
XUTF8_IPKG_TMP		= $(XUTF8_DIR)/ipkg_tmp

# ----------------------------------------------------------------------------
# Get
# ----------------------------------------------------------------------------

xutf8_get: $(STATEDIR)/xutf8.get

xutf8_get_deps = $(XUTF8_SOURCE)

$(STATEDIR)/xutf8.get: $(xutf8_get_deps)
	@$(call targetinfo, $@)
	@$(call get_patches, $(XUTF8))
	touch $@

$(XUTF8_SOURCE):
	@$(call targetinfo, $@)
	@$(call get, $(XUTF8_URL))

# ----------------------------------------------------------------------------
# Extract
# ----------------------------------------------------------------------------

xutf8_extract: $(STATEDIR)/xutf8.extract

xutf8_extract_deps = $(STATEDIR)/xutf8.get

$(STATEDIR)/xutf8.extract: $(xutf8_extract_deps)
	@$(call targetinfo, $@)
	@$(call clean, $(XUTF8_DIR))
	@$(call extract, $(XUTF8_SOURCE))
	@$(call patchin, $(XUTF8), $(XUTF8_DIR))
	touch $@

# ----------------------------------------------------------------------------
# Prepare
# ----------------------------------------------------------------------------

xutf8_prepare: $(STATEDIR)/xutf8.prepare

#
# dependencies
#
xutf8_prepare_deps = \
	$(STATEDIR)/xutf8.extract \
	$(STATEDIR)/virtual-xchain.install

XUTF8_PATH	=  PATH=$(CROSS_PATH)
XUTF8_ENV 	=  $(CROSS_ENV)
XUTF8_ENV	+= CFLAGS="$(TARGET_OPT_CFLAGS)"
XUTF8_ENV	+= CXXFLAGS="$(TARGET_OPT_CFLAGS)"
XUTF8_ENV	+= PKG_CONFIG_PATH=$(CROSS_LIB_DIR)/lib/pkgconfig:$(CROSS_LIB_DIR)/lib/pkgconfig
#ifdef PTXCONF_XFREE430
#XUTF8_ENV	+= LDFLAGS=-Wl,-rpath-link,$(CROSS_LIB_DIR)/lib
#endif

#
# autoconf
#
XUTF8_AUTOCONF = \
	--build=$(GNU_HOST) \
	--host=$(PTXCONF_GNU_TARGET) \
	--prefix=/usr \
	--sysconfdir=/etc \
	--enable-shared

ifdef PTXCONF_XFREE430
XUTF8_AUTOCONF += --x-includes=$(CROSS_LIB_DIR)/include
XUTF8_AUTOCONF += --x-libraries=$(CROSS_LIB_DIR)/lib
endif

$(STATEDIR)/xutf8.prepare: $(xutf8_prepare_deps)
	@$(call targetinfo, $@)
	@$(call clean, $(XUTF8_DIR)/config.cache)
	cd $(XUTF8_DIR) && $(XUTF8_PATH) autoconf
	cd $(XUTF8_DIR) && \
		$(XUTF8_PATH) $(XUTF8_ENV) \
		./configure $(XUTF8_AUTOCONF)
	touch $@

# ----------------------------------------------------------------------------
# Compile
# ----------------------------------------------------------------------------

xutf8_compile: $(STATEDIR)/xutf8.compile

xutf8_compile_deps = $(STATEDIR)/xutf8.prepare

$(STATEDIR)/xutf8.compile: $(xutf8_compile_deps)
	@$(call targetinfo, $@)
	$(XUTF8_PATH) $(MAKE) -C $(XUTF8_DIR)
	touch $@

# ----------------------------------------------------------------------------
# Install
# ----------------------------------------------------------------------------

xutf8_install: $(STATEDIR)/xutf8.install

$(STATEDIR)/xutf8.install: $(STATEDIR)/xutf8.compile
	@$(call targetinfo, $@)
	$(XUTF8_PATH) $(MAKE) -C $(XUTF8_DIR) DESTDIR=$(XUTF8_IPKG_TMP) install
	cp -a  $(XUTF8_IPKG_TMP)/usr/include/* $(CROSS_LIB_DIR)/include
	cp -a  $(XUTF8_IPKG_TMP)/usr/lib/*     $(CROSS_LIB_DIR)/lib
	perl -p -i -e "s/\/usr\/lib/`echo $(PTXCONF_PREFIX)/$(PTXCONF_GNU_TARGET)/lib | sed -e '/\//s//\\\\\//g'`/g" $(PTXCONF_PREFIX)/$(PTXCONF_GNU_TARGET)/lib/libXutf8.la
	rm -rf $(XUTF8_IPKG_TMP)
	touch $@

# ----------------------------------------------------------------------------
# Target-Install
# ----------------------------------------------------------------------------

xutf8_targetinstall: $(STATEDIR)/xutf8.targetinstall

xutf8_targetinstall_deps = $(STATEDIR)/xutf8.compile

$(STATEDIR)/xutf8.targetinstall: $(xutf8_targetinstall_deps)
	@$(call targetinfo, $@)
	$(XUTF8_PATH) $(MAKE) -C $(XUTF8_DIR) DESTDIR=$(XUTF8_IPKG_TMP) install
	rm -rf $(XUTF8_IPKG_TMP)/usr/include
	rm  -f $(XUTF8_IPKG_TMP)/usr/lib/*.*a
	$(CROSSSTRIP) $(XUTF8_IPKG_TMP)/usr/lib/*.so*
	mkdir -p $(XUTF8_IPKG_TMP)/CONTROL
	echo "Package: xutf8" 					 >$(XUTF8_IPKG_TMP)/CONTROL/control
	echo "Priority: optional" 				>>$(XUTF8_IPKG_TMP)/CONTROL/control
	echo "Section: FLTK"		 			>>$(XUTF8_IPKG_TMP)/CONTROL/control
	echo "Maintainer: Alexander Chukov <sash@pdaXrom.org>" 	>>$(XUTF8_IPKG_TMP)/CONTROL/control
	echo "Architecture: $(SHORT_TARGET)" 			>>$(XUTF8_IPKG_TMP)/CONTROL/control
	echo "Version: $(XUTF8_VERSION)" 			>>$(XUTF8_IPKG_TMP)/CONTROL/control
	echo "Depends: libiconv, xfree430" 			>>$(XUTF8_IPKG_TMP)/CONTROL/control
	echo "Description: X11 UTF-8 support"			>>$(XUTF8_IPKG_TMP)/CONTROL/control
	cd $(FEEDDIR) && $(XMKIPKG) $(XUTF8_IPKG_TMP)
	touch $@

# ----------------------------------------------------------------------------
# Image-Install
# ----------------------------------------------------------------------------

ifdef PTXCONF_XUTF8_INSTALL
ROMPACKAGES += $(STATEDIR)/xutf8.imageinstall
endif

xutf8_imageinstall_deps = $(STATEDIR)/xutf8.targetinstall \
	$(STATEDIR)/virtual-image.install

$(STATEDIR)/xutf8.imageinstall: $(xutf8_imageinstall_deps)
	@$(call targetinfo, $@)
	cd $(FEEDDIR) && $(XIPKG) install xutf8
	touch $@

# ----------------------------------------------------------------------------
# Clean
# ----------------------------------------------------------------------------

xutf8_clean:
	rm -rf $(STATEDIR)/xutf8.*
	rm -rf $(XUTF8_DIR)

# vim: syntax=make
