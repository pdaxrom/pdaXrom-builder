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
ifdef PTXCONF_WXBASIC
PACKAGES += wxbasic
endif

#
# Paths and names
#
WXBASIC_VENDOR_VERSION	= 1
WXBASIC_VERSION		= 0.52
WXBASIC			= wxsource-$(WXBASIC_VERSION)
WXBASIC_SUFFIX		= tar.gz
WXBASIC_URL		= http://kent.dl.sourceforge.net/sourceforge/wxbasic/$(WXBASIC).$(WXBASIC_SUFFIX)
WXBASIC_SOURCE		= $(SRCDIR)/$(WXBASIC).$(WXBASIC_SUFFIX)
WXBASIC_DIR		= $(BUILDDIR)/$(WXBASIC)
WXBASIC_IPKG_TMP	= $(WXBASIC_DIR)/ipkg_tmp

# ----------------------------------------------------------------------------
# Get
# ----------------------------------------------------------------------------

wxbasic_get: $(STATEDIR)/wxbasic.get

wxbasic_get_deps = $(WXBASIC_SOURCE)

$(STATEDIR)/wxbasic.get: $(wxbasic_get_deps)
	@$(call targetinfo, $@)
	@$(call get_patches, $(WXBASIC))
	touch $@

$(WXBASIC_SOURCE):
	@$(call targetinfo, $@)
	@$(call get, $(WXBASIC_URL))

# ----------------------------------------------------------------------------
# Extract
# ----------------------------------------------------------------------------

wxbasic_extract: $(STATEDIR)/wxbasic.extract

wxbasic_extract_deps = $(STATEDIR)/wxbasic.get

$(STATEDIR)/wxbasic.extract: $(wxbasic_extract_deps)
	@$(call targetinfo, $@)
	@$(call clean, $(WXBASIC_DIR))
	@$(mkdir -p $(WXBASIC_DIR))
	@$(call extract, $(WXBASIC_SOURCE), $(WXBASIC_DIR))
	@$(call patchin, $(WXBASIC))
	touch $@

# ----------------------------------------------------------------------------
# Prepare
# ----------------------------------------------------------------------------

wxbasic_prepare: $(STATEDIR)/wxbasic.prepare

#
# dependencies
#
wxbasic_prepare_deps = \
	$(STATEDIR)/wxbasic.extract \
	$(STATEDIR)/wxWidgets.install \
	$(STATEDIR)/virtual-xchain.install

WXBASIC_PATH	=  PATH=$(CROSS_PATH)
WXBASIC_ENV 	=  $(CROSS_ENV)
WXBASIC_ENV	+= CFLAGS="$(TARGET_OPT_CFLAGS)"
WXBASIC_ENV	+= CXXFLAGS="$(TARGET_OPT_CFLAGS)"
WXBASIC_ENV	+= PKG_CONFIG_PATH=$(CROSS_LIB_DIR)/lib/pkgconfig:$(CROSS_LIB_DIR)/lib/pkgconfig
#ifdef PTXCONF_XFREE430
#WXBASIC_ENV	+= LDFLAGS=-Wl,-rpath-link,$(CROSS_LIB_DIR)/lib
#endif

#
# autoconf
#
WXBASIC_AUTOCONF = \
	--build=$(GNU_HOST) \
	--host=$(PTXCONF_GNU_TARGET) \
	--prefix=/usr \
	--disable-debug

ifdef PTXCONF_XFREE430
WXBASIC_AUTOCONF += --x-includes=$(CROSS_LIB_DIR)/include
WXBASIC_AUTOCONF += --x-libraries=$(CROSS_LIB_DIR)/lib
endif

$(STATEDIR)/wxbasic.prepare: $(wxbasic_prepare_deps)
	@$(call targetinfo, $@)
	@$(call clean, $(WXBASIC_DIR)/config.cache)
	#cd $(WXBASIC_DIR) && \
	#	$(WXBASIC_PATH) $(WXBASIC_ENV) \
	#	./configure $(WXBASIC_AUTOCONF)
	touch $@

# ----------------------------------------------------------------------------
# Compile
# ----------------------------------------------------------------------------

wxbasic_compile: $(STATEDIR)/wxbasic.compile

wxbasic_compile_deps = $(STATEDIR)/wxbasic.prepare

$(STATEDIR)/wxbasic.compile: $(wxbasic_compile_deps)
	@$(call targetinfo, $@)
	$(WXBASIC_PATH) $(MAKE) -C $(WXBASIC_DIR) -f makefile.unx
	touch $@

# ----------------------------------------------------------------------------
# Install
# ----------------------------------------------------------------------------

wxbasic_install: $(STATEDIR)/wxbasic.install

$(STATEDIR)/wxbasic.install: $(STATEDIR)/wxbasic.compile
	@$(call targetinfo, $@)
	$(WXBASIC_PATH) $(MAKE) -C $(WXBASIC_DIR) install
	touch $@

# ----------------------------------------------------------------------------
# Target-Install
# ----------------------------------------------------------------------------

wxbasic_targetinstall: $(STATEDIR)/wxbasic.targetinstall

wxbasic_targetinstall_deps = $(STATEDIR)/wxbasic.compile \
	$(STATEDIR)/wxWidgets.targetinstall

$(STATEDIR)/wxbasic.targetinstall: $(wxbasic_targetinstall_deps)
	@$(call targetinfo, $@)
	$(WXBASIC_PATH) $(MAKE) -C $(WXBASIC_DIR) DESTDIR=$(WXBASIC_IPKG_TMP) install
	mkdir -p $(WXBASIC_IPKG_TMP)/CONTROL
	echo "Package: wxbasic" 							 >$(WXBASIC_IPKG_TMP)/CONTROL/control
	echo "Priority: optional" 							>>$(WXBASIC_IPKG_TMP)/CONTROL/control
	echo "Section: Development" 							>>$(WXBASIC_IPKG_TMP)/CONTROL/control
	echo "Maintainer: Alexander Chukov <sash@pdaXrom.org>" 				>>$(WXBASIC_IPKG_TMP)/CONTROL/control
	echo "Architecture: $(SHORT_TARGET)" 						>>$(WXBASIC_IPKG_TMP)/CONTROL/control
	echo "Version: $(WXBASIC_VERSION)-$(WXBASIC_VENDOR_VERSION)" 			>>$(WXBASIC_IPKG_TMP)/CONTROL/control
	echo "Depends: wxwidgets" 							>>$(WXBASIC_IPKG_TMP)/CONTROL/control
	echo "Description: wxBasic programming language"				>>$(WXBASIC_IPKG_TMP)/CONTROL/control
	asdasd
	cd $(FEEDDIR) && $(XMKIPKG) $(WXBASIC_IPKG_TMP)
	touch $@

# ----------------------------------------------------------------------------
# Image-Install
# ----------------------------------------------------------------------------

ifdef PTXCONF_WXBASIC_INSTALL
ROMPACKAGES += $(STATEDIR)/wxbasic.imageinstall
endif

wxbasic_imageinstall_deps = $(STATEDIR)/wxbasic.targetinstall \
	$(STATEDIR)/virtual-image.install

$(STATEDIR)/wxbasic.imageinstall: $(wxbasic_imageinstall_deps)
	@$(call targetinfo, $@)
	cd $(FEEDDIR) && $(XIPKG) install wxbasic
	touch $@

# ----------------------------------------------------------------------------
# Clean
# ----------------------------------------------------------------------------

wxbasic_clean:
	rm -rf $(STATEDIR)/wxbasic.*
	rm -rf $(WXBASIC_DIR)

# vim: syntax=make
