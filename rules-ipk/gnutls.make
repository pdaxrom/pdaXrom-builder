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
ifdef PTXCONF_GNUTLS
PACKAGES += gnutls
endif

#
# Paths and names
#
GNUTLS_VERSION		= 1.0.10
GNUTLS			= gnutls-$(GNUTLS_VERSION)
GNUTLS_SUFFIX		= tar.gz
GNUTLS_URL		= http://www.mirrors.wiretapped.net/security/network-security/gnutls/$(GNUTLS).$(GNUTLS_SUFFIX)
GNUTLS_SOURCE		= $(SRCDIR)/$(GNUTLS).$(GNUTLS_SUFFIX)
GNUTLS_DIR		= $(BUILDDIR)/$(GNUTLS)
GNUTLS_IPKG_TMP		= $(GNUTLS_DIR)/ipkg_tmp

# ----------------------------------------------------------------------------
# Get
# ----------------------------------------------------------------------------

gnutls_get: $(STATEDIR)/gnutls.get

gnutls_get_deps = $(GNUTLS_SOURCE)

$(STATEDIR)/gnutls.get: $(gnutls_get_deps)
	@$(call targetinfo, $@)
	@$(call get_patches, $(GNUTLS))
	touch $@

$(GNUTLS_SOURCE):
	@$(call targetinfo, $@)
	@$(call get, $(GNUTLS_URL))

# ----------------------------------------------------------------------------
# Extract
# ----------------------------------------------------------------------------

gnutls_extract: $(STATEDIR)/gnutls.extract

gnutls_extract_deps = \
	$(STATEDIR)/gnutls.get \
	$(STATEDIR)/openssl.install \
	$(STATEDIR)/libtasn1.install \
	$(STATEDIR)/opencdk.install

$(STATEDIR)/gnutls.extract: $(gnutls_extract_deps)
	@$(call targetinfo, $@)
	@$(call clean, $(GNUTLS_DIR))
	@$(call extract, $(GNUTLS_SOURCE))
	@$(call patchin, $(GNUTLS))
	touch $@

# ----------------------------------------------------------------------------
# Prepare
# ----------------------------------------------------------------------------

gnutls_prepare: $(STATEDIR)/gnutls.prepare

#
# dependencies
#
gnutls_prepare_deps = \
	$(STATEDIR)/gnutls.extract \
	$(STATEDIR)/virtual-xchain.install

GNUTLS_PATH	=  PATH=$(CROSS_PATH)
GNUTLS_ENV 	=  $(CROSS_ENV)
#GNUTLS_ENV	+=
GNUTLS_ENV	+= PKG_CONFIG_PATH=$(CROSS_LIB_DIR)/lib/pkgconfig:$(CROSS_LIB_DIR)/lib/pkgconfig
#ifdef PTXCONF_XFREE430
#GNUTLS_ENV	+= LDFLAGS=-Wl,-rpath-link,$(CROSS_LIB_DIR)/lib
#endif

#
# autoconf
#
GNUTLS_AUTOCONF = \
	--build=$(GNU_HOST) \
	--host=$(PTXCONF_GNU_TARGET) \
	--prefix=/usr \
	--disable-static \
	--enable-shared

ifdef PTXCONF_XFREE430
GNUTLS_AUTOCONF += --x-includes=$(CROSS_LIB_DIR)/include
GNUTLS_AUTOCONF += --x-libraries=$(CROSS_LIB_DIR)/lib
endif

$(STATEDIR)/gnutls.prepare: $(gnutls_prepare_deps)
	@$(call targetinfo, $@)
	@$(call clean, $(GNUTLS_DIR)/config.cache)
	cd $(GNUTLS_DIR) && \
		$(GNUTLS_PATH) $(GNUTLS_ENV) \
		./configure $(GNUTLS_AUTOCONF)
	touch $@

# ----------------------------------------------------------------------------
# Compile
# ----------------------------------------------------------------------------

gnutls_compile: $(STATEDIR)/gnutls.compile

gnutls_compile_deps = $(STATEDIR)/gnutls.prepare

$(STATEDIR)/gnutls.compile: $(gnutls_compile_deps)
	@$(call targetinfo, $@)
	$(GNUTLS_PATH) $(MAKE) -C $(GNUTLS_DIR)
	touch $@

# ----------------------------------------------------------------------------
# Install
# ----------------------------------------------------------------------------

gnutls_install: $(STATEDIR)/gnutls.install

$(STATEDIR)/gnutls.install: $(STATEDIR)/gnutls.compile
	@$(call targetinfo, $@)
	$(GNUTLS_PATH) $(MAKE) -C $(GNUTLS_DIR) DESTDIR=$(GNUTLS_IPKG_TMP) install
	cp -a  $(GNUTLS_IPKG_TMP)/usr/include/* $(CROSS_LIB_DIR)/include
	cp -a  $(GNUTLS_IPKG_TMP)/usr/lib/*     $(CROSS_LIB_DIR)/lib
	cp -a  $(GNUTLS_IPKG_TMP)/usr/share/aclocal/*	$(PTXCONF_PREFIX)/share/aclocal/
	cp -a  $(GNUTLS_IPKG_TMP)/usr/bin/*-config	$(PTXCONF_PREFIX)/bin
	rm -rf $(GNUTLS_IPKG_TMP)
	perl -p -i -e "s/\/usr/`echo $(PTXCONF_PREFIX)/$(PTXCONF_GNU_TARGET) | sed -e '/\//s//\\\\\//g'`/g" $(PTXCONF_PREFIX)/bin/libgnutls-config
	perl -p -i -e "s/\/usr/`echo $(PTXCONF_PREFIX)/$(PTXCONF_GNU_TARGET) | sed -e '/\//s//\\\\\//g'`/g" $(PTXCONF_PREFIX)/bin/libgnutls-extra-config
	perl -p -i -e "s/\/usr\/lib/`echo $(PTXCONF_PREFIX)/$(PTXCONF_GNU_TARGET)/lib | sed -e '/\//s//\\\\\//g'`/g" $(PTXCONF_PREFIX)/$(PTXCONF_GNU_TARGET)/lib/libgnutls-extra.la
	perl -p -i -e "s/\/usr\/lib/`echo $(PTXCONF_PREFIX)/$(PTXCONF_GNU_TARGET)/lib | sed -e '/\//s//\\\\\//g'`/g" $(PTXCONF_PREFIX)/$(PTXCONF_GNU_TARGET)/lib/libgnutls-openssl.la
	perl -p -i -e "s/\/usr\/lib/`echo $(PTXCONF_PREFIX)/$(PTXCONF_GNU_TARGET)/lib | sed -e '/\//s//\\\\\//g'`/g" $(PTXCONF_PREFIX)/$(PTXCONF_GNU_TARGET)/lib/libgnutls.la
	touch $@

# ----------------------------------------------------------------------------
# Target-Install
# ----------------------------------------------------------------------------

gnutls_targetinstall: $(STATEDIR)/gnutls.targetinstall

gnutls_targetinstall_deps = \
	$(STATEDIR)/gnutls.compile \
	$(STATEDIR)/libtasn1.targetinstall \
	$(STATEDIR)/openssl.targetinstall \
	$(STATEDIR)/opencdk.targetinstall


$(STATEDIR)/gnutls.targetinstall: $(gnutls_targetinstall_deps)
	@$(call targetinfo, $@)
	$(GNUTLS_PATH) $(MAKE) -C $(GNUTLS_DIR) DESTDIR=$(GNUTLS_IPKG_TMP) install
	rm  -f $(GNUTLS_IPKG_TMP)/usr/bin/*-config
	$(CROSSSTRIP) $(GNUTLS_IPKG_TMP)/usr/bin/*
	rm -rf $(GNUTLS_IPKG_TMP)/usr/include
	rm -rf $(GNUTLS_IPKG_TMP)/usr/lib/*.la
	$(CROSSSTRIP) $(GNUTLS_IPKG_TMP)/usr/lib/*.so
	rm -rf $(GNUTLS_IPKG_TMP)/usr/man
	rm -rf $(GNUTLS_IPKG_TMP)/usr/share
	mkdir -p $(GNUTLS_IPKG_TMP)/CONTROL
	echo "Package: gnutls" 					>$(GNUTLS_IPKG_TMP)/CONTROL/control
	echo "Priority: optional" 				>>$(GNUTLS_IPKG_TMP)/CONTROL/control
	echo "Section: Libraries" 				>>$(GNUTLS_IPKG_TMP)/CONTROL/control
	echo "Maintainer: Alexander Chukov <sash@pdaXrom.org>"	>>$(GNUTLS_IPKG_TMP)/CONTROL/control
	echo "Architecture: $(SHORT_TARGET)" 			>>$(GNUTLS_IPKG_TMP)/CONTROL/control
	echo "Version: $(GNUTLS_VERSION)" 			>>$(GNUTLS_IPKG_TMP)/CONTROL/control
	echo "Depends: libtasn1, opencdk, libgcrypt, openssl" 	>>$(GNUTLS_IPKG_TMP)/CONTROL/control
	echo "Description: This is a TLS (Transport Layer Security) 1.0 and SSL (Secure Sockets Layer) 3.0 implementation for the GNU project.">>$(GNUTLS_IPKG_TMP)/CONTROL/control
	cd $(FEEDDIR) && $(XMKIPKG) $(GNUTLS_IPKG_TMP)
	touch $@

# ----------------------------------------------------------------------------
# Clean
# ----------------------------------------------------------------------------

gnutls_clean:
	rm -rf $(STATEDIR)/gnutls.*
	rm -rf $(GNUTLS_DIR)

# vim: syntax=make
