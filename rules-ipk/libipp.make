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
ifdef PTXCONF_LIBIPP
PACKAGES += libipp
endif

#
# Paths and names
#
LIBIPP_VERSION		= 3.0
LIBIPP			= ipp_arm_lnx
LIBIPP_SUFFIX		= tar.bz2
LIBIPP_URL		= http://www.pdaXrom.org/src/$(LIBIPP).$(LIBIPP_SUFFIX)
LIBIPP_SOURCE		= $(SRCDIR)/$(LIBIPP).$(LIBIPP_SUFFIX)
LIBIPP_DIR		= $(BUILDDIR)/ipp
LIBIPP_IPKG_TMP		= $(LIBIPP_DIR)/ipkg_tmp

# ----------------------------------------------------------------------------
# Get
# ----------------------------------------------------------------------------

libipp_get: $(STATEDIR)/libipp.get

libipp_get_deps = $(LIBIPP_SOURCE)

$(STATEDIR)/libipp.get: $(libipp_get_deps)
	@$(call targetinfo, $@)
	@$(call get_patches, $(LIBIPP))
	touch $@

$(LIBIPP_SOURCE):
	@$(call targetinfo, $@)
	@$(call get, $(LIBIPP_URL))

# ----------------------------------------------------------------------------
# Extract
# ----------------------------------------------------------------------------

libipp_extract: $(STATEDIR)/libipp.extract

libipp_extract_deps = $(STATEDIR)/libipp.get

$(STATEDIR)/libipp.extract: $(libipp_extract_deps)
	@$(call targetinfo, $@)
	@$(call clean, $(LIBIPP_DIR))
	@$(call extract, $(LIBIPP_SOURCE))
	@$(call patchin, $(LIBIPP))
	touch $@

# ----------------------------------------------------------------------------
# Prepare
# ----------------------------------------------------------------------------

libipp_prepare: $(STATEDIR)/libipp.prepare

#
# dependencies
#
libipp_prepare_deps = \
	$(STATEDIR)/libipp.extract \
	$(STATEDIR)/virtual-xchain.install

LIBIPP_PATH	=  PATH=$(CROSS_PATH)
LIBIPP_ENV 	=  $(CROSS_ENV)
#LIBIPP_ENV	+=
LIBIPP_ENV	+= PKG_CONFIG_PATH=$(CROSS_LIB_DIR)/lib/pkgconfig:$(CROSS_LIB_DIR)/lib/pkgconfig
#ifdef PTXCONF_XFREE430
#LIBIPP_ENV	+= LDFLAGS=-Wl,-rpath-link,$(CROSS_LIB_DIR)/lib
#endif

#
# autoconf
#
LIBIPP_AUTOCONF = \
	--build=$(GNU_HOST) \
	--host=$(PTXCONF_GNU_TARGET) \
	--prefix=/usr

ifdef PTXCONF_XFREE430
LIBIPP_AUTOCONF += --x-includes=$(CROSS_LIB_DIR)/include
LIBIPP_AUTOCONF += --x-libraries=$(CROSS_LIB_DIR)/lib
endif

$(STATEDIR)/libipp.prepare: $(libipp_prepare_deps)
	@$(call targetinfo, $@)
	@$(call clean, $(LIBIPP_DIR)/config.cache)
	#cd $(LIBIPP_DIR) && \
	#	$(LIBIPP_PATH) $(LIBIPP_ENV) \
	#	./configure $(LIBIPP_AUTOCONF)
	rm -f $(LIBIPP_DIR)/include $(LIBIPP_DIR)/lib
ifdef PTXCONF_ARM_ARCH_PXA
	ln -sf include.pxa	$(LIBIPP_DIR)/include
	ln -sf lib.pxa		$(LIBIPP_DIR)/lib
endif
ifdef PTXCONF_ARM_ARCH_SA1100
	ln -sf include.sa	$(LIBIPP_DIR)/include
	ln -sf lib.sa1100	$(LIBIPP_DIR)/lib
endif
	touch $@

# ----------------------------------------------------------------------------
# Compile
# ----------------------------------------------------------------------------

libipp_compile: $(STATEDIR)/libipp.compile

libipp_compile_deps = $(STATEDIR)/libipp.prepare

$(STATEDIR)/libipp.compile: $(libipp_compile_deps)
	@$(call targetinfo, $@)
	touch $@

# ----------------------------------------------------------------------------
# Install
# ----------------------------------------------------------------------------

libipp_install: $(STATEDIR)/libipp.install

$(STATEDIR)/libipp.install: $(STATEDIR)/libipp.compile
	@$(call targetinfo, $@)
	touch $@

# ----------------------------------------------------------------------------
# Target-Install
# ----------------------------------------------------------------------------

libipp_targetinstall: $(STATEDIR)/libipp.targetinstall

libipp_targetinstall_deps = $(STATEDIR)/libipp.compile

$(STATEDIR)/libipp.targetinstall: $(libipp_targetinstall_deps)
	@$(call targetinfo, $@)
	asdasd
	$(LIBIPP_PATH) $(MAKE) -C $(LIBIPP_DIR) DESTDIR=$(LIBIPP_IPKG_TMP) install
	mkdir -p $(LIBIPP_IPKG_TMP)/CONTROL
	echo "Package: libipp" 			>$(LIBIPP_IPKG_TMP)/CONTROL/control
	echo "Priority: optional" 			>>$(LIBIPP_IPKG_TMP)/CONTROL/control
	echo "Section: pdaXrom" 			>>$(LIBIPP_IPKG_TMP)/CONTROL/control
	echo "Maintainer: Alexander Chukov <sash@pdaXrom.org>" 			>>$(LIBIPP_IPKG_TMP)/CONTROL/control
	echo "Architecture: $(SHORT_TARGET)" 		>>$(LIBIPP_IPKG_TMP)/CONTROL/control
	echo "Version: $(LIBIPP_VERSION)" 		>>$(LIBIPP_IPKG_TMP)/CONTROL/control
	echo "Depends: " 				>>$(LIBIPP_IPKG_TMP)/CONTROL/control
	echo "Description: generated with pdaXrom builder">>$(LIBIPP_IPKG_TMP)/CONTROL/control
	cd $(FEEDDIR) && $(XMKIPKG) $(LIBIPP_IPKG_TMP)
	touch $@

# ----------------------------------------------------------------------------
# Image-Install
# ----------------------------------------------------------------------------

ifdef PTXCONF_LIBIPP_INSTALL
ROMPACKAGES += $(STATEDIR)/libipp.imageinstall
endif

libipp_imageinstall_deps = $(STATEDIR)/libipp.targetinstall \
	$(STATEDIR)/virtual-image.install

$(STATEDIR)/libipp.imageinstall: $(libipp_imageinstall_deps)
	@$(call targetinfo, $@)
	cd $(FEEDDIR) && $(XIPKG) install libipp
	touch $@

# ----------------------------------------------------------------------------
# Clean
# ----------------------------------------------------------------------------

libipp_clean:
	rm -rf $(STATEDIR)/libipp.*
	rm -rf $(LIBIPP_DIR)

# vim: syntax=make
