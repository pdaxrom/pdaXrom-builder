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
ifdef PTXCONF_UNRAR
PACKAGES += unrar
endif

#
# Paths and names
#
UNRAR_VENDOR_VERSION	= 1
UNRAR_VERSION		= 3.4.3
UNRAR			= unrarsrc-$(UNRAR_VERSION)
UNRAR_SUFFIX		= tar.gz
UNRAR_URL		= http://www.rarlab.com/rar/$(UNRAR).$(UNRAR_SUFFIX)
UNRAR_SOURCE		= $(SRCDIR)/$(UNRAR).$(UNRAR_SUFFIX)
UNRAR_DIR		= $(BUILDDIR)/unrar
UNRAR_IPKG_TMP		= $(UNRAR_DIR)/ipkg_tmp

# ----------------------------------------------------------------------------
# Get
# ----------------------------------------------------------------------------

unrar_get: $(STATEDIR)/unrar.get

unrar_get_deps = $(UNRAR_SOURCE)

$(STATEDIR)/unrar.get: $(unrar_get_deps)
	@$(call targetinfo, $@)
	@$(call get_patches, $(UNRAR))
	touch $@

$(UNRAR_SOURCE):
	@$(call targetinfo, $@)
	@$(call get, $(UNRAR_URL))

# ----------------------------------------------------------------------------
# Extract
# ----------------------------------------------------------------------------

unrar_extract: $(STATEDIR)/unrar.extract

unrar_extract_deps = $(STATEDIR)/unrar.get

$(STATEDIR)/unrar.extract: $(unrar_extract_deps)
	@$(call targetinfo, $@)
	@$(call clean, $(UNRAR_DIR))
	@$(call extract, $(UNRAR_SOURCE))
	@$(call patchin, $(UNRAR))
	touch $@

# ----------------------------------------------------------------------------
# Prepare
# ----------------------------------------------------------------------------

unrar_prepare: $(STATEDIR)/unrar.prepare

#
# dependencies
#
unrar_prepare_deps = \
	$(STATEDIR)/unrar.extract \
	$(STATEDIR)/virtual-xchain.install

UNRAR_PATH	=  PATH=$(CROSS_PATH)
UNRAR_ENV 	=  $(CROSS_ENV)
#UNRAR_ENV	+=
UNRAR_ENV	+= PKG_CONFIG_PATH=$(CROSS_LIB_DIR)/lib/pkgconfig:$(CROSS_LIB_DIR)/lib/pkgconfig
#ifdef PTXCONF_XFREE430
#UNRAR_ENV	+= LDFLAGS=-Wl,-rpath-link,$(CROSS_LIB_DIR)/lib
#endif

#
# autoconf
#
UNRAR_AUTOCONF = \
	--build=$(GNU_HOST) \
	--host=$(PTXCONF_GNU_TARGET) \
	--prefix=/usr

ifdef PTXCONF_XFREE430
UNRAR_AUTOCONF += --x-includes=$(CROSS_LIB_DIR)/include
UNRAR_AUTOCONF += --x-libraries=$(CROSS_LIB_DIR)/lib
endif

$(STATEDIR)/unrar.prepare: $(unrar_prepare_deps)
	@$(call targetinfo, $@)
	@$(call clean, $(UNRAR_DIR)/config.cache)
	#cd $(UNRAR_DIR) && \
	#	$(UNRAR_PATH) $(UNRAR_ENV) \
	#	./configure $(UNRAR_AUTOCONF)
	touch $@

# ----------------------------------------------------------------------------
# Compile
# ----------------------------------------------------------------------------

unrar_compile: $(STATEDIR)/unrar.compile

unrar_compile_deps = $(STATEDIR)/unrar.prepare

$(STATEDIR)/unrar.compile: $(unrar_compile_deps)
	@$(call targetinfo, $@)
	$(UNRAR_PATH) $(MAKE) -C $(UNRAR_DIR) -f makefile.unix CXXFLAGS="$(TARGET_OPT_CFLAGS)" $(CROSS_ENV_CXX) $(CROSS_ENV_STRIP)
	touch $@

# ----------------------------------------------------------------------------
# Install
# ----------------------------------------------------------------------------

unrar_install: $(STATEDIR)/unrar.install

$(STATEDIR)/unrar.install: $(STATEDIR)/unrar.compile
	@$(call targetinfo, $@)
	$(UNRAR_PATH) $(MAKE) -C $(UNRAR_DIR) install
	touch $@

# ----------------------------------------------------------------------------
# Target-Install
# ----------------------------------------------------------------------------

unrar_targetinstall: $(STATEDIR)/unrar.targetinstall

unrar_targetinstall_deps = $(STATEDIR)/unrar.compile

$(STATEDIR)/unrar.targetinstall: $(unrar_targetinstall_deps)
	@$(call targetinfo, $@)
	###$(UNRAR_PATH) $(MAKE) -C $(UNRAR_DIR) DESTDIR=$(UNRAR_IPKG_TMP) install
	$(INSTALL) -D -m 755 $(UNRAR_DIR)/unrar $(UNRAR_IPKG_TMP)/usr/bin/unrar
	mkdir -p $(UNRAR_IPKG_TMP)/CONTROL
	echo "Package: unrar" 								 >$(UNRAR_IPKG_TMP)/CONTROL/control
	echo "Priority: optional" 							>>$(UNRAR_IPKG_TMP)/CONTROL/control
	echo "Section: Utilities" 							>>$(UNRAR_IPKG_TMP)/CONTROL/control
	echo "Maintainer: Alexander Chukov <sash@pdaXrom.org>" 				>>$(UNRAR_IPKG_TMP)/CONTROL/control
	echo "Architecture: $(SHORT_TARGET)" 						>>$(UNRAR_IPKG_TMP)/CONTROL/control
	echo "Version: $(UNRAR_VERSION)-$(UNRAR_VENDOR_VERSION)" 			>>$(UNRAR_IPKG_TMP)/CONTROL/control
	echo "Depends: " 								>>$(UNRAR_IPKG_TMP)/CONTROL/control
	echo "Description: Command line UNRAR utility"					>>$(UNRAR_IPKG_TMP)/CONTROL/control
	cd $(FEEDDIR) && $(XMKIPKG) $(UNRAR_IPKG_TMP)
	touch $@

# ----------------------------------------------------------------------------
# Image-Install
# ----------------------------------------------------------------------------

ifdef PTXCONF_UNRAR_INSTALL
ROMPACKAGES += $(STATEDIR)/unrar.imageinstall
endif

unrar_imageinstall_deps = $(STATEDIR)/unrar.targetinstall \
	$(STATEDIR)/virtual-image.install

$(STATEDIR)/unrar.imageinstall: $(unrar_imageinstall_deps)
	@$(call targetinfo, $@)
	cd $(FEEDDIR) && $(XIPKG) install unrar
	touch $@

# ----------------------------------------------------------------------------
# Clean
# ----------------------------------------------------------------------------

unrar_clean:
	rm -rf $(STATEDIR)/unrar.*
	rm -rf $(UNRAR_DIR)

# vim: syntax=make
