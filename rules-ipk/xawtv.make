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
ifdef PTXCONF_XAWTV
PACKAGES += xawtv
endif

#
# Paths and names
#
XAWTV_VENDOR_VERSION	= 1
XAWTV_VERSION		= 3.94
XAWTV			= xawtv-$(XAWTV_VERSION)
XAWTV_SUFFIX		= tar.gz
XAWTV_URL		= http://bytesex.org/xawtv/$(XAWTV).$(XAWTV_SUFFIX)
XAWTV_SOURCE		= $(SRCDIR)/$(XAWTV).$(XAWTV_SUFFIX)
XAWTV_DIR		= $(BUILDDIR)/$(XAWTV)
XAWTV_IPKG_TMP		= $(XAWTV_DIR)/ipkg_tmp

# ----------------------------------------------------------------------------
# Get
# ----------------------------------------------------------------------------

xawtv_get: $(STATEDIR)/xawtv.get

xawtv_get_deps = $(XAWTV_SOURCE)

$(STATEDIR)/xawtv.get: $(xawtv_get_deps)
	@$(call targetinfo, $@)
	@$(call get_patches, $(XAWTV))
	touch $@

$(XAWTV_SOURCE):
	@$(call targetinfo, $@)
	@$(call get, $(XAWTV_URL))

# ----------------------------------------------------------------------------
# Extract
# ----------------------------------------------------------------------------

xawtv_extract: $(STATEDIR)/xawtv.extract

xawtv_extract_deps = $(STATEDIR)/xawtv.get

$(STATEDIR)/xawtv.extract: $(xawtv_extract_deps)
	@$(call targetinfo, $@)
	@$(call clean, $(XAWTV_DIR))
	@$(call extract, $(XAWTV_SOURCE))
	@$(call patchin, $(XAWTV))
	touch $@

# ----------------------------------------------------------------------------
# Prepare
# ----------------------------------------------------------------------------

xawtv_prepare: $(STATEDIR)/xawtv.prepare

#
# dependencies
#
xawtv_prepare_deps = \
	$(STATEDIR)/xawtv.extract \
	$(STATEDIR)/virtual-xchain.install

XAWTV_PATH	=  PATH=$(CROSS_PATH)
XAWTV_ENV 	=  $(CROSS_ENV)
#XAWTV_ENV	+=
XAWTV_ENV	+= PKG_CONFIG_PATH=$(CROSS_LIB_DIR)/lib/pkgconfig:$(CROSS_LIB_DIR)/lib/pkgconfig
#ifdef PTXCONF_XFREE430
#XAWTV_ENV	+= LDFLAGS=-Wl,-rpath-link,$(CROSS_LIB_DIR)/lib
#endif

#
# autoconf
#
XAWTV_AUTOCONF = \
	--build=$(GNU_HOST) \
	--host=$(PTXCONF_GNU_TARGET) \
	--prefix=/usr

ifdef PTXCONF_XFREE430
XAWTV_AUTOCONF += --x-includes=$(CROSS_LIB_DIR)/include
XAWTV_AUTOCONF += --x-libraries=$(CROSS_LIB_DIR)/lib
endif

$(STATEDIR)/xawtv.prepare: $(xawtv_prepare_deps)
	@$(call targetinfo, $@)
	@$(call clean, $(XAWTV_DIR)/config.cache)
	cd $(XAWTV_DIR) && \
		$(XAWTV_PATH) $(XAWTV_ENV) \
		./configure $(XAWTV_AUTOCONF)
	touch $@

# ----------------------------------------------------------------------------
# Compile
# ----------------------------------------------------------------------------

xawtv_compile: $(STATEDIR)/xawtv.compile

xawtv_compile_deps = $(STATEDIR)/xawtv.prepare

$(STATEDIR)/xawtv.compile: $(xawtv_compile_deps)
	@$(call targetinfo, $@)
	$(XAWTV_PATH) $(MAKE) -C $(XAWTV_DIR)
	touch $@

# ----------------------------------------------------------------------------
# Install
# ----------------------------------------------------------------------------

xawtv_install: $(STATEDIR)/xawtv.install

$(STATEDIR)/xawtv.install: $(STATEDIR)/xawtv.compile
	@$(call targetinfo, $@)
	touch $@

# ----------------------------------------------------------------------------
# Target-Install
# ----------------------------------------------------------------------------

xawtv_targetinstall: $(STATEDIR)/xawtv.targetinstall

xawtv_targetinstall_deps = $(STATEDIR)/xawtv.compile

$(STATEDIR)/xawtv.targetinstall: $(xawtv_targetinstall_deps)
	@$(call targetinfo, $@)
	$(XAWTV_PATH) $(MAKE) -C $(XAWTV_DIR) DESTDIR=$(XAWTV_IPKG_TMP) install
	rm -rf $(XAWTV_IPKG_TMP)/usr/man
	rm -rf $(XAWTV_IPKG_TMP)/etc/X11/de*
	rm -rf $(XAWTV_IPKG_TMP)/etc/X11/fr
	rm -rf $(XAWTV_IPKG_TMP)/etc/X11/it
	for FILE in `find $(XAWTV_IPKG_TMP)/usr -type f`; do	\
	    ZZZ=`file $$FILE | grep 'ELF 32-bit'`;		\
	    if [  "$$ZZZ" != "" ]; then				\
		$(CROSSSTRIP) $$FILE;				\
	    fi;							\
	done
	mkdir -p $(XAWTV_IPKG_TMP)/usr/share/{applications,pixmaps}
	$(INSTALL) -m 644 $(XAWTV_DIR)/contrib/xawtv48x48.xpm $(XAWTV_IPKG_TMP)/usr/share/pixmaps/
	$(INSTALL) -m 644 $(TOPDIR)/config/pics/xawtv.desktop $(XAWTV_IPKG_TMP)/usr/share/applications/
	mkdir -p $(XAWTV_IPKG_TMP)/CONTROL
	echo "Package: xawtv" 								 >$(XAWTV_IPKG_TMP)/CONTROL/control
	echo "Priority: optional" 							>>$(XAWTV_IPKG_TMP)/CONTROL/control
	echo "Section: Multimedia" 							>>$(XAWTV_IPKG_TMP)/CONTROL/control
	echo "Maintainer: Alexander Chukov <sash@pdaXrom.org>" 				>>$(XAWTV_IPKG_TMP)/CONTROL/control
	echo "Architecture: $(SHORT_TARGET)" 						>>$(XAWTV_IPKG_TMP)/CONTROL/control
	echo "Version: $(XAWTV_VERSION)-$(XAWTV_VENDOR_VERSION)" 			>>$(XAWTV_IPKG_TMP)/CONTROL/control
	echo "Depends: xfree430" 							>>$(XAWTV_IPKG_TMP)/CONTROL/control
	echo "Description: v4l applications"						>>$(XAWTV_IPKG_TMP)/CONTROL/control
	cd $(FEEDDIR) && $(XMKIPKG) $(XAWTV_IPKG_TMP)
	touch $@

# ----------------------------------------------------------------------------
# Image-Install
# ----------------------------------------------------------------------------

ifdef PTXCONF_XAWTV_INSTALL
ROMPACKAGES += $(STATEDIR)/xawtv.imageinstall
endif

xawtv_imageinstall_deps = $(STATEDIR)/xawtv.targetinstall \
	$(STATEDIR)/virtual-image.install

$(STATEDIR)/xawtv.imageinstall: $(xawtv_imageinstall_deps)
	@$(call targetinfo, $@)
	cd $(FEEDDIR) && $(XIPKG) install xawtv
	touch $@

# ----------------------------------------------------------------------------
# Clean
# ----------------------------------------------------------------------------

xawtv_clean:
	rm -rf $(STATEDIR)/xawtv.*
	rm -rf $(XAWTV_DIR)

# vim: syntax=make
