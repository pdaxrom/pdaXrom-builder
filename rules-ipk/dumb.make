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
ifdef PTXCONF_DUMB
PACKAGES += dumb
endif

#
# Paths and names
#
DUMB_VERSION		= 0.9.2
DUMB			= dumb-$(DUMB_VERSION)-fixed
DUMB_SUFFIX		= tar.gz
DUMB_URL		= http://easynews.dl.sourceforge.net/sourceforge/dumb/$(DUMB).$(DUMB_SUFFIX)
DUMB_SOURCE		= $(SRCDIR)/$(DUMB).$(DUMB_SUFFIX)
DUMB_DIR		= $(BUILDDIR)/dumb
DUMB_IPKG_TMP		= $(DUMB_DIR)/ipkg_tmp

# ----------------------------------------------------------------------------
# Get
# ----------------------------------------------------------------------------

dumb_get: $(STATEDIR)/dumb.get

dumb_get_deps = $(DUMB_SOURCE)

$(STATEDIR)/dumb.get: $(dumb_get_deps)
	@$(call targetinfo, $@)
	@$(call get_patches, $(DUMB))
	touch $@

$(DUMB_SOURCE):
	@$(call targetinfo, $@)
	@$(call get, $(DUMB_URL))

# ----------------------------------------------------------------------------
# Extract
# ----------------------------------------------------------------------------

dumb_extract: $(STATEDIR)/dumb.extract

dumb_extract_deps = $(STATEDIR)/dumb.get

$(STATEDIR)/dumb.extract: $(dumb_extract_deps)
	@$(call targetinfo, $@)
	@$(call clean, $(DUMB_DIR))
	@$(call extract, $(DUMB_SOURCE))
	@$(call patchin, $(DUMB))
	touch $@

# ----------------------------------------------------------------------------
# Prepare
# ----------------------------------------------------------------------------

dumb_prepare: $(STATEDIR)/dumb.prepare

#
# dependencies
#
dumb_prepare_deps = \
	$(STATEDIR)/dumb.extract \
	$(STATEDIR)/virtual-xchain.install

DUMB_PATH	=  PATH=$(CROSS_PATH)
DUMB_ENV 	=  $(CROSS_ENV)
#DUMB_ENV	+=
DUMB_ENV	+= PKG_CONFIG_PATH=$(CROSS_LIB_DIR)/lib/pkgconfig:$(CROSS_LIB_DIR)/lib/pkgconfig
#ifdef PTXCONF_XFREE430
#DUMB_ENV	+= LDFLAGS=-Wl,-rpath-link,$(CROSS_LIB_DIR)/lib
#endif

#
# autoconf
#
DUMB_AUTOCONF = \
	--build=$(GNU_HOST) \
	--host=$(PTXCONF_GNU_TARGET) \
	--prefix=/usr

ifdef PTXCONF_XFREE430
DUMB_AUTOCONF += --x-includes=$(CROSS_LIB_DIR)/include
DUMB_AUTOCONF += --x-libraries=$(CROSS_LIB_DIR)/lib
endif

$(STATEDIR)/dumb.prepare: $(dumb_prepare_deps)
	@$(call targetinfo, $@)
	@$(call clean, $(DUMB_DIR)/config.cache)
	cp -af $(TOPDIR)/config/pics/dumb_config.txt $(DUMB_DIR)/make/config.txt
	#cd $(DUMB_DIR) && \
	#	$(DUMB_PATH) $(DUMB_ENV) \
	#	make config
	touch $@

# ----------------------------------------------------------------------------
# Compile
# ----------------------------------------------------------------------------

dumb_compile: $(STATEDIR)/dumb.compile

dumb_compile_deps = $(STATEDIR)/dumb.prepare

$(STATEDIR)/dumb.compile: $(dumb_compile_deps)
	@$(call targetinfo, $@)
	cd $(DUMB_DIR) && \
		$(DUMB_PATH) \
		make $(DUMB_ENV) OFLAGS="$(TARGET_OPT_CFLAGS) -ffast-math"
	touch $@

# ----------------------------------------------------------------------------
# Install
# ----------------------------------------------------------------------------

dumb_install: $(STATEDIR)/dumb.install

$(STATEDIR)/dumb.install: $(STATEDIR)/dumb.compile
	@$(call targetinfo, $@)
	cp -af $(DUMB_DIR)/include/dumb.h	$(CROSS_LIB_DIR)/include/
	cp -af $(DUMB_DIR)/lib/unix/libdumb.a	$(CROSS_LIB_DIR)/lib/
	touch $@

# ----------------------------------------------------------------------------
# Target-Install
# ----------------------------------------------------------------------------

dumb_targetinstall: $(STATEDIR)/dumb.targetinstall

dumb_targetinstall_deps = $(STATEDIR)/dumb.compile

$(STATEDIR)/dumb.targetinstall: $(dumb_targetinstall_deps)
	@$(call targetinfo, $@)
	$(DUMB_PATH) $(MAKE) -C $(DUMB_DIR) DESTDIR=$(DUMB_IPKG_TMP) install
	mkdir -p $(DUMB_IPKG_TMP)/CONTROL
	echo "Package: dumb" 								>$(DUMB_IPKG_TMP)/CONTROL/control
	echo "Priority: optional" 							>>$(DUMB_IPKG_TMP)/CONTROL/control
	echo "Section: Multimedia" 							>>$(DUMB_IPKG_TMP)/CONTROL/control
	echo "Maintainer: Alexander Chukov <sash@pdaXrom.org>" 				>>$(DUMB_IPKG_TMP)/CONTROL/control
	echo "Architecture: $(SHORT_TARGET)" 						>>$(DUMB_IPKG_TMP)/CONTROL/control
	echo "Version: $(DUMB_VERSION)" 						>>$(DUMB_IPKG_TMP)/CONTROL/control
	echo "Depends: " 								>>$(DUMB_IPKG_TMP)/CONTROL/control
	echo "Description: generated with pdaXrom builder">>$(DUMB_IPKG_TMP)/CONTROL/control
	asdasd
	cd $(FEEDDIR) && $(XMKIPKG) $(DUMB_IPKG_TMP)
	touch $@

# ----------------------------------------------------------------------------
# Image-Install
# ----------------------------------------------------------------------------

ifdef PTXCONF_DUMB_INSTALL
ROMPACKAGES += $(STATEDIR)/dumb.imageinstall
endif

dumb_imageinstall_deps = $(STATEDIR)/dumb.targetinstall \
	$(STATEDIR)/virtual-image.install

$(STATEDIR)/dumb.imageinstall: $(dumb_imageinstall_deps)
	@$(call targetinfo, $@)
	cd $(FEEDDIR) && $(XIPKG) install dumb
	touch $@

# ----------------------------------------------------------------------------
# Clean
# ----------------------------------------------------------------------------

dumb_clean:
	rm -rf $(STATEDIR)/dumb.*
	rm -rf $(DUMB_DIR)

# vim: syntax=make
