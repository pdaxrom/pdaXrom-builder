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
ifdef PTXCONF_XCHAIN_LIBIDL082
PACKAGES += xchain-libidl082
endif

#
# Paths and names
#
XCHAIN_LIBIDL082		= $(LIBIDL082)
XCHAIN_LIBIDL082_DIR		= $(XCHAIN_BUILDDIR)/$(XCHAIN_LIBIDL082)

# ----------------------------------------------------------------------------
# Get
# ----------------------------------------------------------------------------

xchain-libidl082_get: $(STATEDIR)/xchain-libidl082.get

xchain-libidl082_get_deps = $(XCHAIN_LIBIDL082_SOURCE)

$(STATEDIR)/xchain-libidl082.get: $(xchain-libidl082_get_deps)
	@$(call targetinfo, $@)
	###@$(call get_patches, $(XCHAIN_LIBIDL082))
	touch $@

$(XCHAIN_LIBIDL082_SOURCE):
	@$(call targetinfo, $@)
	@$(call get, $(XCHAIN_LIBIDL082_URL))

# ----------------------------------------------------------------------------
# Extract
# ----------------------------------------------------------------------------

xchain-libidl082_extract: $(STATEDIR)/xchain-libidl082.extract

xchain-libidl082_extract_deps = $(STATEDIR)/xchain-libidl082.get

$(STATEDIR)/xchain-libidl082.extract: $(xchain-libidl082_extract_deps)
	@$(call targetinfo, $@)
	@$(call clean, $(XCHAIN_LIBIDL082_DIR))
	@$(call extract, $(LIBIDL082_SOURCE), $(XCHAIN_BUILDDIR))
	###@$(call patchin, $(XCHAIN_LIBIDL082), $(XCHAIN_LIBIDL082_DIR))
	touch $@

# ----------------------------------------------------------------------------
# Prepare
# ----------------------------------------------------------------------------

xchain-libidl082_prepare: $(STATEDIR)/xchain-libidl082.prepare

#
# dependencies
#
xchain-libidl082_prepare_deps = \
	$(STATEDIR)/xchain-libidl082.extract

XCHAIN_LIBIDL082_PATH	=  PATH=$(CROSS_PATH)
XCHAIN_LIBIDL082_ENV 	=  $(HOSTCC_ENV)
XCHAIN_LIBIDL082_ENV	+= PKG_CONFIG_PATH=$(PTXCONF_PREFIX)/lib/pkgconfig:$PKG_CONFIG_PATH

#
# autoconf
#
XCHAIN_LIBIDL082_AUTOCONF = \
	--prefix=$(PTXCONF_PREFIX) \
	--build=$(GNU_HOST) \
	--enable-static \
	--disable-shared
# 	--host=$(GNU_HOST)
# 	--target=$(PTXCONF_GNU_TARGET)

$(STATEDIR)/xchain-libidl082.prepare: $(xchain-libidl082_prepare_deps)
	@$(call targetinfo, $@)
	@$(call clean, $(XCHAIN_LIBIDL082_DIR)/config.cache)
	cd $(XCHAIN_LIBIDL082_DIR) && \
		$(XCHAIN_LIBIDL082_PATH) $(XCHAIN_LIBIDL082_ENV) \
		./configure $(XCHAIN_LIBIDL082_AUTOCONF)
	touch $@

# ----------------------------------------------------------------------------
# Compile
# ----------------------------------------------------------------------------

xchain-libidl082_compile: $(STATEDIR)/xchain-libidl082.compile

xchain-libidl082_compile_deps = $(STATEDIR)/xchain-libidl082.prepare

$(STATEDIR)/xchain-libidl082.compile: $(xchain-libidl082_compile_deps)
	@$(call targetinfo, $@)
	$(XCHAIN_LIBIDL082_PATH) $(MAKE) -C $(XCHAIN_LIBIDL082_DIR)
	touch $@

# ----------------------------------------------------------------------------
# Install
# ----------------------------------------------------------------------------

xchain-libidl082_install: $(STATEDIR)/xchain-libidl082.install

$(STATEDIR)/xchain-libidl082.install: $(STATEDIR)/xchain-libidl082.compile
	@$(call targetinfo, $@)
	$(XCHAIN_LIBIDL082_PATH) $(MAKE) -C $(XCHAIN_LIBIDL082_DIR) install
	mv $(PTXCONF_PREFIX)/bin/libIDL-config-2 $(PTXCONF_PREFIX)/bin/libIDL-config-2-host
	touch $@

# ----------------------------------------------------------------------------
# Target-Install
# ----------------------------------------------------------------------------

xchain-libidl082_targetinstall: $(STATEDIR)/xchain-libidl082.targetinstall

xchain-libidl082_targetinstall_deps = $(STATEDIR)/xchain-libidl082.compile

$(STATEDIR)/xchain-libidl082.targetinstall: $(xchain-libidl082_targetinstall_deps)
	@$(call targetinfo, $@)
	touch $@

# ----------------------------------------------------------------------------
# Clean
# ----------------------------------------------------------------------------

xchain-libidl082_clean:
	rm -rf $(STATEDIR)/xchain-libidl082.*
	rm -rf $(XCHAIN_LIBIDL082_DIR)

# vim: syntax=make
