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
ifdef PTXCONF_TSLIB
PACKAGES += tslib
endif

#
# Paths and names
#
TSLIB_VERSION		= 1.3
TSLIB			= tslib-$(TSLIB_VERSION)
TSLIB_SUFFIX		= tar.bz2
TSLIB_URL		= http://www.cacko.biz/src/$(TSLIB).$(TSLIB_SUFFIX)
TSLIB_SOURCE		= $(SRCDIR)/$(TSLIB).$(TSLIB_SUFFIX)
TSLIB_DIR		= $(BUILDDIR)/$(TSLIB)
TSLIB_IPKG_TMP		= $(TSLIB_DIR)/ipkg_tmp

# ----------------------------------------------------------------------------
# Get
# ----------------------------------------------------------------------------

tslib_get: $(STATEDIR)/tslib.get

tslib_get_deps = $(TSLIB_SOURCE)

$(STATEDIR)/tslib.get: $(tslib_get_deps)
	@$(call targetinfo, $@)
	@$(call get_patches, $(TSLIB))
	touch $@

$(TSLIB_SOURCE):
	@$(call targetinfo, $@)
	@$(call get, $(TSLIB_URL))

# ----------------------------------------------------------------------------
# Extract
# ----------------------------------------------------------------------------

tslib_extract: $(STATEDIR)/tslib.extract

tslib_extract_deps = $(STATEDIR)/tslib.get

$(STATEDIR)/tslib.extract: $(tslib_extract_deps)
	@$(call targetinfo, $@)
	@$(call clean, $(TSLIB_DIR))
	@$(call extract, $(TSLIB_SOURCE))
	@$(call patchin, $(TSLIB))
	touch $@

# ----------------------------------------------------------------------------
# Prepare
# ----------------------------------------------------------------------------

tslib_prepare: $(STATEDIR)/tslib.prepare

#
# dependencies
#
tslib_prepare_deps = \
	$(STATEDIR)/tslib.extract \
	$(STATEDIR)/virtual-xchain.install

TSLIB_PATH	=  PATH=$(CROSS_PATH)
TSLIB_ENV 	=  $(CROSS_ENV)
#TSLIB_ENV	+=

#
# autoconf
#
TSLIB_AUTOCONF = \
	--build=$(GNU_HOST) \
	--host=$(PTXCONF_GNU_TARGET) \
	--prefix=$(CROSS_LIB_DIR)

$(STATEDIR)/tslib.prepare: $(tslib_prepare_deps)
	@$(call targetinfo, $@)
	@$(call clean, $(TSLIB_DIR)/config.cache)
	cd $(TSLIB_DIR) && \
		$(TSLIB_PATH) $(TSLIB_ENV) \
		./autogen.sh
	cd $(TSLIB_DIR) && \
		$(TSLIB_PATH) $(TSLIB_ENV) \
		./configure $(TSLIB_AUTOCONF) --datadir=/usr/share --sysconfdir=/etc
	touch $@

# ----------------------------------------------------------------------------
# Compile
# ----------------------------------------------------------------------------

tslib_compile: $(STATEDIR)/tslib.compile

tslib_compile_deps = $(STATEDIR)/tslib.prepare

$(STATEDIR)/tslib.compile: $(tslib_compile_deps)
	@$(call targetinfo, $@)
	$(TSLIB_PATH) $(MAKE) -C $(TSLIB_DIR) PLUGIN_DIR=/usr/share/ts/plugins TS_CONF=/etc/ts.conf
	touch $@

# ----------------------------------------------------------------------------
# Install
# ----------------------------------------------------------------------------

tslib_install: $(STATEDIR)/tslib.install

$(STATEDIR)/tslib.install: $(STATEDIR)/tslib.compile
	@$(call targetinfo, $@)
	install $(TSLIB_DIR)/src/.libs/libts-0.0.so.0.1.0 $(CROSS_LIB_DIR)/lib
	ln -sf libts-0.0.so.0.1.0 $(CROSS_LIB_DIR)/lib/libts-0.0.so.0
	ln -sf libts-0.0.so.0.1.0 $(CROSS_LIB_DIR)/lib/libts.so
	cp $(TSLIB_DIR)/src/tslib.h $(CROSS_LIB_DIR)/include
	touch $@

# ----------------------------------------------------------------------------
# Target-Install
# ----------------------------------------------------------------------------

tslib_targetinstall: $(STATEDIR)/tslib.targetinstall

tslib_targetinstall_deps = $(STATEDIR)/tslib.compile

$(STATEDIR)/tslib.targetinstall: $(tslib_targetinstall_deps)
	@$(call targetinfo, $@)
	
	mkdir -p $(TSLIB_IPKG_TMP)/usr/bin
	mkdir -p $(TSLIB_IPKG_TMP)/usr/lib
	mkdir -p $(TSLIB_IPKG_TMP)/etc
	
	install $(TSLIB_DIR)/src/.libs/libts-0.0.so.0.1.0 $(TSLIB_IPKG_TMP)/usr/lib
	$(CROSSSTRIP) -R .note -R comment  $(TSLIB_IPKG_TMP)/usr/lib/libts-0.0.so.0.1.0
	ln -sf libts-0.0.so.0.1.0          $(TSLIB_IPKG_TMP)/usr/lib/libts-0.0.so.0
	install -d $(TSLIB_IPKG_TMP)/usr/share/ts/plugins
	cp -a $(TSLIB_DIR)/plugins/.libs/*.so $(TSLIB_IPKG_TMP)/usr/share/ts/plugins
	$(CROSSSTRIP) -R .note -R comment     $(TSLIB_IPKG_TMP)/usr/share/ts/plugins/*.so
	cp -a $(TSLIB_DIR)/tests/.libs/ts_*   $(TSLIB_IPKG_TMP)/usr/bin
	$(CROSSSTRIP) -R .note -R comment     $(TSLIB_IPKG_TMP)/usr/bin/ts_*
	cp -a $(TSLIB_DIR)/etc/ts.conf        $(TSLIB_IPKG_TMP)/etc

	mkdir -p $(TSLIB_IPKG_TMP)/CONTROL
	echo "Package: tslib" 				 >$(TSLIB_IPKG_TMP)/CONTROL/control
	echo "Priority: optional" 			>>$(TSLIB_IPKG_TMP)/CONTROL/control
	echo "Section: Libraries"	 		>>$(TSLIB_IPKG_TMP)/CONTROL/control
	echo "Maintainer: Alexander Chukov <sash@pdaXrom.org>">>$(TSLIB_IPKG_TMP)/CONTROL/control
	echo "Architecture: $(SHORT_TARGET)" 		>>$(TSLIB_IPKG_TMP)/CONTROL/control
	echo "Version: $(TSLIB_VERSION)" 		>>$(TSLIB_IPKG_TMP)/CONTROL/control
	echo "Depends: " 				>>$(TSLIB_IPKG_TMP)/CONTROL/control
	echo "Description: touchscreen interface library.">>$(TSLIB_IPKG_TMP)/CONTROL/control
	cd $(FEEDDIR) && $(XMKIPKG) $(TSLIB_IPKG_TMP)

	touch $@

# ----------------------------------------------------------------------------
# Image-Install
# ----------------------------------------------------------------------------

ifdef PTXCONF_TSLIB_INSTALL
ROMPACKAGES += $(STATEDIR)/tslib.imageinstall
endif

tslib_imageinstall_deps = $(STATEDIR)/tslib.targetinstall \
	$(STATEDIR)/virtual-image.install

$(STATEDIR)/tslib.imageinstall: $(tslib_imageinstall_deps)
	@$(call targetinfo, $@)
	cd $(FEEDDIR) && $(XIPKG) install tslib
	touch $@

# ----------------------------------------------------------------------------
# Clean
# ----------------------------------------------------------------------------

tslib_clean:
	rm -rf $(STATEDIR)/tslib.*
	rm -rf $(TSLIB_DIR)

# vim: syntax=make
