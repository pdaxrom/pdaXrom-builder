# -*-makefile-*-
# $Id: autoconf-2.57.make,v 1.4 2003/10/23 15:01:19 mkl Exp $
#
# Copyright (C) 2002 by Pengutronix e.K., Hildesheim, Germany
# See CREDITS for details about who has contributed to this project. 
#
# For further information about the PTXdist project and license conditions
# see the README file.
#

#
# We provide this package
#
ifdef PTXCONF_AUTOCONF257
PACKAGES += autoconf257
endif

#
# Paths and names 
#
###AUTOCONF257			= autoconf-2.57
AUTOCONF257			= autoconf-2.59
AUTOCONF257_URL			= http://ftp.gnu.org/pub/gnu/autoconf/$(AUTOCONF257).tar.bz2
AUTOCONF257_SOURCE		= $(SRCDIR)/$(AUTOCONF257).tar.bz2
AUTOCONF257_DIR			= $(BUILDDIR)/$(AUTOCONF257)

# ----------------------------------------------------------------------------
# Get
# ----------------------------------------------------------------------------

autoconf257_get: $(STATEDIR)/autoconf257.get

$(STATEDIR)/autoconf257.get: $(AUTOCONF257_SOURCE)
	@$(call targetinfo, $@)
	touch $@

$(AUTOCONF257_SOURCE):
	@$(call targetinfo, $@)
	@$(call get, $(AUTOCONF257_URL))

# ----------------------------------------------------------------------------
# Extract
# ----------------------------------------------------------------------------

autoconf257_extract: $(STATEDIR)/autoconf257.extract

$(STATEDIR)/autoconf257.extract: $(STATEDIR)/autoconf257.get
	@$(call targetinfo, $@)
	@$(call clean, $(AUTOCONF257_DIR))
	@$(call extract, $(AUTOCONF257_SOURCE))
	touch $@

# ----------------------------------------------------------------------------
# Prepare
# ----------------------------------------------------------------------------

autoconf257_prepare: $(STATEDIR)/autoconf257.prepare

AUTOCONF257_ENV = $(HOSTCC_ENV)

$(STATEDIR)/autoconf257.prepare: $(STATEDIR)/autoconf257.extract
	@$(call targetinfo, $@)
	cd $(AUTOCONF257_DIR) && \
		$(AUTOCONF257_ENV) \
		./configure --prefix=$(PTXCONF_PREFIX)
		#$(AUTOCONF257)
	touch $@

# ----------------------------------------------------------------------------
# Compile
# ----------------------------------------------------------------------------

autoconf257_compile: $(STATEDIR)/autoconf257.compile

$(STATEDIR)/autoconf257.compile: $(STATEDIR)/autoconf257.prepare 
	@$(call targetinfo, $@)
	make -C $(AUTOCONF257_DIR)
	touch $@

# ----------------------------------------------------------------------------
# Install
# ----------------------------------------------------------------------------

autoconf257_install: $(STATEDIR)/autoconf257.install

$(STATEDIR)/autoconf257.install: $(STATEDIR)/autoconf257.compile
	@$(call targetinfo, $@)
	make -C $(AUTOCONF257_DIR) install
	touch $@

# ----------------------------------------------------------------------------
# Target-Install
# ----------------------------------------------------------------------------

autoconf257_targetinstall: $(STATEDIR)/autoconf257.targetinstall

$(STATEDIR)/autoconf257.targetinstall: $(STATEDIR)/autoconf257.install
	@$(call targetinfo, $@)
	touch $@

# ----------------------------------------------------------------------------
# Clean
# ----------------------------------------------------------------------------

autoconf257_clean: 
	rm -rf $(STATEDIR)/autoconf257.* $(AUTOCONF257_DIR)

# vim: syntax=make
