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
ifdef PTXCONF_XCHAIN_ORBIT2
PACKAGES += xchain-ORBit2
endif

#
# Paths and names
#
XCHAIN_ORBIT2			= $(ORBIT2)
XCHAIN_ORBIT2_DIR		= $(XCHAIN_BUILDDIR)/$(XCHAIN_ORBIT2)

# ----------------------------------------------------------------------------
# Get
# ----------------------------------------------------------------------------

xchain-ORBit2_get: $(STATEDIR)/xchain-ORBit2.get

xchain-ORBit2_get_deps = $(XCHAIN_ORBIT2_SOURCE)

$(STATEDIR)/xchain-ORBit2.get: $(xchain-ORBit2_get_deps)
	@$(call targetinfo, $@)
	@$(call get_patches, $(ORBIT2))
	touch $@

$(XCHAIN_ORBIT2_SOURCE):
	@$(call targetinfo, $@)
	@$(call get, $(ORBIT2_URL))

# ----------------------------------------------------------------------------
# Extract
# ----------------------------------------------------------------------------

xchain-ORBit2_extract: $(STATEDIR)/xchain-ORBit2.extract

xchain-ORBit2_extract_deps = $(STATEDIR)/xchain-ORBit2.get

$(STATEDIR)/xchain-ORBit2.extract: $(xchain-ORBit2_extract_deps)
	@$(call targetinfo, $@)
	@$(call clean, $(XCHAIN_ORBIT2_DIR))
	@$(call extract, $(ORBIT2_SOURCE), $(XCHAIN_BUILDDIR))
	###@$(call patchin, $(ORBIT2), $(XCHAIN_ORBIT2_DIR))
	touch $@

# ----------------------------------------------------------------------------
# Prepare
# ----------------------------------------------------------------------------

xchain-ORBit2_prepare: $(STATEDIR)/xchain-ORBit2.prepare

#
# dependencies
#
xchain-ORBit2_prepare_deps = \
	$(STATEDIR)/xchain-ORBit2.extract \
	$(STATEDIR)/xchain-libidl082.install

XCHAIN_ORBIT2_PATH	=  PATH=$(CROSS_PATH)
XCHAIN_ORBIT2_ENV 	=  $(HOSTCC_ENV)
XCHAIN_ORBIT2_ENV	+= PKG_CONFIG_PATH=$(PTXCONF_PREFIX)/lib/pkgconfig:/usr/lib/pkgconfig:/usr/local/lib/pkgconfig:/usr/X11R6/lib/pkgconfig

#
# autoconf
#
XCHAIN_ORBIT2_AUTOCONF = \
	--prefix=$(PTXCONF_PREFIX) \
	--build=$(GNU_HOST)
# 	--host=$(GNU_HOST)
# 	--target=$(PTXCONF_GNU_TARGET)

$(STATEDIR)/xchain-ORBit2.prepare: $(xchain-ORBit2_prepare_deps)
	@$(call targetinfo, $@)
	@$(call clean, $(XCHAIN_ORBIT2_DIR)/config.cache)
	cd $(XCHAIN_ORBIT2_DIR) && \
		$(XCHAIN_ORBIT2_PATH) $(XCHAIN_ORBIT2_ENV) $(ORBIT2X_ENV) \
		./configure $(XCHAIN_ORBIT2_AUTOCONF)
	touch $@

# ----------------------------------------------------------------------------
# Compile
# ----------------------------------------------------------------------------

xchain-ORBit2_compile: $(STATEDIR)/xchain-ORBit2.compile

xchain-ORBit2_compile_deps = $(STATEDIR)/xchain-ORBit2.prepare

$(STATEDIR)/xchain-ORBit2.compile: $(xchain-ORBit2_compile_deps)
	@$(call targetinfo, $@)
	$(XCHAIN_ORBIT2_PATH) $(MAKE) -C $(XCHAIN_ORBIT2_DIR)
	###/src/idl-compiler
	touch $@

# ----------------------------------------------------------------------------
# Install
# ----------------------------------------------------------------------------

xchain-ORBit2_install: $(STATEDIR)/xchain-ORBit2.install

$(STATEDIR)/xchain-ORBit2.install: $(STATEDIR)/xchain-ORBit2.compile
	@$(call targetinfo, $@)
	$(XCHAIN_ORBIT2_PATH) $(MAKE) -C $(XCHAIN_ORBIT2_DIR) install
	###cp -a $(XCHAIN_ORBIT2_DIR)/src/idl-compiler/orbit-idl-2 $(PTXCONF_PREFIX)/bin
	touch $@

# ----------------------------------------------------------------------------
# Target-Install
# ----------------------------------------------------------------------------

xchain-ORBit2_targetinstall: $(STATEDIR)/xchain-ORBit2.targetinstall

xchain-ORBit2_targetinstall_deps = $(STATEDIR)/xchain-ORBit2.compile

$(STATEDIR)/xchain-ORBit2.targetinstall: $(xchain-ORBit2_targetinstall_deps)
	@$(call targetinfo, $@)
	touch $@

# ----------------------------------------------------------------------------
# Clean
# ----------------------------------------------------------------------------

xchain-ORBit2_clean:
	rm -rf $(STATEDIR)/xchain-ORBit2.*
	rm -rf $(XCHAIN_ORBIT2_DIR)

# vim: syntax=make
