# -*-makefile-*-
# $Id: template,v 1.10 2004/01/24 15:50:34 mkl Exp $
#
# Copyright (C) 2004 by Mikkel Skovgaard <laze@pdaXrom.org>
#          
# See CREDITS for details about who has contributed to this project.
#
# For further information about the PTXdist project and license conditions
# see the README file.
#

#
# We provide this package
#
ifdef PTXCONF_XRESIZEWINDOW
PACKAGES += xresizewindow
endif

#
# Paths and names
#
XRESIZEWINDOW_VERSION		= 0.0.2
XRESIZEWINDOW			= xresizewindow-$(XRESIZEWINDOW_VERSION)
XRESIZEWINDOW_SUFFIX		= tar.bz2
XRESIZEWINDOW_URL		= http://www.pdaXrom.org/src/$(XRESIZEWINDOW).$(XRESIZEWINDOW_SUFFIX)
XRESIZEWINDOW_SOURCE		= $(SRCDIR)/$(XRESIZEWINDOW).$(XRESIZEWINDOW_SUFFIX)
XRESIZEWINDOW_DIR		= $(BUILDDIR)/$(XRESIZEWINDOW)
XRESIZEWINDOW_IPKG_TMP		= $(XRESIZEWINDOW_DIR)/ipkg_tmp

# ----------------------------------------------------------------------------
# Get
# ----------------------------------------------------------------------------

xresizewindow_get: $(STATEDIR)/xresizewindow.get

xresizewindow_get_deps = $(XRESIZEWINDOW_SOURCE)

$(STATEDIR)/xresizewindow.get: $(xresizewindow_get_deps)
	@$(call targetinfo, $@)
	@$(call get_patches, $(XRESIZEWINDOW))
	touch $@

$(XRESIZEWINDOW_SOURCE):
	@$(call targetinfo, $@)
	@$(call get, $(XRESIZEWINDOW_URL))

# ----------------------------------------------------------------------------
# Extract
# ----------------------------------------------------------------------------

xresizewindow_extract: $(STATEDIR)/xresizewindow.extract

xresizewindow_extract_deps = $(STATEDIR)/xresizewindow.get

$(STATEDIR)/xresizewindow.extract: $(xresizewindow_extract_deps)
	@$(call targetinfo, $@)
	@$(call clean, $(XRESIZEWINDOW_DIR))
	@$(call extract, $(XRESIZEWINDOW_SOURCE))
	@$(call patchin, $(XRESIZEWINDOW))
	touch $@

# ----------------------------------------------------------------------------
# Prepare
# ----------------------------------------------------------------------------

xresizewindow_prepare: $(STATEDIR)/xresizewindow.prepare

#
# dependencies
#
xresizewindow_prepare_deps = \
	$(STATEDIR)/xresizewindow.extract \
	$(STATEDIR)/xfree430.install \
	$(STATEDIR)/virtual-xchain.install

XRESIZEWINDOW_PATH	=  PATH=$(CROSS_PATH)
XRESIZEWINDOW_ENV 	=  $(CROSS_ENV)
#XRESIZEWINDOW_ENV	+=
XRESIZEWINDOW_ENV	+= PKG_CONFIG_PATH=$(CROSS_LIB_DIR)/lib/pkgconfig:$(CROSS_LIB_DIR)/lib/pkgconfig
ifdef PTXCONF_XFREE430
XRESIZEWINDOW_ENV	+= CFLAGS="-O2 -s"
#XRESIZEWINDOW_ENV	+= LDFLAGS="-L$(CROSS_LIB_DIR)/lib -Wl,-rpath-link,$(CROSS_LIB_DIR)/lib"
endif

#
# autoconf
#
XRESIZEWINDOW_AUTOCONF = \
	--build=$(GNU_HOST) \
	--host=$(PTXCONF_GNU_TARGET) \
	--prefix=/usr

ifdef PTXCONF_XFREE430
XRESIZEWINDOW_AUTOCONF += --x-includes=$(CROSS_LIB_DIR)/include
XRESIZEWINDOW_AUTOCONF += --x-libraries=$(CROSS_LIB_DIR)/lib
endif

$(STATEDIR)/xresizewindow.prepare: $(xresizewindow_prepare_deps)
	@$(call targetinfo, $@)
	@$(call clean, $(XRESIZEWINDOW_DIR)/config.cache)
	#cd $(XRESIZEWINDOW_DIR) && \
	#	$(XRESIZEWINDOW_PATH) $(XRESIZEWINDOW_ENV) \
	#	./configure $(XRESIZEWINDOW_AUTOCONF)
	touch $@

# ----------------------------------------------------------------------------
# Compile
# ----------------------------------------------------------------------------

xresizewindow_compile: $(STATEDIR)/xresizewindow.compile

xresizewindow_compile_deps = $(STATEDIR)/xresizewindow.prepare

$(STATEDIR)/xresizewindow.compile: $(xresizewindow_compile_deps)
	@$(call targetinfo, $@)
	$(XRESIZEWINDOW_PATH) $(XRESIZEWINDOW_ENV) $(MAKE) -C $(XRESIZEWINDOW_DIR)
	touch $@

# ----------------------------------------------------------------------------
# Install
# ----------------------------------------------------------------------------

xresizewindow_install: $(STATEDIR)/xresizewindow.install

$(STATEDIR)/xresizewindow.install: $(STATEDIR)/xresizewindow.compile
	@$(call targetinfo, $@)
	touch $@

# ----------------------------------------------------------------------------
# Target-Install
# ----------------------------------------------------------------------------

xresizewindow_targetinstall: $(STATEDIR)/xresizewindow.targetinstall

xresizewindow_targetinstall_deps = $(STATEDIR)/xresizewindow.compile \
	$(STATEDIR)/xfree430.targetinstall

$(STATEDIR)/xresizewindow.targetinstall: $(xresizewindow_targetinstall_deps)
	@$(call targetinfo, $@)
	###$(XRESIZEWINDOW_PATH) $(MAKE) -C $(XRESIZEWINDOW_DIR) DESTDIR=$(XRESIZEWINDOW_IPKG_TMP) install
	mkdir -p $(XRESIZEWINDOW_IPKG_TMP)/usr/bin
	cp -a $(XRESIZEWINDOW_DIR)/xresizewindow $(XRESIZEWINDOW_IPKG_TMP)/usr/bin
	mkdir -p $(XRESIZEWINDOW_IPKG_TMP)/CONTROL
	echo "Package: xresizewindow" 				>$(XRESIZEWINDOW_IPKG_TMP)/CONTROL/control
	echo "Priority: optional" 				>>$(XRESIZEWINDOW_IPKG_TMP)/CONTROL/control
	echo "Section: X11"	 				>>$(XRESIZEWINDOW_IPKG_TMP)/CONTROL/control
	echo "Maintainer: Mikkel Skovgaard <laze@pdaXrom.org>" 	>>$(XRESIZEWINDOW_IPKG_TMP)/CONTROL/control
	echo "Architecture: $(SHORT_TARGET)" 			>>$(XRESIZEWINDOW_IPKG_TMP)/CONTROL/control
	echo "Version: $(XRESIZEWINDOW_VERSION)" 		>>$(XRESIZEWINDOW_IPKG_TMP)/CONTROL/control
	echo "Depends: xfree430" 				>>$(XRESIZEWINDOW_IPKG_TMP)/CONTROL/control
	echo "Description: move and resize app windows"		>>$(XRESIZEWINDOW_IPKG_TMP)/CONTROL/control
	cd $(FEEDDIR) && $(XMKIPKG) $(XRESIZEWINDOW_IPKG_TMP)
	touch $@

# ----------------------------------------------------------------------------
# Image-Install
# ----------------------------------------------------------------------------

ifdef PTXCONF_XRESIZEWINDOW_INSTALL
ROMPACKAGES += $(STATEDIR)/xresizewindow.imageinstall
endif

xresizewindow_imageinstall_deps = $(STATEDIR)/xresizewindow.targetinstall \
	$(STATEDIR)/virtual-image.install

$(STATEDIR)/xresizewindow.imageinstall: $(xresizewindow_imageinstall_deps)
	@$(call targetinfo, $@)
	cd $(FEEDDIR) && $(XIPKG) install xresizewindow
	touch $@

# ----------------------------------------------------------------------------
# Clean
# ----------------------------------------------------------------------------

xresizewindow_clean:
	rm -rf $(STATEDIR)/xresizewindow.*
	rm -rf $(XRESIZEWINDOW_DIR)

# vim: syntax=make
