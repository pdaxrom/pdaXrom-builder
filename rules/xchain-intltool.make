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
ifdef PTXCONF_XCHAIN_INTLTOOL
PACKAGES += xchain-intltool
endif

#
# Paths and names
#
XCHAIN_INTLTOOL_VERSION		= 0.33
XCHAIN_INTLTOOL			= intltool-$(XCHAIN_INTLTOOL_VERSION)
XCHAIN_INTLTOOL_SUFFIX		= tar.bz2
XCHAIN_INTLTOOL_URL		= http://ftp.gnome.org/pub/GNOME/sources/intltool/0.33/$(XCHAIN_INTLTOOL).$(XCHAIN_INTLTOOL_SUFFIX)
XCHAIN_INTLTOOL_SOURCE		= $(SRCDIR)/$(XCHAIN_INTLTOOL).$(XCHAIN_INTLTOOL_SUFFIX)
XCHAIN_INTLTOOL_DIR		= $(XCHAIN_BUILDDIR)/$(XCHAIN_INTLTOOL)

# ----------------------------------------------------------------------------
# Get
# ----------------------------------------------------------------------------

xchain-intltool_get: $(STATEDIR)/xchain-intltool.get

xchain-intltool_get_deps = $(XCHAIN_INTLTOOL_SOURCE)

$(STATEDIR)/xchain-intltool.get: $(xchain-intltool_get_deps)
	@$(call targetinfo, $@)
	@$(call get_patches, $(XCHAIN_INTLTOOL))
	touch $@

$(XCHAIN_INTLTOOL_SOURCE):
	@$(call targetinfo, $@)
	@$(call get, $(XCHAIN_INTLTOOL_URL))

# ----------------------------------------------------------------------------
# Extract
# ----------------------------------------------------------------------------

xchain-intltool_extract: $(STATEDIR)/xchain-intltool.extract

xchain-intltool_extract_deps = $(STATEDIR)/xchain-intltool.get

$(STATEDIR)/xchain-intltool.extract: $(xchain-intltool_extract_deps)
	@$(call targetinfo, $@)
	@$(call clean, $(XCHAIN_INTLTOOL_DIR))
	@$(call extract, $(XCHAIN_INTLTOOL_SOURCE), $(XCHAIN_BUILDDIR))
	@$(call patchin, $(XCHAIN_INTLTOOL), $(XCHAIN_INTLTOOL_DIR))
	touch $@

# ----------------------------------------------------------------------------
# Prepare
# ----------------------------------------------------------------------------

xchain-intltool_prepare: $(STATEDIR)/xchain-intltool.prepare

#
# dependencies
#
xchain-intltool_prepare_deps = \
	$(STATEDIR)/xchain-intltool.extract

XCHAIN_INTLTOOL_PATH	=  PATH=$(CROSS_PATH)
XCHAIN_INTLTOOL_ENV 	=  $(HOSTCC_ENV)
#XCHAIN_INTLTOOL_ENV	+=

#
# autoconf
#
XCHAIN_INTLTOOL_AUTOCONF = \
	--prefix=$(PTXCONF_PREFIX) \
	--build=$(GNU_HOST)
# 	--host=$(GNU_HOST)
# 	--target=$(PTXCONF_GNU_TARGET)

$(STATEDIR)/xchain-intltool.prepare: $(xchain-intltool_prepare_deps)
	@$(call targetinfo, $@)
	@$(call clean, $(XCHAIN_INTLTOOL_DIR)/config.cache)
	cd $(XCHAIN_INTLTOOL_DIR) && \
		$(XCHAIN_INTLTOOL_PATH) $(XCHAIN_INTLTOOL_ENV) \
		./configure $(XCHAIN_INTLTOOL_AUTOCONF)
	touch $@

# ----------------------------------------------------------------------------
# Compile
# ----------------------------------------------------------------------------

xchain-intltool_compile: $(STATEDIR)/xchain-intltool.compile

xchain-intltool_compile_deps = $(STATEDIR)/xchain-intltool.prepare

$(STATEDIR)/xchain-intltool.compile: $(xchain-intltool_compile_deps)
	@$(call targetinfo, $@)
	$(XCHAIN_INTLTOOL_PATH) $(MAKE) -C $(XCHAIN_INTLTOOL_DIR)
	touch $@

# ----------------------------------------------------------------------------
# Install
# ----------------------------------------------------------------------------

xchain-intltool_install: $(STATEDIR)/xchain-intltool.install

$(STATEDIR)/xchain-intltool.install: $(STATEDIR)/xchain-intltool.compile
	@$(call targetinfo, $@)
	$(XCHAIN_INTLTOOL_PATH) $(MAKE) -C $(XCHAIN_INTLTOOL_DIR) install
	touch $@

# ----------------------------------------------------------------------------
# Target-Install
# ----------------------------------------------------------------------------

xchain-intltool_targetinstall: $(STATEDIR)/xchain-intltool.targetinstall

xchain-intltool_targetinstall_deps = $(STATEDIR)/xchain-intltool.compile

$(STATEDIR)/xchain-intltool.targetinstall: $(xchain-intltool_targetinstall_deps)
	@$(call targetinfo, $@)
	touch $@

# ----------------------------------------------------------------------------
# Clean
# ----------------------------------------------------------------------------

xchain-intltool_clean:
	rm -rf $(STATEDIR)/xchain-intltool.*
	rm -rf $(XCHAIN_INTLTOOL_DIR)

# vim: syntax=make
