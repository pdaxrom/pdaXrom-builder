# -*-makefile-*-
# $Id: xchain-distcc.make,v 1.2 2003/10/29 16:43:30 mkl Exp $
#
# Copyright (C) 2003 Ixia Communications, by Dan Kegel
#          
# See CREDITS for details about who has contributed to this project.
#
# For further information about the PTXdist project and license conditions
# see the README file.
#

#
# We provide this package
#
ifdef PTXCONF_XCHAIN-DISTCC
PACKAGES += xchain-distcc
endif

#
# Paths and names
#
XCHAIN-DISTCC_VERSION	= 2.14
XCHAIN-DISTCC		= distcc-$(XCHAIN-DISTCC_VERSION)
XCHAIN-DISTCC_SUFFIX	= tar.bz2
XCHAIN-DISTCC_URL	= http://distcc.samba.org/ftp/distcc/$(XCHAIN-DISTCC).$(XCHAIN-DISTCC_SUFFIX)
XCHAIN-DISTCC_SOURCE	= $(SRCDIR)/$(XCHAIN-DISTCC).$(XCHAIN-DISTCC_SUFFIX)
XCHAIN-DISTCC_DIR	= $(BUILDDIR)/$(XCHAIN-DISTCC)

# ----------------------------------------------------------------------------
# Get
# ----------------------------------------------------------------------------

xchain-distcc_get: $(STATEDIR)/xchain-distcc.get

xchain-distcc_get_deps	=  $(XCHAIN-DISTCC_SOURCE)

$(STATEDIR)/xchain-distcc.get: $(xchain-distcc_get_deps)
	@$(call targetinfo, $@)
	touch $@

$(XCHAIN-DISTCC_SOURCE):
	@$(call targetinfo, $@)
	@$(call get, $(XCHAIN-DISTCC_URL))

# ----------------------------------------------------------------------------
# Extract
# ----------------------------------------------------------------------------

xchain-distcc_extract: $(STATEDIR)/xchain-distcc.extract

xchain-distcc_extract_deps	=  $(STATEDIR)/xchain-distcc.get

$(STATEDIR)/xchain-distcc.extract: $(xchain-distcc_extract_deps)
	@$(call targetinfo, $@)
	@$(call clean, $(XCHAIN-DISTCC_DIR))
	@$(call extract, $(XCHAIN-DISTCC_SOURCE))
	touch $@

# ----------------------------------------------------------------------------
# Prepare
# ----------------------------------------------------------------------------

xchain-distcc_prepare: $(STATEDIR)/xchain-distcc.prepare

#
# dependencies
#
xchain-distcc_prepare_deps =  \
	$(STATEDIR)/xchain-distcc.extract

#
# autoconf
#
XCHAIN-DISTCC_AUTOCONF = \
	--prefix=$(PTXCONF_PREFIX)

$(STATEDIR)/xchain-distcc.prepare: $(xchain-distcc_prepare_deps)
	@$(call targetinfo, $@)
	@$(call clean, $(XCHAIN-DISTCC_DIR)/config.cache)
	cd $(XCHAIN-DISTCC_DIR) && \
		./configure $(XCHAIN-DISTCC_AUTOCONF)
	touch $@

# ----------------------------------------------------------------------------
# Compile
# ----------------------------------------------------------------------------

xchain-distcc_compile: $(STATEDIR)/xchain-distcc.compile

xchain-distcc_compile_deps =  $(STATEDIR)/xchain-distcc.prepare

$(STATEDIR)/xchain-distcc.compile: $(xchain-distcc_compile_deps)
	@$(call targetinfo, $@)
	$(XCHAIN-DISTCC_PATH) $(MAKE) $(NATIVE_MAKE_JOBS) -C $(XCHAIN-DISTCC_DIR)
	touch $@

# ----------------------------------------------------------------------------
# Install
# ----------------------------------------------------------------------------

xchain-distcc_install: $(STATEDIR)/xchain-distcc.install

$(STATEDIR)/xchain-distcc.install: $(STATEDIR)/xchain-distcc.compile
	@$(call targetinfo, $@)
	$(XCHAIN-DISTCC_PATH) $(MAKE) -C $(XCHAIN-DISTCC_DIR) install
	rm -rf $(PTXCONF_PREFIX)/lib/distcc/bin
	mkdir -p $(PTXCONF_PREFIX)/lib/distcc/bin
	cd $(PTXCONF_PREFIX)/lib/distcc/bin \
	   && ln -s ../../../bin/$(PTXCONF_GNU_TARGET)-* . \
	   && for a in $(PTXCONF_GNU_TARGET)-[cg][+c][+c] $(PTXCONF_GNU_TARGET)-cc; do \
	       rm -f $$a; ln -s ../../../bin/distcc $$a; \
	   done
	touch $@

# ----------------------------------------------------------------------------
# Target-Install
# ----------------------------------------------------------------------------

xchain-distcc_targetinstall: $(STATEDIR)/xchain-distcc.targetinstall

xchain-distcc_targetinstall_deps	=  $(STATEDIR)/xchain-distcc.compile

$(STATEDIR)/xchain-distcc.targetinstall: $(xchain-distcc_targetinstall_deps)
	@$(call targetinfo, $@)
	touch $@

# ----------------------------------------------------------------------------
# Clean
# ----------------------------------------------------------------------------

xchain-distcc_clean:
	rm -rf $(STATEDIR)/xchain-distcc.*
	rm -rf $(XCHAIN-DISTCC_DIR)

# vim: syntax=make
