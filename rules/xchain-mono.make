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
ifdef PTXCONF_XCHAIN_MONO
PACKAGES += xchain-mono
endif

#
# Paths and names
#
XCHAIN_MONO		= mono-$(MONO_VERSION)
XCHAIN_MONO_DIR		= $(XCHAIN_BUILDDIR)/$(XCHAIN_MONO)

# ----------------------------------------------------------------------------
# Get
# ----------------------------------------------------------------------------

xchain-mono_get: $(STATEDIR)/xchain-mono.get

xchain-mono_get_deps = $(MONO_SOURCE)

$(STATEDIR)/xchain-mono.get: $(xchain-mono_get_deps)
	@$(call targetinfo, $@)
	@$(call get_patches, $(MONO))
	touch $@

$(XCHAIN_MONO_SOURCE):
	@$(call targetinfo, $@)
	@$(call get, $(MONO_URL))

# ----------------------------------------------------------------------------
# Extract
# ----------------------------------------------------------------------------

xchain-mono_extract: $(STATEDIR)/xchain-mono.extract

xchain-mono_extract_deps = $(STATEDIR)/xchain-mono.get

$(STATEDIR)/xchain-mono.extract: $(xchain-mono_extract_deps)
	@$(call targetinfo, $@)
	@$(call clean,   $(XCHAIN_MONO_DIR))
	@$(call extract, $(MONO_SOURCE), $(XCHAIN_BUILDDIR))
	@$(call patchin, $(XCHAIN_MONO), $(XCHAIN_MONO_DIR))
	touch $@

# ----------------------------------------------------------------------------
# Prepare
# ----------------------------------------------------------------------------

xchain-mono_prepare: $(STATEDIR)/xchain-mono.prepare

#
# dependencies
#
xchain-mono_prepare_deps = \
	$(STATEDIR)/xchain-mono.extract

XCHAIN_MONO_PATH	=  PATH=$(CROSS_PATH)
XCHAIN_MONO_ENV 	=  $(HOSTCC_ENV)
#XCHAIN_MONO_ENV	+=

#
# autoconf
#
XCHAIN_MONO_AUTOCONF = \
	--prefix=$(PTXCONF_PREFIX) \
	--build=$(GNU_HOST)
	--disable-debug \
	--with-tls=pthread

# 	--host=$(GNU_HOST)
# 	--target=$(PTXCONF_GNU_TARGET)

$(STATEDIR)/xchain-mono.prepare: $(xchain-mono_prepare_deps)
	@$(call targetinfo, $@)
	@$(call clean, $(XCHAIN_MONO_DIR)/config.cache)
	cd $(XCHAIN_MONO_DIR) && \
		$(XCHAIN_MONO_PATH) $(XCHAIN_MONO_ENV) \
		./configure $(XCHAIN_MONO_AUTOCONF)
	touch $@

# ----------------------------------------------------------------------------
# Compile
# ----------------------------------------------------------------------------

xchain-mono_compile: $(STATEDIR)/xchain-mono.compile

xchain-mono_compile_deps = $(STATEDIR)/xchain-mono.prepare

$(STATEDIR)/xchain-mono.compile: $(xchain-mono_compile_deps)
	@$(call targetinfo, $@)
	$(XCHAIN_MONO_PATH) $(MAKE) -C $(XCHAIN_MONO_DIR)
	touch $@

# ----------------------------------------------------------------------------
# Install
# ----------------------------------------------------------------------------

xchain-mono_install: $(STATEDIR)/xchain-mono.install

$(STATEDIR)/xchain-mono.install: $(STATEDIR)/xchain-mono.compile
	@$(call targetinfo, $@)
	#$(XCHAIN_MONO_PATH) $(MAKE) -C $(XCHAIN_MONO_DIR) install
	touch $@

# ----------------------------------------------------------------------------
# Target-Install
# ----------------------------------------------------------------------------

xchain-mono_targetinstall: $(STATEDIR)/xchain-mono.targetinstall

xchain-mono_targetinstall_deps = $(STATEDIR)/xchain-mono.compile

$(STATEDIR)/xchain-mono.targetinstall: $(xchain-mono_targetinstall_deps)
	@$(call targetinfo, $@)
	touch $@

# ----------------------------------------------------------------------------
# Clean
# ----------------------------------------------------------------------------

xchain-mono_clean:
	rm -rf $(STATEDIR)/xchain-mono.*
	rm -rf $(XCHAIN_MONO_DIR)

# vim: syntax=make
