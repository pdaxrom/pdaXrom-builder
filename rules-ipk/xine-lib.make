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
ifdef PTXCONF_XINE-LIB
PACKAGES += xine-lib
endif

#
# Paths and names
#
XINE-LIB_VENDOR_VERSION	= 1
XINE-LIB_VERSION	= 1.0
XINE-LIB		= xine-lib-$(XINE-LIB_VERSION)
XINE-LIB_SUFFIX		= tar.gz
XINE-LIB_URL		= http://heanet.dl.sourceforge.net/sourceforge/xine/$(XINE-LIB).$(XINE-LIB_SUFFIX)
XINE-LIB_SOURCE		= $(SRCDIR)/$(XINE-LIB).$(XINE-LIB_SUFFIX)
XINE-LIB_DIR		= $(BUILDDIR)/$(XINE-LIB)
XINE-LIB_IPKG_TMP	= $(XINE-LIB_DIR)/ipkg_tmp

# ----------------------------------------------------------------------------
# Get
# ----------------------------------------------------------------------------

xine-lib_get: $(STATEDIR)/xine-lib.get

xine-lib_get_deps = $(XINE-LIB_SOURCE)

$(STATEDIR)/xine-lib.get: $(xine-lib_get_deps)
	@$(call targetinfo, $@)
	@$(call get_patches, $(XINE-LIB))
	touch $@

$(XINE-LIB_SOURCE):
	@$(call targetinfo, $@)
	@$(call get, $(XINE-LIB_URL))

# ----------------------------------------------------------------------------
# Extract
# ----------------------------------------------------------------------------

xine-lib_extract: $(STATEDIR)/xine-lib.extract

xine-lib_extract_deps = $(STATEDIR)/xine-lib.get

$(STATEDIR)/xine-lib.extract: $(xine-lib_extract_deps)
	@$(call targetinfo, $@)
	@$(call clean, $(XINE-LIB_DIR))
	@$(call extract, $(XINE-LIB_SOURCE))
	@$(call patchin, $(XINE-LIB))
	touch $@

# ----------------------------------------------------------------------------
# Prepare
# ----------------------------------------------------------------------------

xine-lib_prepare: $(STATEDIR)/xine-lib.prepare

#
# dependencies
#
xine-lib_prepare_deps = \
	$(STATEDIR)/xine-lib.extract \
	$(STATEDIR)/virtual-xchain.install

XINE-LIB_PATH	=  PATH=$(CROSS_PATH)
XINE-LIB_ENV 	=  $(CROSS_ENV)
XINE-LIB_ENV	+= CFLAGS="$(TARGET_OPT_CFLAGS)"
XINE-LIB_ENV	+= CXXFLAGS="$(TARGET_OPT_CFLAGS)"
XINE-LIB_ENV	+= PKG_CONFIG_PATH=$(CROSS_LIB_DIR)/lib/pkgconfig
#ifdef PTXCONF_XFREE430
#XINE-LIB_ENV	+= LDFLAGS=-Wl,-rpath-link,$(CROSS_LIB_DIR)/X11R6/lib
#endif

#
# autoconf
#
XINE-LIB_AUTOCONF = \
	--build=$(GNU_HOST) \
	--host=$(PTXCONF_GNU_TARGET) \
	--prefix=/usr \
	--without-xv \
	--disable-debug \
	--disable-opengl \
	--with-external-ffmpeg=$(CROSS_LIB_DIR)

ifndef PTXCONF_ALSA-UTILS
XINE-LIB_AUTOCONF += --with-alsa-prefix=$(CROSS_LIB_DIR)
endif

ifdef PTXCONF_XFREE430
XINE-LIB_AUTOCONF += --x-includes=$(CROSS_LIB_DIR)/include
XINE-LIB_AUTOCONF += --x-libraries=$(CROSS_LIB_DIR)/lib
endif

$(STATEDIR)/xine-lib.prepare: $(xine-lib_prepare_deps)
	@$(call targetinfo, $@)
	@$(call clean, $(XINE-LIB_DIR)/config.cache)
	cd $(XINE-LIB_DIR) && \
		$(XINE-LIB_PATH) $(XINE-LIB_ENV) \
		./configure $(XINE-LIB_AUTOCONF)
	touch $@

# ----------------------------------------------------------------------------
# Compile
# ----------------------------------------------------------------------------

xine-lib_compile: $(STATEDIR)/xine-lib.compile

xine-lib_compile_deps = $(STATEDIR)/xine-lib.prepare

$(STATEDIR)/xine-lib.compile: $(xine-lib_compile_deps)
	@$(call targetinfo, $@)
	$(XINE-LIB_PATH) $(MAKE) -C $(XINE-LIB_DIR)
	touch $@

# ----------------------------------------------------------------------------
# Install
# ----------------------------------------------------------------------------

xine-lib_install: $(STATEDIR)/xine-lib.install

$(STATEDIR)/xine-lib.install: $(STATEDIR)/xine-lib.compile
	@$(call targetinfo, $@)
	rm -rf $(XINE-LIB_IPKG_TMP)
	$(XINE-LIB_PATH) $(MAKE) -C $(XINE-LIB_DIR) DESTDIR=$(XINE-LIB_IPKG_TMP) install
	asasd
	rm -rf $(XINE-LIB_IPKG_TMP)
	touch $@

# ----------------------------------------------------------------------------
# Target-Install
# ----------------------------------------------------------------------------

xine-lib_targetinstall: $(STATEDIR)/xine-lib.targetinstall

xine-lib_targetinstall_deps = $(STATEDIR)/xine-lib.compile

$(STATEDIR)/xine-lib.targetinstall: $(xine-lib_targetinstall_deps)
	@$(call targetinfo, $@)
	$(XINE-LIB_PATH) $(MAKE) -C $(XINE-LIB_DIR) DESTDIR=$(XINE-LIB_IPKG_TMP) install
	mkdir -p $(XINE-LIB_IPKG_TMP)/CONTROL
	echo "Package: xine-lib" 							 >$(XINE-LIB_IPKG_TMP)/CONTROL/control
	echo "Priority: optional" 							>>$(XINE-LIB_IPKG_TMP)/CONTROL/control
	echo "Section: Multimedia" 							>>$(XINE-LIB_IPKG_TMP)/CONTROL/control
	echo "Maintainer: Alexander Chukov <sash@pdaXrom.org>" 				>>$(XINE-LIB_IPKG_TMP)/CONTROL/control
	echo "Architecture: $(SHORT_TARGET)" 						>>$(XINE-LIB_IPKG_TMP)/CONTROL/control
	echo "Version: $(XINE-LIB_VERSION)-$(XINE-LIB_VENDOR_VERSION)" 			>>$(XINE-LIB_IPKG_TMP)/CONTROL/control
	echo "Depends: " 								>>$(XINE-LIB_IPKG_TMP)/CONTROL/control
	echo "Description: xine-lib is the xine core engine, it is needed for all frontends and applications that use xine.">>$(XINE-LIB_IPKG_TMP)/CONTROL/control
	asdasd
	cd $(FEEDDIR) && $(XMKIPKG) $(XINE-LIB_IPKG_TMP)
	touch $@

# ----------------------------------------------------------------------------
# Image-Install
# ----------------------------------------------------------------------------

ifdef PTXCONF_XINE-LIB_INSTALL
ROMPACKAGES += $(STATEDIR)/xine-lib.imageinstall
endif

xine-lib_imageinstall_deps = $(STATEDIR)/xine-lib.targetinstall \
	$(STATEDIR)/virtual-image.install

$(STATEDIR)/xine-lib.imageinstall: $(xine-lib_imageinstall_deps)
	@$(call targetinfo, $@)
	cd $(FEEDDIR) && $(XIPKG) install xine-lib
	touch $@

# ----------------------------------------------------------------------------
# Clean
# ----------------------------------------------------------------------------

xine-lib_clean:
	rm -rf $(STATEDIR)/xine-lib.*
	rm -rf $(XINE-LIB_DIR)

# vim: syntax=make
