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
ifdef PTXCONF_DEVFSD
PACKAGES += devfsd
endif

#
# Paths and names
#
DEVFSD_VERSION		= 1.3.25
DEVFSD			= devfsd-v$(DEVFSD_VERSION)
DEVFSD_SUFFIX		= tar.gz
DEVFSD_URL		= ftp://ftp.atnf.csiro.au/pub/people/rgooch/linux/daemons/devfsd/$(DEVFSD).$(DEVFSD_SUFFIX)
DEVFSD_SOURCE		= $(SRCDIR)/$(DEVFSD).$(DEVFSD_SUFFIX)
DEVFSD_DIR		= $(BUILDDIR)/devfsd

# ----------------------------------------------------------------------------
# Get
# ----------------------------------------------------------------------------

devfsd_get: $(STATEDIR)/devfsd.get

devfsd_get_deps = $(DEVFSD_SOURCE)

$(STATEDIR)/devfsd.get: $(devfsd_get_deps)
	@$(call targetinfo, $@)
	@$(call get_patches, $(DEVFSD))
	touch $@

$(DEVFSD_SOURCE):
	@$(call targetinfo, $@)
	@$(call get, $(DEVFSD_URL))

# ----------------------------------------------------------------------------
# Extract
# ----------------------------------------------------------------------------

devfsd_extract: $(STATEDIR)/devfsd.extract

devfsd_extract_deps = $(STATEDIR)/devfsd.get

$(STATEDIR)/devfsd.extract: $(devfsd_extract_deps)
	@$(call targetinfo, $@)
	@$(call clean, $(DEVFSD_DIR))
	@$(call extract, $(DEVFSD_SOURCE))
	@$(call patchin, $(DEVFSD))
	touch $@

# ----------------------------------------------------------------------------
# Prepare
# ----------------------------------------------------------------------------

devfsd_prepare: $(STATEDIR)/devfsd.prepare

#
# dependencies
#
devfsd_prepare_deps = \
	$(STATEDIR)/devfsd.extract \
	$(STATEDIR)/virtual-xchain.install

DEVFSD_PATH	=  PATH=$(CROSS_PATH)
DEVFSD_ENV 	=  $(CROSS_ENV)
#DEVFSD_ENV	+=

#
# autoconf
#
DEVFSD_AUTOCONF = \
	--build=$(GNU_HOST) \
	--host=$(PTXCONF_GNU_TARGET) \
	--prefix=$(CROSS_LIB_DIR)

$(STATEDIR)/devfsd.prepare: $(devfsd_prepare_deps)
	@$(call targetinfo, $@)
	@$(call clean, $(DEVFSD_DIR)/config.cache)
	#cd $(DEVFSD_DIR) && \
	#	$(DEVFSD_PATH) $(DEVFSD_ENV) \
	#	./configure $(DEVFSD_AUTOCONF)
	touch $@

# ----------------------------------------------------------------------------
# Compile
# ----------------------------------------------------------------------------

devfsd_compile: $(STATEDIR)/devfsd.compile

devfsd_compile_deps = $(STATEDIR)/devfsd.prepare

$(STATEDIR)/devfsd.compile: $(devfsd_compile_deps)
	@$(call targetinfo, $@)
	$(DEVFSD_PATH) $(MAKE) -C $(DEVFSD_DIR) CC=$(PTXCONF_GNU_TARGET)-gcc
	touch $@

# ----------------------------------------------------------------------------
# Install
# ----------------------------------------------------------------------------

devfsd_install: $(STATEDIR)/devfsd.install

$(STATEDIR)/devfsd.install: $(STATEDIR)/devfsd.compile
	@$(call targetinfo, $@)
	#$(DEVFSD_PATH) $(MAKE) -C $(DEVFSD_DIR) install
	touch $@

# ----------------------------------------------------------------------------
# Target-Install
# ----------------------------------------------------------------------------

devfsd_targetinstall: $(STATEDIR)/devfsd.targetinstall

devfsd_targetinstall_deps = $(STATEDIR)/devfsd.compile

$(STATEDIR)/devfsd.targetinstall: $(devfsd_targetinstall_deps)
	@$(call targetinfo, $@)
	$(INSTALL) -D -m 755 $(DEVFSD_DIR)/devfsd $(DEVFSD_DIR)/ipk/sbin/devfsd
	$(CROSSSTRIP) $(DEVFSD_DIR)/ipk/sbin/devfsd
	mkdir -p $(DEVFSD_DIR)/ipk/CONTROL
	echo "Package: devfsd" 							 >$(DEVFSD_DIR)/ipk/CONTROL/control
	echo "Priority: optional" 						>>$(DEVFSD_DIR)/ipk/CONTROL/control
	echo "Section: Utilities" 						>>$(DEVFSD_DIR)/ipk/CONTROL/control
	echo "Maintainer: Alexander Chukov <sash@pdaXrom.org>" 			>>$(DEVFSD_DIR)/ipk/CONTROL/control
	echo "Architecture: $(SHORT_TARGET)" 					>>$(DEVFSD_DIR)/ipk/CONTROL/control
	echo "Version: $(DEVFSD_VERSION)" 					>>$(DEVFSD_DIR)/ipk/CONTROL/control
	echo "Depends: " 							>>$(DEVFSD_DIR)/ipk/CONTROL/control
	echo "Description: optional daemon for managing devfs (the Linux Device Filesystem)">>$(DEVFSD_DIR)/ipk/CONTROL/control
	cd $(FEEDDIR) && $(XMKIPKG) $(DEVFSD_DIR)/ipk
	touch $@

# ----------------------------------------------------------------------------
# Image-Install
# ----------------------------------------------------------------------------

ifdef PTXCONF_DEVFSD_INSTALL
ROMPACKAGES += $(STATEDIR)/devfsd.imageinstall
endif

devfsd_imageinstall_deps = $(STATEDIR)/devfsd.targetinstall \
	$(STATEDIR)/virtual-image.install

$(STATEDIR)/devfsd.imageinstall: $(devfsd_imageinstall_deps)
	@$(call targetinfo, $@)
	cd $(FEEDDIR) && $(XIPKG) install devfsd
	touch $@

# ----------------------------------------------------------------------------
# Clean
# ----------------------------------------------------------------------------

devfsd_clean:
	rm -rf $(STATEDIR)/devfsd.*
	rm -rf $(DEVFSD_DIR)

# vim: syntax=make
