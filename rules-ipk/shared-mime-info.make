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
ifdef PTXCONF_SHARED-MIME-INFO
PACKAGES += shared-mime-info
endif

#
# Paths and names
#
SHARED-MIME-INFO_VERSION	= 0.14
SHARED-MIME-INFO		= shared-mime-info-$(SHARED-MIME-INFO_VERSION)
SHARED-MIME-INFO_SUFFIX		= tar.gz
SHARED-MIME-INFO_URL		= http://freedesktop.org/Software/shared-mime-info/$(SHARED-MIME-INFO).$(SHARED-MIME-INFO_SUFFIX)
SHARED-MIME-INFO_SOURCE		= $(SRCDIR)/$(SHARED-MIME-INFO).$(SHARED-MIME-INFO_SUFFIX)
SHARED-MIME-INFO_DIR		= $(BUILDDIR)/$(SHARED-MIME-INFO)
SHARED-MIME-INFO_IPKG_TMP	= $(SHARED-MIME-INFO_DIR)/ipkg_tmp

# ----------------------------------------------------------------------------
# Get
# ----------------------------------------------------------------------------

shared-mime-info_get: $(STATEDIR)/shared-mime-info.get

shared-mime-info_get_deps = $(SHARED-MIME-INFO_SOURCE)

$(STATEDIR)/shared-mime-info.get: $(shared-mime-info_get_deps)
	@$(call targetinfo, $@)
	@$(call get_patches, $(SHARED-MIME-INFO))
	touch $@

$(SHARED-MIME-INFO_SOURCE):
	@$(call targetinfo, $@)
	@$(call get, $(SHARED-MIME-INFO_URL))

# ----------------------------------------------------------------------------
# Extract
# ----------------------------------------------------------------------------

shared-mime-info_extract: $(STATEDIR)/shared-mime-info.extract

shared-mime-info_extract_deps = $(STATEDIR)/shared-mime-info.get

$(STATEDIR)/shared-mime-info.extract: $(shared-mime-info_extract_deps)
	@$(call targetinfo, $@)
	@$(call clean, $(SHARED-MIME-INFO_DIR))
	@$(call extract, $(SHARED-MIME-INFO_SOURCE))
	@$(call patchin, $(SHARED-MIME-INFO))
	touch $@

# ----------------------------------------------------------------------------
# Prepare
# ----------------------------------------------------------------------------

shared-mime-info_prepare: $(STATEDIR)/shared-mime-info.prepare

#
# dependencies
#
shared-mime-info_prepare_deps = \
	$(STATEDIR)/shared-mime-info.extract \
	$(STATEDIR)/xchain-shared-mime-info.install \
	$(STATEDIR)/libxml2.install \
	$(STATEDIR)/glib22.install \
	$(STATEDIR)/virtual-xchain.install

SHARED-MIME-INFO_PATH	=  PATH=$(CROSS_PATH)
SHARED-MIME-INFO_ENV 	=  $(CROSS_ENV)
SHARED-MIME-INFO_ENV	+= CFLAGS="-O2 -fomit-frame-pointer"
SHARED-MIME-INFO_ENV	+= PKG_CONFIG_PATH=$(CROSS_LIB_DIR)/lib/pkgconfig:$(CROSS_LIB_DIR)/lib/pkgconfig
#ifdef PTXCONF_XFREE430
#SHARED-MIME-INFO_ENV	+= LDFLAGS=-Wl,-rpath-link,$(CROSS_LIB_DIR)/lib
#endif

#
# autoconf
#
SHARED-MIME-INFO_AUTOCONF = \
	--build=$(GNU_HOST) \
	--host=$(PTXCONF_GNU_TARGET) \
	--prefix=/usr \
	--disable-update-mimedb

ifdef PTXCONF_XFREE430
SHARED-MIME-INFO_AUTOCONF += --x-includes=$(CROSS_LIB_DIR)/include
SHARED-MIME-INFO_AUTOCONF += --x-libraries=$(CROSS_LIB_DIR)/lib
endif

$(STATEDIR)/shared-mime-info.prepare: $(shared-mime-info_prepare_deps)
	@$(call targetinfo, $@)
	@$(call clean, $(SHARED-MIME-INFO_DIR)/config.cache)
	cd $(SHARED-MIME-INFO_DIR) && \
		$(SHARED-MIME-INFO_PATH) $(SHARED-MIME-INFO_ENV) \
		./configure $(SHARED-MIME-INFO_AUTOCONF)
	touch $@

# ----------------------------------------------------------------------------
# Compile
# ----------------------------------------------------------------------------

shared-mime-info_compile: $(STATEDIR)/shared-mime-info.compile

shared-mime-info_compile_deps = $(STATEDIR)/shared-mime-info.prepare

$(STATEDIR)/shared-mime-info.compile: $(shared-mime-info_compile_deps)
	@$(call targetinfo, $@)
	$(SHARED-MIME-INFO_PATH) $(SHARED-MIME-INFO_ENV) $(MAKE) -C $(SHARED-MIME-INFO_DIR)
	touch $@

# ----------------------------------------------------------------------------
# Install
# ----------------------------------------------------------------------------

shared-mime-info_install: $(STATEDIR)/shared-mime-info.install

$(STATEDIR)/shared-mime-info.install: $(STATEDIR)/shared-mime-info.compile
	@$(call targetinfo, $@)
	$(SHARED-MIME-INFO_PATH) $(MAKE) -C $(SHARED-MIME-INFO_DIR) DESTDIR=$(SHARED-MIME-INFO_IPKG_TMP) install
	cp -a  $(SHARED-MIME-INFO_IPKG_TMP)/usr/lib/*              $(CROSS_LIB_DIR)/lib
	###perl -p -i -e "s/\/usr/`echo $(PTXCONF_PREFIX)/$(PTXCONF_GNU_TARGET) | sed -e '/\//s//\\\\\//g'`/g" $(PTXCONF_PREFIX)/$(PTXCONF_GNU_TARGET)/lib/pkgconfig/shared-mime-info.pc
	rm -rf $(SHARED-MIME-INFO_IPKG_TMP)
	touch $@

# ----------------------------------------------------------------------------
# Target-Install
# ----------------------------------------------------------------------------

shared-mime-info_targetinstall: $(STATEDIR)/shared-mime-info.targetinstall

shared-mime-info_targetinstall_deps = $(STATEDIR)/shared-mime-info.compile \
	$(STATEDIR)/libxml2.targetinstall \
	$(STATEDIR)/glib22.targetinstall

$(STATEDIR)/shared-mime-info.targetinstall: $(shared-mime-info_targetinstall_deps)
	@$(call targetinfo, $@)
	$(SHARED-MIME-INFO_PATH) $(MAKE) -C $(SHARED-MIME-INFO_DIR) DESTDIR=$(SHARED-MIME-INFO_IPKG_TMP) install
	$(CROSSSTRIP) $(SHARED-MIME-INFO_IPKG_TMP)/usr/bin/*
	rm -rf $(SHARED-MIME-INFO_IPKG_TMP)/usr/lib
	rm -rf $(SHARED-MIME-INFO_IPKG_TMP)/usr/man
	rm -rf $(SHARED-MIME-INFO_IPKG_TMP)/usr/share/locale
	mkdir -p $(SHARED-MIME-INFO_IPKG_TMP)/CONTROL
	echo "Package: shared-mime-info" 		>$(SHARED-MIME-INFO_IPKG_TMP)/CONTROL/control
	echo "Priority: optional" 			>>$(SHARED-MIME-INFO_IPKG_TMP)/CONTROL/control
	echo "Section: pdaXrom" 			>>$(SHARED-MIME-INFO_IPKG_TMP)/CONTROL/control
	echo "Maintainer: Alexander Chukov <sash@pdaXrom.org>">>$(SHARED-MIME-INFO_IPKG_TMP)/CONTROL/control
	echo "Architecture: $(SHORT_TARGET)" 		>>$(SHARED-MIME-INFO_IPKG_TMP)/CONTROL/control
	echo "Version: $(SHARED-MIME-INFO_VERSION)" 	>>$(SHARED-MIME-INFO_IPKG_TMP)/CONTROL/control
	echo "Depends: glib2, libxml2" 			>>$(SHARED-MIME-INFO_IPKG_TMP)/CONTROL/control
	echo "Description: Freedesktop common MIME database.">>$(SHARED-MIME-INFO_IPKG_TMP)/CONTROL/control
	###echo "#!/bin/sh"					 >$(SHARED-MIME-INFO_IPKG_TMP)/CONTROL/postinst
	###echo "/usr/bin/update-mime-database /usr/share/mime"	>>$(SHARED-MIME-INFO_IPKG_TMP)/CONTROL/postinst
	###chmod 755 $(SHARED-MIME-INFO_IPKG_TMP)/CONTROL/postinst
	$(SHARED-MIME-INFO_PATH) update-mime-database $(SHARED-MIME-INFO_IPKG_TMP)/usr/share/mime
	cd $(FEEDDIR) && $(XMKIPKG) $(SHARED-MIME-INFO_IPKG_TMP)
	touch $@

# ----------------------------------------------------------------------------
# Image-Install
# ----------------------------------------------------------------------------

shared-mime-info_imageinstall_deps = $(STATEDIR)/shared-mime-info.targetinstall \
	$(STATEDIR)/virtual-image.install

$(STATEDIR)/shared-mime-info.imageinstall: $(shared-mime-info_imageinstall_deps)
	@$(call targetinfo, $@)
	cd $(FEEDDIR) && $(XIPKG) install shared-mime-info
	touch $@

# ----------------------------------------------------------------------------
# Clean
# ----------------------------------------------------------------------------

shared-mime-info_clean:
	rm -rf $(STATEDIR)/shared-mime-info.*
	rm -rf $(SHARED-MIME-INFO_DIR)

# vim: syntax=make
