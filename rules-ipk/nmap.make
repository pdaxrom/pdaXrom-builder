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
ifdef PTXCONF_NMAP
PACKAGES += nmap
endif

#
# Paths and names
#
NMAP_VENDOR_VERSION	= 1
NMAP_VERSION		= 3.80
NMAP			= nmap-$(NMAP_VERSION)
NMAP_SUFFIX		= tar.bz2
NMAP_URL		= http://download.insecure.org/nmap/dist/$(NMAP).$(NMAP_SUFFIX)
NMAP_SOURCE		= $(SRCDIR)/$(NMAP).$(NMAP_SUFFIX)
NMAP_DIR		= $(BUILDDIR)/$(NMAP)
NMAP_IPKG_TMP		= $(NMAP_DIR)/ipkg_tmp

# ----------------------------------------------------------------------------
# Get
# ----------------------------------------------------------------------------

nmap_get: $(STATEDIR)/nmap.get

nmap_get_deps = $(NMAP_SOURCE)

$(STATEDIR)/nmap.get: $(nmap_get_deps)
	@$(call targetinfo, $@)
	@$(call get_patches, $(NMAP))
	touch $@

$(NMAP_SOURCE):
	@$(call targetinfo, $@)
	@$(call get, $(NMAP_URL))

# ----------------------------------------------------------------------------
# Extract
# ----------------------------------------------------------------------------

nmap_extract: $(STATEDIR)/nmap.extract

nmap_extract_deps = $(STATEDIR)/nmap.get

$(STATEDIR)/nmap.extract: $(nmap_extract_deps)
	@$(call targetinfo, $@)
	@$(call clean, $(NMAP_DIR))
	@$(call extract, $(NMAP_SOURCE))
	@$(call patchin, $(NMAP))
	touch $@

# ----------------------------------------------------------------------------
# Prepare
# ----------------------------------------------------------------------------

nmap_prepare: $(STATEDIR)/nmap.prepare

#
# dependencies
#
nmap_prepare_deps = \
	$(STATEDIR)/nmap.extract \
	$(STATEDIR)/openssl.install \
	$(STATEDIR)/pcre.install \
	$(STATEDIR)/gtk1210.install \
	$(STATEDIR)/virtual-xchain.install

NMAP_PATH	=  PATH=$(CROSS_PATH)
NMAP_ENV 	=  $(CROSS_ENV)
#NMAP_ENV	+=
NMAP_ENV	+= PKG_CONFIG_PATH=$(CROSS_LIB_DIR)/lib/pkgconfig
#ifdef PTXCONF_XFREE430
#NMAP_ENV	+= LDFLAGS=-Wl,-rpath-link,$(CROSS_LIB_DIR)/X11R6/lib
#endif

#
# autoconf
#
NMAP_AUTOCONF = \
	--build=$(GNU_HOST) \
	--host=$(PTXCONF_GNU_TARGET) \
	--prefix=/usr \
	--disable-debug \
	--sysconfdir=/etc \
	--with-pcap=linux \
	--with-openssl=$(CROSS_LIB_DIR) \
	--with-libpcre=$(CROSS_LIB_DIR)

ifdef PTXCONF_XFREE430
NMAP_AUTOCONF += --x-includes=$(CROSS_LIB_DIR)/include
NMAP_AUTOCONF += --x-libraries=$(CROSS_LIB_DIR)/lib
endif

$(STATEDIR)/nmap.prepare: $(nmap_prepare_deps)
	@$(call targetinfo, $@)
	@$(call clean, $(NMAP_DIR)/config.cache)
	cd $(NMAP_DIR) && \
		$(NMAP_PATH) $(NMAP_ENV) \
		ac_cv_linux_vers=2 \
		./configure $(NMAP_AUTOCONF)
	touch $@

# ----------------------------------------------------------------------------
# Compile
# ----------------------------------------------------------------------------

nmap_compile: $(STATEDIR)/nmap.compile

nmap_compile_deps = $(STATEDIR)/nmap.prepare

$(STATEDIR)/nmap.compile: $(nmap_compile_deps)
	@$(call targetinfo, $@)
	$(NMAP_PATH) $(MAKE) -C $(NMAP_DIR)
	touch $@

# ----------------------------------------------------------------------------
# Install
# ----------------------------------------------------------------------------

nmap_install: $(STATEDIR)/nmap.install

$(STATEDIR)/nmap.install: $(STATEDIR)/nmap.compile
	@$(call targetinfo, $@)
	touch $@

# ----------------------------------------------------------------------------
# Target-Install
# ----------------------------------------------------------------------------

nmap_targetinstall: $(STATEDIR)/nmap.targetinstall

nmap_targetinstall_deps = $(STATEDIR)/nmap.compile \
	$(STATEDIR)/openssl.targetinstall \
	$(STATEDIR)/pcre.targetinstall

$(STATEDIR)/nmap.targetinstall: $(nmap_targetinstall_deps)
	@$(call targetinfo, $@)

	rm -rf $(NMAP_IPKG_TMP)
	$(NMAP_PATH) $(MAKE) -C $(NMAP_DIR) DESTDIR=$(NMAP_IPKG_TMP) install
	$(CROSSSTRIP) $(NMAP_IPKG_TMP)/usr/bin/{nmap,nmapfe}
	$(INSTALL) -D -m 644 $(TOPDIR)/config/pics/icon-network.png $(NMAP_IPKG_TMP)/usr/share/pixmaps/icon-network.png
	rm -rf $(NMAP_IPKG_TMP)/usr/man
	rm -rf $(NMAP_IPKG_TMP)/usr/bin/{nmapfe,xnmap}
	rm -rf $(NMAP_IPKG_TMP)/usr/share/{applications,pixmaps}
	mkdir -p $(NMAP_IPKG_TMP)/CONTROL
	echo "Package: nmap" 								 >$(NMAP_IPKG_TMP)/CONTROL/control
	echo "Priority: optional" 							>>$(NMAP_IPKG_TMP)/CONTROL/control
	echo "Section: Network" 							>>$(NMAP_IPKG_TMP)/CONTROL/control
	echo "Maintainer: Alexander Chukov <sash@pdaXrom.org>" 				>>$(NMAP_IPKG_TMP)/CONTROL/control
	echo "Architecture: $(SHORT_TARGET)" 						>>$(NMAP_IPKG_TMP)/CONTROL/control
	echo "Version: $(NMAP_VERSION)-$(NMAP_VENDOR_VERSION)" 				>>$(NMAP_IPKG_TMP)/CONTROL/control
	echo "Depends: openssl, pcre" 							>>$(NMAP_IPKG_TMP)/CONTROL/control
	echo "Description: Nmap ("Network Mapper") is a free open source utility for network exploration or security auditing."	>>$(NMAP_IPKG_TMP)/CONTROL/control
	cd $(FEEDDIR) && $(XMKIPKG) $(NMAP_IPKG_TMP)
	
	rm -rf $(NMAP_IPKG_TMP)
	$(NMAP_PATH) $(MAKE) -C $(NMAP_DIR) DESTDIR=$(NMAP_IPKG_TMP) install
	$(CROSSSTRIP) $(NMAP_IPKG_TMP)/usr/bin/{nmap,nmapfe}
	$(INSTALL) -D -m 644 $(TOPDIR)/config/pics/icon-network.png $(NMAP_IPKG_TMP)/usr/share/pixmaps/icon-network.png
	rm -rf $(NMAP_IPKG_TMP)/usr/man
	rm -rf $(NMAP_IPKG_TMP)/usr/bin/nmap
	rm -rf $(NMAP_IPKG_TMP)/usr/share/nmap
	mkdir -p $(NMAP_IPKG_TMP)/CONTROL
	echo "Package: nmapfe" 								 >$(NMAP_IPKG_TMP)/CONTROL/control
	echo "Priority: optional" 							>>$(NMAP_IPKG_TMP)/CONTROL/control
	echo "Section: X11" 								>>$(NMAP_IPKG_TMP)/CONTROL/control
	echo "Maintainer: Alexander Chukov <sash@pdaXrom.org>" 				>>$(NMAP_IPKG_TMP)/CONTROL/control
	echo "Architecture: $(SHORT_TARGET)" 						>>$(NMAP_IPKG_TMP)/CONTROL/control
	echo "Version: $(NMAP_VERSION)-$(NMAP_VENDOR_VERSION)" 				>>$(NMAP_IPKG_TMP)/CONTROL/control
	echo "Depends: gtk, nmap" 							>>$(NMAP_IPKG_TMP)/CONTROL/control
	echo "Description: Nmap Gtk frontend."						>>$(NMAP_IPKG_TMP)/CONTROL/control
	cd $(FEEDDIR) && $(XMKIPKG) $(NMAP_IPKG_TMP)

	touch $@

# ----------------------------------------------------------------------------
# Image-Install
# ----------------------------------------------------------------------------

ifdef PTXCONF_NMAP_INSTALL
ROMPACKAGES += $(STATEDIR)/nmap.imageinstall
endif

nmap_imageinstall_deps = $(STATEDIR)/nmap.targetinstall \
	$(STATEDIR)/virtual-image.install

$(STATEDIR)/nmap.imageinstall: $(nmap_imageinstall_deps)
	@$(call targetinfo, $@)
	cd $(FEEDDIR) && $(XIPKG) install nmap
ifdef PTXCONF_NMAP_INSTALL_NMAPFE
	cd $(FEEDDIR) && $(XIPKG) install nmapfe
endif
	touch $@

# ----------------------------------------------------------------------------
# Clean
# ----------------------------------------------------------------------------

nmap_clean:
	rm -rf $(STATEDIR)/nmap.*
	rm -rf $(NMAP_DIR)

# vim: syntax=make
