# -*-makefile-*-
# $Id: template,v 1.10 2003/10/26 21:59:07 mkl Exp $
#
# Copyright (C) 2003 by Alexander Chukov <sash@cacko.biz>
#          
# See CREDITS for details about who has contributed to this project.
#
# For further information about the PTXdist project and license conditions
# see the README file.
#

#
# We provide this package
#
ifdef PTXCONF_DHCPCD
PACKAGES += dhcpcd
endif

#
# Paths and names
#
DHCPCD_VERSION		= 1.3.22-pl4
DHCPCD			= dhcpcd-$(DHCPCD_VERSION)
DHCPCD_SUFFIX		= tar.gz
DHCPCD_URL		= http://www.phystech.com/ftp//$(DHCPCD).$(DHCPCD_SUFFIX)
DHCPCD_SOURCE		= $(SRCDIR)/$(DHCPCD).$(DHCPCD_SUFFIX)
DHCPCD_DIR		= $(BUILDDIR)/$(DHCPCD)

# ----------------------------------------------------------------------------
# Get
# ----------------------------------------------------------------------------

dhcpcd_get: $(STATEDIR)/dhcpcd.get

dhcpcd_get_deps = $(DHCPCD_SOURCE)

$(STATEDIR)/dhcpcd.get: $(dhcpcd_get_deps)
	@$(call targetinfo, $@)
	@$(call get_patches, $(DHCPCD))
	touch $@

$(DHCPCD_SOURCE):
	@$(call targetinfo, $@)
	@$(call get, $(DHCPCD_URL))

# ----------------------------------------------------------------------------
# Extract
# ----------------------------------------------------------------------------

dhcpcd_extract: $(STATEDIR)/dhcpcd.extract

dhcpcd_extract_deps = $(STATEDIR)/dhcpcd.get

$(STATEDIR)/dhcpcd.extract: $(dhcpcd_extract_deps)
	@$(call targetinfo, $@)
	@$(call clean, $(DHCPCD_DIR))
	@$(call extract, $(DHCPCD_SOURCE))
	@$(call patchin, $(DHCPCD))
	touch $@

# ----------------------------------------------------------------------------
# Prepare
# ----------------------------------------------------------------------------

dhcpcd_prepare: $(STATEDIR)/dhcpcd.prepare

#
# dependencies
#
dhcpcd_prepare_deps = \
	$(STATEDIR)/dhcpcd.extract \
	$(STATEDIR)/virtual-xchain.install

DHCPCD_PATH	=  PATH=$(CROSS_PATH)
DHCPCD_ENV 	=  $(CROSS_ENV)
#DHCPCD_ENV	+=

#
# autoconf
#
DHCPCD_AUTOCONF = \
	--build=$(GNU_HOST) \
	--host=$(PTXCONF_GNU_TARGET) \
	--prefix=/

$(STATEDIR)/dhcpcd.prepare: $(dhcpcd_prepare_deps)
	@$(call targetinfo, $@)
	@$(call clean, $(DHCPCD_DIR)/config.cache)
	cd $(DHCPCD_DIR) && \
		$(DHCPCD_PATH) $(DHCPCD_ENV) \
		./configure $(DHCPCD_AUTOCONF)
	touch $@

# ----------------------------------------------------------------------------
# Compile
# ----------------------------------------------------------------------------

dhcpcd_compile: $(STATEDIR)/dhcpcd.compile

dhcpcd_compile_deps = $(STATEDIR)/dhcpcd.prepare

$(STATEDIR)/dhcpcd.compile: $(dhcpcd_compile_deps)
	@$(call targetinfo, $@)
	$(DHCPCD_PATH) $(MAKE) -C $(DHCPCD_DIR)
	touch $@

# ----------------------------------------------------------------------------
# Install
# ----------------------------------------------------------------------------

dhcpcd_install: $(STATEDIR)/dhcpcd.install

$(STATEDIR)/dhcpcd.install: $(STATEDIR)/dhcpcd.compile
	@$(call targetinfo, $@)
	#$(DHCPCD_PATH) $(MAKE) -C $(DHCPCD_DIR) install
	touch $@

# ----------------------------------------------------------------------------
# Target-Install
# ----------------------------------------------------------------------------

dhcpcd_targetinstall: $(STATEDIR)/dhcpcd.targetinstall

dhcpcd_targetinstall_deps = $(STATEDIR)/dhcpcd.compile

$(STATEDIR)/dhcpcd.targetinstall: $(dhcpcd_targetinstall_deps)
	@$(call targetinfo, $@)
	install -D $(DHCPCD_DIR)/dhcpcd $(DHCPCD_DIR)/ipk/sbin/dhcpcd
	$(CROSSSTRIP) -R .note -R .comment $(DHCPCD_DIR)/ipk/sbin/dhcpcd
	mkdir -p $(DHCPCD_DIR)/ipk/CONTROL
	echo "Package: dhcpcd" 							 >$(DHCPCD_DIR)/ipk/CONTROL/control
	echo "Priority: optional" 						>>$(DHCPCD_DIR)/ipk/CONTROL/control
	echo "Section: Network" 						>>$(DHCPCD_DIR)/ipk/CONTROL/control
	echo "Maintainer: Alexander Chukov <sash@pdaXrom.org>" 			>>$(DHCPCD_DIR)/ipk/CONTROL/control
	echo "Architecture: $(SHORT_TARGET)" 					>>$(DHCPCD_DIR)/ipk/CONTROL/control
	echo "Version: $(DHCPCD_VERSION)" 					>>$(DHCPCD_DIR)/ipk/CONTROL/control
	echo "Depends: " 							>>$(DHCPCD_DIR)/ipk/CONTROL/control
	echo "Description: RFC2131,RFC2132, and RFC1541 compliant DHCP client daemon.">>$(DHCPCD_DIR)/ipk/CONTROL/control
	cd $(FEEDDIR) && $(XMKIPKG) $(DHCPCD_DIR)/ipk
	touch $@

# ----------------------------------------------------------------------------
# Image-Install
# ----------------------------------------------------------------------------

ifdef PTXCONF_DHCPCD_INSTALL
ROMPACKAGES += $(STATEDIR)/dhcpcd.imageinstall
endif

dhcpcd_imageinstall_deps = $(STATEDIR)/dhcpcd.targetinstall \
	$(STATEDIR)/virtual-image.install

$(STATEDIR)/dhcpcd.imageinstall: $(dhcpcd_imageinstall_deps)
	@$(call targetinfo, $@)
	cd $(FEEDDIR) && $(XIPKG) install dhcpcd
	touch $@

# ----------------------------------------------------------------------------
# Clean
# ----------------------------------------------------------------------------

dhcpcd_clean:
	rm -rf $(STATEDIR)/dhcpcd.*
	rm -rf $(DHCPCD_DIR)

# vim: syntax=make
