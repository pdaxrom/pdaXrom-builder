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
ifdef PTXCONF_AUDIOFILE
PACKAGES += audiofile
endif

#
# Paths and names
#
AUDIOFILE_VERSION	= 0.2.6
AUDIOFILE		= audiofile-$(AUDIOFILE_VERSION)
AUDIOFILE_SUFFIX	= tar.gz
AUDIOFILE_URL		= http://gentoo.seren.com/gentoo/distfiles/$(AUDIOFILE).$(AUDIOFILE_SUFFIX)
AUDIOFILE_SOURCE	= $(SRCDIR)/$(AUDIOFILE).$(AUDIOFILE_SUFFIX)
AUDIOFILE_DIR		= $(BUILDDIR)/$(AUDIOFILE)
AUDIOFILE_IPKG_TMP	= $(AUDIOFILE_DIR)/ipkg_tmp

# ----------------------------------------------------------------------------
# Get
# ----------------------------------------------------------------------------

audiofile_get: $(STATEDIR)/audiofile.get

audiofile_get_deps = $(AUDIOFILE_SOURCE)

$(STATEDIR)/audiofile.get: $(audiofile_get_deps)
	@$(call targetinfo, $@)
	@$(call get_patches, $(AUDIOFILE))
	touch $@

$(AUDIOFILE_SOURCE):
	@$(call targetinfo, $@)
	@$(call get, $(AUDIOFILE_URL))

# ----------------------------------------------------------------------------
# Extract
# ----------------------------------------------------------------------------

audiofile_extract: $(STATEDIR)/audiofile.extract

audiofile_extract_deps = $(STATEDIR)/audiofile.get

$(STATEDIR)/audiofile.extract: $(audiofile_extract_deps)
	@$(call targetinfo, $@)
	@$(call clean, $(AUDIOFILE_DIR))
	@$(call extract, $(AUDIOFILE_SOURCE))
	@$(call patchin, $(AUDIOFILE))
	touch $@

# ----------------------------------------------------------------------------
# Prepare
# ----------------------------------------------------------------------------

audiofile_prepare: $(STATEDIR)/audiofile.prepare

#
# dependencies
#
audiofile_prepare_deps = \
	$(STATEDIR)/audiofile.extract \
	$(STATEDIR)/virtual-xchain.install

AUDIOFILE_PATH	=  PATH=$(CROSS_PATH)
AUDIOFILE_ENV 	=  $(CROSS_ENV)
#AUDIOFILE_ENV	+=
AUDIOFILE_ENV	+= PKG_CONFIG_PATH=$(CROSS_LIB_DIR)/lib/pkgconfig:$(CROSS_LIB_DIR)/lib/pkgconfig
#ifdef PTXCONF_XFREE430
#AUDIOFILE_ENV	+= LDFLAGS=-Wl,-rpath-link,$(CROSS_LIB_DIR)/lib
#endif

#
# autoconf
#
AUDIOFILE_AUTOCONF = \
	--build=$(GNU_HOST) \
	--host=$(PTXCONF_GNU_TARGET) \
	--prefix=/usr \
	--disable-static \
	--enable-shared

ifdef PTXCONF_XFREE430
AUDIOFILE_AUTOCONF += --x-includes=$(CROSS_LIB_DIR)/include
AUDIOFILE_AUTOCONF += --x-libraries=$(CROSS_LIB_DIR)/lib
endif

$(STATEDIR)/audiofile.prepare: $(audiofile_prepare_deps)
	@$(call targetinfo, $@)
	@$(call clean, $(AUDIOFILE_DIR)/config.cache)
	cd $(AUDIOFILE_DIR) && \
		$(AUDIOFILE_PATH) $(AUDIOFILE_ENV) \
		./configure $(AUDIOFILE_AUTOCONF)
	touch $@

# ----------------------------------------------------------------------------
# Compile
# ----------------------------------------------------------------------------

audiofile_compile: $(STATEDIR)/audiofile.compile

audiofile_compile_deps = $(STATEDIR)/audiofile.prepare

$(STATEDIR)/audiofile.compile: $(audiofile_compile_deps)
	@$(call targetinfo, $@)
	$(AUDIOFILE_PATH) $(MAKE) -C $(AUDIOFILE_DIR)
	touch $@

# ----------------------------------------------------------------------------
# Install
# ----------------------------------------------------------------------------

audiofile_install: $(STATEDIR)/audiofile.install

$(STATEDIR)/audiofile.install: $(STATEDIR)/audiofile.compile
	@$(call targetinfo, $@)
	###mkdir -p $(CROSS_LIB_DIR)/share/aclocal/
	$(AUDIOFILE_PATH) $(MAKE) -C $(AUDIOFILE_DIR) DESTDIR=$(AUDIOFILE_IPKG_TMP) install
	cp -a  $(AUDIOFILE_IPKG_TMP)/usr/include/* $(CROSS_LIB_DIR)/include
	cp -a  $(AUDIOFILE_IPKG_TMP)/usr/lib/*     $(CROSS_LIB_DIR)/lib
	cp -a  $(AUDIOFILE_IPKG_TMP)/usr/share/aclocal/*  $(PTXCONF_PREFIX)/share/aclocal/
	cp -a  $(AUDIOFILE_IPKG_TMP)/usr/bin/*-config     $(PTXCONF_PREFIX)/bin
	rm -rf $(AUDIOFILE_IPKG_TMP)
	perl -p -i -e "s/\/usr/`echo $(PTXCONF_PREFIX)/$(PTXCONF_GNU_TARGET) | sed -e '/\//s//\\\\\//g'`/g" $(PTXCONF_PREFIX)/bin/audiofile-config
	perl -p -i -e "s/\/usr\/lib/`echo $(PTXCONF_PREFIX)/$(PTXCONF_GNU_TARGET)/lib | sed -e '/\//s//\\\\\//g'`/g" $(PTXCONF_PREFIX)/$(PTXCONF_GNU_TARGET)/lib/libaudiofile.la
	perl -p -i -e "s/\/usr/`echo $(PTXCONF_PREFIX)/$(PTXCONF_GNU_TARGET) | sed -e '/\//s//\\\\\//g'`/g" $(PTXCONF_PREFIX)/$(PTXCONF_GNU_TARGET)/lib/pkgconfig/audiofile.pc
	touch $@

# ----------------------------------------------------------------------------
# Target-Install
# ----------------------------------------------------------------------------

audiofile_targetinstall: $(STATEDIR)/audiofile.targetinstall

audiofile_targetinstall_deps = $(STATEDIR)/audiofile.compile

$(STATEDIR)/audiofile.targetinstall: $(audiofile_targetinstall_deps)
	@$(call targetinfo, $@)
	$(AUDIOFILE_PATH) $(MAKE) -C $(AUDIOFILE_DIR) DESTDIR=$(AUDIOFILE_IPKG_TMP) install
	rm  -f $(AUDIOFILE_IPKG_TMP)/usr/bin/audiofile-config
	$(CROSSSTRIP) $(AUDIOFILE_IPKG_TMP)/usr/bin/*
	rm -rf $(AUDIOFILE_IPKG_TMP)/usr/include
	rm -rf $(AUDIOFILE_IPKG_TMP)/usr/lib/pkgconfig
	rm  -f $(AUDIOFILE_IPKG_TMP)/usr/lib/*.la
	$(CROSSSTRIP) $(AUDIOFILE_IPKG_TMP)/usr/lib/*.so
	rm -rf $(AUDIOFILE_IPKG_TMP)/usr/share
	mkdir -p $(AUDIOFILE_IPKG_TMP)/CONTROL
	echo "Package: audiofile" 			>$(AUDIOFILE_IPKG_TMP)/CONTROL/control
	echo "Priority: optional" 			>>$(AUDIOFILE_IPKG_TMP)/CONTROL/control
	echo "Section: Libraries" 			>>$(AUDIOFILE_IPKG_TMP)/CONTROL/control
	echo "Maintainer: Alexander Chukov <sash@pdaXrom.org>">>$(AUDIOFILE_IPKG_TMP)/CONTROL/control
	echo "Architecture: $(SHORT_TARGET)" 		>>$(AUDIOFILE_IPKG_TMP)/CONTROL/control
	echo "Version: $(AUDIOFILE_VERSION)" 		>>$(AUDIOFILE_IPKG_TMP)/CONTROL/control
	echo "Depends: " 				>>$(AUDIOFILE_IPKG_TMP)/CONTROL/control
	echo "Description: The Audio File Library provides a uniform programming interface to standard digital audio file formats.">>$(AUDIOFILE_IPKG_TMP)/CONTROL/control
	cd $(FEEDDIR) && $(XMKIPKG) $(AUDIOFILE_IPKG_TMP)
	touch $@

# ----------------------------------------------------------------------------
# Clean
# ----------------------------------------------------------------------------

audiofile_clean:
	rm -rf $(STATEDIR)/audiofile.*
	rm -rf $(AUDIOFILE_DIR)

# vim: syntax=make
