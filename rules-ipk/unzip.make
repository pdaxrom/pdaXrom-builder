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
ifdef PTXCONF_UNZIP
PACKAGES += unzip
endif

#
# Paths and names
#
UNZIP_VERSION		= 5.51
UNZIP			= unzip551
UNZIP_SUFFIX		= tar.gz
UNZIP_URL		= ftp://ftp.info-zip.org/pub/infozip/src/$(UNZIP).$(UNZIP_SUFFIX)
UNZIP_SOURCE		= $(SRCDIR)/$(UNZIP).$(UNZIP_SUFFIX)
UNZIP_DIR		= $(BUILDDIR)/unzip-$(UNZIP_VERSION)
UNZIP_IPKG_TMP		= $(UNZIP_DIR)/ipkg_tmp

# ----------------------------------------------------------------------------
# Get
# ----------------------------------------------------------------------------

unzip_get: $(STATEDIR)/unzip.get

unzip_get_deps = $(UNZIP_SOURCE)

$(STATEDIR)/unzip.get: $(unzip_get_deps)
	@$(call targetinfo, $@)
	@$(call get_patches, $(UNZIP))
	touch $@

$(UNZIP_SOURCE):
	@$(call targetinfo, $@)
	@$(call get, $(UNZIP_URL))

# ----------------------------------------------------------------------------
# Extract
# ----------------------------------------------------------------------------

unzip_extract: $(STATEDIR)/unzip.extract

unzip_extract_deps = $(STATEDIR)/unzip.get

$(STATEDIR)/unzip.extract: $(unzip_extract_deps)
	@$(call targetinfo, $@)
	@$(call clean, $(UNZIP_DIR))
	@$(call extract, $(UNZIP_SOURCE))
	@$(call patchin, $(UNZIP))
	touch $@

# ----------------------------------------------------------------------------
# Prepare
# ----------------------------------------------------------------------------

unzip_prepare: $(STATEDIR)/unzip.prepare

#
# dependencies
#
unzip_prepare_deps = \
	$(STATEDIR)/unzip.extract \
	$(STATEDIR)/virtual-xchain.install

UNZIP_PATH	=  PATH=$(CROSS_PATH)
UNZIP_ENV 	=  CC=$(PTXCONF_GNU_TARGET)-gcc
#UNZIP_ENV	+=
UNZIP_ENV	+= PKG_CONFIG_PATH=$(CROSS_LIB_DIR)/lib/pkgconfig:$(CROSS_LIB_DIR)/lib/pkgconfig
#ifdef PTXCONF_XFREE430
#UNZIP_ENV	+= LDFLAGS=-Wl,-rpath-link,$(CROSS_LIB_DIR)/lib
#endif

#
# autoconf
#
UNZIP_AUTOCONF = \
	--build=$(GNU_HOST) \
	--host=$(PTXCONF_GNU_TARGET) \
	--prefix=/usr

ifdef PTXCONF_XFREE430
UNZIP_AUTOCONF += --x-includes=$(CROSS_LIB_DIR)/include
UNZIP_AUTOCONF += --x-libraries=$(CROSS_LIB_DIR)/lib
endif

$(STATEDIR)/unzip.prepare: $(unzip_prepare_deps)
	@$(call targetinfo, $@)
	@$(call clean, $(UNZIP_DIR)/config.cache)
	#cd $(UNZIP_DIR) && \
	#	$(UNZIP_PATH) $(UNZIP_ENV) \
	#	./configure $(UNZIP_AUTOCONF)
	touch $@

# ----------------------------------------------------------------------------
# Compile
# ----------------------------------------------------------------------------

unzip_compile: $(STATEDIR)/unzip.compile

unzip_compile_deps = $(STATEDIR)/unzip.prepare

$(STATEDIR)/unzip.compile: $(unzip_compile_deps)
	@$(call targetinfo, $@)
	$(UNZIP_PATH) $(MAKE) $(UNZIP_ENV) -C $(UNZIP_DIR) -f unix/Makefile CF="$(TARGET_OPT_CFLAGS) -DUNIX -I." generic
	touch $@

# ----------------------------------------------------------------------------
# Install
# ----------------------------------------------------------------------------

unzip_install: $(STATEDIR)/unzip.install

$(STATEDIR)/unzip.install: $(STATEDIR)/unzip.compile
	@$(call targetinfo, $@)
	$(UNZIP_PATH) $(MAKE) -C $(UNZIP_DIR) install
	touch $@

# ----------------------------------------------------------------------------
# Target-Install
# ----------------------------------------------------------------------------

unzip_targetinstall: $(STATEDIR)/unzip.targetinstall

unzip_targetinstall_deps = $(STATEDIR)/unzip.compile

$(STATEDIR)/unzip.targetinstall: $(unzip_targetinstall_deps)
	@$(call targetinfo, $@)
	$(UNZIP_PATH) $(MAKE) $(UNZIP_ENV) -C $(UNZIP_DIR) -f unix/Makefile CF="$(TARGET_OPT_CFLAGS) -DUNIX -I." prefix=$(UNZIP_IPKG_TMP)/usr install
	ln -sf $(UNZIP_IPKG_TMP)/usr/bin/unzip $(UNZIP_IPKG_TMP)/usr/bin/zipinfo
	rm -rf $(UNZIP_IPKG_TMP)/usr/man
	mkdir -p $(UNZIP_IPKG_TMP)/CONTROL
	echo "Package: unzip" 							>$(UNZIP_IPKG_TMP)/CONTROL/control
	echo "Priority: optional" 						>>$(UNZIP_IPKG_TMP)/CONTROL/control
	echo "Section: Utilities" 						>>$(UNZIP_IPKG_TMP)/CONTROL/control
	echo "Maintainer: Alexander Chukov <sash@pdaXrom.org>" 			>>$(UNZIP_IPKG_TMP)/CONTROL/control
	echo "Architecture: $(SHORT_TARGET)" 					>>$(UNZIP_IPKG_TMP)/CONTROL/control
	echo "Version: $(UNZIP_VERSION)" 					>>$(UNZIP_IPKG_TMP)/CONTROL/control
	echo "Depends: " 							>>$(UNZIP_IPKG_TMP)/CONTROL/control
	echo "Description: UnZip is an extraction utility for archives compressed in .zip format (also called 'zipfiles').">>$(UNZIP_IPKG_TMP)/CONTROL/control
	cd $(FEEDDIR) && $(XMKIPKG) $(UNZIP_IPKG_TMP)
	touch $@

# ----------------------------------------------------------------------------
# Image-Install
# ----------------------------------------------------------------------------

ifdef PTXCONF_UNZIP_INSTALL
ROMPACKAGES += $(STATEDIR)/unzip.imageinstall
endif

unzip_imageinstall_deps = $(STATEDIR)/unzip.targetinstall \
	$(STATEDIR)/virtual-image.install

$(STATEDIR)/unzip.imageinstall: $(unzip_imageinstall_deps)
	@$(call targetinfo, $@)
	cd $(FEEDDIR) && $(XIPKG) install unzip
	touch $@

# ----------------------------------------------------------------------------
# Clean
# ----------------------------------------------------------------------------

unzip_clean:
	rm -rf $(STATEDIR)/unzip.*
	rm -rf $(UNZIP_DIR)

# vim: syntax=make
