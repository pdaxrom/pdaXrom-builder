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
ifdef PTXCONF_XMMS-TREMOR
PACKAGES += xmms-tremor
endif

#
# Paths and names
#
XMMS-TREMOR_VERSION	= 1.0
XMMS-TREMOR		= xmms-tremor-$(XMMS-TREMOR_VERSION)
XMMS-TREMOR_SUFFIX	= tar.bz2
XMMS-TREMOR_URL		= http://www.pdaxrom.org/src/$(XMMS-TREMOR).$(XMMS-TREMOR_SUFFIX)
XMMS-TREMOR_SOURCE	= $(SRCDIR)/$(XMMS-TREMOR).$(XMMS-TREMOR_SUFFIX)
XMMS-TREMOR_DIR		= $(BUILDDIR)/$(XMMS-TREMOR)
XMMS-TREMOR_IPKG_TMP	= $(XMMS-TREMOR_DIR)/ipkg_tmp

# ----------------------------------------------------------------------------
# Get
# ----------------------------------------------------------------------------

xmms-tremor_get: $(STATEDIR)/xmms-tremor.get

xmms-tremor_get_deps = $(XMMS-TREMOR_SOURCE)

$(STATEDIR)/xmms-tremor.get: $(xmms-tremor_get_deps)
	@$(call targetinfo, $@)
	@$(call get_patches, $(XMMS-TREMOR))
	touch $@

$(XMMS-TREMOR_SOURCE):
	@$(call targetinfo, $@)
	@$(call get, $(XMMS-TREMOR_URL))

# ----------------------------------------------------------------------------
# Extract
# ----------------------------------------------------------------------------

xmms-tremor_extract: $(STATEDIR)/xmms-tremor.extract

xmms-tremor_extract_deps = $(STATEDIR)/xmms-tremor.get

$(STATEDIR)/xmms-tremor.extract: $(xmms-tremor_extract_deps)
	@$(call targetinfo, $@)
	@$(call clean, $(XMMS-TREMOR_DIR))
	@$(call extract, $(XMMS-TREMOR_SOURCE))
	@$(call patchin, $(XMMS-TREMOR))
	touch $@

# ----------------------------------------------------------------------------
# Prepare
# ----------------------------------------------------------------------------

xmms-tremor_prepare: $(STATEDIR)/xmms-tremor.prepare

#
# dependencies
#
xmms-tremor_prepare_deps = \
	$(STATEDIR)/xmms-tremor.extract \
	$(STATEDIR)/tremor.install \
	$(STATEDIR)/xmms.install \
	$(STATEDIR)/virtual-xchain.install

XMMS-TREMOR_PATH	=  PATH=$(CROSS_PATH)
XMMS-TREMOR_ENV 	=  $(CROSS_ENV)
#XMMS-TREMOR_ENV	+=
XMMS-TREMOR_ENV	+= PKG_CONFIG_PATH=$(CROSS_LIB_DIR)/lib/pkgconfig:$(CROSS_LIB_DIR)/lib/pkgconfig
#ifdef PTXCONF_XFREE430
#XMMS-TREMOR_ENV	+= LDFLAGS=-Wl,-rpath-link,$(CROSS_LIB_DIR)/lib
#endif

#
# autoconf
#
XMMS-TREMOR_AUTOCONF = \
	--build=$(GNU_HOST) \
	--host=$(PTXCONF_GNU_TARGET) \
	--prefix=/usr

ifdef PTXCONF_XFREE430
XMMS-TREMOR_AUTOCONF += --x-includes=$(CROSS_LIB_DIR)/include
XMMS-TREMOR_AUTOCONF += --x-libraries=$(CROSS_LIB_DIR)/lib
endif

$(STATEDIR)/xmms-tremor.prepare: $(xmms-tremor_prepare_deps)
	@$(call targetinfo, $@)
	@$(call clean, $(XMMS-TREMOR_DIR)/config.cache)
	cd $(XMMS-TREMOR_DIR) && \
		$(XMMS-TREMOR_PATH) $(XMMS-TREMOR_ENV) \
		./configure $(XMMS-TREMOR_AUTOCONF)
	cp -f $(PTXCONF_PREFIX)/bin/libtool $(XMMS-TREMOR_DIR)
	touch $@

# ----------------------------------------------------------------------------
# Compile
# ----------------------------------------------------------------------------

xmms-tremor_compile: $(STATEDIR)/xmms-tremor.compile

xmms-tremor_compile_deps = $(STATEDIR)/xmms-tremor.prepare

$(STATEDIR)/xmms-tremor.compile: $(xmms-tremor_compile_deps)
	@$(call targetinfo, $@)
	$(XMMS-TREMOR_PATH) $(MAKE) -C $(XMMS-TREMOR_DIR)
	touch $@

# ----------------------------------------------------------------------------
# Install
# ----------------------------------------------------------------------------

xmms-tremor_install: $(STATEDIR)/xmms-tremor.install

$(STATEDIR)/xmms-tremor.install: $(STATEDIR)/xmms-tremor.compile
	@$(call targetinfo, $@)
	touch $@

# ----------------------------------------------------------------------------
# Target-Install
# ----------------------------------------------------------------------------

xmms-tremor_targetinstall: $(STATEDIR)/xmms-tremor.targetinstall

xmms-tremor_targetinstall_deps = \
	$(STATEDIR)/xmms-tremor.compile \
	$(STATEDIR)/tremor.targetinstall \
	$(STATEDIR)/xmms.targetinstall

$(STATEDIR)/xmms-tremor.targetinstall: $(xmms-tremor_targetinstall_deps)
	@$(call targetinfo, $@)
	$(XMMS-TREMOR_PATH) $(MAKE) -C $(XMMS-TREMOR_DIR) DESTDIR=$(XMMS-TREMOR_IPKG_TMP) install
	rm -f $(XMMS-TREMOR_IPKG_TMP)/usr/lib/xmms/Input/*.*a
	$(CROSSSTRIP) $(XMMS-TREMOR_IPKG_TMP)/usr/lib/xmms/Input/*.so
	mkdir -p $(XMMS-TREMOR_IPKG_TMP)/CONTROL
	echo "Package: xmms-tremor" 			>$(XMMS-TREMOR_IPKG_TMP)/CONTROL/control
	echo "Priority: optional" 			>>$(XMMS-TREMOR_IPKG_TMP)/CONTROL/control
	echo "Section: pdaXrom" 			>>$(XMMS-TREMOR_IPKG_TMP)/CONTROL/control
	echo "Maintainer: Alexander Chukov <sash@pdaXrom.org>">>$(XMMS-TREMOR_IPKG_TMP)/CONTROL/control
	echo "Architecture: $(SHORT_TARGET)" 		>>$(XMMS-TREMOR_IPKG_TMP)/CONTROL/control
	echo "Version: $(XMMS-TREMOR_VERSION)" 		>>$(XMMS-TREMOR_IPKG_TMP)/CONTROL/control
	echo "Depends: tremor, xmms" 			>>$(XMMS-TREMOR_IPKG_TMP)/CONTROL/control
	echo "Description: Tremor Ogg/Vorbis xmms plugin.">>$(XMMS-TREMOR_IPKG_TMP)/CONTROL/control
	cd $(FEEDDIR) && $(XMKIPKG) $(XMMS-TREMOR_IPKG_TMP)
	touch $@

# ----------------------------------------------------------------------------
# Image-Install
# ----------------------------------------------------------------------------

ifdef PTXCONF_XMMS-TREMOR_INSTALL
ROMPACKAGES += $(STATEDIR)/xmms-tremor.imageinstall
endif

xmms-tremor_imageinstall_deps = $(STATEDIR)/xmms-tremor.targetinstall \
	$(STATEDIR)/virtual-image.install

$(STATEDIR)/xmms-tremor.imageinstall: $(xmms-tremor_imageinstall_deps)
	@$(call targetinfo, $@)
	cd $(FEEDDIR) && $(XIPKG) install xmms-tremor
	touch $@

# ----------------------------------------------------------------------------
# Clean
# ----------------------------------------------------------------------------

xmms-tremor_clean:
	rm -rf $(STATEDIR)/xmms-tremor.*
	rm -rf $(XMMS-TREMOR_DIR)

# vim: syntax=make
