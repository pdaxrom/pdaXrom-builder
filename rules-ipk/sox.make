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
ifdef PTXCONF_SOX
PACKAGES += sox
endif

#
# Paths and names
#
SOX_VERSION	= 12.17.4
SOX		= sox-$(SOX_VERSION)
SOX_SUFFIX	= tar.gz
SOX_URL		= http://heanet.dl.sourceforge.net/sourceforge/sox/$(SOX).$(SOX_SUFFIX)
SOX_SOURCE	= $(SRCDIR)/$(SOX).$(SOX_SUFFIX)
SOX_DIR		= $(BUILDDIR)/$(SOX)
SOX_IPKG_TMP	= $(SOX_DIR)/ipkg_tmp

# ----------------------------------------------------------------------------
# Get
# ----------------------------------------------------------------------------

sox_get: $(STATEDIR)/sox.get

sox_get_deps = $(SOX_SOURCE)

$(STATEDIR)/sox.get: $(sox_get_deps)
	@$(call targetinfo, $@)
	@$(call get_patches, $(SOX))
	touch $@

$(SOX_SOURCE):
	@$(call targetinfo, $@)
	@$(call get, $(SOX_URL))

# ----------------------------------------------------------------------------
# Extract
# ----------------------------------------------------------------------------

sox_extract: $(STATEDIR)/sox.extract

sox_extract_deps = $(STATEDIR)/sox.get

$(STATEDIR)/sox.extract: $(sox_extract_deps)
	@$(call targetinfo, $@)
	@$(call clean, $(SOX_DIR))
	@$(call extract, $(SOX_SOURCE))
	@$(call patchin, $(SOX))
	touch $@

# ----------------------------------------------------------------------------
# Prepare
# ----------------------------------------------------------------------------

sox_prepare: $(STATEDIR)/sox.prepare

#
# dependencies
#
sox_prepare_deps = \
	$(STATEDIR)/sox.extract \
	$(STATEDIR)/libmad.install \
	$(STATEDIR)/virtual-xchain.install

SOX_PATH	=  PATH=$(CROSS_PATH)
SOX_ENV 	=  $(CROSS_ENV)
#SOX_ENV	+=
SOX_ENV	+= PKG_CONFIG_PATH=$(CROSS_LIB_DIR)/lib/pkgconfig:$(CROSS_LIB_DIR)/lib/pkgconfig
#ifdef PTXCONF_XFREE430
#SOX_ENV	+= LDFLAGS=-Wl,-rpath-link,$(CROSS_LIB_DIR)/lib
#endif
SOX_ENV	+= CFLAGS="-O2 -fomit-frame-pointer"

#
# autoconf
#
SOX_AUTOCONF = \
	--build=$(GNU_HOST) \
	--host=$(PTXCONF_GNU_TARGET) \
	--prefix=/usr \
	--disable-gsm
#	--enable-shared \
#	--disable-static

ifdef PTXCONF_XFREE430
SOX_AUTOCONF += --x-includes=$(CROSS_LIB_DIR)/include
SOX_AUTOCONF += --x-libraries=$(CROSS_LIB_DIR)/lib
endif

$(STATEDIR)/sox.prepare: $(sox_prepare_deps)
	@$(call targetinfo, $@)
	@$(call clean, $(SOX_DIR)/config.cache)
	#cd $(SOX_DIR) && aclocal
	#cd $(SOX_DIR) && automake --add-missing
	#cd $(SOX_DIR) && autoconf
	cd $(SOX_DIR) && \
		$(SOX_PATH) $(SOX_ENV) \
		./configure $(SOX_AUTOCONF)
	touch $@

# ----------------------------------------------------------------------------
# Compile
# ----------------------------------------------------------------------------

sox_compile: $(STATEDIR)/sox.compile

sox_compile_deps = $(STATEDIR)/sox.prepare

$(STATEDIR)/sox.compile: $(sox_compile_deps)
	@$(call targetinfo, $@)
	$(SOX_PATH) $(MAKE) -C $(SOX_DIR)
	touch $@

# ----------------------------------------------------------------------------
# Install
# ----------------------------------------------------------------------------

sox_install: $(STATEDIR)/sox.install

$(STATEDIR)/sox.install: $(STATEDIR)/sox.compile
	@$(call targetinfo, $@)
	#$(SOX_PATH) $(MAKE) -C $(SOX_DIR) install
	touch $@

# ----------------------------------------------------------------------------
# Target-Install
# ----------------------------------------------------------------------------

sox_targetinstall: $(STATEDIR)/sox.targetinstall

sox_targetinstall_deps = \
	$(STATEDIR)/sox.compile \
	$(STATEDIR)/libmad.targetinstall


$(STATEDIR)/sox.targetinstall: $(sox_targetinstall_deps)
	@$(call targetinfo, $@)
	$(SOX_PATH) $(MAKE) -C $(SOX_DIR) prefix=$(SOX_IPKG_TMP)/usr install
	$(CROSSSTRIP) $(SOX_IPKG_TMP)/usr/bin/sox
	$(CROSSSTRIP) $(SOX_IPKG_TMP)/usr/bin/soxmix
	ln -sf play $(SOX_IPKG_TMP)/usr/bin/rec
	rm -rf $(SOX_IPKG_TMP)/usr/man
	mkdir -p $(SOX_IPKG_TMP)/CONTROL
	echo "Package: sox" 				>$(SOX_IPKG_TMP)/CONTROL/control
	echo "Priority: optional" 			>>$(SOX_IPKG_TMP)/CONTROL/control
	echo "Section: pdaXrom" 			>>$(SOX_IPKG_TMP)/CONTROL/control
	echo "Maintainer: Alexander Chukov <sash@pdaXrom.org>" >>$(SOX_IPKG_TMP)/CONTROL/control
	echo "Architecture: $(SHORT_TARGET)" 		>>$(SOX_IPKG_TMP)/CONTROL/control
	echo "Version: $(SOX_VERSION)" 			>>$(SOX_IPKG_TMP)/CONTROL/control
	echo "Depends: libmad" 				>>$(SOX_IPKG_TMP)/CONTROL/control
	echo "Description: SoX (also known as Sound eXchange) translates sound files between different file formats, and optionally applies various sound effects.">>$(SOX_IPKG_TMP)/CONTROL/control
	cd $(FEEDDIR) && $(XMKIPKG) $(SOX_IPKG_TMP)
	touch $@

# ----------------------------------------------------------------------------
# Image-Install
# ----------------------------------------------------------------------------

ifdef PTXCONF_SOX_INSTALL
ROMPACKAGES += $(STATEDIR)/sox.imageinstall
endif

sox_imageinstall_deps = $(STATEDIR)/sox.targetinstall \
	$(STATEDIR)/virtual-image.install

$(STATEDIR)/sox.imageinstall: $(sox_imageinstall_deps)
	@$(call targetinfo, $@)
	cd $(FEEDDIR) && $(XIPKG) install sox
	touch $@

# ----------------------------------------------------------------------------
# Clean
# ----------------------------------------------------------------------------

sox_clean:
	rm -rf $(STATEDIR)/sox.*
	rm -rf $(SOX_DIR)

# vim: syntax=make
