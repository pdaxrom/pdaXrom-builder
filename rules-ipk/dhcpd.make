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
ifdef PTXCONF_DHCPD
PACKAGES += dhcpd
endif

#
# Paths and names
#
DHCPD_VERSION		= 3.0.1
DHCPD			= dhcp-$(DHCPD_VERSION)
DHCPD_SUFFIX		= tar.gz
DHCPD_URL		= ftp://ftp.isc.org/isc/dhcp/$(DHCPD).$(DHCPD_SUFFIX)
DHCPD_SOURCE		= $(SRCDIR)/$(DHCPD).$(DHCPD_SUFFIX)
DHCPD_DIR		= $(BUILDDIR)/$(DHCPD)
DHCPD_IPKG_TMP		= $(DHCPD_DIR)/ipkg_tmp

# ----------------------------------------------------------------------------
# Get
# ----------------------------------------------------------------------------

dhcpd_get: $(STATEDIR)/dhcpd.get

dhcpd_get_deps = $(DHCPD_SOURCE)

$(STATEDIR)/dhcpd.get: $(dhcpd_get_deps)
	@$(call targetinfo, $@)
	@$(call get_patches, $(DHCPD))
	touch $@

$(DHCPD_SOURCE):
	@$(call targetinfo, $@)
	@$(call get, $(DHCPD_URL))

# ----------------------------------------------------------------------------
# Extract
# ----------------------------------------------------------------------------

dhcpd_extract: $(STATEDIR)/dhcpd.extract

dhcpd_extract_deps = $(STATEDIR)/dhcpd.get

$(STATEDIR)/dhcpd.extract: $(dhcpd_extract_deps)
	@$(call targetinfo, $@)
	@$(call clean, $(DHCPD_DIR))
	@$(call extract, $(DHCPD_SOURCE))
	@$(call patchin, $(DHCPD))
	touch $@

# ----------------------------------------------------------------------------
# Prepare
# ----------------------------------------------------------------------------

dhcpd_prepare: $(STATEDIR)/dhcpd.prepare

#
# dependencies
#
dhcpd_prepare_deps = \
	$(STATEDIR)/dhcpd.extract \
	$(STATEDIR)/virtual-xchain.install

DHCPD_PATH	=  PATH=$(CROSS_PATH)
DHCPD_ENV 	=  $(CROSS_ENV)
#DHCPD_ENV	+=
DHCPD_ENV	+= PKG_CONFIG_PATH=$(CROSS_LIB_DIR)/lib/pkgconfig:$(CROSS_LIB_DIR)/lib/pkgconfig
#ifdef PTXCONF_XFREE430
#DHCPD_ENV	+= LDFLAGS=-Wl,-rpath-link,$(CROSS_LIB_DIR)/lib
#endif

#
# autoconf
#
DHCPD_AUTOCONF = \
	--build=$(GNU_HOST) \
	--host=$(PTXCONF_GNU_TARGET) \
	--prefix=/usr

ifdef PTXCONF_XFREE430
DHCPD_AUTOCONF += --x-includes=$(CROSS_LIB_DIR)/include
DHCPD_AUTOCONF += --x-libraries=$(CROSS_LIB_DIR)/lib
endif

$(STATEDIR)/dhcpd.prepare: $(dhcpd_prepare_deps)
	@$(call targetinfo, $@)
	@$(call clean, $(DHCPD_DIR)/config.cache)
	cd $(DHCPD_DIR) && \
		$(DHCPD_PATH) $(DHCPD_ENV) \
		./configure
		###$(DHCPD_AUTOCONF)
	touch $@

# ----------------------------------------------------------------------------
# Compile
# ----------------------------------------------------------------------------

dhcpd_compile: $(STATEDIR)/dhcpd.compile

dhcpd_compile_deps = $(STATEDIR)/dhcpd.prepare

$(STATEDIR)/dhcpd.compile: $(dhcpd_compile_deps)
	@$(call targetinfo, $@)
	$(DHCPD_PATH) $(DHCPD_ENV) $(MAKE) -C $(DHCPD_DIR) \
	    PREDEFINES='-D_PATH_DHCPD_DB=\"/var/lib/dhcp/dhcpd.leases\" \
    	    -D_PATH_DHCLIENT_DB=\"/var/lib/dhcp/dhclient.leases\" \
    	    -D_PATH_DHCLIENT_SCRIPT=\"/sbin/dhclient-script\" \
    	    -D_PATH_DHCPD_CONF=\"/etc/dhcp/dhcpd.conf\" \
    	    -D_PATH_DHCLIENT_CONF=\"/etc/dhcp/dhclient.conf\"'
	touch $@

# ----------------------------------------------------------------------------
# Install
# ----------------------------------------------------------------------------

dhcpd_install: $(STATEDIR)/dhcpd.install

$(STATEDIR)/dhcpd.install: $(STATEDIR)/dhcpd.compile
	@$(call targetinfo, $@)
	touch $@

# ----------------------------------------------------------------------------
# Target-Install
# ----------------------------------------------------------------------------

dhcpd_targetinstall: $(STATEDIR)/dhcpd.targetinstall

dhcpd_targetinstall_deps = $(STATEDIR)/dhcpd.compile

$(STATEDIR)/dhcpd.targetinstall: $(dhcpd_targetinstall_deps)
	@$(call targetinfo, $@)
	$(DHCPD_PATH) $(MAKE) -C $(DHCPD_DIR) DESTDIR=$(DHCPD_IPKG_TMP) install
	rm -rf $(DHCPD_IPKG_TMP)/sbin
	rm -rf $(DHCPD_IPKG_TMP)/usr/local
	rm -rf $(DHCPD_IPKG_TMP)/usr/man
	cp -a $(TOPDIR)/config/pics/dhcp/* $(DHCPD_IPKG_TMP)/
	mkdir -p $(DHCPD_IPKG_TMP)/var/lib/dhcp/
	touch $(DHCPD_IPKG_TMP)/var/lib/dhcp/dhcpd.leases
	for FILE in `find $(DHCPD_IPKG_TMP)/usr -type f`; do		\
	    ZZZ=`file $$FILE | grep 'ELF 32-bit'`;			\
	    if [  "$$ZZZ" != "" ]; then					\
		$(CROSSSTRIP) $$FILE;					\
	    fi;								\
	done
	mkdir -p $(DHCPD_IPKG_TMP)/CONTROL
	echo "Package: dhcpd" 								>$(DHCPD_IPKG_TMP)/CONTROL/control
	echo "Priority: optional" 							>>$(DHCPD_IPKG_TMP)/CONTROL/control
	echo "Section: Internet" 							>>$(DHCPD_IPKG_TMP)/CONTROL/control
	echo "Maintainer: Alexander Chukov <sash@pdaXrom.org>" 				>>$(DHCPD_IPKG_TMP)/CONTROL/control
	echo "Architecture: $(SHORT_TARGET)" 						>>$(DHCPD_IPKG_TMP)/CONTROL/control
	echo "Version: $(DHCPD_VERSION)" 						>>$(DHCPD_IPKG_TMP)/CONTROL/control
	echo "Depends: " 								>>$(DHCPD_IPKG_TMP)/CONTROL/control
	echo "Description: Internet Software Consortium DHCP package"			>>$(DHCPD_IPKG_TMP)/CONTROL/control
	cd $(FEEDDIR) && $(XMKIPKG) $(DHCPD_IPKG_TMP)
	touch $@

# ----------------------------------------------------------------------------
# Image-Install
# ----------------------------------------------------------------------------

ifdef PTXCONF_DHCPD_INSTALL
ROMPACKAGES += $(STATEDIR)/dhcpd.imageinstall
endif

dhcpd_imageinstall_deps = $(STATEDIR)/dhcpd.targetinstall \
	$(STATEDIR)/virtual-image.install

$(STATEDIR)/dhcpd.imageinstall: $(dhcpd_imageinstall_deps)
	@$(call targetinfo, $@)
	cd $(FEEDDIR) && $(XIPKG) install dhcpd
	touch $@

# ----------------------------------------------------------------------------
# Clean
# ----------------------------------------------------------------------------

dhcpd_clean:
	rm -rf $(STATEDIR)/dhcpd.*
	rm -rf $(DHCPD_DIR)

# vim: syntax=make
