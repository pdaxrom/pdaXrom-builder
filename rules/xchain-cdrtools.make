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
ifdef PTXCONF_XCHAIN_CDRTOOLS
PACKAGES += xchain-cdrtools
endif

#
# Paths and names
#
XCHAIN_CDRTOOLS_VERSION		= $(CDRTOOLS_VERSION)
XCHAIN_CDRTOOLS			= cdrtools-$(XCHAIN_CDRTOOLS_VERSION)
XCHAIN_CDRTOOLS_DIR		= $(XCHAIN_BUILDDIR)/$(XCHAIN_CDRTOOLS)

# ----------------------------------------------------------------------------
# Get
# ----------------------------------------------------------------------------

xchain-cdrtools_get: $(STATEDIR)/xchain-cdrtools.get

xchain-cdrtools_get_deps = $(XCHAIN_CDRTOOLS_SOURCE)

$(STATEDIR)/xchain-cdrtools.get: $(xchain-cdrtools_get_deps)
	@$(call targetinfo, $@)
	@$(call get_patches, $(CDRTOOLS))
	touch $@

$(XCHAIN_CDRTOOLS_SOURCE):
	@$(call targetinfo, $@)
	@$(call get, $(CDRTOOLS_URL))

# ----------------------------------------------------------------------------
# Extract
# ----------------------------------------------------------------------------

xchain-cdrtools_extract: $(STATEDIR)/xchain-cdrtools.extract

xchain-cdrtools_extract_deps = $(STATEDIR)/cdrtools.get

$(STATEDIR)/xchain-cdrtools.extract: $(xchain-cdrtools_extract_deps)
	@$(call targetinfo, $@)
	@$(call clean, $(XCHAIN_CDRTOOLS_DIR))
	@$(call extract, $(CDRTOOLS_SOURCE), $(XCHAIN_BUILDDIR))
	@$(call patchin, $(XCHAIN_CDRTOOLS), $(XCHAIN_CDRTOOLS_DIR))
	touch $@

# ----------------------------------------------------------------------------
# Prepare
# ----------------------------------------------------------------------------

xchain-cdrtools_prepare: $(STATEDIR)/xchain-cdrtools.prepare

#
# dependencies
#
xchain-cdrtools_prepare_deps = \
	$(STATEDIR)/xchain-cdrtools.extract

XCHAIN_CDRTOOLS_PATH	=  PATH=$(CROSS_PATH)
XCHAIN_CDRTOOLS_ENV 	=  $(HOSTCC_ENV)
#XCHAIN_CDRTOOLS_ENV	+=

#
# autoconf
#
XCHAIN_CDRTOOLS_AUTOCONF = \
	--prefix=$(PTXCONF_PREFIX) \
	--build=$(GNU_HOST)
# 	--host=$(GNU_HOST)
# 	--target=$(PTXCONF_GNU_TARGET)

$(STATEDIR)/xchain-cdrtools.prepare: $(xchain-cdrtools_prepare_deps)
	@$(call targetinfo, $@)
	@$(call clean, $(XCHAIN_CDRTOOLS_DIR)/config.cache)
	#cd $(XCHAIN_CDRTOOLS_DIR) && \
	#	$(XCHAIN_CDRTOOLS_PATH) $(XCHAIN_CDRTOOLS_ENV) \
	#	./configure $(XCHAIN_CDRTOOLS_AUTOCONF)
	touch $@

# ----------------------------------------------------------------------------
# Compile
# ----------------------------------------------------------------------------

xchain-cdrtools_compile: $(STATEDIR)/xchain-cdrtools.compile

xchain-cdrtools_compile_deps = $(STATEDIR)/xchain-cdrtools.prepare

$(STATEDIR)/xchain-cdrtools.compile: $(xchain-cdrtools_compile_deps)
	@$(call targetinfo, $@)
	$(XCHAIN_CDRTOOLS_PATH) $(MAKE) -C $(XCHAIN_CDRTOOLS_DIR)
	touch $@

# ----------------------------------------------------------------------------
# Install
# ----------------------------------------------------------------------------

xchain-cdrtools_install: $(STATEDIR)/xchain-cdrtools.install

$(STATEDIR)/xchain-cdrtools.install: $(STATEDIR)/xchain-cdrtools.compile
	@$(call targetinfo, $@)
	$(XCHAIN_CDRTOOLS_PATH) $(MAKE) -C $(XCHAIN_CDRTOOLS_DIR) install INS_BASE=$(PTXCONF_PREFIX)
	touch $@

# ----------------------------------------------------------------------------
# Target-Install
# ----------------------------------------------------------------------------

xchain-cdrtools_targetinstall: $(STATEDIR)/xchain-cdrtools.targetinstall

xchain-cdrtools_targetinstall_deps = $(STATEDIR)/xchain-cdrtools.compile \
	$(STATEDIR)/xchain-cdrtools.install

$(STATEDIR)/xchain-cdrtools.targetinstall: $(xchain-cdrtools_targetinstall_deps)
	@$(call targetinfo, $@)
	touch $@

# ----------------------------------------------------------------------------
# Clean
# ----------------------------------------------------------------------------

xchain-cdrtools_clean:
	rm -rf $(STATEDIR)/xchain-cdrtools.*
	rm -rf $(XCHAIN_CDRTOOLS_DIR)

# vim: syntax=make
