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
#ifdef PTXCONF_NEWLIB
#PACKAGES += newlib
#endif

#
# Paths and names
#
NEWLIB_VERSION		= 1.12.0
NEWLIB			= newlib-$(NEWLIB_VERSION)
NEWLIB_SUFFIX		= tar.gz
NEWLIB_URL		= ftp://sources.redhat.com/pub/newlib/$(NEWLIB).$(NEWLIB_SUFFIX)
NEWLIB_SOURCE		= $(SRCDIR)/$(NEWLIB).$(NEWLIB_SUFFIX)
NEWLIB_DIR		= $(BUILDDIR)/$(NEWLIB)

# ----------------------------------------------------------------------------
# Get
# ----------------------------------------------------------------------------

newlib_get: $(STATEDIR)/newlib.get

newlib_get_deps = $(NEWLIB_SOURCE)

$(STATEDIR)/newlib.get: $(newlib_get_deps)
	@$(call targetinfo, $@)
	@$(call get_patches, $(NEWLIB))
	touch $@

$(NEWLIB_SOURCE):
	@$(call targetinfo, $@)
	@$(call get, $(NEWLIB_URL))

# ----------------------------------------------------------------------------
# Extract
# ----------------------------------------------------------------------------

newlib_extract: $(STATEDIR)/newlib.extract

newlib_extract_deps = $(STATEDIR)/newlib.get

$(STATEDIR)/newlib.extract: $(newlib_extract_deps)
	@$(call targetinfo, $@)
	@$(call clean, $(NEWLIB_DIR))
	@$(call extract, $(NEWLIB_SOURCE))
	@$(call patchin, $(NEWLIB))
	touch $@

# ----------------------------------------------------------------------------
# Prepare
# ----------------------------------------------------------------------------

newlib_prepare: $(STATEDIR)/newlib.prepare

#
# dependencies
#
newlib_prepare_deps = \
	$(STATEDIR)/autoconf213.install \
	$(STATEDIR)/newlib.extract

ifdef PTXCONF_BUILD_CROSSCHAIN
newlib_prepare_deps += \
	$(STATEDIR)/xchain-binutils.install \
	$(STATEDIR)/xchain-gccstage2.extract
endif

NEWLIB_PATH	=  PATH=$(CROSS_PATH)
NEWLIB_ENV 	=  $(CROSS_ENV)
#NEWLIB_ENV	+=

#
# autoconf
#
NEWLIB_AUTOCONF = \
	--target=$(PTXCONF_GNU_TARGET) \
	--prefix=$(CROSS_LIB_DIR)

$(STATEDIR)/newlib.prepare: $(newlib_prepare_deps)
	@$(call targetinfo, $@)
	@$(call clean, $(NEWLIB_DIR)/config.cache)
	#cd $(NEWLIB_DIR) && \
	#	$(NEWLIB_PATH) $(NEWLIB_ENV) \
	#	./configure $(NEWLIB_AUTOCONF)
	cp -a $(NEWLIB_DIR)/newlib	$(GCC_DIR)/
	cp -a $(NEWLIB_DIR)/libgloss	$(GCC_DIR)/
	touch $@

# ----------------------------------------------------------------------------
# Compile
# ----------------------------------------------------------------------------

newlib_compile: $(STATEDIR)/newlib.compile

newlib_compile_deps = $(STATEDIR)/newlib.prepare

ifdef PTXCONF_BUILD_CROSSCHAIN
newlib_compile_deps += \
	$(STATEDIR)/xchain-gccstage2.compile
endif

$(STATEDIR)/newlib.compile: $(newlib_compile_deps)
	@$(call targetinfo, $@)
	##$(NEWLIB_PATH) $(MAKE) -C $(NEWLIB_DIR)
	touch $@

# ----------------------------------------------------------------------------
# Install
# ----------------------------------------------------------------------------

newlib_install: $(STATEDIR)/newlib.install

newlib_install_deps = $(STATEDIR)/newlib.compile

ifdef PTXCONF_BUILD_CROSSCHAIN
newlib_install_deps += \
	$(STATEDIR)/xchain-gccstage2.install
endif

$(STATEDIR)/newlib.install: $(newlib_install_deps)
	@$(call targetinfo, $@)
	##$(NEWLIB_PATH) $(MAKE) -C $(NEWLIB_DIR) install
	touch $@

# ----------------------------------------------------------------------------
# Target-Install
# ----------------------------------------------------------------------------

newlib_targetinstall: $(STATEDIR)/newlib.targetinstall

newlib_targetinstall_deps = $(STATEDIR)/newlib.compile

$(STATEDIR)/newlib.targetinstall: $(newlib_targetinstall_deps)
	@$(call targetinfo, $@)
	touch $@

# ----------------------------------------------------------------------------
# Clean
# ----------------------------------------------------------------------------

newlib_clean:
	rm -rf $(STATEDIR)/newlib.*
	rm -rf $(NEWLIB_DIR)

# vim: syntax=make
