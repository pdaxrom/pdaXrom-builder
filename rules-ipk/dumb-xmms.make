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
ifdef PTXCONF_DUMB-XMMS
PACKAGES += dumb-xmms
endif

#
# Paths and names
#
DUMB-XMMS_VERSION	= 0.1
DUMB-XMMS		= dumb-xmms-$(DUMB-XMMS_VERSION)
DUMB-XMMS_SUFFIX	= tar.gz
DUMB-XMMS_URL		= http://easynews.dl.sourceforge.net/sourceforge/dumb/$(DUMB-XMMS).$(DUMB-XMMS_SUFFIX)
DUMB-XMMS_SOURCE	= $(SRCDIR)/$(DUMB-XMMS).$(DUMB-XMMS_SUFFIX)
DUMB-XMMS_DIR		= $(BUILDDIR)/dumb-xmms
DUMB-XMMS_IPKG_TMP	= $(DUMB-XMMS_DIR)/ipkg_tmp

# ----------------------------------------------------------------------------
# Get
# ----------------------------------------------------------------------------

dumb-xmms_get: $(STATEDIR)/dumb-xmms.get

dumb-xmms_get_deps = $(DUMB-XMMS_SOURCE)

$(STATEDIR)/dumb-xmms.get: $(dumb-xmms_get_deps)
	@$(call targetinfo, $@)
	@$(call get_patches, $(DUMB-XMMS))
	touch $@

$(DUMB-XMMS_SOURCE):
	@$(call targetinfo, $@)
	@$(call get, $(DUMB-XMMS_URL))

# ----------------------------------------------------------------------------
# Extract
# ----------------------------------------------------------------------------

dumb-xmms_extract: $(STATEDIR)/dumb-xmms.extract

dumb-xmms_extract_deps = $(STATEDIR)/dumb-xmms.get

$(STATEDIR)/dumb-xmms.extract: $(dumb-xmms_extract_deps)
	@$(call targetinfo, $@)
	@$(call clean, $(DUMB-XMMS_DIR))
	@$(call extract, $(DUMB-XMMS_SOURCE))
	@$(call patchin, $(DUMB-XMMS))
	touch $@

# ----------------------------------------------------------------------------
# Prepare
# ----------------------------------------------------------------------------

dumb-xmms_prepare: $(STATEDIR)/dumb-xmms.prepare

#
# dependencies
#
dumb-xmms_prepare_deps = \
	$(STATEDIR)/dumb-xmms.extract \
	$(STATEDIR)/dumb.install \
	$(STATEDIR)/xmms.install \
	$(STATEDIR)/virtual-xchain.install

DUMB-XMMS_PATH	=  PATH=$(CROSS_PATH)
DUMB-XMMS_ENV 	=  $(CROSS_ENV)
#DUMB-XMMS_ENV	+=
DUMB-XMMS_ENV	+= PKG_CONFIG_PATH=$(CROSS_LIB_DIR)/lib/pkgconfig:$(CROSS_LIB_DIR)/lib/pkgconfig
#ifdef PTXCONF_XFREE430
#DUMB-XMMS_ENV	+= LDFLAGS=-Wl,-rpath-link,$(CROSS_LIB_DIR)/lib
#endif

#
# autoconf
#
DUMB-XMMS_AUTOCONF = \
	--build=$(GNU_HOST) \
	--host=$(PTXCONF_GNU_TARGET) \
	--prefix=/usr

ifdef PTXCONF_XFREE430
DUMB-XMMS_AUTOCONF += --x-includes=$(CROSS_LIB_DIR)/include
DUMB-XMMS_AUTOCONF += --x-libraries=$(CROSS_LIB_DIR)/lib
endif

$(STATEDIR)/dumb-xmms.prepare: $(dumb-xmms_prepare_deps)
	@$(call targetinfo, $@)
	@$(call clean, $(DUMB-XMMS_DIR)/config.cache)
	#cd $(DUMB-XMMS_DIR) && \
	#	$(DUMB-XMMS_PATH) $(DUMB-XMMS_ENV) \
	#	./configure $(DUMB-XMMS_AUTOCONF)
	touch $@

# ----------------------------------------------------------------------------
# Compile
# ----------------------------------------------------------------------------

dumb-xmms_compile: $(STATEDIR)/dumb-xmms.compile

dumb-xmms_compile_deps = $(STATEDIR)/dumb-xmms.prepare

$(STATEDIR)/dumb-xmms.compile: $(dumb-xmms_compile_deps)
	@$(call targetinfo, $@)
	$(DUMB-XMMS_PATH) $(MAKE) -C $(DUMB-XMMS_DIR) $(DUMB-XMMS_ENV)
	touch $@

# ----------------------------------------------------------------------------
# Install
# ----------------------------------------------------------------------------

dumb-xmms_install: $(STATEDIR)/dumb-xmms.install

$(STATEDIR)/dumb-xmms.install: $(STATEDIR)/dumb-xmms.compile
	@$(call targetinfo, $@)
	touch $@

# ----------------------------------------------------------------------------
# Target-Install
# ----------------------------------------------------------------------------

dumb-xmms_targetinstall: $(STATEDIR)/dumb-xmms.targetinstall

dumb-xmms_targetinstall_deps = $(STATEDIR)/dumb-xmms.compile \
	$(STATEDIR)/xmms.targetinstall

$(STATEDIR)/dumb-xmms.targetinstall: $(dumb-xmms_targetinstall_deps)
	@$(call targetinfo, $@)
	$(INSTALL) -D -m 755 $(DUMB-XMMS_DIR)/libdumb-xmms.so $(DUMB-XMMS_IPKG_TMP)/usr/lib/xmms/Input/libdumb-xmms.so
	$(CROSSSTRIP) $(DUMB-XMMS_IPKG_TMP)/usr/lib/xmms/Input/*
	mkdir -p $(DUMB-XMMS_IPKG_TMP)/CONTROL
	echo "Package: xmms-dumb" 								>$(DUMB-XMMS_IPKG_TMP)/CONTROL/control
	echo "Priority: optional" 								>>$(DUMB-XMMS_IPKG_TMP)/CONTROL/control
	echo "Section: Multimedia" 								>>$(DUMB-XMMS_IPKG_TMP)/CONTROL/control
	echo "Maintainer: Alexander Chukov <sash@pdaXrom.org>" 					>>$(DUMB-XMMS_IPKG_TMP)/CONTROL/control
	echo "Architecture: $(SHORT_TARGET)" 							>>$(DUMB-XMMS_IPKG_TMP)/CONTROL/control
	echo "Version: $(DUMB-XMMS_VERSION)" 							>>$(DUMB-XMMS_IPKG_TMP)/CONTROL/control
	echo "Depends: xmms" 									>>$(DUMB-XMMS_IPKG_TMP)/CONTROL/control
	echo "Description: MOD,IT,S3M XMMS plugin"						>>$(DUMB-XMMS_IPKG_TMP)/CONTROL/control
	cd $(FEEDDIR) && $(XMKIPKG) $(DUMB-XMMS_IPKG_TMP)
	touch $@

# ----------------------------------------------------------------------------
# Image-Install
# ----------------------------------------------------------------------------

ifdef PTXCONF_DUMB-XMMS_INSTALL
ROMPACKAGES += $(STATEDIR)/dumb-xmms.imageinstall
endif

dumb-xmms_imageinstall_deps = $(STATEDIR)/dumb-xmms.targetinstall \
	$(STATEDIR)/virtual-image.install

$(STATEDIR)/dumb-xmms.imageinstall: $(dumb-xmms_imageinstall_deps)
	@$(call targetinfo, $@)
	cd $(FEEDDIR) && $(XIPKG) install xmms-dumb
	touch $@

# ----------------------------------------------------------------------------
# Clean
# ----------------------------------------------------------------------------

dumb-xmms_clean:
	rm -rf $(STATEDIR)/dumb-xmms.*
	rm -rf $(DUMB-XMMS_DIR)

# vim: syntax=make
