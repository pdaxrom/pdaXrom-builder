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
ifdef PTXCONF_XMMSPIPE
PACKAGES += xmmspipe
endif

#
# Paths and names
#
XMMSPIPE_VERSION	= 0.5.4
XMMSPIPE		= xmmspipe-$(XMMSPIPE_VERSION)
XMMSPIPE_SUFFIX		= tgz
XMMSPIPE_URL		= http://rooster.stanford.edu/~ben/xmmspipe/$(XMMSPIPE).$(XMMSPIPE_SUFFIX)
XMMSPIPE_SOURCE		= $(SRCDIR)/$(XMMSPIPE).$(XMMSPIPE_SUFFIX)
XMMSPIPE_DIR		= $(BUILDDIR)/$(XMMSPIPE)
XMMSPIPE_IPKG_TMP	= $(XMMSPIPE_DIR)/ipkg_tmp

# ----------------------------------------------------------------------------
# Get
# ----------------------------------------------------------------------------

xmmspipe_get: $(STATEDIR)/xmmspipe.get

xmmspipe_get_deps = $(XMMSPIPE_SOURCE)

$(STATEDIR)/xmmspipe.get: $(xmmspipe_get_deps)
	@$(call targetinfo, $@)
	@$(call get_patches, $(XMMSPIPE))
	touch $@

$(XMMSPIPE_SOURCE):
	@$(call targetinfo, $@)
	@$(call get, $(XMMSPIPE_URL))

# ----------------------------------------------------------------------------
# Extract
# ----------------------------------------------------------------------------

xmmspipe_extract: $(STATEDIR)/xmmspipe.extract

xmmspipe_extract_deps = $(STATEDIR)/xmmspipe.get

$(STATEDIR)/xmmspipe.extract: $(xmmspipe_extract_deps)
	@$(call targetinfo, $@)
	@$(call clean, $(XMMSPIPE_DIR))
	@$(call extract, $(XMMSPIPE_SOURCE))
	@$(call patchin, $(XMMSPIPE))
	touch $@

# ----------------------------------------------------------------------------
# Prepare
# ----------------------------------------------------------------------------

xmmspipe_prepare: $(STATEDIR)/xmmspipe.prepare

#
# dependencies
#
xmmspipe_prepare_deps = \
	$(STATEDIR)/xmmspipe.extract \
	$(STATEDIR)/xmms.install \
	$(STATEDIR)/virtual-xchain.install

XMMSPIPE_PATH	=  PATH=$(CROSS_PATH)
XMMSPIPE_ENV 	=  $(CROSS_ENV)
#XMMSPIPE_ENV	+=
XMMSPIPE_ENV	+= PKG_CONFIG_PATH=$(CROSS_LIB_DIR)/lib/pkgconfig:$(CROSS_LIB_DIR)/lib/pkgconfig
#ifdef PTXCONF_XFREE430
#XMMSPIPE_ENV	+= LDFLAGS=-Wl,-rpath-link,$(CROSS_LIB_DIR)/lib
#endif

#
# autoconf
#
XMMSPIPE_AUTOCONF = \
	--build=$(GNU_HOST) \
	--host=$(PTXCONF_GNU_TARGET) \
	--prefix=/usr

ifdef PTXCONF_XFREE430
XMMSPIPE_AUTOCONF += --x-includes=$(CROSS_LIB_DIR)/include
XMMSPIPE_AUTOCONF += --x-libraries=$(CROSS_LIB_DIR)/lib
endif

$(STATEDIR)/xmmspipe.prepare: $(xmmspipe_prepare_deps)
	@$(call targetinfo, $@)
	@$(call clean, $(XMMSPIPE_DIR)/config.cache)
	#cd $(XMMSPIPE_DIR) && \
	#	$(XMMSPIPE_PATH) $(XMMSPIPE_ENV) \
	#	./configure $(XMMSPIPE_AUTOCONF)
	touch $@

# ----------------------------------------------------------------------------
# Compile
# ----------------------------------------------------------------------------

xmmspipe_compile: $(STATEDIR)/xmmspipe.compile

xmmspipe_compile_deps = $(STATEDIR)/xmmspipe.prepare

$(STATEDIR)/xmmspipe.compile: $(xmmspipe_compile_deps)
	@$(call targetinfo, $@)
	$(XMMSPIPE_PATH) $(MAKE) -C $(XMMSPIPE_DIR) $(CROSS_ENV_CC)
	touch $@

# ----------------------------------------------------------------------------
# Install
# ----------------------------------------------------------------------------

xmmspipe_install: $(STATEDIR)/xmmspipe.install

$(STATEDIR)/xmmspipe.install: $(STATEDIR)/xmmspipe.compile
	@$(call targetinfo, $@)
	$(XMMSPIPE_PATH) $(MAKE) -C $(XMMSPIPE_DIR) install
	touch $@

# ----------------------------------------------------------------------------
# Target-Install
# ----------------------------------------------------------------------------

xmmspipe_targetinstall: $(STATEDIR)/xmmspipe.targetinstall

xmmspipe_targetinstall_deps = $(STATEDIR)/xmmspipe.compile \
	$(STATEDIR)/xmms.targetinstall

$(STATEDIR)/xmmspipe.targetinstall: $(xmmspipe_targetinstall_deps)
	@$(call targetinfo, $@)
	$(XMMSPIPE_PATH) $(MAKE) -C $(XMMSPIPE_DIR) INSTALLPATH=$(XMMSPIPE_IPKG_TMP)/usr/lib/xmms/General install
	$(CROSSSTRIP) $(XMMSPIPE_IPKG_TMP)/usr/lib/xmms/General/*
	mkdir -p $(XMMSPIPE_IPKG_TMP)/CONTROL
	echo "Package: xmmspipe" 							>$(XMMSPIPE_IPKG_TMP)/CONTROL/control
	echo "Priority: optional" 							>>$(XMMSPIPE_IPKG_TMP)/CONTROL/control
	echo "Section: Multimedia"				 			>>$(XMMSPIPE_IPKG_TMP)/CONTROL/control
	echo "Maintainer: Alexander Chukov <sash@pdaXrom.org>" 				>>$(XMMSPIPE_IPKG_TMP)/CONTROL/control
	echo "Architecture: $(SHORT_TARGET)" 						>>$(XMMSPIPE_IPKG_TMP)/CONTROL/control
	echo "Version: $(XMMSPIPE_VERSION)" 						>>$(XMMSPIPE_IPKG_TMP)/CONTROL/control
	echo "Depends: xmms" 								>>$(XMMSPIPE_IPKG_TMP)/CONTROL/control
	echo "Description: Control xmms by sending string to a named pipe (FIFO)"	>>$(XMMSPIPE_IPKG_TMP)/CONTROL/control
	cd $(FEEDDIR) && $(XMKIPKG) $(XMMSPIPE_IPKG_TMP)
	touch $@

# ----------------------------------------------------------------------------
# Image-Install
# ----------------------------------------------------------------------------

ifdef PTXCONF_XMMSPIPE_INSTALL
ROMPACKAGES += $(STATEDIR)/xmmspipe.imageinstall
endif

xmmspipe_imageinstall_deps = $(STATEDIR)/xmmspipe.targetinstall \
	$(STATEDIR)/virtual-image.install

$(STATEDIR)/xmmspipe.imageinstall: $(xmmspipe_imageinstall_deps)
	@$(call targetinfo, $@)
	cd $(FEEDDIR) && $(XIPKG) install xmmspipe
	touch $@

# ----------------------------------------------------------------------------
# Clean
# ----------------------------------------------------------------------------

xmmspipe_clean:
	rm -rf $(STATEDIR)/xmmspipe.*
	rm -rf $(XMMSPIPE_DIR)

# vim: syntax=make
