# -*-makefile-*-
# $Id: template,v 1.10 2004/01/24 15:50:34 mkl Exp $
#
# Copyright (C) 2004 by Alexander Chukov <Sash@pdaXrom.org>
#          
# See CREDITS for details about who has contributed to this project.
#
# For further information about the PTXdist project and license conditions
# see the README file.
#

#
# We provide this package
#
ifdef PTXCONF_LIBIDL
PACKAGES += libIDL
endif

#
# Paths and names
#
LIBIDL_VERSION		= 0.6.8
LIBIDL			= libIDL-$(LIBIDL_VERSION)
LIBIDL_SUFFIX		= tar.gz
LIBIDL_URL		= http://ftp.mozilla.org/pub/mozilla/libraries/source/$(LIBIDL).$(LIBIDL_SUFFIX)
LIBIDL_SOURCE		= $(SRCDIR)/$(LIBIDL).$(LIBIDL_SUFFIX)
LIBIDL_DIR		= $(BUILDDIR)/$(LIBIDL)
LIBIDL_IPKG_TMP		= $(LIBIDL_DIR)/ipkg_tmp

# ----------------------------------------------------------------------------
# Get
# ----------------------------------------------------------------------------

libIDL_get: $(STATEDIR)/libIDL.get

libIDL_get_deps = $(LIBIDL_SOURCE)

$(STATEDIR)/libIDL.get: $(libIDL_get_deps)
	@$(call targetinfo, $@)
	@$(call get_patches, $(LIBIDL))
	touch $@

$(LIBIDL_SOURCE):
	@$(call targetinfo, $@)
	@$(call get, $(LIBIDL_URL))

# ----------------------------------------------------------------------------
# Extract
# ----------------------------------------------------------------------------

libIDL_extract: $(STATEDIR)/libIDL.extract

libIDL_extract_deps = $(STATEDIR)/libIDL.get

$(STATEDIR)/libIDL.extract: $(libIDL_extract_deps)
	@$(call targetinfo, $@)
	@$(call clean, $(LIBIDL_DIR))
	@$(call extract, $(LIBIDL_SOURCE))
	@$(call patchin, $(LIBIDL))
	touch $@

# ----------------------------------------------------------------------------
# Prepare
# ----------------------------------------------------------------------------

libIDL_prepare: $(STATEDIR)/libIDL.prepare

#
# dependencies
#
libIDL_prepare_deps = \
	$(STATEDIR)/libIDL.extract \
	$(STATEDIR)/glib1210.install \
	$(STATEDIR)/xchain-libIDL.install \
	$(STATEDIR)/virtual-xchain.install

LIBIDL_PATH	=  PATH=$(CROSS_PATH)
LIBIDL_ENV 	=  $(CROSS_ENV)
LIBIDL_ENV	+= CFLAGS="-O2 -fomit-frame-pointer"
LIBIDL_ENV	+= PKG_CONFIG_PATH=$(CROSS_LIB_DIR)/lib/pkgconfig:$(CROSS_LIB_DIR)/lib/pkgconfig
#ifdef PTXCONF_XFREE430
#LIBIDL_ENV	+= LDFLAGS=-Wl,-rpath-link,$(CROSS_LIB_DIR)/lib
#endif

#
# autoconf
#
LIBIDL_AUTOCONF = \
	--build=$(GNU_HOST) \
	--host=$(PTXCONF_GNU_TARGET) \
	--prefix=/usr \
	--disable-debug \
	--disable-static \
	--enable-shared

ifdef PTXCONF_XFREE430
LIBIDL_AUTOCONF += --x-includes=$(CROSS_LIB_DIR)/include
LIBIDL_AUTOCONF += --x-libraries=$(CROSS_LIB_DIR)/lib
endif

$(STATEDIR)/libIDL.prepare: $(libIDL_prepare_deps)
	@$(call targetinfo, $@)
	@$(call clean, $(LIBIDL_DIR)/config.cache)
	cd $(LIBIDL_DIR) && \
		$(LIBIDL_PATH) $(LIBIDL_ENV) \
		./configure $(LIBIDL_AUTOCONF)
	touch $@

# ----------------------------------------------------------------------------
# Compile
# ----------------------------------------------------------------------------

libIDL_compile: $(STATEDIR)/libIDL.compile

libIDL_compile_deps = $(STATEDIR)/libIDL.prepare

$(STATEDIR)/libIDL.compile: $(libIDL_compile_deps)
	@$(call targetinfo, $@)
	$(LIBIDL_PATH) $(MAKE) -C $(LIBIDL_DIR)
	touch $@

# ----------------------------------------------------------------------------
# Install
# ----------------------------------------------------------------------------

libIDL_install: $(STATEDIR)/libIDL.install

$(STATEDIR)/libIDL.install: $(STATEDIR)/libIDL.compile
	@$(call targetinfo, $@)
	$(LIBIDL_PATH) $(MAKE) -C $(LIBIDL_DIR) DESTDIR=$(LIBIDL_IPKG_TMP) install
	cp -a  $(LIBIDL_IPKG_TMP)/usr/include/*        	$(CROSS_LIB_DIR)/include
	cp -a  $(LIBIDL_IPKG_TMP)/usr/lib/*            	$(CROSS_LIB_DIR)/lib
	cp -a  $(LIBIDL_IPKG_TMP)/usr/bin/libIDL-config	$(PTXCONF_PREFIX)/bin
	perl -p -i -e "s/\/usr/`echo $(PTXCONF_PREFIX)/$(PTXCONF_GNU_TARGET) | sed -e '/\//s//\\\\\//g'`/g" $(PTXCONF_PREFIX)/bin/libIDL-config
	perl -p -i -e "s/\/usr\/lib/`echo $(PTXCONF_PREFIX)/$(PTXCONF_GNU_TARGET)/lib | sed -e '/\//s//\\\\\//g'`/g" $(PTXCONF_PREFIX)/$(PTXCONF_GNU_TARGET)/lib/libIDL.la
	perl -p -i -e "s/\/usr/`echo $(PTXCONF_PREFIX)/$(PTXCONF_GNU_TARGET) | sed -e '/\//s//\\\\\//g'`/g" $(PTXCONF_PREFIX)/$(PTXCONF_GNU_TARGET)/lib/libIDLConf.sh
	rm -rf $(LIBIDL_IPKG_TMP)
	touch $@

# ----------------------------------------------------------------------------
# Target-Install
# ----------------------------------------------------------------------------

libIDL_targetinstall: $(STATEDIR)/libIDL.targetinstall

libIDL_targetinstall_deps = $(STATEDIR)/libIDL.compile \
	$(STATEDIR)/glib1210.targetinstall

$(STATEDIR)/libIDL.targetinstall: $(libIDL_targetinstall_deps)
	@$(call targetinfo, $@)
	$(LIBIDL_PATH) $(MAKE) -C $(LIBIDL_DIR) DESTDIR=$(LIBIDL_IPKG_TMP) install
	rm -rf $(LIBIDL_IPKG_TMP)/usr/bin
	rm -rf $(LIBIDL_IPKG_TMP)/usr/include
	rm -rf $(LIBIDL_IPKG_TMP)/usr/info
	rm -rf $(LIBIDL_IPKG_TMP)/usr/lib/*.*a
	rm -rf $(LIBIDL_IPKG_TMP)/usr/lib/*.sh
	rm -rf $(LIBIDL_IPKG_TMP)/usr/share
	$(CROSSSTRIP) $(LIBIDL_IPKG_TMP)/usr/lib/*
	mkdir -p $(LIBIDL_IPKG_TMP)/CONTROL
	echo "Package: libidl" 							 >$(LIBIDL_IPKG_TMP)/CONTROL/control
	echo "Priority: optional" 						>>$(LIBIDL_IPKG_TMP)/CONTROL/control
	echo "Section: Libraries" 						>>$(LIBIDL_IPKG_TMP)/CONTROL/control
	echo "Maintainer: Alexander Chukov <Sash@pdaXrom.org>" 			>>$(LIBIDL_IPKG_TMP)/CONTROL/control
	echo "Architecture: $(SHORT_TARGET)" 					>>$(LIBIDL_IPKG_TMP)/CONTROL/control
	echo "Version: $(LIBIDL_VERSION)" 					>>$(LIBIDL_IPKG_TMP)/CONTROL/control
	echo "Depends: glib" 							>>$(LIBIDL_IPKG_TMP)/CONTROL/control
	echo "Description: Interface Definition Language parsing library."	>>$(LIBIDL_IPKG_TMP)/CONTROL/control
	###cd $(FEEDDIR) && $(XMKIPKG) $(LIBIDL_IPKG_TMP)
	touch $@

# ----------------------------------------------------------------------------
# Image-Install
# ----------------------------------------------------------------------------

ifdef PTXCONF_LIBIDL_INSTALL
ROMPACKAGES += $(STATEDIR)/libIDL.imageinstall
endif

libIDL_imageinstall_deps = $(STATEDIR)/libIDL.targetinstall \
	$(STATEDIR)/virtual-image.install

$(STATEDIR)/libIDL.imageinstall: $(libIDL_imageinstall_deps)
	@$(call targetinfo, $@)
	cd $(FEEDDIR) && $(XIPKG) install libidl
	touch $@

# ----------------------------------------------------------------------------
# Clean
# ----------------------------------------------------------------------------

libIDL_clean:
	rm -rf $(STATEDIR)/libIDL.*
	rm -rf $(LIBIDL_DIR)

# vim: syntax=make
