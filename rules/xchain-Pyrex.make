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
ifdef PTXCONF_XCHAIN_PYREX
PACKAGES += xchain-Pyrex
endif

#
# Paths and names
#
XCHAIN_PYREX_VERSION		= 0.9.2.1
XCHAIN_PYREX			= Pyrex-$(XCHAIN_PYREX_VERSION)
XCHAIN_PYREX_SUFFIX		= tar.gz
XCHAIN_PYREX_URL		= http://www.cosc.canterbury.ac.nz/~greg/python/Pyrex/$(XCHAIN_PYREX).$(XCHAIN_PYREX_SUFFIX)
XCHAIN_PYREX_SOURCE		= $(SRCDIR)/$(XCHAIN_PYREX).$(XCHAIN_PYREX_SUFFIX)
XCHAIN_PYREX_DIR		= $(XCHAIN_BUILDDIR)/$(XCHAIN_PYREX)

# ----------------------------------------------------------------------------
# Get
# ----------------------------------------------------------------------------

xchain-Pyrex_get: $(STATEDIR)/xchain-Pyrex.get

xchain-Pyrex_get_deps = $(XCHAIN_PYREX_SOURCE)

$(STATEDIR)/xchain-Pyrex.get: $(xchain-Pyrex_get_deps)
	@$(call targetinfo, $@)
	@$(call get_patches, $(XCHAIN_PYREX))
	touch $@

$(XCHAIN_PYREX_SOURCE):
	@$(call targetinfo, $@)
	@$(call get, $(XCHAIN_PYREX_URL))

# ----------------------------------------------------------------------------
# Extract
# ----------------------------------------------------------------------------

xchain-Pyrex_extract: $(STATEDIR)/xchain-Pyrex.extract

xchain-Pyrex_extract_deps = $(STATEDIR)/xchain-Pyrex.get

$(STATEDIR)/xchain-Pyrex.extract: $(xchain-Pyrex_extract_deps)
	@$(call targetinfo, $@)
	@$(call clean, $(XCHAIN_PYREX_DIR))
	@$(call extract, $(XCHAIN_PYREX_SOURCE), $(XCHAIN_BUILDDIR))
	@$(call patchin, $(XCHAIN_PYREX), $(XCHAIN_PYREX_DIR))
	touch $@

# ----------------------------------------------------------------------------
# Prepare
# ----------------------------------------------------------------------------

xchain-Pyrex_prepare: $(STATEDIR)/xchain-Pyrex.prepare

#
# dependencies
#
xchain-Pyrex_prepare_deps = \
	$(STATEDIR)/xchain-Pyrex.extract \
	$(STATEDIR)/xchain-python.install

XCHAIN_PYREX_PATH	=  PATH=$(CROSS_PATH)
XCHAIN_PYREX_ENV 	=  $(HOSTCC_ENV)
#XCHAIN_PYREX_ENV	+=

#
# autoconf
#
XCHAIN_PYREX_AUTOCONF = \
	--prefix=$(PTXCONF_PREFIX) \
	--build=$(GNU_HOST)
# 	--host=$(GNU_HOST)
# 	--target=$(PTXCONF_GNU_TARGET)

$(STATEDIR)/xchain-Pyrex.prepare: $(xchain-Pyrex_prepare_deps)
	@$(call targetinfo, $@)
	@$(call clean, $(XCHAIN_PYREX_DIR)/config.cache)
	touch $@

# ----------------------------------------------------------------------------
# Compile
# ----------------------------------------------------------------------------

xchain-Pyrex_compile: $(STATEDIR)/xchain-Pyrex.compile

xchain-Pyrex_compile_deps = $(STATEDIR)/xchain-Pyrex.prepare

$(STATEDIR)/xchain-Pyrex.compile: $(xchain-Pyrex_compile_deps)
	@$(call targetinfo, $@)
	touch $@

# ----------------------------------------------------------------------------
# Install
# ----------------------------------------------------------------------------

xchain-Pyrex_install: $(STATEDIR)/xchain-Pyrex.install

$(STATEDIR)/xchain-Pyrex.install: $(STATEDIR)/xchain-Pyrex.compile
	@$(call targetinfo, $@)
	cd $(XCHAIN_PYREX_DIR) && \
	    $(XCHAIN_PYREX_PATH) python setup.py install
	touch $@

# ----------------------------------------------------------------------------
# Target-Install
# ----------------------------------------------------------------------------

xchain-Pyrex_targetinstall: $(STATEDIR)/xchain-Pyrex.targetinstall

xchain-Pyrex_targetinstall_deps = $(STATEDIR)/xchain-Pyrex.compile

$(STATEDIR)/xchain-Pyrex.targetinstall: $(xchain-Pyrex_targetinstall_deps)
	@$(call targetinfo, $@)
	touch $@

# ----------------------------------------------------------------------------
# Clean
# ----------------------------------------------------------------------------

xchain-Pyrex_clean:
	rm -rf $(STATEDIR)/xchain-Pyrex.*
	rm -rf $(XCHAIN_PYREX_DIR)

# vim: syntax=make
