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
ifdef PTXCONF_ROX
PACKAGES += rox
endif

#
# Paths and names
#
ROX_VERSION	= 2.1.3
ROX		= rox-$(ROX_VERSION)
ROX_SUFFIX	= tgz
ROX_URL		= http://heanet.dl.sourceforge.net/sourceforge/rox/$(ROX).$(ROX_SUFFIX)
ROX_SOURCE	= $(SRCDIR)/$(ROX).$(ROX_SUFFIX)
ROX_DIR		= $(BUILDDIR)/$(ROX)
ROX_IPKG_TMP	= $(ROX_DIR)/ipkg_tmp

# ----------------------------------------------------------------------------
# Get
# ----------------------------------------------------------------------------

rox_get: $(STATEDIR)/rox.get

rox_get_deps = $(ROX_SOURCE)

$(STATEDIR)/rox.get: $(rox_get_deps)
	@$(call targetinfo, $@)
	@$(call get_patches, $(ROX))
	touch $@

$(ROX_SOURCE):
	@$(call targetinfo, $@)
	@$(call get, $(ROX_URL))

# ----------------------------------------------------------------------------
# Extract
# ----------------------------------------------------------------------------

rox_extract: $(STATEDIR)/rox.extract

rox_extract_deps = $(STATEDIR)/rox.get

$(STATEDIR)/rox.extract: $(rox_extract_deps)
	@$(call targetinfo, $@)
	@$(call clean, $(ROX_DIR))
	@$(call extract, $(ROX_SOURCE))
	@$(call patchin, $(ROX))
	touch $@

# ----------------------------------------------------------------------------
# Prepare
# ----------------------------------------------------------------------------

rox_prepare: $(STATEDIR)/rox.prepare

#
# dependencies
#
rox_prepare_deps = \
	$(STATEDIR)/rox.extract \
	$(STATEDIR)/gtk22.install \
	$(STATEDIR)/shared-mime-info.install \
	$(STATEDIR)/virtual-xchain.install

ROX_PATH	=  PATH=$(CROSS_PATH)
ROX_ENV 	=  $(CROSS_ENV)
ROX_ENV		+= CFLAGS="$(TARGET_OPT_CFLAGS)"
ROX_ENV		+= PKG_CONFIG_PATH=$(CROSS_LIB_DIR)/lib/pkgconfig:$(CROSS_LIB_DIR)/lib/pkgconfig
ROX_ENV		+= APP_DIR=$(ROX_DIR)/ROX-Filer
#ifdef PTXCONF_XFREE430
#ROX_ENV		+= LDFLAGS=-Wl,-rpath-link,$(CROSS_LIB_DIR)/lib
#endif

#
# autoconf
#
ROX_AUTOCONF = \
	--build=$(GNU_HOST) \
	--host=$(PTXCONF_GNU_TARGET) \
	--with-platform=Linux-$(PTXCONF_ARCH) \
	--disable-debug

ifdef PTXCONF_XFREE430
ROX_AUTOCONF += --x-includes=$(CROSS_LIB_DIR)/include
ROX_AUTOCONF += --x-libraries=$(CROSS_LIB_DIR)/lib
endif

$(STATEDIR)/rox.prepare: $(rox_prepare_deps)
	@$(call targetinfo, $@)
	@$(call clean, $(ROX_DIR)/config.cache)
	cd $(ROX_DIR)/ROX-Filer/src && \
		$(ROX_PATH) $(ROX_ENV) \
		./configure $(ROX_AUTOCONF)
	touch $@

# ----------------------------------------------------------------------------
# Compile
# ----------------------------------------------------------------------------

rox_compile: $(STATEDIR)/rox.compile

rox_compile_deps = $(STATEDIR)/rox.prepare

$(STATEDIR)/rox.compile: $(rox_compile_deps)
	@$(call targetinfo, $@)
	$(ROX_ENV) $(ROX_PATH) $(MAKE) -C $(ROX_DIR)/ROX-Filer/src
	touch $@

# ----------------------------------------------------------------------------
# Install
# ----------------------------------------------------------------------------

rox_install: $(STATEDIR)/rox.install

$(STATEDIR)/rox.install: $(STATEDIR)/rox.compile
	@$(call targetinfo, $@)
	touch $@

# ----------------------------------------------------------------------------
# Target-Install
# ----------------------------------------------------------------------------

rox_targetinstall: $(STATEDIR)/rox.targetinstall

rox_targetinstall_deps = $(STATEDIR)/rox.compile \
	$(STATEDIR)/gtk22.targetinstall \
	$(STATEDIR)/shared-mime-info.targetinstall

$(STATEDIR)/rox.targetinstall: $(rox_targetinstall_deps)
	@$(call targetinfo, $@)
	mkdir -p $(ROX_IPKG_TMP)/usr/apps
	mkdir -p $(ROX_IPKG_TMP)/usr/bin
	mkdir -p $(ROX_IPKG_TMP)/usr/share
	mkdir -p $(ROX_IPKG_TMP)/usr/share/mime/packages
	cp -a $(ROX_DIR)/ROX-Filer $(ROX_IPKG_TMP)/usr/apps
	cp -a $(ROX_DIR)/Choices   $(ROX_IPKG_TMP)/usr/share
	cp -a $(ROX_DIR)/rox.xml   $(ROX_IPKG_TMP)/usr/share/mime/packages
	$(CROSSSTRIP) $(ROX_IPKG_TMP)/usr/apps/ROX-Filer/Linux-$(PTXCONF_ARCH)/*
	rm -rf $(ROX_IPKG_TMP)/usr/apps/ROX-Filer/src
	rm -rf $(ROX_IPKG_TMP)/usr/apps/ROX-Filer/Messages/*
	rm -rf $(ROX_IPKG_TMP)/usr/apps/ROX-Filer/Help/Manual-*
	rm -rf $(ROX_IPKG_TMP)/usr/apps/ROX-Filer/Help/README-*
	rm -rf $(ROX_IPKG_TMP)/usr/apps/ROX-Filer/Help/Changes
	cp -a $(TOPDIR)/config/pdaXrom/ROX-mimes/* $(ROX_IPKG_TMP)/usr/share/Choices/MIME-types
	echo "#!/bin/sh"				 >$(ROX_IPKG_TMP)/usr/bin/rox
	echo "exec /usr/apps/ROX-Filer/AppRun \"\$$@\""	>>$(ROX_IPKG_TMP)/usr/bin/rox
	chmod 755 $(ROX_IPKG_TMP)/usr/bin/rox
	mkdir -p $(ROX_IPKG_TMP)/usr/share/applications
	mkdir -p $(ROX_IPKG_TMP)/usr/share/pixmaps
	cp -f $(TOPDIR)/config/pics/rox.desktop $(ROX_IPKG_TMP)/usr/share/applications
	cp -f $(TOPDIR)/config/pics/rox.png     $(ROX_IPKG_TMP)/usr/share/pixmaps
	mkdir -p $(ROX_IPKG_TMP)/CONTROL
	echo "Package: rox" 				>$(ROX_IPKG_TMP)/CONTROL/control
	echo "Priority: optional" 			>>$(ROX_IPKG_TMP)/CONTROL/control
	echo "Section: ROX" 				>>$(ROX_IPKG_TMP)/CONTROL/control
	echo "Maintainer: Alexander Chukov <sash@pdaXrom.org>">>$(ROX_IPKG_TMP)/CONTROL/control
	echo "Architecture: $(SHORT_TARGET)" 		>>$(ROX_IPKG_TMP)/CONTROL/control
	echo "Version: $(ROX_VERSION)" 			>>$(ROX_IPKG_TMP)/CONTROL/control
	echo "Depends: shared-mime-info, gtk2" 		>>$(ROX_IPKG_TMP)/CONTROL/control
	echo "Description: A RISC OS-like filer for X">>$(ROX_IPKG_TMP)/CONTROL/control
	cd $(FEEDDIR) && $(XMKIPKG) $(ROX_IPKG_TMP)
	touch $@

# ----------------------------------------------------------------------------
# Image-Install
# ----------------------------------------------------------------------------

ifdef PTXCONF_ROX_INSTALL
ROMPACKAGES += $(STATEDIR)/rox.imageinstall
endif

rox_imageinstall_deps = $(STATEDIR)/rox.targetinstall \
	$(STATEDIR)/virtual-image.install \
	$(STATEDIR)/shared-mime-info.imageinstall

$(STATEDIR)/rox.imageinstall: $(rox_imageinstall_deps)
	@$(call targetinfo, $@)
	cd $(FEEDDIR) && $(XIPKG) install rox
	touch $@

# ----------------------------------------------------------------------------
# Clean
# ----------------------------------------------------------------------------

rox_clean:
	rm -rf $(STATEDIR)/rox.*
	rm -rf $(ROX_DIR)

# vim: syntax=make
