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
ifdef PTXCONF_CURL
PACKAGES += curl
endif

#
# Paths and names
#
CURL_VENDOR_VERSION	= 1
CURL_VERSION		= 7.12.2
CURL			= curl-$(CURL_VERSION)
CURL_SUFFIX		= tar.bz2
CURL_URL		= http://curl.haxx.se/download/$(CURL).$(CURL_SUFFIX)
CURL_SOURCE		= $(SRCDIR)/$(CURL).$(CURL_SUFFIX)
CURL_DIR		= $(BUILDDIR)/$(CURL)
CURL_IPKG_TMP		= $(CURL_DIR)/ipkg_tmp

# ----------------------------------------------------------------------------
# Get
# ----------------------------------------------------------------------------

curl_get: $(STATEDIR)/curl.get

curl_get_deps = $(CURL_SOURCE)

$(STATEDIR)/curl.get: $(curl_get_deps)
	@$(call targetinfo, $@)
	@$(call get_patches, $(CURL))
	touch $@

$(CURL_SOURCE):
	@$(call targetinfo, $@)
	@$(call get, $(CURL_URL))

# ----------------------------------------------------------------------------
# Extract
# ----------------------------------------------------------------------------

curl_extract: $(STATEDIR)/curl.extract

curl_extract_deps = $(STATEDIR)/curl.get

$(STATEDIR)/curl.extract: $(curl_extract_deps)
	@$(call targetinfo, $@)
	@$(call clean, $(CURL_DIR))
	@$(call extract, $(CURL_SOURCE))
	@$(call patchin, $(CURL))
	touch $@

# ----------------------------------------------------------------------------
# Prepare
# ----------------------------------------------------------------------------

curl_prepare: $(STATEDIR)/curl.prepare

#
# dependencies
#
curl_prepare_deps = \
	$(STATEDIR)/curl.extract \
	$(STATEDIR)/openssl.install \
	$(STATEDIR)/virtual-xchain.install

CURL_PATH	=  PATH=$(CROSS_PATH)
CURL_ENV 	=  $(CROSS_ENV)
#CURL_ENV	+=
CURL_ENV	+= PKG_CONFIG_PATH=$(CROSS_LIB_DIR)/lib/pkgconfig:$(CROSS_LIB_DIR)/lib/pkgconfig
#ifdef PTXCONF_XFREE430
#CURL_ENV	+= LDFLAGS=-Wl,-rpath-link,$(CROSS_LIB_DIR)/lib
#endif

#
# autoconf
#
CURL_AUTOCONF = \
	--build=$(GNU_HOST) \
	--host=$(PTXCONF_GNU_TARGET) \
	--prefix=/usr \
	--with-zlib=$(CROSS_LIB_DIR) \
	--with-ssl=$(CROSS_LIB_DIR) \
	--with-random=/dev/urandom \
	--enable-shared \
	--disable-static

ifdef PTXCONF_XFREE430
CURL_AUTOCONF += --x-includes=$(CROSS_LIB_DIR)/include
CURL_AUTOCONF += --x-libraries=$(CROSS_LIB_DIR)/lib
endif

$(STATEDIR)/curl.prepare: $(curl_prepare_deps)
	@$(call targetinfo, $@)
	@$(call clean, $(CURL_DIR)/config.cache)
	cd $(CURL_DIR) && \
		$(CURL_PATH) $(CURL_ENV) \
		./configure $(CURL_AUTOCONF)
	touch $@

# ----------------------------------------------------------------------------
# Compile
# ----------------------------------------------------------------------------

curl_compile: $(STATEDIR)/curl.compile

curl_compile_deps = $(STATEDIR)/curl.prepare

$(STATEDIR)/curl.compile: $(curl_compile_deps)
	@$(call targetinfo, $@)
	$(CURL_PATH) $(MAKE) -C $(CURL_DIR)
	touch $@

# ----------------------------------------------------------------------------
# Install
# ----------------------------------------------------------------------------

curl_install: $(STATEDIR)/curl.install

$(STATEDIR)/curl.install: $(STATEDIR)/curl.compile
	@$(call targetinfo, $@)
	rm -rf $(CURL_IPKG_TMP)
	$(CURL_PATH) $(MAKE) -C $(CURL_DIR) DESTDIR=$(CURL_IPKG_TMP) install
	cp -a  $(CURL_IPKG_TMP)/usr/bin/curl-config		$(PTXCONF_PREFIX)/bin
	cp -a  $(CURL_IPKG_TMP)/usr/include/* 			$(CROSS_LIB_DIR)/include
	cp -a  $(CURL_IPKG_TMP)/usr/lib/*     			$(CROSS_LIB_DIR)/lib
	perl -p -i -e "s/\/usr/`echo $(PTXCONF_PREFIX)/$(PTXCONF_GNU_TARGET) | sed -e '/\//s//\\\\\//g'`/g" $(PTXCONF_PREFIX)/bin/curl-config
	perl -p -i -e "s/\/usr\/lib/`echo $(PTXCONF_PREFIX)/$(PTXCONF_GNU_TARGET)/lib | sed -e '/\//s//\\\\\//g'`/g" $(PTXCONF_PREFIX)/$(PTXCONF_GNU_TARGET)/lib/libcurl.la
	rm -rf $(CURL_IPKG_TMP)
	touch $@

# ----------------------------------------------------------------------------
# Target-Install
# ----------------------------------------------------------------------------

curl_targetinstall: $(STATEDIR)/curl.targetinstall

curl_targetinstall_deps = $(STATEDIR)/curl.compile \
	$(STATEDIR)/openssl.targetinstall

$(STATEDIR)/curl.targetinstall: $(curl_targetinstall_deps)
	@$(call targetinfo, $@)
	rm -rf $(CURL_IPKG_TMP)
	$(CURL_PATH) $(MAKE) -C $(CURL_DIR) DESTDIR=$(CURL_IPKG_TMP) install
	rm -rf $(CURL_IPKG_TMP)/usr/bin
	rm -rf $(CURL_IPKG_TMP)/usr/include
	rm -rf $(CURL_IPKG_TMP)/usr/man
	rm -rf $(CURL_IPKG_TMP)/usr/lib/*.*a
	$(CROSSSTRIP) $(CURL_IPKG_TMP)/usr/lib/*
	mkdir -p $(CURL_IPKG_TMP)/CONTROL
	echo "Package: libcurl" 									 >$(CURL_IPKG_TMP)/CONTROL/control
	echo "Priority: optional" 									>>$(CURL_IPKG_TMP)/CONTROL/control
	echo "Section: Libraries" 									>>$(CURL_IPKG_TMP)/CONTROL/control
	echo "Maintainer: Alexander Chukov <sash@pdaXrom.org>" 						>>$(CURL_IPKG_TMP)/CONTROL/control
	echo "Architecture: $(SHORT_TARGET)" 								>>$(CURL_IPKG_TMP)/CONTROL/control
	echo "Version: $(CURL_VERSION)-$(CURL_VENDOR_VERSION)" 						>>$(CURL_IPKG_TMP)/CONTROL/control
	echo "Depends: openssl, libz" 									>>$(CURL_IPKG_TMP)/CONTROL/control
	echo "Description:  Curl is a command line tool for transferring files with URL syntax, supporting FTP, FTPS, HTTP, HTTPS, GOPHER, TELNET, DICT, FILE and LDAP. Curl supports HTTPS certificates, HTTP POST, HTTP PUT, FTP uploading, kerberos, HTTP form based upload, proxies, cookies, user+password authentication, file transfer resume, http proxy tunneling and a busload of other useful tricks." >>$(CURL_IPKG_TMP)/CONTROL/control
	cd $(FEEDDIR) && $(XMKIPKG) $(CURL_IPKG_TMP)

	rm -rf $(CURL_IPKG_TMP)
	$(CURL_PATH) $(MAKE) -C $(CURL_DIR) DESTDIR=$(CURL_IPKG_TMP) install
	rm -rf $(CURL_IPKG_TMP)/usr/bin/curl-config
	rm -rf $(CURL_IPKG_TMP)/usr/include
	rm -rf $(CURL_IPKG_TMP)/usr/lib
	rm -rf $(CURL_IPKG_TMP)/usr/man
	rm -rf $(CURL_IPKG_TMP)/usr/share
	$(CROSSSTRIP) $(CURL_IPKG_TMP)/usr/bin/*
	mkdir -p $(CURL_IPKG_TMP)/CONTROL
	echo "Package: curl" 										 >$(CURL_IPKG_TMP)/CONTROL/control
	echo "Priority: optional" 									>>$(CURL_IPKG_TMP)/CONTROL/control
	echo "Section: Network" 									>>$(CURL_IPKG_TMP)/CONTROL/control
	echo "Maintainer: Alexander Chukov <sash@pdaXrom.org>" 						>>$(CURL_IPKG_TMP)/CONTROL/control
	echo "Architecture: $(SHORT_TARGET)" 								>>$(CURL_IPKG_TMP)/CONTROL/control
	echo "Version: $(CURL_VERSION)-$(CURL_VENDOR_VERSION)" 						>>$(CURL_IPKG_TMP)/CONTROL/control
	echo "Depends: libcurl" 									>>$(CURL_IPKG_TMP)/CONTROL/control
	echo "Description:  Curl is a command line tool for transferring files with URL syntax, supporting FTP, FTPS, HTTP, HTTPS, GOPHER, TELNET, DICT, FILE and LDAP. Curl supports HTTPS certificates, HTTP POST, HTTP PUT, FTP uploading, kerberos, HTTP form based upload, proxies, cookies, user+password authentication, file transfer resume, http proxy tunneling and a busload of other useful tricks." >>$(CURL_IPKG_TMP)/CONTROL/control
	cd $(FEEDDIR) && $(XMKIPKG) $(CURL_IPKG_TMP)
	touch $@

# ----------------------------------------------------------------------------
# Image-Install
# ----------------------------------------------------------------------------

ifdef PTXCONF_CURL_INSTALL
ROMPACKAGES += $(STATEDIR)/curl.imageinstall
endif

curl_imageinstall_deps = $(STATEDIR)/curl.targetinstall \
	$(STATEDIR)/virtual-image.install

$(STATEDIR)/curl.imageinstall: $(curl_imageinstall_deps)
	@$(call targetinfo, $@)
	cd $(FEEDDIR) && $(XIPKG) install curl
	touch $@

# ----------------------------------------------------------------------------
# Clean
# ----------------------------------------------------------------------------

curl_clean:
	rm -rf $(STATEDIR)/curl.*
	rm -rf $(CURL_DIR)

# vim: syntax=make
