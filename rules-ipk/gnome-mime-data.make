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
ifdef PTXCONF_GNOME-MIME-DATA
PACKAGES += gnome-mime-data
endif

#
# Paths and names
#
GNOME-MIME-DATA_VERSION		= 2.4.1
GNOME-MIME-DATA			= gnome-mime-data-$(GNOME-MIME-DATA_VERSION)
GNOME-MIME-DATA_SUFFIX		= tar.bz2
GNOME-MIME-DATA_URL		= ftp://ftp.gnome.org/pub/GNOME/sources/gnome-mime-data/2.4/$(GNOME-MIME-DATA).$(GNOME-MIME-DATA_SUFFIX)
GNOME-MIME-DATA_SOURCE		= $(SRCDIR)/$(GNOME-MIME-DATA).$(GNOME-MIME-DATA_SUFFIX)
GNOME-MIME-DATA_DIR		= $(BUILDDIR)/$(GNOME-MIME-DATA)
GNOME-MIME-DATA_IPKG_TMP	= $(GNOME-MIME-DATA_DIR)/ipkg_tmp

# ----------------------------------------------------------------------------
# Get
# ----------------------------------------------------------------------------

gnome-mime-data_get: $(STATEDIR)/gnome-mime-data.get

gnome-mime-data_get_deps = $(GNOME-MIME-DATA_SOURCE)

$(STATEDIR)/gnome-mime-data.get: $(gnome-mime-data_get_deps)
	@$(call targetinfo, $@)
	@$(call get_patches, $(GNOME-MIME-DATA))
	touch $@

$(GNOME-MIME-DATA_SOURCE):
	@$(call targetinfo, $@)
	@$(call get, $(GNOME-MIME-DATA_URL))

# ----------------------------------------------------------------------------
# Extract
# ----------------------------------------------------------------------------

gnome-mime-data_extract: $(STATEDIR)/gnome-mime-data.extract

gnome-mime-data_extract_deps = $(STATEDIR)/gnome-mime-data.get

$(STATEDIR)/gnome-mime-data.extract: $(gnome-mime-data_extract_deps)
	@$(call targetinfo, $@)
	@$(call clean, $(GNOME-MIME-DATA_DIR))
	@$(call extract, $(GNOME-MIME-DATA_SOURCE))
	@$(call patchin, $(GNOME-MIME-DATA))
	touch $@

# ----------------------------------------------------------------------------
# Prepare
# ----------------------------------------------------------------------------

gnome-mime-data_prepare: $(STATEDIR)/gnome-mime-data.prepare

#
# dependencies
#
gnome-mime-data_prepare_deps = \
	$(STATEDIR)/gnome-mime-data.extract \
	$(STATEDIR)/virtual-xchain.install

GNOME-MIME-DATA_PATH	=  PATH=$(CROSS_PATH)
GNOME-MIME-DATA_ENV 	=  $(CROSS_ENV)
GNOME-MIME-DATA_ENV	+= CFLAGS="-O2 -fomit-frame-pointer"
GNOME-MIME-DATA_ENV	+= PKG_CONFIG_PATH=$(CROSS_LIB_DIR)/lib/pkgconfig:$(CROSS_LIB_DIR)/lib/pkgconfig
#ifdef PTXCONF_XFREE430
#GNOME-MIME-DATA_ENV	+= LDFLAGS=-Wl,-rpath-link,$(CROSS_LIB_DIR)/lib
#endif

#
# autoconf
#
GNOME-MIME-DATA_AUTOCONF = \
	--build=$(GNU_HOST) \
	--host=$(PTXCONF_GNU_TARGET) \
	--prefix=/usr \
	--enable-shared \
	--disable-static \
	--sysconfdir=/etc \
	--libexecdir=/usr/bin \
	--disable-debug

ifdef PTXCONF_XFREE430
GNOME-MIME-DATA_AUTOCONF += --x-includes=$(CROSS_LIB_DIR)/include
GNOME-MIME-DATA_AUTOCONF += --x-libraries=$(CROSS_LIB_DIR)/lib
endif

$(STATEDIR)/gnome-mime-data.prepare: $(gnome-mime-data_prepare_deps)
	@$(call targetinfo, $@)
	@$(call clean, $(GNOME-MIME-DATA_DIR)/config.cache)
	cd $(GNOME-MIME-DATA_DIR) && \
		$(GNOME-MIME-DATA_PATH) $(GNOME-MIME-DATA_ENV) \
		./configure $(GNOME-MIME-DATA_AUTOCONF)
	touch $@

# ----------------------------------------------------------------------------
# Compile
# ----------------------------------------------------------------------------

gnome-mime-data_compile: $(STATEDIR)/gnome-mime-data.compile

gnome-mime-data_compile_deps = $(STATEDIR)/gnome-mime-data.prepare

$(STATEDIR)/gnome-mime-data.compile: $(gnome-mime-data_compile_deps)
	@$(call targetinfo, $@)
	$(GNOME-MIME-DATA_PATH) $(MAKE) -C $(GNOME-MIME-DATA_DIR)
	touch $@

# ----------------------------------------------------------------------------
# Install
# ----------------------------------------------------------------------------

gnome-mime-data_install: $(STATEDIR)/gnome-mime-data.install

$(STATEDIR)/gnome-mime-data.install: $(STATEDIR)/gnome-mime-data.compile
	@$(call targetinfo, $@)
	$(GNOME-MIME-DATA_PATH) $(MAKE) -C $(GNOME-MIME-DATA_DIR) DESTDIR=$(GNOME-MIME-DATA_IPKG_TMP) install
	cp -a $(GNOME-MIME-DATA_IPKG_TMP)/usr/lib/*  $(CROSS_LIB_DIR)/lib
	perl -p -i -e "s/\/usr/`echo $(PTXCONF_PREFIX)/$(PTXCONF_GNU_TARGET) | sed -e '/\//s//\\\\\//g'`/g" $(PTXCONF_PREFIX)/$(PTXCONF_GNU_TARGET)/lib/pkgconfig/gnome-mime-data-2.0.pc
	rm -rf $(GNOME-MIME-DATA_IPKG_TMP)
	touch $@

# ----------------------------------------------------------------------------
# Target-Install
# ----------------------------------------------------------------------------

gnome-mime-data_targetinstall: $(STATEDIR)/gnome-mime-data.targetinstall

gnome-mime-data_targetinstall_deps = $(STATEDIR)/gnome-mime-data.compile

$(STATEDIR)/gnome-mime-data.targetinstall: $(gnome-mime-data_targetinstall_deps)
	@$(call targetinfo, $@)
	$(GNOME-MIME-DATA_PATH) $(MAKE) -C $(GNOME-MIME-DATA_DIR) DESTDIR=$(GNOME-MIME-DATA_IPKG_TMP) install
	rm -rf $(GNOME-MIME-DATA_IPKG_TMP)/usr/lib
	rm -rf $(GNOME-MIME-DATA_IPKG_TMP)/usr/share/locale
	mkdir -p $(GNOME-MIME-DATA_IPKG_TMP)/CONTROL
	echo "Package: gnome-mime-data" 		>$(GNOME-MIME-DATA_IPKG_TMP)/CONTROL/control
	echo "Priority: optional" 			>>$(GNOME-MIME-DATA_IPKG_TMP)/CONTROL/control
	echo "Section: Gnome" 				>>$(GNOME-MIME-DATA_IPKG_TMP)/CONTROL/control
	echo "Maintainer: Alexander Chukov <sash@pdaXrom.org>">>$(GNOME-MIME-DATA_IPKG_TMP)/CONTROL/control
	echo "Architecture: $(SHORT_TARGET)" 		>>$(GNOME-MIME-DATA_IPKG_TMP)/CONTROL/control
	echo "Version: $(GNOME-MIME-DATA_VERSION)" 	>>$(GNOME-MIME-DATA_IPKG_TMP)/CONTROL/control
	echo "Depends: " 				>>$(GNOME-MIME-DATA_IPKG_TMP)/CONTROL/control
	echo "Description: This module contains the base MIME and Application database for GNOME.">>$(GNOME-MIME-DATA_IPKG_TMP)/CONTROL/control
	cd $(FEEDDIR) && $(XMKIPKG) $(GNOME-MIME-DATA_IPKG_TMP)
	touch $@

# ----------------------------------------------------------------------------
# Clean
# ----------------------------------------------------------------------------

gnome-mime-data_clean:
	rm -rf $(STATEDIR)/gnome-mime-data.*
	rm -rf $(GNOME-MIME-DATA_DIR)

# vim: syntax=make
