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
ifdef PTXCONF_XCHAIN_SQUASHFS
PACKAGES += xchain-squashfs
endif

#
# Paths and names
#
XCHAIN_SQUASHFS			= squashfs$(SQUASHFS_VERSION)r2
XCHAIN_SQUASHFS_DIR		= $(XCHAIN_BUILDDIR)/$(XCHAIN_SQUASHFS)

# ----------------------------------------------------------------------------
# Get
# ----------------------------------------------------------------------------

xchain-squashfs_get: $(STATEDIR)/xchain-squashfs.get

xchain-squashfs_get_deps = $(SQUASHFS_SOURCE)

# ----------------------------------------------------------------------------
# Extract
# ----------------------------------------------------------------------------

xchain-squashfs_extract: $(STATEDIR)/xchain-squashfs.extract

xchain-squashfs_extract_deps = $(STATEDIR)/squashfs.get

$(STATEDIR)/xchain-squashfs.extract: $(xchain-squashfs_extract_deps)
	@$(call targetinfo, $@)
	@$(call clean,   $(XCHAIN_SQUASHFS_DIR))
	@$(call extract, $(SQUASHFS_SOURCE), $(XCHAIN_BUILDDIR))
	@$(call patchin, $(SQUASHFS), $(XCHAIN_SQUASHFS_DIR))
	touch $@

# ----------------------------------------------------------------------------
# Prepare
# ----------------------------------------------------------------------------

xchain-squashfs_prepare: $(STATEDIR)/xchain-squashfs.prepare

#
# dependencies
#
xchain-squashfs_prepare_deps = \
	$(STATEDIR)/xchain-squashfs.extract

XCHAIN_SQUASHFS_PATH	=  PATH=$(CROSS_PATH)
XCHAIN_SQUASHFS_ENV 	=  $(HOSTCC_ENV)
#XCHAIN_SQUASHFS_ENV	+=

#
# autoconf
#
XCHAIN_SQUASHFS_AUTOCONF = \
	--prefix=$(PTXCONF_PREFIX) \
	--build=$(GNU_HOST)
# 	--host=$(GNU_HOST)
# 	--target=$(PTXCONF_GNU_TARGET)

$(STATEDIR)/xchain-squashfs.prepare: $(xchain-squashfs_prepare_deps)
	@$(call targetinfo, $@)
	@$(call clean, $(XCHAIN_SQUASHFS_DIR)/config.cache)
	#cd $(XCHAIN_SQUASHFS_DIR) && \
	#	$(XCHAIN_SQUASHFS_PATH) $(XCHAIN_SQUASHFS_ENV) \
	#	./configure $(XCHAIN_SQUASHFS_AUTOCONF)
	touch $@

# ----------------------------------------------------------------------------
# Compile
# ----------------------------------------------------------------------------

xchain-squashfs_compile: $(STATEDIR)/xchain-squashfs.compile

xchain-squashfs_compile_deps = $(STATEDIR)/xchain-squashfs.prepare

$(STATEDIR)/xchain-squashfs.compile: $(xchain-squashfs_compile_deps)
	@$(call targetinfo, $@)
	$(XCHAIN_SQUASHFS_PATH) $(MAKE) -C $(XCHAIN_SQUASHFS_DIR)/squashfs-tools
	touch $@

# ----------------------------------------------------------------------------
# Install
# ----------------------------------------------------------------------------

xchain-squashfs_install: $(STATEDIR)/xchain-squashfs.install

$(STATEDIR)/xchain-squashfs.install: $(STATEDIR)/xchain-squashfs.compile
	@$(call targetinfo, $@)
	$(INSTALL) -m 755 $(XCHAIN_SQUASHFS_DIR)/squashfs-tools/mksquashfs $(PTXCONF_PREFIX)/bin/
	touch $@

# ----------------------------------------------------------------------------
# Target-Install
# ----------------------------------------------------------------------------

xchain-squashfs_targetinstall: $(STATEDIR)/xchain-squashfs.targetinstall

xchain-squashfs_targetinstall_deps = $(STATEDIR)/xchain-squashfs.install

$(STATEDIR)/xchain-squashfs.targetinstall: $(xchain-squashfs_targetinstall_deps)
	@$(call targetinfo, $@)
	touch $@

# ----------------------------------------------------------------------------
# Clean
# ----------------------------------------------------------------------------

xchain-squashfs_clean:
	rm -rf $(STATEDIR)/xchain-squashfs.*
	rm -rf $(XCHAIN_SQUASHFS_DIR)

# vim: syntax=make
