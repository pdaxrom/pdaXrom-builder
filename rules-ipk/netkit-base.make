# -*-makefile-*-
# $Id: template,v 1.10 2003/10/26 21:59:07 mkl Exp $
#
# Copyright (C) 2003 by Alexander Chukov
#          
# See CREDITS for details about who has contributed to this project.
#
# For further information about the PTXdist project and license conditions
# see the README file.
#

#
# We provide this package
#
ifdef PTXCONF_NETKIT-BASE
PACKAGES += netkit-base
endif

#
# Paths and names
#
NETKIT-BASE_VERSION	= 0.17
NETKIT-BASE		= netkit-base-$(NETKIT-BASE_VERSION)
NETKIT-BASE_SUFFIX	= tar.gz
NETKIT-BASE_URL		= ftp://ftp.uk.linux.org/pub/linux/Networking/netkit//$(NETKIT-BASE).$(NETKIT-BASE_SUFFIX)
NETKIT-BASE_SOURCE	= $(SRCDIR)/$(NETKIT-BASE).$(NETKIT-BASE_SUFFIX)
NETKIT-BASE_DIR		= $(BUILDDIR)/$(NETKIT-BASE)

# ----------------------------------------------------------------------------
# Get
# ----------------------------------------------------------------------------

netkit-base_get: $(STATEDIR)/netkit-base.get

netkit-base_get_deps = $(NETKIT-BASE_SOURCE)

$(STATEDIR)/netkit-base.get: $(netkit-base_get_deps)
	@$(call targetinfo, $@)
	@$(call get_patches, $(NETKIT-BASE))
	touch $@

$(NETKIT-BASE_SOURCE):
	@$(call targetinfo, $@)
	@$(call get, $(NETKIT-BASE_URL))

# ----------------------------------------------------------------------------
# Extract
# ----------------------------------------------------------------------------

netkit-base_extract: $(STATEDIR)/netkit-base.extract

netkit-base_extract_deps = $(STATEDIR)/netkit-base.get

$(STATEDIR)/netkit-base.extract: $(netkit-base_extract_deps)
	@$(call targetinfo, $@)
	@$(call clean, $(NETKIT-BASE_DIR))
	@$(call extract, $(NETKIT-BASE_SOURCE))
	@$(call patchin, $(NETKIT-BASE))
	touch $@

# ----------------------------------------------------------------------------
# Prepare
# ----------------------------------------------------------------------------

netkit-base_prepare: $(STATEDIR)/netkit-base.prepare

#
# dependencies
#
netkit-base_prepare_deps = \
	$(STATEDIR)/netkit-base.extract \
	$(STATEDIR)/virtual-xchain.install

NETKIT-BASE_PATH	=  PATH=$(CROSS_PATH)
NETKIT-BASE_ENV 	=  $(CROSS_ENV)
#NETKIT-BASE_ENV	+=

#
# autoconf
#
NETKIT-BASE_AUTOCONF = \
	--build=$(GNU_HOST) \
	--host=$(PTXCONF_GNU_TARGET) \
	--prefix=/usr

$(STATEDIR)/netkit-base.prepare: $(netkit-base_prepare_deps)
	@$(call targetinfo, $@)
	touch $@

# ----------------------------------------------------------------------------
# Compile
# ----------------------------------------------------------------------------

netkit-base_compile: $(STATEDIR)/netkit-base.compile

netkit-base_compile_deps = $(STATEDIR)/netkit-base.prepare

$(STATEDIR)/netkit-base.compile: $(netkit-base_compile_deps)
	@$(call targetinfo, $@)
	$(NETKIT-BASE_PATH) $(MAKE) -C $(NETKIT-BASE_DIR) CC=$(PTXCONF_GNU_TARGET)-gcc
	touch $@

# ----------------------------------------------------------------------------
# Install
# ----------------------------------------------------------------------------

netkit-base_install: $(STATEDIR)/netkit-base.install

$(STATEDIR)/netkit-base.install: $(STATEDIR)/netkit-base.compile
	@$(call targetinfo, $@)
	touch $@

# ----------------------------------------------------------------------------
# Target-Install
# ----------------------------------------------------------------------------

netkit-base_targetinstall: $(STATEDIR)/netkit-base.targetinstall

netkit-base_targetinstall_deps = $(STATEDIR)/netkit-base.compile

$(STATEDIR)/netkit-base.targetinstall: $(netkit-base_targetinstall_deps)
	@$(call targetinfo, $@)
ifdef	PTXCONF_NETKIT-BASE-INETD
	$(INSTALL) -m 755 -D $(NETKIT-BASE_DIR)/etc.sample/rc.inet $(NETKIT-BASE_DIR)/ipkg/etc/rc.d/init.d/inet
	$(INSTALL) -m 755 -D $(NETKIT-BASE_DIR)/inetd/inetd $(NETKIT-BASE_DIR)/ipkg/usr/sbin/inetd
	$(CROSSSTRIP) -R .note -R .comment $(NETKIT-BASE_DIR)/ipkg/usr/sbin/inetd
	install -d $(NETKIT-BASE_DIR)/ipkg/etc/rc.d/rc0.d
	install -d $(NETKIT-BASE_DIR)/ipkg/etc/rc.d/rc1.d
	install -d $(NETKIT-BASE_DIR)/ipkg/etc/rc.d/rc2.d
	install -d $(NETKIT-BASE_DIR)/ipkg/etc/rc.d/rc3.d
	install -d $(NETKIT-BASE_DIR)/ipkg/etc/rc.d/rc4.d
	install -d $(NETKIT-BASE_DIR)/ipkg/etc/rc.d/rc5.d
	install -d $(NETKIT-BASE_DIR)/ipkg/etc/rc.d/rc6.d
	cd $(NETKIT-BASE_DIR)/ipkg/etc/rc.d/rc0.d && ln -sf ../init.d/inet K85inet
	cd $(NETKIT-BASE_DIR)/ipkg/etc/rc.d/rc1.d && ln -sf ../init.d/inet K85inet
	cd $(NETKIT-BASE_DIR)/ipkg/etc/rc.d/rc3.d && ln -sf ../init.d/inet S15inet
	cd $(NETKIT-BASE_DIR)/ipkg/etc/rc.d/rc4.d && ln -sf ../init.d/inet S15inet
	cd $(NETKIT-BASE_DIR)/ipkg/etc/rc.d/rc5.d && ln -sf ../init.d/inet S15inet
	cd $(NETKIT-BASE_DIR)/ipkg/etc/rc.d/rc6.d && ln -sf ../init.d/inet K85inet
endif
ifdef	PTXCONF_NETKIT-BASE-PING
	$(INSTALL) -m 755 -D $(NETKIT-BASE_DIR)/ping/ping $(NETKIT-BASE_DIR)/ipkg/bin/ping
	$(CROSSSTRIP) -R .note -R .comment $(NETKIT-BASE_DIR)/ipkg/bin/ping
endif
	mkdir -p $(NETKIT-BASE_DIR)/ipkg/CONTROL
	echo "Package: netkit-base" 						 >$(NETKIT-BASE_DIR)/ipkg/CONTROL/control
	echo "Priority: optional" 						>>$(NETKIT-BASE_DIR)/ipkg/CONTROL/control
	echo "Section: Network" 						>>$(NETKIT-BASE_DIR)/ipkg/CONTROL/control
	echo "Maintainer: Alexander Chukov <sash@pdaXrom.org>" 			>>$(NETKIT-BASE_DIR)/ipkg/CONTROL/control
	echo "Architecture: $(SHORT_TARGET)" 					>>$(NETKIT-BASE_DIR)/ipkg/CONTROL/control
	echo "Version: $(NETKIT-BASE_VERSION)" 					>>$(NETKIT-BASE_DIR)/ipkg/CONTROL/control
	echo "Depends: " 							>>$(NETKIT-BASE_DIR)/ipkg/CONTROL/control
	echo "Description: some network apps"					>>$(NETKIT-BASE_DIR)/ipkg/CONTROL/control
	cd $(FEEDDIR) && $(XMKIPKG) $(NETKIT-BASE_DIR)/ipkg
	touch $@

# ----------------------------------------------------------------------------
# Image-Install
# ----------------------------------------------------------------------------

ifdef PTXCONF_NETKIT-BASE_INSTALL
ROMPACKAGES += $(STATEDIR)/netkit-base.imageinstall
endif

netkit-base_imageinstall_deps = $(STATEDIR)/netkit-base.targetinstall \
	$(STATEDIR)/virtual-image.install

$(STATEDIR)/netkit-base.imageinstall: $(netkit-base_imageinstall_deps)
	@$(call targetinfo, $@)
	cd $(FEEDDIR) && $(XIPKG) install netkit-base
	touch $@

# ----------------------------------------------------------------------------
# Clean
# ----------------------------------------------------------------------------

netkit-base_clean:
	rm -rf $(STATEDIR)/netkit-base.*
	rm -rf $(NETKIT-BASE_DIR)

# vim: syntax=make
