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
ifdef PTXCONF_XDTV
PACKAGES += xdtv
endif

#
# Paths and names
#
XDTV_VENDOR_VERSION	= 1
XDTV_VERSION		= 2.0.1
XDTV			= xdtv-$(XDTV_VERSION)
XDTV_SUFFIX		= tar.bz2
XDTV_URL		= http://belnet.dl.sourceforge.net/sourceforge/xawdecode/$(XDTV).$(XDTV_SUFFIX)
XDTV_SOURCE		= $(SRCDIR)/$(XDTV).$(XDTV_SUFFIX)
XDTV_DIR		= $(BUILDDIR)/$(XDTV)
XDTV_IPKG_TMP		= $(XDTV_DIR)/ipkg_tmp

# ----------------------------------------------------------------------------
# Get
# ----------------------------------------------------------------------------

xdtv_get: $(STATEDIR)/xdtv.get

xdtv_get_deps = $(XDTV_SOURCE)

$(STATEDIR)/xdtv.get: $(xdtv_get_deps)
	@$(call targetinfo, $@)
	@$(call get_patches, $(XDTV))
	touch $@

$(XDTV_SOURCE):
	@$(call targetinfo, $@)
	@$(call get, $(XDTV_URL))

# ----------------------------------------------------------------------------
# Extract
# ----------------------------------------------------------------------------

xdtv_extract: $(STATEDIR)/xdtv.extract

xdtv_extract_deps = $(STATEDIR)/xdtv.get

$(STATEDIR)/xdtv.extract: $(xdtv_extract_deps)
	@$(call targetinfo, $@)
	@$(call clean, $(XDTV_DIR))
	@$(call extract, $(XDTV_SOURCE))
	@$(call patchin, $(XDTV))
	touch $@

# ----------------------------------------------------------------------------
# Prepare
# ----------------------------------------------------------------------------

xdtv_prepare: $(STATEDIR)/xdtv.prepare

#
# dependencies
#
xdtv_prepare_deps = \
	$(STATEDIR)/xdtv.extract \
	$(STATEDIR)/virtual-xchain.install

XDTV_PATH	=  PATH=$(CROSS_PATH)
XDTV_ENV 	=  $(CROSS_ENV)
#XDTV_ENV	+=
XDTV_ENV	+= PKG_CONFIG_PATH=$(CROSS_LIB_DIR)/lib/pkgconfig
#ifdef PTXCONF_XFREE430
#XDTV_ENV	+= LDFLAGS=-Wl,-rpath-link,$(CROSS_LIB_DIR)/X11R6/lib
#endif

#
# autoconf
#
XDTV_AUTOCONF = \
	--build=$(GNU_HOST) \
	--host=$(PTXCONF_GNU_TARGET) \
	--prefix=/usr \
	--disable-alsa \
	--disable-xvid

ifdef PTXCONF_XFREE430
XDTV_AUTOCONF += --x-includes=$(CROSS_LIB_DIR)/include
XDTV_AUTOCONF += --x-libraries=$(CROSS_LIB_DIR)/lib
endif

$(STATEDIR)/xdtv.prepare: $(xdtv_prepare_deps)
	@$(call targetinfo, $@)
	@$(call clean, $(XDTV_DIR)/config.cache)
	cd $(XDTV_DIR) && \
		$(XDTV_PATH) $(XDTV_ENV) \
		./configure $(XDTV_AUTOCONF)
	touch $@

# ----------------------------------------------------------------------------
# Compile
# ----------------------------------------------------------------------------

xdtv_compile: $(STATEDIR)/xdtv.compile

xdtv_compile_deps = $(STATEDIR)/xdtv.prepare

$(STATEDIR)/xdtv.compile: $(xdtv_compile_deps)
	@$(call targetinfo, $@)
	$(XDTV_PATH) $(MAKE) -C $(XDTV_DIR)
	touch $@

# ----------------------------------------------------------------------------
# Install
# ----------------------------------------------------------------------------

xdtv_install: $(STATEDIR)/xdtv.install

$(STATEDIR)/xdtv.install: $(STATEDIR)/xdtv.compile
	@$(call targetinfo, $@)
	$(XDTV_PATH) $(MAKE) -C $(XDTV_DIR) install
	touch $@

# ----------------------------------------------------------------------------
# Target-Install
# ----------------------------------------------------------------------------

xdtv_targetinstall: $(STATEDIR)/xdtv.targetinstall

xdtv_targetinstall_deps = $(STATEDIR)/xdtv.compile

$(STATEDIR)/xdtv.targetinstall: $(xdtv_targetinstall_deps)
	@$(call targetinfo, $@)
	$(XDTV_PATH) $(MAKE) -C $(XDTV_DIR) DESTDIR=$(XDTV_IPKG_TMP) install
	rm -rf $(XDTV_IPKG_TMP)/usr/include
	rm -rf $(XDTV_IPKG_TMP)/usr/man
	$(INSTALL) -D -m 644 $(TOPDIR)/config/pics/xdtv.desktop $(XDTV_IPKG_TMP)/usr/share/applications/xdtv.desktop
	mkdir -p $(XDTV_IPKG_TMP)/usr/X11R6/lib
	mv $(XDTV_IPKG_TMP)/$(CROSS_LIB_DIR)/lib/* $(XDTV_IPKG_TMP)/usr/X11R6/lib
	rm -rf $(XDTV_IPKG_TMP)/opt

	for FILE in `find $(XDTV_IPKG_TMP)/usr -type f`; do	\
	    ZZZ=`file $$FILE | grep 'ELF 32-bit'`;		\
	    if [  "$$ZZZ" != "" ]; then				\
		$(CROSSSTRIP) $$FILE;				\
	    fi;							\
	done

	mkdir -p $(XDTV_IPKG_TMP)/CONTROL
	echo "Package: xdtv" 							 	 >$(XDTV_IPKG_TMP)/CONTROL/control
	echo "Priority: optional" 							>>$(XDTV_IPKG_TMP)/CONTROL/control
	echo "Section: Multimedia" 							>>$(XDTV_IPKG_TMP)/CONTROL/control
	echo "Maintainer: Alexander Chukov <sash@pdaXrom.org>" 				>>$(XDTV_IPKG_TMP)/CONTROL/control
	echo "Architecture: $(SHORT_TARGET)" 						>>$(XDTV_IPKG_TMP)/CONTROL/control
	echo "Version: $(XDTV_VERSION)-$(XDTV_VENDOR_VERSION)" 				>>$(XDTV_IPKG_TMP)/CONTROL/control
	echo "Depends: xfree430, libffmpeg" 						>>$(XDTV_IPKG_TMP)/CONTROL/control
	echo "Description: XdTV is a software that allows you to watch TV."		>>$(XDTV_IPKG_TMP)/CONTROL/control
	cd $(FEEDDIR) && $(XMKIPKG) $(XDTV_IPKG_TMP)
	touch $@

# ----------------------------------------------------------------------------
# Image-Install
# ----------------------------------------------------------------------------

ifdef PTXCONF_XDTV_INSTALL
ROMPACKAGES += $(STATEDIR)/xdtv.imageinstall
endif

xdtv_imageinstall_deps = $(STATEDIR)/xdtv.targetinstall \
	$(STATEDIR)/virtual-image.install

$(STATEDIR)/xdtv.imageinstall: $(xdtv_imageinstall_deps)
	@$(call targetinfo, $@)
	cd $(FEEDDIR) && $(XIPKG) install xdtv
	touch $@

# ----------------------------------------------------------------------------
# Clean
# ----------------------------------------------------------------------------

xdtv_clean:
	rm -rf $(STATEDIR)/xdtv.*
	rm -rf $(XDTV_DIR)

# vim: syntax=make
