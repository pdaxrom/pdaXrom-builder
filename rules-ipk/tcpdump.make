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
ifdef PTXCONF_TCPDUMP
PACKAGES += tcpdump
endif

#
# Paths and names
#
TCPDUMP_VENDOR_VERSION	= 1
TCPDUMP_VERSION		= 3.8.3
TCPDUMP			= tcpdump-$(TCPDUMP_VERSION)
TCPDUMP_SUFFIX		= tar.gz
TCPDUMP_URL		= http://www.tcpdump.org/release/$(TCPDUMP).$(TCPDUMP_SUFFIX)
TCPDUMP_SOURCE		= $(SRCDIR)/$(TCPDUMP).$(TCPDUMP_SUFFIX)
TCPDUMP_DIR		= $(BUILDDIR)/$(TCPDUMP)
TCPDUMP_IPKG_TMP	= $(TCPDUMP_DIR)/ipkg_tmp

# ----------------------------------------------------------------------------
# Get
# ----------------------------------------------------------------------------

tcpdump_get: $(STATEDIR)/tcpdump.get

tcpdump_get_deps = $(TCPDUMP_SOURCE)

$(STATEDIR)/tcpdump.get: $(tcpdump_get_deps)
	@$(call targetinfo, $@)
	@$(call get_patches, $(TCPDUMP))
	touch $@

$(TCPDUMP_SOURCE):
	@$(call targetinfo, $@)
	@$(call get, $(TCPDUMP_URL))

# ----------------------------------------------------------------------------
# Extract
# ----------------------------------------------------------------------------

tcpdump_extract: $(STATEDIR)/tcpdump.extract

tcpdump_extract_deps = $(STATEDIR)/tcpdump.get

$(STATEDIR)/tcpdump.extract: $(tcpdump_extract_deps)
	@$(call targetinfo, $@)
	@$(call clean, $(TCPDUMP_DIR))
	@$(call extract, $(TCPDUMP_SOURCE))
	@$(call patchin, $(TCPDUMP))
	touch $@

# ----------------------------------------------------------------------------
# Prepare
# ----------------------------------------------------------------------------

tcpdump_prepare: $(STATEDIR)/tcpdump.prepare

#
# dependencies
#
tcpdump_prepare_deps = \
	$(STATEDIR)/tcpdump.extract \
	$(STATEDIR)/libpcap.install \
	$(STATEDIR)/virtual-xchain.install

TCPDUMP_PATH	=  PATH=$(CROSS_PATH)
TCPDUMP_ENV 	=  $(CROSS_ENV)
#TCPDUMP_ENV	+=
TCPDUMP_ENV	+= PKG_CONFIG_PATH=$(CROSS_LIB_DIR)/lib/pkgconfig
#ifdef PTXCONF_XFREE430
#TCPDUMP_ENV	+= LDFLAGS=-Wl,-rpath-link,$(CROSS_LIB_DIR)/X11R6/lib
#endif

#
# autoconf
#
TCPDUMP_AUTOCONF = \
	--build=$(GNU_HOST) \
	--host=$(PTXCONF_GNU_TARGET) \
	--prefix=/usr

ifdef PTXCONF_XFREE430
TCPDUMP_AUTOCONF += --x-includes=$(CROSS_LIB_DIR)/include
TCPDUMP_AUTOCONF += --x-libraries=$(CROSS_LIB_DIR)/lib
endif

$(STATEDIR)/tcpdump.prepare: $(tcpdump_prepare_deps)
	@$(call targetinfo, $@)
	@$(call clean, $(TCPDUMP_DIR)/config.cache)
	cd $(TCPDUMP_DIR) && \
		$(TCPDUMP_PATH) $(TCPDUMP_ENV) \
		ac_cv_linux_vers=2 \
		./configure $(TCPDUMP_AUTOCONF)
	touch $@

# ----------------------------------------------------------------------------
# Compile
# ----------------------------------------------------------------------------

tcpdump_compile: $(STATEDIR)/tcpdump.compile

tcpdump_compile_deps = $(STATEDIR)/tcpdump.prepare

$(STATEDIR)/tcpdump.compile: $(tcpdump_compile_deps)
	@$(call targetinfo, $@)
	$(TCPDUMP_PATH) $(MAKE) -C $(TCPDUMP_DIR)
	touch $@

# ----------------------------------------------------------------------------
# Install
# ----------------------------------------------------------------------------

tcpdump_install: $(STATEDIR)/tcpdump.install

$(STATEDIR)/tcpdump.install: $(STATEDIR)/tcpdump.compile
	@$(call targetinfo, $@)
	touch $@

# ----------------------------------------------------------------------------
# Target-Install
# ----------------------------------------------------------------------------

tcpdump_targetinstall: $(STATEDIR)/tcpdump.targetinstall

tcpdump_targetinstall_deps = $(STATEDIR)/tcpdump.compile

$(STATEDIR)/tcpdump.targetinstall: $(tcpdump_targetinstall_deps)
	@$(call targetinfo, $@)
	$(TCPDUMP_PATH) $(MAKE) -C $(TCPDUMP_DIR) DESTDIR=$(TCPDUMP_IPKG_TMP) install
	rm -rf $(TCPDUMP_IPKG_TMP)/usr/man
	$(CROSSSTRIP) $(TCPDUMP_IPKG_TMP)/usr/sbin/*
	mkdir -p $(TCPDUMP_IPKG_TMP)/CONTROL
	echo "Package: tcpdump" 							 >$(TCPDUMP_IPKG_TMP)/CONTROL/control
	echo "Priority: optional" 							>>$(TCPDUMP_IPKG_TMP)/CONTROL/control
	echo "Section: Network" 							>>$(TCPDUMP_IPKG_TMP)/CONTROL/control
	echo "Maintainer: Alexander Chukov <sash@pdaXrom.org>" 				>>$(TCPDUMP_IPKG_TMP)/CONTROL/control
	echo "Architecture: $(SHORT_TARGET)" 						>>$(TCPDUMP_IPKG_TMP)/CONTROL/control
	echo "Version: $(TCPDUMP_VERSION)-$(TCPDUMP_VENDOR_VERSION)" 			>>$(TCPDUMP_IPKG_TMP)/CONTROL/control
	echo "Depends: " 								>>$(TCPDUMP_IPKG_TMP)/CONTROL/control
	echo "Description: dump traffic on a network"					>>$(TCPDUMP_IPKG_TMP)/CONTROL/control
	cd $(FEEDDIR) && $(XMKIPKG) $(TCPDUMP_IPKG_TMP)
	touch $@

# ----------------------------------------------------------------------------
# Image-Install
# ----------------------------------------------------------------------------

ifdef PTXCONF_TCPDUMP_INSTALL
ROMPACKAGES += $(STATEDIR)/tcpdump.imageinstall
endif

tcpdump_imageinstall_deps = $(STATEDIR)/tcpdump.targetinstall \
	$(STATEDIR)/virtual-image.install

$(STATEDIR)/tcpdump.imageinstall: $(tcpdump_imageinstall_deps)
	@$(call targetinfo, $@)
	cd $(FEEDDIR) && $(XIPKG) install tcpdump
	touch $@

# ----------------------------------------------------------------------------
# Clean
# ----------------------------------------------------------------------------

tcpdump_clean:
	rm -rf $(STATEDIR)/tcpdump.*
	rm -rf $(TCPDUMP_DIR)

# vim: syntax=make
