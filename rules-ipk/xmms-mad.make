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
ifdef PTXCONF_XMMS-MAD
PACKAGES += xmms-mad
endif

#
# Paths and names
#
XMMS-MAD_VERSION	= 0.5.6
XMMS-MAD		= xmms-mad-$(XMMS-MAD_VERSION)
XMMS-MAD_SUFFIX		= tar.gz
XMMS-MAD_URL		= http://heanet.dl.sourceforge.net/sourceforge/xmms-mad/$(XMMS-MAD).$(XMMS-MAD_SUFFIX)
XMMS-MAD_SOURCE		= $(SRCDIR)/$(XMMS-MAD).$(XMMS-MAD_SUFFIX)
XMMS-MAD_DIR		= $(BUILDDIR)/$(XMMS-MAD)
XMMS-MAD_IPKG_TMP	= $(XMMS-MAD_DIR)/ipkg_tmp

# ----------------------------------------------------------------------------
# Get
# ----------------------------------------------------------------------------

xmms-mad_get: $(STATEDIR)/xmms-mad.get

xmms-mad_get_deps = $(XMMS-MAD_SOURCE)

$(STATEDIR)/xmms-mad.get: $(xmms-mad_get_deps)
	@$(call targetinfo, $@)
	@$(call get_patches, $(XMMS-MAD))
	touch $@

$(XMMS-MAD_SOURCE):
	@$(call targetinfo, $@)
	@$(call get, $(XMMS-MAD_URL))

# ----------------------------------------------------------------------------
# Extract
# ----------------------------------------------------------------------------

xmms-mad_extract: $(STATEDIR)/xmms-mad.extract

xmms-mad_extract_deps = $(STATEDIR)/xmms-mad.get

$(STATEDIR)/xmms-mad.extract: $(xmms-mad_extract_deps)
	@$(call targetinfo, $@)
	@$(call clean, $(XMMS-MAD_DIR))
	@$(call extract, $(XMMS-MAD_SOURCE))
	@$(call patchin, $(XMMS-MAD))
	touch $@

# ----------------------------------------------------------------------------
# Prepare
# ----------------------------------------------------------------------------

xmms-mad_prepare: $(STATEDIR)/xmms-mad.prepare

#
# dependencies
#
xmms-mad_prepare_deps = \
	$(STATEDIR)/xmms-mad.extract \
	$(STATEDIR)/xmms.install \
	$(STATEDIR)/libmad.install \
	$(STATEDIR)/libid3tag.install \
	$(STATEDIR)/virtual-xchain.install

XMMS-MAD_PATH	=  PATH=$(CROSS_PATH)
XMMS-MAD_ENV 	=  $(CROSS_ENV)
#XMMS-MAD_ENV	+=
XMMS-MAD_ENV	+= PKG_CONFIG_PATH=$(CROSS_LIB_DIR)/lib/pkgconfig:$(CROSS_LIB_DIR)/lib/pkgconfig
#ifdef PTXCONF_XFREE430
#XMMS-MAD_ENV	+= LDFLAGS=-Wl,-rpath-link,$(CROSS_LIB_DIR)/lib
#endif

#
# autoconf
#
XMMS-MAD_AUTOCONF = \
	--build=$(GNU_HOST) \
	--host=$(PTXCONF_GNU_TARGET) \
	--prefix=/usr

ifdef PTXCONF_XFREE430
XMMS-MAD_AUTOCONF += --x-includes=$(CROSS_LIB_DIR)/include
XMMS-MAD_AUTOCONF += --x-libraries=$(CROSS_LIB_DIR)/lib
endif

$(STATEDIR)/xmms-mad.prepare: $(xmms-mad_prepare_deps)
	@$(call targetinfo, $@)
	@$(call clean, $(XMMS-MAD_DIR)/config.cache)
	cd $(XMMS-MAD_DIR) && \
		$(XMMS-MAD_PATH) $(XMMS-MAD_ENV) \
		./configure $(XMMS-MAD_AUTOCONF)
	touch $@

# ----------------------------------------------------------------------------
# Compile
# ----------------------------------------------------------------------------

xmms-mad_compile: $(STATEDIR)/xmms-mad.compile

xmms-mad_compile_deps = $(STATEDIR)/xmms-mad.prepare

$(STATEDIR)/xmms-mad.compile: $(xmms-mad_compile_deps)
	@$(call targetinfo, $@)
	$(XMMS-MAD_PATH) $(MAKE) -C $(XMMS-MAD_DIR)
	touch $@

# ----------------------------------------------------------------------------
# Install
# ----------------------------------------------------------------------------

xmms-mad_install: $(STATEDIR)/xmms-mad.install

$(STATEDIR)/xmms-mad.install: $(STATEDIR)/xmms-mad.compile
	@$(call targetinfo, $@)
	touch $@

# ----------------------------------------------------------------------------
# Target-Install
# ----------------------------------------------------------------------------

xmms-mad_targetinstall: $(STATEDIR)/xmms-mad.targetinstall

xmms-mad_targetinstall_deps = \
	$(STATEDIR)/xmms-mad.compile \
	$(STATEDIR)/libmad.targetinstall \
	$(STATEDIR)/libid3tag.targetinstall \
	$(STATEDIR)/xmms.targetinstall

$(STATEDIR)/xmms-mad.targetinstall: $(xmms-mad_targetinstall_deps)
	@$(call targetinfo, $@)
	$(XMMS-MAD_PATH) $(MAKE) -C $(XMMS-MAD_DIR) DESTDIR=$(XMMS-MAD_IPKG_TMP) install
	rm -f $(XMMS-MAD_IPKG_TMP)/usr/lib/xmms/Input/*.la
	$(CROSSSTRIP) $(XMMS-MAD_IPKG_TMP)/usr/lib/xmms/Input/*.so
	mkdir -p $(XMMS-MAD_IPKG_TMP)/CONTROL
	echo "Package: xmms-mad" 			>$(XMMS-MAD_IPKG_TMP)/CONTROL/control
	echo "Priority: optional" 			>>$(XMMS-MAD_IPKG_TMP)/CONTROL/control
	echo "Section: Multimedia" 			>>$(XMMS-MAD_IPKG_TMP)/CONTROL/control
	echo "Maintainer: Alexander Chukov <sash@pdaXrom.org>">>$(XMMS-MAD_IPKG_TMP)/CONTROL/control
	echo "Architecture: $(SHORT_TARGET)" 		>>$(XMMS-MAD_IPKG_TMP)/CONTROL/control
	echo "Version: $(XMMS-MAD_VERSION)" 		>>$(XMMS-MAD_IPKG_TMP)/CONTROL/control
	echo "Depends: xmms, libmad, libid3tag" 	>>$(XMMS-MAD_IPKG_TMP)/CONTROL/control
	echo "Description: xmms-mad is an input plugin for xmms that uses libmad to decode MPEG layer 1/2/3 files and streams.">>$(XMMS-MAD_IPKG_TMP)/CONTROL/control
	cd $(FEEDDIR) && $(XMKIPKG) $(XMMS-MAD_IPKG_TMP)
	touch $@

# ----------------------------------------------------------------------------
# Image-Install
# ----------------------------------------------------------------------------

ifdef PTXCONF_XMMS-MAD_INSTALL
ROMPACKAGES += $(STATEDIR)/xmms-mad.imageinstall
endif

xmms-mad_imageinstall_deps = $(STATEDIR)/xmms-mad.targetinstall \
	$(STATEDIR)/virtual-image.install

$(STATEDIR)/xmms-mad.imageinstall: $(xmms-mad_imageinstall_deps)
	@$(call targetinfo, $@)
	cd $(FEEDDIR) && $(XIPKG) install xmms-mad
	touch $@

# ----------------------------------------------------------------------------
# Clean
# ----------------------------------------------------------------------------

xmms-mad_clean:
	rm -rf $(STATEDIR)/xmms-mad.*
	rm -rf $(XMMS-MAD_DIR)

# vim: syntax=make
