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
ifdef PTXCONF_NXCOMPEXT
PACKAGES += nxcompext
endif

#
# Paths and names
#
NXCOMPEXT_VERSION	= 1.3.2-6
NXCOMPEXT		= nxcompext-$(NXCOMPEXT_VERSION)
NXCOMPEXT_SUFFIX	= tar.gz
NXCOMPEXT_URL		= http://www.nomachine.com/source/$(NXCOMPEXT).$(NXCOMPEXT_SUFFIX)
NXCOMPEXT_SOURCE	= $(SRCDIR)/$(NXCOMPEXT).$(NXCOMPEXT_SUFFIX)
NXCOMPEXT_DIR		= $(BUILDDIR)/nxcompext
NXCOMPEXT_IPKG_TMP	= $(NXCOMPEXT_DIR)/ipkg_tmp

# ----------------------------------------------------------------------------
# Get
# ----------------------------------------------------------------------------

nxcompext_get: $(STATEDIR)/nxcompext.get

nxcompext_get_deps = $(NXCOMPEXT_SOURCE)

$(STATEDIR)/nxcompext.get: $(nxcompext_get_deps)
	@$(call targetinfo, $@)
	@$(call get_patches, $(NXCOMPEXT))
	touch $@

$(NXCOMPEXT_SOURCE):
	@$(call targetinfo, $@)
	@$(call get, $(NXCOMPEXT_URL))

# ----------------------------------------------------------------------------
# Extract
# ----------------------------------------------------------------------------

nxcompext_extract: $(STATEDIR)/nxcompext.extract

nxcompext_extract_deps = $(STATEDIR)/nxcompext.get

$(STATEDIR)/nxcompext.extract: $(nxcompext_extract_deps)
	@$(call targetinfo, $@)
	@$(call clean, $(NXCOMPEXT_DIR))
	@$(call extract, $(NXCOMPEXT_SOURCE))
	@$(call patchin, $(NXCOMPEXT), $(NXCOMPEXT_DIR))
	touch $@

# ----------------------------------------------------------------------------
# Prepare
# ----------------------------------------------------------------------------

nxcompext_prepare: $(STATEDIR)/nxcompext.prepare

#
# dependencies
#
nxcompext_prepare_deps = \
	$(STATEDIR)/nxcompext.extract \
	$(STATEDIR)/virtual-xchain.install

NXCOMPEXT_PATH	=  PATH=$(CROSS_PATH)
NXCOMPEXT_ENV 	=  $(CROSS_ENV)
#NXCOMPEXT_ENV	+=
NXCOMPEXT_ENV	+= PKG_CONFIG_PATH=$(CROSS_LIB_DIR)/lib/pkgconfig:$(CROSS_LIB_DIR)/lib/pkgconfig
#ifdef PTXCONF_XFREE430
#NXCOMPEXT_ENV	+= LDFLAGS=-Wl,-rpath-link,$(CROSS_LIB_DIR)/lib
#endif

#
# autoconf
#
NXCOMPEXT_AUTOCONF = \
	--build=$(GNU_HOST) \
	--host=$(PTXCONF_GNU_TARGET) \
	--prefix=/usr

ifdef PTXCONF_XFREE430
NXCOMPEXT_AUTOCONF += --x-includes=$(CROSS_LIB_DIR)/include
NXCOMPEXT_AUTOCONF += --x-libraries=$(CROSS_LIB_DIR)/lib
endif

$(STATEDIR)/nxcompext.prepare: $(nxcompext_prepare_deps)
	@$(call targetinfo, $@)
	@$(call clean, $(NXCOMPEXT_DIR)/config.cache)
	cd $(NXCOMPEXT_DIR) && aclocal
	#cd $(NXCOMPEXT_DIR) && automake --add-missing
	cd $(NXCOMPEXT_DIR) && autoconf
	cd $(NXCOMPEXT_DIR) && \
		$(NXCOMPEXT_PATH) $(NXCOMPEXT_ENV) \
		./configure $(NXCOMPEXT_AUTOCONF)
	touch $@

# ----------------------------------------------------------------------------
# Compile
# ----------------------------------------------------------------------------

nxcompext_compile: $(STATEDIR)/nxcompext.compile

nxcompext_compile_deps = $(STATEDIR)/nxcompext.prepare

$(STATEDIR)/nxcompext.compile: $(nxcompext_compile_deps)
	@$(call targetinfo, $@)
	$(NXCOMPEXT_PATH) $(MAKE) -C $(NXCOMPEXT_DIR)
	touch $@

# ----------------------------------------------------------------------------
# Install
# ----------------------------------------------------------------------------

nxcompext_install: $(STATEDIR)/nxcompext.install

$(STATEDIR)/nxcompext.install: $(STATEDIR)/nxcompext.compile
	@$(call targetinfo, $@)
	asdasd
	touch $@

# ----------------------------------------------------------------------------
# Target-Install
# ----------------------------------------------------------------------------

nxcompext_targetinstall: $(STATEDIR)/nxcompext.targetinstall

nxcompext_targetinstall_deps = $(STATEDIR)/nxcompext.compile

$(STATEDIR)/nxcompext.targetinstall: $(nxcompext_targetinstall_deps)
	@$(call targetinfo, $@)
	$(NXCOMPEXT_PATH) $(MAKE) -C $(NXCOMPEXT_DIR) DESTDIR=$(NXCOMPEXT_IPKG_TMP) install
	mkdir -p $(NXCOMPEXT_IPKG_TMP)/CONTROL
	echo "Package: nxcompext" 			>$(NXCOMPEXT_IPKG_TMP)/CONTROL/control
	echo "Priority: optional" 			>>$(NXCOMPEXT_IPKG_TMP)/CONTROL/control
	echo "Section: pdaXrom" 			>>$(NXCOMPEXT_IPKG_TMP)/CONTROL/control
	echo "Maintainer: Alexander Chukov <sash@pdaXrom.org>" 			>>$(NXCOMPEXT_IPKG_TMP)/CONTROL/control
	echo "Architecture: $(SHORT_TARGET)" 		>>$(NXCOMPEXT_IPKG_TMP)/CONTROL/control
	echo "Version: $(NXCOMPEXT_VERSION)" 		>>$(NXCOMPEXT_IPKG_TMP)/CONTROL/control
	echo "Depends: " 				>>$(NXCOMPEXT_IPKG_TMP)/CONTROL/control
	echo "Description: generated with pdaXrom builder">>$(NXCOMPEXT_IPKG_TMP)/CONTROL/control
	asdasd
	cd $(FEEDDIR) && $(XMKIPKG) $(NXCOMPEXT_IPKG_TMP)
	touch $@

# ----------------------------------------------------------------------------
# Image-Install
# ----------------------------------------------------------------------------

ifdef PTXCONF_NXCOMPEXT_INSTALL
ROMPACKAGES += $(STATEDIR)/nxcompext.imageinstall
endif

nxcompext_imageinstall_deps = $(STATEDIR)/nxcompext.targetinstall \
	$(STATEDIR)/virtual-image.install

$(STATEDIR)/nxcompext.imageinstall: $(nxcompext_imageinstall_deps)
	@$(call targetinfo, $@)
	cd $(FEEDDIR) && $(XIPKG) install nxcompext
	touch $@

# ----------------------------------------------------------------------------
# Clean
# ----------------------------------------------------------------------------

nxcompext_clean:
	rm -rf $(STATEDIR)/nxcompext.*
	rm -rf $(NXCOMPEXT_DIR)

# vim: syntax=make
