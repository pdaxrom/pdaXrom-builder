# -*-makefile-*-
# $Id: template,v 1.10 2004/01/24 15:50:34 mkl Exp $
#
# Copyright (C) 2004 by Alexander Chukov <sash@cacko.biz>
#          
# See CREDITS for details about who has contributed to this project.
#
# For further information about the PTXdist project and license conditions
# see the README file.
#

#
# We provide this package
#
ifdef PTXCONF_LIBICONV
PACKAGES += libiconv
endif

#
# Paths and names
#
LIBICONV_VERSION	= 1.9.2
LIBICONV		= libiconv-$(LIBICONV_VERSION)
LIBICONV_SUFFIX		= tar.gz
LIBICONV_URL		= http://ftp.gnu.org/pub/gnu/libiconv/$(LIBICONV).$(LIBICONV_SUFFIX)
LIBICONV_SOURCE		= $(SRCDIR)/$(LIBICONV).$(LIBICONV_SUFFIX)
LIBICONV_DIR		= $(BUILDDIR)/$(LIBICONV)
LIBICONV_IPKG_TMP	= $(LIBICONV_DIR)/ipkg_tmp

# ----------------------------------------------------------------------------
# Get
# ----------------------------------------------------------------------------

libiconv_get: $(STATEDIR)/libiconv.get

libiconv_get_deps = $(LIBICONV_SOURCE)

$(STATEDIR)/libiconv.get: $(libiconv_get_deps)
	@$(call targetinfo, $@)
	@$(call get_patches, $(LIBICONV))
	touch $@

$(LIBICONV_SOURCE):
	@$(call targetinfo, $@)
	@$(call get, $(LIBICONV_URL))

# ----------------------------------------------------------------------------
# Extract
# ----------------------------------------------------------------------------

libiconv_extract: $(STATEDIR)/libiconv.extract

libiconv_extract_deps = $(STATEDIR)/libiconv.get

$(STATEDIR)/libiconv.extract: $(libiconv_extract_deps)
	@$(call targetinfo, $@)
	@$(call clean, $(LIBICONV_DIR))
	@$(call extract, $(LIBICONV_SOURCE))
	@$(call patchin, $(LIBICONV))
	touch $@

# ----------------------------------------------------------------------------
# Prepare
# ----------------------------------------------------------------------------

libiconv_prepare: $(STATEDIR)/libiconv.prepare

#
# dependencies
#
libiconv_prepare_deps = \
	$(STATEDIR)/libiconv.extract \
	$(STATEDIR)/virtual-xchain.install

LIBICONV_PATH	=  PATH=$(CROSS_PATH)
LIBICONV_ENV 	=  $(CROSS_ENV)
#LIBICONV_ENV	+=

#
# autoconf
#
LIBICONV_AUTOCONF = \
	--build=$(GNU_HOST) \
	--host=$(PTXCONF_GNU_TARGET) \
	--prefix=/usr \
	--sysconfdir=/etc \
	--disable-static --enable-shared --disable-debug

$(STATEDIR)/libiconv.prepare: $(libiconv_prepare_deps)
	@$(call targetinfo, $@)
	@$(call clean, $(LIBICONV_DIR)/config.cache)
	cd $(LIBICONV_DIR) && \
		$(LIBICONV_PATH) $(LIBICONV_ENV) \
		./configure $(LIBICONV_AUTOCONF)
	cp -f $(PTXCONF_PREFIX)/bin/libtool $(LIBICONV_DIR)
	touch $@

# ----------------------------------------------------------------------------
# Compile
# ----------------------------------------------------------------------------

libiconv_compile: $(STATEDIR)/libiconv.compile

libiconv_compile_deps = $(STATEDIR)/libiconv.prepare

$(STATEDIR)/libiconv.compile: $(libiconv_compile_deps)
	@$(call targetinfo, $@)
	$(LIBICONV_PATH) $(MAKE) -C $(LIBICONV_DIR)
	touch $@

# ----------------------------------------------------------------------------
# Install
# ----------------------------------------------------------------------------

libiconv_install: $(STATEDIR)/libiconv.install

$(STATEDIR)/libiconv.install: $(STATEDIR)/libiconv.compile
	@$(call targetinfo, $@)
	$(LIBICONV_PATH) $(MAKE) -C $(LIBICONV_DIR) prefix=$(CROSS_LIB_DIR) install
	perl -p -i -e "s/\/usr\/lib/`echo $(PTXCONF_PREFIX)/$(PTXCONF_GNU_TARGET)/lib | sed -e '/\//s//\\\\\//g'`/g" $(PTXCONF_PREFIX)/$(PTXCONF_GNU_TARGET)/lib/libiconv.la
	perl -p -i -e "s/\/usr\/lib/`echo $(PTXCONF_PREFIX)/$(PTXCONF_GNU_TARGET)/lib | sed -e '/\//s//\\\\\//g'`/g" $(PTXCONF_PREFIX)/$(PTXCONF_GNU_TARGET)/lib/libcharset.la
	rm -f $(CROSS_LIB_DIR)/sys-include/iconv.h
	touch $@

# ----------------------------------------------------------------------------
# Target-Install
# ----------------------------------------------------------------------------

libiconv_targetinstall: $(STATEDIR)/libiconv.targetinstall

libiconv_targetinstall_deps = $(STATEDIR)/libiconv.install

$(STATEDIR)/libiconv.targetinstall: $(libiconv_targetinstall_deps)
	@$(call targetinfo, $@)
	mkdir -p $(LIBICONV_IPKG_TMP)/usr/lib
	$(INSTALL) -m 755 $(CROSS_LIB_DIR)/lib/libcharset.so.1.0.0 $(LIBICONV_IPKG_TMP)/usr/lib
	$(CROSSSTRIP) $(LIBICONV_IPKG_TMP)/usr/lib/libcharset.so.1.0.0
	ln -sf libcharset.so.1.0.0 $(LIBICONV_IPKG_TMP)/usr/lib/libcharset.so.1
	ln -sf libcharset.so.1.0.0 $(LIBICONV_IPKG_TMP)/usr/lib/libcharset.so
	$(INSTALL) -m 755 $(CROSS_LIB_DIR)/lib/libiconv.so.2.2.0 $(LIBICONV_IPKG_TMP)/usr/lib
	$(CROSSSTRIP) $(LIBICONV_IPKG_TMP)/usr/lib/libiconv.so.2.2.0
	ln -sf libiconv.so.2.2.0   $(LIBICONV_IPKG_TMP)/usr/lib/libiconv.so.2
	ln -sf libiconv.so.2.2.0   $(LIBICONV_IPKG_TMP)/usr/lib/libiconv.so
	$(INSTALL) -D -m 755 $(LIBICONV_DIR)/src/iconv $(LIBICONV_IPKG_TMP)/usr/bin/iconv
	$(CROSSSTRIP) $(LIBICONV_IPKG_TMP)/usr/bin/iconv
	mkdir -p $(LIBICONV_IPKG_TMP)/CONTROL
	echo "Package: libiconv" 			>$(LIBICONV_IPKG_TMP)/CONTROL/control
	echo "Priority: optional" 			>>$(LIBICONV_IPKG_TMP)/CONTROL/control
	echo "Section: Libraries" 			>>$(LIBICONV_IPKG_TMP)/CONTROL/control
	echo "Maintainer: Alexander Chukov <sash@pdaXrom.org>" >>$(LIBICONV_IPKG_TMP)/CONTROL/control
	echo "Architecture: $(SHORT_TARGET)" 		>>$(LIBICONV_IPKG_TMP)/CONTROL/control
	echo "Version: $(LIBICONV_VERSION)" 		>>$(LIBICONV_IPKG_TMP)/CONTROL/control
	echo "Depends: " 				>>$(LIBICONV_IPKG_TMP)/CONTROL/control
	echo "Description: character set conversion library">>$(LIBICONV_IPKG_TMP)/CONTROL/control
	cd $(FEEDDIR) && $(XMKIPKG) $(LIBICONV_IPKG_TMP)

	touch $@

# ----------------------------------------------------------------------------
# Image-Install
# ----------------------------------------------------------------------------

ifdef PTXCONF_LIBICONV_INSTALL
ROMPACKAGES += $(STATEDIR)/libiconv.imageinstall
endif

libiconv_imageinstall_deps = $(STATEDIR)/libiconv.targetinstall \
	$(STATEDIR)/virtual-image.install

$(STATEDIR)/libiconv.imageinstall: $(libiconv_imageinstall_deps)
	@$(call targetinfo, $@)
	cd $(FEEDDIR) && $(XIPKG) install libiconv
	touch $@

# ----------------------------------------------------------------------------
# Clean
# ----------------------------------------------------------------------------

libiconv_clean:
	rm -rf $(STATEDIR)/libiconv.*
	rm -rf $(LIBICONV_DIR)

# vim: syntax=make
