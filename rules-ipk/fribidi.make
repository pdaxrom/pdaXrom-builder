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
ifdef PTXCONF_FRIBIDI
PACKAGES += fribidi
endif

#
# Paths and names
#
FRIBIDI_VERSION		= 0.10.4
FRIBIDI			= fribidi-$(FRIBIDI_VERSION)
FRIBIDI_SUFFIX		= tar.bz2
FRIBIDI_URL		= http://heanet.dl.sourceforge.net/sourceforge/fribidi/$(FRIBIDI).$(FRIBIDI_SUFFIX)
FRIBIDI_SOURCE		= $(SRCDIR)/$(FRIBIDI).$(FRIBIDI_SUFFIX)
FRIBIDI_DIR		= $(BUILDDIR)/$(FRIBIDI)
FRIBIDI_IPKG_TMP	= $(FRIBIDI_DIR)/ipkg_tmp

# ----------------------------------------------------------------------------
# Get
# ----------------------------------------------------------------------------

fribidi_get: $(STATEDIR)/fribidi.get

fribidi_get_deps = $(FRIBIDI_SOURCE)

$(STATEDIR)/fribidi.get: $(fribidi_get_deps)
	@$(call targetinfo, $@)
	@$(call get_patches, $(FRIBIDI))
	touch $@

$(FRIBIDI_SOURCE):
	@$(call targetinfo, $@)
	@$(call get, $(FRIBIDI_URL))

# ----------------------------------------------------------------------------
# Extract
# ----------------------------------------------------------------------------

fribidi_extract: $(STATEDIR)/fribidi.extract

fribidi_extract_deps = $(STATEDIR)/fribidi.get

$(STATEDIR)/fribidi.extract: $(fribidi_extract_deps)
	@$(call targetinfo, $@)
	@$(call clean, $(FRIBIDI_DIR))
	@$(call extract, $(FRIBIDI_SOURCE))
	@$(call patchin, $(FRIBIDI))
	touch $@

# ----------------------------------------------------------------------------
# Prepare
# ----------------------------------------------------------------------------

fribidi_prepare: $(STATEDIR)/fribidi.prepare

#
# dependencies
#
fribidi_prepare_deps = \
	$(STATEDIR)/fribidi.extract \
	$(STATEDIR)/virtual-xchain.install

FRIBIDI_PATH	=  PATH=$(CROSS_PATH)
FRIBIDI_ENV 	=  $(CROSS_ENV)
#FRIBIDI_ENV	+=
FRIBIDI_ENV	+= PKG_CONFIG_PATH=$(CROSS_LIB_DIR)/lib/pkgconfig:$(CROSS_LIB_DIR)/lib/pkgconfig
#ifdef PTXCONF_XFREE430
#FRIBIDI_ENV	+= LDFLAGS=-Wl,-rpath-link,$(CROSS_LIB_DIR)/lib
#endif

#
# autoconf
#
FRIBIDI_AUTOCONF = \
	--build=$(GNU_HOST) \
	--host=$(PTXCONF_GNU_TARGET) \
	--prefix=/usr \
	--enable-shared \
	--disable-static

ifdef PTXCONF_XFREE430
FRIBIDI_AUTOCONF += --x-includes=$(CROSS_LIB_DIR)/include
FRIBIDI_AUTOCONF += --x-libraries=$(CROSS_LIB_DIR)/lib
endif

$(STATEDIR)/fribidi.prepare: $(fribidi_prepare_deps)
	@$(call targetinfo, $@)
	@$(call clean, $(FRIBIDI_DIR)/config.cache)
	cd $(FRIBIDI_DIR) && \
		$(FRIBIDI_PATH) $(FRIBIDI_ENV) \
		./configure $(FRIBIDI_AUTOCONF)
	touch $@

# ----------------------------------------------------------------------------
# Compile
# ----------------------------------------------------------------------------

fribidi_compile: $(STATEDIR)/fribidi.compile

fribidi_compile_deps = $(STATEDIR)/fribidi.prepare

$(STATEDIR)/fribidi.compile: $(fribidi_compile_deps)
	@$(call targetinfo, $@)
	$(FRIBIDI_PATH) $(MAKE) -C $(FRIBIDI_DIR)
	touch $@

# ----------------------------------------------------------------------------
# Install
# ----------------------------------------------------------------------------

fribidi_install: $(STATEDIR)/fribidi.install

$(STATEDIR)/fribidi.install: $(STATEDIR)/fribidi.compile
	@$(call targetinfo, $@)
	$(FRIBIDI_PATH) $(MAKE) -C $(FRIBIDI_DIR) DESTDIR=$(FRIBIDI_IPKG_TMP) install
	cp -a  $(FRIBIDI_IPKG_TMP)/usr/include/*          $(CROSS_LIB_DIR)/include
	cp -a  $(FRIBIDI_IPKG_TMP)/usr/lib/*              $(CROSS_LIB_DIR)/lib
	cp -a  $(FRIBIDI_IPKG_TMP)/usr/bin/fribidi-config $(PTXCONF_PREFIX)/bin
	perl -p -i -e "s/\/usr/`echo $(PTXCONF_PREFIX)/$(PTXCONF_GNU_TARGET) | sed -e '/\//s//\\\\\//g'`/g" $(PTXCONF_PREFIX)/bin/fribidi-config
	perl -p -i -e "s/\/usr\/lib/`echo $(PTXCONF_PREFIX)/$(PTXCONF_GNU_TARGET)/lib | sed -e '/\//s//\\\\\//g'`/g" $(PTXCONF_PREFIX)/$(PTXCONF_GNU_TARGET)/lib/libfribidi.la
	perl -p -i -e "s/\/usr/`echo $(PTXCONF_PREFIX)/$(PTXCONF_GNU_TARGET) | sed -e '/\//s//\\\\\//g'`/g" $(PTXCONF_PREFIX)/$(PTXCONF_GNU_TARGET)/lib/pkgconfig/fribidi.pc
	rm -rf $(FRIBIDI_IPKG_TMP)
	touch $@

# ----------------------------------------------------------------------------
# Target-Install
# ----------------------------------------------------------------------------

fribidi_targetinstall: $(STATEDIR)/fribidi.targetinstall

fribidi_targetinstall_deps = $(STATEDIR)/fribidi.compile

$(STATEDIR)/fribidi.targetinstall: $(fribidi_targetinstall_deps)
	@$(call targetinfo, $@)
	$(FRIBIDI_PATH) $(MAKE) -C $(FRIBIDI_DIR) DESTDIR=$(FRIBIDI_IPKG_TMP) install
	rm  -f $(FRIBIDI_IPKG_TMP)/usr/bin/fribidi-config
	rm -rf $(FRIBIDI_IPKG_TMP)/usr/include
	rm -rf $(FRIBIDI_IPKG_TMP)/usr/lib/pkgconfig
	rm  -f $(FRIBIDI_IPKG_TMP)/usr/lib/*.*a
	$(CROSSSTRIP) $(FRIBIDI_IPKG_TMP)/usr/bin/*
	$(CROSSSTRIP) $(FRIBIDI_IPKG_TMP)/usr/lib/*
	mkdir -p $(FRIBIDI_IPKG_TMP)/CONTROL
	echo "Package: fribidi" 			>$(FRIBIDI_IPKG_TMP)/CONTROL/control
	echo "Priority: optional" 			>>$(FRIBIDI_IPKG_TMP)/CONTROL/control
	echo "Section: Libraries" 			>>$(FRIBIDI_IPKG_TMP)/CONTROL/control
	echo "Maintainer: Alexander Chukov <sash@pdaXrom.org>" >>$(FRIBIDI_IPKG_TMP)/CONTROL/control
	echo "Architecture: $(SHORT_TARGET)" 		>>$(FRIBIDI_IPKG_TMP)/CONTROL/control
	echo "Version: $(FRIBIDI_VERSION)" 		>>$(FRIBIDI_IPKG_TMP)/CONTROL/control
	echo "Depends: " 				>>$(FRIBIDI_IPKG_TMP)/CONTROL/control
	echo "Description: A Free Implementation of the Unicode Bidirectional Algorithm">>$(FRIBIDI_IPKG_TMP)/CONTROL/control
	cd $(FEEDDIR) && $(XMKIPKG) $(FRIBIDI_IPKG_TMP)
	touch $@

# ----------------------------------------------------------------------------
# Clean
# ----------------------------------------------------------------------------

fribidi_clean:
	rm -rf $(STATEDIR)/fribidi.*
	rm -rf $(FRIBIDI_DIR)

# vim: syntax=make
