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
ifdef PTXCONF_KISMET
PACKAGES += kismet
endif

#
# Paths and names
#
KISMET_VERSION		= 2004-04-R1
KISMET			= kismet-$(KISMET_VERSION)
KISMET_SUFFIX		= tar.gz
KISMET_URL		= http://www.kismetwireless.net/code/$(KISMET).$(KISMET_SUFFIX)
KISMET_SOURCE		= $(SRCDIR)/$(KISMET).$(KISMET_SUFFIX)
KISMET_DIR		= $(BUILDDIR)/$(KISMET)
KISMET_IPKG_TMP		= $(KISMET_DIR)/ipkg_tmp

# ----------------------------------------------------------------------------
# Get
# ----------------------------------------------------------------------------

kismet_get: $(STATEDIR)/kismet.get

kismet_get_deps = $(KISMET_SOURCE)

$(STATEDIR)/kismet.get: $(kismet_get_deps)
	@$(call targetinfo, $@)
	@$(call get_patches, $(KISMET))
	touch $@

$(KISMET_SOURCE):
	@$(call targetinfo, $@)
	@$(call get, $(KISMET_URL))

# ----------------------------------------------------------------------------
# Extract
# ----------------------------------------------------------------------------

kismet_extract: $(STATEDIR)/kismet.extract

kismet_extract_deps = $(STATEDIR)/kismet.get

$(STATEDIR)/kismet.extract: $(kismet_extract_deps)
	@$(call targetinfo, $@)
	@$(call clean, $(KISMET_DIR))
	@$(call extract, $(KISMET_SOURCE))
	@$(call patchin, $(KISMET))
	touch $@

# ----------------------------------------------------------------------------
# Prepare
# ----------------------------------------------------------------------------

kismet_prepare: $(STATEDIR)/kismet.prepare

#
# dependencies
#
kismet_prepare_deps = \
	$(STATEDIR)/kismet.extract \
	$(STATEDIR)/virtual-xchain.install

KISMET_PATH	=  PATH=$(CROSS_PATH)
KISMET_ENV 	=  $(CROSS_ENV)
KISMET_ENV	+= ac_cv_linux_vers=2
KISMET_ENV	+= PKG_CONFIG_PATH=$(CROSS_LIB_DIR)/lib/pkgconfig:$(CROSS_LIB_DIR)/lib/pkgconfig
#ifdef PTXCONF_XFREE430
#KISMET_ENV	+= LDFLAGS="-Wl,-rpath-link,$(CROSS_LIB_DIR)/lib -L$(CROSS_LIB_DIR)/lib"
#endif

#
# autoconf
#
KISMET_AUTOCONF = \
	--build=$(GNU_HOST) \
	--host=$(PTXCONF_GNU_TARGET) \
	--prefix=/usr \
	--with-pcap=linux

ifdef PTXCONF_XFREE430
KISMET_AUTOCONF += --x-includes=$(CROSS_LIB_DIR)/include
KISMET_AUTOCONF += --x-libraries=$(CROSS_LIB_DIR)/lib
endif

$(STATEDIR)/kismet.prepare: $(kismet_prepare_deps)
	@$(call targetinfo, $@)
	@$(call clean, $(KISMET_DIR)/config.cache)
	cd $(KISMET_DIR) && \
		$(KISMET_PATH) $(KISMET_ENV) \
		./configure $(KISMET_AUTOCONF)
	touch $@

# ----------------------------------------------------------------------------
# Compile
# ----------------------------------------------------------------------------

kismet_compile: $(STATEDIR)/kismet.compile

kismet_compile_deps = $(STATEDIR)/kismet.prepare

$(STATEDIR)/kismet.compile: $(kismet_compile_deps)
	@$(call targetinfo, $@)
	$(KISMET_PATH) $(MAKE) -C $(KISMET_DIR)
	touch $@

# ----------------------------------------------------------------------------
# Install
# ----------------------------------------------------------------------------

kismet_install: $(STATEDIR)/kismet.install

$(STATEDIR)/kismet.install: $(STATEDIR)/kismet.compile
	@$(call targetinfo, $@)
	###$(KISMET_PATH) $(MAKE) -C $(KISMET_DIR) install
	touch $@

# ----------------------------------------------------------------------------
# Target-Install
# ----------------------------------------------------------------------------

kismet_targetinstall: $(STATEDIR)/kismet.targetinstall

kismet_targetinstall_deps = $(STATEDIR)/kismet.compile

$(STATEDIR)/kismet.targetinstall: $(kismet_targetinstall_deps)
	@$(call targetinfo, $@)
	$(KISMET_PATH) $(MAKE) -C $(KISMET_DIR) DESTDIR=$(KISMET_IPKG_TMP) install
	$(CROSSSTRIP) $(KISMET_IPKG_TMP)/usr/bin/kismet_client
	$(CROSSSTRIP) $(KISMET_IPKG_TMP)/usr/bin/kismet_drone
	$(CROSSSTRIP) $(KISMET_IPKG_TMP)/usr/bin/kismet_server
	mkdir -p $(KISMET_IPKG_TMP)/CONTROL
	echo "Package: kismet" 				>$(KISMET_IPKG_TMP)/CONTROL/control
	echo "Priority: optional" 			>>$(KISMET_IPKG_TMP)/CONTROL/control
	echo "Section: extras"	 			>>$(KISMET_IPKG_TMP)/CONTROL/control
	echo "Maintainer: Mike Kershaw <dragorn@nerv-un.net>" >>$(KISMET_IPKG_TMP)/CONTROL/control
	echo "Architecture: $(SHORT_TARGET)" 		>>$(KISMET_IPKG_TMP)/CONTROL/control
	echo "Version: 2.6.0" 				>>$(KISMET_IPKG_TMP)/CONTROL/control
	echo "Depends: " 				>>$(KISMET_IPKG_TMP)/CONTROL/control
	echo "Description:  802.11b network sniffer and analyser">>$(KISMET_IPKG_TMP)/CONTROL/control
	cd $(FEEDDIR) && $(XMKIPKG) $(KISMET_IPKG_TMP)
	touch $@

# ----------------------------------------------------------------------------
# Image-Install
# ----------------------------------------------------------------------------

ifdef PTXCONF_KISMET_INSTALL
ROMPACKAGES += $(STATEDIR)/kismet.imageinstall
endif

kismet_imageinstall_deps = $(STATEDIR)/kismet.targetinstall \
	$(STATEDIR)/virtual-image.install

$(STATEDIR)/kismet.imageinstall: $(kismet_imageinstall_deps)
	@$(call targetinfo, $@)
	cd $(FEEDDIR) && $(XIPKG) install kismet
	touch $@

# ----------------------------------------------------------------------------
# Clean
# ----------------------------------------------------------------------------

kismet_clean:
	rm -rf $(STATEDIR)/kismet.*
	rm -rf $(KISMET_DIR)

# vim: syntax=make
