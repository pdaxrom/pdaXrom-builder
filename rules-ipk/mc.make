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
ifdef PTXCONF_MC
PACKAGES += mc
endif

#
# Paths and names
#
MC_VERSION	= 4.6.1-pre1
MC		= mc-$(MC_VERSION)
MC_SUFFIX	= tar.gz
MC_URL		= http://www.ibiblio.org/pub/Linux/utils/file/managers/mc/$(MC).$(MC_SUFFIX)
MC_SOURCE	= $(SRCDIR)/$(MC).$(MC_SUFFIX)
MC_DIR		= $(BUILDDIR)/$(MC)
MC_IPKG_TMP	= $(MC_DIR)/ipkg_tmp

# ----------------------------------------------------------------------------
# Get
# ----------------------------------------------------------------------------

mc_get: $(STATEDIR)/mc.get

mc_get_deps = $(MC_SOURCE)

$(STATEDIR)/mc.get: $(mc_get_deps)
	@$(call targetinfo, $@)
	@$(call get_patches, $(MC))
	touch $@

$(MC_SOURCE):
	@$(call targetinfo, $@)
	@$(call get, $(MC_URL))

# ----------------------------------------------------------------------------
# Extract
# ----------------------------------------------------------------------------

mc_extract: $(STATEDIR)/mc.extract

mc_extract_deps = $(STATEDIR)/mc.get

$(STATEDIR)/mc.extract: $(mc_extract_deps)
	@$(call targetinfo, $@)
	@$(call clean, $(MC_DIR))
	@$(call extract, $(MC_SOURCE))
	@$(call patchin, $(MC))
	touch $@

# ----------------------------------------------------------------------------
# Prepare
# ----------------------------------------------------------------------------

mc_prepare: $(STATEDIR)/mc.prepare

#
# dependencies
#
mc_prepare_deps = \
	$(STATEDIR)/mc.extract \
	$(STATEDIR)/glib22.install \
	$(STATEDIR)/virtual-xchain.install

MC_PATH	=  PATH=$(CROSS_PATH)
MC_ENV 	=  $(CROSS_ENV)
#MC_ENV	+=
MC_ENV	+= PKG_CONFIG_PATH=$(CROSS_LIB_DIR)/lib/pkgconfig:$(CROSS_LIB_DIR)/lib/pkgconfig
#ifdef PTXCONF_XFREE430
#MC_ENV	+= LDFLAGS=-Wl,-rpath-link,$(CROSS_LIB_DIR)/lib
#endif

#
# autoconf
#
MC_AUTOCONF = \
	--build=$(GNU_HOST) \
	--host=$(PTXCONF_GNU_TARGET) \
	--prefix=/usr

ifdef PTXCONF_XFREE430
MC_AUTOCONF += --x-includes=$(CROSS_LIB_DIR)/include
MC_AUTOCONF += --x-libraries=$(CROSS_LIB_DIR)/lib
else
MC_AUTOCONF += --without-x
endif

$(STATEDIR)/mc.prepare: $(mc_prepare_deps)
	@$(call targetinfo, $@)
	@$(call clean, $(MC_DIR)/config.cache)
	cd $(MC_DIR) && \
		$(MC_PATH) $(MC_ENV) \
		./configure $(MC_AUTOCONF)
	touch $@

# ----------------------------------------------------------------------------
# Compile
# ----------------------------------------------------------------------------

mc_compile: $(STATEDIR)/mc.compile

mc_compile_deps = $(STATEDIR)/mc.prepare

$(STATEDIR)/mc.compile: $(mc_compile_deps)
	@$(call targetinfo, $@)
	$(MC_PATH) $(MAKE) -C $(MC_DIR)
	rm -f $(MC_DIR)/src/man2hlp $(MC_DIR)/src/man2hlp.o
	gcc `pkg-config glib-2.0 --cflags --libs` -I$(MC_DIR) \
	    $(MC_DIR)/src/man2hlp.c -o $(MC_DIR)/src/man2hlp
	$(MC_PATH) $(MAKE) -C $(MC_DIR)/doc
	touch $@

# ----------------------------------------------------------------------------
# Install
# ----------------------------------------------------------------------------

mc_install: $(STATEDIR)/mc.install

$(STATEDIR)/mc.install: $(STATEDIR)/mc.compile
	@$(call targetinfo, $@)
	###$(MC_PATH) $(MAKE) -C $(MC_DIR) install
	touch $@

# ----------------------------------------------------------------------------
# Target-Install
# ----------------------------------------------------------------------------

mc_targetinstall: $(STATEDIR)/mc.targetinstall

mc_targetinstall_deps = $(STATEDIR)/mc.compile \
	$(STATEDIR)/glib22.targetinstall

$(STATEDIR)/mc.targetinstall: $(mc_targetinstall_deps)
	@$(call targetinfo, $@)
	$(MC_PATH) $(MAKE) -C $(MC_DIR) DESTDIR=$(MC_IPKG_TMP) install
	$(CROSSSTRIP) $(MC_IPKG_TMP)/usr/bin/mc
	$(CROSSSTRIP) $(MC_IPKG_TMP)/usr/bin/mcmfmt
	$(CROSSSTRIP) $(MC_IPKG_TMP)/usr/lib/mc/cons.saver
	rm -rf $(MC_IPKG_TMP)/usr/man $(MC_IPKG_TMP)/usr/share/locale
	mkdir -p $(MC_IPKG_TMP)/CONTROL
	echo "Package: mc" 				>$(MC_IPKG_TMP)/CONTROL/control
	echo "Priority: optional" 			>>$(MC_IPKG_TMP)/CONTROL/control
	echo "Section: pdaXrom" 			>>$(MC_IPKG_TMP)/CONTROL/control
	echo "Maintainer: Alexander Chukov <sash@pdaXrom.org>">>$(MC_IPKG_TMP)/CONTROL/control
	echo "Architecture: $(SHORT_TARGET)" 		>>$(MC_IPKG_TMP)/CONTROL/control
	echo "Version: $(MC_VERSION)" 			>>$(MC_IPKG_TMP)/CONTROL/control
	echo "Depends: glib2" 				>>$(MC_IPKG_TMP)/CONTROL/control
	echo "Description: GNU Midnight Commander is a file manager for free operating systems.">>$(MC_IPKG_TMP)/CONTROL/control
	cd $(FEEDDIR) && $(XMKIPKG) $(MC_IPKG_TMP)
	touch $@

# ----------------------------------------------------------------------------
# Image-Install
# ----------------------------------------------------------------------------

ifdef PTXCONF_MC_INSTALL
ROMPACKAGES += $(STATEDIR)/mc.imageinstall
endif

mc_imageinstall_deps = $(STATEDIR)/mc.targetinstall \
	$(STATEDIR)/virtual-image.install

$(STATEDIR)/mc.imageinstall: $(mc_imageinstall_deps)
	@$(call targetinfo, $@)
	cd $(FEEDDIR) && $(XIPKG) install mc
	touch $@

# ----------------------------------------------------------------------------
# Clean
# ----------------------------------------------------------------------------

mc_clean:
	rm -rf $(STATEDIR)/mc.*
	rm -rf $(MC_DIR)

# vim: syntax=make
