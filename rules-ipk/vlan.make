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
ifdef PTXCONF_VLAN
PACKAGES += vlan
endif

#
# Paths and names
#
VLAN_VENDOR_VERSION	= 1
VLAN_VERSION		= 1.8
VLAN			= vlan.$(VLAN_VERSION)
VLAN_SUFFIX		= tar.gz
VLAN_URL		= http://scry.wanfear.com/~greear/vlan/$(VLAN).$(VLAN_SUFFIX)
VLAN_SOURCE		= $(SRCDIR)/$(VLAN).$(VLAN_SUFFIX)
VLAN_DIR		= $(BUILDDIR)/vlan
VLAN_IPKG_TMP		= $(VLAN_DIR)/ipkg_tmp

# ----------------------------------------------------------------------------
# Get
# ----------------------------------------------------------------------------

vlan_get: $(STATEDIR)/vlan.get

vlan_get_deps = $(VLAN_SOURCE)

$(STATEDIR)/vlan.get: $(vlan_get_deps)
	@$(call targetinfo, $@)
	@$(call get_patches, $(VLAN))
	touch $@

$(VLAN_SOURCE):
	@$(call targetinfo, $@)
	@$(call get, $(VLAN_URL))

# ----------------------------------------------------------------------------
# Extract
# ----------------------------------------------------------------------------

vlan_extract: $(STATEDIR)/vlan.extract

vlan_extract_deps = $(STATEDIR)/vlan.get

$(STATEDIR)/vlan.extract: $(vlan_extract_deps)
	@$(call targetinfo, $@)
	@$(call clean,   $(VLAN_DIR))
	@$(call extract, $(VLAN_SOURCE))
	@$(call patchin, $(VLAN), $(VLAN_DIR))
	touch $@

# ----------------------------------------------------------------------------
# Prepare
# ----------------------------------------------------------------------------

vlan_prepare: $(STATEDIR)/vlan.prepare

#
# dependencies
#
vlan_prepare_deps = \
	$(STATEDIR)/vlan.extract \
	$(STATEDIR)/virtual-xchain.install

VLAN_PATH	=  PATH=$(CROSS_PATH)
VLAN_ENV 	=  $(CROSS_ENV)
#VLAN_ENV	+=
VLAN_ENV	+= PKG_CONFIG_PATH=$(CROSS_LIB_DIR)/lib/pkgconfig
#ifdef PTXCONF_XFREE430
#VLAN_ENV	+= LDFLAGS=-Wl,-rpath-link,$(CROSS_LIB_DIR)/X11R6/lib
#endif

#
# autoconf
#
VLAN_AUTOCONF = \
	--build=$(GNU_HOST) \
	--host=$(PTXCONF_GNU_TARGET) \
	--prefix=/usr

ifdef PTXCONF_XFREE430
VLAN_AUTOCONF += --x-includes=$(CROSS_LIB_DIR)/include
VLAN_AUTOCONF += --x-libraries=$(CROSS_LIB_DIR)/lib
endif

$(STATEDIR)/vlan.prepare: $(vlan_prepare_deps)
	@$(call targetinfo, $@)
	@$(call clean, $(VLAN_DIR)/config.cache)
	#cd $(VLAN_DIR) && \
	#	$(VLAN_PATH) $(VLAN_ENV) \
	#	./configure $(VLAN_AUTOCONF)
	$(VLAN_PATH) $(VLAN_ENV) $(MAKE) -C $(VLAN_DIR) clean
	rm -f $(VLAN_DIR)/{vconfig,macvlan_config}
	touch $@

# ----------------------------------------------------------------------------
# Compile
# ----------------------------------------------------------------------------

vlan_compile: $(STATEDIR)/vlan.compile

vlan_compile_deps = $(STATEDIR)/vlan.prepare

$(STATEDIR)/vlan.compile: $(vlan_compile_deps)
	@$(call targetinfo, $@)
	$(VLAN_PATH) $(VLAN_ENV) $(MAKE) -C $(VLAN_DIR) \
	    $(CROSS_ENV_CC) $(CROSS_ENV_STRIP) CCFLAGS='-O2 -D_GNU_SOURCE -Wall -I$(KERNEL_DIR)/include' \
	    vconfig
	touch $@

# ----------------------------------------------------------------------------
# Install
# ----------------------------------------------------------------------------

vlan_install: $(STATEDIR)/vlan.install

$(STATEDIR)/vlan.install: $(STATEDIR)/vlan.compile
	@$(call targetinfo, $@)
	touch $@

# ----------------------------------------------------------------------------
# Target-Install
# ----------------------------------------------------------------------------

vlan_targetinstall: $(STATEDIR)/vlan.targetinstall

vlan_targetinstall_deps = $(STATEDIR)/vlan.compile

$(STATEDIR)/vlan.targetinstall: $(vlan_targetinstall_deps)
	@$(call targetinfo, $@)
	##$(VLAN_PATH) $(MAKE) -C $(VLAN_DIR) DESTDIR=$(VLAN_IPKG_TMP) install
	$(INSTALL) -D -m 755 $(VLAN_DIR)/vconfig $(VLAN_IPKG_TMP)/usr/sbin/vconfig
	##$(INSTALL) -D -m 755 $(VLAN_DIR)/macvlan_config $(VLAN_IPKG_TMP)/usr/sbin/macvlan_config
	mkdir -p $(VLAN_IPKG_TMP)/CONTROL
	echo "Package: vlan" 								 >$(VLAN_IPKG_TMP)/CONTROL/control
	echo "Priority: optional" 							>>$(VLAN_IPKG_TMP)/CONTROL/control
	echo "Section: Network" 							>>$(VLAN_IPKG_TMP)/CONTROL/control
	echo "Maintainer: Alexander Chukov <sash@pdaXrom.org>" 				>>$(VLAN_IPKG_TMP)/CONTROL/control
	echo "Architecture: $(SHORT_TARGET)" 						>>$(VLAN_IPKG_TMP)/CONTROL/control
	echo "Version: $(VLAN_VERSION)-$(VLAN_VENDOR_VERSION)" 				>>$(VLAN_IPKG_TMP)/CONTROL/control
	echo "Depends: " 								>>$(VLAN_IPKG_TMP)/CONTROL/control
	echo "Description: 802.1Q VLAN implementation for Linux"			>>$(VLAN_IPKG_TMP)/CONTROL/control
	cd $(FEEDDIR) && $(XMKIPKG) $(VLAN_IPKG_TMP)
	touch $@

# ----------------------------------------------------------------------------
# Image-Install
# ----------------------------------------------------------------------------

ifdef PTXCONF_VLAN_INSTALL
ROMPACKAGES += $(STATEDIR)/vlan.imageinstall
endif

vlan_imageinstall_deps = $(STATEDIR)/vlan.targetinstall \
	$(STATEDIR)/virtual-image.install

$(STATEDIR)/vlan.imageinstall: $(vlan_imageinstall_deps)
	@$(call targetinfo, $@)
	cd $(FEEDDIR) && $(XIPKG) install vlan
	touch $@

# ----------------------------------------------------------------------------
# Clean
# ----------------------------------------------------------------------------

vlan_clean:
	rm -rf $(STATEDIR)/vlan.*
	rm -rf $(VLAN_DIR)

# vim: syntax=make
