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
ifdef PTXCONF_FINDUTILS
PACKAGES += findutils
endif

#
# Paths and names
#
FINDUTILS_VERSION	= 4.1
FINDUTILS		= findutils-$(FINDUTILS_VERSION)
FINDUTILS_SUFFIX	= tar.gz
FINDUTILS_URL		= http://ftp.gnu.org/pub/gnu/findutils/$(FINDUTILS).$(FINDUTILS_SUFFIX)
FINDUTILS_SOURCE	= $(SRCDIR)/$(FINDUTILS).$(FINDUTILS_SUFFIX)
FINDUTILS_DIR		= $(BUILDDIR)/$(FINDUTILS)
FINDUTILS_IPKG_TMP	= $(FINDUTILS_DIR)/ipkg_tmp

# ----------------------------------------------------------------------------
# Get
# ----------------------------------------------------------------------------

findutils_get: $(STATEDIR)/findutils.get

findutils_get_deps = $(FINDUTILS_SOURCE)

$(STATEDIR)/findutils.get: $(findutils_get_deps)
	@$(call targetinfo, $@)
	@$(call get_patches, $(FINDUTILS))
	touch $@

$(FINDUTILS_SOURCE):
	@$(call targetinfo, $@)
	@$(call get, $(FINDUTILS_URL))

# ----------------------------------------------------------------------------
# Extract
# ----------------------------------------------------------------------------

findutils_extract: $(STATEDIR)/findutils.extract

findutils_extract_deps = $(STATEDIR)/findutils.get

$(STATEDIR)/findutils.extract: $(findutils_extract_deps)
	@$(call targetinfo, $@)
	@$(call clean, $(FINDUTILS_DIR))
	@$(call extract, $(FINDUTILS_SOURCE))
	@$(call patchin, $(FINDUTILS))
	touch $@

# ----------------------------------------------------------------------------
# Prepare
# ----------------------------------------------------------------------------

findutils_prepare: $(STATEDIR)/findutils.prepare

#
# dependencies
#
findutils_prepare_deps = \
	$(STATEDIR)/findutils.extract \
	$(STATEDIR)/virtual-xchain.install

FINDUTILS_PATH	=  PATH=$(CROSS_PATH)
FINDUTILS_ENV 	=  $(CROSS_ENV)
#FINDUTILS_ENV	+=
FINDUTILS_ENV	+= PKG_CONFIG_PATH=$(CROSS_LIB_DIR)/lib/pkgconfig:$(CROSS_LIB_DIR)/lib/pkgconfig
#ifdef PTXCONF_XFREE430
#FINDUTILS_ENV	+= LDFLAGS=-Wl,-rpath-link,$(CROSS_LIB_DIR)/lib
#endif

#
# autoconf
#
FINDUTILS_AUTOCONF = \
	--build=$(GNU_HOST) \
	--host=$(PTXCONF_GNU_TARGET) \
	--prefix=/usr

ifdef PTXCONF_XFREE430
FINDUTILS_AUTOCONF += --x-includes=$(CROSS_LIB_DIR)/include
FINDUTILS_AUTOCONF += --x-libraries=$(CROSS_LIB_DIR)/lib
endif

$(STATEDIR)/findutils.prepare: $(findutils_prepare_deps)
	@$(call targetinfo, $@)
	@$(call clean, $(FINDUTILS_DIR)/config.cache)
	cd $(FINDUTILS_DIR) && \
		$(FINDUTILS_PATH) $(FINDUTILS_ENV) \
		./configure $(FINDUTILS_AUTOCONF)
	touch $@

# ----------------------------------------------------------------------------
# Compile
# ----------------------------------------------------------------------------

findutils_compile: $(STATEDIR)/findutils.compile

findutils_compile_deps = $(STATEDIR)/findutils.prepare

$(STATEDIR)/findutils.compile: $(findutils_compile_deps)
	@$(call targetinfo, $@)
	$(FINDUTILS_PATH) $(MAKE) -C $(FINDUTILS_DIR) CPPFLAGS="-D_GNU_SOURCE -I$(CROSS_LIB_DIR)/include" LDFLAGS=" -L$(CROSS_LIB_DIR)/lib -lc"
	touch $@

# ----------------------------------------------------------------------------
# Install
# ----------------------------------------------------------------------------

findutils_install: $(STATEDIR)/findutils.install

$(STATEDIR)/findutils.install: $(STATEDIR)/findutils.compile
	@$(call targetinfo, $@)
	touch $@

# ----------------------------------------------------------------------------
# Target-Install
# ----------------------------------------------------------------------------

findutils_targetinstall: $(STATEDIR)/findutils.targetinstall

findutils_targetinstall_deps = $(STATEDIR)/findutils.compile

$(STATEDIR)/findutils.targetinstall: $(findutils_targetinstall_deps)
	@$(call targetinfo, $@)
	mkdir -p $(FINDUTILS_IPKG_TMP)/usr
	$(FINDUTILS_PATH) $(MAKE) -C $(FINDUTILS_DIR) prefix=$(FINDUTILS_IPKG_TMP)/usr libexecdir=$(FINDUTILS_IPKG_TMP)/usr/bin install
	rm -rf $(FINDUTILS_IPKG_TMP)/usr/bin/bigram
	rm -rf $(FINDUTILS_IPKG_TMP)/usr/bin/code
	rm -rf $(FINDUTILS_IPKG_TMP)/usr/bin/frcode
	rm -rf $(FINDUTILS_IPKG_TMP)/usr/bin/locate
	rm -rf $(FINDUTILS_IPKG_TMP)/usr/bin/updatedb
	#rm -rf $(FINDUTILS_IPKG_TMP)/usr/bin/xargs
	rm -rf $(FINDUTILS_IPKG_TMP)/usr/info
	rm -rf $(FINDUTILS_IPKG_TMP)/usr/man
	rm -rf $(FINDUTILS_IPKG_TMP)/usr/var
	$(CROSSSTRIP) $(FINDUTILS_IPKG_TMP)/usr/bin/xargs
	$(CROSSSTRIP) $(FINDUTILS_IPKG_TMP)/usr/bin/find
	mkdir -p $(FINDUTILS_IPKG_TMP)/CONTROL
	echo "Package: findutils" 			>$(FINDUTILS_IPKG_TMP)/CONTROL/control
	echo "Priority: optional" 			>>$(FINDUTILS_IPKG_TMP)/CONTROL/control
	echo "Section: Utils"	 			>>$(FINDUTILS_IPKG_TMP)/CONTROL/control
	echo "Maintainer: Alexander Chukov <sash@pdaXrom.org>">>$(FINDUTILS_IPKG_TMP)/CONTROL/control
	echo "Architecture: $(SHORT_TARGET)" 		>>$(FINDUTILS_IPKG_TMP)/CONTROL/control
	echo "Version: $(FINDUTILS_VERSION)" 		>>$(FINDUTILS_IPKG_TMP)/CONTROL/control
	echo "Depends: " 				>>$(FINDUTILS_IPKG_TMP)/CONTROL/control
	echo "Description: The GNU Find Utilities are the basic directory searching utilities of the GNU operating system.">>$(FINDUTILS_IPKG_TMP)/CONTROL/control
	cd $(FEEDDIR) && $(XMKIPKG) $(FINDUTILS_IPKG_TMP)
	touch $@

# ----------------------------------------------------------------------------
# Image-Install
# ----------------------------------------------------------------------------

ifdef PTXCONF_FINDUTILS_INSTALL
ROMPACKAGES += $(STATEDIR)/findutils.imageinstall
endif

findutils_imageinstall_deps = $(STATEDIR)/findutils.targetinstall \
	$(STATEDIR)/virtual-image.install

$(STATEDIR)/findutils.imageinstall: $(findutils_imageinstall_deps)
	@$(call targetinfo, $@)
	cd $(FEEDDIR) && $(XIPKG) install findutils
	touch $@

# ----------------------------------------------------------------------------
# Clean
# ----------------------------------------------------------------------------

findutils_clean:
	rm -rf $(STATEDIR)/findutils.*
	rm -rf $(FINDUTILS_DIR)

# vim: syntax=make
