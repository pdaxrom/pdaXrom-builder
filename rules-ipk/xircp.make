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
ifdef PTXCONF_XIRCP
PACKAGES += xircp
endif

#
# Paths and names
#
XIRCP_VERSION		= 0.1
XIRCP			= xircp-$(XIRCP_VERSION)
XIRCP_SUFFIX		= tar.bz2
XIRCP_URL		= http://www.pdaXrom.org/src/$(XIRCP).$(XIRCP_SUFFIX)
XIRCP_SOURCE		= $(SRCDIR)/$(XIRCP).$(XIRCP_SUFFIX)
XIRCP_DIR		= $(BUILDDIR)/$(XIRCP)
XIRCP_IPKG_TMP		= $(XIRCP_DIR)/ipkg_tmp

# ----------------------------------------------------------------------------
# Get
# ----------------------------------------------------------------------------

xircp_get: $(STATEDIR)/xircp.get

xircp_get_deps = $(XIRCP_SOURCE)

$(STATEDIR)/xircp.get: $(xircp_get_deps)
	@$(call targetinfo, $@)
	@$(call get_patches, $(XIRCP))
	touch $@

$(XIRCP_SOURCE):
	@$(call targetinfo, $@)
	@$(call get, $(XIRCP_URL))

# ----------------------------------------------------------------------------
# Extract
# ----------------------------------------------------------------------------

xircp_extract: $(STATEDIR)/xircp.extract

xircp_extract_deps = $(STATEDIR)/xircp.get

$(STATEDIR)/xircp.extract: $(xircp_extract_deps)
	@$(call targetinfo, $@)
	@$(call clean, $(XIRCP_DIR))
	@$(call extract, $(XIRCP_SOURCE))
	@$(call patchin, $(XIRCP))
	touch $@

# ----------------------------------------------------------------------------
# Prepare
# ----------------------------------------------------------------------------

xircp_prepare: $(STATEDIR)/xircp.prepare

#
# dependencies
#
xircp_prepare_deps = \
	$(STATEDIR)/xircp.extract \
	$(STATEDIR)/gtk22.install \
	$(STATEDIR)/ircp.install \
	$(STATEDIR)/virtual-xchain.install

XIRCP_PATH	=  PATH=$(CROSS_PATH)
XIRCP_ENV 	=  $(CROSS_ENV)
XIRCP_ENV	+= CFLAGS="-O2 -fomit-frame-pointer"
XIRCP_ENV	+= PKG_CONFIG_PATH=$(CROSS_LIB_DIR)/lib/pkgconfig:$(CROSS_LIB_DIR)/lib/pkgconfig
#ifdef PTXCONF_XFREE430
#XIRCP_ENV	+= LDFLAGS=-Wl,-rpath-link,$(CROSS_LIB_DIR)/lib
#endif

#
# autoconf
#
XIRCP_AUTOCONF = \
	--build=$(GNU_HOST) \
	--host=$(PTXCONF_GNU_TARGET) \
	--prefix=/usr

ifdef PTXCONF_XFREE430
XIRCP_AUTOCONF += --x-includes=$(CROSS_LIB_DIR)/include
XIRCP_AUTOCONF += --x-libraries=$(CROSS_LIB_DIR)/lib
endif

$(STATEDIR)/xircp.prepare: $(xircp_prepare_deps)
	@$(call targetinfo, $@)
	@$(call clean, $(XIRCP_DIR)/config.cache)
	ln -sf $(PTXCONF_PREFIX)/share/automake-1.9/install-sh $(XIRCP_DIR)/install-sh
	ln -sf $(PTXCONF_PREFIX)/share/automake-1.9/missing $(XIRCP_DIR)/missing
	ln -sf $(PTXCONF_PREFIX)/share/automake-1.9/depcomp $(XIRCP_DIR)/depcomp
	ln -sf $(PTXCONF_PREFIX)/share/automake-1.9/INSTALL $(XIRCP_DIR)/INSTALL
	ln -sf $(PTXCONF_PREFIX)/share/automake-1.9/COPYING $(XIRCP_DIR)/COPYING
	ln -sf $(PTXCONF_PREFIX)/share/automake-1.9/mkinstalldirs $(XIRCP_DIR)/mkinstalldirs
	cd $(XIRCP_DIR) && \
		$(XIRCP_PATH) $(XIRCP_ENV) \
		./configure $(XIRCP_AUTOCONF)
	touch $@

# ----------------------------------------------------------------------------
# Compile
# ----------------------------------------------------------------------------

xircp_compile: $(STATEDIR)/xircp.compile

xircp_compile_deps = $(STATEDIR)/xircp.prepare

$(STATEDIR)/xircp.compile: $(xircp_compile_deps)
	@$(call targetinfo, $@)
	$(XIRCP_PATH) $(MAKE) -C $(XIRCP_DIR)
	touch $@

# ----------------------------------------------------------------------------
# Install
# ----------------------------------------------------------------------------

xircp_install: $(STATEDIR)/xircp.install

$(STATEDIR)/xircp.install: $(STATEDIR)/xircp.compile
	@$(call targetinfo, $@)
	$(XIRCP_PATH) $(MAKE) -C $(XIRCP_DIR) install
	touch $@

# ----------------------------------------------------------------------------
# Target-Install
# ----------------------------------------------------------------------------

xircp_targetinstall: $(STATEDIR)/xircp.targetinstall

xircp_targetinstall_deps = $(STATEDIR)/xircp.compile \
	$(STATEDIR)/gtk22.targetinstall \
	$(STATEDIR)/ircp.targetinstall

$(STATEDIR)/xircp.targetinstall: $(xircp_targetinstall_deps)
	@$(call targetinfo, $@)
	$(XIRCP_PATH) $(MAKE) -C $(XIRCP_DIR) DESTDIR=$(XIRCP_IPKG_TMP) install
	$(CROSSSTRIP) $(XIRCP_IPKG_TMP)/usr/bin/*
	mkdir -p $(XIRCP_IPKG_TMP)/CONTROL
	echo "Package: xircp" 					 >$(XIRCP_IPKG_TMP)/CONTROL/control
	echo "Priority: optional" 				>>$(XIRCP_IPKG_TMP)/CONTROL/control
	echo "Section: IrDA"	 				>>$(XIRCP_IPKG_TMP)/CONTROL/control
	echo "Maintainer: Anthony Lineberry <omin0us_@hotmail.com>">>$(XIRCP_IPKG_TMP)/CONTROL/control
	echo "Architecture: $(SHORT_TARGET)" 			>>$(XIRCP_IPKG_TMP)/CONTROL/control
	echo "Version: $(XIRCP_VERSION)" 			>>$(XIRCP_IPKG_TMP)/CONTROL/control
	echo "Depends: ircp, gtk2" 				>>$(XIRCP_IPKG_TMP)/CONTROL/control
	echo "Description: Xircp is a GUI frontend to the program ircp. It is used for transfering files via IrDA. ">>$(XIRCP_IPKG_TMP)/CONTROL/control
	cd $(FEEDDIR) && $(XMKIPKG) $(XIRCP_IPKG_TMP)
	touch $@

# ----------------------------------------------------------------------------
# Image-Install
# ----------------------------------------------------------------------------

ifdef PTXCONF_XIRCP_INSTALL
ROMPACKAGES += $(STATEDIR)/xircp.imageinstall
endif

xircp_imageinstall_deps = $(STATEDIR)/xircp.targetinstall \
	$(STATEDIR)/virtual-image.install

$(STATEDIR)/xircp.imageinstall: $(xircp_imageinstall_deps)
	@$(call targetinfo, $@)
	cd $(FEEDDIR) && $(XIPKG) install xircp
	touch $@

# ----------------------------------------------------------------------------
# Clean
# ----------------------------------------------------------------------------

xircp_clean:
	rm -rf $(STATEDIR)/xircp.*
	rm -rf $(XIRCP_DIR)

# vim: syntax=make
