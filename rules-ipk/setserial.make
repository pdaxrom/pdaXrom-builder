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
ifdef PTXCONF_SETSERIAL
PACKAGES += setserial
endif

#
# Paths and names
#
SETSERIAL_VERSION	= 2.17
SETSERIAL		= setserial-$(SETSERIAL_VERSION)
SETSERIAL_SUFFIX	= tar.gz
SETSERIAL_URL		= http://heanet.dl.sourceforge.net/sourceforge/setserial/$(SETSERIAL).$(SETSERIAL_SUFFIX)
SETSERIAL_SOURCE	= $(SRCDIR)/$(SETSERIAL).$(SETSERIAL_SUFFIX)
SETSERIAL_DIR		= $(BUILDDIR)/$(SETSERIAL)

# ----------------------------------------------------------------------------
# Get
# ----------------------------------------------------------------------------

setserial_get: $(STATEDIR)/setserial.get

setserial_get_deps = $(SETSERIAL_SOURCE)

$(STATEDIR)/setserial.get: $(setserial_get_deps)
	@$(call targetinfo, $@)
	@$(call get_patches, $(SETSERIAL))
	touch $@

$(SETSERIAL_SOURCE):
	@$(call targetinfo, $@)
	@$(call get, $(SETSERIAL_URL))

# ----------------------------------------------------------------------------
# Extract
# ----------------------------------------------------------------------------

setserial_extract: $(STATEDIR)/setserial.extract

setserial_extract_deps = $(STATEDIR)/setserial.get

$(STATEDIR)/setserial.extract: $(setserial_extract_deps)
	@$(call targetinfo, $@)
	@$(call clean, $(SETSERIAL_DIR))
	@$(call extract, $(SETSERIAL_SOURCE))
	@$(call patchin, $(SETSERIAL))
	touch $@

# ----------------------------------------------------------------------------
# Prepare
# ----------------------------------------------------------------------------

setserial_prepare: $(STATEDIR)/setserial.prepare

#
# dependencies
#
setserial_prepare_deps = \
	$(STATEDIR)/setserial.extract \
	$(STATEDIR)/virtual-xchain.install

SETSERIAL_PATH	=  PATH=$(CROSS_PATH)
SETSERIAL_ENV 	=  $(CROSS_ENV)
#SETSERIAL_ENV	+=

#
# autoconf
#
SETSERIAL_AUTOCONF = \
	--build=$(GNU_HOST) \
	--host=$(PTXCONF_GNU_TARGET) \
	--prefix=$(CROSS_LIB_DIR) \
	--sysconfdir=/etc

$(STATEDIR)/setserial.prepare: $(setserial_prepare_deps)
	@$(call targetinfo, $@)
	@$(call clean, $(SETSERIAL_DIR)/config.cache)
	cd $(SETSERIAL_DIR) && \
		$(SETSERIAL_PATH) $(SETSERIAL_ENV) \
		./configure $(SETSERIAL_AUTOCONF)
	touch $@

# ----------------------------------------------------------------------------
# Compile
# ----------------------------------------------------------------------------

setserial_compile: $(STATEDIR)/setserial.compile

setserial_compile_deps = $(STATEDIR)/setserial.prepare

$(STATEDIR)/setserial.compile: $(setserial_compile_deps)
	@$(call targetinfo, $@)
	$(SETSERIAL_PATH) $(MAKE) -C $(SETSERIAL_DIR)
	touch $@

# ----------------------------------------------------------------------------
# Install
# ----------------------------------------------------------------------------

setserial_install: $(STATEDIR)/setserial.install

$(STATEDIR)/setserial.install: $(STATEDIR)/setserial.compile
	@$(call targetinfo, $@)
	#$(SETSERIAL_PATH) $(MAKE) -C $(SETSERIAL_DIR) install
	touch $@

# ----------------------------------------------------------------------------
# Target-Install
# ----------------------------------------------------------------------------

setserial_targetinstall: $(STATEDIR)/setserial.targetinstall

setserial_targetinstall_deps = $(STATEDIR)/setserial.compile

$(STATEDIR)/setserial.targetinstall: $(setserial_targetinstall_deps)
	@$(call targetinfo, $@)
	$(INSTALL) -D -m 755 $(SETSERIAL_DIR)/setserial $(SETSERIAL_DIR)/ipkg/sbin/setserial
	$(CROSSSTRIP) $(SETSERIAL_DIR)/ipkg/sbin/setserial
	mkdir -p $(SETSERIAL_DIR)/ipkg/CONTROL
	echo "Package: setserial" 						 >$(SETSERIAL_DIR)/ipkg/CONTROL/control
	echo "Priority: optional" 						>>$(SETSERIAL_DIR)/ipkg/CONTROL/control
	echo "Section: Utilities" 						>>$(SETSERIAL_DIR)/ipkg/CONTROL/control
	echo "Maintainer: Alexander Chukov <sash@pdaXrom.org>" 			>>$(SETSERIAL_DIR)/ipkg/CONTROL/control
	echo "Architecture: $(SHORT_TARGET)" 					>>$(SETSERIAL_DIR)/ipkg/CONTROL/control
	echo "Version: $(SETSERIAL_VERSION)" 					>>$(SETSERIAL_DIR)/ipkg/CONTROL/control
	echo "Depends: " 							>>$(SETSERIAL_DIR)/ipkg/CONTROL/control
	echo "Description: compression and file packaging utility."		>>$(SETSERIAL_DIR)/ipkg/CONTROL/control
	cd $(FEEDDIR) && $(XMKIPKG) $(SETSERIAL_DIR)/ipkg
	touch $@

# ----------------------------------------------------------------------------
# Image-Install
# ----------------------------------------------------------------------------

ifdef PTXCONF_SETSERIAL_INSTALL
ROMPACKAGES += $(STATEDIR)/setserial.imageinstall
endif

setserial_imageinstall_deps = $(STATEDIR)/setserial.targetinstall \
	$(STATEDIR)/virtual-image.install

$(STATEDIR)/setserial.imageinstall: $(setserial_imageinstall_deps)
	@$(call targetinfo, $@)
	cd $(FEEDDIR) && $(XIPKG) install setserial
	touch $@

# ----------------------------------------------------------------------------
# Clean
# ----------------------------------------------------------------------------

setserial_clean:
	rm -rf $(STATEDIR)/setserial.*
	rm -rf $(SETSERIAL_DIR)

# vim: syntax=make
