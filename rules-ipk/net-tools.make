# -*-makefile-*-
# $Id: template,v 1.10 2004/01/24 15:50:34 mkl Exp $
#
# Copyright (C) 2004 by Alexander Chukov <sash@cacko.biz>
#          
# See CREDITS for details about who has contributed to this project.
#
# For further information about the PTXdist project and license conditions
# see the README file.
#

#
# We provide this package
#
ifdef PTXCONF_NET-TOOLS
PACKAGES += net-tools
endif

#
# Paths and names
#
NET-TOOLS_VERSION	= 1.60
NET-TOOLS		= net-tools-$(NET-TOOLS_VERSION)
NET-TOOLS_SUFFIX	= tar.bz2
NET-TOOLS_URL		= http://www.tazenda.demon.co.uk/phil/net-tools//$(NET-TOOLS).$(NET-TOOLS_SUFFIX)
NET-TOOLS_SOURCE	= $(SRCDIR)/$(NET-TOOLS).$(NET-TOOLS_SUFFIX)
NET-TOOLS_DIR		= $(BUILDDIR)/$(NET-TOOLS)

# ----------------------------------------------------------------------------
# Get
# ----------------------------------------------------------------------------

net-tools_get: $(STATEDIR)/net-tools.get

net-tools_get_deps = $(NET-TOOLS_SOURCE)

$(STATEDIR)/net-tools.get: $(net-tools_get_deps)
	@$(call targetinfo, $@)
	@$(call get_patches, $(NET-TOOLS))
	touch $@

$(NET-TOOLS_SOURCE):
	@$(call targetinfo, $@)
	@$(call get, $(NET-TOOLS_URL))

# ----------------------------------------------------------------------------
# Extract
# ----------------------------------------------------------------------------

net-tools_extract: $(STATEDIR)/net-tools.extract

net-tools_extract_deps = $(STATEDIR)/net-tools.get

$(STATEDIR)/net-tools.extract: $(net-tools_extract_deps)
	@$(call targetinfo, $@)
	@$(call clean, $(NET-TOOLS_DIR))
	@$(call extract, $(NET-TOOLS_SOURCE))
	@$(call patchin, $(NET-TOOLS))
	touch $@

# ----------------------------------------------------------------------------
# Prepare
# ----------------------------------------------------------------------------

net-tools_prepare: $(STATEDIR)/net-tools.prepare

#
# dependencies
#
net-tools_prepare_deps = \
	$(STATEDIR)/net-tools.extract \
	$(STATEDIR)/virtual-xchain.install

NET-TOOLS_PATH	=  PATH=$(CROSS_PATH)
NET-TOOLS_ENV 	=  $(CROSS_ENV)
#NET-TOOLS_ENV	+=

#
# autoconf
#
NET-TOOLS_AUTOCONF = \
	--build=$(GNU_HOST) \
	--host=$(PTXCONF_GNU_TARGET) \
	--prefix=$(CROSS_LIB_DIR)

$(STATEDIR)/net-tools.prepare: $(net-tools_prepare_deps)
	@$(call targetinfo, $@)
	@$(call clean, $(NET-TOOLS_DIR)/config.make)
ifdef	PTXCONF_NET-TOOLS_IPMADDR
	echo "HAVE_IP_TOOLS=1" >$(NET-TOOLS_DIR)/config.make
endif
ifdef	PTXCONF_NET-TOOLS_IPTUNNEL
	echo "HAVE_IP_TOOLS=1" >$(NET-TOOLS_DIR)/config.make
endif
ifdef	PTXCONF_NET-TOOLS_MII-TOOL
	echo "HAVE_MII=1"      >>$(NET-TOOLS_DIR)/config.make
endif
	touch $@

# ----------------------------------------------------------------------------
# Compile
# ----------------------------------------------------------------------------

net-tools_compile: $(STATEDIR)/net-tools.compile

net-tools_compile_deps = $(STATEDIR)/net-tools.prepare

$(STATEDIR)/net-tools.compile: $(net-tools_compile_deps)
	@$(call targetinfo, $@)
	$(NET-TOOLS_PATH) $(NET-TOOLS_ENV) $(MAKE) -C $(NET-TOOLS_DIR)
	touch $@

# ----------------------------------------------------------------------------
# Install
# ----------------------------------------------------------------------------

net-tools_install: $(STATEDIR)/net-tools.install

$(STATEDIR)/net-tools.install: $(STATEDIR)/net-tools.compile
	@$(call targetinfo, $@)
	#$(NET-TOOLS_PATH) $(MAKE) -C $(NET-TOOLS_DIR) install
	touch $@

# ----------------------------------------------------------------------------
# Target-Install
# ----------------------------------------------------------------------------

net-tools_targetinstall: $(STATEDIR)/net-tools.targetinstall

net-tools_targetinstall_deps = $(STATEDIR)/net-tools.compile

$(STATEDIR)/net-tools.targetinstall: $(net-tools_targetinstall_deps)
	@$(call targetinfo, $@)
	install -d $(NET-TOOLS_DIR)/ipkg/bin
	install -d $(NET-TOOLS_DIR)/ipkg/sbin
	install -d $(NET-TOOLS_DIR)/ipkg/usr/bin
	install -d $(NET-TOOLS_DIR)/ipkg/usr/sbin
ifdef	PTXCONF_NET-TOOLS_IFCONFIG
	$(INSTALL) -m 755 $(NET-TOOLS_DIR)/ifconfig $(NET-TOOLS_DIR)/ipkg/sbin/
	$(CROSSSTRIP) -R .note -R .comment $(NET-TOOLS_DIR)/ipkg/sbin/ifconfig
endif
ifdef	PTXCONF_NET-TOOLS_ROUTE
	$(INSTALL) -m 755 $(NET-TOOLS_DIR)/route $(NET-TOOLS_DIR)/ipkg/sbin/
	$(CROSSSTRIP) -R .note -R .comment $(NET-TOOLS_DIR)/ipkg/sbin/route
endif
ifdef	PTXCONF_NET-TOOLS_HOSTNAME
	$(INSTALL) -m 755 $(NET-TOOLS_DIR)/hostname $(NET-TOOLS_DIR)/ipkg/bin/
	$(CROSSSTRIP) -R .note -R .comment $(NET-TOOLS_DIR)/ipkg/bin/hostname
	ln -fs hostname $(NET-TOOLS_DIR)/ipkg/bin/dnsdomainname
	ln -fs hostname $(NET-TOOLS_DIR)/ipkg/bin/ypdomainname
	ln -fs hostname $(NET-TOOLS_DIR)/ipkg/bin/nisdomainname
	ln -fs hostname $(NET-TOOLS_DIR)/ipkg/bin/domainname
endif
ifdef	PTXCONF_NET-TOOLS_NETSTAT
	$(INSTALL) -m 755 $(NET-TOOLS_DIR)/netstat $(NET-TOOLS_DIR)/ipkg/bin/
	$(CROSSSTRIP) -R .note -R .comment $(NET-TOOLS_DIR)/ipkg/bin/netstat
endif
ifdef	PTXCONF_NET-TOOLS_SLATTACH
	$(INSTALL) -m 755 $(NET-TOOLS_DIR)/slattach $(NET-TOOLS_DIR)/ipkg/sbin/
	$(CROSSSTRIP) -R .note -R .comment $(NET-TOOLS_DIR)/ipkg/sbin/slattach
endif
ifdef	PTXCONF_NET-TOOLS_PLIPCONFIG
	$(INSTALL) -m 755 $(NET-TOOLS_DIR)/plipconfig $(NET-TOOLS_DIR)/ipkg/sbin/
	$(CROSSSTRIP) -R .note -R .comment $(NET-TOOLS_DIR)/ipkg/sbin/plipconfig
endif
ifdef	PTXCONF_NET-TOOLS_ARP
	$(INSTALL) -m 755 $(NET-TOOLS_DIR)/arp $(NET-TOOLS_DIR)/ipkg/sbin/
	$(CROSSSTRIP) -R .note -R .comment $(NET-TOOLS_DIR)/ipkg/sbin/arp
endif
ifdef	PTXCONF_NET-TOOLS_RARP
	$(INSTALL) -m 755 $(NET-TOOLS_DIR)/rarp $(NET-TOOLS_DIR)/ipkg/sbin/
	$(CROSSSTRIP) -R .note -R .comment $(NET-TOOLS_DIR)/ipkg/sbin/rarp
endif
ifdef	PTXCONF_NET-TOOLS_NAMEIF
	$(INSTALL) -m 755 $(NET-TOOLS_DIR)/nameif $(NET-TOOLS_DIR)/ipkg/sbin/
	$(CROSSSTRIP) -R .note -R .comment $(NET-TOOLS_DIR)/ipkg/sbin/nameif
endif
ifdef	PTXCONF_NET-TOOLS_IPMADDR
	$(INSTALL) -m 755 $(NET-TOOLS_DIR)/ipmaddr $(NET-TOOLS_DIR)/ipkg/sbin/
	$(CROSSSTRIP) -R .note -R .comment $(NET-TOOLS_DIR)/ipkg/sbin/ipmaddr
endif
ifdef	PTXCONF_NET-TOOLS_IPTUNNEL
	$(INSTALL) -m 755 $(NET-TOOLS_DIR)/iptunnel $(NET-TOOLS_DIR)/ipkg/sbin/
	$(CROSSSTRIP) -R .note -R .comment $(NET-TOOLS_DIR)/ipkg/sbin/iptunnel
endif
ifdef	PTXCONF_NET-TOOLS_MII-TOOL
	$(INSTALL) -m 755 $(NET-TOOLS_DIR)/mii-tool $(NET-TOOLS_DIR)/ipkg/sbin/
	$(CROSSSTRIP) -R .note -R .comment $(NET-TOOLS_DIR)/ipkg/sbin/mii-tool
endif
	mkdir -p $(NET-TOOLS_DIR)/ipkg/CONTROL
	echo "Package: net-tools" 						 >$(NET-TOOLS_DIR)/ipkg/CONTROL/control
	echo "Priority: optional" 						>>$(NET-TOOLS_DIR)/ipkg/CONTROL/control
	echo "Section: Network" 						>>$(NET-TOOLS_DIR)/ipkg/CONTROL/control
	echo "Maintainer: Alexander Chukov <sash@pdaXrom.org>" 			>>$(NET-TOOLS_DIR)/ipkg/CONTROL/control
	echo "Architecture: $(SHORT_TARGET)" 					>>$(NET-TOOLS_DIR)/ipkg/CONTROL/control
	echo "Version: $(NET-TOOLS_VERSION)" 					>>$(NET-TOOLS_DIR)/ipkg/CONTROL/control
	echo "Depends: " 							>>$(NET-TOOLS_DIR)/ipkg/CONTROL/control
	echo "Description: Network tools"					>>$(NET-TOOLS_DIR)/ipkg/CONTROL/control
	cd $(FEEDDIR) && $(XMKIPKG) $(NET-TOOLS_DIR)/ipkg
	touch $@

# ----------------------------------------------------------------------------
# Image-Install
# ----------------------------------------------------------------------------

ifdef PTXCONF_NET-TOOLS_INSTALL
ROMPACKAGES += $(STATEDIR)/net-tools.imageinstall
endif

net-tools_imageinstall_deps = $(STATEDIR)/net-tools.targetinstall \
	$(STATEDIR)/virtual-image.install

$(STATEDIR)/net-tools.imageinstall: $(net-tools_imageinstall_deps)
	@$(call targetinfo, $@)
	cd $(FEEDDIR) && $(XIPKG) install net-tools
	touch $@

# ----------------------------------------------------------------------------
# Clean
# ----------------------------------------------------------------------------

net-tools_clean:
	rm -rf $(STATEDIR)/net-tools.*
	rm -rf $(NET-TOOLS_DIR)

# vim: syntax=make
