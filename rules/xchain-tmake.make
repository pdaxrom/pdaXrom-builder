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
ifdef PTXCONF_XCHAIN_TMAKE
PACKAGES += xchain-tmake
endif

#
# Paths and names
#
XCHAIN_TMAKE_VERSION		= 1.13
XCHAIN_TMAKE			= tmake-$(XCHAIN_TMAKE_VERSION)
XCHAIN_TMAKE_SUFFIX		= tar.gz
XCHAIN_TMAKE_URL		= ftp://ftp.trolltech.com/freebies/tmake/$(XCHAIN_TMAKE).$(XCHAIN_TMAKE_SUFFIX)
XCHAIN_TMAKE_SOURCE		= $(SRCDIR)/$(XCHAIN_TMAKE).$(XCHAIN_TMAKE_SUFFIX)
XCHAIN_TMAKE_DIR		= $(XCHAIN_BUILDDIR)/$(XCHAIN_TMAKE)

# ----------------------------------------------------------------------------
# Get
# ----------------------------------------------------------------------------

xchain-tmake_get: $(STATEDIR)/xchain-tmake.get

xchain-tmake_get_deps = $(XCHAIN_TMAKE_SOURCE)

$(STATEDIR)/xchain-tmake.get: $(xchain-tmake_get_deps)
	@$(call targetinfo, $@)
	@$(call get_patches, $(XCHAIN_TMAKE))
	touch $@

$(XCHAIN_TMAKE_SOURCE):
	@$(call targetinfo, $@)
	@$(call get, $(XCHAIN_TMAKE_URL))

# ----------------------------------------------------------------------------
# Extract
# ----------------------------------------------------------------------------

xchain-tmake_extract: $(STATEDIR)/xchain-tmake.extract

xchain-tmake_extract_deps = $(STATEDIR)/xchain-tmake.get

$(STATEDIR)/xchain-tmake.extract: $(xchain-tmake_extract_deps)
	@$(call targetinfo, $@)
	@$(call clean, $(XCHAIN_TMAKE_DIR))
	@$(call extract, $(XCHAIN_TMAKE_SOURCE), $(XCHAIN_BUILDDIR))
	@$(call patchin, $(XCHAIN_TMAKE), $(XCHAIN_TMAKE_DIR))
	touch $@

# ----------------------------------------------------------------------------
# Prepare
# ----------------------------------------------------------------------------

xchain-tmake_prepare: $(STATEDIR)/xchain-tmake.prepare

#
# dependencies
#
xchain-tmake_prepare_deps = \
	$(STATEDIR)/xchain-tmake.extract

XCHAIN_TMAKE_PATH	=  PATH=$(CROSS_PATH)
XCHAIN_TMAKE_ENV 	=  $(HOSTCC_ENV)
#XCHAIN_TMAKE_ENV	+=

#
# autoconf
#
XCHAIN_TMAKE_AUTOCONF = \
	--prefix=$(PTXCONF_PREFIX) \
	--build=$(GNU_HOST)
# 	--host=$(GNU_HOST)
# 	--target=$(PTXCONF_GNU_TARGET)

$(STATEDIR)/xchain-tmake.prepare: $(xchain-tmake_prepare_deps)
	@$(call targetinfo, $@)
	@$(call clean, $(XCHAIN_TMAKE_DIR)/config.cache)
	#cd $(XCHAIN_TMAKE_DIR) && \
	#	$(XCHAIN_TMAKE_PATH) $(XCHAIN_TMAKE_ENV) \
	#	./configure $(XCHAIN_TMAKE_AUTOCONF)
	touch $@

# ----------------------------------------------------------------------------
# Compile
# ----------------------------------------------------------------------------

xchain-tmake_compile: $(STATEDIR)/xchain-tmake.compile

xchain-tmake_compile_deps = $(STATEDIR)/xchain-tmake.prepare

$(STATEDIR)/xchain-tmake.compile: $(xchain-tmake_compile_deps)
	@$(call targetinfo, $@)
	#$(XCHAIN_TMAKE_PATH) $(MAKE) -C $(XCHAIN_TMAKE_DIR)
	touch $@

# ----------------------------------------------------------------------------
# Install
# ----------------------------------------------------------------------------

xchain-tmake_install: $(STATEDIR)/xchain-tmake.install

$(STATEDIR)/xchain-tmake.install: $(STATEDIR)/xchain-tmake.compile
	@$(call targetinfo, $@)
	#$(XCHAIN_TMAKE_PATH) $(MAKE) -C $(XCHAIN_TMAKE_DIR) install
	mkdir -p $(PTXCONF_PREFIX)/tmake
	cp -a $(XCHAIN_TMAKE_DIR)/* $(PTXCONF_PREFIX)/tmake/
	touch $@

# ----------------------------------------------------------------------------
# Target-Install
# ----------------------------------------------------------------------------

xchain-tmake_targetinstall: $(STATEDIR)/xchain-tmake.targetinstall

xchain-tmake_targetinstall_deps = $(STATEDIR)/xchain-tmake.compile

$(STATEDIR)/xchain-tmake.targetinstall: $(xchain-tmake_targetinstall_deps)
	@$(call targetinfo, $@)
	touch $@

# ----------------------------------------------------------------------------
# Clean
# ----------------------------------------------------------------------------

xchain-tmake_clean:
	rm -rf $(STATEDIR)/xchain-tmake.*
	rm -rf $(XCHAIN_TMAKE_DIR)

# vim: syntax=make
