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
ifdef PTXCONF_NXCOMP
PACKAGES += nxcomp
endif

#
# Paths and names
#
NXCOMP_VERSION		= 1.3.2-4
NXCOMP			= nxcomp-$(NXCOMP_VERSION)
NXCOMP_SUFFIX		= tar.gz
NXCOMP_URL		= http://www.nomachine.com/source/$(NXCOMP).$(NXCOMP_SUFFIX)
NXCOMP_SOURCE		= $(SRCDIR)/$(NXCOMP).$(NXCOMP_SUFFIX)
NXCOMP_DIR		= $(BUILDDIR)/nxcomp
NXCOMP_IPKG_TMP		= $(NXCOMP_DIR)/ipkg_tmp

# ----------------------------------------------------------------------------
# Get
# ----------------------------------------------------------------------------

nxcomp_get: $(STATEDIR)/nxcomp.get

nxcomp_get_deps = $(NXCOMP_SOURCE)

$(STATEDIR)/nxcomp.get: $(nxcomp_get_deps)
	@$(call targetinfo, $@)
	@$(call get_patches, $(NXCOMP))
	touch $@

$(NXCOMP_SOURCE):
	@$(call targetinfo, $@)
	@$(call get, $(NXCOMP_URL))

# ----------------------------------------------------------------------------
# Extract
# ----------------------------------------------------------------------------

nxcomp_extract: $(STATEDIR)/nxcomp.extract

nxcomp_extract_deps = $(STATEDIR)/nxcomp.get

$(STATEDIR)/nxcomp.extract: $(nxcomp_extract_deps)
	@$(call targetinfo, $@)
	@$(call clean, $(NXCOMP_DIR))
	@$(call extract, $(NXCOMP_SOURCE))
	@$(call patchin, $(NXCOMP), $(NXCOMP_DIR))
	touch $@

# ----------------------------------------------------------------------------
# Prepare
# ----------------------------------------------------------------------------

nxcomp_prepare: $(STATEDIR)/nxcomp.prepare

#
# dependencies
#
nxcomp_prepare_deps = \
	$(STATEDIR)/nxcomp.extract \
	$(STATEDIR)/virtual-xchain.install

NXCOMP_PATH	=  PATH=$(CROSS_PATH)
NXCOMP_ENV 	=  $(CROSS_ENV)
NXCOMP_ENV	+= CFLAGS="$(TARGET_OPT_CFLAGS) -Wno-deprecated"
NXCOMP_ENV	+= CXXFLAGS="$(TARGET_OPT_CFLAGS) -Wno-deprecated"
NXCOMP_ENV	+= PKG_CONFIG_PATH=$(CROSS_LIB_DIR)/lib/pkgconfig:$(CROSS_LIB_DIR)/lib/pkgconfig
#ifdef PTXCONF_XFREE430
#NXCOMP_ENV	+= LDFLAGS=-Wl,-rpath-link,$(CROSS_LIB_DIR)/lib
#endif

#
# autoconf
#
NXCOMP_AUTOCONF = \
	--build=$(GNU_HOST) \
	--host=$(PTXCONF_GNU_TARGET) \
	--prefix=/usr \
	--disable-static \
	--enable-shared

ifdef PTXCONF_XFREE430
NXCOMP_AUTOCONF += --x-includes=$(CROSS_LIB_DIR)/include
NXCOMP_AUTOCONF += --x-libraries=$(CROSS_LIB_DIR)/lib
endif

$(STATEDIR)/nxcomp.prepare: $(nxcomp_prepare_deps)
	@$(call targetinfo, $@)
	@$(call clean, $(NXCOMP_DIR)/config.cache)
	cd $(NXCOMP_DIR) && aclocal
	#cd $(NXCOMP_DIR) && automake --add-missing
	cd $(NXCOMP_DIR) && autoconf
	cd $(NXCOMP_DIR) && \
		$(NXCOMP_PATH) $(NXCOMP_ENV) \
		./configure $(NXCOMP_AUTOCONF)
	touch $@

# ----------------------------------------------------------------------------
# Compile
# ----------------------------------------------------------------------------

nxcomp_compile: $(STATEDIR)/nxcomp.compile

nxcomp_compile_deps = $(STATEDIR)/nxcomp.prepare

$(STATEDIR)/nxcomp.compile: $(nxcomp_compile_deps)
	@$(call targetinfo, $@)
	$(NXCOMP_PATH) $(MAKE) -C $(NXCOMP_DIR)
	touch $@

# ----------------------------------------------------------------------------
# Install
# ----------------------------------------------------------------------------

nxcomp_install: $(STATEDIR)/nxcomp.install

$(STATEDIR)/nxcomp.install: $(STATEDIR)/nxcomp.compile
	@$(call targetinfo, $@)
	asdasd
	touch $@

# ----------------------------------------------------------------------------
# Target-Install
# ----------------------------------------------------------------------------

nxcomp_targetinstall: $(STATEDIR)/nxcomp.targetinstall

nxcomp_targetinstall_deps = $(STATEDIR)/nxcomp.compile

$(STATEDIR)/nxcomp.targetinstall: $(nxcomp_targetinstall_deps)
	@$(call targetinfo, $@)
	$(NXCOMP_PATH) $(MAKE) -C $(NXCOMP_DIR) DESTDIR=$(NXCOMP_IPKG_TMP) install
	mkdir -p $(NXCOMP_IPKG_TMP)/CONTROL
	echo "Package: nxcomp" 			>$(NXCOMP_IPKG_TMP)/CONTROL/control
	echo "Priority: optional" 			>>$(NXCOMP_IPKG_TMP)/CONTROL/control
	echo "Section: pdaXrom" 			>>$(NXCOMP_IPKG_TMP)/CONTROL/control
	echo "Maintainer: Alexander Chukov <sash@pdaXrom.org>" 			>>$(NXCOMP_IPKG_TMP)/CONTROL/control
	echo "Architecture: $(SHORT_TARGET)" 		>>$(NXCOMP_IPKG_TMP)/CONTROL/control
	echo "Version: $(NXCOMP_VERSION)" 		>>$(NXCOMP_IPKG_TMP)/CONTROL/control
	echo "Depends: " 				>>$(NXCOMP_IPKG_TMP)/CONTROL/control
	echo "Description: generated with pdaXrom builder">>$(NXCOMP_IPKG_TMP)/CONTROL/control
	asdasd
	cd $(FEEDDIR) && $(XMKIPKG) $(NXCOMP_IPKG_TMP)
	touch $@

# ----------------------------------------------------------------------------
# Image-Install
# ----------------------------------------------------------------------------

ifdef PTXCONF_NXCOMP_INSTALL
ROMPACKAGES += $(STATEDIR)/nxcomp.imageinstall
endif

nxcomp_imageinstall_deps = $(STATEDIR)/nxcomp.targetinstall \
	$(STATEDIR)/virtual-image.install

$(STATEDIR)/nxcomp.imageinstall: $(nxcomp_imageinstall_deps)
	@$(call targetinfo, $@)
	cd $(FEEDDIR) && $(XIPKG) install nxcomp
	touch $@

# ----------------------------------------------------------------------------
# Clean
# ----------------------------------------------------------------------------

nxcomp_clean:
	rm -rf $(STATEDIR)/nxcomp.*
	rm -rf $(NXCOMP_DIR)

# vim: syntax=make
