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
ifdef PTXCONF_DATENTIME2
PACKAGES += datentime2
endif

#
# Paths and names
#
DATENTIME2_VENDOR_VERSION	= 1
DATENTIME2_VERSION		= 1.1.0
DATENTIME2			= datentime-$(DATENTIME2_VERSION)
DATENTIME2_SUFFIX		= tar.bz2
DATENTIME2_URL			= http://www.pdaXrom.org/src/$(DATENTIME2).$(DATENTIME2_SUFFIX)
DATENTIME2_SOURCE		= $(SRCDIR)/$(DATENTIME2).$(DATENTIME2_SUFFIX)
DATENTIME2_DIR			= $(GPE-CVS_DIR)/base/$(DATENTIME2)
DATENTIME2_IPKG_TMP		= $(DATENTIME2_DIR)/ipkg_tmp

# ----------------------------------------------------------------------------
# Get
# ----------------------------------------------------------------------------

datentime2_get: $(STATEDIR)/datentime2.get

datentime2_get_deps = $(DATENTIME2_SOURCE)

$(STATEDIR)/datentime2.get: $(datentime2_get_deps)
	@$(call targetinfo, $@)
	@$(call get_patches, $(DATENTIME2))
	touch $@

$(DATENTIME2_SOURCE):
	@$(call targetinfo, $@)
	@$(call get, $(DATENTIME2_URL))

# ----------------------------------------------------------------------------
# Extract
# ----------------------------------------------------------------------------

datentime2_extract: $(STATEDIR)/datentime2.extract

datentime2_extract_deps = $(STATEDIR)/datentime2.get

$(STATEDIR)/datentime2.extract: $(datentime2_extract_deps)
	@$(call targetinfo, $@)
	@$(call clean,   $(DATENTIME2_DIR))
	@$(call extract, $(DATENTIME2_SOURCE), $(GPE-CVS_DIR)/base)
	@$(call patchin, $(DATENTIME2), $(DATENTIME2_DIR))
	touch $@

# ----------------------------------------------------------------------------
# Prepare
# ----------------------------------------------------------------------------

datentime2_prepare: $(STATEDIR)/datentime2.prepare

#
# dependencies
#
datentime2_prepare_deps = \
	$(STATEDIR)/datentime2.extract \
	$(STATEDIR)/gpe-cvs.install \
	$(STATEDIR)/virtual-xchain.install

DATENTIME2_PATH	=  PATH=$(CROSS_PATH)
DATENTIME2_ENV 	=  $(CROSS_ENV)
#DATENTIME2_ENV	+=
DATENTIME2_ENV	+= PKG_CONFIG_PATH=$(CROSS_LIB_DIR)/lib/pkgconfig
#ifdef PTXCONF_XFREE430
#DATENTIME2_ENV	+= LDFLAGS=-Wl,-rpath-link,$(CROSS_LIB_DIR)/X11R6/lib
#endif

#
# autoconf
#
DATENTIME2_AUTOCONF = \
	--build=$(GNU_HOST) \
	--host=$(PTXCONF_GNU_TARGET) \
	--prefix=/usr

ifdef PTXCONF_XFREE430
DATENTIME2_AUTOCONF += --x-includes=$(CROSS_LIB_DIR)/include
DATENTIME2_AUTOCONF += --x-libraries=$(CROSS_LIB_DIR)/lib
endif

$(STATEDIR)/datentime2.prepare: $(datentime2_prepare_deps)
	@$(call targetinfo, $@)
	@$(call clean, $(DATENTIME2_DIR)/config.cache)
	#cd $(DATENTIME2_DIR) && \
	#	$(DATENTIME2_PATH) $(DATENTIME2_ENV) \
	#	./configure $(DATENTIME2_AUTOCONF)
	touch $@

# ----------------------------------------------------------------------------
# Compile
# ----------------------------------------------------------------------------

datentime2_compile: $(STATEDIR)/datentime2.compile

datentime2_compile_deps = $(STATEDIR)/datentime2.prepare

$(STATEDIR)/datentime2.compile: $(datentime2_compile_deps)
	@$(call targetinfo, $@)
	$(DATENTIME2_PATH) $(GPE-CVS_ENV) $(MAKE) -C $(DATENTIME2_DIR) CVSBUILD=yes
	touch $@

# ----------------------------------------------------------------------------
# Install
# ----------------------------------------------------------------------------

datentime2_install: $(STATEDIR)/datentime2.install

$(STATEDIR)/datentime2.install: $(STATEDIR)/datentime2.compile
	@$(call targetinfo, $@)
	touch $@

# ----------------------------------------------------------------------------
# Target-Install
# ----------------------------------------------------------------------------

datentime2_targetinstall: $(STATEDIR)/datentime2.targetinstall

datentime2_targetinstall_deps = $(STATEDIR)/datentime2.compile

$(STATEDIR)/datentime2.targetinstall: $(datentime2_targetinstall_deps)
	@$(call targetinfo, $@)
	$(DATENTIME2_PATH) $(GPE-CVS_ENV) $(MAKE) -C $(DATENTIME2_DIR) DESTDIR=$(DATENTIME2_IPKG_TMP) install CVSBUILD=yes
	mkdir -p $(DATENTIME2_IPKG_TMP)/CONTROL
	echo "Package: datentime2" 							 >$(DATENTIME2_IPKG_TMP)/CONTROL/control
	echo "Priority: optional" 							>>$(DATENTIME2_IPKG_TMP)/CONTROL/control
	echo "Section: X11" 								>>$(DATENTIME2_IPKG_TMP)/CONTROL/control
	echo "Maintainer: Alexander Chukov <sash@pdaXrom.org>" 				>>$(DATENTIME2_IPKG_TMP)/CONTROL/control
	echo "Architecture: $(SHORT_TARGET)" 						>>$(DATENTIME2_IPKG_TMP)/CONTROL/control
	echo "Version: $(DATENTIME2_VERSION)-$(DATENTIME2_VENDOR_VERSION)" 		>>$(DATENTIME2_IPKG_TMP)/CONTROL/control
	echo "Depends: gtk2, libgpewidget" 						>>$(DATENTIME2_IPKG_TMP)/CONTROL/control
	echo "Description: Date and Time settings"					>>$(DATENTIME2_IPKG_TMP)/CONTROL/control
	asasd
	cd $(FEEDDIR) && $(XMKIPKG) $(DATENTIME2_IPKG_TMP)
	touch $@

# ----------------------------------------------------------------------------
# Image-Install
# ----------------------------------------------------------------------------

ifdef PTXCONF_DATENTIME2_INSTALL
ROMPACKAGES += $(STATEDIR)/datentime2.imageinstall
endif

datentime2_imageinstall_deps = $(STATEDIR)/datentime2.targetinstall \
	$(STATEDIR)/virtual-image.install

$(STATEDIR)/datentime2.imageinstall: $(datentime2_imageinstall_deps)
	@$(call targetinfo, $@)
	cd $(FEEDDIR) && $(XIPKG) install datentime2
	touch $@

# ----------------------------------------------------------------------------
# Clean
# ----------------------------------------------------------------------------

datentime2_clean:
	rm -rf $(STATEDIR)/datentime2.*
	rm -rf $(DATENTIME2_DIR)

# vim: syntax=make
