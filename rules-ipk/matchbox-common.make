# -*-makefile-*-
# $Id: template,v 1.10 2004/01/24 15:50:34 mkl Exp $
#
# Copyright (C) 2004 by Alexander Chukov <sash@cacko.biz>
#          
# See CREDITS for details about who has contributed to this project.
#
# For further information about the PTXdist project and license conditions
# see the README file.
#

#
# We provide this package
#
ifdef PTXCONF_MATCHBOX-COMMON
PACKAGES += matchbox-common
endif

#
# Paths and names
#
MATCHBOX-COMMON_VERSION		= 0.9.1
MATCHBOX-COMMON			= matchbox-common-$(MATCHBOX-COMMON_VERSION)
MATCHBOX-COMMON_SUFFIX		= tar.bz2
MATCHBOX-COMMON_URL		= http://projects.o-hand.com/matchbox/sources/matchbox-common/0.9/$(MATCHBOX-COMMON).$(MATCHBOX-COMMON_SUFFIX)
MATCHBOX-COMMON_SOURCE		= $(SRCDIR)/$(MATCHBOX-COMMON).$(MATCHBOX-COMMON_SUFFIX)
MATCHBOX-COMMON_DIR		= $(BUILDDIR)/$(MATCHBOX-COMMON)
MATCHBOX-COMMON_ROOTDIR		= $(MATCHBOX-COMMON_DIR)/ipkg_tmp
# ----------------------------------------------------------------------------
# Get
# ----------------------------------------------------------------------------

matchbox-common_get: $(STATEDIR)/matchbox-common.get

matchbox-common_get_deps = $(MATCHBOX-COMMON_SOURCE)

$(STATEDIR)/matchbox-common.get: $(matchbox-common_get_deps)
	@$(call targetinfo, $@)
	@$(call get_patches, $(MATCHBOX-COMMON))
	touch $@

$(MATCHBOX-COMMON_SOURCE):
	@$(call targetinfo, $@)
	@$(call get, $(MATCHBOX-COMMON_URL))

# ----------------------------------------------------------------------------
# Extract
# ----------------------------------------------------------------------------

matchbox-common_extract: $(STATEDIR)/matchbox-common.extract

matchbox-common_extract_deps = $(STATEDIR)/matchbox-common.get

$(STATEDIR)/matchbox-common.extract: $(matchbox-common_extract_deps)
	@$(call targetinfo, $@)
	@$(call clean, $(MATCHBOX-COMMON_DIR))
	@$(call extract, $(MATCHBOX-COMMON_SOURCE))
	@$(call patchin, $(MATCHBOX-COMMON))
	touch $@

# ----------------------------------------------------------------------------
# Prepare
# ----------------------------------------------------------------------------

matchbox-common_prepare: $(STATEDIR)/matchbox-common.prepare

#
# dependencies
#
matchbox-common_prepare_deps = \
	$(STATEDIR)/matchbox-common.extract \
	$(STATEDIR)/virtual-xchain.install

MATCHBOX-COMMON_PATH	=  PATH=$(CROSS_PATH)
MATCHBOX-COMMON_ENV 	=  $(CROSS_ENV)
#MATCHBOX-COMMON_ENV	+=
MATCHBOX-COMMON_ENV	+= PKG_CONFIG_PATH=$(CROSS_LIB_DIR)/lib/pkgconfig:$(CROSS_LIB_DIR)/lib/pkgconfig
#MATCHBOX-COMMON_ENV	+= LDFLAGS=-Wl,-rpath-link,$(CROSS_LIB_DIR)/lib

#
# autoconf
#
MATCHBOX-COMMON_AUTOCONF = \
	--build=$(GNU_HOST) \
	--host=$(PTXCONF_GNU_TARGET) \
	--prefix=/usr

$(STATEDIR)/matchbox-common.prepare: $(matchbox-common_prepare_deps)
	@$(call targetinfo, $@)
	@$(call clean, $(MATCHBOX-COMMON_DIR)/config.cache)
	cd $(MATCHBOX-COMMON_DIR) && \
		$(MATCHBOX-COMMON_PATH) $(MATCHBOX-COMMON_ENV) \
		./configure $(MATCHBOX-COMMON_AUTOCONF)
	touch $@

# ----------------------------------------------------------------------------
# Compile
# ----------------------------------------------------------------------------

matchbox-common_compile: $(STATEDIR)/matchbox-common.compile

matchbox-common_compile_deps = $(STATEDIR)/matchbox-common.prepare

$(STATEDIR)/matchbox-common.compile: $(matchbox-common_compile_deps)
	@$(call targetinfo, $@)
	$(MATCHBOX-COMMON_PATH) $(MAKE) -C $(MATCHBOX-COMMON_DIR)
	touch $@

# ----------------------------------------------------------------------------
# Install
# ----------------------------------------------------------------------------

matchbox-common_install: $(STATEDIR)/matchbox-common.install

$(STATEDIR)/matchbox-common.install: $(STATEDIR)/matchbox-common.compile
	@$(call targetinfo, $@)
	touch $@

# ----------------------------------------------------------------------------
# Target-Install
# ----------------------------------------------------------------------------

matchbox-common_targetinstall: $(STATEDIR)/matchbox-common.targetinstall

matchbox-common_targetinstall_deps = $(STATEDIR)/matchbox-common.compile

$(STATEDIR)/matchbox-common.targetinstall: $(matchbox-common_targetinstall_deps)
	@$(call targetinfo, $@)
	$(MATCHBOX-COMMON_PATH) $(MAKE) -C $(MATCHBOX-COMMON_DIR) DESTDIR=$(MATCHBOX-COMMON_ROOTDIR) install
	mkdir -p $(MATCHBOX-COMMON_ROOTDIR)/CONTROL
	echo "Package: matchbox-common" 		 >$(MATCHBOX-COMMON_ROOTDIR)/CONTROL/control
	echo "Priority: optional" 			>>$(MATCHBOX-COMMON_ROOTDIR)/CONTROL/control
	echo "Section: Matchbox" 			>>$(MATCHBOX-COMMON_ROOTDIR)/CONTROL/control
	echo "Maintainer: Alexander Chukov <sash@pdaXrom.org>">>$(MATCHBOX-COMMON_ROOTDIR)/CONTROL/control
	echo "Architecture: $(SHORT_TARGET)" 		>>$(MATCHBOX-COMMON_ROOTDIR)/CONTROL/control
	echo "Version: $(MATCHBOX-COMMON_VERSION)" 	>>$(MATCHBOX-COMMON_ROOTDIR)/CONTROL/control
	echo "Depends: "		 		>>$(MATCHBOX-COMMON_ROOTDIR)/CONTROL/control
	echo "Description: Matchbox common data"	>>$(MATCHBOX-COMMON_ROOTDIR)/CONTROL/control
	cd $(FEEDDIR) && $(XMKIPKG) $(MATCHBOX-COMMON_ROOTDIR)
	touch $@

# ----------------------------------------------------------------------------
# Image-Install
# ----------------------------------------------------------------------------

matchbox-common_imageinstall_deps = $(STATEDIR)/matchbox-common.targetinstall \
	$(STATEDIR)/virtual-image.install

$(STATEDIR)/matchbox-common.imageinstall: $(matchbox-common_imageinstall_deps)
	@$(call targetinfo, $@)
	cd $(FEEDDIR) && $(XIPKG) install matchbox-common
	touch $@

# ----------------------------------------------------------------------------
# Clean
# ----------------------------------------------------------------------------

matchbox-common_clean:
	rm -rf $(STATEDIR)/matchbox-common.*
	rm -rf $(MATCHBOX-COMMON_DIR)

# vim: syntax=make
