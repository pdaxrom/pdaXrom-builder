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
ifdef PTXCONF_ROX-ARCHIVE
PACKAGES += rox-archive
endif

#
# Paths and names
#
ROX-ARCHIVE_VERSION	= 1.9.4
ROX-ARCHIVE		= archive-$(ROX-ARCHIVE_VERSION)
ROX-ARCHIVE_SUFFIX	= tgz
ROX-ARCHIVE_URL		= http://heanet.dl.sourceforge.net/sourceforge/rox/$(ROX-ARCHIVE).$(ROX-ARCHIVE_SUFFIX)
ROX-ARCHIVE_SOURCE	= $(SRCDIR)/$(ROX-ARCHIVE).$(ROX-ARCHIVE_SUFFIX)
ROX-ARCHIVE_DIR		= $(BUILDDIR)/$(ROX-ARCHIVE)
ROX-ARCHIVE_IPKG_TMP	= $(ROX-ARCHIVE_DIR)/ipkg_tmp

# ----------------------------------------------------------------------------
# Get
# ----------------------------------------------------------------------------

rox-archive_get: $(STATEDIR)/rox-archive.get

rox-archive_get_deps = $(ROX-ARCHIVE_SOURCE)

$(STATEDIR)/rox-archive.get: $(rox-archive_get_deps)
	@$(call targetinfo, $@)
	@$(call get_patches, $(ROX-ARCHIVE))
	touch $@

$(ROX-ARCHIVE_SOURCE):
	@$(call targetinfo, $@)
	@$(call get, $(ROX-ARCHIVE_URL))

# ----------------------------------------------------------------------------
# Extract
# ----------------------------------------------------------------------------

rox-archive_extract: $(STATEDIR)/rox-archive.extract

rox-archive_extract_deps = $(STATEDIR)/rox-archive.get

$(STATEDIR)/rox-archive.extract: $(rox-archive_extract_deps)
	@$(call targetinfo, $@)
	@$(call clean, $(ROX-ARCHIVE_DIR))
	@$(call extract, $(ROX-ARCHIVE_SOURCE))
	@$(call patchin, $(ROX-ARCHIVE))
	touch $@

# ----------------------------------------------------------------------------
# Prepare
# ----------------------------------------------------------------------------

rox-archive_prepare: $(STATEDIR)/rox-archive.prepare

#
# dependencies
#
rox-archive_prepare_deps = \
	$(STATEDIR)/rox-archive.extract \
	$(STATEDIR)/rox.install \
	$(STATEDIR)/pygtk.install \
	$(STATEDIR)/virtual-xchain.install

ROX-ARCHIVE_PATH	=  PATH=$(CROSS_PATH)
ROX-ARCHIVE_ENV 	=  $(CROSS_ENV)
#ROX-ARCHIVE_ENV	+=
ROX-ARCHIVE_ENV	+= PKG_CONFIG_PATH=$(CROSS_LIB_DIR)/lib/pkgconfig:$(CROSS_LIB_DIR)/lib/pkgconfig
#ifdef PTXCONF_XFREE430
#ROX-ARCHIVE_ENV	+= LDFLAGS=-Wl,-rpath-link,$(CROSS_LIB_DIR)/lib
#endif

#
# autoconf
#
ROX-ARCHIVE_AUTOCONF = \
	--build=$(GNU_HOST) \
	--host=$(PTXCONF_GNU_TARGET) \
	--prefix=/usr

ifdef PTXCONF_XFREE430
ROX-ARCHIVE_AUTOCONF += --x-includes=$(CROSS_LIB_DIR)/include
ROX-ARCHIVE_AUTOCONF += --x-libraries=$(CROSS_LIB_DIR)/lib
endif

$(STATEDIR)/rox-archive.prepare: $(rox-archive_prepare_deps)
	@$(call targetinfo, $@)
	@$(call clean, $(ROX-ARCHIVE_DIR)/config.cache)
	touch $@

# ----------------------------------------------------------------------------
# Compile
# ----------------------------------------------------------------------------

rox-archive_compile: $(STATEDIR)/rox-archive.compile

rox-archive_compile_deps = $(STATEDIR)/rox-archive.prepare

$(STATEDIR)/rox-archive.compile: $(rox-archive_compile_deps)
	@$(call targetinfo, $@)
	touch $@

# ----------------------------------------------------------------------------
# Install
# ----------------------------------------------------------------------------

rox-archive_install: $(STATEDIR)/rox-archive.install

$(STATEDIR)/rox-archive.install: $(STATEDIR)/rox-archive.compile
	@$(call targetinfo, $@)
	touch $@

# ----------------------------------------------------------------------------
# Target-Install
# ----------------------------------------------------------------------------

rox-archive_targetinstall: $(STATEDIR)/rox-archive.targetinstall

rox-archive_targetinstall_deps = $(STATEDIR)/rox-archive.compile \
	$(STATEDIR)/rox.targetinstall \
	$(STATEDIR)/pygtk.targetinstall

$(STATEDIR)/rox-archive.targetinstall: $(rox-archive_targetinstall_deps)
	@$(call targetinfo, $@)
	mkdir -p $(ROX-ARCHIVE_IPKG_TMP)/usr/apps
	cp -a $(ROX-ARCHIVE_DIR)/Archive $(ROX-ARCHIVE_IPKG_TMP)/usr/apps
	rm -f $(ROX-ARCHIVE_IPKG_TMP)/usr/apps/Archive/Messages/*.po
	rm -f $(ROX-ARCHIVE_IPKG_TMP)/usr/apps/Archive/Messages/*.gmo
	find $(ROX-ARCHIVE_IPKG_TMP)/usr/apps -name "CVS" | xargs rm -fr 
	mkdir -p $(ROX-ARCHIVE_IPKG_TMP)/CONTROL
	echo "Package: archive" 			>$(ROX-ARCHIVE_IPKG_TMP)/CONTROL/control
	echo "Priority: optional" 			>>$(ROX-ARCHIVE_IPKG_TMP)/CONTROL/control
	echo "Section: ROX"	 			>>$(ROX-ARCHIVE_IPKG_TMP)/CONTROL/control
	echo "Maintainer: Alexander Chukov <sash@pdaXrom.org>" >>$(ROX-ARCHIVE_IPKG_TMP)/CONTROL/control
	echo "Architecture: $(SHORT_TARGET)" 		>>$(ROX-ARCHIVE_IPKG_TMP)/CONTROL/control
	echo "Version: $(ROX-ARCHIVE_VERSION)" 		>>$(ROX-ARCHIVE_IPKG_TMP)/CONTROL/control
	echo "Depends: rox, pygtk, rox-lib" 		>>$(ROX-ARCHIVE_IPKG_TMP)/CONTROL/control
	echo "Description: ROX Create or read archive files.">>$(ROX-ARCHIVE_IPKG_TMP)/CONTROL/control
	cd $(FEEDDIR) && $(XMKIPKG) $(ROX-ARCHIVE_IPKG_TMP)
	touch $@

# ----------------------------------------------------------------------------
# Image-Install
# ----------------------------------------------------------------------------

ifdef PTXCONF_ROX-ARCHIVE_INSTALL
ROMPACKAGES += $(STATEDIR)/rox-archive.imageinstall
endif

rox-archive_imageinstall_deps = $(STATEDIR)/rox-archive.targetinstall \
	$(STATEDIR)/virtual-image.install

$(STATEDIR)/rox-archive.imageinstall: $(rox-archive_imageinstall_deps)
	@$(call targetinfo, $@)
	cd $(FEEDDIR) && $(XIPKG) install archive
	touch $@

# ----------------------------------------------------------------------------
# Clean
# ----------------------------------------------------------------------------

rox-archive_clean:
	rm -rf $(STATEDIR)/rox-archive.*
	rm -rf $(ROX-ARCHIVE_DIR)

# vim: syntax=make
