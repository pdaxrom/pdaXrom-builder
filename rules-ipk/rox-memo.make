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
ifdef PTXCONF_ROX-MEMO
PACKAGES += rox-memo
endif

#
# Paths and names
#
ROX-MEMO_VERSION	= 1.9.4
ROX-MEMO		= memo-$(ROX-MEMO_VERSION)
ROX-MEMO_SUFFIX		= tgz
ROX-MEMO_URL		= http://heanet.dl.sourceforge.net/sourceforge/rox/$(ROX-MEMO).$(ROX-MEMO_SUFFIX)
ROX-MEMO_SOURCE		= $(SRCDIR)/$(ROX-MEMO).$(ROX-MEMO_SUFFIX)
ROX-MEMO_DIR		= $(BUILDDIR)/$(ROX-MEMO)
ROX-MEMO_IPKG_TMP	= $(ROX-MEMO_DIR)/ipkg_tmp

# ----------------------------------------------------------------------------
# Get
# ----------------------------------------------------------------------------

rox-memo_get: $(STATEDIR)/rox-memo.get

rox-memo_get_deps = $(ROX-MEMO_SOURCE)

$(STATEDIR)/rox-memo.get: $(rox-memo_get_deps)
	@$(call targetinfo, $@)
	@$(call get_patches, $(ROX-MEMO))
	touch $@

$(ROX-MEMO_SOURCE):
	@$(call targetinfo, $@)
	@$(call get, $(ROX-MEMO_URL))

# ----------------------------------------------------------------------------
# Extract
# ----------------------------------------------------------------------------

rox-memo_extract: $(STATEDIR)/rox-memo.extract

rox-memo_extract_deps = $(STATEDIR)/rox-memo.get

$(STATEDIR)/rox-memo.extract: $(rox-memo_extract_deps)
	@$(call targetinfo, $@)
	@$(call clean, $(ROX-MEMO_DIR))
	@$(call extract, $(ROX-MEMO_SOURCE))
	@$(call patchin, $(ROX-MEMO))
	touch $@

# ----------------------------------------------------------------------------
# Prepare
# ----------------------------------------------------------------------------

rox-memo_prepare: $(STATEDIR)/rox-memo.prepare

#
# dependencies
#
rox-memo_prepare_deps = \
	$(STATEDIR)/rox-memo.extract \
	$(STATEDIR)/rox.install \
	$(STATEDIR)/pygtk.install \
	$(STATEDIR)/virtual-xchain.install

ROX-MEMO_PATH	=  PATH=$(CROSS_PATH)
ROX-MEMO_ENV 	=  $(CROSS_ENV)
#ROX-MEMO_ENV	+=
ROX-MEMO_ENV	+= PKG_CONFIG_PATH=$(CROSS_LIB_DIR)/lib/pkgconfig:$(CROSS_LIB_DIR)/lib/pkgconfig
#ifdef PTXCONF_XFREE430
#ROX-MEMO_ENV	+= LDFLAGS=-Wl,-rpath-link,$(CROSS_LIB_DIR)/lib
#endif

#
# autoconf
#
ROX-MEMO_AUTOCONF = \
	--build=$(GNU_HOST) \
	--host=$(PTXCONF_GNU_TARGET) \
	--prefix=/usr

ifdef PTXCONF_XFREE430
ROX-MEMO_AUTOCONF += --x-includes=$(CROSS_LIB_DIR)/include
ROX-MEMO_AUTOCONF += --x-libraries=$(CROSS_LIB_DIR)/lib
endif

$(STATEDIR)/rox-memo.prepare: $(rox-memo_prepare_deps)
	@$(call targetinfo, $@)
	@$(call clean, $(ROX-MEMO_DIR)/config.cache)
	touch $@

# ----------------------------------------------------------------------------
# Compile
# ----------------------------------------------------------------------------

rox-memo_compile: $(STATEDIR)/rox-memo.compile

rox-memo_compile_deps = $(STATEDIR)/rox-memo.prepare

$(STATEDIR)/rox-memo.compile: $(rox-memo_compile_deps)
	@$(call targetinfo, $@)
	touch $@

# ----------------------------------------------------------------------------
# Install
# ----------------------------------------------------------------------------

rox-memo_install: $(STATEDIR)/rox-memo.install

$(STATEDIR)/rox-memo.install: $(STATEDIR)/rox-memo.compile
	@$(call targetinfo, $@)
	touch $@

# ----------------------------------------------------------------------------
# Target-Install
# ----------------------------------------------------------------------------

rox-memo_targetinstall: $(STATEDIR)/rox-memo.targetinstall

rox-memo_targetinstall_deps = $(STATEDIR)/rox-memo.compile \
	$(STATEDIR)/rox.targetinstall \
	$(STATEDIR)/pygtk.targetinstall

$(STATEDIR)/rox-memo.targetinstall: $(rox-memo_targetinstall_deps)
	@$(call targetinfo, $@)
	mkdir -p $(ROX-MEMO_IPKG_TMP)/usr/apps
	cp -a $(ROX-MEMO_DIR)/Memo $(ROX-MEMO_IPKG_TMP)/usr/apps
	rm -f $(ROX-MEMO_IPKG_TMP)/usr/apps/Memo/Messages/*.po
	rm -f $(ROX-MEMO_IPKG_TMP)/usr/apps/Memo/Messages/*.gmo
	find  $(ROX-MEMO_IPKG_TMP)/usr/apps -name "CVS" | xargs rm -fr 
	mkdir -p $(ROX-MEMO_IPKG_TMP)/CONTROL
	echo "Package: memo" 				>$(ROX-MEMO_IPKG_TMP)/CONTROL/control
	echo "Priority: optional" 			>>$(ROX-MEMO_IPKG_TMP)/CONTROL/control
	echo "Section: ROX"	 			>>$(ROX-MEMO_IPKG_TMP)/CONTROL/control
	echo "Maintainer: Alexander Chukov <sash@pdaXrom.org>">>$(ROX-MEMO_IPKG_TMP)/CONTROL/control
	echo "Architecture: $(SHORT_TARGET)" 		>>$(ROX-MEMO_IPKG_TMP)/CONTROL/control
	echo "Version: $(ROX-MEMO_VERSION)" 		>>$(ROX-MEMO_IPKG_TMP)/CONTROL/control
	echo "Depends: rox, pygtk, rox-lib" 		>>$(ROX-MEMO_IPKG_TMP)/CONTROL/control
	echo "Description: Shows the time and lets you set memos and alarms">>$(ROX-MEMO_IPKG_TMP)/CONTROL/control
	cd $(FEEDDIR) && $(XMKIPKG) $(ROX-MEMO_IPKG_TMP)
	touch $@

# ----------------------------------------------------------------------------
# Image-Install
# ----------------------------------------------------------------------------

ifdef PTXCONF_ROX-MEMO_INSTALL
ROMPACKAGES += $(STATEDIR)/rox-memo.imageinstall
endif

rox-memo_imageinstall_deps = $(STATEDIR)/rox-memo.targetinstall \
	$(STATEDIR)/virtual-image.install

$(STATEDIR)/rox-memo.imageinstall: $(rox-memo_imageinstall_deps)
	@$(call targetinfo, $@)
	cd $(FEEDDIR) && $(XIPKG) install memo
	touch $@

# ----------------------------------------------------------------------------
# Clean
# ----------------------------------------------------------------------------

rox-memo_clean:
	rm -rf $(STATEDIR)/rox-memo.*
	rm -rf $(ROX-MEMO_DIR)

# vim: syntax=make
