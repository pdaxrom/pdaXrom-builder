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
ifdef PTXCONF_DIFFUTILS
PACKAGES += diffutils
endif

#
# Paths and names
#
DIFFUTILS_VERSION	= 2.8.1
DIFFUTILS		= diffutils-$(DIFFUTILS_VERSION)
DIFFUTILS_SUFFIX	= tar.gz
DIFFUTILS_URL		= ftp://ftp.gnu.org/gnu/diffutils/$(DIFFUTILS).$(DIFFUTILS_SUFFIX)
DIFFUTILS_SOURCE	= $(SRCDIR)/$(DIFFUTILS).$(DIFFUTILS_SUFFIX)
DIFFUTILS_DIR		= $(BUILDDIR)/$(DIFFUTILS)
DIFFUTILS_IPKG_TMP	= $(DIFFUTILS_DIR)/ipkg_tmp

# ----------------------------------------------------------------------------
# Get
# ----------------------------------------------------------------------------

diffutils_get: $(STATEDIR)/diffutils.get

diffutils_get_deps = $(DIFFUTILS_SOURCE)

$(STATEDIR)/diffutils.get: $(diffutils_get_deps)
	@$(call targetinfo, $@)
	@$(call get_patches, $(DIFFUTILS))
	touch $@

$(DIFFUTILS_SOURCE):
	@$(call targetinfo, $@)
	@$(call get, $(DIFFUTILS_URL))

# ----------------------------------------------------------------------------
# Extract
# ----------------------------------------------------------------------------

diffutils_extract: $(STATEDIR)/diffutils.extract

diffutils_extract_deps = $(STATEDIR)/diffutils.get

$(STATEDIR)/diffutils.extract: $(diffutils_extract_deps)
	@$(call targetinfo, $@)
	@$(call clean, $(DIFFUTILS_DIR))
	@$(call extract, $(DIFFUTILS_SOURCE))
	@$(call patchin, $(DIFFUTILS))
	touch $@

# ----------------------------------------------------------------------------
# Prepare
# ----------------------------------------------------------------------------

diffutils_prepare: $(STATEDIR)/diffutils.prepare

#
# dependencies
#
diffutils_prepare_deps = \
	$(STATEDIR)/diffutils.extract \
	$(STATEDIR)/virtual-xchain.install

DIFFUTILS_PATH	=  PATH=$(CROSS_PATH)
DIFFUTILS_ENV 	=  $(CROSS_ENV)
#DIFFUTILS_ENV	+=
DIFFUTILS_ENV	+= PKG_CONFIG_PATH=$(CROSS_LIB_DIR)/lib/pkgconfig:$(CROSS_LIB_DIR)/lib/pkgconfig
#ifdef PTXCONF_XFREE430
#DIFFUTILS_ENV	+= LDFLAGS=-Wl,-rpath-link,$(CROSS_LIB_DIR)/lib
#endif

#
# autoconf
#
DIFFUTILS_AUTOCONF = \
	--build=$(GNU_HOST) \
	--host=$(PTXCONF_GNU_TARGET) \
	--prefix=$(PTXCONF_NATIVE_PREFIX)

ifdef PTXCONF_XFREE430
DIFFUTILS_AUTOCONF += --x-includes=$(CROSS_LIB_DIR)/include
DIFFUTILS_AUTOCONF += --x-libraries=$(CROSS_LIB_DIR)/lib
endif

$(STATEDIR)/diffutils.prepare: $(diffutils_prepare_deps)
	@$(call targetinfo, $@)
	@$(call clean, $(DIFFUTILS_DIR)/config.cache)
	cd $(DIFFUTILS_DIR) && \
		$(DIFFUTILS_PATH) $(DIFFUTILS_ENV) \
		./configure $(DIFFUTILS_AUTOCONF)
	touch $@

# ----------------------------------------------------------------------------
# Compile
# ----------------------------------------------------------------------------

diffutils_compile: $(STATEDIR)/diffutils.compile

diffutils_compile_deps = $(STATEDIR)/diffutils.prepare

$(STATEDIR)/diffutils.compile: $(diffutils_compile_deps)
	@$(call targetinfo, $@)
	$(DIFFUTILS_PATH) $(MAKE) -C $(DIFFUTILS_DIR)
	touch $@

# ----------------------------------------------------------------------------
# Install
# ----------------------------------------------------------------------------

diffutils_install: $(STATEDIR)/diffutils.install

$(STATEDIR)/diffutils.install: $(STATEDIR)/diffutils.compile
	@$(call targetinfo, $@)
	###$(DIFFUTILS_PATH) $(MAKE) -C $(DIFFUTILS_DIR) install
	touch $@

# ----------------------------------------------------------------------------
# Target-Install
# ----------------------------------------------------------------------------

diffutils_targetinstall: $(STATEDIR)/diffutils.targetinstall

diffutils_targetinstall_deps = $(STATEDIR)/diffutils.compile

$(STATEDIR)/diffutils.targetinstall: $(diffutils_targetinstall_deps)
	@$(call targetinfo, $@)
	$(DIFFUTILS_PATH) $(MAKE) -C $(DIFFUTILS_DIR) DESTDIR=$(DIFFUTILS_IPKG_TMP) install
	$(CROSSSTRIP) $(DIFFUTILS_IPKG_TMP)$(PTXCONF_NATIVE_PREFIX)/bin/*
	rm -rf $(DIFFUTILS_IPKG_TMP)$(PTXCONF_NATIVE_PREFIX)/info
	rm -rf $(DIFFUTILS_IPKG_TMP)$(PTXCONF_NATIVE_PREFIX)/man
	rm -rf $(DIFFUTILS_IPKG_TMP)$(PTXCONF_NATIVE_PREFIX)/share
	mkdir -p $(DIFFUTILS_IPKG_TMP)/CONTROL
	echo "Package: diffutils" 			>$(DIFFUTILS_IPKG_TMP)/CONTROL/control
	echo "Priority: optional" 			>>$(DIFFUTILS_IPKG_TMP)/CONTROL/control
	echo "Section: Utils"	 			>>$(DIFFUTILS_IPKG_TMP)/CONTROL/control
	echo "Maintainer: Alexander Chukov <sash@pdaXrom.org>">>$(DIFFUTILS_IPKG_TMP)/CONTROL/control
	echo "Architecture: $(SHORT_TARGET)" 		>>$(DIFFUTILS_IPKG_TMP)/CONTROL/control
	echo "Version: $(DIFFUTILS_VERSION)" 		>>$(DIFFUTILS_IPKG_TMP)/CONTROL/control
	echo "Depends: " 				>>$(DIFFUTILS_IPKG_TMP)/CONTROL/control
	echo "Description: the GNU diff, diff3, sdiff, and cmp utilities.">>$(DIFFUTILS_IPKG_TMP)/CONTROL/control
	cd $(FEEDDIR) && $(XMKIPKG) $(DIFFUTILS_IPKG_TMP)
	touch $@

# ----------------------------------------------------------------------------
# Image-Install
# ----------------------------------------------------------------------------

ifdef PTXCONF_DIFFUTILS_INSTALL
ROMPACKAGES += $(STATEDIR)/diffutils.imageinstall
endif

diffutils_imageinstall_deps = $(STATEDIR)/diffutils.targetinstall \
	$(STATEDIR)/virtual-image.install

$(STATEDIR)/diffutils.imageinstall: $(diffutils_imageinstall_deps)
	@$(call targetinfo, $@)
	cd $(FEEDDIR) && $(XIPKG) install diffutils
	touch $@

# ----------------------------------------------------------------------------
# Clean
# ----------------------------------------------------------------------------

diffutils_clean:
	rm -rf $(STATEDIR)/diffutils.*
	rm -rf $(DIFFUTILS_DIR)

# vim: syntax=make
