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
ifdef PTXCONF_CDRTOOLS
PACKAGES += cdrtools
endif

#
# Paths and names
#
CDRTOOLS_VERSION	= 2.01
CDRTOOLS		= cdrtools-$(CDRTOOLS_VERSION)
CDRTOOLS_SUFFIX		= tar.bz2
CDRTOOLS_URL		= ftp://ftp.berlios.de/pub/cdrecord/$(CDRTOOLS).$(CDRTOOLS_SUFFIX)
CDRTOOLS_SOURCE		= $(SRCDIR)/$(CDRTOOLS).$(CDRTOOLS_SUFFIX)
CDRTOOLS_DIR		= $(BUILDDIR)/$(CDRTOOLS)
CDRTOOLS_IPKG_TMP	= $(CDRTOOLS_DIR)/ipkg_tmp

# ----------------------------------------------------------------------------
# Get
# ----------------------------------------------------------------------------

cdrtools_get: $(STATEDIR)/cdrtools.get

cdrtools_get_deps = $(CDRTOOLS_SOURCE)

$(STATEDIR)/cdrtools.get: $(cdrtools_get_deps)
	@$(call targetinfo, $@)
	@$(call get_patches, $(CDRTOOLS))
	touch $@

$(CDRTOOLS_SOURCE):
	@$(call targetinfo, $@)
	@$(call get, $(CDRTOOLS_URL))

# ----------------------------------------------------------------------------
# Extract
# ----------------------------------------------------------------------------

cdrtools_extract: $(STATEDIR)/cdrtools.extract

cdrtools_extract_deps = $(STATEDIR)/cdrtools.get

$(STATEDIR)/cdrtools.extract: $(cdrtools_extract_deps)
	@$(call targetinfo, $@)
	@$(call clean, $(CDRTOOLS_DIR))
	@$(call extract, $(CDRTOOLS_SOURCE))
	@$(call patchin, $(CDRTOOLS))
	touch $@

# ----------------------------------------------------------------------------
# Prepare
# ----------------------------------------------------------------------------

cdrtools_prepare: $(STATEDIR)/cdrtools.prepare

#
# dependencies
#
cdrtools_prepare_deps = \
	$(STATEDIR)/cdrtools.extract \
	$(STATEDIR)/virtual-xchain.install

CDRTOOLS_PATH	=  PATH=$(CROSS_PATH)
CDRTOOLS_ENV 	=  $(CROSS_ENV)
#CDRTOOLS_ENV	+=
CDRTOOLS_ENV	+= PKG_CONFIG_PATH=$(CROSS_LIB_DIR)/lib/pkgconfig:$(CROSS_LIB_DIR)/lib/pkgconfig
#ifdef PTXCONF_XFREE430
#CDRTOOLS_ENV	+= LDFLAGS=-Wl,-rpath-link,$(CROSS_LIB_DIR)/lib
#endif

#
# autoconf
#
CDRTOOLS_AUTOCONF = \
	--build=$(GNU_HOST) \
	--prefix=/usr \
	--sysconfdir=/etc \
	--host=$(PTXCONF_GNU_TARGET)

ifdef PTXCONF_XFREE430
CDRTOOLS_AUTOCONF += --x-includes=$(CROSS_LIB_DIR)/include
CDRTOOLS_AUTOCONF += --x-libraries=$(CROSS_LIB_DIR)/lib
endif

$(STATEDIR)/cdrtools.prepare: $(cdrtools_prepare_deps)
	@$(call targetinfo, $@)
	@$(call clean, $(CDRTOOLS_DIR)/config.cache)
	#cd $(CDRTOOLS_DIR) && \
	#	$(CDRTOOLS_PATH) $(CDRTOOLS_ENV) \
	#	./configure $(CDRTOOLS_AUTOCONF)
	touch $@

# ----------------------------------------------------------------------------
# Compile
# ----------------------------------------------------------------------------

cdrtools_compile: $(STATEDIR)/cdrtools.compile

cdrtools_compile_deps = $(STATEDIR)/cdrtools.prepare

$(STATEDIR)/cdrtools.compile: $(cdrtools_compile_deps)
	@$(call targetinfo, $@)
	$(CDRTOOLS_PATH) $(CDRTOOLS_ENV) $(MAKE) -C $(CDRTOOLS_DIR)
	touch $@

# ----------------------------------------------------------------------------
# Install
# ----------------------------------------------------------------------------

cdrtools_install: $(STATEDIR)/cdrtools.install

$(STATEDIR)/cdrtools.install: $(STATEDIR)/cdrtools.compile
	@$(call targetinfo, $@)
	asdasd
	touch $@

# ----------------------------------------------------------------------------
# Target-Install
# ----------------------------------------------------------------------------

cdrtools_targetinstall: $(STATEDIR)/cdrtools.targetinstall

cdrtools_targetinstall_deps = $(STATEDIR)/cdrtools.compile

$(STATEDIR)/cdrtools.targetinstall: $(cdrtools_targetinstall_deps)
	@$(call targetinfo, $@)
	$(CDRTOOLS_PATH) $(MAKE) -C $(CDRTOOLS_DIR) install INS_BASE=$(CDRTOOLS_IPKG_TMP)/usr
	rm -rf $(CDRTOOLS_IPKG_TMP)/usr/include
	rm -rf $(CDRTOOLS_IPKG_TMP)/usr/lib
	rm -rf $(CDRTOOLS_IPKG_TMP)/usr/man
	$(CROSSSTRIP) $(CDRTOOLS_IPKG_TMP)/usr/bin/*
	$(CROSSSTRIP) $(CDRTOOLS_IPKG_TMP)/usr/sbin/*
	mkdir -p $(CDRTOOLS_IPKG_TMP)/CONTROL
	echo "Package: cdrtools" 						 >$(CDRTOOLS_IPKG_TMP)/CONTROL/control
	echo "Priority: optional" 						>>$(CDRTOOLS_IPKG_TMP)/CONTROL/control
	echo "Section: Utilities" 						>>$(CDRTOOLS_IPKG_TMP)/CONTROL/control
	echo "Maintainer: Alexander Chukov <sash@pdaXrom.org>" 			>>$(CDRTOOLS_IPKG_TMP)/CONTROL/control
	echo "Architecture: $(SHORT_TARGET)" 					>>$(CDRTOOLS_IPKG_TMP)/CONTROL/control
	echo "Version: $(CDRTOOLS_VERSION)" 					>>$(CDRTOOLS_IPKG_TMP)/CONTROL/control
	echo "Depends: " 							>>$(CDRTOOLS_IPKG_TMP)/CONTROL/control
	echo "Description: command line cdrw utils"				>>$(CDRTOOLS_IPKG_TMP)/CONTROL/control
	cd $(FEEDDIR) && $(XMKIPKG) $(CDRTOOLS_IPKG_TMP)
	touch $@

# ----------------------------------------------------------------------------
# Image-Install
# ----------------------------------------------------------------------------

ifdef PTXCONF_CDRTOOLS_INSTALL
ROMPACKAGES += $(STATEDIR)/cdrtools.imageinstall
endif

cdrtools_imageinstall_deps = $(STATEDIR)/cdrtools.targetinstall \
	$(STATEDIR)/virtual-image.install

$(STATEDIR)/cdrtools.imageinstall: $(cdrtools_imageinstall_deps)
	@$(call targetinfo, $@)
	cd $(FEEDDIR) && $(XIPKG) install cdrtools
	touch $@

# ----------------------------------------------------------------------------
# Clean
# ----------------------------------------------------------------------------

cdrtools_clean:
	rm -rf $(STATEDIR)/cdrtools.*
	rm -rf $(CDRTOOLS_DIR)

# vim: syntax=make
