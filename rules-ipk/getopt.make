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
ifdef PTXCONF_GETOPT
PACKAGES += getopt
endif

#
# Paths and names
#
GETOPT_VENDOR_VERSION	= 1
GETOPT_VERSION		= 20030307
GETOPT			= getopt-$(GETOPT_VERSION)
GETOPT_SUFFIX		= tar.gz
GETOPT_URL		= ftp://ftp.ossp.org/pkg/lib/getopt/$(GETOPT).$(GETOPT_SUFFIX)
GETOPT_SOURCE		= $(SRCDIR)/$(GETOPT).$(GETOPT_SUFFIX)
GETOPT_DIR		= $(BUILDDIR)/$(GETOPT)
GETOPT_IPKG_TMP		= $(GETOPT_DIR)/ipkg_tmp

# ----------------------------------------------------------------------------
# Get
# ----------------------------------------------------------------------------

getopt_get: $(STATEDIR)/getopt.get

getopt_get_deps = $(GETOPT_SOURCE)

$(STATEDIR)/getopt.get: $(getopt_get_deps)
	@$(call targetinfo, $@)
	@$(call get_patches, $(GETOPT))
	touch $@

$(GETOPT_SOURCE):
	@$(call targetinfo, $@)
	@$(call get, $(GETOPT_URL))

# ----------------------------------------------------------------------------
# Extract
# ----------------------------------------------------------------------------

getopt_extract: $(STATEDIR)/getopt.extract

getopt_extract_deps = $(STATEDIR)/getopt.get

$(STATEDIR)/getopt.extract: $(getopt_extract_deps)
	@$(call targetinfo, $@)
	@$(call clean, $(GETOPT_DIR))
	@$(call extract, $(GETOPT_SOURCE))
	@$(call patchin, $(GETOPT))
	touch $@

# ----------------------------------------------------------------------------
# Prepare
# ----------------------------------------------------------------------------

getopt_prepare: $(STATEDIR)/getopt.prepare

#
# dependencies
#
getopt_prepare_deps = \
	$(STATEDIR)/getopt.extract \
	$(STATEDIR)/virtual-xchain.install

GETOPT_PATH	=  PATH=$(CROSS_PATH)
GETOPT_ENV 	=  $(CROSS_ENV)
#GETOPT_ENV	+=
GETOPT_ENV	+= PKG_CONFIG_PATH=$(CROSS_LIB_DIR)/lib/pkgconfig:$(CROSS_LIB_DIR)/lib/pkgconfig
#ifdef PTXCONF_XFREE430
#GETOPT_ENV	+= LDFLAGS=-Wl,-rpath-link,$(CROSS_LIB_DIR)/lib
#endif

#
# autoconf
#
GETOPT_AUTOCONF = \
	--build=$(GNU_HOST) \
	--host=$(PTXCONF_GNU_TARGET) \
	--prefix=/usr

ifdef PTXCONF_XFREE430
GETOPT_AUTOCONF += --x-includes=$(CROSS_LIB_DIR)/include
GETOPT_AUTOCONF += --x-libraries=$(CROSS_LIB_DIR)/lib
endif

$(STATEDIR)/getopt.prepare: $(getopt_prepare_deps)
	@$(call targetinfo, $@)
	@$(call clean, $(GETOPT_DIR)/config.cache)
	cd $(GETOPT_DIR) && \
		$(GETOPT_PATH) $(GETOPT_ENV) \
		./configure $(GETOPT_AUTOCONF)
	touch $@

# ----------------------------------------------------------------------------
# Compile
# ----------------------------------------------------------------------------

getopt_compile: $(STATEDIR)/getopt.compile

getopt_compile_deps = $(STATEDIR)/getopt.prepare

$(STATEDIR)/getopt.compile: $(getopt_compile_deps)
	@$(call targetinfo, $@)
	$(GETOPT_PATH) $(MAKE) -C $(GETOPT_DIR)
	touch $@

# ----------------------------------------------------------------------------
# Install
# ----------------------------------------------------------------------------

getopt_install: $(STATEDIR)/getopt.install

$(STATEDIR)/getopt.install: $(STATEDIR)/getopt.compile
	@$(call targetinfo, $@)
	asdasd
	touch $@

# ----------------------------------------------------------------------------
# Target-Install
# ----------------------------------------------------------------------------

getopt_targetinstall: $(STATEDIR)/getopt.targetinstall

getopt_targetinstall_deps = $(STATEDIR)/getopt.compile

$(STATEDIR)/getopt.targetinstall: $(getopt_targetinstall_deps)
	@$(call targetinfo, $@)
	$(GETOPT_PATH) $(MAKE) -C $(GETOPT_DIR) DESTDIR=$(GETOPT_IPKG_TMP) install
	rm -rf $(GETOPT_IPKG_TMP)/usr/bin/getopt-config
	rm -rf $(GETOPT_IPKG_TMP)/usr/include
	rm -rf $(GETOPT_IPKG_TMP)/usr/lib
	rm -rf $(GETOPT_IPKG_TMP)/usr/man
	$(CROSSSTRIP) $(GETOPT_IPKG_TMP)/usr/bin/getopt
	mkdir -p $(GETOPT_IPKG_TMP)/CONTROL
	echo "Package: getopt" 								 >$(GETOPT_IPKG_TMP)/CONTROL/control
	echo "Priority: optional" 							>>$(GETOPT_IPKG_TMP)/CONTROL/control
	echo "Section: Utilities" 							>>$(GETOPT_IPKG_TMP)/CONTROL/control
	echo "Maintainer: Alexander Chukov <sash@pdaXrom.org>" 				>>$(GETOPT_IPKG_TMP)/CONTROL/control
	echo "Architecture: $(SHORT_TARGET)" 						>>$(GETOPT_IPKG_TMP)/CONTROL/control
	echo "Version: $(GETOPT_VERSION)-$(GETOPT_VENDOR_VERSION)" 			>>$(GETOPT_IPKG_TMP)/CONTROL/control
	echo "Depends: " 								>>$(GETOPT_IPKG_TMP)/CONTROL/control
	echo "Description: GNU getopt"							>>$(GETOPT_IPKG_TMP)/CONTROL/control
	cd $(FEEDDIR) && $(XMKIPKG) $(GETOPT_IPKG_TMP)
	touch $@

# ----------------------------------------------------------------------------
# Image-Install
# ----------------------------------------------------------------------------

ifdef PTXCONF_GETOPT_INSTALL
ROMPACKAGES += $(STATEDIR)/getopt.imageinstall
endif

getopt_imageinstall_deps = $(STATEDIR)/getopt.targetinstall \
	$(STATEDIR)/virtual-image.install

$(STATEDIR)/getopt.imageinstall: $(getopt_imageinstall_deps)
	@$(call targetinfo, $@)
	cd $(FEEDDIR) && $(XIPKG) install getopt
	touch $@

# ----------------------------------------------------------------------------
# Clean
# ----------------------------------------------------------------------------

getopt_clean:
	rm -rf $(STATEDIR)/getopt.*
	rm -rf $(GETOPT_DIR)

# vim: syntax=make
