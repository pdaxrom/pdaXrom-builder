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
ifdef PTXCONF_BISON
PACKAGES += bison
endif

#
# Paths and names
#
BISON_VERSION		= 1.875c
BISON			= bison-$(BISON_VERSION)
BISON_SUFFIX		= tar.gz
BISON_URL		= ftp://alpha.gnu.org/pub/gnu/bison/$(BISON).$(BISON_SUFFIX)
BISON_SOURCE		= $(SRCDIR)/$(BISON).$(BISON_SUFFIX)
BISON_DIR		= $(BUILDDIR)/$(BISON)
BISON_IPKG_TMP		= $(BISON_DIR)/ipkg_tmp

# ----------------------------------------------------------------------------
# Get
# ----------------------------------------------------------------------------

bison_get: $(STATEDIR)/bison.get

bison_get_deps = $(BISON_SOURCE)

$(STATEDIR)/bison.get: $(bison_get_deps)
	@$(call targetinfo, $@)
	@$(call get_patches, $(BISON))
	touch $@

$(BISON_SOURCE):
	@$(call targetinfo, $@)
	@$(call get, $(BISON_URL))

# ----------------------------------------------------------------------------
# Extract
# ----------------------------------------------------------------------------

bison_extract: $(STATEDIR)/bison.extract

bison_extract_deps = $(STATEDIR)/bison.get

$(STATEDIR)/bison.extract: $(bison_extract_deps)
	@$(call targetinfo, $@)
	@$(call clean, $(BISON_DIR))
	@$(call extract, $(BISON_SOURCE))
	@$(call patchin, $(BISON))
	touch $@

# ----------------------------------------------------------------------------
# Prepare
# ----------------------------------------------------------------------------

bison_prepare: $(STATEDIR)/bison.prepare

#
# dependencies
#
bison_prepare_deps = \
	$(STATEDIR)/bison.extract \
	$(STATEDIR)/virtual-xchain.install

BISON_PATH	=  PATH=$(CROSS_PATH)
BISON_ENV 	=  $(CROSS_ENV)
BISON_ENV	+= ac_cv_path_M4=m4
BISON_ENV	+= PKG_CONFIG_PATH=$(CROSS_LIB_DIR)/lib/pkgconfig:$(CROSS_LIB_DIR)/lib/pkgconfig
#ifdef PTXCONF_XFREE430
#BISON_ENV	+= LDFLAGS=-Wl,-rpath-link,$(CROSS_LIB_DIR)/lib
#endif

#
# autoconf
#
BISON_AUTOCONF = \
	--build=$(GNU_HOST) \
	--host=$(PTXCONF_GNU_TARGET) \
	--prefix=$(PTXCONF_NATIVE_PREFIX)

ifdef PTXCONF_XFREE430
BISON_AUTOCONF += --x-includes=$(CROSS_LIB_DIR)/include
BISON_AUTOCONF += --x-libraries=$(CROSS_LIB_DIR)/lib
endif

$(STATEDIR)/bison.prepare: $(bison_prepare_deps)
	@$(call targetinfo, $@)
	@$(call clean, $(BISON_DIR)/config.cache)
	cd $(BISON_DIR) && \
		$(BISON_PATH) $(BISON_ENV) \
		./configure $(BISON_AUTOCONF)
	touch $@

# ----------------------------------------------------------------------------
# Compile
# ----------------------------------------------------------------------------

bison_compile: $(STATEDIR)/bison.compile

bison_compile_deps = $(STATEDIR)/bison.prepare

$(STATEDIR)/bison.compile: $(bison_compile_deps)
	@$(call targetinfo, $@)
	$(BISON_PATH) $(MAKE) -C $(BISON_DIR)
	touch $@

# ----------------------------------------------------------------------------
# Install
# ----------------------------------------------------------------------------

bison_install: $(STATEDIR)/bison.install

$(STATEDIR)/bison.install: $(STATEDIR)/bison.compile
	@$(call targetinfo, $@)
	###$(BISON_PATH) $(MAKE) -C $(BISON_DIR) install
	touch $@

# ----------------------------------------------------------------------------
# Target-Install
# ----------------------------------------------------------------------------

bison_targetinstall: $(STATEDIR)/bison.targetinstall

bison_targetinstall_deps = $(STATEDIR)/bison.compile

$(STATEDIR)/bison.targetinstall: $(bison_targetinstall_deps)
	@$(call targetinfo, $@)
	$(BISON_PATH) $(MAKE) -C $(BISON_DIR) DESTDIR=$(BISON_IPKG_TMP) install
	$(CROSSSTRIP) $(BISON_IPKG_TMP)$(PTXCONF_NATIVE_PREFIX)/bin/bison
	rm -rf $(BISON_IPKG_TMP)$(PTXCONF_NATIVE_PREFIX)/info
	rm -rf $(BISON_IPKG_TMP)$(PTXCONF_NATIVE_PREFIX)/lib
	rm -rf $(BISON_IPKG_TMP)$(PTXCONF_NATIVE_PREFIX)/man
	rm -rf $(BISON_IPKG_TMP)$(PTXCONF_NATIVE_PREFIX)/share/locale
	mkdir -p $(BISON_IPKG_TMP)/CONTROL
	echo "Package: bison" 				>$(BISON_IPKG_TMP)/CONTROL/control
	echo "Priority: optional" 			>>$(BISON_IPKG_TMP)/CONTROL/control
	echo "Section: Utils"	 			>>$(BISON_IPKG_TMP)/CONTROL/control
	echo "Maintainer: Alexander Chukov <sash@pdaXrom.org>">>$(BISON_IPKG_TMP)/CONTROL/control
	echo "Architecture: $(SHORT_TARGET)" 		>>$(BISON_IPKG_TMP)/CONTROL/control
	echo "Version: $(BISON_VERSION)" 		>>$(BISON_IPKG_TMP)/CONTROL/control
	echo "Depends: " 				>>$(BISON_IPKG_TMP)/CONTROL/control
	echo "Description: Bison is a general-purpose parser generator that converts a grammar description for an LALR context-free grammar into a C program to parse that grammar.">>$(BISON_IPKG_TMP)/CONTROL/control
	cd $(FEEDDIR) && $(XMKIPKG) $(BISON_IPKG_TMP)
	touch $@

# ----------------------------------------------------------------------------
# Image-Install
# ----------------------------------------------------------------------------

ifdef PTXCONF_BISON_INSTALL
ROMPACKAGES += $(STATEDIR)/bison.imageinstall
endif

bison_imageinstall_deps = $(STATEDIR)/bison.targetinstall \
	$(STATEDIR)/virtual-image.install

$(STATEDIR)/bison.imageinstall: $(bison_imageinstall_deps)
	@$(call targetinfo, $@)
	cd $(FEEDDIR) && $(XIPKG) install bison
	touch $@

# ----------------------------------------------------------------------------
# Clean
# ----------------------------------------------------------------------------

bison_clean:
	rm -rf $(STATEDIR)/bison.*
	rm -rf $(BISON_DIR)

# vim: syntax=make
