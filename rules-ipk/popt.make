# -*-makefile-*-
# $Id: popt.make,v 1.4 2003/10/28 01:50:31 mkl Exp $
#
# Copyright (C) 2003 by Benedikt Spranger <b.spranger@pengutronix.de>
#          
# See CREDITS for details about who has contributed to this project.
#
# For further information about the PTXdist project and license conditions
# see the README file.
#

#
# We provide this package
#
ifdef PTXCONF_POPT
PACKAGES += popt
endif

#
# Paths and names
#
POPT_VERSION	= 1.7
POPT		= popt-$(POPT_VERSION)
POPT_SUFFIX	= tar.gz
POPT_URL	= ftp://ftp.rpm.org/pub/rpm/dist/rpm-4.1.x/$(POPT).$(POPT_SUFFIX)
POPT_SOURCE	= $(SRCDIR)/$(POPT).$(POPT_SUFFIX)
POPT_DIR	= $(BUILDDIR)/$(POPT)

# ----------------------------------------------------------------------------
# Get
# ----------------------------------------------------------------------------

popt_get: $(STATEDIR)/popt.get

popt_get_deps = $(POPT_SOURCE)

$(STATEDIR)/popt.get: $(popt_get_deps)
	@$(call targetinfo, $@)
	touch $@

$(POPT_SOURCE):
	@$(call targetinfo, $@)
	@$(call get, $(POPT_URL))

# ----------------------------------------------------------------------------
# Extract
# ----------------------------------------------------------------------------

popt_extract: $(STATEDIR)/popt.extract

popt_extract_deps = $(STATEDIR)/popt.get

$(STATEDIR)/popt.extract: $(popt_extract_deps)
	@$(call targetinfo, $@)
	@$(call clean, $(POPT_DIR))
	@$(call extract, $(POPT_SOURCE))
	touch $@

# ----------------------------------------------------------------------------
# Prepare
# ----------------------------------------------------------------------------

popt_prepare: $(STATEDIR)/popt.prepare

#
# dependencies
#
popt_prepare_deps =  \
	$(STATEDIR)/popt.extract \
	$(STATEDIR)/virtual-xchain.install

POPT_PATH	=  PATH=$(PTXCONF_PREFIX)/$(PTXCONF_GNU_TARGET)/bin:$(CROSS_PATH)
POPT_ENV 	=  $(CROSS_ENV)

#
# autoconf
#
POPT_AUTOCONF = \
	--prefix=$(CROSS_LIB_DIR) \
	--build=$(GNU_HOST) \
	--host=$(PTXCONF_GNU_TARGET)

$(STATEDIR)/popt.prepare: $(popt_prepare_deps)
	@$(call targetinfo, $@)
	@$(call clean, $(POP_DIR)/config.cache)
	cd $(POPT_DIR) && \
		$(POPT_PATH) $(POPT_ENV) \
		./configure $(POPT_AUTOCONF)
	touch $@

# ----------------------------------------------------------------------------
# Compile
# ----------------------------------------------------------------------------

popt_compile: $(STATEDIR)/popt.compile

popt_compile_deps = $(STATEDIR)/popt.prepare

$(STATEDIR)/popt.compile: $(popt_compile_deps)
	@$(call targetinfo, $@)
	$(POPT_PATH) $(MAKE) -C $(POPT_DIR)
	touch $@

# ----------------------------------------------------------------------------
# Install
# ----------------------------------------------------------------------------

popt_install: $(STATEDIR)/popt.install

$(STATEDIR)/popt.install: $(STATEDIR)/popt.compile
	@$(call targetinfo, $@)
	$(POPT_PATH) $(MAKE) -C $(POPT_DIR) install
	touch $@

# ----------------------------------------------------------------------------
# Target-Install
# ----------------------------------------------------------------------------

popt_targetinstall: $(STATEDIR)/popt.targetinstall

popt_targetinstall_deps	= $(STATEDIR)/popt.install

$(STATEDIR)/popt.targetinstall: $(popt_targetinstall_deps)
	@$(call targetinfo, $@)
	rm -rf $(POPT_DIR)/ipk
	$(INSTALL) -m 755 -D $(POPT_DIR)/.libs/libpopt.so.0.0.0 $(POPT_DIR)/ipk/lib/libpopt.so.0.0.0
	$(CROSSSTRIP) -R .note -R .comment $(POPT_DIR)/ipk/lib/libpopt.so.0.0.0
	cd $(POPT_DIR)/ipk/lib && ln -sf libpopt.so.0.0.0 libpopt.so.0
	cd $(POPT_DIR)/ipk/lib && ln -sf libpopt.so.0.0.0 libpopt.so
	mkdir -p $(POPT_DIR)/ipk/CONTROL
	echo "Package: popt" 							 >$(POPT_DIR)/ipk/CONTROL/control
	echo "Priority: optional" 						>>$(POPT_DIR)/ipk/CONTROL/control
	echo "Section: Libraries" 						>>$(POPT_DIR)/ipk/CONTROL/control
	echo "Maintainer: Alexander Chukov <sash@pdaXrom.org>" 			>>$(POPT_DIR)/ipk/CONTROL/control
	echo "Architecture: $(SHORT_TARGET)" 					>>$(POPT_DIR)/ipk/CONTROL/control
	echo "Version: $(POPT_VERSION)" 					>>$(POPT_DIR)/ipk/CONTROL/control
	echo "Depends: " 							>>$(POPT_DIR)/ipk/CONTROL/control
	echo "Description: The popt library exists essentially for parsing command line options." >>$(POPT_DIR)/ipk/CONTROL/control
	cd $(FEEDDIR) && $(XMKIPKG) $(POPT_DIR)/ipk
	touch $@

# ----------------------------------------------------------------------------
# Image-Install
# ----------------------------------------------------------------------------

ifdef PTXCONF_POPT_INSTALL
ROMPACKAGES += $(STATEDIR)/popt.imageinstall
endif

popt_imageinstall_deps = $(STATEDIR)/popt.targetinstall \
	$(STATEDIR)/virtual-image.install

$(STATEDIR)/popt.imageinstall: $(popt_imageinstall_deps)
	@$(call targetinfo, $@)
	cd $(FEEDDIR) && $(XIPKG) install popt
	touch $@

# ----------------------------------------------------------------------------
# Clean
# ----------------------------------------------------------------------------

popt_clean:
	rm -rf $(STATEDIR)/popt.*
	rm -rf $(POPT_DIR)

# vim: syntax=make
