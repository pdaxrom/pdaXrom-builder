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
ifdef PTXCONF_XCHAIN_SHARED-MIME-INFO
PACKAGES += xchain-shared-mime-info
endif

#
# Paths and names
#
XCHAIN_SHARED-MIME-INFO			= shared-mime-info-$(SHARED-MIME-INFO_VERSION)
XCHAIN_SHARED-MIME-INFO_DIR		= $(XCHAIN_BUILDDIR)/$(XCHAIN_SHARED-MIME-INFO)

# ----------------------------------------------------------------------------
# Get
# ----------------------------------------------------------------------------

xchain-shared-mime-info_get: $(STATEDIR)/xchain-shared-mime-info.get

xchain-shared-mime-info_get_deps = $(XCHAIN_SHARED-MIME-INFO_SOURCE)

$(STATEDIR)/xchain-shared-mime-info.get: $(xchain-shared-mime-info_get_deps)
	@$(call targetinfo, $@)
	@$(call get_patches, $(SHARED-MIME-INFO))
	touch $@

$(XCHAIN_SHARED-MIME-INFO_SOURCE):
	@$(call targetinfo, $@)
	@$(call get, $(SHARED-MIME-INFO_URL))

# ----------------------------------------------------------------------------
# Extract
# ----------------------------------------------------------------------------

xchain-shared-mime-info_extract: $(STATEDIR)/xchain-shared-mime-info.extract

xchain-shared-mime-info_extract_deps = $(STATEDIR)/xchain-shared-mime-info.get

$(STATEDIR)/xchain-shared-mime-info.extract: $(xchain-shared-mime-info_extract_deps)
	@$(call targetinfo, $@)
	@$(call clean, $(XCHAIN_SHARED-MIME-INFO_DIR))
	@$(call extract, $(SHARED-MIME-INFO_SOURCE), $(XCHAIN_BUILDDIR))
	@$(call patchin, $(SHARED-MIME-INFO), $(XCHAIN_SHARED-MIME-INFO_DIR))
	touch $@

# ----------------------------------------------------------------------------
# Prepare
# ----------------------------------------------------------------------------

xchain-shared-mime-info_prepare: $(STATEDIR)/xchain-shared-mime-info.prepare

#
# dependencies
#
xchain-shared-mime-info_prepare_deps = \
	$(STATEDIR)/xchain-shared-mime-info.extract

XCHAIN_SHARED-MIME-INFO_PATH	=  PATH=$(CROSS_PATH)
XCHAIN_SHARED-MIME-INFO_ENV 	=  $(HOSTCC_ENV)
#XCHAIN_SHARED-MIME-INFO_ENV	+=

#
# autoconf
#
XCHAIN_SHARED-MIME-INFO_AUTOCONF = \
	--prefix=$(PTXCONF_PREFIX) \
	--build=$(GNU_HOST)
# 	--host=$(GNU_HOST)
# 	--target=$(PTXCONF_GNU_TARGET)

$(STATEDIR)/xchain-shared-mime-info.prepare: $(xchain-shared-mime-info_prepare_deps)
	@$(call targetinfo, $@)
	@$(call clean, $(XCHAIN_SHARED-MIME-INFO_DIR)/config.cache)
	cd $(XCHAIN_SHARED-MIME-INFO_DIR) && \
		$(XCHAIN_SHARED-MIME-INFO_PATH) $(XCHAIN_SHARED-MIME-INFO_ENV) \
		./configure $(XCHAIN_SHARED-MIME-INFO_AUTOCONF)
	touch $@

# ----------------------------------------------------------------------------
# Compile
# ----------------------------------------------------------------------------

xchain-shared-mime-info_compile: $(STATEDIR)/xchain-shared-mime-info.compile

xchain-shared-mime-info_compile_deps = $(STATEDIR)/xchain-shared-mime-info.prepare

$(STATEDIR)/xchain-shared-mime-info.compile: $(xchain-shared-mime-info_compile_deps)
	@$(call targetinfo, $@)
	$(XCHAIN_SHARED-MIME-INFO_PATH) $(MAKE) -C $(XCHAIN_SHARED-MIME-INFO_DIR)
	touch $@

# ----------------------------------------------------------------------------
# Install
# ----------------------------------------------------------------------------

xchain-shared-mime-info_install: $(STATEDIR)/xchain-shared-mime-info.install

$(STATEDIR)/xchain-shared-mime-info.install: $(STATEDIR)/xchain-shared-mime-info.compile
	@$(call targetinfo, $@)
	$(XCHAIN_SHARED-MIME-INFO_PATH) $(MAKE) -C $(XCHAIN_SHARED-MIME-INFO_DIR) install
	touch $@

# ----------------------------------------------------------------------------
# Target-Install
# ----------------------------------------------------------------------------

xchain-shared-mime-info_targetinstall: $(STATEDIR)/xchain-shared-mime-info.targetinstall

xchain-shared-mime-info_targetinstall_deps = $(STATEDIR)/xchain-shared-mime-info.compile

$(STATEDIR)/xchain-shared-mime-info.targetinstall: $(xchain-shared-mime-info_targetinstall_deps)
	@$(call targetinfo, $@)
	touch $@

# ----------------------------------------------------------------------------
# Clean
# ----------------------------------------------------------------------------

xchain-shared-mime-info_clean:
	rm -rf $(STATEDIR)/xchain-shared-mime-info.*
	rm -rf $(XCHAIN_SHARED-MIME-INFO_DIR)

# vim: syntax=make
