# -*-makefile-*-
# $Id: sysvinit.make,v 1.1 2003/12/04 13:19:46 bsp Exp $
#
# Copyright (C) 2003 by Benedikt Spranger
#          
# See CREDITS for details about who has contributed to this project.
#
# For further information about the PTXdist project and license conditions
# see the README file.
#

#
# We provide this package
#
ifdef PTXCONF_SYSVINIT
PACKAGES += sysvinit
endif

#
# Paths and names
#
SYSVINIT_VERSION	= 2.85
SYSVINIT		= sysvinit-$(SYSVINIT_VERSION)
SYSVINIT_SUFFIX		= tar.bz2
SYSVINIT_URL		= ftp://ftp.cistron.nl/pub/people/miquels/software/$(SYSVINIT).$(SYSVINIT_SUFFIX)
SYSVINIT_SOURCE		= $(SRCDIR)/$(SYSVINIT).$(SYSVINIT_SUFFIX)
SYSVINIT_DIR		= $(BUILDDIR)/$(SYSVINIT)/src

# ----------------------------------------------------------------------------
# Get
# ----------------------------------------------------------------------------

sysvinit_get: $(STATEDIR)/sysvinit.get

sysvinit_get_deps = $(SYSVINIT_SOURCE)

$(STATEDIR)/sysvinit.get: $(sysvinit_get_deps)
	@$(call targetinfo, $@)
	@$(call get_patches, $(SYSVINIT))
	touch $@

$(SYSVINIT_SOURCE):
	@$(call targetinfo, $@)
	@$(call get, $(SYSVINIT_URL))

# ----------------------------------------------------------------------------
# Extract
# ----------------------------------------------------------------------------

sysvinit_extract: $(STATEDIR)/sysvinit.extract

sysvinit_extract_deps = $(STATEDIR)/sysvinit.get

$(STATEDIR)/sysvinit.extract: $(sysvinit_extract_deps)
	@$(call targetinfo, $@)
	@$(call clean, $(SYSVINIT_DIR))
	@$(call extract, $(SYSVINIT_SOURCE))
	@$(call patchin, $(SYSVINIT))
	touch $@

# ----------------------------------------------------------------------------
# Prepare
# ----------------------------------------------------------------------------

sysvinit_prepare: $(STATEDIR)/sysvinit.prepare

#
# dependencies
#
sysvinit_prepare_deps = \
	$(STATEDIR)/sysvinit.extract \
	$(STATEDIR)/virtual-xchain.install

SYSVINIT_PATH	=  PATH=$(CROSS_PATH)
SYSVINIT_ENV 	=  $(CROSS_ENV)
#SYSVINIT_ENV	+=

$(STATEDIR)/sysvinit.prepare: $(sysvinit_prepare_deps)
	@$(call targetinfo, $@)
	@$(call clean, $(SYSVINIT_DIR)/config.cache)
	cd $(SYSVINIT_DIR) && $(SYSVINIT_PATH) \
		perl -i -p -e 's/CC.*=.*//g' $(SYSVINIT_DIR)/Makefile
	touch $@

# ----------------------------------------------------------------------------
# Compile
# ----------------------------------------------------------------------------

sysvinit_compile: $(STATEDIR)/sysvinit.compile

sysvinit_compile_deps = $(STATEDIR)/sysvinit.prepare

$(STATEDIR)/sysvinit.compile: $(sysvinit_compile_deps)
	@$(call targetinfo, $@)
	$(SYSVINIT_PATH) $(SYSVINIT_ENV) $(MAKE) -C $(SYSVINIT_DIR)
	touch $@

# ----------------------------------------------------------------------------
# Install
# ----------------------------------------------------------------------------

sysvinit_install: $(STATEDIR)/sysvinit.install

$(STATEDIR)/sysvinit.install: $(STATEDIR)/sysvinit.compile
	@$(call targetinfo, $@)
	touch $@

# ----------------------------------------------------------------------------
# Target-Install
# ----------------------------------------------------------------------------

sysvinit_targetinstall: $(STATEDIR)/sysvinit.targetinstall

sysvinit_targetinstall_deps = $(STATEDIR)/sysvinit.compile

$(STATEDIR)/sysvinit.targetinstall: $(sysvinit_targetinstall_deps)
	@$(call targetinfo, $@)
	install -d $(SYSVINIT_DIR)/ipkg_tmp/bin $(SYSVINIT_DIR)/ipkg_tmp/sbin
	install -d $(SYSVINIT_DIR)/ipkg_tmp/usr/bin $(SYSVINIT_DIR)/ipkg_tmp/usr/sbin
	$(SYSVINIT_PATH) ROOT=$(SYSVINIT_DIR)/ipkg_tmp $(MAKE) -C $(SYSVINIT_DIR) install
	mkdir -p $(SYSVINIT_DIR)/ipkg_tmp/CONTROL
	echo "Package: sysvinit" 						 >$(SYSVINIT_DIR)/ipkg_tmp/CONTROL/control
	echo "Priority: optional" 						>>$(SYSVINIT_DIR)/ipkg_tmp/CONTROL/control
	echo "Section: Console" 						>>$(SYSVINIT_DIR)/ipkg_tmp/CONTROL/control
	echo "Maintainer: Alexander Chukov <sash@pdaXrom.org>" 			>>$(SYSVINIT_DIR)/ipkg_tmp/CONTROL/control
	echo "Architecture: $(SHORT_TARGET)" 					>>$(SYSVINIT_DIR)/ipkg_tmp/CONTROL/control
	echo "Version: $(SYSVINIT_VERSION)" 					>>$(SYSVINIT_DIR)/ipkg_tmp/CONTROL/control
	echo "Depends: " 							>>$(SYSVINIT_DIR)/ipkg_tmp/CONTROL/control
	echo "Description: System-V like init"					>>$(SYSVINIT_DIR)/ipkg_tmp/CONTROL/control
	cd $(FEEDDIR) && $(XMKIPKG) $(SYSVINIT_DIR)/ipkg_tmp
	touch $@

# ----------------------------------------------------------------------------
# Image-Install
# ----------------------------------------------------------------------------

ifdef PTXCONF_SYSVINIT_INSTALL
ROMPACKAGES += $(STATEDIR)/sysvinit.imageinstall
endif

sysvinit_imageinstall_deps = $(STATEDIR)/sysvinit.targetinstall \
	$(STATEDIR)/virtual-image.install

$(STATEDIR)/sysvinit.imageinstall: $(sysvinit_imageinstall_deps)
	@$(call targetinfo, $@)
	cd $(FEEDDIR) && $(XIPKG) install sysvinit
	touch $@

# ----------------------------------------------------------------------------
# Clean
# ----------------------------------------------------------------------------

sysvinit_clean:
	rm -rf $(STATEDIR)/sysvinit.*
	rm -rf $(SYSVINIT_DIR)

# vim: syntax=make
