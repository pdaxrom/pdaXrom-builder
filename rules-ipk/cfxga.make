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
ifdef PTXCONF_CFXGA
PACKAGES += cfxga
endif

#
# Paths and names
#
CFXGA_VENDOR_VERSION	= 2
CFXGA_VERSION		= 0.0.1
CFXGA			= cfxga-$(CFXGA_VERSION)
CFXGA_SUFFIX		= tar.bz2
CFXGA_URL		= http://www.pdaXrom.org/src/$(CFXGA).$(CFXGA_SUFFIX)
CFXGA_SOURCE		= $(SRCDIR)/$(CFXGA).$(CFXGA_SUFFIX)
CFXGA_DIR		= $(BUILDDIR)/$(CFXGA)
CFXGA_IPKG_TMP		= $(CFXGA_DIR)/ipkg_tmp

# ----------------------------------------------------------------------------
# Get
# ----------------------------------------------------------------------------

cfxga_get: $(STATEDIR)/cfxga.get

cfxga_get_deps = $(CFXGA_SOURCE)

$(STATEDIR)/cfxga.get: $(cfxga_get_deps)
	@$(call targetinfo, $@)
	@$(call get_patches, $(CFXGA))
	touch $@

$(CFXGA_SOURCE):
	@$(call targetinfo, $@)
	@$(call get, $(CFXGA_URL))

# ----------------------------------------------------------------------------
# Extract
# ----------------------------------------------------------------------------

cfxga_extract: $(STATEDIR)/cfxga.extract

cfxga_extract_deps = $(STATEDIR)/cfxga.get

$(STATEDIR)/cfxga.extract: $(cfxga_extract_deps)
	@$(call targetinfo, $@)
	@$(call clean, $(CFXGA_DIR))
	@$(call extract, $(CFXGA_SOURCE))
	@$(call patchin, $(CFXGA))
	touch $@

# ----------------------------------------------------------------------------
# Prepare
# ----------------------------------------------------------------------------

cfxga_prepare: $(STATEDIR)/cfxga.prepare

#
# dependencies
#
cfxga_prepare_deps = \
	$(STATEDIR)/cfxga.extract \
	$(STATEDIR)/pcmcia-cs.install \
	$(STATEDIR)/virtual-xchain.install

CFXGA_PATH	=  PATH=$(CROSS_PATH)
CFXGA_ENV 	=  $(CROSS_ENV)
#CFXGA_ENV	+=
CFXGA_ENV	+= PKG_CONFIG_PATH=$(CROSS_LIB_DIR)/lib/pkgconfig
#ifdef PTXCONF_XFREE430
#CFXGA_ENV	+= LDFLAGS=-Wl,-rpath-link,$(CROSS_LIB_DIR)/X11R6/lib
#endif

#
# autoconf
#
CFXGA_AUTOCONF = \
	--build=$(GNU_HOST) \
	--host=$(PTXCONF_GNU_TARGET) \
	--prefix=/usr

ifdef PTXCONF_XFREE430
CFXGA_AUTOCONF += --x-includes=$(CROSS_LIB_DIR)/include
CFXGA_AUTOCONF += --x-libraries=$(CROSS_LIB_DIR)/lib
endif

$(STATEDIR)/cfxga.prepare: $(cfxga_prepare_deps)
	@$(call targetinfo, $@)
	@$(call clean, $(CFXGA_DIR)/config.cache)
	#cd $(CFXGA_DIR) && \
	#	$(CFXGA_PATH) $(CFXGA_ENV) \
	#	./Configure --kernel=$(KERNEL_DIR)
	touch $@

# ----------------------------------------------------------------------------
# Compile
# ----------------------------------------------------------------------------

cfxga_compile: $(STATEDIR)/cfxga.compile

cfxga_compile_deps = $(STATEDIR)/cfxga.prepare

$(STATEDIR)/cfxga.compile: $(cfxga_compile_deps)
	@$(call targetinfo, $@)
	$(CFXGA_PATH) $(MAKE) -C $(CFXGA_DIR)
	$(CFXGA_PATH) $(MAKE) -C $(CFXGA_DIR) $(CROSS_ENV_CC) $(CROSS_ENV_CXX) mirror
	touch $@

# ----------------------------------------------------------------------------
# Install
# ----------------------------------------------------------------------------

cfxga_install: $(STATEDIR)/cfxga.install

$(STATEDIR)/cfxga.install: $(STATEDIR)/cfxga.compile
	@$(call targetinfo, $@)
	touch $@

# ----------------------------------------------------------------------------
# Target-Install
# ----------------------------------------------------------------------------

cfxga_targetinstall: $(STATEDIR)/cfxga.targetinstall

cfxga_targetinstall_deps = $(STATEDIR)/cfxga.compile

$(STATEDIR)/cfxga.targetinstall: $(cfxga_targetinstall_deps)
	@$(call targetinfo, $@)
	mkdir -p $(CFXGA_IPKG_TMP)/CONTROL
	cp -a $(CFXGA_DIR)/root/* $(CFXGA_IPKG_TMP)/
	echo "Package: cfxga" 											 >$(CFXGA_IPKG_TMP)/CONTROL/control
	echo "Priority: optional" 										>>$(CFXGA_IPKG_TMP)/CONTROL/control
	echo "Section: Utilities" 										>>$(CFXGA_IPKG_TMP)/CONTROL/control
	echo "Maintainer: Alexander Chukov <sash@pdaXrom.org>" 							>>$(CFXGA_IPKG_TMP)/CONTROL/control
	echo "Architecture: $(SHORT_TARGET)" 									>>$(CFXGA_IPKG_TMP)/CONTROL/control
	echo "Version: $(CFXGA_VERSION)-$(CFXGA_VENDOR_VERSION)" 						>>$(CFXGA_IPKG_TMP)/CONTROL/control
	echo "Depends: " 											>>$(CFXGA_IPKG_TMP)/CONTROL/control
	echo "Description: CFXGA Linux driver"									>>$(CFXGA_IPKG_TMP)/CONTROL/control

	echo "#!/bin/sh"											 >$(CFXGA_IPKG_TMP)/CONTROL/postinst
	echo "/sbin/depmod -a"											>>$(CFXGA_IPKG_TMP)/CONTROL/postinst
	echo "#!/bin/sh"											 >$(CFXGA_IPKG_TMP)/CONTROL/postrm
	echo "/sbin/depmod -a"											>>$(CFXGA_IPKG_TMP)/CONTROL/postrm
	chmod 755 $(CFXGA_IPKG_TMP)/CONTROL/postinst $(CFXGA_IPKG_TMP)/CONTROL/postrm

	cd $(FEEDDIR) && $(XMKIPKG) $(CFXGA_IPKG_TMP)
	touch $@

# ----------------------------------------------------------------------------
# Image-Install
# ----------------------------------------------------------------------------

ifdef PTXCONF_CFXGA_INSTALL
ROMPACKAGES += $(STATEDIR)/cfxga.imageinstall
endif

cfxga_imageinstall_deps = $(STATEDIR)/cfxga.targetinstall \
	$(STATEDIR)/virtual-image.install

$(STATEDIR)/cfxga.imageinstall: $(cfxga_imageinstall_deps)
	@$(call targetinfo, $@)
	cd $(FEEDDIR) && $(XIPKG) install cfxga
	touch $@

# ----------------------------------------------------------------------------
# Clean
# ----------------------------------------------------------------------------

cfxga_clean:
	rm -rf $(STATEDIR)/cfxga.*
	rm -rf $(CFXGA_DIR)

# vim: syntax=make
