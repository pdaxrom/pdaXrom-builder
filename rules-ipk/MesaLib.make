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
ifdef PTXCONF_MESALIB
PACKAGES += MesaLib
endif

#
# Paths and names
#
MESALIB_VENDOR_VERSION	= 1
MESALIB_VERSION		= 6.2.1
MESALIB			= MesaLib-$(MESALIB_VERSION)
MESADEMOS		= MesaDemos-$(MESALIB_VERSION)
MESALIB_SUFFIX		= tar.bz2
MESALIB_URL		= http://aleron.dl.sourceforge.net/sourceforge/mesa3d/$(MESALIB).$(MESALIB_SUFFIX)
MESALIB_URL1		= http://aleron.dl.sourceforge.net/sourceforge/mesa3d/$(MESADEMOS).$(MESALIB_SUFFIX)
MESALIB_SOURCE		= $(SRCDIR)/$(MESALIB).$(MESALIB_SUFFIX)
MESALIB_SOURCE1		= $(SRCDIR)/$(MESADEMOS).$(MESALIB_SUFFIX)
MESALIB_DIR		= $(BUILDDIR)/Mesa-$(MESALIB_VERSION)
MESALIB_IPKG_TMP	= $(MESALIB_DIR)/ipkg_tmp

# ----------------------------------------------------------------------------
# Get
# ----------------------------------------------------------------------------

MesaLib_get: $(STATEDIR)/MesaLib.get

MesaLib_get_deps = $(MESALIB_SOURCE) $(MESALIB_SOURCE1)

$(STATEDIR)/MesaLib.get: $(MesaLib_get_deps)
	@$(call targetinfo, $@)
	@$(call get_patches, $(MESALIB))
	touch $@

$(MESALIB_SOURCE):
	@$(call targetinfo, $@)
	@$(call get, $(MESALIB_URL))

$(MESALIB_SOURCE1):
	@$(call targetinfo, $@)
	@$(call get, $(MESALIB_URL1))

# ----------------------------------------------------------------------------
# Extract
# ----------------------------------------------------------------------------

MesaLib_extract: $(STATEDIR)/MesaLib.extract

MesaLib_extract_deps = $(STATEDIR)/MesaLib.get

$(STATEDIR)/MesaLib.extract: $(MesaLib_extract_deps)
	@$(call targetinfo, $@)
	@$(call clean,   $(MESALIB_DIR))
	@$(call extract, $(MESALIB_SOURCE))
	@$(call extract, $(MESALIB_SOURCE1))
	@$(call patchin, $(MESALIB), $(MESALIB_DIR))
	touch $@

# ----------------------------------------------------------------------------
# Prepare
# ----------------------------------------------------------------------------

MesaLib_prepare: $(STATEDIR)/MesaLib.prepare

#
# dependencies
#
MesaLib_prepare_deps = \
	$(STATEDIR)/MesaLib.extract \
	$(STATEDIR)/xfree430.install \
	$(STATEDIR)/virtual-xchain.install

MESALIB_PATH	=  PATH=$(CROSS_PATH)
MESALIB_ENV 	=  $(CROSS_ENV)
#MESALIB_ENV	+=
MESALIB_ENV	+= PKG_CONFIG_PATH=$(CROSS_LIB_DIR)/lib/pkgconfig:$(CROSS_LIB_DIR)/lib/pkgconfig
#ifdef PTXCONF_XFREE430
#MESALIB_ENV	+= LDFLAGS=-Wl,-rpath-link,$(CROSS_LIB_DIR)/lib
#endif

#
# autoconf
#
MESALIB_AUTOCONF = \
	--build=$(GNU_HOST) \
	--host=$(PTXCONF_GNU_TARGET) \
	--prefix=/usr

ifdef PTXCONF_XFREE430
MESALIB_AUTOCONF += --x-includes=$(CROSS_LIB_DIR)/include
MESALIB_AUTOCONF += --x-libraries=$(CROSS_LIB_DIR)/lib
endif

$(STATEDIR)/MesaLib.prepare: $(MesaLib_prepare_deps)
	@$(call targetinfo, $@)
	@$(call clean, $(MESALIB_DIR)/config.cache)
	#cd $(MESALIB_DIR) && \
	#	$(MESALIB_PATH) $(MESALIB_ENV) \
	#	./configure $(MESALIB_AUTOCONF)
	touch $@

# ----------------------------------------------------------------------------
# Compile
# ----------------------------------------------------------------------------

MesaLib_compile: $(STATEDIR)/MesaLib.compile

MesaLib_compile_deps = $(STATEDIR)/MesaLib.prepare

$(STATEDIR)/MesaLib.compile: $(MesaLib_compile_deps)
	@$(call targetinfo, $@)
	$(MESALIB_PATH) $(MAKE) -C $(MESALIB_DIR) linux \
	    $(CROSS_ENV_CC) $(CROSS_ENV_CXX) X11_INC=$(CROSS_LIB_DIR)/lib X11_LIB=$(CROSS_LIB_DIR)/lib
	touch $@

# ----------------------------------------------------------------------------
# Install
# ----------------------------------------------------------------------------

MesaLib_install: $(STATEDIR)/MesaLib.install

$(STATEDIR)/MesaLib.install: $(STATEDIR)/MesaLib.compile
	@$(call targetinfo, $@)
	###$(MESALIB_PATH) $(MAKE) -C $(MESALIB_DIR) install
	cp -a $(MESALIB_DIR)/include/*	$(CROSS_LIB_DIR)/include/
	cp -a $(MESALIB_DIR)/lib/*	$(CROSS_LIB_DIR)/lib/
	touch $@

# ----------------------------------------------------------------------------
# Target-Install
# ----------------------------------------------------------------------------

MesaLib_targetinstall: $(STATEDIR)/MesaLib.targetinstall

MesaLib_targetinstall_deps = $(STATEDIR)/MesaLib.compile

$(STATEDIR)/MesaLib.targetinstall: $(MesaLib_targetinstall_deps)
	@$(call targetinfo, $@)
	###$(MESALIB_PATH) $(MAKE) -C $(MESALIB_DIR) DESTDIR=$(MESALIB_IPKG_TMP) install
	mkdir -p $(MESALIB_IPKG_TMP)/usr/{bin,lib}
	cp -a $(MESALIB_DIR)/progs/xdemos/{glxgears,glxinfo} $(MESALIB_IPKG_TMP)/usr/bin/
	cp -a $(MESALIB_DIR)/lib/*	$(MESALIB_IPKG_TMP)/usr/lib/
	$(CROSSSTRIP) 			$(MESALIB_IPKG_TMP)/usr/bin/*
	$(CROSSSTRIP) 			$(MESALIB_IPKG_TMP)/usr/lib/*.so*
	mkdir -p $(MESALIB_IPKG_TMP)/CONTROL
	echo "Package: mesa3d"	 							 >$(MESALIB_IPKG_TMP)/CONTROL/control
	echo "Priority: optional" 							>>$(MESALIB_IPKG_TMP)/CONTROL/control
	echo "Section: X11" 								>>$(MESALIB_IPKG_TMP)/CONTROL/control
	echo "Maintainer: Alexander Chukov <sash@pdaXrom.org>" 				>>$(MESALIB_IPKG_TMP)/CONTROL/control
	echo "Architecture: $(SHORT_TARGET)" 						>>$(MESALIB_IPKG_TMP)/CONTROL/control
	echo "Version: $(MESALIB_VERSION)-$(MESALIB_VENDOR_VERSION)" 			>>$(MESALIB_IPKG_TMP)/CONTROL/control
	echo "Depends: xfree430" 							>>$(MESALIB_IPKG_TMP)/CONTROL/control
	echo "Description: Mesa is a 3-D graphics library with an API which is very similar to that of OpenGL">>$(MESALIB_IPKG_TMP)/CONTROL/control
	cd $(FEEDDIR) && $(XMKIPKG) $(MESALIB_IPKG_TMP)
	touch $@

# ----------------------------------------------------------------------------
# Image-Install
# ----------------------------------------------------------------------------

ifdef PTXCONF_MESALIB_INSTALL
ROMPACKAGES += $(STATEDIR)/MesaLib.imageinstall
endif

MesaLib_imageinstall_deps = $(STATEDIR)/MesaLib.targetinstall \
	$(STATEDIR)/virtual-image.install

$(STATEDIR)/MesaLib.imageinstall: $(MesaLib_imageinstall_deps)
	@$(call targetinfo, $@)
	cd $(FEEDDIR) && $(XIPKG) install mesa3d
	touch $@

# ----------------------------------------------------------------------------
# Clean
# ----------------------------------------------------------------------------

MesaLib_clean:
	rm -rf $(STATEDIR)/MesaLib.*
	rm -rf $(MESALIB_DIR)

# vim: syntax=make
