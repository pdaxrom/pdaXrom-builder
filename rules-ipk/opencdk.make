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
ifdef PTXCONF_OPENCDK
PACKAGES += opencdk
endif

#
# Paths and names
#
OPENCDK_VERSION		= 0.5.4
OPENCDK			= opencdk-$(OPENCDK_VERSION)
OPENCDK_SUFFIX		= tar.gz
OPENCDK_URL		= http://www.mirrors.wiretapped.net/security/network-security/gnutls/opencdk/$(OPENCDK).$(OPENCDK_SUFFIX)
OPENCDK_SOURCE		= $(SRCDIR)/$(OPENCDK).$(OPENCDK_SUFFIX)
OPENCDK_DIR		= $(BUILDDIR)/$(OPENCDK)
OPENCDK_IPKG_TMP	= $(OPENCDK_DIR)/ipkg_tmp

# ----------------------------------------------------------------------------
# Get
# ----------------------------------------------------------------------------

opencdk_get: $(STATEDIR)/opencdk.get

opencdk_get_deps = $(OPENCDK_SOURCE)

$(STATEDIR)/opencdk.get: $(opencdk_get_deps)
	@$(call targetinfo, $@)
	@$(call get_patches, $(OPENCDK))
	touch $@

$(OPENCDK_SOURCE):
	@$(call targetinfo, $@)
	@$(call get, $(OPENCDK_URL))

# ----------------------------------------------------------------------------
# Extract
# ----------------------------------------------------------------------------

opencdk_extract: $(STATEDIR)/opencdk.extract

opencdk_extract_deps = $(STATEDIR)/opencdk.get

$(STATEDIR)/opencdk.extract: $(opencdk_extract_deps)
	@$(call targetinfo, $@)
	@$(call clean, $(OPENCDK_DIR))
	@$(call extract, $(OPENCDK_SOURCE))
	@$(call patchin, $(OPENCDK))
	touch $@

# ----------------------------------------------------------------------------
# Prepare
# ----------------------------------------------------------------------------

opencdk_prepare: $(STATEDIR)/opencdk.prepare

#
# dependencies
#
opencdk_prepare_deps = \
	$(STATEDIR)/opencdk.extract \
	$(STATEDIR)/libgcrypt.install \
	$(STATEDIR)/virtual-xchain.install

OPENCDK_PATH	=  PATH=$(CROSS_PATH)
OPENCDK_ENV 	=  $(CROSS_ENV)
#OPENCDK_ENV	+=
OPENCDK_ENV	+= PKG_CONFIG_PATH=$(CROSS_LIB_DIR)/lib/pkgconfig:$(CROSS_LIB_DIR)/lib/pkgconfig
#ifdef PTXCONF_XFREE430
#OPENCDK_ENV	+= LDFLAGS=-Wl,-rpath-link,$(CROSS_LIB_DIR)/lib
#endif

#
# autoconf
#
OPENCDK_AUTOCONF = \
	--build=$(GNU_HOST) \
	--host=$(PTXCONF_GNU_TARGET) \
	--prefix=/usr \
	--disable-static \
	--enable-shared

ifdef PTXCONF_XFREE430
OPENCDK_AUTOCONF += --x-includes=$(CROSS_LIB_DIR)/include
OPENCDK_AUTOCONF += --x-libraries=$(CROSS_LIB_DIR)/lib
endif

$(STATEDIR)/opencdk.prepare: $(opencdk_prepare_deps)
	@$(call targetinfo, $@)
	@$(call clean, $(OPENCDK_DIR)/config.cache)
	cd $(OPENCDK_DIR) && \
		$(OPENCDK_PATH) $(OPENCDK_ENV) \
		./configure $(OPENCDK_AUTOCONF)
	touch $@

# ----------------------------------------------------------------------------
# Compile
# ----------------------------------------------------------------------------

opencdk_compile: $(STATEDIR)/opencdk.compile

opencdk_compile_deps = $(STATEDIR)/opencdk.prepare

$(STATEDIR)/opencdk.compile: $(opencdk_compile_deps)
	@$(call targetinfo, $@)
	$(OPENCDK_PATH) $(MAKE) -C $(OPENCDK_DIR)
	touch $@

# ----------------------------------------------------------------------------
# Install
# ----------------------------------------------------------------------------

opencdk_install: $(STATEDIR)/opencdk.install

$(STATEDIR)/opencdk.install: $(STATEDIR)/opencdk.compile
	@$(call targetinfo, $@)
	$(OPENCDK_PATH) $(MAKE) -C $(OPENCDK_DIR) DESTDIR=$(OPENCDK_IPKG_TMP) install
	cp -a  $(OPENCDK_IPKG_TMP)/usr/include/* $(CROSS_LIB_DIR)/include
	cp -a  $(OPENCDK_IPKG_TMP)/usr/lib/*     $(CROSS_LIB_DIR)/lib
	cp -a  $(OPENCDK_IPKG_TMP)/usr/bin/opencdk-config $(PTXCONF_PREFIX)/bin
	rm -rf $(OPENCDK_IPKG_TMP)
	perl -p -i -e "s/\/usr/`echo $(PTXCONF_PREFIX)/$(PTXCONF_GNU_TARGET) | sed -e '/\//s//\\\\\//g'`/g" $(PTXCONF_PREFIX)/bin/opencdk-config
	perl -p -i -e "s/\/usr\/lib/`echo $(PTXCONF_PREFIX)/$(PTXCONF_GNU_TARGET)/lib | sed -e '/\//s//\\\\\//g'`/g" $(PTXCONF_PREFIX)/$(PTXCONF_GNU_TARGET)/lib/libopencdk.la
	touch $@

# ----------------------------------------------------------------------------
# Target-Install
# ----------------------------------------------------------------------------

opencdk_targetinstall: $(STATEDIR)/opencdk.targetinstall

opencdk_targetinstall_deps = \
	$(STATEDIR)/libgcrypt.targetinstall \
	$(STATEDIR)/opencdk.compile

$(STATEDIR)/opencdk.targetinstall: $(opencdk_targetinstall_deps)
	@$(call targetinfo, $@)
	$(OPENCDK_PATH) $(MAKE) -C $(OPENCDK_DIR) DESTDIR=$(OPENCDK_IPKG_TMP) install
	rm -rf $(OPENCDK_IPKG_TMP)/usr/bin
	rm -rf $(OPENCDK_IPKG_TMP)/usr/include
	rm -rf $(OPENCDK_IPKG_TMP)/usr/lib/*.la
	$(CROSSSTRIP) $(OPENCDK_IPKG_TMP)/usr/lib/*.so
	mkdir -p $(OPENCDK_IPKG_TMP)/CONTROL
	echo "Package: opencdk" 			>$(OPENCDK_IPKG_TMP)/CONTROL/control
	echo "Priority: optional" 			>>$(OPENCDK_IPKG_TMP)/CONTROL/control
	echo "Section: Libraries" 			>>$(OPENCDK_IPKG_TMP)/CONTROL/control
	echo "Maintainer: Alexander Chukov <sash@pdaXrom.org>">>$(OPENCDK_IPKG_TMP)/CONTROL/control
	echo "Architecture: $(SHORT_TARGET)" 		>>$(OPENCDK_IPKG_TMP)/CONTROL/control
	echo "Version: $(OPENCDK_VERSION)" 		>>$(OPENCDK_IPKG_TMP)/CONTROL/control
	echo "Depends: libgcrypt" 			>>$(OPENCDK_IPKG_TMP)/CONTROL/control
	echo "Description: Open Crypto Development Kit">>$(OPENCDK_IPKG_TMP)/CONTROL/control
	cd $(FEEDDIR) && $(XMKIPKG) $(OPENCDK_IPKG_TMP)
	touch $@

# ----------------------------------------------------------------------------
# Clean
# ----------------------------------------------------------------------------

opencdk_clean:
	rm -rf $(STATEDIR)/opencdk.*
	rm -rf $(OPENCDK_DIR)

# vim: syntax=make
