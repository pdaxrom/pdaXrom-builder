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
ifdef PTXCONF_SED
PACKAGES += sed
endif

#
# Paths and names
#
SED_VERSION	= 4.0.9
SED		= sed-$(SED_VERSION)
SED_SUFFIX	= tar.gz
SED_URL		= ftp://ftp.gnu.org/gnu/sed/$(SED).$(SED_SUFFIX)
SED_SOURCE	= $(SRCDIR)/$(SED).$(SED_SUFFIX)
SED_DIR		= $(BUILDDIR)/$(SED)
SED_IPKG_TMP	= $(SED_DIR)/ipkg_tmp

# ----------------------------------------------------------------------------
# Get
# ----------------------------------------------------------------------------

sed_get: $(STATEDIR)/sed.get

sed_get_deps = $(SED_SOURCE)

$(STATEDIR)/sed.get: $(sed_get_deps)
	@$(call targetinfo, $@)
	@$(call get_patches, $(SED))
	touch $@

$(SED_SOURCE):
	@$(call targetinfo, $@)
	@$(call get, $(SED_URL))

# ----------------------------------------------------------------------------
# Extract
# ----------------------------------------------------------------------------

sed_extract: $(STATEDIR)/sed.extract

sed_extract_deps = $(STATEDIR)/sed.get

$(STATEDIR)/sed.extract: $(sed_extract_deps)
	@$(call targetinfo, $@)
	@$(call clean, $(SED_DIR))
	@$(call extract, $(SED_SOURCE))
	@$(call patchin, $(SED))
	touch $@

# ----------------------------------------------------------------------------
# Prepare
# ----------------------------------------------------------------------------

sed_prepare: $(STATEDIR)/sed.prepare

#
# dependencies
#
sed_prepare_deps = \
	$(STATEDIR)/sed.extract \
	$(STATEDIR)/virtual-xchain.install

SED_PATH	=  PATH=$(CROSS_PATH)
SED_ENV 	=  $(CROSS_ENV)
#SED_ENV	+=
SED_ENV	+= PKG_CONFIG_PATH=$(CROSS_LIB_DIR)/lib/pkgconfig:$(CROSS_LIB_DIR)/lib/pkgconfig
#ifdef PTXCONF_XFREE430
#SED_ENV	+= LDFLAGS=-Wl,-rpath-link,$(CROSS_LIB_DIR)/lib
#endif

#
# autoconf
#
SED_AUTOCONF = \
	--build=$(GNU_HOST) \
	--host=$(PTXCONF_GNU_TARGET) \
	--prefix=$(PTXCONF_NATIVE_PREFIX)

ifdef PTXCONF_XFREE430
SED_AUTOCONF += --x-includes=$(CROSS_LIB_DIR)/include
SED_AUTOCONF += --x-libraries=$(CROSS_LIB_DIR)/lib
endif

$(STATEDIR)/sed.prepare: $(sed_prepare_deps)
	@$(call targetinfo, $@)
	@$(call clean, $(SED_DIR)/config.cache)
	cd $(SED_DIR) && \
		$(SED_PATH) $(SED_ENV) \
		./configure $(SED_AUTOCONF)
	touch $@

# ----------------------------------------------------------------------------
# Compile
# ----------------------------------------------------------------------------

sed_compile: $(STATEDIR)/sed.compile

sed_compile_deps = $(STATEDIR)/sed.prepare

$(STATEDIR)/sed.compile: $(sed_compile_deps)
	@$(call targetinfo, $@)
	$(SED_PATH) $(MAKE) -C $(SED_DIR)
	touch $@

# ----------------------------------------------------------------------------
# Install
# ----------------------------------------------------------------------------

sed_install: $(STATEDIR)/sed.install

$(STATEDIR)/sed.install: $(STATEDIR)/sed.compile
	@$(call targetinfo, $@)
	###$(SED_PATH) $(MAKE) -C $(SED_DIR) install
	touch $@

# ----------------------------------------------------------------------------
# Target-Install
# ----------------------------------------------------------------------------

sed_targetinstall: $(STATEDIR)/sed.targetinstall

sed_targetinstall_deps = $(STATEDIR)/sed.compile

$(STATEDIR)/sed.targetinstall: $(sed_targetinstall_deps)
	@$(call targetinfo, $@)
	$(SED_PATH) $(MAKE) -C $(SED_DIR) DESTDIR=$(SED_IPKG_TMP) install
	$(CROSSSTRIP) $(SED_IPKG_TMP)$(PTXCONF_NATIVE_PREFIX)/bin/sed
	rm -rf $(SED_IPKG_TMP)$(PTXCONF_NATIVE_PREFIX)/info
	rm -rf $(SED_IPKG_TMP)$(PTXCONF_NATIVE_PREFIX)/man
	rm -rf $(SED_IPKG_TMP)$(PTXCONF_NATIVE_PREFIX)/share
	mkdir -p $(SED_IPKG_TMP)/CONTROL
	echo "Package: sed" 				>$(SED_IPKG_TMP)/CONTROL/control
	echo "Priority: optional" 			>>$(SED_IPKG_TMP)/CONTROL/control
	echo "Section: Utils"	 			>>$(SED_IPKG_TMP)/CONTROL/control
	echo "Maintainer: Alexander Chukov <sash@pdaXrom.org>">>$(SED_IPKG_TMP)/CONTROL/control
	echo "Architecture: $(SHORT_TARGET)" 		>>$(SED_IPKG_TMP)/CONTROL/control
	echo "Version: $(SED_VERSION)" 			>>$(SED_IPKG_TMP)/CONTROL/control
	echo "Depends: " 				>>$(SED_IPKG_TMP)/CONTROL/control
	echo "Description: a stream editor.">>$(SED_IPKG_TMP)/CONTROL/control
	cd $(FEEDDIR) && $(XMKIPKG) $(SED_IPKG_TMP)
	touch $@

# ----------------------------------------------------------------------------
# Image-Install
# ----------------------------------------------------------------------------

ifdef PTXCONF_SED_INSTALL
ROMPACKAGES += $(STATEDIR)/sed.imageinstall
endif

sed_imageinstall_deps = $(STATEDIR)/sed.targetinstall \
	$(STATEDIR)/virtual-image.install

$(STATEDIR)/sed.imageinstall: $(sed_imageinstall_deps)
	@$(call targetinfo, $@)
	cd $(FEEDDIR) && $(XIPKG) install sed
	touch $@

# ----------------------------------------------------------------------------
# Clean
# ----------------------------------------------------------------------------

sed_clean:
	rm -rf $(STATEDIR)/sed.*
	rm -rf $(SED_DIR)

# vim: syntax=make
