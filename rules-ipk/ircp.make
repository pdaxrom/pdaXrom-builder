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
ifdef PTXCONF_IRCP
PACKAGES += ircp
endif

#
# Paths and names
#
IRCP_VERSION		= 0.3
IRCP			= ircp-$(IRCP_VERSION)
IRCP_SUFFIX		= tar.gz
IRCP_URL		= http://heanet.dl.sourceforge.net/sourceforge/openobex/$(IRCP).$(IRCP_SUFFIX)
IRCP_SOURCE		= $(SRCDIR)/$(IRCP).$(IRCP_SUFFIX)
IRCP_DIR		= $(BUILDDIR)/$(IRCP)
IRCP_IPKG_TMP		= $(IRCP_DIR)/ipkg_tmp

# ----------------------------------------------------------------------------
# Get
# ----------------------------------------------------------------------------

ircp_get: $(STATEDIR)/ircp.get

ircp_get_deps = $(IRCP_SOURCE)

$(STATEDIR)/ircp.get: $(ircp_get_deps)
	@$(call targetinfo, $@)
	@$(call get_patches, $(IRCP))
	touch $@

$(IRCP_SOURCE):
	@$(call targetinfo, $@)
	@$(call get, $(IRCP_URL))

# ----------------------------------------------------------------------------
# Extract
# ----------------------------------------------------------------------------

ircp_extract: $(STATEDIR)/ircp.extract

ircp_extract_deps = $(STATEDIR)/ircp.get

$(STATEDIR)/ircp.extract: $(ircp_extract_deps)
	@$(call targetinfo, $@)
	@$(call clean, $(IRCP_DIR))
	@$(call extract, $(IRCP_SOURCE))
	@$(call patchin, $(IRCP))
	touch $@

# ----------------------------------------------------------------------------
# Prepare
# ----------------------------------------------------------------------------

ircp_prepare: $(STATEDIR)/ircp.prepare

#
# dependencies
#
ircp_prepare_deps = \
	$(STATEDIR)/ircp.extract \
	$(STATEDIR)/openobex.install \
	$(STATEDIR)/virtual-xchain.install

IRCP_PATH	=  PATH=$(CROSS_PATH)
IRCP_ENV 	=  $(CROSS_ENV)
IRCP_ENV	+= CFLAGS="-O2 -fomit-frame-pointer"
IRCP_ENV	+= PKG_CONFIG_PATH=$(CROSS_LIB_DIR)/lib/pkgconfig:$(CROSS_LIB_DIR)/lib/pkgconfig
#ifdef PTXCONF_XFREE430
#IRCP_ENV	+= LDFLAGS=-Wl,-rpath-link,$(CROSS_LIB_DIR)/lib
#endif

#
# autoconf
#
IRCP_AUTOCONF = \
	--build=$(GNU_HOST) \
	--host=$(PTXCONF_GNU_TARGET) \
	--prefix=/usr \
	--disable-debug

ifdef PTXCONF_XFREE430
IRCP_AUTOCONF += --x-includes=$(CROSS_LIB_DIR)/include
IRCP_AUTOCONF += --x-libraries=$(CROSS_LIB_DIR)/lib
endif

$(STATEDIR)/ircp.prepare: $(ircp_prepare_deps)
	@$(call targetinfo, $@)
	@$(call clean, $(IRCP_DIR)/config.cache)
	cd $(IRCP_DIR) && \
		$(IRCP_PATH) $(IRCP_ENV) \
		./configure $(IRCP_AUTOCONF)
	touch $@

# ----------------------------------------------------------------------------
# Compile
# ----------------------------------------------------------------------------

ircp_compile: $(STATEDIR)/ircp.compile

ircp_compile_deps = $(STATEDIR)/ircp.prepare

$(STATEDIR)/ircp.compile: $(ircp_compile_deps)
	@$(call targetinfo, $@)
	$(IRCP_PATH) $(MAKE) -C $(IRCP_DIR)
	touch $@

# ----------------------------------------------------------------------------
# Install
# ----------------------------------------------------------------------------

ircp_install: $(STATEDIR)/ircp.install

$(STATEDIR)/ircp.install: $(STATEDIR)/ircp.compile
	@$(call targetinfo, $@)
	touch $@

# ----------------------------------------------------------------------------
# Target-Install
# ----------------------------------------------------------------------------

ircp_targetinstall: $(STATEDIR)/ircp.targetinstall

ircp_targetinstall_deps = $(STATEDIR)/ircp.compile \
	$(STATEDIR)/openobex.targetinstall

$(STATEDIR)/ircp.targetinstall: $(ircp_targetinstall_deps)
	@$(call targetinfo, $@)
	$(IRCP_PATH) $(MAKE) -C $(IRCP_DIR) DESTDIR=$(IRCP_IPKG_TMP) install
	$(CROSSSTRIP) $(IRCP_IPKG_TMP)/usr/bin/*
	mkdir -p $(IRCP_IPKG_TMP)/CONTROL
	echo "Package: ircp" 					 >$(IRCP_IPKG_TMP)/CONTROL/control
	echo "Priority: optional" 				>>$(IRCP_IPKG_TMP)/CONTROL/control
	echo "Section: IrDA"	 				>>$(IRCP_IPKG_TMP)/CONTROL/control
	echo "Maintainer: Alexander Chukov <sash@pdaXrom.org>" 	>>$(IRCP_IPKG_TMP)/CONTROL/control
	echo "Architecture: $(SHORT_TARGET)"	 		>>$(IRCP_IPKG_TMP)/CONTROL/control
	echo "Version: $(IRCP_VERSION)" 			>>$(IRCP_IPKG_TMP)/CONTROL/control
	echo "Depends: openobex" 				>>$(IRCP_IPKG_TMP)/CONTROL/control
	echo "Description: ircp is used to "beam" files or whole directories to/from Linux, Windows.">>$(IRCP_IPKG_TMP)/CONTROL/control
	cd $(FEEDDIR) && $(XMKIPKG) $(IRCP_IPKG_TMP)
	touch $@

# ----------------------------------------------------------------------------
# Image-Install
# ----------------------------------------------------------------------------

ifdef PTXCONF_IRCP_INSTALL
ROMPACKAGES += $(STATEDIR)/ircp.imageinstall
endif

ircp_imageinstall_deps = $(STATEDIR)/ircp.targetinstall \
	$(STATEDIR)/virtual-image.install

$(STATEDIR)/ircp.imageinstall: $(ircp_imageinstall_deps)
	@$(call targetinfo, $@)
	cd $(FEEDDIR) && $(XIPKG) install ircp
	touch $@

# ----------------------------------------------------------------------------
# Clean
# ----------------------------------------------------------------------------

ircp_clean:
	rm -rf $(STATEDIR)/ircp.*
	rm -rf $(IRCP_DIR)

# vim: syntax=make
