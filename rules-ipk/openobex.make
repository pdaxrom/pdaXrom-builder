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
ifdef PTXCONF_OPENOBEX
PACKAGES += openobex
endif

#
# Paths and names
#
OPENOBEX_VERSION	= 1.0.1
OPENOBEX		= openobex-$(OPENOBEX_VERSION)
OPENOBEX_SUFFIX		= tar.gz
OPENOBEX_URL		= http://heanet.dl.sourceforge.net/sourceforge/openobex/$(OPENOBEX).$(OPENOBEX_SUFFIX)
OPENOBEX_SOURCE		= $(SRCDIR)/$(OPENOBEX).$(OPENOBEX_SUFFIX)
OPENOBEX_DIR		= $(BUILDDIR)/$(OPENOBEX)
OPENOBEX_IPKG_TMP	= $(OPENOBEX_DIR)/ipkg_tmp

# ----------------------------------------------------------------------------
# Get
# ----------------------------------------------------------------------------

openobex_get: $(STATEDIR)/openobex.get

openobex_get_deps = $(OPENOBEX_SOURCE)

$(STATEDIR)/openobex.get: $(openobex_get_deps)
	@$(call targetinfo, $@)
	@$(call get_patches, $(OPENOBEX))
	touch $@

$(OPENOBEX_SOURCE):
	@$(call targetinfo, $@)
	@$(call get, $(OPENOBEX_URL))

# ----------------------------------------------------------------------------
# Extract
# ----------------------------------------------------------------------------

openobex_extract: $(STATEDIR)/openobex.extract

openobex_extract_deps = $(STATEDIR)/openobex.get

$(STATEDIR)/openobex.extract: $(openobex_extract_deps)
	@$(call targetinfo, $@)
	@$(call clean, $(OPENOBEX_DIR))
	@$(call extract, $(OPENOBEX_SOURCE))
	@$(call patchin, $(OPENOBEX))
	touch $@

# ----------------------------------------------------------------------------
# Prepare
# ----------------------------------------------------------------------------

openobex_prepare: $(STATEDIR)/openobex.prepare

#
# dependencies
#
openobex_prepare_deps = \
	$(STATEDIR)/openobex.extract \
	$(STATEDIR)/virtual-xchain.install

OPENOBEX_PATH	=  PATH=$(CROSS_PATH)
OPENOBEX_ENV 	=  $(CROSS_ENV)
OPENOBEX_ENV	+= CFLAGS="-O2 -fomit-frame-pointer"
OPENOBEX_ENV	+= PKG_CONFIG_PATH=$(CROSS_LIB_DIR)/lib/pkgconfig:$(CROSS_LIB_DIR)/lib/pkgconfig
#ifdef PTXCONF_XFREE430
#OPENOBEX_ENV	+= LDFLAGS=-Wl,-rpath-link,$(CROSS_LIB_DIR)/lib
#endif

#
# autoconf
#
OPENOBEX_AUTOCONF = \
	--build=$(GNU_HOST) \
	--host=$(PTXCONF_GNU_TARGET) \
	--prefix=/usr \
	--disable-static \
	--enable-shared

ifdef PTXCONF_XFREE430
OPENOBEX_AUTOCONF += --x-includes=$(CROSS_LIB_DIR)/include
OPENOBEX_AUTOCONF += --x-libraries=$(CROSS_LIB_DIR)/lib
endif

$(STATEDIR)/openobex.prepare: $(openobex_prepare_deps)
	@$(call targetinfo, $@)
	@$(call clean, $(OPENOBEX_DIR)/config.cache)
	##cd $(OPENOBEX_DIR) && aclocal
	##cd $(OPENOBEX_DIR) && automake --add-missing
	##cd $(OPENOBEX_DIR) && autoconf
	cd $(OPENOBEX_DIR) && \
		$(OPENOBEX_PATH) $(OPENOBEX_ENV) \
		./configure $(OPENOBEX_AUTOCONF)
	touch $@

# ----------------------------------------------------------------------------
# Compile
# ----------------------------------------------------------------------------

openobex_compile: $(STATEDIR)/openobex.compile

openobex_compile_deps = $(STATEDIR)/openobex.prepare

$(STATEDIR)/openobex.compile: $(openobex_compile_deps)
	@$(call targetinfo, $@)
	$(OPENOBEX_PATH) $(MAKE) -C $(OPENOBEX_DIR)
	touch $@

# ----------------------------------------------------------------------------
# Install
# ----------------------------------------------------------------------------

openobex_install: $(STATEDIR)/openobex.install

$(STATEDIR)/openobex.install: $(STATEDIR)/openobex.compile
	@$(call targetinfo, $@)
	$(OPENOBEX_PATH) $(MAKE) -C $(OPENOBEX_DIR) DESTDIR=$(OPENOBEX_IPKG_TMP) install
	cp -a  $(OPENOBEX_IPKG_TMP)/usr/include/* $(CROSS_LIB_DIR)/include
	cp -a  $(OPENOBEX_IPKG_TMP)/usr/lib/*     $(CROSS_LIB_DIR)/lib
	cp -a  $(OPENOBEX_IPKG_TMP)/usr/bin/openobex-config $(PTXCONF_PREFIX)/bin
	perl -p -i -e "s/\/usr/`echo $(PTXCONF_PREFIX)/$(PTXCONF_GNU_TARGET) | sed -e '/\//s//\\\\\//g'`/g" $(PTXCONF_PREFIX)/bin/openobex-config
	perl -p -i -e "s/\/usr\/lib/`echo $(PTXCONF_PREFIX)/$(PTXCONF_GNU_TARGET)/lib | sed -e '/\//s//\\\\\//g'`/g" $(PTXCONF_PREFIX)/$(PTXCONF_GNU_TARGET)/lib/libopenobex.la
	rm -rf $(OPENOBEX_IPKG_TMP)
	touch $@

# ----------------------------------------------------------------------------
# Target-Install
# ----------------------------------------------------------------------------

openobex_targetinstall: $(STATEDIR)/openobex.targetinstall

openobex_targetinstall_deps = $(STATEDIR)/openobex.compile

$(STATEDIR)/openobex.targetinstall: $(openobex_targetinstall_deps)
	@$(call targetinfo, $@)
	$(OPENOBEX_PATH) $(MAKE) -C $(OPENOBEX_DIR) DESTDIR=$(OPENOBEX_IPKG_TMP) install
	rm -rf $(OPENOBEX_IPKG_TMP)/usr/bin
	rm -rf $(OPENOBEX_IPKG_TMP)/usr/include
	rm -rf $(OPENOBEX_IPKG_TMP)/usr/lib/*.*a
	rm -rf $(OPENOBEX_IPKG_TMP)/usr/share
	$(CROSSSTRIP) $(OPENOBEX_IPKG_TMP)/usr/lib/*.so*
	mkdir -p $(OPENOBEX_IPKG_TMP)/CONTROL
	echo "Package: openobex" 				 >$(OPENOBEX_IPKG_TMP)/CONTROL/control
	echo "Priority: optional" 				>>$(OPENOBEX_IPKG_TMP)/CONTROL/control
	echo "Section: IrDA"	 				>>$(OPENOBEX_IPKG_TMP)/CONTROL/control
	echo "Maintainer: Alexander Chukov <sash@pdaXrom.org>" 	>>$(OPENOBEX_IPKG_TMP)/CONTROL/control
	echo "Architecture: $(SHORT_TARGET)" 			>>$(OPENOBEX_IPKG_TMP)/CONTROL/control
	echo "Version: $(OPENOBEX_VERSION)" 			>>$(OPENOBEX_IPKG_TMP)/CONTROL/control
	echo "Depends: " 					>>$(OPENOBEX_IPKG_TMP)/CONTROL/control
	echo "Description: This library tries to implement a generic OBEX Session Protocol. It does not implement the OBEX Application FrameWork.">>$(OPENOBEX_IPKG_TMP)/CONTROL/control
	cd $(FEEDDIR) && $(XMKIPKG) $(OPENOBEX_IPKG_TMP)
	touch $@

# ----------------------------------------------------------------------------
# Image-Install
# ----------------------------------------------------------------------------

ifdef PTXCONF_OPENOBEX_INSTALL
ROMPACKAGES += $(STATEDIR)/openobex.imageinstall
endif

openobex_imageinstall_deps = $(STATEDIR)/openobex.targetinstall \
	$(STATEDIR)/virtual-image.install

$(STATEDIR)/openobex.imageinstall: $(openobex_imageinstall_deps)
	@$(call targetinfo, $@)
	cd $(FEEDDIR) && $(XIPKG) install openobex
	touch $@

# ----------------------------------------------------------------------------
# Clean
# ----------------------------------------------------------------------------

openobex_clean:
	rm -rf $(STATEDIR)/openobex.*
	rm -rf $(OPENOBEX_DIR)

# vim: syntax=make
