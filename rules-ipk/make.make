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
ifdef PTXCONF_UMAKE
PACKAGES += umake
endif

#
# Paths and names
#
UMAKE_VERSION		= 3.80
UMAKE			= make-$(UMAKE_VERSION)
UMAKE_SUFFIX		= tar.gz
UMAKE_URL		= ftp://ftp.gnu.org/gnu/make/$(UMAKE).$(UMAKE_SUFFIX)
UMAKE_SOURCE		= $(SRCDIR)/$(UMAKE).$(UMAKE_SUFFIX)
UMAKE_DIR		= $(BUILDDIR)/$(UMAKE)
UMAKE_IPKG_TMP		= $(UMAKE_DIR)/ipkg_tmp

# ----------------------------------------------------------------------------
# Get
# ----------------------------------------------------------------------------

umake_get: $(STATEDIR)/umake.get

umake_get_deps = $(UMAKE_SOURCE)

$(STATEDIR)/umake.get: $(umake_get_deps)
	@$(call targetinfo, $@)
	@$(call get_patches, $(UMAKE))
	touch $@

$(UMAKE_SOURCE):
	@$(call targetinfo, $@)
	@$(call get, $(UMAKE_URL))

# ----------------------------------------------------------------------------
# Extract
# ----------------------------------------------------------------------------

umake_extract: $(STATEDIR)/umake.extract

umake_extract_deps = $(STATEDIR)/umake.get

$(STATEDIR)/umake.extract: $(umake_extract_deps)
	@$(call targetinfo, $@)
	@$(call clean, $(UMAKE_DIR))
	@$(call extract, $(UMAKE_SOURCE))
	@$(call patchin, $(UMAKE))
	touch $@

# ----------------------------------------------------------------------------
# Prepare
# ----------------------------------------------------------------------------

umake_prepare: $(STATEDIR)/umake.prepare

#
# dependencies
#
umake_prepare_deps = \
	$(STATEDIR)/umake.extract \
	$(STATEDIR)/virtual-xchain.install

UMAKE_PATH	=  PATH=$(CROSS_PATH)
UMAKE_ENV 	=  $(CROSS_ENV)
#UMAKE_ENV	+=
UMAKE_ENV	+= PKG_CONFIG_PATH=$(CROSS_LIB_DIR)/lib/pkgconfig:$(CROSS_LIB_DIR)/lib/pkgconfig
#ifdef PTXCONF_XFREE430
#UMAKE_ENV	+= LDFLAGS=-Wl,-rpath-link,$(CROSS_LIB_DIR)/lib
#endif

#
# autoconf
#
UMAKE_AUTOCONF = \
	--build=$(GNU_HOST) \
	--host=$(PTXCONF_GNU_TARGET) \
	--prefix=$(PTXCONF_NATIVE_PREFIX)

ifdef PTXCONF_XFREE430
UMAKE_AUTOCONF += --x-includes=$(CROSS_LIB_DIR)/include
UMAKE_AUTOCONF += --x-libraries=$(CROSS_LIB_DIR)/lib
endif

$(STATEDIR)/umake.prepare: $(umake_prepare_deps)
	@$(call targetinfo, $@)
	@$(call clean, $(UMAKE_DIR)/config.cache)
	cd $(UMAKE_DIR) && \
		$(UMAKE_PATH) $(UMAKE_ENV) \
		./configure $(UMAKE_AUTOCONF)
	touch $@

# ----------------------------------------------------------------------------
# Compile
# ----------------------------------------------------------------------------

umake_compile: $(STATEDIR)/umake.compile

umake_compile_deps = $(STATEDIR)/umake.prepare

$(STATEDIR)/umake.compile: $(umake_compile_deps)
	@$(call targetinfo, $@)
	$(UMAKE_PATH) $(MAKE) -C $(UMAKE_DIR)
	touch $@

# ----------------------------------------------------------------------------
# Install
# ----------------------------------------------------------------------------

umake_install: $(STATEDIR)/umake.install

$(STATEDIR)/umake.install: $(STATEDIR)/umake.compile
	@$(call targetinfo, $@)
	###$(UMAKE_PATH) make -C $(UMAKE_DIR) install
	touch $@

# ----------------------------------------------------------------------------
# Target-Install
# ----------------------------------------------------------------------------

umake_targetinstall: $(STATEDIR)/umake.targetinstall

umake_targetinstall_deps = $(STATEDIR)/umake.compile

$(STATEDIR)/umake.targetinstall: $(umake_targetinstall_deps)
	@$(call targetinfo, $@)
	$(UMAKE_PATH) $(MAKE) -C $(UMAKE_DIR) DESTDIR=$(UMAKE_IPKG_TMP) install
	$(CROSSSTRIP) $(UMAKE_IPKG_TMP)$(PTXCONF_NATIVE_PREFIX)/bin/make
	rm -rf $(UMAKE_IPKG_TMP)$(PTXCONF_NATIVE_PREFIX)/info
	rm -rf $(UMAKE_IPKG_TMP)$(PTXCONF_NATIVE_PREFIX)/man
	rm -rf $(UMAKE_IPKG_TMP)$(PTXCONF_NATIVE_PREFIX)/share
	mkdir -p $(UMAKE_IPKG_TMP)/CONTROL
	echo "Package: make" 				>$(UMAKE_IPKG_TMP)/CONTROL/control
	echo "Priority: optional" 			>>$(UMAKE_IPKG_TMP)/CONTROL/control
	echo "Section: Utils"	 			>>$(UMAKE_IPKG_TMP)/CONTROL/control
	echo "Maintainer: Alexander Chukov <sash@pdaXrom.org>" 			>>$(UMAKE_IPKG_TMP)/CONTROL/control
	echo "Architecture: $(SHORT_TARGET)" 		>>$(UMAKE_IPKG_TMP)/CONTROL/control
	echo "Version: $(UMAKE_VERSION)" 		>>$(UMAKE_IPKG_TMP)/CONTROL/control
	echo "Depends: " 				>>$(UMAKE_IPKG_TMP)/CONTROL/control
	echo "Description: GNU make utility to maintain groups of programs.">>$(UMAKE_IPKG_TMP)/CONTROL/control
	cd $(FEEDDIR) && $(XMKIPKG) $(UMAKE_IPKG_TMP)
	touch $@

# ----------------------------------------------------------------------------
# Image-Install
# ----------------------------------------------------------------------------

ifdef PTXCONF_UMAKE_INSTALL
ROMPACKAGES += $(STATEDIR)/umake.imageinstall
endif

umake_imageinstall_deps = $(STATEDIR)/umake.targetinstall \
	$(STATEDIR)/virtual-image.install

$(STATEDIR)/umake.imageinstall: $(umake_imageinstall_deps)
	@$(call targetinfo, $@)
	cd $(FEEDDIR) && $(XIPKG) install make
	touch $@

# ----------------------------------------------------------------------------
# Clean
# ----------------------------------------------------------------------------

umake_clean:
	rm -rf $(STATEDIR)/umake.*
	rm -rf $(UMAKE_DIR)

# vim: syntax=umake
