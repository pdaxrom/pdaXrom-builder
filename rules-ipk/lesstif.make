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
ifdef PTXCONF_LESSTIF
PACKAGES += lesstif
endif

#
# Paths and names
#
LESSTIF_VERSION		= 0.93.94
LESSTIF			= lesstif-$(LESSTIF_VERSION)
LESSTIF_SUFFIX		= tar.bz2
LESSTIF_URL		= http://heanet.dl.sourceforge.net/sourceforge/lesstif/$(LESSTIF).$(LESSTIF_SUFFIX)
LESSTIF_SOURCE		= $(SRCDIR)/$(LESSTIF).$(LESSTIF_SUFFIX)
LESSTIF_DIR		= $(BUILDDIR)/$(LESSTIF)
LESSTIF_IPKG_TMP	= $(LESSTIF_DIR)/ipkg_tmp

# ----------------------------------------------------------------------------
# Get
# ----------------------------------------------------------------------------

lesstif_get: $(STATEDIR)/lesstif.get

lesstif_get_deps = $(LESSTIF_SOURCE)

$(STATEDIR)/lesstif.get: $(lesstif_get_deps)
	@$(call targetinfo, $@)
	@$(call get_patches, $(LESSTIF))
	touch $@

$(LESSTIF_SOURCE):
	@$(call targetinfo, $@)
	@$(call get, $(LESSTIF_URL))

# ----------------------------------------------------------------------------
# Extract
# ----------------------------------------------------------------------------

lesstif_extract: $(STATEDIR)/lesstif.extract

lesstif_extract_deps = $(STATEDIR)/lesstif.get

$(STATEDIR)/lesstif.extract: $(lesstif_extract_deps)
	@$(call targetinfo, $@)
	@$(call clean, $(LESSTIF_DIR))
	@$(call extract, $(LESSTIF_SOURCE))
	@$(call patchin, $(LESSTIF))
	touch $@

# ----------------------------------------------------------------------------
# Prepare
# ----------------------------------------------------------------------------

lesstif_prepare: $(STATEDIR)/lesstif.prepare

#
# dependencies
#
lesstif_prepare_deps = \
	$(STATEDIR)/lesstif.extract \
	$(STATEDIR)/xfree430.install \
	$(STATEDIR)/virtual-xchain.install

LESSTIF_PATH	=  PATH=$(CROSS_PATH)
LESSTIF_ENV 	=  $(CROSS_ENV)
LESSTIF_ENV	+= CFLAGS="$(TARGET_OPT_CFLAGS)"
LESSTIF_ENV	+= CXXFLAGS="$(TARGET_OPT_CFLAGS)"
LESSTIF_ENV	+= PKG_CONFIG_PATH=$(CROSS_LIB_DIR)/lib/pkgconfig:$(CROSS_LIB_DIR)/lib/pkgconfig
#ifdef PTXCONF_XFREE430
#LESSTIF_ENV	+= LDFLAGS=-Wl,-rpath-link,$(CROSS_LIB_DIR)/lib
#endif

LESSTIF_ENV	+= ac_cv_header_freetype_freetype_h=yes

#
# autoconf
#
LESSTIF_AUTOCONF = \
	--build=$(GNU_HOST) \
	--host=$(PTXCONF_GNU_TARGET) \
	--prefix=/usr/X11R6 \
	--sysconfdir=/etc \
	--with-fontconfig-includes=$(CROSS_LIB_DIR)/include \
	--with-fontconfig-lib=$(CROSS_LIB_DIR)/lib

ifdef PTXCONF_XFREE430
LESSTIF_AUTOCONF += --x-includes=$(CROSS_LIB_DIR)/include
LESSTIF_AUTOCONF += --x-libraries=$(CROSS_LIB_DIR)/lib
endif

$(STATEDIR)/lesstif.prepare: $(lesstif_prepare_deps)
	@$(call targetinfo, $@)
	@$(call clean, $(LESSTIF_DIR)/config.cache)
	cd $(LESSTIF_DIR) && \
		$(LESSTIF_PATH) $(LESSTIF_ENV) \
		./configure $(LESSTIF_AUTOCONF)
	touch $@

# ----------------------------------------------------------------------------
# Compile
# ----------------------------------------------------------------------------

lesstif_compile: $(STATEDIR)/lesstif.compile

lesstif_compile_deps = $(STATEDIR)/lesstif.prepare

$(STATEDIR)/lesstif.compile: $(lesstif_compile_deps)
	@$(call targetinfo, $@)
	gcc $(LESSTIF_DIR)/scripts/man2html.c -c -o $(LESSTIF_DIR)/scripts/man2html.o
	gcc $(LESSTIF_DIR)/scripts/man2html.o    -o $(LESSTIF_DIR)/scripts/man2html
	$(LESSTIF_PATH) $(MAKE) -C $(LESSTIF_DIR)
	touch $@

# ----------------------------------------------------------------------------
# Install
# ----------------------------------------------------------------------------

lesstif_install: $(STATEDIR)/lesstif.install

$(STATEDIR)/lesstif.install: $(STATEDIR)/lesstif.compile
	@$(call targetinfo, $@)
	$(LESSTIF_PATH) $(MAKE) -C $(LESSTIF_DIR) DESTDIR=$(LESSTIF_IPKG_TMP) install
	rm -rf $(LESSTIF_IPKG_TMP)/usr/X11R6/lib/LessTif
	rm -rf $(LESSTIF_IPKG_TMP)/usr/X11R6/lib/X11
	cp -a  $(LESSTIF_IPKG_TMP)/usr/X11R6/include/* 		$(CROSS_LIB_DIR)/include
	cp -a  $(LESSTIF_IPKG_TMP)/usr/X11R6/lib/*     		$(CROSS_LIB_DIR)/lib
	perl -p -i -e "s/\/usr\/X11R6\/lib/`echo $(CROSS_LIB_DIR)/lib | sed -e '/\//s//\\\\\//g'`/g" $(CROSS_LIB_DIR)/lib/libMrm.la
	perl -p -i -e "s/\/usr\/X11R6\/lib/`echo $(CROSS_LIB_DIR)/lib | sed -e '/\//s//\\\\\//g'`/g" $(CROSS_LIB_DIR)/lib/libUil.la
	perl -p -i -e "s/\/usr\/X11R6\/lib/`echo $(CROSS_LIB_DIR)/lib | sed -e '/\//s//\\\\\//g'`/g" $(CROSS_LIB_DIR)/lib/libXm.la
	rm -rf $(LESSTIF_IPKG_TMP)
	touch $@

# ----------------------------------------------------------------------------
# Target-Install
# ----------------------------------------------------------------------------

lesstif_targetinstall: $(STATEDIR)/lesstif.targetinstall

lesstif_targetinstall_deps = $(STATEDIR)/lesstif.compile \
	$(STATEDIR)/xfree430.targetinstall

$(STATEDIR)/lesstif.targetinstall: $(lesstif_targetinstall_deps)
	@$(call targetinfo, $@)
	$(LESSTIF_PATH) $(MAKE) -C $(LESSTIF_DIR) DESTDIR=$(LESSTIF_IPKG_TMP) install
	rm -rf $(LESSTIF_IPKG_TMP)/usr/X11R6/LessTif
	rm -rf $(LESSTIF_IPKG_TMP)/usr/X11R6/man
	rm -rf $(LESSTIF_IPKG_TMP)/usr/X11R6/bin/mxmkmf
	rm -rf $(LESSTIF_IPKG_TMP)/usr/X11R6/include
	rm -rf $(LESSTIF_IPKG_TMP)/usr/X11R6/lib/LessTif
	rm -rf $(LESSTIF_IPKG_TMP)/usr/X11R6/lib/*.la
	rm -rf $(LESSTIF_IPKG_TMP)/opt
	$(CROSSSTRIP) $(LESSTIF_IPKG_TMP)/usr/X11R6/bin/*
	$(CROSSSTRIP) $(LESSTIF_IPKG_TMP)/usr/X11R6/lib/*.so*
	mkdir -p $(LESSTIF_IPKG_TMP)/CONTROL
	echo "Package: lesstif" 				 >$(LESSTIF_IPKG_TMP)/CONTROL/control
	echo "Priority: optional" 				>>$(LESSTIF_IPKG_TMP)/CONTROL/control
	echo "Section: X11"	 				>>$(LESSTIF_IPKG_TMP)/CONTROL/control
	echo "Maintainer: Alexander Chukov <sash@pdaXrom.org>" 	>>$(LESSTIF_IPKG_TMP)/CONTROL/control
	echo "Architecture: $(SHORT_TARGET)" 			>>$(LESSTIF_IPKG_TMP)/CONTROL/control
	echo "Version: $(LESSTIF_VERSION)" 			>>$(LESSTIF_IPKG_TMP)/CONTROL/control
	echo "Depends: xfree430" 				>>$(LESSTIF_IPKG_TMP)/CONTROL/control
	echo "Description: LessTif is the Hungry Programmers' version of OSF/Motif(R). It aims to be source compatible meaning that the same source code should compile with both and work exactly the same!">>$(LESSTIF_IPKG_TMP)/CONTROL/control
	cd $(FEEDDIR) && $(XMKIPKG) $(LESSTIF_IPKG_TMP)
	touch $@

# ----------------------------------------------------------------------------
# Image-Install
# ----------------------------------------------------------------------------

ifdef PTXCONF_LESSTIF_INSTALL
ROMPACKAGES += $(STATEDIR)/lesstif.imageinstall
endif

lesstif_imageinstall_deps = $(STATEDIR)/lesstif.targetinstall \
	$(STATEDIR)/virtual-image.install

$(STATEDIR)/lesstif.imageinstall: $(lesstif_imageinstall_deps)
	@$(call targetinfo, $@)
	cd $(FEEDDIR) && $(XIPKG) install lesstif
	touch $@

# ----------------------------------------------------------------------------
# Clean
# ----------------------------------------------------------------------------

lesstif_clean:
	rm -rf $(STATEDIR)/lesstif.*
	rm -rf $(LESSTIF_DIR)

# vim: syntax=make
