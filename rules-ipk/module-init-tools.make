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
ifdef PTXCONF_MODULE-INIT-TOOLS
PACKAGES += module-init-tools
endif

#
# Paths and names
#
MODULE-INIT-TOOLS_VENDOR_VERSION	= 1
MODULE-INIT-TOOLS_VERSION		= 3.1
MODULE-INIT-TOOLS			= module-init-tools-$(MODULE-INIT-TOOLS_VERSION)
MODULE-INIT-TOOLS_SUFFIX		= tar.bz2
MODULE-INIT-TOOLS_URL			= http://www.kernel.org/pub/linux/utils/kernel/module-init-tools/$(MODULE-INIT-TOOLS).$(MODULE-INIT-TOOLS_SUFFIX)
MODULE-INIT-TOOLS_SOURCE		= $(SRCDIR)/$(MODULE-INIT-TOOLS).$(MODULE-INIT-TOOLS_SUFFIX)
MODULE-INIT-TOOLS_DIR			= $(BUILDDIR)/$(MODULE-INIT-TOOLS)
MODULE-INIT-TOOLS_IPKG_TMP		= $(MODULE-INIT-TOOLS_DIR)/ipkg_tmp

# ----------------------------------------------------------------------------
# Get
# ----------------------------------------------------------------------------

module-init-tools_get: $(STATEDIR)/module-init-tools.get

module-init-tools_get_deps = $(MODULE-INIT-TOOLS_SOURCE)

$(STATEDIR)/module-init-tools.get: $(module-init-tools_get_deps)
	@$(call targetinfo, $@)
	@$(call get_patches, $(MODULE-INIT-TOOLS))
	touch $@

$(MODULE-INIT-TOOLS_SOURCE):
	@$(call targetinfo, $@)
	@$(call get, $(MODULE-INIT-TOOLS_URL))

# ----------------------------------------------------------------------------
# Extract
# ----------------------------------------------------------------------------

module-init-tools_extract: $(STATEDIR)/module-init-tools.extract

module-init-tools_extract_deps = $(STATEDIR)/module-init-tools.get

$(STATEDIR)/module-init-tools.extract: $(module-init-tools_extract_deps)
	@$(call targetinfo, $@)
	@$(call clean, $(MODULE-INIT-TOOLS_DIR))
	@$(call extract, $(MODULE-INIT-TOOLS_SOURCE))
	@$(call patchin, $(MODULE-INIT-TOOLS))
	touch $@

# ----------------------------------------------------------------------------
# Prepare
# ----------------------------------------------------------------------------

module-init-tools_prepare: $(STATEDIR)/module-init-tools.prepare

#
# dependencies
#
module-init-tools_prepare_deps = \
	$(STATEDIR)/module-init-tools.extract \
	$(STATEDIR)/virtual-xchain.install

MODULE-INIT-TOOLS_PATH	=  PATH=$(CROSS_PATH)
MODULE-INIT-TOOLS_ENV 	=  $(CROSS_ENV)
#MODULE-INIT-TOOLS_ENV	+=
MODULE-INIT-TOOLS_ENV	+= PKG_CONFIG_PATH=$(CROSS_LIB_DIR)/lib/pkgconfig:$(CROSS_LIB_DIR)/lib/pkgconfig
#ifdef PTXCONF_XFREE430
#MODULE-INIT-TOOLS_ENV	+= LDFLAGS=-Wl,-rpath-link,$(CROSS_LIB_DIR)/lib
#endif

#
# autoconf
#
MODULE-INIT-TOOLS_AUTOCONF = \
	--build=$(GNU_HOST) \
	--host=$(PTXCONF_GNU_TARGET) \
	--prefix=/

ifdef PTXCONF_XFREE430
MODULE-INIT-TOOLS_AUTOCONF += --x-includes=$(CROSS_LIB_DIR)/include
MODULE-INIT-TOOLS_AUTOCONF += --x-libraries=$(CROSS_LIB_DIR)/lib
endif

$(STATEDIR)/module-init-tools.prepare: $(module-init-tools_prepare_deps)
	@$(call targetinfo, $@)
	@$(call clean, $(MODULE-INIT-TOOLS_DIR)/config.cache)
	cd $(MODULE-INIT-TOOLS_DIR) && \
		$(MODULE-INIT-TOOLS_PATH) $(MODULE-INIT-TOOLS_ENV) \
		./configure $(MODULE-INIT-TOOLS_AUTOCONF)
	touch $@

# ----------------------------------------------------------------------------
# Compile
# ----------------------------------------------------------------------------

module-init-tools_compile: $(STATEDIR)/module-init-tools.compile

module-init-tools_compile_deps = $(STATEDIR)/module-init-tools.prepare

$(STATEDIR)/module-init-tools.compile: $(module-init-tools_compile_deps)
	@$(call targetinfo, $@)
	$(MODULE-INIT-TOOLS_PATH) $(MAKE) -C $(MODULE-INIT-TOOLS_DIR) DOCBOOKTOMAN=/bin/true
	touch $@

# ----------------------------------------------------------------------------
# Install
# ----------------------------------------------------------------------------

module-init-tools_install: $(STATEDIR)/module-init-tools.install

$(STATEDIR)/module-init-tools.install: $(STATEDIR)/module-init-tools.compile
	@$(call targetinfo, $@)
	$(MODULE-INIT-TOOLS_PATH) $(MAKE) -C $(MODULE-INIT-TOOLS_DIR) install
	touch $@

# ----------------------------------------------------------------------------
# Target-Install
# ----------------------------------------------------------------------------

module-init-tools_targetinstall: $(STATEDIR)/module-init-tools.targetinstall

module-init-tools_targetinstall_deps = $(STATEDIR)/module-init-tools.compile

$(STATEDIR)/module-init-tools.targetinstall: $(module-init-tools_targetinstall_deps)
	@$(call targetinfo, $@)
	$(MODULE-INIT-TOOLS_PATH) $(MAKE) -C $(MODULE-INIT-TOOLS_DIR) DESTDIR=$(MODULE-INIT-TOOLS_IPKG_TMP) install
	rm -rf $(MODULE-INIT-TOOLS_IPKG_TMP)/usr/
	mv $(MODULE-INIT-TOOLS_IPKG_TMP)/bin/lsmod $(MODULE-INIT-TOOLS_IPKG_TMP)/sbin/
	rm -rf $(MODULE-INIT-TOOLS_IPKG_TMP)/bin
	mkdir -p $(MODULE-INIT-TOOLS_IPKG_TMP)/etc
	$(INSTALL) -m 644 -D $(MODULE-INIT-TOOLS_DIR)/modprobe.devfs $(MODULE-INIT-TOOLS_IPKG_TMP)/etc/modprobe.devfs
	touch $(MODULE-INIT-TOOLS_IPKG_TMP)/etc/modprobe.conf
	$(CROSSSTRIP) $(MODULE-INIT-TOOLS_IPKG_TMP)/sbin/{lsmod,depmod,insmod,insmod.static,modinfo,modprobe,rmmod}
	mkdir -p $(MODULE-INIT-TOOLS_IPKG_TMP)/CONTROL
	echo "Package: module-init-tools" 							 >$(MODULE-INIT-TOOLS_IPKG_TMP)/CONTROL/control
	echo "Priority: optional" 								>>$(MODULE-INIT-TOOLS_IPKG_TMP)/CONTROL/control
	echo "Section: Kernel" 									>>$(MODULE-INIT-TOOLS_IPKG_TMP)/CONTROL/control
	echo "Maintainer: Alexander Chukov <sash@pdaXrom.org>" 					>>$(MODULE-INIT-TOOLS_IPKG_TMP)/CONTROL/control
	echo "Architecture: $(SHORT_TARGET)" 							>>$(MODULE-INIT-TOOLS_IPKG_TMP)/CONTROL/control
	echo "Version: $(MODULE-INIT-TOOLS_VERSION)-$(MODULE-INIT-TOOLS_VENDOR_VERSION)" 	>>$(MODULE-INIT-TOOLS_IPKG_TMP)/CONTROL/control
	echo "Depends: " 									>>$(MODULE-INIT-TOOLS_IPKG_TMP)/CONTROL/control
	echo "Description: generated with pdaXrom builder"					>>$(MODULE-INIT-TOOLS_IPKG_TMP)/CONTROL/control

	echo "#!/bin/sh"								 >$(MODULE-INIT-TOOLS_IPKG_TMP)/CONTROL/preinst
	echo 'test -f $$PKG_ROOT/sbin/insmod.old   || mv $$PKG_ROOT/sbin/insmod   $$PKG_ROOT/sbin/insmod.old'		>>$(MODULE-INIT-TOOLS_IPKG_TMP)/CONTROL/preinst
	echo 'test -f $$PKG_ROOT/sbin/modprobe.old || mv $$PKG_ROOT/sbin/modprobe $$PKG_ROOT/sbin/modprobe.old'		>>$(MODULE-INIT-TOOLS_IPKG_TMP)/CONTROL/preinst
	echo 'test -f $$PKG_ROOT/sbin/rmmod.old    || mv $$PKG_ROOT/sbin/rmmod    $$PKG_ROOT/sbin/rmmod.old'		>>$(MODULE-INIT-TOOLS_IPKG_TMP)/CONTROL/preinst
	echo 'test -f $$PKG_ROOT/sbin/lsmod.old    || mv $$PKG_ROOT/sbin/lsmod    $$PKG_ROOT/sbin/lsmod.old'		>>$(MODULE-INIT-TOOLS_IPKG_TMP)/CONTROL/preinst

	echo "#!/bin/sh"								 >$(MODULE-INIT-TOOLS_IPKG_TMP)/CONTROL/postrm
	echo 'test -f $$PKG_ROOT/sbin/insmod.old   && mv $$PKG_ROOT/sbin/insmod.old   $$PKG_ROOT/sbin/insmod'		>>$(MODULE-INIT-TOOLS_IPKG_TMP)/CONTROL/postrm
	echo 'test -f $$PKG_ROOT/sbin/modprobe.old && mv $$PKG_ROOT/sbin/modprobe.old $$PKG_ROOT/sbin/modprobe'		>>$(MODULE-INIT-TOOLS_IPKG_TMP)/CONTROL/postrm
	echo 'test -f $$PKG_ROOT/sbin/rmmod.old    && mv $$PKG_ROOT/sbin/rmmod.old    $$PKG_ROOT/sbin/rmmod'		>>$(MODULE-INIT-TOOLS_IPKG_TMP)/CONTROL/postrm
	echo 'test -f $$PKG_ROOT/sbin/lsmod.old    && mv $$PKG_ROOT/sbin/lnsmod.old   $$PKG_ROOT/sbin/lsmod'		>>$(MODULE-INIT-TOOLS_IPKG_TMP)/CONTROL/postrm

	chmod 755 $(MODULE-INIT-TOOLS_IPKG_TMP)/CONTROL/postrm
	chmod 755 $(MODULE-INIT-TOOLS_IPKG_TMP)/CONTROL/preinst

	cd $(FEEDDIR) && $(XMKIPKG) $(MODULE-INIT-TOOLS_IPKG_TMP)
	touch $@

# ----------------------------------------------------------------------------
# Image-Install
# ----------------------------------------------------------------------------

ifdef PTXCONF_MODULE-INIT-TOOLS_INSTALL
ROMPACKAGES += $(STATEDIR)/module-init-tools.imageinstall
endif

module-init-tools_imageinstall_deps = $(STATEDIR)/module-init-tools.targetinstall \
	$(STATEDIR)/virtual-image.install \
	$(STATEDIR)/modutils.imageinstall

$(STATEDIR)/module-init-tools.imageinstall: $(module-init-tools_imageinstall_deps)
	@$(call targetinfo, $@)
	cd $(FEEDDIR) && $(XIPKG) install module-init-tools
	touch $@

# ----------------------------------------------------------------------------
# Clean
# ----------------------------------------------------------------------------

module-init-tools_clean:
	rm -rf $(STATEDIR)/module-init-tools.*
	rm -rf $(MODULE-INIT-TOOLS_DIR)

# vim: syntax=make
