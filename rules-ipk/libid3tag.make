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
ifdef PTXCONF_LIBID3TAG
PACKAGES += libid3tag
endif

#
# Paths and names
#
LIBID3TAG_VERSION	= 0.15.1b
LIBID3TAG		= libid3tag-$(LIBID3TAG_VERSION)
LIBID3TAG_SUFFIX	= tar.gz
LIBID3TAG_URL		= ftp://ftp.mars.org/mpeg/$(LIBID3TAG).$(LIBID3TAG_SUFFIX)
LIBID3TAG_SOURCE	= $(SRCDIR)/$(LIBID3TAG).$(LIBID3TAG_SUFFIX)
LIBID3TAG_DIR		= $(BUILDDIR)/$(LIBID3TAG)
LIBID3TAG_IPKG_TMP	= $(LIBID3TAG_DIR)/ipkg_tmp

# ----------------------------------------------------------------------------
# Get
# ----------------------------------------------------------------------------

libid3tag_get: $(STATEDIR)/libid3tag.get

libid3tag_get_deps = $(LIBID3TAG_SOURCE)

$(STATEDIR)/libid3tag.get: $(libid3tag_get_deps)
	@$(call targetinfo, $@)
	@$(call get_patches, $(LIBID3TAG))
	touch $@

$(LIBID3TAG_SOURCE):
	@$(call targetinfo, $@)
	@$(call get, $(LIBID3TAG_URL))

# ----------------------------------------------------------------------------
# Extract
# ----------------------------------------------------------------------------

libid3tag_extract: $(STATEDIR)/libid3tag.extract

libid3tag_extract_deps = $(STATEDIR)/libid3tag.get

$(STATEDIR)/libid3tag.extract: $(libid3tag_extract_deps)
	@$(call targetinfo, $@)
	@$(call clean, $(LIBID3TAG_DIR))
	@$(call extract, $(LIBID3TAG_SOURCE))
	@$(call patchin, $(LIBID3TAG))
	touch $@

# ----------------------------------------------------------------------------
# Prepare
# ----------------------------------------------------------------------------

libid3tag_prepare: $(STATEDIR)/libid3tag.prepare

#
# dependencies
#
libid3tag_prepare_deps = \
	$(STATEDIR)/libid3tag.extract \
	$(STATEDIR)/virtual-xchain.install
	
ifdef PTXCONF_LIBICONV
libid3tag_prepare_deps += $(STATEDIR)/libiconv.install
endif

LIBID3TAG_PATH	=  PATH=$(CROSS_PATH)
LIBID3TAG_ENV 	=  $(CROSS_ENV)
#LIBID3TAG_ENV	+=
LIBID3TAG_ENV	+= PKG_CONFIG_PATH=$(CROSS_LIB_DIR)/lib/pkgconfig:$(CROSS_LIB_DIR)/lib/pkgconfig
#ifdef PTXCONF_XFREE430
#LIBID3TAG_ENV	+= LDFLAGS=-Wl,-rpath-link,$(CROSS_LIB_DIR)/lib
#endif

#
# autoconf
#
LIBID3TAG_AUTOCONF = \
	--build=$(GNU_HOST) \
	--host=$(PTXCONF_GNU_TARGET) \
	--prefix=/usr \
	--enable-shared \
	--disable-static

ifdef PTXCONF_XFREE430
LIBID3TAG_AUTOCONF += --x-includes=$(CROSS_LIB_DIR)/include
LIBID3TAG_AUTOCONF += --x-libraries=$(CROSS_LIB_DIR)/lib
endif

$(STATEDIR)/libid3tag.prepare: $(libid3tag_prepare_deps)
	@$(call targetinfo, $@)
	@$(call clean, $(LIBID3TAG_DIR)/config.cache)
	cd $(LIBID3TAG_DIR) && \
		$(LIBID3TAG_PATH) $(LIBID3TAG_ENV) \
		./configure $(LIBID3TAG_AUTOCONF)
	touch $@

# ----------------------------------------------------------------------------
# Compile
# ----------------------------------------------------------------------------

libid3tag_compile: $(STATEDIR)/libid3tag.compile

libid3tag_compile_deps = $(STATEDIR)/libid3tag.prepare

$(STATEDIR)/libid3tag.compile: $(libid3tag_compile_deps)
	@$(call targetinfo, $@)
	$(LIBID3TAG_PATH) $(MAKE) -C $(LIBID3TAG_DIR)
	touch $@

# ----------------------------------------------------------------------------
# Install
# ----------------------------------------------------------------------------

libid3tag_install: $(STATEDIR)/libid3tag.install

$(STATEDIR)/libid3tag.install: $(STATEDIR)/libid3tag.compile
	@$(call targetinfo, $@)
	$(LIBID3TAG_PATH) $(MAKE) -C $(LIBID3TAG_DIR) install DESTDIR=$(LIBID3TAG_IPKG_TMP)
	cp -a  $(LIBID3TAG_IPKG_TMP)/usr/include/* $(CROSS_LIB_DIR)/include
	cp -a  $(LIBID3TAG_IPKG_TMP)/usr/lib/*     $(CROSS_LIB_DIR)/lib
	rm -rf $(LIBID3TAG_IPKG_TMP)
	perl -p -i -e "s/\/usr\/lib/`echo $(PTXCONF_PREFIX)/$(PTXCONF_GNU_TARGET)/lib | sed -e '/\//s//\\\\\//g'`/g" $(PTXCONF_PREFIX)/$(PTXCONF_GNU_TARGET)/lib/libid3tag.la
	touch $@

# ----------------------------------------------------------------------------
# Target-Install
# ----------------------------------------------------------------------------

libid3tag_targetinstall: $(STATEDIR)/libid3tag.targetinstall

libid3tag_targetinstall_deps = $(STATEDIR)/libid3tag.compile

$(STATEDIR)/libid3tag.targetinstall: $(libid3tag_targetinstall_deps)
	@$(call targetinfo, $@)
	$(LIBID3TAG_PATH) $(MAKE) -C $(LIBID3TAG_DIR) DESTDIR=$(LIBID3TAG_IPKG_TMP) install
	rm -rf $(LIBID3TAG_IPKG_TMP)/usr/include
	rm -rf $(LIBID3TAG_IPKG_TMP)/usr/lib/libid3tag.la
	$(CROSSSTRIP) $(LIBID3TAG_IPKG_TMP)/usr/lib/libid3tag.so.0.3.0
	mkdir -p $(LIBID3TAG_IPKG_TMP)/CONTROL
	echo "Package: libid3tag" 			>$(LIBID3TAG_IPKG_TMP)/CONTROL/control
	echo "Priority: optional" 			>>$(LIBID3TAG_IPKG_TMP)/CONTROL/control
	echo "Section: Multimedia" 			>>$(LIBID3TAG_IPKG_TMP)/CONTROL/control
	echo "Maintainer: Alexander Chukov <sash@pdaXrom.org>" >>$(LIBID3TAG_IPKG_TMP)/CONTROL/control
	echo "Architecture: $(SHORT_TARGET)" 		>>$(LIBID3TAG_IPKG_TMP)/CONTROL/control
	echo "Version: $(LIBID3TAG_VERSION)" 		>>$(LIBID3TAG_IPKG_TMP)/CONTROL/control
	echo "Depends: " 				>>$(LIBID3TAG_IPKG_TMP)/CONTROL/control
	echo "Description: libid3tag is a library for reading and (eventually) writing ID3 tags, both ID3v1 and the various versions of ID3v2.">>$(LIBID3TAG_IPKG_TMP)/CONTROL/control
	cd $(FEEDDIR) && $(XMKIPKG) $(LIBID3TAG_IPKG_TMP)
	touch $@

# ----------------------------------------------------------------------------
# Image-Install
# ----------------------------------------------------------------------------

ifdef PTXCONF_LIBID3TAG_INSTALL
ROMPACKAGES += $(STATEDIR)/libid3tag.imageinstall
endif

libid3tag_imageinstall_deps = $(STATEDIR)/libid3tag.targetinstall \
	$(STATEDIR)/virtual-image.install

$(STATEDIR)/libid3tag.imageinstall: $(libid3tag_imageinstall_deps)
	@$(call targetinfo, $@)
	cd $(FEEDDIR) && $(XIPKG) install libid3tag
	touch $@

# ----------------------------------------------------------------------------
# Clean
# ----------------------------------------------------------------------------

libid3tag_clean:
	rm -rf $(STATEDIR)/libid3tag.*
	rm -rf $(LIBID3TAG_DIR)

# vim: syntax=make
