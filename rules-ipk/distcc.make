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
ifdef PTXCONF_DISTCC
PACKAGES += distcc
endif

#
# Paths and names
#
DISTCC			= $(XCHAIN-DISTCC)
DISTCC_DIR		= $(BUILDDIR)/$(DISTCC)
DISTCC_IPKG_TMP		= $(DISTCC_DIR)/ipkg_tmp

# ----------------------------------------------------------------------------
# Get
# ----------------------------------------------------------------------------

distcc_get: $(STATEDIR)/distcc.get

distcc_get_deps = $(XCHAIN-DISTCC_SOURCE)

$(STATEDIR)/distcc.get: $(distcc_get_deps)
	@$(call targetinfo, $@)
	@$(call get_patches, $(DISTCC))
	touch $@

$(DISTCC_SOURCE):
	@$(call targetinfo, $@)
	@$(call get, $(XCHAIN-DISTCC_URL))

# ----------------------------------------------------------------------------
# Extract
# ----------------------------------------------------------------------------

distcc_extract: $(STATEDIR)/distcc.extract

distcc_extract_deps = $(STATEDIR)/distcc.get

$(STATEDIR)/distcc.extract: $(distcc_extract_deps)
	@$(call targetinfo, $@)
	@$(call clean, $(DISTCC_DIR))
	@$(call extract, $(XCHAIN-DISTCC_SOURCE))
	@$(call patchin, $(DISTCC))
	touch $@

# ----------------------------------------------------------------------------
# Prepare
# ----------------------------------------------------------------------------

distcc_prepare: $(STATEDIR)/distcc.prepare

#
# dependencies
#
distcc_prepare_deps = \
	$(STATEDIR)/distcc.extract \
	$(STATEDIR)/popt.install \
	$(STATEDIR)/virtual-xchain.install

DISTCC_PATH	=  PATH=$(CROSS_PATH)
DISTCC_ENV 	=  $(CROSS_ENV)
#DISTCC_ENV	+=
DISTCC_ENV	+= PKG_CONFIG_PATH=$(CROSS_LIB_DIR)/lib/pkgconfig:$(CROSS_LIB_DIR)/lib/pkgconfig
#ifdef PTXCONF_XFREE430
#DISTCC_ENV	+= LDFLAGS=-Wl,-rpath-link,$(CROSS_LIB_DIR)/lib
#endif

#
# autoconf
#
DISTCC_AUTOCONF = \
	--build=$(GNU_HOST) \
	--host=$(PTXCONF_GNU_TARGET) \
	--prefix=$(PTXCONF_NATIVE_PREFIX)

ifdef PTXCONF_XFREE430
DISTCC_AUTOCONF += --x-includes=$(CROSS_LIB_DIR)/include
DISTCC_AUTOCONF += --x-libraries=$(CROSS_LIB_DIR)/lib
endif

$(STATEDIR)/distcc.prepare: $(distcc_prepare_deps)
	@$(call targetinfo, $@)
	@$(call clean, $(DISTCC_DIR)/config.cache)
	cd $(DISTCC_DIR) && \
		$(DISTCC_PATH) $(DISTCC_ENV) \
		./configure $(DISTCC_AUTOCONF)
	touch $@

# ----------------------------------------------------------------------------
# Compile
# ----------------------------------------------------------------------------

distcc_compile: $(STATEDIR)/distcc.compile

distcc_compile_deps = $(STATEDIR)/distcc.prepare

$(STATEDIR)/distcc.compile: $(distcc_compile_deps)
	@$(call targetinfo, $@)
	$(DISTCC_PATH) $(MAKE) -C $(DISTCC_DIR)
	touch $@

# ----------------------------------------------------------------------------
# Install
# ----------------------------------------------------------------------------

distcc_install: $(STATEDIR)/distcc.install

$(STATEDIR)/distcc.install: $(STATEDIR)/distcc.compile
	@$(call targetinfo, $@)
	####$(DISTCC_PATH) $(MAKE) -C $(DISTCC_DIR) install
	touch $@

# ----------------------------------------------------------------------------
# Target-Install
# ----------------------------------------------------------------------------

distcc_targetinstall: $(STATEDIR)/distcc.targetinstall

distcc_targetinstall_deps = \
	$(STATEDIR)/distcc.compile \
	$(STATEDIR)/popt.targetinstall

$(STATEDIR)/distcc.targetinstall: $(distcc_targetinstall_deps)
	@$(call targetinfo, $@)
	$(DISTCC_PATH) $(MAKE) -C $(DISTCC_DIR) DESTDIR=$(DISTCC_IPKG_TMP) install
	$(CROSSSTRIP) $(DISTCC_IPKG_TMP)$(PTXCONF_NATIVE_PREFIX)/bin/*
	rm -rf $(DISTCC_IPKG_TMP)$(PTXCONF_NATIVE_PREFIX)/man
	rm -rf $(DISTCC_IPKG_TMP)$(PTXCONF_NATIVE_PREFIX)/share
	mkdir -p $(DISTCC_IPKG_TMP)/CONTROL
	echo "Package: distcc" 				>$(DISTCC_IPKG_TMP)/CONTROL/control
	echo "Priority: optional" 			>>$(DISTCC_IPKG_TMP)/CONTROL/control
	echo "Section: Development" 			>>$(DISTCC_IPKG_TMP)/CONTROL/control
	echo "Maintainer: Alexander Chukov <sash@pdaXrom.org>">>$(DISTCC_IPKG_TMP)/CONTROL/control
	echo "Architecture: $(SHORT_TARGET)" 		>>$(DISTCC_IPKG_TMP)/CONTROL/control
	echo "Version: $(XCHAIN-DISTCC_VERSION)" 	>>$(DISTCC_IPKG_TMP)/CONTROL/control
	echo "Depends: popt" 				>>$(DISTCC_IPKG_TMP)/CONTROL/control
	echo "Description: a free distributed C/C++ compiler system.">>$(DISTCC_IPKG_TMP)/CONTROL/control
	cd $(FEEDDIR) && $(XMKIPKG) $(DISTCC_IPKG_TMP)
	touch $@

# ----------------------------------------------------------------------------
# Image-Install
# ----------------------------------------------------------------------------

ifdef PTXCONF_DISTCC_INSTALL
ROMPACKAGES += $(STATEDIR)/distcc.imageinstall
endif

distcc_imageinstall_deps = $(STATEDIR)/distcc.targetinstall \
	$(STATEDIR)/virtual-image.install

$(STATEDIR)/distcc.imageinstall: $(distcc_imageinstall_deps)
	@$(call targetinfo, $@)
	cd $(FEEDDIR) && $(XIPKG) install distcc
	touch $@

# ----------------------------------------------------------------------------
# Clean
# ----------------------------------------------------------------------------

distcc_clean:
	rm -rf $(STATEDIR)/distcc.*
	rm -rf $(DISTCC_DIR)

# vim: syntax=make
