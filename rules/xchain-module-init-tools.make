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
ifdef PTXCONF_XCHAIN_MODULE-INIT-TOOLS
PACKAGES += xchain-module-init-tools
endif

#
# Paths and names
#
XCHAIN_MODULE-INIT-TOOLS		= $(MODULE-INIT-TOOLS)
XCHAIN_MODULE-INIT-TOOLS_DIR		= $(XCHAIN_BUILDDIR)/$(XCHAIN_MODULE-INIT-TOOLS)

# ----------------------------------------------------------------------------
# Get
# ----------------------------------------------------------------------------

xchain-module-init-tools_get: $(STATEDIR)/xchain-module-init-tools.get

xchain-module-init-tools_get_deps = $(XCHAIN_MODULE-INIT-TOOLS_SOURCE)

$(STATEDIR)/xchain-module-init-tools.get: $(xchain-module-init-tools_get_deps)
	@$(call targetinfo, $@)
	@$(call get_patches, $(MODULE-INIT-TOOLS))
	touch $@

$(XCHAIN_MODULE-INIT-TOOLS_SOURCE):
	@$(call targetinfo, $@)
	@$(call get, $(MODULE-INIT-TOOLS_URL))

# ----------------------------------------------------------------------------
# Extract
# ----------------------------------------------------------------------------

xchain-module-init-tools_extract: $(STATEDIR)/xchain-module-init-tools.extract

xchain-module-init-tools_extract_deps = $(STATEDIR)/xchain-module-init-tools.get

$(STATEDIR)/xchain-module-init-tools.extract: $(xchain-module-init-tools_extract_deps)
	@$(call targetinfo, $@)
	@$(call clean, $(XCHAIN_MODULE-INIT-TOOLS_DIR))
	@$(call extract, $(MODULE-INIT-TOOLS_SOURCE), $(XCHAIN_BUILDDIR))
	@$(call patchin, $(MODULE-INIT-TOOLS), $(XCHAIN_MODULE-INIT-TOOLS_DIR))
	touch $@

# ----------------------------------------------------------------------------
# Prepare
# ----------------------------------------------------------------------------

xchain-module-init-tools_prepare: $(STATEDIR)/xchain-module-init-tools.prepare

#
# dependencies
#
xchain-module-init-tools_prepare_deps = \
	$(STATEDIR)/xchain-module-init-tools.extract

XCHAIN_MODULE-INIT-TOOLS_PATH	=  PATH=$(CROSS_PATH)
XCHAIN_MODULE-INIT-TOOLS_ENV 	=  $(HOSTCC_ENV)
#XCHAIN_MODULE-INIT-TOOLS_ENV	+=

#
# autoconf
#
XCHAIN_MODULE-INIT-TOOLS_AUTOCONF = \
	--prefix=$(PTXCONF_PREFIX) \
	--build=$(GNU_HOST)
# 	--host=$(GNU_HOST)
# 	--target=$(PTXCONF_GNU_TARGET)

$(STATEDIR)/xchain-module-init-tools.prepare: $(xchain-module-init-tools_prepare_deps)
	@$(call targetinfo, $@)
	@$(call clean, $(XCHAIN_MODULE-INIT-TOOLS_DIR)/config.cache)
	cd $(XCHAIN_MODULE-INIT-TOOLS_DIR) && \
		$(XCHAIN_MODULE-INIT-TOOLS_PATH) $(XCHAIN_MODULE-INIT-TOOLS_ENV) \
		./configure $(XCHAIN_MODULE-INIT-TOOLS_AUTOCONF)
	touch $@

# ----------------------------------------------------------------------------
# Compile
# ----------------------------------------------------------------------------

xchain-module-init-tools_compile: $(STATEDIR)/xchain-module-init-tools.compile

xchain-module-init-tools_compile_deps = $(STATEDIR)/xchain-module-init-tools.prepare

$(STATEDIR)/xchain-module-init-tools.compile: $(xchain-module-init-tools_compile_deps)
	@$(call targetinfo, $@)
	$(XCHAIN_MODULE-INIT-TOOLS_PATH) $(MAKE) -C $(XCHAIN_MODULE-INIT-TOOLS_DIR)
	touch $@

# ----------------------------------------------------------------------------
# Install
# ----------------------------------------------------------------------------

xchain-module-init-tools_install: $(STATEDIR)/xchain-module-init-tools.install

$(STATEDIR)/xchain-module-init-tools.install: $(STATEDIR)/xchain-module-init-tools.compile
	@$(call targetinfo, $@)
	$(XCHAIN_MODULE-INIT-TOOLS_PATH) $(MAKE) -C $(XCHAIN_MODULE-INIT-TOOLS_DIR) install
	touch $@

# ----------------------------------------------------------------------------
# Target-Install
# ----------------------------------------------------------------------------

xchain-module-init-tools_targetinstall: $(STATEDIR)/xchain-module-init-tools.targetinstall

xchain-module-init-tools_targetinstall_deps = $(STATEDIR)/xchain-module-init-tools.compile

$(STATEDIR)/xchain-module-init-tools.targetinstall: $(xchain-module-init-tools_targetinstall_deps)
	@$(call targetinfo, $@)
	touch $@

# ----------------------------------------------------------------------------
# Clean
# ----------------------------------------------------------------------------

xchain-module-init-tools_clean:
	rm -rf $(STATEDIR)/xchain-module-init-tools.*
	rm -rf $(XCHAIN_MODULE-INIT-TOOLS_DIR)

# vim: syntax=make
