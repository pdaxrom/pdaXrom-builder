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
ifdef PTXCONF_WGETA
PACKAGES += wget
endif

#
# Paths and names
#
WGETA_VERSION		= 1.9
WGETA			= wget-$(WGETA_VERSION)
WGETA_SUFFIX		= tar.gz
WGETA_URL		= http://ftp.lug.udel.edu/pub/gnu/wget/$(WGETA).$(WGETA_SUFFIX)
WGETA_SOURCE		= $(SRCDIR)/$(WGETA).$(WGETA_SUFFIX)
WGETA_DIR		= $(BUILDDIR)/$(WGETA)

# ----------------------------------------------------------------------------
# Get
# ----------------------------------------------------------------------------

wget_get: $(STATEDIR)/wget.get

wget_get_deps = $(WGETA_SOURCE)

$(STATEDIR)/wget.get: $(wget_get_deps)
	@$(call targetinfo, $@)
	@$(call get_patches, $(WGETA))
	touch $@

$(WGETA_SOURCE):
	@$(call targetinfo, $@)
	@$(call get, $(WGETA_URL))

# ----------------------------------------------------------------------------
# Extract
# ----------------------------------------------------------------------------

wget_extract: $(STATEDIR)/wget.extract

wget_extract_deps = $(STATEDIR)/wget.get

$(STATEDIR)/wget.extract: $(wget_extract_deps)
	@$(call targetinfo, $@)
	@$(call clean, $(WGETA_DIR))
	@$(call extract, $(WGETA_SOURCE))
	@$(call patchin, $(WGETA))
	touch $@

# ----------------------------------------------------------------------------
# Prepare
# ----------------------------------------------------------------------------

wget_prepare: $(STATEDIR)/wget.prepare

#
# dependencies
#
wget_prepare_deps = \
	$(STATEDIR)/wget.extract \
	$(STATEDIR)/virtual-xchain.install

WGETA_PATH	=  PATH=$(CROSS_PATH)
WGETA_ENV 	=  $(CROSS_ENV)
#WGETA_ENV	+=

#
# autoconf
#
WGETA_AUTOCONF = \
	--build=$(GNU_HOST) \
	--host=$(PTXCONF_GNU_TARGET) \
	--prefix=$(CROSS_LIB_DIR)

$(STATEDIR)/wget.prepare: $(wget_prepare_deps)
	@$(call targetinfo, $@)
	@$(call clean, $(WGETA_DIR)/config.cache)
	cd $(WGETA_DIR) && \
		$(WGETA_PATH) $(WGETA_ENV) \
		./configure --without-ssl $(WGETA_AUTOCONF)
	touch $@

# ----------------------------------------------------------------------------
# Compile
# ----------------------------------------------------------------------------

wget_compile: $(STATEDIR)/wget.compile

wget_compile_deps = $(STATEDIR)/wget.prepare

$(STATEDIR)/wget.compile: $(wget_compile_deps)
	@$(call targetinfo, $@)
	$(WGETA_PATH) $(WGETA_ENV) \
		$(WGETA_PATH) $(MAKE) -C $(WGETA_DIR)
	touch $@

# ----------------------------------------------------------------------------
# Install
# ----------------------------------------------------------------------------

wget_install: $(STATEDIR)/wget.install

$(STATEDIR)/wget.install: $(STATEDIR)/wget.compile
	@$(call targetinfo, $@)
	#$(WGETA_PATH) $(MAKE) -C $(WGETA_DIR) install
	touch $@

# ----------------------------------------------------------------------------
# Target-Install
# ----------------------------------------------------------------------------

wget_targetinstall: $(STATEDIR)/wget.targetinstall

wget_targetinstall_deps = $(STATEDIR)/wget.compile

$(STATEDIR)/wget.targetinstall: $(wget_targetinstall_deps)
	@$(call targetinfo, $@)
	$(INSTALL) -D -m 755 $(WGETA_DIR)/src/wget	$(WGETA_DIR)/ipkg_tmp/usr/bin/wget
	$(CROSSSTRIP) -R .note -R .comment		$(WGETA_DIR)/ipkg_tmp/usr/bin/wget
	mkdir -p $(WGETA_DIR)/ipkg_tmp/CONTROL
	echo "Package: wget" 							 >$(WGETA_DIR)/ipkg_tmp/CONTROL/control
	echo "Priority: optional" 						>>$(WGETA_DIR)/ipkg_tmp/CONTROL/control
	echo "Section: Internet" 						>>$(WGETA_DIR)/ipkg_tmp/CONTROL/control
	echo "Maintainer: Alexander Chukov <sash@pdaXrom.org>" 			>>$(WGETA_DIR)/ipkg_tmp/CONTROL/control
	echo "Architecture: $(SHORT_TARGET)" 					>>$(WGETA_DIR)/ipkg_tmp/CONTROL/control
	echo "Version: $(WGETA_VERSION)" 					>>$(WGETA_DIR)/ipkg_tmp/CONTROL/control
	echo "Depends: " 							>>$(WGETA_DIR)/ipkg_tmp/CONTROL/control
	echo "Description: free utility for non-interactive download of files from the Web." >>$(WGETA_DIR)/ipkg_tmp/CONTROL/control
	cd $(FEEDDIR) && $(XMKIPKG) $(WGETA_DIR)/ipkg_tmp
	touch $@

# ----------------------------------------------------------------------------
# Image-Install
# ----------------------------------------------------------------------------

ifdef PTXCONF_WGETA_INSTALL
ROMPACKAGES += $(STATEDIR)/wget.imageinstall
endif

wget_imageinstall_deps = $(STATEDIR)/wget.targetinstall \
	$(STATEDIR)/virtual-image.install

$(STATEDIR)/wget.imageinstall: $(wget_imageinstall_deps)
	@$(call targetinfo, $@)
	cd $(FEEDDIR) && $(XIPKG) install wget
	touch $@

# ----------------------------------------------------------------------------
# Clean
# ----------------------------------------------------------------------------

wget_clean:
	rm -rf $(STATEDIR)/wget.*
	rm -rf $(WGETA_DIR)

# vim: syntax=make
