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
ifdef PTXCONF_SYLPHEED
PACKAGES += sylpheed
endif

#
# Paths and names
#
SYLPHEED_VERSION	= 0.9.9
SYLPHEED		= sylpheed-$(SYLPHEED_VERSION)-gtk2-20040229
SYLPHEED_SUFFIX		= tar.gz
SYLPHEED_URL		= http://heanet.dl.sourceforge.net/sourceforge/sylpheed-gtk2/$(SYLPHEED).$(SYLPHEED_SUFFIX)
SYLPHEED_SOURCE		= $(SRCDIR)/$(SYLPHEED).$(SYLPHEED_SUFFIX)
SYLPHEED_DIR		= $(BUILDDIR)/$(SYLPHEED)
SYLPHEED_IPKG_TMP	= $(SYLPHEED_DIR)/ipkg_tmp

# ----------------------------------------------------------------------------
# Get
# ----------------------------------------------------------------------------

sylpheed_get: $(STATEDIR)/sylpheed.get

sylpheed_get_deps = $(SYLPHEED_SOURCE)

$(STATEDIR)/sylpheed.get: $(sylpheed_get_deps)
	@$(call targetinfo, $@)
	@$(call get_patches, $(SYLPHEED))
	touch $@

$(SYLPHEED_SOURCE):
	@$(call targetinfo, $@)
	@$(call get, $(SYLPHEED_URL))

# ----------------------------------------------------------------------------
# Extract
# ----------------------------------------------------------------------------

sylpheed_extract: $(STATEDIR)/sylpheed.extract

sylpheed_extract_deps = $(STATEDIR)/sylpheed.get

$(STATEDIR)/sylpheed.extract: $(sylpheed_extract_deps)
	@$(call targetinfo, $@)
	@$(call clean, $(SYLPHEED_DIR))
	@$(call extract, $(SYLPHEED_SOURCE))
	@$(call patchin, $(SYLPHEED))
	touch $@

# ----------------------------------------------------------------------------
# Prepare
# ----------------------------------------------------------------------------

sylpheed_prepare: $(STATEDIR)/sylpheed.prepare

#
# dependencies
#
sylpheed_prepare_deps = \
	$(STATEDIR)/sylpheed.extract \
	$(STATEDIR)/openssl.install \
	$(STATEDIR)/virtual-xchain.install

SYLPHEED_PATH	=  PATH=$(CROSS_PATH)
SYLPHEED_ENV 	=  $(CROSS_ENV)
SYLPHEED_ENV	+= CFLAGS="-O2 -fomit-frame-pointer"
SYLPHEED_ENV	+= PKG_CONFIG_PATH=$(CROSS_LIB_DIR)/lib/pkgconfig:$(CROSS_LIB_DIR)/lib/pkgconfig
#ifdef PTXCONF_XFREE430
#SYLPHEED_ENV	+= LDFLAGS=-Wl,-rpath-link,$(CROSS_LIB_DIR)/lib
#endif

#
# autoconf
#
SYLPHEED_AUTOCONF = \
	--build=$(GNU_HOST) \
	--host=$(PTXCONF_GNU_TARGET) \
	--prefix=/usr \
	--enable-ssl \
	--disable-debug \
	--disable-ipv6 \
	--sysconfdir=/etc
###	--enable-gpgme

ifdef PTXCONF_XFREE430
SYLPHEED_AUTOCONF += --x-includes=$(CROSS_LIB_DIR)/include
SYLPHEED_AUTOCONF += --x-libraries=$(CROSS_LIB_DIR)/lib
endif

$(STATEDIR)/sylpheed.prepare: $(sylpheed_prepare_deps)
	@$(call targetinfo, $@)
	@$(call clean, $(SYLPHEED_DIR)/config.cache)
	###cd $(SYLPHEED_DIR) && aclocal
	###cd $(SYLPHEED_DIR) && automake --add-missing
	###cd $(SYLPHEED_DIR) && autoconf
	cd $(SYLPHEED_DIR) && \
		$(SYLPHEED_PATH) $(SYLPHEED_ENV) \
		./configure $(SYLPHEED_AUTOCONF)
	###perl -p -i -e "s/\-gtk2\-20040229//g" $(SYLPHEED_DIR)/src/version.h
	###cp -f $(PTXCONF_PREFIX)/bin/libtool   $(SYLPHEED_DIR)
	touch $@

# ----------------------------------------------------------------------------
# Compile
# ----------------------------------------------------------------------------

sylpheed_compile: $(STATEDIR)/sylpheed.compile

sylpheed_compile_deps = $(STATEDIR)/sylpheed.prepare

$(STATEDIR)/sylpheed.compile: $(sylpheed_compile_deps)
	@$(call targetinfo, $@)
	$(SYLPHEED_PATH) $(MAKE) -C $(SYLPHEED_DIR)
	touch $@

# ----------------------------------------------------------------------------
# Install
# ----------------------------------------------------------------------------

sylpheed_install: $(STATEDIR)/sylpheed.install

$(STATEDIR)/sylpheed.install: $(STATEDIR)/sylpheed.compile
	@$(call targetinfo, $@)
	$(SYLPHEED_PATH) $(MAKE) -C $(SYLPHEED_DIR) install
	touch $@

# ----------------------------------------------------------------------------
# Target-Install
# ----------------------------------------------------------------------------

sylpheed_targetinstall: $(STATEDIR)/sylpheed.targetinstall

sylpheed_targetinstall_deps = $(STATEDIR)/sylpheed.compile \
	$(STATEDIR)/openssl.targetinstall

$(STATEDIR)/sylpheed.targetinstall: $(sylpheed_targetinstall_deps)
	@$(call targetinfo, $@)
	$(SYLPHEED_PATH) $(MAKE) -C $(SYLPHEED_DIR) DESTDIR=$(SYLPHEED_IPKG_TMP) install
	$(CROSSSTRIP) $(SYLPHEED_IPKG_TMP)/usr/bin/*
	rm -rf $(SYLPHEED_IPKG_TMP)/usr/share/locale
	rm -rf $(SYLPHEED_IPKG_TMP)/usr/share/sylpheed/faq/de
	rm -rf $(SYLPHEED_IPKG_TMP)/usr/share/sylpheed/faq/es
	rm -rf $(SYLPHEED_IPKG_TMP)/usr/share/sylpheed/faq/fr
	rm -rf $(SYLPHEED_IPKG_TMP)/usr/share/sylpheed/faq/it
	rm -rf $(SYLPHEED_IPKG_TMP)/usr/share/sylpheed/manual/ja
	mkdir -p $(SYLPHEED_IPKG_TMP)/usr/share/applications
	mkdir -p $(SYLPHEED_IPKG_TMP)/usr/share/pixmaps
	cp -f $(TOPDIR)/config/pics/sylpheed.desktop $(SYLPHEED_IPKG_TMP)/usr/share/applications
	cp -f $(SYLPHEED_DIR)/sylpheed.png           $(SYLPHEED_IPKG_TMP)/usr/share/pixmaps
	mkdir -p $(SYLPHEED_IPKG_TMP)/CONTROL
	echo "Package: sylpheed-gtk2" 				 >$(SYLPHEED_IPKG_TMP)/CONTROL/control
	echo "Priority: optional" 				>>$(SYLPHEED_IPKG_TMP)/CONTROL/control
	echo "Section: Network" 				>>$(SYLPHEED_IPKG_TMP)/CONTROL/control
	echo "Maintainer: Alexander Chukov <sash@pdaXrom.org>" 	>>$(SYLPHEED_IPKG_TMP)/CONTROL/control
	echo "Architecture: $(SHORT_TARGET)" 			>>$(SYLPHEED_IPKG_TMP)/CONTROL/control
	echo "Version: $(SYLPHEED_VERSION)" 			>>$(SYLPHEED_IPKG_TMP)/CONTROL/control
	echo "Depends: gtk2, openssl" 				>>$(SYLPHEED_IPKG_TMP)/CONTROL/control
	echo "Description: Fast GTK2 mail client"		>>$(SYLPHEED_IPKG_TMP)/CONTROL/control
	cd $(FEEDDIR) && $(XMKIPKG) $(SYLPHEED_IPKG_TMP)
	touch $@

# ----------------------------------------------------------------------------
# Image-Install
# ----------------------------------------------------------------------------

ifdef PTXCONF_SYLPHEED_INSTALL
ROMPACKAGES += $(STATEDIR)/sylpheed.imageinstall
endif

sylpheed_imageinstall_deps = $(STATEDIR)/sylpheed.targetinstall \
	$(STATEDIR)/virtual-image.install

$(STATEDIR)/sylpheed.imageinstall: $(sylpheed_imageinstall_deps)
	@$(call targetinfo, $@)
	cd $(FEEDDIR) && $(XIPKG) install sylpheed-gtk2
	touch $@

# ----------------------------------------------------------------------------
# Clean
# ----------------------------------------------------------------------------

sylpheed_clean:
	rm -rf $(STATEDIR)/sylpheed.*
	rm -rf $(SYLPHEED_DIR)

# vim: syntax=make
