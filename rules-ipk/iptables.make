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
ifdef PTXCONF_IPTABLES
PACKAGES += iptables
endif

#
# Paths and names
#
IPTABLES_VERSION	= 1.2.11
IPTABLES		= iptables-$(IPTABLES_VERSION)
IPTABLES_SUFFIX		= tar.bz2
IPTABLES_URL		= http://netfilter.org/files/$(IPTABLES).$(IPTABLES_SUFFIX)
IPTABLES_SOURCE		= $(SRCDIR)/$(IPTABLES).$(IPTABLES_SUFFIX)
IPTABLES_DIR		= $(BUILDDIR)/$(IPTABLES)
IPTABLES_IPKG_TMP	= $(IPTABLES_DIR)/ipkg_tmp

# ----------------------------------------------------------------------------
# Get
# ----------------------------------------------------------------------------

iptables_get: $(STATEDIR)/iptables.get

iptables_get_deps = $(IPTABLES_SOURCE)

$(STATEDIR)/iptables.get: $(iptables_get_deps)
	@$(call targetinfo, $@)
	@$(call get_patches, $(IPTABLES))
	touch $@

$(IPTABLES_SOURCE):
	@$(call targetinfo, $@)
	@$(call get, $(IPTABLES_URL))

# ----------------------------------------------------------------------------
# Extract
# ----------------------------------------------------------------------------

iptables_extract: $(STATEDIR)/iptables.extract

iptables_extract_deps = $(STATEDIR)/iptables.get

$(STATEDIR)/iptables.extract: $(iptables_extract_deps)
	@$(call targetinfo, $@)
	@$(call clean, $(IPTABLES_DIR))
	@$(call extract, $(IPTABLES_SOURCE))
	@$(call patchin, $(IPTABLES))
	touch $@

# ----------------------------------------------------------------------------
# Prepare
# ----------------------------------------------------------------------------

iptables_prepare: $(STATEDIR)/iptables.prepare

#
# dependencies
#
iptables_prepare_deps = \
	$(STATEDIR)/iptables.extract \
	$(STATEDIR)/virtual-xchain.install

IPTABLES_PATH	=  PATH=$(CROSS_PATH)
IPTABLES_ENV 	=  $(CROSS_ENV)
#IPTABLES_ENV	+=
IPTABLES_ENV	+= PKG_CONFIG_PATH=$(CROSS_LIB_DIR)/lib/pkgconfig:$(CROSS_LIB_DIR)/lib/pkgconfig
#ifdef PTXCONF_XFREE430
#IPTABLES_ENV	+= LDFLAGS=-Wl,-rpath-link,$(CROSS_LIB_DIR)/lib
#endif

#
# autoconf
#
IPTABLES_AUTOCONF = \
	--build=$(GNU_HOST) \
	--host=$(PTXCONF_GNU_TARGET) \
	--prefix=/usr

ifdef PTXCONF_XFREE430
IPTABLES_AUTOCONF += --x-includes=$(CROSS_LIB_DIR)/include
IPTABLES_AUTOCONF += --x-libraries=$(CROSS_LIB_DIR)/lib
endif

$(STATEDIR)/iptables.prepare: $(iptables_prepare_deps)
	@$(call targetinfo, $@)
	@$(call clean, $(IPTABLES_DIR)/config.cache)
	#cd $(IPTABLES_DIR) && \
	#	$(IPTABLES_PATH) $(IPTABLES_ENV) \
	#	./configure $(IPTABLES_AUTOCONF)
	#asdasd
	touch $@

# ----------------------------------------------------------------------------
# Compile
# ----------------------------------------------------------------------------

iptables_compile: $(STATEDIR)/iptables.compile

iptables_compile_deps = $(STATEDIR)/iptables.prepare

$(STATEDIR)/iptables.compile: $(iptables_compile_deps)
	@$(call targetinfo, $@)
	$(IPTABLES_PATH) $(IPTABLES_ENV) $(MAKE) -C $(IPTABLES_DIR) DO_IPV6=0 KERNEL_DIR=$(KERNEL_DIR) PREFIX=/usr
	touch $@

# ----------------------------------------------------------------------------
# Install
# ----------------------------------------------------------------------------

iptables_install: $(STATEDIR)/iptables.install

$(STATEDIR)/iptables.install: $(STATEDIR)/iptables.compile
	@$(call targetinfo, $@)
	#$(IPTABLES_PATH) $(MAKE) -C $(IPTABLES_DIR) install
	sadfsd
	touch $@

# ----------------------------------------------------------------------------
# Target-Install
# ----------------------------------------------------------------------------

iptables_targetinstall: $(STATEDIR)/iptables.targetinstall

iptables_targetinstall_deps = $(STATEDIR)/iptables.compile

$(STATEDIR)/iptables.targetinstall: $(iptables_targetinstall_deps)
	@$(call targetinfo, $@)
	$(IPTABLES_PATH) $(IPTABLES_ENV) $(MAKE) -C $(IPTABLES_DIR) DO_IPV6=0 KERNEL_DIR=$(KERNEL_DIR) PREFIX=/usr DESTDIR=$(IPTABLES_IPKG_TMP) install
	rm -rf        $(IPTABLES_IPKG_TMP)/usr/man
	$(CROSSSTRIP) $(IPTABLES_IPKG_TMP)/usr/lib/iptables/*
	$(CROSSSTRIP) $(IPTABLES_IPKG_TMP)/usr/sbin/*
	mkdir -p $(IPTABLES_IPKG_TMP)/CONTROL
	echo "Package: iptables" 			>$(IPTABLES_IPKG_TMP)/CONTROL/control
	echo "Priority: optional" 			>>$(IPTABLES_IPKG_TMP)/CONTROL/control
	echo "Section: Network" 			>>$(IPTABLES_IPKG_TMP)/CONTROL/control
	echo "Maintainer: Alexander Chukov <sash@pdaXrom.org>">>$(IPTABLES_IPKG_TMP)/CONTROL/control
	echo "Architecture: $(SHORT_TARGET)" 		>>$(IPTABLES_IPKG_TMP)/CONTROL/control
	echo "Version: $(IPTABLES_VERSION)" 		>>$(IPTABLES_IPKG_TMP)/CONTROL/control
	echo "Depends: "		 		>>$(IPTABLES_IPKG_TMP)/CONTROL/control
	echo "Description: administration tool for IPv4 packet filtering and NAT">>$(IPTABLES_IPKG_TMP)/CONTROL/control
	cd $(FEEDDIR) && $(XMKIPKG) $(IPTABLES_IPKG_TMP)
	touch $@

# ----------------------------------------------------------------------------
# Image-Install
# ----------------------------------------------------------------------------

ifdef PTXCONF_IPTABLES_INSTALL
ROMPACKAGES += $(STATEDIR)/iptables.imageinstall
endif

iptables_imageinstall_deps = $(STATEDIR)/iptables.targetinstall \
	$(STATEDIR)/virtual-image.install

$(STATEDIR)/iptables.imageinstall: $(iptables_imageinstall_deps)
	@$(call targetinfo, $@)
	cd $(FEEDDIR) && $(XIPKG) install iptables
	touch $@

# ----------------------------------------------------------------------------
# Clean
# ----------------------------------------------------------------------------

iptables_clean:
	rm -rf $(STATEDIR)/iptables.*
	rm -rf $(IPTABLES_DIR)

# vim: syntax=make
