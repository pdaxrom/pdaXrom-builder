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
ifdef PTXCONF_XMMSCTRL
PACKAGES += xmmsctrl
endif

#
# Paths and names
#
XMMSCTRL_VERSION	= 1.8
XMMSCTRL		= xmmsctrl-$(XMMSCTRL_VERSION)
XMMSCTRL_SUFFIX		= tar.gz
XMMSCTRL_URL		= http://user.it.uu.se/~adavid/utils/$(XMMSCTRL).$(XMMSCTRL_SUFFIX)
XMMSCTRL_SOURCE		= $(SRCDIR)/$(XMMSCTRL).$(XMMSCTRL_SUFFIX)
XMMSCTRL_DIR		= $(BUILDDIR)/$(XMMSCTRL)
XMMSCTRL_IPKG_TMP	= $(XMMSCTRL_DIR)/ipkg_tmp

# ----------------------------------------------------------------------------
# Get
# ----------------------------------------------------------------------------

xmmsctrl_get: $(STATEDIR)/xmmsctrl.get

xmmsctrl_get_deps = $(XMMSCTRL_SOURCE)

$(STATEDIR)/xmmsctrl.get: $(xmmsctrl_get_deps)
	@$(call targetinfo, $@)
	@$(call get_patches, $(XMMSCTRL))
	touch $@

$(XMMSCTRL_SOURCE):
	@$(call targetinfo, $@)
	@$(call get, $(XMMSCTRL_URL))

# ----------------------------------------------------------------------------
# Extract
# ----------------------------------------------------------------------------

xmmsctrl_extract: $(STATEDIR)/xmmsctrl.extract

xmmsctrl_extract_deps = $(STATEDIR)/xmmsctrl.get

$(STATEDIR)/xmmsctrl.extract: $(xmmsctrl_extract_deps)
	@$(call targetinfo, $@)
	@$(call clean, $(XMMSCTRL_DIR))
	@$(call extract, $(XMMSCTRL_SOURCE))
	@$(call patchin, $(XMMSCTRL))
	touch $@

# ----------------------------------------------------------------------------
# Prepare
# ----------------------------------------------------------------------------

xmmsctrl_prepare: $(STATEDIR)/xmmsctrl.prepare

#
# dependencies
#
xmmsctrl_prepare_deps = \
	$(STATEDIR)/xmmsctrl.extract \
	$(STATEDIR)/xmms.install \
	$(STATEDIR)/virtual-xchain.install

XMMSCTRL_PATH	=  PATH=$(CROSS_PATH)
XMMSCTRL_ENV 	=  $(CROSS_ENV)
#XMMSCTRL_ENV	+=
XMMSCTRL_ENV	+= PKG_CONFIG_PATH=$(CROSS_LIB_DIR)/lib/pkgconfig:$(CROSS_LIB_DIR)/lib/pkgconfig
#ifdef PTXCONF_XFREE430
#XMMSCTRL_ENV	+= LDFLAGS=-Wl,-rpath-link,$(CROSS_LIB_DIR)/lib
#endif

#
# autoconf
#
XMMSCTRL_AUTOCONF = \
	--build=$(GNU_HOST) \
	--host=$(PTXCONF_GNU_TARGET) \
	--prefix=/usr

ifdef PTXCONF_XFREE430
XMMSCTRL_AUTOCONF += --x-includes=$(CROSS_LIB_DIR)/include
XMMSCTRL_AUTOCONF += --x-libraries=$(CROSS_LIB_DIR)/lib
endif

$(STATEDIR)/xmmsctrl.prepare: $(xmmsctrl_prepare_deps)
	@$(call targetinfo, $@)
	@$(call clean, $(XMMSCTRL_DIR)/config.cache)
	#cd $(XMMSCTRL_DIR) && \
	#	$(XMMSCTRL_PATH) $(XMMSCTRL_ENV) \
	#	./configure $(XMMSCTRL_AUTOCONF)
	touch $@

# ----------------------------------------------------------------------------
# Compile
# ----------------------------------------------------------------------------

xmmsctrl_compile: $(STATEDIR)/xmmsctrl.compile

xmmsctrl_compile_deps = $(STATEDIR)/xmmsctrl.prepare

$(STATEDIR)/xmmsctrl.compile: $(xmmsctrl_compile_deps)
	@$(call targetinfo, $@)
	$(XMMSCTRL_PATH) $(MAKE) -C $(XMMSCTRL_DIR) $(CROSS_ENV_CC)
	touch $@

# ----------------------------------------------------------------------------
# Install
# ----------------------------------------------------------------------------

xmmsctrl_install: $(STATEDIR)/xmmsctrl.install

$(STATEDIR)/xmmsctrl.install: $(STATEDIR)/xmmsctrl.compile
	@$(call targetinfo, $@)
	touch $@

# ----------------------------------------------------------------------------
# Target-Install
# ----------------------------------------------------------------------------

xmmsctrl_targetinstall: $(STATEDIR)/xmmsctrl.targetinstall

xmmsctrl_targetinstall_deps = $(STATEDIR)/xmmsctrl.compile \
	$(STATEDIR)/xmms.targetinstall

$(STATEDIR)/xmmsctrl.targetinstall: $(xmmsctrl_targetinstall_deps)
	@$(call targetinfo, $@)
	###$(XMMSCTRL_PATH) $(MAKE) -C $(XMMSCTRL_DIR) DESTDIR=$(XMMSCTRL_IPKG_TMP) install
	$(INSTALL) -D -m 755 $(XMMSCTRL_DIR)/xmmsctrl $(XMMSCTRL_IPKG_TMP)/usr/bin/xmmsctrl
	mkdir -p $(XMMSCTRL_IPKG_TMP)/CONTROL
	echo "Package: xmmsctrl" 								>$(XMMSCTRL_IPKG_TMP)/CONTROL/control
	echo "Priority: optional" 								>>$(XMMSCTRL_IPKG_TMP)/CONTROL/control
	echo "Section: Multimedia" 								>>$(XMMSCTRL_IPKG_TMP)/CONTROL/control
	echo "Maintainer: Alexander Chukov <sash@pdaXrom.org>" 					>>$(XMMSCTRL_IPKG_TMP)/CONTROL/control
	echo "Architecture: $(SHORT_TARGET)" 							>>$(XMMSCTRL_IPKG_TMP)/CONTROL/control
	echo "Version: $(XMMSCTRL_VERSION)" 							>>$(XMMSCTRL_IPKG_TMP)/CONTROL/control
	echo "Depends: xmms"					 				>>$(XMMSCTRL_IPKG_TMP)/CONTROL/control
	echo "Description: control xmms from the command line"					>>$(XMMSCTRL_IPKG_TMP)/CONTROL/control
	cd $(FEEDDIR) && $(XMKIPKG) $(XMMSCTRL_IPKG_TMP)
	touch $@

# ----------------------------------------------------------------------------
# Image-Install
# ----------------------------------------------------------------------------

ifdef PTXCONF_XMMSCTRL_INSTALL
ROMPACKAGES += $(STATEDIR)/xmmsctrl.imageinstall
endif

xmmsctrl_imageinstall_deps = $(STATEDIR)/xmmsctrl.targetinstall \
	$(STATEDIR)/virtual-image.install

$(STATEDIR)/xmmsctrl.imageinstall: $(xmmsctrl_imageinstall_deps)
	@$(call targetinfo, $@)
	cd $(FEEDDIR) && $(XIPKG) install xmmsctrl
	touch $@

# ----------------------------------------------------------------------------
# Clean
# ----------------------------------------------------------------------------

xmmsctrl_clean:
	rm -rf $(STATEDIR)/xmmsctrl.*
	rm -rf $(XMMSCTRL_DIR)

# vim: syntax=make
