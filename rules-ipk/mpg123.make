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
ifdef PTXCONF_MPG123
PACKAGES += mpg123
endif

#
# Paths and names
#
MPG123_VENDOR_VERSION	= 1
MPG123_VERSION		= 0.59r
MPG123			= mpg123-$(MPG123_VERSION)
MPG123_SUFFIX		= tar.gz
MPG123_URL		= http://www-ti.informatik.uni-tuebingen.de/~hippm/mpg123/$(MPG123).$(MPG123_SUFFIX)
MPG123_SOURCE		= $(SRCDIR)/$(MPG123).$(MPG123_SUFFIX)
MPG123_DIR		= $(BUILDDIR)/$(MPG123)
MPG123_IPKG_TMP		= $(MPG123_DIR)/ipkg_tmp

# ----------------------------------------------------------------------------
# Get
# ----------------------------------------------------------------------------

mpg123_get: $(STATEDIR)/mpg123.get

mpg123_get_deps = $(MPG123_SOURCE)

$(STATEDIR)/mpg123.get: $(mpg123_get_deps)
	@$(call targetinfo, $@)
	@$(call get_patches, $(MPG123))
	touch $@

$(MPG123_SOURCE):
	@$(call targetinfo, $@)
	@$(call get, $(MPG123_URL))

# ----------------------------------------------------------------------------
# Extract
# ----------------------------------------------------------------------------

mpg123_extract: $(STATEDIR)/mpg123.extract

mpg123_extract_deps = $(STATEDIR)/mpg123.get

$(STATEDIR)/mpg123.extract: $(mpg123_extract_deps)
	@$(call targetinfo, $@)
	@$(call clean, $(MPG123_DIR))
	@$(call extract, $(MPG123_SOURCE))
	@$(call patchin, $(MPG123))
	touch $@

# ----------------------------------------------------------------------------
# Prepare
# ----------------------------------------------------------------------------

mpg123_prepare: $(STATEDIR)/mpg123.prepare

#
# dependencies
#
mpg123_prepare_deps = \
	$(STATEDIR)/mpg123.extract \
	$(STATEDIR)/virtual-xchain.install

MPG123_PATH	=  PATH=$(CROSS_PATH)
MPG123_ENV 	=  $(CROSS_ENV)
#MPG123_ENV	+=
MPG123_ENV	+= PKG_CONFIG_PATH=$(CROSS_LIB_DIR)/lib/pkgconfig:$(CROSS_LIB_DIR)/lib/pkgconfig
#ifdef PTXCONF_XFREE430
#MPG123_ENV	+= LDFLAGS=-Wl,-rpath-link,$(CROSS_LIB_DIR)/lib
#endif

#
# autoconf
#
MPG123_AUTOCONF = \
	--build=$(GNU_HOST) \
	--host=$(PTXCONF_GNU_TARGET) \
	--prefix=/usr

ifdef PTXCONF_XFREE430
MPG123_AUTOCONF += --x-includes=$(CROSS_LIB_DIR)/include
MPG123_AUTOCONF += --x-libraries=$(CROSS_LIB_DIR)/lib
endif

$(STATEDIR)/mpg123.prepare: $(mpg123_prepare_deps)
	@$(call targetinfo, $@)
	@$(call clean, $(MPG123_DIR)/config.cache)
	#cd $(MPG123_DIR) && \
	#	$(MPG123_PATH) $(MPG123_ENV) \
	#	./configure $(MPG123_AUTOCONF)
	touch $@

# ----------------------------------------------------------------------------
# Compile
# ----------------------------------------------------------------------------

mpg123_compile: $(STATEDIR)/mpg123.compile

mpg123_compile_deps = $(STATEDIR)/mpg123.prepare

$(STATEDIR)/mpg123.compile: $(mpg123_compile_deps)
	@$(call targetinfo, $@)
ifdef PTXCONF_ARCH_ARM
	$(MPG123_PATH) $(MAKE) -C $(MPG123_DIR) linux-arm $(CROSS_ENV_CC)
else
	$(MPG123_PATH) $(MAKE) -C $(MPG123_DIR) linux $(CROSS_ENV_CC)
endif
	touch $@

# ----------------------------------------------------------------------------
# Install
# ----------------------------------------------------------------------------

mpg123_install: $(STATEDIR)/mpg123.install

$(STATEDIR)/mpg123.install: $(STATEDIR)/mpg123.compile
	@$(call targetinfo, $@)
	touch $@

# ----------------------------------------------------------------------------
# Target-Install
# ----------------------------------------------------------------------------

mpg123_targetinstall: $(STATEDIR)/mpg123.targetinstall

mpg123_targetinstall_deps = $(STATEDIR)/mpg123.compile

$(STATEDIR)/mpg123.targetinstall: $(mpg123_targetinstall_deps)
	@$(call targetinfo, $@)
	$(INSTALL) -m 755 -D $(MPG123_DIR)/mpg123 $(MPG123_IPKG_TMP)/usr/bin/mpg123
	$(CROSSSTRIP) $(MPG123_IPKG_TMP)/usr/bin/mpg123
	mkdir -p $(MPG123_IPKG_TMP)/CONTROL
	echo "Package: mpg123" 								 >$(MPG123_IPKG_TMP)/CONTROL/control
	echo "Priority: optional" 							>>$(MPG123_IPKG_TMP)/CONTROL/control
	echo "Section: Multimedia" 							>>$(MPG123_IPKG_TMP)/CONTROL/control
	echo "Maintainer: Alexander Chukov <sash@pdaXrom.org>" 				>>$(MPG123_IPKG_TMP)/CONTROL/control
	echo "Architecture: $(SHORT_TARGET)" 						>>$(MPG123_IPKG_TMP)/CONTROL/control
	echo "Version: $(MPG123_VERSION)-$(MPG123_VENDOR_VERSION)" 			>>$(MPG123_IPKG_TMP)/CONTROL/control
	echo "Depends: " 								>>$(MPG123_IPKG_TMP)/CONTROL/control
	echo "Description: commande line mpeg 1,2 layer 1,2,3 player"			>>$(MPG123_IPKG_TMP)/CONTROL/control
	cd $(FEEDDIR) && $(XMKIPKG) $(MPG123_IPKG_TMP)
	touch $@

# ----------------------------------------------------------------------------
# Image-Install
# ----------------------------------------------------------------------------

ifdef PTXCONF_MPG123_INSTALL
ROMPACKAGES += $(STATEDIR)/mpg123.imageinstall
endif

mpg123_imageinstall_deps = $(STATEDIR)/mpg123.targetinstall \
	$(STATEDIR)/virtual-image.install

$(STATEDIR)/mpg123.imageinstall: $(mpg123_imageinstall_deps)
	@$(call targetinfo, $@)
	cd $(FEEDDIR) && $(XIPKG) install mpg123
	touch $@

# ----------------------------------------------------------------------------
# Clean
# ----------------------------------------------------------------------------

mpg123_clean:
	rm -rf $(STATEDIR)/mpg123.*
	rm -rf $(MPG123_DIR)

# vim: syntax=make
