# -*-makefile-*-
# $Id: template,v 1.10 2004/01/24 15:50:34 mkl Exp $
#
# Copyright (C) 2004 by Alexander Chukov <sash@cacko.biz>
#          
# See CREDITS for details about who has contributed to this project.
#
# For further information about the PTXdist project and license conditions
# see the README file.
#

#
# We provide this package
#
ifdef PTXCONF_IRDA-UTILS
PACKAGES += irda-utils
endif

#
# Paths and names
#
IRDA-UTILS_VERSION	= 0.9.15
IRDA-UTILS		= irda-utils-$(IRDA-UTILS_VERSION)
IRDA-UTILS_SUFFIX	= tar.gz
IRDA-UTILS_URL		= http://keihanna.dl.sourceforge.net/sourceforge/irda/$(IRDA-UTILS).$(IRDA-UTILS_SUFFIX)
IRDA-UTILS_SOURCE	= $(SRCDIR)/$(IRDA-UTILS).$(IRDA-UTILS_SUFFIX)
IRDA-UTILS_DIR		= $(BUILDDIR)/$(IRDA-UTILS)

# ----------------------------------------------------------------------------
# Get
# ----------------------------------------------------------------------------

irda-utils_get: $(STATEDIR)/irda-utils.get

irda-utils_get_deps = $(IRDA-UTILS_SOURCE)

$(STATEDIR)/irda-utils.get: $(irda-utils_get_deps)
	@$(call targetinfo, $@)
	@$(call get_patches, $(IRDA-UTILS))
	touch $@

$(IRDA-UTILS_SOURCE):
	@$(call targetinfo, $@)
	@$(call get, $(IRDA-UTILS_URL))

# ----------------------------------------------------------------------------
# Extract
# ----------------------------------------------------------------------------

irda-utils_extract: $(STATEDIR)/irda-utils.extract

irda-utils_extract_deps = $(STATEDIR)/irda-utils.get

$(STATEDIR)/irda-utils.extract: $(irda-utils_extract_deps)
	@$(call targetinfo, $@)
	@$(call clean, $(IRDA-UTILS_DIR))
	@$(call extract, $(IRDA-UTILS_SOURCE))
	@$(call patchin, $(IRDA-UTILS))
	touch $@

# ----------------------------------------------------------------------------
# Prepare
# ----------------------------------------------------------------------------

irda-utils_prepare: $(STATEDIR)/irda-utils.prepare

#
# dependencies
#
irda-utils_prepare_deps = \
	$(STATEDIR)/irda-utils.extract \
	$(STATEDIR)/virtual-xchain.install

IRDA-UTILS_PATH	=  PATH=$(CROSS_PATH)
IRDA-UTILS_ENV 	=  $(CROSS_ENV)
#IRDA-UTILS_ENV	+=

#
# autoconf
#
IRDA-UTILS_AUTOCONF = \
	--build=$(GNU_HOST) \
	--host=$(PTXCONF_GNU_TARGET) \
	--prefix=$(CROSS_LIB_DIR)

$(STATEDIR)/irda-utils.prepare: $(irda-utils_prepare_deps)
	@$(call targetinfo, $@)
	@$(call clean, $(IRDA-UTILS_DIR)/config.cache)
	#cd $(IRDA-UTILS_DIR) && \
	#	$(IRDA-UTILS_PATH) $(IRDA-UTILS_ENV) \
	#	./configure $(IRDA-UTILS_AUTOCONF)
	touch $@

# ----------------------------------------------------------------------------
# Compile
# ----------------------------------------------------------------------------

irda-utils_compile: $(STATEDIR)/irda-utils.compile

irda-utils_compile_deps = $(STATEDIR)/irda-utils.prepare

$(STATEDIR)/irda-utils.compile: $(irda-utils_compile_deps)
	@$(call targetinfo, $@)
	$(IRDA-UTILS_PATH) $(MAKE) -C $(IRDA-UTILS_DIR)/irattach CC=$(PTXCONF_GNU_TARGET)-gcc
	touch $@

# ----------------------------------------------------------------------------
# Install
# ----------------------------------------------------------------------------

irda-utils_install: $(STATEDIR)/irda-utils.install

$(STATEDIR)/irda-utils.install: $(STATEDIR)/irda-utils.compile
	@$(call targetinfo, $@)
	#$(IRDA-UTILS_PATH) $(MAKE) -C $(IRDA-UTILS_DIR) install
	touch $@

# ----------------------------------------------------------------------------
# Target-Install
# ----------------------------------------------------------------------------

irda-utils_targetinstall: $(STATEDIR)/irda-utils.targetinstall

irda-utils_targetinstall_deps = $(STATEDIR)/irda-utils.compile

$(STATEDIR)/irda-utils.targetinstall: $(irda-utils_targetinstall_deps)
	@$(call targetinfo, $@)
	$(INSTALL) -D -m 755 $(IRDA-UTILS_DIR)/irattach/irattach $(IRDA-UTILS_DIR)/ipkg/usr/sbin/irattach
	$(CROSSSTRIP) $(IRDA-UTILS_DIR)/ipkg/usr/sbin/irattach
	mkdir -p $(IRDA-UTILS_DIR)/ipkg/CONTROL
	echo "Package: irda-utils" 						 >$(IRDA-UTILS_DIR)/ipkg/CONTROL/control
	echo "Priority: optional" 						>>$(IRDA-UTILS_DIR)/ipkg/CONTROL/control
	echo "Section: Utilities" 						>>$(IRDA-UTILS_DIR)/ipkg/CONTROL/control
	echo "Maintainer: Alexander Chukov <sash@pdaXrom.org>" 			>>$(IRDA-UTILS_DIR)/ipkg/CONTROL/control
	echo "Architecture: $(SHORT_TARGET)" 					>>$(IRDA-UTILS_DIR)/ipkg/CONTROL/control
	echo "Version: $(IRDA-UTILS_VERSION)" 					>>$(IRDA-UTILS_DIR)/ipkg/CONTROL/control
	echo "Depends: " 							>>$(IRDA-UTILS_DIR)/ipkg/CONTROL/control
	echo "Description: Provides common files needed to use IrDA."		>>$(IRDA-UTILS_DIR)/ipkg/CONTROL/control
	cd $(FEEDDIR) && $(XMKIPKG) $(IRDA-UTILS_DIR)/ipkg
	touch $@

# ----------------------------------------------------------------------------
# Image-Install
# ----------------------------------------------------------------------------

ifdef PTXCONF_IRDA-UTILS_INSTALL
ROMPACKAGES += $(STATEDIR)/irda-utils.imageinstall
endif

irda-utils_imageinstall_deps = $(STATEDIR)/irda-utils.targetinstall \
	$(STATEDIR)/virtual-image.install

$(STATEDIR)/irda-utils.imageinstall: $(irda-utils_imageinstall_deps)
	@$(call targetinfo, $@)
	cd $(FEEDDIR) && $(XIPKG) install irda-utils
	touch $@

# ----------------------------------------------------------------------------
# Clean
# ----------------------------------------------------------------------------

irda-utils_clean:
	rm -rf $(STATEDIR)/irda-utils.*
	rm -rf $(IRDA-UTILS_DIR)

# vim: syntax=make
