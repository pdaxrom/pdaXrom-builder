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
ifdef PTXCONF_LIBAO
PACKAGES += libao
endif

#
# Paths and names
#
LIBAO_VERSION		= 0.8.5
LIBAO			= libao-$(LIBAO_VERSION)
LIBAO_SUFFIX		= tar.gz
LIBAO_URL		= http://www.xiph.org/ao/src/$(LIBAO).$(LIBAO_SUFFIX)
LIBAO_SOURCE		= $(SRCDIR)/$(LIBAO).$(LIBAO_SUFFIX)
LIBAO_DIR		= $(BUILDDIR)/$(LIBAO)
LIBAO_IPKG_TMP		= $(LIBAO_DIR)/ipkg_tmp

# ----------------------------------------------------------------------------
# Get
# ----------------------------------------------------------------------------

libao_get: $(STATEDIR)/libao.get

libao_get_deps = $(LIBAO_SOURCE)

$(STATEDIR)/libao.get: $(libao_get_deps)
	@$(call targetinfo, $@)
	@$(call get_patches, $(LIBAO))
	touch $@

$(LIBAO_SOURCE):
	@$(call targetinfo, $@)
	@$(call get, $(LIBAO_URL))

# ----------------------------------------------------------------------------
# Extract
# ----------------------------------------------------------------------------

libao_extract: $(STATEDIR)/libao.extract

libao_extract_deps = $(STATEDIR)/libao.get

$(STATEDIR)/libao.extract: $(libao_extract_deps)
	@$(call targetinfo, $@)
	@$(call clean, $(LIBAO_DIR))
	@$(call extract, $(LIBAO_SOURCE))
	@$(call patchin, $(LIBAO))
	touch $@

# ----------------------------------------------------------------------------
# Prepare
# ----------------------------------------------------------------------------

libao_prepare: $(STATEDIR)/libao.prepare

#
# dependencies
#
libao_prepare_deps = \
	$(STATEDIR)/libao.extract \
	$(STATEDIR)/virtual-xchain.install

LIBAO_PATH	=  PATH=$(CROSS_PATH)
LIBAO_ENV 	=  $(CROSS_ENV)
#LIBAO_ENV	+=
LIBAO_ENV	+= PKG_CONFIG_PATH=$(CROSS_LIB_DIR)/lib/pkgconfig:$(CROSS_LIB_DIR)/lib/pkgconfig
#ifdef PTXCONF_XFREE430
#LIBAO_ENV	+= LDFLAGS=-Wl,-rpath-link,$(CROSS_LIB_DIR)/lib
#endif

#
# autoconf
#
LIBAO_AUTOCONF = \
	--build=$(GNU_HOST) \
	--host=$(PTXCONF_GNU_TARGET) \
	--prefix=/usr \
	--disable-static \
	--enable-shared \
	--disable-esd \
	--disable-alsa \
	--disable-arts \
	--disable-nas

ifdef PTXCONF_XFREE430
LIBAO_AUTOCONF += --x-includes=$(CROSS_LIB_DIR)/include
LIBAO_AUTOCONF += --x-libraries=$(CROSS_LIB_DIR)/lib
endif

$(STATEDIR)/libao.prepare: $(libao_prepare_deps)
	@$(call targetinfo, $@)
	@$(call clean, $(LIBAO_DIR)/config.cache)
	cd $(LIBAO_DIR) && \
		$(LIBAO_PATH) $(LIBAO_ENV) \
		./configure $(LIBAO_AUTOCONF)
	touch $@

# ----------------------------------------------------------------------------
# Compile
# ----------------------------------------------------------------------------

libao_compile: $(STATEDIR)/libao.compile

libao_compile_deps = $(STATEDIR)/libao.prepare

$(STATEDIR)/libao.compile: $(libao_compile_deps)
	@$(call targetinfo, $@)
	$(LIBAO_PATH) $(MAKE) -C $(LIBAO_DIR)
	touch $@

# ----------------------------------------------------------------------------
# Install
# ----------------------------------------------------------------------------

libao_install: $(STATEDIR)/libao.install

$(STATEDIR)/libao.install: $(STATEDIR)/libao.compile
	@$(call targetinfo, $@)
	$(LIBAO_PATH) $(MAKE) -C $(LIBAO_DIR) DESTDIR=$(LIBAO_IPKG_TMP) install
	cp -a  $(LIBAO_IPKG_TMP)/usr/include/* 		$(CROSS_LIB_DIR)/include
	cp -a  $(LIBAO_IPKG_TMP)/usr/lib/*     		$(CROSS_LIB_DIR)/lib
	cp -a  $(LIBAO_IPKG_TMP)/usr/share/aclocal/*    $(CROSS_LIB_DIR)/share/aclocal
	rm -rf $(LIBAO_IPKG_TMP)
	rm -rf $(CROSS_LIB_DIR)/lib/ao
	perl -p -i -e "s/\/usr\/lib/`echo $(PTXCONF_PREFIX)/$(PTXCONF_GNU_TARGET)/lib | sed -e '/\//s//\\\\\//g'`/g" $(PTXCONF_PREFIX)/$(PTXCONF_GNU_TARGET)/lib/libao.la
	perl -p -i -e "s/\/usr/`echo $(PTXCONF_PREFIX)/$(PTXCONF_GNU_TARGET) | sed -e '/\//s//\\\\\//g'`/g" $(PTXCONF_PREFIX)/$(PTXCONF_GNU_TARGET)/lib/pkgconfig/ao.pc
	touch $@

# ----------------------------------------------------------------------------
# Target-Install
# ----------------------------------------------------------------------------

libao_targetinstall: $(STATEDIR)/libao.targetinstall

libao_targetinstall_deps = $(STATEDIR)/libao.compile

$(STATEDIR)/libao.targetinstall: $(libao_targetinstall_deps)
	@$(call targetinfo, $@)
	$(LIBAO_PATH) $(MAKE) -C $(LIBAO_DIR) DESTDIR=$(LIBAO_IPKG_TMP) install
	rm -rf $(LIBAO_IPKG_TMP)/usr/include
	rm -rf $(LIBAO_IPKG_TMP)/usr/share
	rm -rf $(LIBAO_IPKG_TMP)/usr/lib/pkgconfig
	rm -rf $(LIBAO_IPKG_TMP)/usr/lib/*.la
	rm -rf $(LIBAO_IPKG_TMP)/usr/lib/ao/plugins-2/*.la
	$(CROSSSTRIP) $(LIBAO_IPKG_TMP)/usr/lib/*.so
	$(CROSSSTRIP) $(LIBAO_IPKG_TMP)/usr/lib/ao/plugins-2/*.so
	mkdir -p $(LIBAO_IPKG_TMP)/CONTROL
	echo "Package: libao" 				>$(LIBAO_IPKG_TMP)/CONTROL/control
	echo "Priority: optional" 			>>$(LIBAO_IPKG_TMP)/CONTROL/control
	echo "Section: Libraries" 			>>$(LIBAO_IPKG_TMP)/CONTROL/control
	echo "Maintainer: Alexander Chukov <sash@pdaXrom.org>" >>$(LIBAO_IPKG_TMP)/CONTROL/control
	echo "Architecture: $(SHORT_TARGET)" 		>>$(LIBAO_IPKG_TMP)/CONTROL/control
	echo "Version: $(LIBAO_VERSION)" 		>>$(LIBAO_IPKG_TMP)/CONTROL/control
	echo "Depends: " 				>>$(LIBAO_IPKG_TMP)/CONTROL/control
	echo "Description: Cross-platform Audio Library">>$(LIBAO_IPKG_TMP)/CONTROL/control
	cd $(FEEDDIR) && $(XMKIPKG) $(LIBAO_IPKG_TMP)
	touch $@

# ----------------------------------------------------------------------------
# Clean
# ----------------------------------------------------------------------------

libao_clean:
	rm -rf $(STATEDIR)/libao.*
	rm -rf $(LIBAO_DIR)

# vim: syntax=make
