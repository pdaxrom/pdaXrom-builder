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
ifdef PTXCONF_TRANSLUCENCY
PACKAGES += translucency
endif

#
# Paths and names
#
TRANSLUCENCY_VERSION		= 0.6.1
TRANSLUCENCY			= translucency-$(TRANSLUCENCY_VERSION)
TRANSLUCENCY_SUFFIX		= tar.gz
TRANSLUCENCY_URL		= http://voxel.dl.sourceforge.net/sourceforge/translucency/$(TRANSLUCENCY).$(TRANSLUCENCY_SUFFIX)
TRANSLUCENCY_SOURCE		= $(SRCDIR)/$(TRANSLUCENCY).$(TRANSLUCENCY_SUFFIX)
TRANSLUCENCY_DIR		= $(BUILDDIR)/$(TRANSLUCENCY)
TRANSLUCENCY_IPKG_TMP		= $(TRANSLUCENCY_DIR)/ipkg_tmp

# ----------------------------------------------------------------------------
# Get
# ----------------------------------------------------------------------------

translucency_get: $(STATEDIR)/translucency.get

translucency_get_deps = $(TRANSLUCENCY_SOURCE)

$(STATEDIR)/translucency.get: $(translucency_get_deps)
	@$(call targetinfo, $@)
	@$(call get_patches, $(TRANSLUCENCY))
	touch $@

$(TRANSLUCENCY_SOURCE):
	@$(call targetinfo, $@)
	@$(call get, $(TRANSLUCENCY_URL))

# ----------------------------------------------------------------------------
# Extract
# ----------------------------------------------------------------------------

translucency_extract: $(STATEDIR)/translucency.extract

translucency_extract_deps = $(STATEDIR)/translucency.get

$(STATEDIR)/translucency.extract: $(translucency_extract_deps)
	@$(call targetinfo, $@)
	@$(call clean, $(TRANSLUCENCY_DIR))
	@$(call extract, $(TRANSLUCENCY_SOURCE))
	@$(call patchin, $(TRANSLUCENCY))
	touch $@

# ----------------------------------------------------------------------------
# Prepare
# ----------------------------------------------------------------------------

translucency_prepare: $(STATEDIR)/translucency.prepare

#
# dependencies
#
translucency_prepare_deps = \
	$(STATEDIR)/translucency.extract \
	$(STATEDIR)/virtual-xchain.install

TRANSLUCENCY_PATH	=  PATH=$(CROSS_PATH)
TRANSLUCENCY_ENV 	=  $(CROSS_ENV)
#TRANSLUCENCY_ENV	+=
TRANSLUCENCY_ENV	+= PKG_CONFIG_PATH=$(CROSS_LIB_DIR)/lib/pkgconfig:$(CROSS_LIB_DIR)/lib/pkgconfig
#ifdef PTXCONF_XFREE430
#TRANSLUCENCY_ENV	+= LDFLAGS=-Wl,-rpath-link,$(CROSS_LIB_DIR)/lib
#endif

#
# autoconf
#
TRANSLUCENCY_AUTOCONF = \
	--build=$(GNU_HOST) \
	--host=$(PTXCONF_GNU_TARGET) \
	--prefix=/usr

ifdef PTXCONF_XFREE430
TRANSLUCENCY_AUTOCONF += --x-includes=$(CROSS_LIB_DIR)/include
TRANSLUCENCY_AUTOCONF += --x-libraries=$(CROSS_LIB_DIR)/lib
endif

$(STATEDIR)/translucency.prepare: $(translucency_prepare_deps)
	@$(call targetinfo, $@)
	@$(call clean, $(TRANSLUCENCY_DIR)/config.cache)
	cd $(TRANSLUCENCY_DIR) && \
		$(TRANSLUCENCY_PATH) $(TRANSLUCENCY_ENV) \
		sh Configure --kernel=$(KERNEL_DIR)
	touch $@

# ----------------------------------------------------------------------------
# Compile
# ----------------------------------------------------------------------------

translucency_compile: $(STATEDIR)/translucency.compile

translucency_compile_deps = $(STATEDIR)/translucency.prepare

$(STATEDIR)/translucency.compile: $(translucency_compile_deps)
	@$(call targetinfo, $@)
ifdef PTXCONF_KERNEL_EXTERNAL_GCC
	cd $(TRANSLUCENCY_DIR) && \
	$(TRANSLUCENCY_PATH) $(TRANSLUCENCY_ENV) \
	    $(MAKE) CC=$(PTXCONF_KERNEL_EXTERNAL_GCC_PATH)-gcc LD=$(PTXCONF_KERNEL_EXTERNAL_GCC_PATH)-ld
else
	cd $(TRANSLUCENCY_DIR) && \
	$(TRANSLUCENCY_PATH) $(TRANSLUCENCY_ENV) \
	    $(MAKE) $(CROSS_ENV_CC) $(CROSS_ENV_LD)
endif
	touch $@

# ----------------------------------------------------------------------------
# Install
# ----------------------------------------------------------------------------

translucency_install: $(STATEDIR)/translucency.install

$(STATEDIR)/translucency.install: $(STATEDIR)/translucency.compile
	@$(call targetinfo, $@)
	touch $@

# ----------------------------------------------------------------------------
# Target-Install
# ----------------------------------------------------------------------------

translucency_targetinstall: $(STATEDIR)/translucency.targetinstall

translucency_targetinstall_deps = $(STATEDIR)/translucency.compile

$(STATEDIR)/translucency.targetinstall: $(translucency_targetinstall_deps)
	@$(call targetinfo, $@)
	$(TRANSLUCENCY_PATH) $(MAKE) -C $(TRANSLUCENCY_DIR) DESTDIR=$(TRANSLUCENCY_IPKG_TMP) install
	rm -rf $(TRANSLUCENCY_IPKG_TMP)/usr/share/man
	mkdir -p $(TRANSLUCENCY_IPKG_TMP)/CONTROL
	echo "Package: translucency" 					>$(TRANSLUCENCY_IPKG_TMP)/CONTROL/control
	echo "Priority: optional" 					>>$(TRANSLUCENCY_IPKG_TMP)/CONTROL/control
	echo "Section: Utils"			 			>>$(TRANSLUCENCY_IPKG_TMP)/CONTROL/control
	echo "Maintainer: Alexander Chukov <sash@pdaXrom.org>" 		>>$(TRANSLUCENCY_IPKG_TMP)/CONTROL/control
	echo "Architecture: $(SHORT_TARGET)" 				>>$(TRANSLUCENCY_IPKG_TMP)/CONTROL/control
	echo "Version: $(TRANSLUCENCY_VERSION)" 			>>$(TRANSLUCENCY_IPKG_TMP)/CONTROL/control
	echo "Depends: " 						>>$(TRANSLUCENCY_IPKG_TMP)/CONTROL/control
	echo "Description: translucency kernel module"			>>$(TRANSLUCENCY_IPKG_TMP)/CONTROL/control
	cd $(FEEDDIR) && $(XMKIPKG) $(TRANSLUCENCY_IPKG_TMP)
	touch $@

# ----------------------------------------------------------------------------
# Image-Install
# ----------------------------------------------------------------------------

ifdef PTXCONF_TRANSLUCENCY_INSTALL
ROMPACKAGES += $(STATEDIR)/translucency.imageinstall
endif

translucency_imageinstall_deps = $(STATEDIR)/translucency.targetinstall \
	$(STATEDIR)/virtual-image.install

$(STATEDIR)/translucency.imageinstall: $(translucency_imageinstall_deps)
	@$(call targetinfo, $@)
	cd $(FEEDDIR) && $(XIPKG) install translucency
	touch $@

# ----------------------------------------------------------------------------
# Clean
# ----------------------------------------------------------------------------

translucency_clean:
	rm -rf $(STATEDIR)/translucency.*
	rm -rf $(TRANSLUCENCY_DIR)

# vim: syntax=make
