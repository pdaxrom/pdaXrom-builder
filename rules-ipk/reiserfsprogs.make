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
ifdef PTXCONF_REISERFSPROGS
PACKAGES += reiserfsprogs
endif

#
# Paths and names
#
REISERFSPROGS_VENDOR_VERSION	= 1
REISERFSPROGS_VERSION		= 3.6.19
REISERFSPROGS			= reiserfsprogs-$(REISERFSPROGS_VERSION)
REISERFSPROGS_SUFFIX		= tar.gz
REISERFSPROGS_URL		= ftp://ftp.namesys.com/pub/reiserfsprogs/$(REISERFSPROGS).$(REISERFSPROGS_SUFFIX)
REISERFSPROGS_SOURCE		= $(SRCDIR)/$(REISERFSPROGS).$(REISERFSPROGS_SUFFIX)
REISERFSPROGS_DIR		= $(BUILDDIR)/$(REISERFSPROGS)
REISERFSPROGS_IPKG_TMP		= $(REISERFSPROGS_DIR)/ipkg_tmp

# ----------------------------------------------------------------------------
# Get
# ----------------------------------------------------------------------------

reiserfsprogs_get: $(STATEDIR)/reiserfsprogs.get

reiserfsprogs_get_deps = $(REISERFSPROGS_SOURCE)

$(STATEDIR)/reiserfsprogs.get: $(reiserfsprogs_get_deps)
	@$(call targetinfo, $@)
	@$(call get_patches, $(REISERFSPROGS))
	touch $@

$(REISERFSPROGS_SOURCE):
	@$(call targetinfo, $@)
	@$(call get, $(REISERFSPROGS_URL))

# ----------------------------------------------------------------------------
# Extract
# ----------------------------------------------------------------------------

reiserfsprogs_extract: $(STATEDIR)/reiserfsprogs.extract

reiserfsprogs_extract_deps = $(STATEDIR)/reiserfsprogs.get

$(STATEDIR)/reiserfsprogs.extract: $(reiserfsprogs_extract_deps)
	@$(call targetinfo, $@)
	@$(call clean, $(REISERFSPROGS_DIR))
	@$(call extract, $(REISERFSPROGS_SOURCE))
	@$(call patchin, $(REISERFSPROGS))
	touch $@

# ----------------------------------------------------------------------------
# Prepare
# ----------------------------------------------------------------------------

reiserfsprogs_prepare: $(STATEDIR)/reiserfsprogs.prepare

#
# dependencies
#
reiserfsprogs_prepare_deps = \
	$(STATEDIR)/reiserfsprogs.extract \
	$(STATEDIR)/virtual-xchain.install

REISERFSPROGS_PATH	=  PATH=$(CROSS_PATH)
REISERFSPROGS_ENV 	=  $(CROSS_ENV)
#REISERFSPROGS_ENV	+=
REISERFSPROGS_ENV	+= PKG_CONFIG_PATH=$(CROSS_LIB_DIR)/lib/pkgconfig:$(CROSS_LIB_DIR)/lib/pkgconfig
#ifdef PTXCONF_XFREE430
#REISERFSPROGS_ENV	+= LDFLAGS=-Wl,-rpath-link,$(CROSS_LIB_DIR)/lib
#endif

#
# autoconf
#
REISERFSPROGS_AUTOCONF = \
	--build=$(GNU_HOST) \
	--host=$(PTXCONF_GNU_TARGET) \
	--prefix=/usr

ifdef PTXCONF_XFREE430
REISERFSPROGS_AUTOCONF += --x-includes=$(CROSS_LIB_DIR)/include
REISERFSPROGS_AUTOCONF += --x-libraries=$(CROSS_LIB_DIR)/lib
endif

$(STATEDIR)/reiserfsprogs.prepare: $(reiserfsprogs_prepare_deps)
	@$(call targetinfo, $@)
	@$(call clean, $(REISERFSPROGS_DIR)/config.cache)
	cd $(REISERFSPROGS_DIR) && \
		$(REISERFSPROGS_PATH) $(REISERFSPROGS_ENV) \
		./configure $(REISERFSPROGS_AUTOCONF)
	touch $@

# ----------------------------------------------------------------------------
# Compile
# ----------------------------------------------------------------------------

reiserfsprogs_compile: $(STATEDIR)/reiserfsprogs.compile

reiserfsprogs_compile_deps = $(STATEDIR)/reiserfsprogs.prepare

$(STATEDIR)/reiserfsprogs.compile: $(reiserfsprogs_compile_deps)
	@$(call targetinfo, $@)
	$(REISERFSPROGS_PATH) $(MAKE) -C $(REISERFSPROGS_DIR)
	touch $@

# ----------------------------------------------------------------------------
# Install
# ----------------------------------------------------------------------------

reiserfsprogs_install: $(STATEDIR)/reiserfsprogs.install

$(STATEDIR)/reiserfsprogs.install: $(STATEDIR)/reiserfsprogs.compile
	@$(call targetinfo, $@)
	touch $@

# ----------------------------------------------------------------------------
# Target-Install
# ----------------------------------------------------------------------------

reiserfsprogs_targetinstall: $(STATEDIR)/reiserfsprogs.targetinstall

reiserfsprogs_targetinstall_deps = $(STATEDIR)/reiserfsprogs.compile

$(STATEDIR)/reiserfsprogs.targetinstall: $(reiserfsprogs_targetinstall_deps)
	@$(call targetinfo, $@)
	$(REISERFSPROGS_PATH) $(MAKE) -C $(REISERFSPROGS_DIR) DESTDIR=$(REISERFSPROGS_IPKG_TMP) install
	rm -rf $(REISERFSPROGS_IPKG_TMP)/usr/man
	$(CROSSSTRIP) $(REISERFSPROGS_IPKG_TMP)/usr/sbin/*
	mkdir -p $(REISERFSPROGS_IPKG_TMP)/CONTROL
	echo "Package: reiserfsprogs" 									 >$(REISERFSPROGS_IPKG_TMP)/CONTROL/control
	echo "Priority: optional" 									>>$(REISERFSPROGS_IPKG_TMP)/CONTROL/control
	echo "Section: Kernel" 										>>$(REISERFSPROGS_IPKG_TMP)/CONTROL/control
	echo "Maintainer: Alexander Chukov <sash@pdaXrom.org>" 						>>$(REISERFSPROGS_IPKG_TMP)/CONTROL/control
	echo "Architecture: $(SHORT_TARGET)" 								>>$(REISERFSPROGS_IPKG_TMP)/CONTROL/control
	echo "Version: $(REISERFSPROGS_VERSION)-$(REISERFSPROGS_VENDOR_VERSION)" 			>>$(REISERFSPROGS_IPKG_TMP)/CONTROL/control
	echo "Depends: " 										>>$(REISERFSPROGS_IPKG_TMP)/CONTROL/control
	echo "Description: The reiserfsprogs package contains programs for creating (mkreiserfs), checking and correcting any inconsistencies (reiserfsck) and resizing (resize_reiserfs) of a reiserfs filesystem." >>$(REISERFSPROGS_IPKG_TMP)/CONTROL/control
	cd $(FEEDDIR) && $(XMKIPKG) $(REISERFSPROGS_IPKG_TMP)
	touch $@

# ----------------------------------------------------------------------------
# Image-Install
# ----------------------------------------------------------------------------

ifdef PTXCONF_REISERFSPROGS_INSTALL
ROMPACKAGES += $(STATEDIR)/reiserfsprogs.imageinstall
endif

reiserfsprogs_imageinstall_deps = $(STATEDIR)/reiserfsprogs.targetinstall \
	$(STATEDIR)/virtual-image.install

$(STATEDIR)/reiserfsprogs.imageinstall: $(reiserfsprogs_imageinstall_deps)
	@$(call targetinfo, $@)
	cd $(FEEDDIR) && $(XIPKG) install reiserfsprogs
	touch $@

# ----------------------------------------------------------------------------
# Clean
# ----------------------------------------------------------------------------

reiserfsprogs_clean:
	rm -rf $(STATEDIR)/reiserfsprogs.*
	rm -rf $(REISERFSPROGS_DIR)

# vim: syntax=make
