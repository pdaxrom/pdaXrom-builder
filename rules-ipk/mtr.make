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
ifdef PTXCONF_MTR
PACKAGES += mtr
endif

#
# Paths and names
#
MTR_VERSION	= 0.65
MTR		= mtr-$(MTR_VERSION)
MTR_SUFFIX	= tar.gz
MTR_URL		= ftp://ftp.bitwizard.nl/mtr/$(MTR).$(MTR_SUFFIX)
MTR_SOURCE	= $(SRCDIR)/$(MTR).$(MTR_SUFFIX)
MTR_DIR		= $(BUILDDIR)/$(MTR)
MTR_IPKG_TMP	= $(MTR_DIR)/ipkg_tmp

# ----------------------------------------------------------------------------
# Get
# ----------------------------------------------------------------------------

mtr_get: $(STATEDIR)/mtr.get

mtr_get_deps = $(MTR_SOURCE)

$(STATEDIR)/mtr.get: $(mtr_get_deps)
	@$(call targetinfo, $@)
	@$(call get_patches, $(MTR))
	touch $@

$(MTR_SOURCE):
	@$(call targetinfo, $@)
	@$(call get, $(MTR_URL))

# ----------------------------------------------------------------------------
# Extract
# ----------------------------------------------------------------------------

mtr_extract: $(STATEDIR)/mtr.extract

mtr_extract_deps = $(STATEDIR)/mtr.get

$(STATEDIR)/mtr.extract: $(mtr_extract_deps)
	@$(call targetinfo, $@)
	@$(call clean, $(MTR_DIR))
	@$(call extract, $(MTR_SOURCE))
	@$(call patchin, $(MTR))
	touch $@

# ----------------------------------------------------------------------------
# Prepare
# ----------------------------------------------------------------------------

mtr_prepare: $(STATEDIR)/mtr.prepare

#
# dependencies
#
mtr_prepare_deps = \
	$(STATEDIR)/mtr.extract \
	$(STATEDIR)/virtual-xchain.install

ifdef PTXCONF_XFREE430
mtr_prepare_deps += \
	$(STATEDIR)/gtk1210.install
endif

MTR_PATH	=  PATH=$(CROSS_PATH)
MTR_ENV 	=  $(CROSS_ENV)
#MTR_ENV	+=
MTR_ENV	+= PKG_CONFIG_PATH=$(CROSS_LIB_DIR)/lib/pkgconfig:$(CROSS_LIB_DIR)/lib/pkgconfig
#ifdef PTXCONF_XFREE430
#MTR_ENV	+= LDFLAGS=-Wl,-rpath-link,$(CROSS_LIB_DIR)/lib
#endif

#
# autoconf
#
MTR_AUTOCONF = \
	--build=$(GNU_HOST) \
	--host=$(PTXCONF_GNU_TARGET) \
	--prefix=/usr

ifdef PTXCONF_XFREE430
MTR_AUTOCONF += --x-includes=$(CROSS_LIB_DIR)/include
MTR_AUTOCONF += --x-libraries=$(CROSS_LIB_DIR)/lib
else
MTR_AUTOCONF += --without-x
MTR_AUTOCONF += --without-gtk
endif

$(STATEDIR)/mtr.prepare: $(mtr_prepare_deps)
	@$(call targetinfo, $@)
	@$(call clean, $(MTR_DIR)/config.cache)
	cd $(MTR_DIR) && \
		$(MTR_PATH) $(MTR_ENV) \
		./configure $(MTR_AUTOCONF)
	touch $@

# ----------------------------------------------------------------------------
# Compile
# ----------------------------------------------------------------------------

mtr_compile: $(STATEDIR)/mtr.compile

mtr_compile_deps = $(STATEDIR)/mtr.prepare

$(STATEDIR)/mtr.compile: $(mtr_compile_deps)
	@$(call targetinfo, $@)
	$(MTR_PATH) $(MAKE) -C $(MTR_DIR)
	touch $@

# ----------------------------------------------------------------------------
# Install
# ----------------------------------------------------------------------------

mtr_install: $(STATEDIR)/mtr.install

$(STATEDIR)/mtr.install: $(STATEDIR)/mtr.compile
	@$(call targetinfo, $@)
	$(MTR_PATH) $(MAKE) -C $(MTR_DIR) install
	touch $@

# ----------------------------------------------------------------------------
# Target-Install
# ----------------------------------------------------------------------------

mtr_targetinstall: $(STATEDIR)/mtr.targetinstall

mtr_targetinstall_deps = $(STATEDIR)/mtr.compile

ifdef PTXCONF_XFREE430
mtr_targetinstall_deps += \
	$(STATEDIR)/gtk1210.targetinstall
endif

$(STATEDIR)/mtr.targetinstall: $(mtr_targetinstall_deps)
	@$(call targetinfo, $@)
	$(MTR_PATH) $(MAKE) -C $(MTR_DIR) DESTDIR=$(MTR_IPKG_TMP) install
	rm -rf $(MTR_IPKG_TMP)/usr/man
	$(CROSSSTRIP) $(MTR_IPKG_TMP)/usr/sbin/*
	mkdir -p $(MTR_IPKG_TMP)/CONTROL
	echo "Package: mtr" 							>$(MTR_IPKG_TMP)/CONTROL/control
	echo "Priority: optional" 						>>$(MTR_IPKG_TMP)/CONTROL/control
	echo "Section: Network" 						>>$(MTR_IPKG_TMP)/CONTROL/control
	echo "Maintainer: Alexander Chukov <sash@pdaXrom.org>" 			>>$(MTR_IPKG_TMP)/CONTROL/control
	echo "Architecture: $(SHORT_TARGET)" 					>>$(MTR_IPKG_TMP)/CONTROL/control
	echo "Version: $(MTR_VERSION)" 						>>$(MTR_IPKG_TMP)/CONTROL/control
ifdef PTXCONF_XFREE430
	echo "Depends: gtk" 							>>$(MTR_IPKG_TMP)/CONTROL/control
else
	echo "Depends: " 							>>$(MTR_IPKG_TMP)/CONTROL/control
endif
	echo "Description: mtr combines the functionality of the 'traceroute' and 'ping' programs in a single network diagnostic tool."	>>$(MTR_IPKG_TMP)/CONTROL/control
	cd $(FEEDDIR) && $(XMKIPKG) $(MTR_IPKG_TMP)
	touch $@

# ----------------------------------------------------------------------------
# Image-Install
# ----------------------------------------------------------------------------

ifdef PTXCONF_MTR_INSTALL
ROMPACKAGES += $(STATEDIR)/mtr.imageinstall
endif

mtr_imageinstall_deps = $(STATEDIR)/mtr.targetinstall \
	$(STATEDIR)/virtual-image.install

$(STATEDIR)/mtr.imageinstall: $(mtr_imageinstall_deps)
	@$(call targetinfo, $@)
	cd $(FEEDDIR) && $(XIPKG) install mtr
	touch $@

# ----------------------------------------------------------------------------
# Clean
# ----------------------------------------------------------------------------

mtr_clean:
	rm -rf $(STATEDIR)/mtr.*
	rm -rf $(MTR_DIR)

# vim: syntax=make
