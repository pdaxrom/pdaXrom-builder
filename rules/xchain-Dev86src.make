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
ifdef PTXCONF_XCHAIN_DEV86SRC
PACKAGES += xchain-Dev86src
endif

#
# Paths and names
#
XCHAIN_DEV86SRC			= $(DEV86SRC)
XCHAIN_DEV86SRC_DIR		= $(XCHAIN_BUILDDIR)/dev86-$(DEV86SRC_VERSION)

# ----------------------------------------------------------------------------
# Get
# ----------------------------------------------------------------------------

xchain-Dev86src_get: $(STATEDIR)/xchain-Dev86src.get

xchain-Dev86src_get_deps = $(XCHAIN_DEV86SRC_SOURCE)

$(STATEDIR)/xchain-Dev86src.get: $(xchain-Dev86src_get_deps)
	@$(call targetinfo, $@)
	@$(call get_patches, $(DEV86SRC))
	touch $@

$(XCHAIN_DEV86SRC_SOURCE):
	@$(call targetinfo, $@)
	@$(call get, $(DEV86SRC_URL))

# ----------------------------------------------------------------------------
# Extract
# ----------------------------------------------------------------------------

xchain-Dev86src_extract: $(STATEDIR)/xchain-Dev86src.extract

xchain-Dev86src_extract_deps = $(STATEDIR)/xchain-Dev86src.get

$(STATEDIR)/xchain-Dev86src.extract: $(xchain-Dev86src_extract_deps)
	@$(call targetinfo, $@)
	@$(call clean,   $(XCHAIN_DEV86SRC_DIR))
	@$(call extract, $(DEV86SRC_SOURCE), $(XCHAIN_BUILDDIR))
	@$(call patchin, $(DEV86SRC), $(XCHAIN_DEV86SRC_DIR))
	touch $@

# ----------------------------------------------------------------------------
# Prepare
# ----------------------------------------------------------------------------

xchain-Dev86src_prepare: $(STATEDIR)/xchain-Dev86src.prepare

#
# dependencies
#
xchain-Dev86src_prepare_deps = \
	$(STATEDIR)/xchain-Dev86src.extract

XCHAIN_DEV86SRC_PATH	=  PATH=$(CROSS_PATH)
XCHAIN_DEV86SRC_ENV 	=  $(HOSTCC_ENV)
#XCHAIN_DEV86SRC_ENV	+=

#
# autoconf
#
XCHAIN_DEV86SRC_AUTOCONF = \
	--prefix=$(PTXCONF_PREFIX) \
	--build=$(GNU_HOST)
# 	--host=$(GNU_HOST)
# 	--target=$(PTXCONF_GNU_TARGET)

$(STATEDIR)/xchain-Dev86src.prepare: $(xchain-Dev86src_prepare_deps)
	@$(call targetinfo, $@)
	@$(call clean, $(XCHAIN_DEV86SRC_DIR)/config.cache)
	#cd $(XCHAIN_DEV86SRC_DIR) && \
	#	$(XCHAIN_DEV86SRC_PATH) $(XCHAIN_DEV86SRC_ENV) \
	#	./configure $(XCHAIN_DEV86SRC_AUTOCONF)
	touch $@

# ----------------------------------------------------------------------------
# Compile
# ----------------------------------------------------------------------------

xchain-Dev86src_compile: $(STATEDIR)/xchain-Dev86src.compile

xchain-Dev86src_compile_deps = $(STATEDIR)/xchain-Dev86src.prepare

$(STATEDIR)/xchain-Dev86src.compile: $(xchain-Dev86src_compile_deps)
	@$(call targetinfo, $@)
	echo quit | $(XCHAIN_DEV86SRC_PATH) $(MAKE) -C $(XCHAIN_DEV86SRC_DIR) PREFIX=$(PTXCONF_PREFIX)
	touch $@

# ----------------------------------------------------------------------------
# Install
# ----------------------------------------------------------------------------

xchain-Dev86src_install: $(STATEDIR)/xchain-Dev86src.install

$(STATEDIR)/xchain-Dev86src.install: $(STATEDIR)/xchain-Dev86src.compile
	@$(call targetinfo, $@)
	$(XCHAIN_DEV86SRC_PATH) $(MAKE) -C $(XCHAIN_DEV86SRC_DIR) install PREFIX=$(PTXCONF_PREFIX)
	touch $@

# ----------------------------------------------------------------------------
# Target-Install
# ----------------------------------------------------------------------------

xchain-Dev86src_targetinstall: $(STATEDIR)/xchain-Dev86src.targetinstall

xchain-Dev86src_targetinstall_deps = $(STATEDIR)/xchain-Dev86src.compile

$(STATEDIR)/xchain-Dev86src.targetinstall: $(xchain-Dev86src_targetinstall_deps)
	@$(call targetinfo, $@)
	touch $@

# ----------------------------------------------------------------------------
# Clean
# ----------------------------------------------------------------------------

xchain-Dev86src_clean:
	rm -rf $(STATEDIR)/xchain-Dev86src.*
	rm -rf $(XCHAIN_DEV86SRC_DIR)

# vim: syntax=make
