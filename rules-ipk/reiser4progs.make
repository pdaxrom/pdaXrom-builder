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
ifdef PTXCONF_REISER4PROGS
PACKAGES += reiser4progs
endif

#
# Paths and names
#
REISER4PROGS_VENDOR_VERSION	= 1
REISER4PROGS_VERSION		= 1.0.3
REISER4PROGS			= reiser4progs-$(REISER4PROGS_VERSION)
REISER4PROGS_SUFFIX		= tar.gz
REISER4PROGS_URL		= ftp://ftp.namesys.com/pub/reiser4progs/$(REISER4PROGS).$(REISER4PROGS_SUFFIX)
REISER4PROGS_SOURCE		= $(SRCDIR)/$(REISER4PROGS).$(REISER4PROGS_SUFFIX)
REISER4PROGS_DIR		= $(BUILDDIR)/$(REISER4PROGS)
REISER4PROGS_IPKG_TMP		= $(REISER4PROGS_DIR)/ipkg_tmp

# ----------------------------------------------------------------------------
# Get
# ----------------------------------------------------------------------------

reiser4progs_get: $(STATEDIR)/reiser4progs.get

reiser4progs_get_deps = $(REISER4PROGS_SOURCE)

$(STATEDIR)/reiser4progs.get: $(reiser4progs_get_deps)
	@$(call targetinfo, $@)
	@$(call get_patches, $(REISER4PROGS))
	touch $@

$(REISER4PROGS_SOURCE):
	@$(call targetinfo, $@)
	@$(call get, $(REISER4PROGS_URL))

# ----------------------------------------------------------------------------
# Extract
# ----------------------------------------------------------------------------

reiser4progs_extract: $(STATEDIR)/reiser4progs.extract

reiser4progs_extract_deps = $(STATEDIR)/reiser4progs.get

$(STATEDIR)/reiser4progs.extract: $(reiser4progs_extract_deps)
	@$(call targetinfo, $@)
	@$(call clean, $(REISER4PROGS_DIR))
	@$(call extract, $(REISER4PROGS_SOURCE))
	@$(call patchin, $(REISER4PROGS))
	touch $@

# ----------------------------------------------------------------------------
# Prepare
# ----------------------------------------------------------------------------

reiser4progs_prepare: $(STATEDIR)/reiser4progs.prepare

#
# dependencies
#
reiser4progs_prepare_deps = \
	$(STATEDIR)/reiser4progs.extract \
	$(STATEDIR)/libaal.install \
	$(STATEDIR)/virtual-xchain.install

REISER4PROGS_PATH	=  PATH=$(CROSS_PATH)
REISER4PROGS_ENV 	=  $(CROSS_ENV)
#REISER4PROGS_ENV	+=
REISER4PROGS_ENV	+= PKG_CONFIG_PATH=$(CROSS_LIB_DIR)/lib/pkgconfig:$(CROSS_LIB_DIR)/lib/pkgconfig
#ifdef PTXCONF_XFREE430
#REISER4PROGS_ENV	+= LDFLAGS=-Wl,-rpath-link,$(CROSS_LIB_DIR)/lib
#endif

#
# autoconf
#
REISER4PROGS_AUTOCONF = \
	--build=$(GNU_HOST) \
	--host=$(PTXCONF_GNU_TARGET) \
	--prefix=/usr

ifdef PTXCONF_XFREE430
REISER4PROGS_AUTOCONF += --x-includes=$(CROSS_LIB_DIR)/include
REISER4PROGS_AUTOCONF += --x-libraries=$(CROSS_LIB_DIR)/lib
endif

$(STATEDIR)/reiser4progs.prepare: $(reiser4progs_prepare_deps)
	@$(call targetinfo, $@)
	@$(call clean, $(REISER4PROGS_DIR)/config.cache)
	cd $(REISER4PROGS_DIR) && \
		$(REISER4PROGS_PATH) $(REISER4PROGS_ENV) \
		./configure $(REISER4PROGS_AUTOCONF)
	touch $@

# ----------------------------------------------------------------------------
# Compile
# ----------------------------------------------------------------------------

reiser4progs_compile: $(STATEDIR)/reiser4progs.compile

reiser4progs_compile_deps = $(STATEDIR)/reiser4progs.prepare

$(STATEDIR)/reiser4progs.compile: $(reiser4progs_compile_deps)
	@$(call targetinfo, $@)
	$(REISER4PROGS_PATH) $(MAKE) -C $(REISER4PROGS_DIR)
	touch $@

# ----------------------------------------------------------------------------
# Install
# ----------------------------------------------------------------------------

reiser4progs_install: $(STATEDIR)/reiser4progs.install

$(STATEDIR)/reiser4progs.install: $(STATEDIR)/reiser4progs.compile
	@$(call targetinfo, $@)
	touch $@

# ----------------------------------------------------------------------------
# Target-Install
# ----------------------------------------------------------------------------

reiser4progs_targetinstall: $(STATEDIR)/reiser4progs.targetinstall

reiser4progs_targetinstall_deps = $(STATEDIR)/reiser4progs.compile \
	$(STATEDIR)/libaal.targetinstall

$(STATEDIR)/reiser4progs.targetinstall: $(reiser4progs_targetinstall_deps)
	@$(call targetinfo, $@)
	$(REISER4PROGS_PATH) $(MAKE) -C $(REISER4PROGS_DIR) DESTDIR=$(REISER4PROGS_IPKG_TMP) install
	rm -rf $(REISER4PROGS_IPKG_TMP)/usr/include
	rm -rf $(REISER4PROGS_IPKG_TMP)/usr/lib/*.*a
	rm -rf $(REISER4PROGS_IPKG_TMP)/usr/man
	rm -rf $(REISER4PROGS_IPKG_TMP)/usr/share
	$(CROSSSTRIP) $(REISER4PROGS_IPKG_TMP)/usr/lib/*.so*
	$(CROSSSTRIP) $(REISER4PROGS_IPKG_TMP)/usr/sbin/*
	mkdir -p $(REISER4PROGS_IPKG_TMP)/CONTROL
	echo "Package: reiser4progs" 							 >$(REISER4PROGS_IPKG_TMP)/CONTROL/control
	echo "Priority: optional" 							>>$(REISER4PROGS_IPKG_TMP)/CONTROL/control
	echo "Section: Kernel" 								>>$(REISER4PROGS_IPKG_TMP)/CONTROL/control
	echo "Maintainer: Alexander Chukov <sash@pdaXrom.org>" 				>>$(REISER4PROGS_IPKG_TMP)/CONTROL/control
	echo "Architecture: $(SHORT_TARGET)" 						>>$(REISER4PROGS_IPKG_TMP)/CONTROL/control
	echo "Version: $(REISER4PROGS_VERSION)-$(REISER4PROGS_VENDOR_VERSION)" 		>>$(REISER4PROGS_IPKG_TMP)/CONTROL/control
	echo "Depends: libaal" 								>>$(REISER4PROGS_IPKG_TMP)/CONTROL/control
	echo "Description: It contains the library for reiser4 filesystem access and manipulation and reiser4 utilities.">>$(REISER4PROGS_IPKG_TMP)/CONTROL/control
	cd $(FEEDDIR) && $(XMKIPKG) $(REISER4PROGS_IPKG_TMP)
	touch $@

# ----------------------------------------------------------------------------
# Image-Install
# ----------------------------------------------------------------------------

ifdef PTXCONF_REISER4PROGS_INSTALL
ROMPACKAGES += $(STATEDIR)/reiser4progs.imageinstall
endif

reiser4progs_imageinstall_deps = $(STATEDIR)/reiser4progs.targetinstall \
	$(STATEDIR)/virtual-image.install

$(STATEDIR)/reiser4progs.imageinstall: $(reiser4progs_imageinstall_deps)
	@$(call targetinfo, $@)
	cd $(FEEDDIR) && $(XIPKG) install reiser4progs
	touch $@

# ----------------------------------------------------------------------------
# Clean
# ----------------------------------------------------------------------------

reiser4progs_clean:
	rm -rf $(STATEDIR)/reiser4progs.*
	rm -rf $(REISER4PROGS_DIR)

# vim: syntax=make
