# -*-makefile-*-
# $Id: wireless.make,v 1.3 2003/10/23 15:01:19 mkl Exp $
#
# Copyright (C) 2003 by Pengutronix e.K., Hildesheim, Germany
# See CREDITS for details about who has contributed to this project. 
#
# For further information about the PTXdist project and license conditions
# see the README file.
#

#
# We provide this package
#
ifdef PTXCONF_WIRELESS
PACKAGES += wireless
endif

#
# Paths and names 
#
WIRELESS_VERSION	= 26
WIRELESS		= wireless_tools.$(WIRELESS_VERSION)
WIRELESS_SUFFIX		= tar.gz
WIRELESS_URL		= http://pcmcia-cs.sourceforge.net/ftp/contrib/$(WIRELESS).$(WIRELESS_SUFFIX)
WIRELESS_SOURCE		= $(SRCDIR)/$(WIRELESS).$(WIRELESS_SUFFIX)
WIRELESS_DIR 		= $(BUILDDIR)/$(WIRELESS)

# ----------------------------------------------------------------------------
# Get
# ----------------------------------------------------------------------------

wireless_get: $(STATEDIR)/wireless.get

wireless_get_deps	= $(WIRELESS_SOURCE)

$(STATEDIR)/wireless.get: $(wireless_get_deps)
	@$(call targetinfo, $@)
	touch $@

$(WIRELESS_SOURCE):
	@$(call targetinfo, $@)
	@$(call get, $(WIRELESS_URL))

# ----------------------------------------------------------------------------
# Extract
# ----------------------------------------------------------------------------

wireless_extract: $(STATEDIR)/wireless.extract

wireless_extract_deps	= $(STATEDIR)/wireless.get

$(STATEDIR)/wireless.extract: $(wireless_extract_deps)
	@$(call targetinfo, $@)
	@$(call clean, $(WIRELESS_DIR))
	@$(call extract, $(WIRELESS_SOURCE))
	touch $@

# ----------------------------------------------------------------------------
# Prepare
# ----------------------------------------------------------------------------

wireless_prepare: $(STATEDIR)/wireless.prepare

wireless_prepare_deps	= $(STATEDIR)/wireless.extract

$(STATEDIR)/wireless.prepare: $(wireless_prepare_deps)
	@$(call targetinfo, $@)
	touch $@

# ----------------------------------------------------------------------------
# Compile
# ----------------------------------------------------------------------------

wireless_compile: $(STATEDIR)/wireless.compile

wireless_compile_deps	= $(STATEDIR)/wireless.prepare

WIRELESS_PATH	=  PATH=$(CROSS_PATH)
NEWCC=
ifdef PTXCONF_ARCH_ARM
NEWCC=CC=$(PTXCONF_GNU_TARGET)-gcc
endif

$(STATEDIR)/wireless.compile: $(wireless_compile_deps) 
	@$(call targetinfo, $@)
	$(WIRELESS_PATH) $(MAKE) -C $(WIRELESS_DIR) $(NEWCC) KERNEL_SRC=$(KERNEL_DIR)
	touch $@

# ----------------------------------------------------------------------------
# Install
# ----------------------------------------------------------------------------

wireless_install: $(STATEDIR)/wireless.install

wireless_compile_deps	= $(STATEDIR)/wireless.compile

$(STATEDIR)/wireless.install: $(wireless_compile_deps)
	@$(call targetinfo, $@)
	touch $@

# ----------------------------------------------------------------------------
# Target-Install
# ----------------------------------------------------------------------------

wireless_targetinstall: $(STATEDIR)/wireless.targetinstall

$(STATEDIR)/wireless.targetinstall: $(STATEDIR)/wireless.install
	@$(call targetinfo, $@)
	mkdir -p $(WIRELESS_DIR)/ipkg_tmp/sbin
	mkdir -p $(WIRELESS_DIR)/ipkg_tmp/lib
	$(INSTALL) -m 755 $(WIRELESS_DIR)/iwconfig $(WIRELESS_DIR)/ipkg_tmp/sbin
	$(INSTALL) -m 755 $(WIRELESS_DIR)/iwevent  $(WIRELESS_DIR)/ipkg_tmp/sbin
	$(INSTALL) -m 755 $(WIRELESS_DIR)/iwgetid  $(WIRELESS_DIR)/ipkg_tmp/sbin
	$(INSTALL) -m 755 $(WIRELESS_DIR)/iwlist   $(WIRELESS_DIR)/ipkg_tmp/sbin
	$(INSTALL) -m 755 $(WIRELESS_DIR)/iwpriv   $(WIRELESS_DIR)/ipkg_tmp/sbin
	$(INSTALL) -m 755 $(WIRELESS_DIR)/iwspy    $(WIRELESS_DIR)/ipkg_tmp/sbin
	$(INSTALL) -m 755 $(WIRELESS_DIR)/libiw.so.26 $(WIRELESS_DIR)/ipkg_tmp/lib
	$(CROSSSTRIP) -R .note -R .comment $(WIRELESS_DIR)/ipkg_tmp/sbin/iwconfig
	$(CROSSSTRIP) -R .note -R .comment $(WIRELESS_DIR)/ipkg_tmp/sbin/iwevent
	$(CROSSSTRIP) -R .note -R .comment $(WIRELESS_DIR)/ipkg_tmp/sbin/iwgetid
	$(CROSSSTRIP) -R .note -R .comment $(WIRELESS_DIR)/ipkg_tmp/sbin/iwlist
	$(CROSSSTRIP) -R .note -R .comment $(WIRELESS_DIR)/ipkg_tmp/sbin/iwpriv
	$(CROSSSTRIP) -R .note -R .comment $(WIRELESS_DIR)/ipkg_tmp/sbin/iwspy
	$(CROSSSTRIP) -R .note -R .comment $(WIRELESS_DIR)/ipkg_tmp/lib/libiw.so.26

	mkdir -p $(WIRELESS_DIR)/ipkg_tmp/CONTROL
	echo "Package: wireless" 						 >$(WIRELESS_DIR)/ipkg_tmp/CONTROL/control
	echo "Priority: optional" 						>>$(WIRELESS_DIR)/ipkg_tmp/CONTROL/control
	echo "Section: Network" 						>>$(WIRELESS_DIR)/ipkg_tmp/CONTROL/control
	echo "Maintainer: Alexander Chukov <sash@pdaXrom.org>" 			>>$(WIRELESS_DIR)/ipkg_tmp/CONTROL/control
	echo "Architecture: $(SHORT_TARGET)" 					>>$(WIRELESS_DIR)/ipkg_tmp/CONTROL/control
	echo "Version: $(WIRELESS_VERSION)" 					>>$(WIRELESS_DIR)/ipkg_tmp/CONTROL/control
	echo "Depends: " 							>>$(WIRELESS_DIR)/ipkg_tmp/CONTROL/control
	echo "Description: Tools for the Linux Standard Wireless Extension Subsystem" >>$(WIRELESS_DIR)/ipkg_tmp/CONTROL/control
	cd $(FEEDDIR) && $(XMKIPKG) $(WIRELESS_DIR)/ipkg_tmp

	touch $@

# ----------------------------------------------------------------------------
# Image-Install
# ----------------------------------------------------------------------------

ifdef PTXCONF_WIRELESS_INSTALL
ROMPACKAGES += $(STATEDIR)/wireless.imageinstall
endif

wireless_imageinstall_deps = $(STATEDIR)/wireless.targetinstall \
	$(STATEDIR)/virtual-image.install

$(STATEDIR)/wireless.imageinstall: $(wireless_imageinstall_deps)
	@$(call targetinfo, $@)
	cd $(FEEDDIR) && $(XIPKG) install wireless
	touch $@

# ----------------------------------------------------------------------------
# Clean
# ----------------------------------------------------------------------------

wireless_clean: 
	rm -rf $(STATEDIR)/wireless.* $(WIRELESS_DIR)

# vim: syntax=make
