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
ifdef PTXCONF_XCHAIN_LIBIDL
PACKAGES += xchain-libIDL
endif

#
# Paths and names
#
XCHAIN_LIBIDL			= $(LIBIDL)
XCHAIN_LIBIDL_DIR		= $(XCHAIN_BUILDDIR)/$(XCHAIN_LIBIDL)

# ----------------------------------------------------------------------------
# Get
# ----------------------------------------------------------------------------

xchain-libIDL_get: $(STATEDIR)/xchain-libIDL.get

xchain-libIDL_get_deps = $(XCHAIN_LIBIDL_SOURCE)

$(STATEDIR)/xchain-libIDL.get: $(xchain-libIDL_get_deps)
	@$(call targetinfo, $@)
	@$(call get_patches, $(LIBIDL))
	touch $@

$(XCHAIN_LIBIDL_SOURCE):
	@$(call targetinfo, $@)
	@$(call get, $(LIBIDL_URL))

# ----------------------------------------------------------------------------
# Extract
# ----------------------------------------------------------------------------

xchain-libIDL_extract: $(STATEDIR)/xchain-libIDL.extract

xchain-libIDL_extract_deps = $(STATEDIR)/xchain-libIDL.get

$(STATEDIR)/xchain-libIDL.extract: $(xchain-libIDL_extract_deps)
	@$(call targetinfo, $@)
	@$(call clean, $(XCHAIN_LIBIDL_DIR))
	@$(call extract, $(LIBIDL_SOURCE), $(XCHAIN_BUILDDIR))
	@$(call patchin, $(LIBIDL), $(XCHAIN_LIBIDL_DIR))
	touch $@

# ----------------------------------------------------------------------------
# Prepare
# ----------------------------------------------------------------------------

xchain-libIDL_prepare: $(STATEDIR)/xchain-libIDL.prepare

#
# dependencies
#
xchain-libIDL_prepare_deps = \
	$(STATEDIR)/xchain-libIDL.extract

#XCHAIN_LIBIDL_PATH	=  PATH=$(NATIVE_SDK_FILES_PREFIX)/../bin:$(CROSS_PATH)
#XCHAIN_LIBIDL_PATH	=  PATH=$(CROSS_PATH)
XCHAIN_LIBIDL_ENV 	=  $(HOSTCC_ENV)
#XCHAIN_LIBIDL_ENV	+=

#
# autoconf
#
XCHAIN_LIBIDL_AUTOCONF = \
	--prefix=$(PTXCONF_PREFIX) \
	--build=$(GNU_HOST) \
	--enable-static \
	--disable-shared
# 	--host=$(GNU_HOST)
# 	--target=$(PTXCONF_GNU_TARGET)

$(STATEDIR)/xchain-libIDL.prepare: $(xchain-libIDL_prepare_deps)
	@$(call targetinfo, $@)
	@$(call clean, $(XCHAIN_LIBIDL_DIR)/config.cache)
	cd $(XCHAIN_LIBIDL_DIR) && \
		$(XCHAIN_LIBIDL_PATH) $(XCHAIN_LIBIDL_ENV) \
		./configure $(XCHAIN_LIBIDL_AUTOCONF)
	touch $@

# ----------------------------------------------------------------------------
# Compile
# ----------------------------------------------------------------------------

xchain-libIDL_compile: $(STATEDIR)/xchain-libIDL.compile

xchain-libIDL_compile_deps = $(STATEDIR)/xchain-libIDL.prepare

$(STATEDIR)/xchain-libIDL.compile: $(xchain-libIDL_compile_deps)
	@$(call targetinfo, $@)
	$(XCHAIN_LIBIDL_PATH) $(MAKE) -C $(XCHAIN_LIBIDL_DIR)
	touch $@

# ----------------------------------------------------------------------------
# Install
# ----------------------------------------------------------------------------

xchain-libIDL_install: $(STATEDIR)/xchain-libIDL.install

$(STATEDIR)/xchain-libIDL.install: $(STATEDIR)/xchain-libIDL.compile
	@$(call targetinfo, $@)
	$(XCHAIN_LIBIDL_PATH) $(MAKE) -C $(XCHAIN_LIBIDL_DIR) install
	mv $(PTXCONF_PREFIX)/bin/libIDL-config $(PTXCONF_PREFIX)/bin/libIDL-config-host
	touch $@

# ----------------------------------------------------------------------------
# Target-Install
# ----------------------------------------------------------------------------

xchain-libIDL_targetinstall: $(STATEDIR)/xchain-libIDL.targetinstall

xchain-libIDL_targetinstall_deps = $(STATEDIR)/xchain-libIDL.compile

$(STATEDIR)/xchain-libIDL.targetinstall: $(xchain-libIDL_targetinstall_deps)
	@$(call targetinfo, $@)
	touch $@

# ----------------------------------------------------------------------------
# Clean
# ----------------------------------------------------------------------------

xchain-libIDL_clean:
	rm -rf $(STATEDIR)/xchain-libIDL.*
	rm -rf $(XCHAIN_LIBIDL_DIR)

# vim: syntax=make
