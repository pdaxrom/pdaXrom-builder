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
ifdef PTXCONF_XCHAIN_GLIB22
PACKAGES += xchain-glib22
endif

#
# Paths and names
#
XCHAIN_GLIB22			= glib-$(GLIB22_VERSION)
XCHAIN_GLIB22_DIR		= $(XCHAIN_BUILDDIR)/$(XCHAIN_GLIB22)

# ----------------------------------------------------------------------------
# Get
# ----------------------------------------------------------------------------

xchain-glib22_get: $(STATEDIR)/xchain-glib22.get

xchain-glib22_get_deps = $(XCHAIN_GLIB22_SOURCE)

$(STATEDIR)/xchain-glib22.get: $(xchain-glib22_get_deps)
	@$(call targetinfo, $@)
	@$(call get_patches, $(GLIB22))
	touch $@

$(XCHAIN_GLIB22_SOURCE):
	@$(call targetinfo, $@)
	@$(call get, $(GLIB22_URL))

# ----------------------------------------------------------------------------
# Extract
# ----------------------------------------------------------------------------

xchain-glib22_extract: $(STATEDIR)/xchain-glib22.extract

xchain-glib22_extract_deps = $(STATEDIR)/xchain-glib22.get

$(STATEDIR)/xchain-glib22.extract: $(xchain-glib22_extract_deps)
	@$(call targetinfo, $@)
	@$(call clean, $(XCHAIN_GLIB22_DIR))
	@$(call extract, $(GLIB22_SOURCE), $(XCHAIN_BUILDDIR))
	###@$(call patchin, $(GLIB22), $(XCHAIN_GLIB22_DIR))
	touch $@

# ----------------------------------------------------------------------------
# Prepare
# ----------------------------------------------------------------------------

xchain-glib22_prepare: $(STATEDIR)/xchain-glib22.prepare

#
# dependencies
#
xchain-glib22_prepare_deps = \
	$(STATEDIR)/xchain-glib22.extract

XCHAIN_GLIB22_PATH	=  PATH=$(CROSS_PATH)
XCHAIN_GLIB22_ENV 	=  $(HOSTCC_ENV)
#XCHAIN_GLIB22_ENV	+=

#
# autoconf
#
XCHAIN_GLIB22_AUTOCONF = \
	--prefix=$(PTXCONF_PREFIX) \
	--build=$(GNU_HOST) \
	--with-libiconv=gnu
# 	--host=$(GNU_HOST)
# 	--target=$(PTXCONF_GNU_TARGET)

$(STATEDIR)/xchain-glib22.prepare: $(xchain-glib22_prepare_deps)
	@$(call targetinfo, $@)
	@$(call clean, $(XCHAIN_GLIB22_DIR)/config.cache)
	cd $(XCHAIN_GLIB22_DIR) && \
		$(XCHAIN_GLIB22_PATH) $(XCHAIN_GLIB22_ENV) \
		./configure $(XCHAIN_GLIB22_AUTOCONF)
	touch $@

# ----------------------------------------------------------------------------
# Compile
# ----------------------------------------------------------------------------

xchain-glib22_compile: $(STATEDIR)/xchain-glib22.compile

xchain-glib22_compile_deps = $(STATEDIR)/xchain-glib22.prepare

$(STATEDIR)/xchain-glib22.compile: $(xchain-glib22_compile_deps)
	@$(call targetinfo, $@)
	$(XCHAIN_GLIB22_PATH) $(MAKE) -C $(XCHAIN_GLIB22_DIR)
	touch $@

# ----------------------------------------------------------------------------
# Install
# ----------------------------------------------------------------------------

xchain-glib22_install: $(STATEDIR)/xchain-glib22.install

$(STATEDIR)/xchain-glib22.install: $(STATEDIR)/xchain-glib22.compile
	@$(call targetinfo, $@)
	$(XCHAIN_GLIB22_PATH) $(MAKE) -C $(XCHAIN_GLIB22_DIR) install
	touch $@

# ----------------------------------------------------------------------------
# Target-Install
# ----------------------------------------------------------------------------

xchain-glib22_targetinstall: $(STATEDIR)/xchain-glib22.targetinstall

xchain-glib22_targetinstall_deps = $(STATEDIR)/xchain-glib22.compile

$(STATEDIR)/xchain-glib22.targetinstall: $(xchain-glib22_targetinstall_deps)
	@$(call targetinfo, $@)
	touch $@

# ----------------------------------------------------------------------------
# Clean
# ----------------------------------------------------------------------------

xchain-glib22_clean:
	rm -rf $(STATEDIR)/xchain-glib22.*
	rm -rf $(XCHAIN_GLIB22_DIR)

# vim: syntax=make
