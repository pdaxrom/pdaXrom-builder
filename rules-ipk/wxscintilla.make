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
ifdef PTXCONF_WXSCINTILLA
PACKAGES += wxscintilla
endif

#
# Paths and names
#
WXSCINTILLA_VENDOR_VERSION	= 1
WXSCINTILLA_VERSION		= 1.62.3
WXSCINTILLA			= wxscintilla_$(WXSCINTILLA_VERSION)
WXSCINTILLA_SUFFIX		= tar.gz
WXSCINTILLA_URL			= http://mesh.dl.sourceforge.net/sourceforge/wxguide/$(WXSCINTILLA).$(WXSCINTILLA_SUFFIX)
WXSCINTILLA_SOURCE		= $(SRCDIR)/$(WXSCINTILLA).$(WXSCINTILLA_SUFFIX)
WXSCINTILLA_DIR			= $(BUILDDIR)/$(WXSCINTILLA)
WXSCINTILLA_IPKG_TMP		= $(WXSCINTILLA_DIR)/ipkg_tmp

# ----------------------------------------------------------------------------
# Get
# ----------------------------------------------------------------------------

wxscintilla_get: $(STATEDIR)/wxscintilla.get

wxscintilla_get_deps = $(WXSCINTILLA_SOURCE)

$(STATEDIR)/wxscintilla.get: $(wxscintilla_get_deps)
	@$(call targetinfo, $@)
	@$(call get_patches, $(WXSCINTILLA))
	touch $@

$(WXSCINTILLA_SOURCE):
	@$(call targetinfo, $@)
	@$(call get, $(WXSCINTILLA_URL))

# ----------------------------------------------------------------------------
# Extract
# ----------------------------------------------------------------------------

wxscintilla_extract: $(STATEDIR)/wxscintilla.extract

wxscintilla_extract_deps = $(STATEDIR)/wxscintilla.get

$(STATEDIR)/wxscintilla.extract: $(wxscintilla_extract_deps)
	@$(call targetinfo, $@)
	@$(call clean, $(WXSCINTILLA_DIR))
	@$(call extract, $(WXSCINTILLA_SOURCE))
	@$(call patchin, $(WXSCINTILLA))
	touch $@

# ----------------------------------------------------------------------------
# Prepare
# ----------------------------------------------------------------------------

wxscintilla_prepare: $(STATEDIR)/wxscintilla.prepare

#
# dependencies
#
wxscintilla_prepare_deps = \
	$(STATEDIR)/wxscintilla.extract \
	$(STATEDIR)/virtual-xchain.install

WXSCINTILLA_PATH	=  PATH=PATH=$(CROSS_LIB_DIR)/bin:$(CROSS_PATH)
WXSCINTILLA_ENV 	=  $(CROSS_ENV)
WXSCINTILLA_ENV		+= CFLAGS="$(TARGET_OPT_CFLAGS)"
WXSCINTILLA_ENV		+= CXXFLAGS="$(TARGET_OPT_CFLAGS)"
WXSCINTILLA_ENV		+= PKG_CONFIG_PATH=$(CROSS_LIB_DIR)/lib/pkgconfig
#ifdef PTXCONF_XFREE430
#WXSCINTILLA_ENV	+= LDFLAGS=-Wl,-rpath-link,$(CROSS_LIB_DIR)/X11R6/lib
#endif

#
# autoconf
#
WXSCINTILLA_AUTOCONF = \
	--build=$(GNU_HOST) \
	--host=$(PTXCONF_GNU_TARGET) \
	--prefix=/usr

ifdef PTXCONF_XFREE430
WXSCINTILLA_AUTOCONF += --x-includes=$(CROSS_LIB_DIR)/include
WXSCINTILLA_AUTOCONF += --x-libraries=$(CROSS_LIB_DIR)/lib
endif

$(STATEDIR)/wxscintilla.prepare: $(wxscintilla_prepare_deps)
	@$(call targetinfo, $@)
	@$(call clean, $(WXSCINTILLA_DIR)/config.cache)
	#cd $(WXSCINTILLA_DIR) && \
	#	$(WXSCINTILLA_PATH) $(WXSCINTILLA_ENV) \
	#	./configure $(WXSCINTILLA_AUTOCONF)
	touch $@

# ----------------------------------------------------------------------------
# Compile
# ----------------------------------------------------------------------------

wxscintilla_compile: $(STATEDIR)/wxscintilla.compile

wxscintilla_compile_deps = $(STATEDIR)/wxscintilla.prepare

$(STATEDIR)/wxscintilla.compile: $(wxscintilla_compile_deps)
	@$(call targetinfo, $@)
	$(WXSCINTILLA_PATH) $(WXSCINTILLA_ENV) $(MAKE) -C $(WXSCINTILLA_DIR)/build GTK2=yes
	touch $@

# ----------------------------------------------------------------------------
# Install
# ----------------------------------------------------------------------------

wxscintilla_install: $(STATEDIR)/wxscintilla.install

$(STATEDIR)/wxscintilla.install: $(STATEDIR)/wxscintilla.compile
	@$(call targetinfo, $@)
	#$(WXSCINTILLA_PATH) $(MAKE) -C $(WXSCINTILLA_DIR) install
	asdasd
	touch $@

# ----------------------------------------------------------------------------
# Target-Install
# ----------------------------------------------------------------------------

wxscintilla_targetinstall: $(STATEDIR)/wxscintilla.targetinstall

wxscintilla_targetinstall_deps = $(STATEDIR)/wxscintilla.compile

$(STATEDIR)/wxscintilla.targetinstall: $(wxscintilla_targetinstall_deps)
	@$(call targetinfo, $@)
	$(WXSCINTILLA_PATH) $(MAKE) -C $(WXSCINTILLA_DIR) DESTDIR=$(WXSCINTILLA_IPKG_TMP) install
	mkdir -p $(WXSCINTILLA_IPKG_TMP)/CONTROL
	echo "Package: wxscintilla" 							 >$(WXSCINTILLA_IPKG_TMP)/CONTROL/control
	echo "Priority: optional" 							>>$(WXSCINTILLA_IPKG_TMP)/CONTROL/control
	echo "Section: pdaXrom" 							>>$(WXSCINTILLA_IPKG_TMP)/CONTROL/control
	echo "Maintainer: Alexander Chukov <sash@pdaXrom.org>" 				>>$(WXSCINTILLA_IPKG_TMP)/CONTROL/control
	echo "Architecture: $(SHORT_TARGET)" 						>>$(WXSCINTILLA_IPKG_TMP)/CONTROL/control
	echo "Version: $(WXSCINTILLA_VERSION)-$(WXSCINTILLA_VENDOR_VERSION)" 		>>$(WXSCINTILLA_IPKG_TMP)/CONTROL/control
	echo "Depends: " 								>>$(WXSCINTILLA_IPKG_TMP)/CONTROL/control
	echo "Description: generated with pdaXrom builder"				>>$(WXSCINTILLA_IPKG_TMP)/CONTROL/control
	asdasd
	cd $(FEEDDIR) && $(XMKIPKG) $(WXSCINTILLA_IPKG_TMP)
	touch $@

# ----------------------------------------------------------------------------
# Image-Install
# ----------------------------------------------------------------------------

ifdef PTXCONF_WXSCINTILLA_INSTALL
ROMPACKAGES += $(STATEDIR)/wxscintilla.imageinstall
endif

wxscintilla_imageinstall_deps = $(STATEDIR)/wxscintilla.targetinstall \
	$(STATEDIR)/virtual-image.install

$(STATEDIR)/wxscintilla.imageinstall: $(wxscintilla_imageinstall_deps)
	@$(call targetinfo, $@)
	cd $(FEEDDIR) && $(XIPKG) install wxscintilla
	touch $@

# ----------------------------------------------------------------------------
# Clean
# ----------------------------------------------------------------------------

wxscintilla_clean:
	rm -rf $(STATEDIR)/wxscintilla.*
	rm -rf $(WXSCINTILLA_DIR)

# vim: syntax=make
