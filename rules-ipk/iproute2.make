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
ifdef PTXCONF_IPROUTE2
PACKAGES += iproute2
endif

#
# Paths and names
#
IPROUTE2_VENDOR_VERSION	= 1
IPROUTE2_VERSION	= 2.6.8
IPROUTE2		= iproute2-$(IPROUTE2_VERSION)-ss040730
IPROUTE2_SUFFIX		= tar.gz
IPROUTE2_URL		= http://developer.osdl.org/dev/iproute2/download/$(IPROUTE2).$(IPROUTE2_SUFFIX)
IPROUTE2_SOURCE		= $(SRCDIR)/$(IPROUTE2).$(IPROUTE2_SUFFIX)
IPROUTE2_DIR		= $(BUILDDIR)/iproute2-$(IPROUTE2_VERSION)
IPROUTE2_IPKG_TMP	= $(IPROUTE2_DIR)/ipkg_tmp

# ----------------------------------------------------------------------------
# Get
# ----------------------------------------------------------------------------

iproute2_get: $(STATEDIR)/iproute2.get

iproute2_get_deps = $(IPROUTE2_SOURCE)

$(STATEDIR)/iproute2.get: $(iproute2_get_deps)
	@$(call targetinfo, $@)
	@$(call get_patches, $(IPROUTE2))
	touch $@

$(IPROUTE2_SOURCE):
	@$(call targetinfo, $@)
	@$(call get, $(IPROUTE2_URL))

# ----------------------------------------------------------------------------
# Extract
# ----------------------------------------------------------------------------

iproute2_extract: $(STATEDIR)/iproute2.extract

iproute2_extract_deps = $(STATEDIR)/iproute2.get

$(STATEDIR)/iproute2.extract: $(iproute2_extract_deps)
	@$(call targetinfo, $@)
	@$(call clean,   $(IPROUTE2_DIR))
	@$(call extract, $(IPROUTE2_SOURCE))
	@$(call patchin, $(IPROUTE2), $(IPROUTE2_DIR))
	touch $@

# ----------------------------------------------------------------------------
# Prepare
# ----------------------------------------------------------------------------

iproute2_prepare: $(STATEDIR)/iproute2.prepare

#
# dependencies
#
iproute2_prepare_deps = \
	$(STATEDIR)/iproute2.extract \
	$(STATEDIR)/virtual-xchain.install

IPROUTE2_PATH	=  PATH=$(CROSS_PATH)
IPROUTE2_ENV 	=  $(CROSS_ENV)
#IPROUTE2_ENV	+=
IPROUTE2_ENV	+= PKG_CONFIG_PATH=$(CROSS_LIB_DIR)/lib/pkgconfig:$(CROSS_LIB_DIR)/lib/pkgconfig
#ifdef PTXCONF_XFREE430
#IPROUTE2_ENV	+= LDFLAGS=-Wl,-rpath-link,$(CROSS_LIB_DIR)/lib
#endif

#
# autoconf
#
IPROUTE2_AUTOCONF = \
	--build=$(GNU_HOST) \
	--host=$(PTXCONF_GNU_TARGET) \
	--prefix=/usr

ifdef PTXCONF_XFREE430
IPROUTE2_AUTOCONF += --x-includes=$(CROSS_LIB_DIR)/include
IPROUTE2_AUTOCONF += --x-libraries=$(CROSS_LIB_DIR)/lib
endif

$(STATEDIR)/iproute2.prepare: $(iproute2_prepare_deps)
	@$(call targetinfo, $@)
	@$(call clean, $(IPROUTE2_DIR)/config.cache)
	#cd $(IPROUTE2_DIR) && \
	#	$(IPROUTE2_PATH) $(IPROUTE2_ENV) \
	#	./configure $(IPROUTE2_AUTOCONF)
	touch $@

# ----------------------------------------------------------------------------
# Compile
# ----------------------------------------------------------------------------

iproute2_compile: $(STATEDIR)/iproute2.compile

iproute2_compile_deps = $(STATEDIR)/iproute2.prepare

$(STATEDIR)/iproute2.compile: $(iproute2_compile_deps)
	@$(call targetinfo, $@)
	$(IPROUTE2_PATH) $(IPROUTE2_ENV) $(MAKE) -C $(IPROUTE2_DIR) $(CROSS_ENV_CC) KERNEL_INCLUDE=$(KERNEL_DIR)/include DOCDIR=/usr/share/doc/iproute2 SUBDIRS='lib tc ip'
	touch $@

# ----------------------------------------------------------------------------
# Install
# ----------------------------------------------------------------------------

iproute2_install: $(STATEDIR)/iproute2.install

$(STATEDIR)/iproute2.install: $(STATEDIR)/iproute2.compile
	@$(call targetinfo, $@)
	touch $@

# ----------------------------------------------------------------------------
# Target-Install
# ----------------------------------------------------------------------------

iproute2_targetinstall: $(STATEDIR)/iproute2.targetinstall

iproute2_targetinstall_deps = $(STATEDIR)/iproute2.compile

$(STATEDIR)/iproute2.targetinstall: $(iproute2_targetinstall_deps)
	@$(call targetinfo, $@)
	$(IPROUTE2_PATH) $(IPROUTE2_ENV) $(MAKE) -C $(IPROUTE2_DIR) DESTDIR=$(IPROUTE2_IPKG_TMP) install  $(CROSS_ENV_CC) KERNEL_INCLUDE=$(KERNEL_DIR)/include DOCDIR=/usr/share/doc/iproute2 SUBDIRS='lib tc ip'
	rm -rf $(IPROUTE2_IPKG_TMP)/usr/share/doc
	$(CROSSSTRIP) $(IPROUTE2_IPKG_TMP)/usr/sbin/{ip,rtmon,tc}
	mkdir -p $(IPROUTE2_IPKG_TMP)/CONTROL
	echo "Package: iproute2" 							 >$(IPROUTE2_IPKG_TMP)/CONTROL/control
	echo "Priority: optional" 							>>$(IPROUTE2_IPKG_TMP)/CONTROL/control
	echo "Section: Network" 							>>$(IPROUTE2_IPKG_TMP)/CONTROL/control
	echo "Maintainer: Alexander Chukov <sash@pdaXrom.org>" 				>>$(IPROUTE2_IPKG_TMP)/CONTROL/control
	echo "Architecture: $(SHORT_TARGET)" 						>>$(IPROUTE2_IPKG_TMP)/CONTROL/control
	echo "Version: $(IPROUTE2_VERSION)-$(IPROUTE2_VENDOR_VERSION)" 			>>$(IPROUTE2_IPKG_TMP)/CONTROL/control
	echo "Depends: " 								>>$(IPROUTE2_IPKG_TMP)/CONTROL/control
	echo "Description: IP routing utilites"						>>$(IPROUTE2_IPKG_TMP)/CONTROL/control
	cd $(FEEDDIR) && $(XMKIPKG) $(IPROUTE2_IPKG_TMP)
	touch $@

# ----------------------------------------------------------------------------
# Image-Install
# ----------------------------------------------------------------------------

ifdef PTXCONF_IPROUTE2_INSTALL
ROMPACKAGES += $(STATEDIR)/iproute2.imageinstall
endif

iproute2_imageinstall_deps = $(STATEDIR)/iproute2.targetinstall \
	$(STATEDIR)/virtual-image.install

$(STATEDIR)/iproute2.imageinstall: $(iproute2_imageinstall_deps)
	@$(call targetinfo, $@)
	cd $(FEEDDIR) && $(XIPKG) install iproute2
	touch $@

# ----------------------------------------------------------------------------
# Clean
# ----------------------------------------------------------------------------

iproute2_clean:
	rm -rf $(STATEDIR)/iproute2.*
	rm -rf $(IPROUTE2_DIR)

# vim: syntax=make
