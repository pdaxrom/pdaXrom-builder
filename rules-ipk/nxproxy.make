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
ifdef PTXCONF_NXPROXY
PACKAGES += nxproxy
endif

#
# Paths and names
#
NXPROXY_VERSION		= 1.3.2-1
NXPROXY			= nxproxy-$(NXPROXY_VERSION)
NXPROXY_SUFFIX		= tar.gz
NXPROXY_URL		= http://www.nomachine.com/source/$(NXPROXY).$(NXPROXY_SUFFIX)
NXPROXY_SOURCE		= $(SRCDIR)/$(NXPROXY).$(NXPROXY_SUFFIX)
NXPROXY_DIR		= $(BUILDDIR)/nxproxy
NXPROXY_IPKG_TMP	= $(NXPROXY_DIR)/ipkg_tmp

# ----------------------------------------------------------------------------
# Get
# ----------------------------------------------------------------------------

nxproxy_get: $(STATEDIR)/nxproxy.get

nxproxy_get_deps = $(NXPROXY_SOURCE)

$(STATEDIR)/nxproxy.get: $(nxproxy_get_deps)
	@$(call targetinfo, $@)
	@$(call get_patches, $(NXPROXY))
	touch $@

$(NXPROXY_SOURCE):
	@$(call targetinfo, $@)
	@$(call get, $(NXPROXY_URL))

# ----------------------------------------------------------------------------
# Extract
# ----------------------------------------------------------------------------

nxproxy_extract: $(STATEDIR)/nxproxy.extract

nxproxy_extract_deps = $(STATEDIR)/nxproxy.get

$(STATEDIR)/nxproxy.extract: $(nxproxy_extract_deps)
	@$(call targetinfo, $@)
	@$(call clean, $(NXPROXY_DIR))
	@$(call extract, $(NXPROXY_SOURCE))
	@$(call patchin, $(NXPROXY), $(NXPROXY_DIR))
	touch $@

# ----------------------------------------------------------------------------
# Prepare
# ----------------------------------------------------------------------------

nxproxy_prepare: $(STATEDIR)/nxproxy.prepare

#
# dependencies
#
nxproxy_prepare_deps = \
	$(STATEDIR)/nxproxy.extract \
	$(STATEDIR)/nx-X11.compile \
	$(STATEDIR)/virtual-xchain.install

NXPROXY_PATH	=  PATH=$(CROSS_PATH)
NXPROXY_ENV 	=  $(CROSS_ENV)
#NXPROXY_ENV	+=
NXPROXY_ENV	+= PKG_CONFIG_PATH=$(CROSS_LIB_DIR)/lib/pkgconfig:$(CROSS_LIB_DIR)/lib/pkgconfig
#ifdef PTXCONF_XFREE430
#NXPROXY_ENV	+= LDFLAGS=-Wl,-rpath-link,$(CROSS_LIB_DIR)/lib
#endif

#
# autoconf
#
NXPROXY_AUTOCONF = \
	--build=$(GNU_HOST) \
	--host=$(PTXCONF_GNU_TARGET) \
	--prefix=/usr

ifdef PTXCONF_XFREE430
NXPROXY_AUTOCONF += --x-includes=$(CROSS_LIB_DIR)/include
NXPROXY_AUTOCONF += --x-libraries=$(CROSS_LIB_DIR)/lib
endif

$(STATEDIR)/nxproxy.prepare: $(nxproxy_prepare_deps)
	@$(call targetinfo, $@)
	@$(call clean, $(NXPROXY_DIR)/config.cache)
	cd $(NXPROXY_DIR) && aclocal
	#cd $(NXPROXY_DIR) && automake --add-missing
	cd $(NXPROXY_DIR) && autoconf
	cd $(NXPROXY_DIR) && \
		$(NXPROXY_PATH) $(NXPROXY_ENV) \
		./configure $(NXPROXY_AUTOCONF)
	touch $@

# ----------------------------------------------------------------------------
# Compile
# ----------------------------------------------------------------------------

nxproxy_compile: $(STATEDIR)/nxproxy.compile

nxproxy_compile_deps = $(STATEDIR)/nxproxy.prepare

$(STATEDIR)/nxproxy.compile: $(nxproxy_compile_deps)
	@$(call targetinfo, $@)
	$(NXPROXY_PATH) $(MAKE) -C $(NXPROXY_DIR)
	touch $@

# ----------------------------------------------------------------------------
# Install
# ----------------------------------------------------------------------------

nxproxy_install: $(STATEDIR)/nxproxy.install

$(STATEDIR)/nxproxy.install: $(STATEDIR)/nxproxy.compile
	@$(call targetinfo, $@)
	asasd
	touch $@

# ----------------------------------------------------------------------------
# Target-Install
# ----------------------------------------------------------------------------

nxproxy_targetinstall: $(STATEDIR)/nxproxy.targetinstall

nxproxy_targetinstall_deps = $(STATEDIR)/nxproxy.compile

$(STATEDIR)/nxproxy.targetinstall: $(nxproxy_targetinstall_deps)
	@$(call targetinfo, $@)
	$(NXPROXY_PATH) $(MAKE) -C $(NXPROXY_DIR) DESTDIR=$(NXPROXY_IPKG_TMP) install
	mkdir -p $(NXPROXY_IPKG_TMP)/CONTROL
	echo "Package: nxproxy" 			>$(NXPROXY_IPKG_TMP)/CONTROL/control
	echo "Priority: optional" 			>>$(NXPROXY_IPKG_TMP)/CONTROL/control
	echo "Section: pdaXrom" 			>>$(NXPROXY_IPKG_TMP)/CONTROL/control
	echo "Maintainer: Alexander Chukov <sash@pdaXrom.org>" 			>>$(NXPROXY_IPKG_TMP)/CONTROL/control
	echo "Architecture: $(SHORT_TARGET)" 		>>$(NXPROXY_IPKG_TMP)/CONTROL/control
	echo "Version: $(NXPROXY_VERSION)" 		>>$(NXPROXY_IPKG_TMP)/CONTROL/control
	echo "Depends: " 				>>$(NXPROXY_IPKG_TMP)/CONTROL/control
	echo "Description: generated with pdaXrom builder">>$(NXPROXY_IPKG_TMP)/CONTROL/control
	saasd
	cd $(FEEDDIR) && $(XMKIPKG) $(NXPROXY_IPKG_TMP)
	touch $@

# ----------------------------------------------------------------------------
# Image-Install
# ----------------------------------------------------------------------------

ifdef PTXCONF_NXPROXY_INSTALL
ROMPACKAGES += $(STATEDIR)/nxproxy.imageinstall
endif

nxproxy_imageinstall_deps = $(STATEDIR)/nxproxy.targetinstall \
	$(STATEDIR)/virtual-image.install

$(STATEDIR)/nxproxy.imageinstall: $(nxproxy_imageinstall_deps)
	@$(call targetinfo, $@)
	cd $(FEEDDIR) && $(XIPKG) install nxproxy
	touch $@

# ----------------------------------------------------------------------------
# Clean
# ----------------------------------------------------------------------------

nxproxy_clean:
	rm -rf $(STATEDIR)/nxproxy.*
	rm -rf $(NXPROXY_DIR)

# vim: syntax=make
