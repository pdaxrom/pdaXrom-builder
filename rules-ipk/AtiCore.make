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
ifdef PTXCONF_ATICORE
PACKAGES += AtiCore
endif

#
# Paths and names
#
ATICORE_VERSION		= 1.0.1
ATICORE			= AtiCore-$(ATICORE_VERSION)
ATICORE_SUFFIX		= tar.bz2
ATICORE_URL		= http://www.pdaXrom.org/src/$(ATICORE).$(ATICORE_SUFFIX)
ATICORE_SOURCE		= $(SRCDIR)/$(ATICORE).$(ATICORE_SUFFIX)
ATICORE_DIR		= $(BUILDDIR)/$(ATICORE)
ATICORE_IPKG_TMP	= $(ATICORE_DIR)/ipkg_tmp

# ----------------------------------------------------------------------------
# Get
# ----------------------------------------------------------------------------

AtiCore_get: $(STATEDIR)/AtiCore.get

AtiCore_get_deps = $(ATICORE_SOURCE)

$(STATEDIR)/AtiCore.get: $(AtiCore_get_deps)
	@$(call targetinfo, $@)
	@$(call get_patches, $(ATICORE))
	touch $@

$(ATICORE_SOURCE):
	@$(call targetinfo, $@)
	@$(call get, $(ATICORE_URL))

# ----------------------------------------------------------------------------
# Extract
# ----------------------------------------------------------------------------

AtiCore_extract: $(STATEDIR)/AtiCore.extract

AtiCore_extract_deps = $(STATEDIR)/AtiCore.get

$(STATEDIR)/AtiCore.extract: $(AtiCore_extract_deps)
	@$(call targetinfo, $@)
	@$(call clean, $(ATICORE_DIR))
	@$(call extract, $(ATICORE_SOURCE))
	@$(call patchin, $(ATICORE))
	touch $@

# ----------------------------------------------------------------------------
# Prepare
# ----------------------------------------------------------------------------

AtiCore_prepare: $(STATEDIR)/AtiCore.prepare

#
# dependencies
#
AtiCore_prepare_deps = \
	$(STATEDIR)/AtiCore.extract \
	$(STATEDIR)/virtual-xchain.install

ATICORE_PATH	=  PATH=$(CROSS_PATH)
ATICORE_ENV 	=  $(CROSS_ENV)
#ATICORE_ENV	+=
ATICORE_ENV	+= PKG_CONFIG_PATH=$(CROSS_LIB_DIR)/lib/pkgconfig:$(CROSS_LIB_DIR)/lib/pkgconfig
#ifdef PTXCONF_XFREE430
#ATICORE_ENV	+= LDFLAGS=-Wl,-rpath-link,$(CROSS_LIB_DIR)/lib
#endif

#
# autoconf
#
ATICORE_AUTOCONF = \
	--build=$(GNU_HOST) \
	--host=$(PTXCONF_GNU_TARGET) \
	--prefix=/usr

ifdef PTXCONF_XFREE430
ATICORE_AUTOCONF += --x-includes=$(CROSS_LIB_DIR)/include
ATICORE_AUTOCONF += --x-libraries=$(CROSS_LIB_DIR)/lib
endif

ASFLAGS=AS=$(PTXCONF_GNU_TARGET)-gcc ASFLAGS="-mcpu=xscale -c"

$(STATEDIR)/AtiCore.prepare: $(AtiCore_prepare_deps)
	@$(call targetinfo, $@)
	@$(call clean, $(ATICORE_DIR)/config.cache)
	#cd $(ATICORE_DIR) && \
	#	$(ATICORE_PATH) $(ATICORE_ENV) \
	#	./configure $(ATICORE_AUTOCONF)
	touch $@

# ----------------------------------------------------------------------------
# Compile
# ----------------------------------------------------------------------------

AtiCore_compile: $(STATEDIR)/AtiCore.compile

AtiCore_compile_deps = $(STATEDIR)/AtiCore.prepare

$(STATEDIR)/AtiCore.compile: $(AtiCore_compile_deps)
	@$(call targetinfo, $@)
	$(ATICORE_PATH) $(MAKE) -C $(ATICORE_DIR) $(ASFLAGS)
	touch $@

# ----------------------------------------------------------------------------
# Install
# ----------------------------------------------------------------------------

AtiCore_install: $(STATEDIR)/AtiCore.install

$(STATEDIR)/AtiCore.install: $(STATEDIR)/AtiCore.compile
	@$(call targetinfo, $@)
	###$(ATICORE_PATH) $(MAKE) -C $(ATICORE_DIR) install
	cp -a $(ATICORE_DIR)/*.so*	$(CROSS_LIB_DIR)/lib
	cp -a $(ATICORE_DIR)/*.h	$(CROSS_LIB_DIR)/include
	touch $@

# ----------------------------------------------------------------------------
# Target-Install
# ----------------------------------------------------------------------------

AtiCore_targetinstall: $(STATEDIR)/AtiCore.targetinstall

AtiCore_targetinstall_deps = $(STATEDIR)/AtiCore.compile

$(STATEDIR)/AtiCore.targetinstall: $(AtiCore_targetinstall_deps)
	@$(call targetinfo, $@)
	$(ATICORE_PATH) $(MAKE) -C $(ATICORE_DIR) DESTDIR=$(ATICORE_IPKG_TMP) install
	mkdir -p $(ATICORE_IPKG_TMP)/CONTROL
	echo "Package: aticore" 						 >$(ATICORE_IPKG_TMP)/CONTROL/control
	echo "Priority: optional" 						>>$(ATICORE_IPKG_TMP)/CONTROL/control
	echo "Section: Libraries" 						>>$(ATICORE_IPKG_TMP)/CONTROL/control
	echo "Maintainer: Alexander Chukov <sash@pdaXrom.org>" 			>>$(ATICORE_IPKG_TMP)/CONTROL/control
	echo "Architecture: $(SHORT_TARGET)" 					>>$(ATICORE_IPKG_TMP)/CONTROL/control
	echo "Version: $(ATICORE_VERSION)" 					>>$(ATICORE_IPKG_TMP)/CONTROL/control
	echo "Depends: " 							>>$(ATICORE_IPKG_TMP)/CONTROL/control
	echo "Description: ATI W100 graphics library"				>>$(ATICORE_IPKG_TMP)/CONTROL/control
	cd $(FEEDDIR) && $(XMKIPKG) $(ATICORE_IPKG_TMP)
	touch $@

# ----------------------------------------------------------------------------
# Image-Install
# ----------------------------------------------------------------------------

ifdef PTXCONF_ATICORE_INSTALL
ROMPACKAGES += $(STATEDIR)/AtiCore.imageinstall
endif

AtiCore_imageinstall_deps = $(STATEDIR)/AtiCore.targetinstall \
	$(STATEDIR)/virtual-image.install

$(STATEDIR)/AtiCore.imageinstall: $(AtiCore_imageinstall_deps)
	@$(call targetinfo, $@)
	cd $(FEEDDIR) && $(XIPKG) install aticore
	touch $@

# ----------------------------------------------------------------------------
# Clean
# ----------------------------------------------------------------------------

AtiCore_clean:
	rm -rf $(STATEDIR)/AtiCore.*
	rm -rf $(ATICORE_DIR)

# vim: syntax=make
