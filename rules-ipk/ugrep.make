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
ifdef PTXCONF_UGREP
PACKAGES += ugrep
endif

#
# Paths and names
#
UGREP_VERSION		= 2.5
UGREP			= grep-$(UGREP_VERSION)
UGREP_SUFFIX		= tar.bz2
UGREP_URL		= http://mirrors.kernel.org/gnu/grep/$(UGREP).$(UGREP_SUFFIX)
UGREP_SOURCE		= $(SRCDIR)/$(UGREP).$(UGREP_SUFFIX)
UGREP_DIR		= $(BUILDDIR)/$(UGREP)
UGREP_IPKG_TMP		= $(UGREP_DIR)/ipkg_tmp

# ----------------------------------------------------------------------------
# Get
# ----------------------------------------------------------------------------

ugrep_get: $(STATEDIR)/ugrep.get

ugrep_get_deps = $(UGREP_SOURCE)

$(STATEDIR)/ugrep.get: $(ugrep_get_deps)
	@$(call targetinfo, $@)
	@$(call get_patches, $(UGREP))
	touch $@

$(UGREP_SOURCE):
	@$(call targetinfo, $@)
	@$(call get, $(UGREP_URL))

# ----------------------------------------------------------------------------
# Extract
# ----------------------------------------------------------------------------

ugrep_extract: $(STATEDIR)/ugrep.extract

ugrep_extract_deps = $(STATEDIR)/ugrep.get

$(STATEDIR)/ugrep.extract: $(ugrep_extract_deps)
	@$(call targetinfo, $@)
	@$(call clean, $(UGREP_DIR))
	@$(call extract, $(UGREP_SOURCE))
	@$(call patchin, $(UGREP))
	touch $@

# ----------------------------------------------------------------------------
# Prepare
# ----------------------------------------------------------------------------

ugrep_prepare: $(STATEDIR)/ugrep.prepare

#
# dependencies
#
ugrep_prepare_deps = \
	$(STATEDIR)/ugrep.extract \
	$(STATEDIR)/pcre.install \
	$(STATEDIR)/virtual-xchain.install

UGREP_PATH	=  PATH=$(CROSS_PATH)
UGREP_ENV 	=  $(CROSS_ENV)
#UGREP_ENV	+=
UGREP_ENV	+= PKG_CONFIG_PATH=$(CROSS_LIB_DIR)/lib/pkgconfig:$(CROSS_LIB_DIR)/lib/pkgconfig
#ifdef PTXCONF_XFREE430
#UGREP_ENV	+= LDFLAGS=-Wl,-rpath-link,$(CROSS_LIB_DIR)/lib
#endif

#
# autoconf
#
UGREP_AUTOCONF = \
	--build=$(GNU_HOST) \
	--host=$(PTXCONF_GNU_TARGET) \
	--prefix=$(PTXCONF_NATIVE_PREFIX)

ifdef PTXCONF_LIBICONV
UGREP_AUTOCONF += --with-libiconv-prefix=$(CROSS_LIB_DIR)
endif

ifdef PTXCONF_XFREE430
UGREP_AUTOCONF += --x-includes=$(CROSS_LIB_DIR)/include
UGREP_AUTOCONF += --x-libraries=$(CROSS_LIB_DIR)/lib
endif

$(STATEDIR)/ugrep.prepare: $(ugrep_prepare_deps)
	@$(call targetinfo, $@)
	@$(call clean, $(UGREP_DIR)/config.cache)
	cd $(UGREP_DIR) && \
		$(UGREP_PATH) $(UGREP_ENV) \
		./configure $(UGREP_AUTOCONF)
	touch $@

# ----------------------------------------------------------------------------
# Compile
# ----------------------------------------------------------------------------

ugrep_compile: $(STATEDIR)/ugrep.compile

ugrep_compile_deps = $(STATEDIR)/ugrep.prepare

$(STATEDIR)/ugrep.compile: $(ugrep_compile_deps)
	@$(call targetinfo, $@)
	$(UGREP_PATH) $(MAKE) -C $(UGREP_DIR)
	touch $@

# ----------------------------------------------------------------------------
# Install
# ----------------------------------------------------------------------------

ugrep_install: $(STATEDIR)/ugrep.install

$(STATEDIR)/ugrep.install: $(STATEDIR)/ugrep.compile
	@$(call targetinfo, $@)
	$(UGREP_PATH) $(MAKE) -C $(UGREP_DIR) install
	touch $@

# ----------------------------------------------------------------------------
# Target-Install
# ----------------------------------------------------------------------------

ugrep_targetinstall: $(STATEDIR)/ugrep.targetinstall

ugrep_targetinstall_deps = $(STATEDIR)/ugrep.compile \
	$(STATEDIR)/pcre.targetinstall

$(STATEDIR)/ugrep.targetinstall: $(ugrep_targetinstall_deps)
	@$(call targetinfo, $@)
	$(UGREP_PATH) $(MAKE) -C $(UGREP_DIR) prefix=$(UGREP_IPKG_TMP)$(PTXCONF_NATIVE_PREFIX) install
	rm -rf $(UGREP_IPKG_TMP)$(PTXCONF_NATIVE_PREFIX)/info
	rm -rf $(UGREP_IPKG_TMP)$(PTXCONF_NATIVE_PREFIX)/man
	rm -rf $(UGREP_IPKG_TMP)$(PTXCONF_NATIVE_PREFIX)/share
	$(CROSSSTRIP) $(UGREP_IPKG_TMP)$(PTXCONF_NATIVE_PREFIX)/bin/grep
	mkdir -p $(UGREP_IPKG_TMP)/CONTROL
	echo "Package: grep" 							>$(UGREP_IPKG_TMP)/CONTROL/control
	echo "Priority: optional" 						>>$(UGREP_IPKG_TMP)/CONTROL/control
	echo "Section: Utilities" 						>>$(UGREP_IPKG_TMP)/CONTROL/control
	echo "Maintainer: Alexander Chukov <sash@pdaXrom.org>" 			>>$(UGREP_IPKG_TMP)/CONTROL/control
	echo "Architecture: $(SHORT_TARGET)" 					>>$(UGREP_IPKG_TMP)/CONTROL/control
	echo "Version: $(UGREP_VERSION)" 					>>$(UGREP_IPKG_TMP)/CONTROL/control
	echo "Depends: pcre" 							>>$(UGREP_IPKG_TMP)/CONTROL/control
	echo "Description: Grep searches one or more input files for lines containing a match to a specified pattern. By default, grep prints the matching lines.">>$(UGREP_IPKG_TMP)/CONTROL/control
	cd $(FEEDDIR) && $(XMKIPKG) $(UGREP_IPKG_TMP)
	touch $@

# ----------------------------------------------------------------------------
# Image-Install
# ----------------------------------------------------------------------------

ifdef PTXCONF_UGREP_INSTALL
ROMPACKAGES += $(STATEDIR)/ugrep.imageinstall
endif

ugrep_imageinstall_deps = $(STATEDIR)/ugrep.targetinstall \
	$(STATEDIR)/virtual-image.install

$(STATEDIR)/ugrep.imageinstall: $(ugrep_imageinstall_deps)
	@$(call targetinfo, $@)
	cd $(FEEDDIR) && $(XIPKG) install grep
	touch $@

# ----------------------------------------------------------------------------
# Clean
# ----------------------------------------------------------------------------

ugrep_clean:
	rm -rf $(STATEDIR)/ugrep.*
	rm -rf $(UGREP_DIR)

# vim: syntax=make
