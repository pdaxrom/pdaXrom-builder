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
ifdef PTXCONF_XCHAIN_GCONF
PACKAGES += xchain-GConf
endif

#
# Paths and names
#
XCHAIN_GCONF			= $(GCONF)
XCHAIN_GCONF_DIR		= $(XCHAIN_BUILDDIR)/$(XCHAIN_GCONF)

# ----------------------------------------------------------------------------
# Get
# ----------------------------------------------------------------------------

xchain-GConf_get: $(STATEDIR)/xchain-GConf.get

xchain-GConf_get_deps = $(XCHAIN_GCONF_SOURCE)

$(STATEDIR)/xchain-GConf.get: $(xchain-GConf_get_deps)
	@$(call targetinfo, $@)
	@$(call get_patches, $(XCHAIN_GCONF))
	touch $@

$(XCHAIN_GCONF_SOURCE):
	@$(call targetinfo, $@)
	@$(call get, $(XCHAIN_GCONF_URL))

# ----------------------------------------------------------------------------
# Extract
# ----------------------------------------------------------------------------

xchain-GConf_extract: $(STATEDIR)/xchain-GConf.extract

xchain-GConf_extract_deps = $(STATEDIR)/xchain-GConf.get

$(STATEDIR)/xchain-GConf.extract: $(xchain-GConf_extract_deps)
	@$(call targetinfo, $@)
	@$(call clean, $(XCHAIN_GCONF_DIR))
	@$(call extract, $(GCONF_SOURCE), $(XCHAIN_BUILDDIR))
	@$(call patchin, $(GCONF), $(XCHAIN_GCONF_DIR))
	touch $@

# ----------------------------------------------------------------------------
# Prepare
# ----------------------------------------------------------------------------

xchain-GConf_prepare: $(STATEDIR)/xchain-GConf.prepare

#
# dependencies
#
xchain-GConf_prepare_deps = \
	$(STATEDIR)/xchain-GConf.extract \
	$(STATEDIR)/xchain-ORBit2.install

XCHAIN_GCONF_PATH	=  PATH=$(CROSS_PATH)
XCHAIN_GCONF_ENV 	=  $(HOSTCC_ENV)
#XCHAIN_GCONF_ENV	+= PKG_CONFIG_PATH=$(PTXCONF_PREFIX)/lib/pkgconfig:$PKG_CONFIG_PATH
#XCHAIN_GCONF_ENV	+=

#
# autoconf
#
XCHAIN_GCONF_AUTOCONF = \
	--prefix=$(PTXCONF_PREFIX) \
	--build=$(GNU_HOST)
# 	--host=$(GNU_HOST)
# 	--target=$(PTXCONF_GNU_TARGET)

$(STATEDIR)/xchain-GConf.prepare: $(xchain-GConf_prepare_deps)
	@$(call targetinfo, $@)
	@$(call clean, $(XCHAIN_GCONF_DIR)/config.cache)
	cd $(XCHAIN_GCONF_DIR) && \
		$(XCHAIN_GCONF_PATH) $(XCHAIN_GCONF_ENV) \
		./configure $(XCHAIN_GCONF_AUTOCONF)
	touch $@

# ----------------------------------------------------------------------------
# Compile
# ----------------------------------------------------------------------------

xchain-GConf_compile: $(STATEDIR)/xchain-GConf.compile

xchain-GConf_compile_deps = $(STATEDIR)/xchain-GConf.prepare

$(STATEDIR)/xchain-GConf.compile: $(xchain-GConf_compile_deps)
	@$(call targetinfo, $@)
	$(XCHAIN_GCONF_PATH) $(MAKE) -C $(XCHAIN_GCONF_DIR) ORBIT_IDL=$(PTXCONF_PREFIX)/bin/orbit-idl-2
	touch $@

# ----------------------------------------------------------------------------
# Install
# ----------------------------------------------------------------------------

xchain-GConf_install: $(STATEDIR)/xchain-GConf.install

$(STATEDIR)/xchain-GConf.install: $(STATEDIR)/xchain-GConf.compile
	@$(call targetinfo, $@)
	$(XCHAIN_GCONF_PATH) $(MAKE) -C $(XCHAIN_GCONF_DIR) install ORBIT_IDL=$(PTXCONF_PREFIX)/bin/orbit-idl-2
	touch $@

# ----------------------------------------------------------------------------
# Target-Install
# ----------------------------------------------------------------------------

xchain-GConf_targetinstall: $(STATEDIR)/xchain-GConf.targetinstall

xchain-GConf_targetinstall_deps = $(STATEDIR)/xchain-GConf.compile

$(STATEDIR)/xchain-GConf.targetinstall: $(xchain-GConf_targetinstall_deps)
	@$(call targetinfo, $@)
	touch $@

# ----------------------------------------------------------------------------
# Clean
# ----------------------------------------------------------------------------

xchain-GConf_clean:
	rm -rf $(STATEDIR)/xchain-GConf.*
	rm -rf $(XCHAIN_GCONF_DIR)

# vim: syntax=make
