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
ifdef PTXCONF_BATTALION
PACKAGES += battalion
endif

#
# Paths and names
#
BATTALION_VENDOR_VERSION	= 1
BATTALION_VERSION		= 1.4b
BATTALION			= battalion$(BATTALION_VERSION)
BATTALION_SUFFIX		= tar.bz2
BATTALION_URL			= http://www.evl.uic.edu/aej/BATTALION/$(BATTALION).$(BATTALION_SUFFIX)
BATTALION_SOURCE		= $(SRCDIR)/$(BATTALION).$(BATTALION_SUFFIX)
BATTALION_DIR			= $(BUILDDIR)/$(BATTALION)
BATTALION_IPKG_TMP		= $(BATTALION_DIR)/ipkg_tmp

# ----------------------------------------------------------------------------
# Get
# ----------------------------------------------------------------------------

battalion_get: $(STATEDIR)/battalion.get

battalion_get_deps = $(BATTALION_SOURCE)

$(STATEDIR)/battalion.get: $(battalion_get_deps)
	@$(call targetinfo, $@)
	@$(call get_patches, $(BATTALION))
	touch $@

$(BATTALION_SOURCE):
	@$(call targetinfo, $@)
	@$(call get, $(BATTALION_URL))

# ----------------------------------------------------------------------------
# Extract
# ----------------------------------------------------------------------------

battalion_extract: $(STATEDIR)/battalion.extract

battalion_extract_deps = $(STATEDIR)/battalion.get

$(STATEDIR)/battalion.extract: $(battalion_extract_deps)
	@$(call targetinfo, $@)
	@$(call clean, $(BATTALION_DIR))
	@$(call extract, $(BATTALION_SOURCE))
	@$(call patchin, $(BATTALION))
	touch $@

# ----------------------------------------------------------------------------
# Prepare
# ----------------------------------------------------------------------------

battalion_prepare: $(STATEDIR)/battalion.prepare

#
# dependencies
#
battalion_prepare_deps = \
	$(STATEDIR)/battalion.extract \
	$(STATEDIR)/MesaLib.install \
	$(STATEDIR)/virtual-xchain.install

BATTALION_PATH	=  PATH=$(CROSS_PATH)
BATTALION_ENV 	=  $(CROSS_ENV)
#BATTALION_ENV	+=
BATTALION_ENV	+= PKG_CONFIG_PATH=$(CROSS_LIB_DIR)/lib/pkgconfig:$(CROSS_LIB_DIR)/lib/pkgconfig
#ifdef PTXCONF_XFREE430
#BATTALION_ENV	+= LDFLAGS=-Wl,-rpath-link,$(CROSS_LIB_DIR)/lib
#endif

#
# autoconf
#
BATTALION_AUTOCONF = \
	--build=$(GNU_HOST) \
	--host=$(PTXCONF_GNU_TARGET) \
	--prefix=/usr

ifdef PTXCONF_XFREE430
BATTALION_AUTOCONF += --x-includes=$(CROSS_LIB_DIR)/include
BATTALION_AUTOCONF += --x-libraries=$(CROSS_LIB_DIR)/lib
endif

$(STATEDIR)/battalion.prepare: $(battalion_prepare_deps)
	@$(call targetinfo, $@)
	@$(call clean, $(BATTALION_DIR)/config.cache)
	#cd $(BATTALION_DIR) && \
	#	$(BATTALION_PATH) $(BATTALION_ENV) \
	#	./configure $(BATTALION_AUTOCONF)
	rm -f $(BATTALION_DIR)/battalion
	touch $@

# ----------------------------------------------------------------------------
# Compile
# ----------------------------------------------------------------------------

battalion_compile: $(STATEDIR)/battalion.compile

battalion_compile_deps = $(STATEDIR)/battalion.prepare

$(STATEDIR)/battalion.compile: $(battalion_compile_deps)
	@$(call targetinfo, $@)
	$(BATTALION_PATH) $(MAKE) -C $(BATTALION_DIR) $(CROSS_ENV_CC) \
	    X11_INC=$(CROSS_LIB_DIR)/include X11_LIB=$(CROSS_LIB_DIR)/lib
	touch $@

# ----------------------------------------------------------------------------
# Install
# ----------------------------------------------------------------------------

battalion_install: $(STATEDIR)/battalion.install

$(STATEDIR)/battalion.install: $(STATEDIR)/battalion.compile
	@$(call targetinfo, $@)
	touch $@

# ----------------------------------------------------------------------------
# Target-Install
# ----------------------------------------------------------------------------

battalion_targetinstall: $(STATEDIR)/battalion.targetinstall

battalion_targetinstall_deps = $(STATEDIR)/battalion.compile \
	$(STATEDIR)/MesaLib.targetinstall

$(STATEDIR)/battalion.targetinstall: $(battalion_targetinstall_deps)
	@$(call targetinfo, $@)
	mkdir -p $(BATTALION_IPKG_TMP)/usr/share/{battalion,applications,pixmaps}
	cp -a $(BATTALION_DIR)/DATA	$(BATTALION_IPKG_TMP)/usr/share/battalion/
	cp -a $(BATTALION_DIR)/MUSIC	$(BATTALION_IPKG_TMP)/usr/share/battalion/
	cp -a $(BATTALION_DIR)/SOUNDS	$(BATTALION_IPKG_TMP)/usr/share/battalion/
	cp -a $(BATTALION_DIR)/TEXTURES	$(BATTALION_IPKG_TMP)/usr/share/battalion/
	cp -a $(TOPDIR)/config/pics/battalion.desktop $(BATTALION_IPKG_TMP)/usr/share/applications/
	cp -a $(TOPDIR)/config/pics/Googelonrmesa.png $(BATTALION_IPKG_TMP)/usr/share/pixmaps/
	$(INSTALL) -m 755 $(BATTALION_DIR)/battalion	$(BATTALION_IPKG_TMP)/usr/share/battalion/
	$(CROSSSTRIP) $(BATTALION_IPKG_TMP)/usr/share/battalion/battalion
	rm -f $(BATTALION_IPKG_TMP)/usr/share/battalion/MUSIC/*.au
	rm -f $(BATTALION_IPKG_TMP)/usr/share/battalion/SOUNDS/*.au
	mkdir -p $(BATTALION_IPKG_TMP)/usr/bin
	echo "#!/bin/bash"									 >$(BATTALION_IPKG_TMP)/usr/bin/battalion
	echo "cd /usr/share/battalion"								>>$(BATTALION_IPKG_TMP)/usr/bin/battalion
ifdef PTXCONF_ARCH_ARM
	echo "xrandr -s 1"									>>$(BATTALION_IPKG_TMP)/usr/bin/battalion
	echo "./battalion -noaudio"								>>$(BATTALION_IPKG_TMP)/usr/bin/battalion
	echo "xrandr -s 0"									>>$(BATTALION_IPKG_TMP)/usr/bin/battalion
else
	echo "./battalion"									>>$(BATTALION_IPKG_TMP)/usr/bin/battalion
endif
	chmod 755 $(BATTALION_IPKG_TMP)/usr/bin/battalion
	mkdir -p $(BATTALION_IPKG_TMP)/CONTROL
	echo "Package: battalion" 								 >$(BATTALION_IPKG_TMP)/CONTROL/control
	echo "Priority: optional" 								>>$(BATTALION_IPKG_TMP)/CONTROL/control
	echo "Section: Games" 									>>$(BATTALION_IPKG_TMP)/CONTROL/control
	echo "Maintainer: Alexander Chukov <sash@pdaXrom.org>" 					>>$(BATTALION_IPKG_TMP)/CONTROL/control
	echo "Architecture: $(SHORT_TARGET)" 							>>$(BATTALION_IPKG_TMP)/CONTROL/control
	echo "Version: $(BATTALION_VERSION)-$(BATTALION_VENDOR_VERSION)" 			>>$(BATTALION_IPKG_TMP)/CONTROL/control
	echo "Depends: mesa3d" 									>>$(BATTALION_IPKG_TMP)/CONTROL/control
	echo "Description: battalion was a game written in 1994 on a Silicon Graphics Indy in GL">>$(BATTALION_IPKG_TMP)/CONTROL/control
	cd $(FEEDDIR) && $(XMKIPKG) $(BATTALION_IPKG_TMP)
	touch $@

# ----------------------------------------------------------------------------
# Image-Install
# ----------------------------------------------------------------------------

ifdef PTXCONF_BATTALION_INSTALL
ROMPACKAGES += $(STATEDIR)/battalion.imageinstall
endif

battalion_imageinstall_deps = $(STATEDIR)/battalion.targetinstall \
	$(STATEDIR)/virtual-image.install

$(STATEDIR)/battalion.imageinstall: $(battalion_imageinstall_deps)
	@$(call targetinfo, $@)
	cd $(FEEDDIR) && $(XIPKG) install battalion
	touch $@

# ----------------------------------------------------------------------------
# Clean
# ----------------------------------------------------------------------------

battalion_clean:
	rm -rf $(STATEDIR)/battalion.*
	rm -rf $(BATTALION_DIR)

# vim: syntax=make
