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
ifdef PTXCONF_GNOME-KEYRING
PACKAGES += gnome-keyring
endif

#
# Paths and names
#
GNOME-KEYRING_VERSION	= 0.2.1
GNOME-KEYRING		= gnome-keyring-$(GNOME-KEYRING_VERSION)
GNOME-KEYRING_SUFFIX	= tar.bz2
GNOME-KEYRING_URL	= ftp://ftp.gnome.org/pub/GNOME/sources/gnome-keyring/0.2/$(GNOME-KEYRING).$(GNOME-KEYRING_SUFFIX)
GNOME-KEYRING_SOURCE	= $(SRCDIR)/$(GNOME-KEYRING).$(GNOME-KEYRING_SUFFIX)
GNOME-KEYRING_DIR	= $(BUILDDIR)/$(GNOME-KEYRING)
GNOME-KEYRING_IPKG_TMP	= $(GNOME-KEYRING_DIR)/ipkg_tmp

# ----------------------------------------------------------------------------
# Get
# ----------------------------------------------------------------------------

gnome-keyring_get: $(STATEDIR)/gnome-keyring.get

gnome-keyring_get_deps = $(GNOME-KEYRING_SOURCE)

$(STATEDIR)/gnome-keyring.get: $(gnome-keyring_get_deps)
	@$(call targetinfo, $@)
	@$(call get_patches, $(GNOME-KEYRING))
	touch $@

$(GNOME-KEYRING_SOURCE):
	@$(call targetinfo, $@)
	@$(call get, $(GNOME-KEYRING_URL))

# ----------------------------------------------------------------------------
# Extract
# ----------------------------------------------------------------------------

gnome-keyring_extract: $(STATEDIR)/gnome-keyring.extract

gnome-keyring_extract_deps = $(STATEDIR)/gnome-keyring.get

$(STATEDIR)/gnome-keyring.extract: $(gnome-keyring_extract_deps)
	@$(call targetinfo, $@)
	@$(call clean, $(GNOME-KEYRING_DIR))
	@$(call extract, $(GNOME-KEYRING_SOURCE))
	@$(call patchin, $(GNOME-KEYRING))
	touch $@

# ----------------------------------------------------------------------------
# Prepare
# ----------------------------------------------------------------------------

gnome-keyring_prepare: $(STATEDIR)/gnome-keyring.prepare

#
# dependencies
#
gnome-keyring_prepare_deps = \
	$(STATEDIR)/gnome-keyring.extract \
	$(STATEDIR)/virtual-xchain.install

GNOME-KEYRING_PATH	=  PATH=$(CROSS_PATH)
GNOME-KEYRING_ENV 	=  $(CROSS_ENV)
GNOME-KEYRING_ENV	+= CFLAGS="-O2 -fomit-frame-pointer"
GNOME-KEYRING_ENV	+= PKG_CONFIG_PATH=$(CROSS_LIB_DIR)/lib/pkgconfig:$(CROSS_LIB_DIR)/lib/pkgconfig
#ifdef PTXCONF_XFREE430
#GNOME-KEYRING_ENV	+= LDFLAGS=-Wl,-rpath-link,$(CROSS_LIB_DIR)/lib
#endif

#
# autoconf
#
GNOME-KEYRING_AUTOCONF = \
	--build=$(GNU_HOST) \
	--host=$(PTXCONF_GNU_TARGET) \
	--prefix=/usr \
	--enable-shared \
	--disable-static \
	--sysconfdir=/etc \
	--libexecdir=/usr/bin \
	--disable-debug

ifdef PTXCONF_XFREE430
GNOME-KEYRING_AUTOCONF += --x-includes=$(CROSS_LIB_DIR)/include
GNOME-KEYRING_AUTOCONF += --x-libraries=$(CROSS_LIB_DIR)/lib
endif

$(STATEDIR)/gnome-keyring.prepare: $(gnome-keyring_prepare_deps)
	@$(call targetinfo, $@)
	@$(call clean, $(GNOME-KEYRING_DIR)/config.cache)
	cd $(GNOME-KEYRING_DIR) && \
		$(GNOME-KEYRING_PATH) $(GNOME-KEYRING_ENV) \
		./configure $(GNOME-KEYRING_AUTOCONF)
	touch $@

# ----------------------------------------------------------------------------
# Compile
# ----------------------------------------------------------------------------

gnome-keyring_compile: $(STATEDIR)/gnome-keyring.compile

gnome-keyring_compile_deps = $(STATEDIR)/gnome-keyring.prepare

$(STATEDIR)/gnome-keyring.compile: $(gnome-keyring_compile_deps)
	@$(call targetinfo, $@)
	$(GNOME-KEYRING_PATH) $(MAKE) -C $(GNOME-KEYRING_DIR)
	touch $@

# ----------------------------------------------------------------------------
# Install
# ----------------------------------------------------------------------------

gnome-keyring_install: $(STATEDIR)/gnome-keyring.install

$(STATEDIR)/gnome-keyring.install: $(STATEDIR)/gnome-keyring.compile
	@$(call targetinfo, $@)
	$(GNOME-KEYRING_PATH) $(MAKE) -C $(GNOME-KEYRING_DIR) DESTDIR=$(GNOME-KEYRING_IPKG_TMP) install
	cp -a  $(GNOME-KEYRING_IPKG_TMP)/usr/include/*          $(CROSS_LIB_DIR)/include
	cp -a  $(GNOME-KEYRING_IPKG_TMP)/usr/lib/*              $(CROSS_LIB_DIR)/lib
	perl -p -i -e "s/\/usr\/lib/`echo $(PTXCONF_PREFIX)/$(PTXCONF_GNU_TARGET)/lib | sed -e '/\//s//\\\\\//g'`/g" $(PTXCONF_PREFIX)/$(PTXCONF_GNU_TARGET)/lib/libgnome-keyring.la
	perl -p -i -e "s/\/usr/`echo $(PTXCONF_PREFIX)/$(PTXCONF_GNU_TARGET) | sed -e '/\//s//\\\\\//g'`/g" $(PTXCONF_PREFIX)/$(PTXCONF_GNU_TARGET)/lib/pkgconfig/gnome-keyring-1.pc
	rm -rf $(GNOME-KEYRING_IPKG_TMP)
	touch $@

# ----------------------------------------------------------------------------
# Target-Install
# ----------------------------------------------------------------------------

gnome-keyring_targetinstall: $(STATEDIR)/gnome-keyring.targetinstall

gnome-keyring_targetinstall_deps = $(STATEDIR)/gnome-keyring.compile

$(STATEDIR)/gnome-keyring.targetinstall: $(gnome-keyring_targetinstall_deps)
	@$(call targetinfo, $@)
	$(GNOME-KEYRING_PATH) $(MAKE) -C $(GNOME-KEYRING_DIR) DESTDIR=$(GNOME-KEYRING_IPKG_TMP) install
	rm -rf $(GNOME-KEYRING_IPKG_TMP)/usr/include
	rm -rf $(GNOME-KEYRING_IPKG_TMP)/usr/lib/pkgconfig
	rm -rf $(GNOME-KEYRING_IPKG_TMP)/usr/lib/*.*a
	rm -rf $(GNOME-KEYRING_IPKG_TMP)/usr/share
	$(CROSSSTRIP) $(GNOME-KEYRING_IPKG_TMP)/usr/bin/*
	$(CROSSSTRIP) $(GNOME-KEYRING_IPKG_TMP)/usr/lib/*
	mkdir -p $(GNOME-KEYRING_IPKG_TMP)/CONTROL
	echo "Package: gnome-keyring" 			>$(GNOME-KEYRING_IPKG_TMP)/CONTROL/control
	echo "Priority: optional" 			>>$(GNOME-KEYRING_IPKG_TMP)/CONTROL/control
	echo "Section: Gnome"	 			>>$(GNOME-KEYRING_IPKG_TMP)/CONTROL/control
	echo "Maintainer: Alexander Chukov <sash@pdaXrom.org>">>$(GNOME-KEYRING_IPKG_TMP)/CONTROL/control
	echo "Architecture: $(SHORT_TARGET)" 		>>$(GNOME-KEYRING_IPKG_TMP)/CONTROL/control
	echo "Version: $(GNOME-KEYRING_VERSION)" 	>>$(GNOME-KEYRING_IPKG_TMP)/CONTROL/control
	echo "Depends: " 				>>$(GNOME-KEYRING_IPKG_TMP)/CONTROL/control
	echo "Description: gnome-keyring is a program that keep password and other secrets for users.">>$(GNOME-KEYRING_IPKG_TMP)/CONTROL/control
	cd $(FEEDDIR) && $(XMKIPKG) $(GNOME-KEYRING_IPKG_TMP)
	touch $@

# ----------------------------------------------------------------------------
# Clean
# ----------------------------------------------------------------------------

gnome-keyring_clean:
	rm -rf $(STATEDIR)/gnome-keyring.*
	rm -rf $(GNOME-KEYRING_DIR)

# vim: syntax=make
