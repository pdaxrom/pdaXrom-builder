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
ifdef PTXCONF_M4
PACKAGES += m4
endif

#
# Paths and names
#
M4_VERSION	= 1.4
M4		= m4-$(M4_VERSION)
M4_SUFFIX	= tar.gz
M4_URL		= ftp://ftp.gnu.org/gnu/m4/$(M4).$(M4_SUFFIX)
M4_SOURCE	= $(SRCDIR)/$(M4).$(M4_SUFFIX)
M4_DIR		= $(BUILDDIR)/$(M4)
M4_IPKG_TMP	= $(M4_DIR)/ipkg_tmp

# ----------------------------------------------------------------------------
# Get
# ----------------------------------------------------------------------------

m4_get: $(STATEDIR)/m4.get

m4_get_deps = $(M4_SOURCE)

$(STATEDIR)/m4.get: $(m4_get_deps)
	@$(call targetinfo, $@)
	@$(call get_patches, $(M4))
	touch $@

$(M4_SOURCE):
	@$(call targetinfo, $@)
	@$(call get, $(M4_URL))

# ----------------------------------------------------------------------------
# Extract
# ----------------------------------------------------------------------------

m4_extract: $(STATEDIR)/m4.extract

m4_extract_deps = $(STATEDIR)/m4.get

$(STATEDIR)/m4.extract: $(m4_extract_deps)
	@$(call targetinfo, $@)
	@$(call clean, $(M4_DIR))
	@$(call extract, $(M4_SOURCE))
	@$(call patchin, $(M4))
	touch $@

# ----------------------------------------------------------------------------
# Prepare
# ----------------------------------------------------------------------------

m4_prepare: $(STATEDIR)/m4.prepare

#
# dependencies
#
m4_prepare_deps = \
	$(STATEDIR)/m4.extract \
	$(STATEDIR)/virtual-xchain.install

M4_PATH	=  PATH=$(CROSS_PATH)
M4_ENV 	=  $(CROSS_ENV)
#M4_ENV	+=
M4_ENV	+= PKG_CONFIG_PATH=$(CROSS_LIB_DIR)/lib/pkgconfig:$(CROSS_LIB_DIR)/lib/pkgconfig
#ifdef PTXCONF_XFREE430
#M4_ENV	+= LDFLAGS=-Wl,-rpath-link,$(CROSS_LIB_DIR)/lib
#endif

#
# autoconf
#
M4_AUTOCONF = \
	--build=$(GNU_HOST) \
	--host=$(PTXCONF_GNU_TARGET) \
	--prefix=$(PTXCONF_NATIVE_PREFIX)

ifdef PTXCONF_XFREE430
M4_AUTOCONF += --x-includes=$(CROSS_LIB_DIR)/include
M4_AUTOCONF += --x-libraries=$(CROSS_LIB_DIR)/lib
endif

$(STATEDIR)/m4.prepare: $(m4_prepare_deps)
	@$(call targetinfo, $@)
	@$(call clean, $(M4_DIR)/config.cache)
	cd $(M4_DIR) && \
		$(M4_PATH) $(M4_ENV) \
		./configure $(M4_AUTOCONF)
	touch $@

# ----------------------------------------------------------------------------
# Compile
# ----------------------------------------------------------------------------

m4_compile: $(STATEDIR)/m4.compile

m4_compile_deps = $(STATEDIR)/m4.prepare

$(STATEDIR)/m4.compile: $(m4_compile_deps)
	@$(call targetinfo, $@)
	$(M4_PATH) $(MAKE) -C $(M4_DIR)
	touch $@

# ----------------------------------------------------------------------------
# Install
# ----------------------------------------------------------------------------

m4_install: $(STATEDIR)/m4.install

$(STATEDIR)/m4.install: $(STATEDIR)/m4.compile
	@$(call targetinfo, $@)
	###$(M4_PATH) $(MAKE) -C $(M4_DIR) install
	touch $@

# ----------------------------------------------------------------------------
# Target-Install
# ----------------------------------------------------------------------------

m4_targetinstall: $(STATEDIR)/m4.targetinstall

m4_targetinstall_deps = $(STATEDIR)/m4.compile

$(STATEDIR)/m4.targetinstall: $(m4_targetinstall_deps)
	@$(call targetinfo, $@)
	$(M4_PATH) $(MAKE) -C $(M4_DIR) prefix=$(M4_IPKG_TMP)$(PTXCONF_NATIVE_PREFIX) install
	$(CROSSSTRIP) $(M4_IPKG_TMP)$(PTXCONF_NATIVE_PREFIX)/bin/m4
	rm -rf $(M4_IPKG_TMP)$(PTXCONF_NATIVE_PREFIX)/info
	mkdir -p $(M4_IPKG_TMP)/CONTROL
	echo "Package: m4" 				>$(M4_IPKG_TMP)/CONTROL/control
	echo "Priority: optional" 			>>$(M4_IPKG_TMP)/CONTROL/control
	echo "Section: Utils" 				>>$(M4_IPKG_TMP)/CONTROL/control
	echo "Maintainer: Alexander Chukov <sash@pdaXrom.org>">>$(M4_IPKG_TMP)/CONTROL/control
	echo "Architecture: $(SHORT_TARGET)" 		>>$(M4_IPKG_TMP)/CONTROL/control
	echo "Version: $(M4_VERSION)" 			>>$(M4_IPKG_TMP)/CONTROL/control
	echo "Depends: " 				>>$(M4_IPKG_TMP)/CONTROL/control
	echo "Description: GNU m4 is an implementation of the traditional Unix macro processor.">>$(M4_IPKG_TMP)/CONTROL/control
	cd $(FEEDDIR) && $(XMKIPKG) $(M4_IPKG_TMP)
	touch $@

# ----------------------------------------------------------------------------
# Image-Install
# ----------------------------------------------------------------------------

ifdef PTXCONF_M4_INSTALL
ROMPACKAGES += $(STATEDIR)/m4.imageinstall
endif

m4_imageinstall_deps = $(STATEDIR)/m4.targetinstall \
	$(STATEDIR)/virtual-image.install

$(STATEDIR)/m4.imageinstall: $(m4_imageinstall_deps)
	@$(call targetinfo, $@)
	cd $(FEEDDIR) && $(XIPKG) install m4
	touch $@

# ----------------------------------------------------------------------------
# Clean
# ----------------------------------------------------------------------------

m4_clean:
	rm -rf $(STATEDIR)/m4.*
	rm -rf $(M4_DIR)

# vim: syntax=make
