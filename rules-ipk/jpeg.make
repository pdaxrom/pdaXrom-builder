# -*-makefile-*-
# $Id: template,v 1.10 2004/01/24 15:50:34 mkl Exp $
#
# Copyright (C) 2004 by Alexander Chukov <sash@cacko.biz>
#          
# See CREDITS for details about who has contributed to this project.
#
# For further information about the PTXdist project and license conditions
# see the README file.
#

#
# We provide this package
#
ifdef PTXCONF_JPEG
PACKAGES += jpeg
endif

#
# Paths and names
#
JPEG_VERSION		= 6b
JPEG			= jpeg-$(JPEG_VERSION)
JPEG_SUFFIX		= tar.gz
JPEG_URL		= http://www.ijg.org/files/jpegsrc.v6b.$(JPEG_SUFFIX)
JPEG_SOURCE		= $(SRCDIR)/jpegsrc.v6b.$(JPEG_SUFFIX)
JPEG_DIR		= $(BUILDDIR)/$(JPEG)
JPEG_IPKG_TMP		= $(JPEG_DIR)/ipkg_tmp

# ----------------------------------------------------------------------------
# Get
# ----------------------------------------------------------------------------

jpeg_get: $(STATEDIR)/jpeg.get

jpeg_get_deps = $(JPEG_SOURCE)

$(STATEDIR)/jpeg.get: $(jpeg_get_deps)
	@$(call targetinfo, $@)
	@$(call get_patches, $(JPEG))
	touch $@

$(JPEG_SOURCE):
	@$(call targetinfo, $@)
	@$(call get, $(JPEG_URL))

# ----------------------------------------------------------------------------
# Extract
# ----------------------------------------------------------------------------

jpeg_extract: $(STATEDIR)/jpeg.extract

jpeg_extract_deps = $(STATEDIR)/jpeg.get

$(STATEDIR)/jpeg.extract: $(jpeg_extract_deps)
	@$(call targetinfo, $@)
	@$(call clean, $(JPEG_DIR))
	@$(call extract, $(JPEG_SOURCE))
	@$(call patchin, $(JPEG))
	touch $@

# ----------------------------------------------------------------------------
# Prepare
# ----------------------------------------------------------------------------

jpeg_prepare: $(STATEDIR)/jpeg.prepare

#
# dependencies
#
jpeg_prepare_deps = \
	$(STATEDIR)/jpeg.extract \
	$(STATEDIR)/virtual-xchain.install

JPEG_PATH	=  PATH=$(CROSS_PATH)
JPEG_ENV 	=  $(CROSS_ENV)
JPEG_ENV	+= CFLAGS="$(TARGET_OPT_CFLAGS)"

#
# autoconf
#
JPEG_AUTOCONF = \
	--build=$(GNU_HOST) \
	--host=$(PTXCONF_GNU_TARGET) \
	--prefix=$(CROSS_LIB_DIR)

$(STATEDIR)/jpeg.prepare: $(jpeg_prepare_deps)
	@$(call targetinfo, $@)
	@$(call clean, $(JPEG_DIR)/config.cache)
	cd $(JPEG_DIR) && \
		$(JPEG_PATH) $(JPEG_ENV) \
		./configure $(JPEG_AUTOCONF) --disable-static --enable-shared --disable-debug
	touch $@

# ----------------------------------------------------------------------------
# Compile
# ----------------------------------------------------------------------------

jpeg_compile: $(STATEDIR)/jpeg.compile

jpeg_compile_deps = $(STATEDIR)/jpeg.prepare

$(STATEDIR)/jpeg.compile: $(jpeg_compile_deps)
	@$(call targetinfo, $@)
	$(JPEG_PATH) $(MAKE) -C $(JPEG_DIR)
	touch $@

# ----------------------------------------------------------------------------
# Install
# ----------------------------------------------------------------------------

jpeg_install: $(STATEDIR)/jpeg.install

$(STATEDIR)/jpeg.install: $(STATEDIR)/jpeg.compile
	@$(call targetinfo, $@)
	$(INSTALL) -m 755 -D $(JPEG_DIR)/.libs/libjpeg.so.62.0.0 $(CROSS_LIB_DIR)/lib/libjpeg.so.62.0.0
	ln -sf libjpeg.so.62.0.0 $(CROSS_LIB_DIR)/lib/libjpeg.so.62
	ln -sf libjpeg.so.62.0.0 $(CROSS_LIB_DIR)/lib/libjpeg.so
	install -m 644 -D $(JPEG_DIR)/jconfig.h  $(CROSS_LIB_DIR)/include/jconfig.h
	install -m 644 -D $(JPEG_DIR)/jpeglib.h  $(CROSS_LIB_DIR)/include/jpeglib.h
	install -m 644 -D $(JPEG_DIR)/jmorecfg.h $(CROSS_LIB_DIR)/include/jmorecfg.h
	install -m 644 -D $(JPEG_DIR)/jerror.h   $(CROSS_LIB_DIR)/include/jerror.h
	install -m 644 -D $(JPEG_DIR)/jpegint.h  $(CROSS_LIB_DIR)/include/jpegint.h
	touch $@

# ----------------------------------------------------------------------------
# Target-Install
# ----------------------------------------------------------------------------

jpeg_targetinstall: $(STATEDIR)/jpeg.targetinstall

jpeg_targetinstall_deps = $(STATEDIR)/jpeg.compile

$(STATEDIR)/jpeg.targetinstall: $(jpeg_targetinstall_deps)
	@$(call targetinfo, $@)
	mkdir -p $(JPEG_IPKG_TMP)/usr/lib
	
	$(INSTALL) -m 755 -D $(JPEG_DIR)/.libs/libjpeg.so.62.0.0 $(JPEG_IPKG_TMP)/usr/lib/libjpeg.so.62.0.0
	$(CROSSSTRIP) $(JPEG_IPKG_TMP)/usr/lib/libjpeg.so.62.0.0
	ln -sf libjpeg.so.62.0.0 $(JPEG_IPKG_TMP)/usr/lib/libjpeg.so.62
	ln -sf libjpeg.so.62.0.0 $(JPEG_IPKG_TMP)/usr/lib/libjpeg.so

	mkdir -p $(JPEG_IPKG_TMP)/CONTROL
	echo "Package: libjpeg"	 				 >$(JPEG_IPKG_TMP)/CONTROL/control
	echo "Priority: optional" 				>>$(JPEG_IPKG_TMP)/CONTROL/control
	echo "Section: Libraries"	 			>>$(JPEG_IPKG_TMP)/CONTROL/control
	echo "Maintainer: Alexander Chukov <sash@pdaXrom.org>"	>>$(JPEG_IPKG_TMP)/CONTROL/control
	echo "Architecture: $(SHORT_TARGET)" 			>>$(JPEG_IPKG_TMP)/CONTROL/control
	echo "Version: $(JPEG_VERSION)" 			>>$(JPEG_IPKG_TMP)/CONTROL/control
	echo "Depends: "			 		>>$(JPEG_IPKG_TMP)/CONTROL/control
	echo "Description: Read and saves JPEG files."		>>$(JPEG_IPKG_TMP)/CONTROL/control
	cd $(FEEDDIR) && $(XMKIPKG) $(JPEG_IPKG_TMP)
	
	touch $@

# ----------------------------------------------------------------------------
# Image-Install
# ----------------------------------------------------------------------------

ifdef PTXCONF_JPEG_INSTALL
ROMPACKAGES += $(STATEDIR)/jpeg.imageinstall
endif

jpeg_imageinstall_deps = $(STATEDIR)/jpeg.targetinstall \
	$(STATEDIR)/virtual-image.install

$(STATEDIR)/jpeg.imageinstall: $(jpeg_imageinstall_deps)
	@$(call targetinfo, $@)
	cd $(FEEDDIR) && $(XIPKG) install libjpeg
	touch $@

# ----------------------------------------------------------------------------
# Clean
# ----------------------------------------------------------------------------

jpeg_clean:
	rm -rf $(STATEDIR)/jpeg.*
	rm -rf $(JPEG_DIR)

# vim: syntax=make
