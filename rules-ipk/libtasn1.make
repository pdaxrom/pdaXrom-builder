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
ifdef PTXCONF_LIBTASN1
PACKAGES += libtasn1
endif

#
# Paths and names
#
LIBTASN1_VERSION	= 0.2.9
LIBTASN1		= libtasn1-$(LIBTASN1_VERSION)
LIBTASN1_SUFFIX		= tar.gz
LIBTASN1_URL		= http://www.mirrors.wiretapped.net/security/network-security/gnutls/libtasn1/$(LIBTASN1).$(LIBTASN1_SUFFIX)
LIBTASN1_SOURCE		= $(SRCDIR)/$(LIBTASN1).$(LIBTASN1_SUFFIX)
LIBTASN1_DIR		= $(BUILDDIR)/$(LIBTASN1)
LIBTASN1_IPKG_TMP	= $(LIBTASN1_DIR)/ipkg_tmp

# ----------------------------------------------------------------------------
# Get
# ----------------------------------------------------------------------------

libtasn1_get: $(STATEDIR)/libtasn1.get

libtasn1_get_deps = $(LIBTASN1_SOURCE)

$(STATEDIR)/libtasn1.get: $(libtasn1_get_deps)
	@$(call targetinfo, $@)
	@$(call get_patches, $(LIBTASN1))
	touch $@

$(LIBTASN1_SOURCE):
	@$(call targetinfo, $@)
	@$(call get, $(LIBTASN1_URL))

# ----------------------------------------------------------------------------
# Extract
# ----------------------------------------------------------------------------

libtasn1_extract: $(STATEDIR)/libtasn1.extract

libtasn1_extract_deps = $(STATEDIR)/libtasn1.get

$(STATEDIR)/libtasn1.extract: $(libtasn1_extract_deps)
	@$(call targetinfo, $@)
	@$(call clean, $(LIBTASN1_DIR))
	@$(call extract, $(LIBTASN1_SOURCE))
	@$(call patchin, $(LIBTASN1))
	touch $@

# ----------------------------------------------------------------------------
# Prepare
# ----------------------------------------------------------------------------

libtasn1_prepare: $(STATEDIR)/libtasn1.prepare

#
# dependencies
#
libtasn1_prepare_deps = \
	$(STATEDIR)/libtasn1.extract \
	$(STATEDIR)/virtual-xchain.install

LIBTASN1_PATH	=  PATH=$(CROSS_PATH)
LIBTASN1_ENV 	=  $(CROSS_ENV)
#LIBTASN1_ENV	+=
LIBTASN1_ENV	+= PKG_CONFIG_PATH=$(CROSS_LIB_DIR)/lib/pkgconfig:$(CROSS_LIB_DIR)/lib/pkgconfig
#ifdef PTXCONF_XFREE430
#LIBTASN1_ENV	+= LDFLAGS=-Wl,-rpath-link,$(CROSS_LIB_DIR)/lib
#endif

#
# autoconf
#
LIBTASN1_AUTOCONF = \
	--build=$(GNU_HOST) \
	--host=$(PTXCONF_GNU_TARGET) \
	--prefix=/usr \
	--disable-static \
	--enable-shared

ifdef PTXCONF_XFREE430
LIBTASN1_AUTOCONF += --x-includes=$(CROSS_LIB_DIR)/include
LIBTASN1_AUTOCONF += --x-libraries=$(CROSS_LIB_DIR)/lib
endif

$(STATEDIR)/libtasn1.prepare: $(libtasn1_prepare_deps)
	@$(call targetinfo, $@)
	@$(call clean, $(LIBTASN1_DIR)/config.cache)
	cd $(LIBTASN1_DIR) && \
		$(LIBTASN1_PATH) $(LIBTASN1_ENV) \
		./configure $(LIBTASN1_AUTOCONF)
	touch $@

# ----------------------------------------------------------------------------
# Compile
# ----------------------------------------------------------------------------

libtasn1_compile: $(STATEDIR)/libtasn1.compile

libtasn1_compile_deps = $(STATEDIR)/libtasn1.prepare

$(STATEDIR)/libtasn1.compile: $(libtasn1_compile_deps)
	@$(call targetinfo, $@)
	$(LIBTASN1_PATH) $(MAKE) -C $(LIBTASN1_DIR)
	touch $@

# ----------------------------------------------------------------------------
# Install
# ----------------------------------------------------------------------------

libtasn1_install: $(STATEDIR)/libtasn1.install

$(STATEDIR)/libtasn1.install: $(STATEDIR)/libtasn1.compile
	@$(call targetinfo, $@)
	$(LIBTASN1_PATH) $(MAKE) -C $(LIBTASN1_DIR) DESTDIR=$(LIBTASN1_IPKG_TMP) install
	cp -a  $(LIBTASN1_IPKG_TMP)/usr/include/* $(CROSS_LIB_DIR)/include
	cp -a  $(LIBTASN1_IPKG_TMP)/usr/lib/*     $(CROSS_LIB_DIR)/lib
	rm -rf $(LIBTASN1_IPKG_TMP)
	perl -p -i -e "s/\/usr\/lib/`echo $(PTXCONF_PREFIX)/$(PTXCONF_GNU_TARGET)/lib | sed -e '/\//s//\\\\\//g'`/g" $(PTXCONF_PREFIX)/$(PTXCONF_GNU_TARGET)/lib/libtasn1.la
	touch $@

# ----------------------------------------------------------------------------
# Target-Install
# ----------------------------------------------------------------------------

libtasn1_targetinstall: $(STATEDIR)/libtasn1.targetinstall

libtasn1_targetinstall_deps = $(STATEDIR)/libtasn1.compile

$(STATEDIR)/libtasn1.targetinstall: $(libtasn1_targetinstall_deps)
	@$(call targetinfo, $@)
	$(LIBTASN1_PATH) $(MAKE) -C $(LIBTASN1_DIR) DESTDIR=$(LIBTASN1_IPKG_TMP) install
	rm -rf $(LIBTASN1_IPKG_TMP)/usr/include
	rm -rf $(LIBTASN1_IPKG_TMP)/usr/lib/*.la
	$(CROSSSTRIP) $(LIBTASN1_IPKG_TMP)/usr/lib/*.so
	mkdir -p $(LIBTASN1_IPKG_TMP)/CONTROL
	echo "Package: libtasn1" 			>$(LIBTASN1_IPKG_TMP)/CONTROL/control
	echo "Priority: optional" 			>>$(LIBTASN1_IPKG_TMP)/CONTROL/control
	echo "Section: Libraries" 			>>$(LIBTASN1_IPKG_TMP)/CONTROL/control
	echo "Maintainer: Alexander Chukov <sash@pdaXrom.org>">>$(LIBTASN1_IPKG_TMP)/CONTROL/control
	echo "Architecture: $(SHORT_TARGET)" 		>>$(LIBTASN1_IPKG_TMP)/CONTROL/control
	echo "Version: $(LIBTASN1_VERSION)" 		>>$(LIBTASN1_IPKG_TMP)/CONTROL/control
	echo "Depends: " 				>>$(LIBTASN1_IPKG_TMP)/CONTROL/control
	echo "Description: This is the ASN.1 library used in GNUTLS.">>$(LIBTASN1_IPKG_TMP)/CONTROL/control
	cd $(FEEDDIR) && $(XMKIPKG) $(LIBTASN1_IPKG_TMP)
	touch $@

# ----------------------------------------------------------------------------
# Clean
# ----------------------------------------------------------------------------

libtasn1_clean:
	rm -rf $(STATEDIR)/libtasn1.*
	rm -rf $(LIBTASN1_DIR)

# vim: syntax=make
