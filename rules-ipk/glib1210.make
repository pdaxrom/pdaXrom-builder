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
ifdef PTXCONF_GLIB1210
PACKAGES += glib1210
endif

#
# Paths and names
#
GLIB1210_VERSION	= 1.2.10-1
GLIB1210		= glib-$(GLIB1210_VERSION)
GLIB1210_SUFFIX		= tar.gz
GLIB1210_URL		= http://developer.ezaurus.com/slj/source/commands/$(GLIB1210).$(GLIB1210_SUFFIX)
GLIB1210_SOURCE		= $(SRCDIR)/$(GLIB1210).$(GLIB1210_SUFFIX)
GLIB1210_DIR		= $(BUILDDIR)/$(GLIB1210)
GLIB1210_IPKG_TMP	= $(GLIB1210_DIR)/ipkg_tmp

# ----------------------------------------------------------------------------
# Get
# ----------------------------------------------------------------------------

glib1210_get: $(STATEDIR)/glib1210.get

glib1210_get_deps = $(GLIB1210_SOURCE)

$(STATEDIR)/glib1210.get: $(glib1210_get_deps)
	@$(call targetinfo, $@)
	@$(call get_patches, $(GLIB1210))
	touch $@

$(GLIB1210_SOURCE):
	@$(call targetinfo, $@)
	@$(call get, $(GLIB1210_URL))

# ----------------------------------------------------------------------------
# Extract
# ----------------------------------------------------------------------------

glib1210_extract: $(STATEDIR)/glib1210.extract

glib1210_extract_deps = $(STATEDIR)/glib1210.get

$(STATEDIR)/glib1210.extract: $(glib1210_extract_deps)
	@$(call targetinfo, $@)
	@$(call clean, $(GLIB1210_DIR))
	@$(call extract, $(GLIB1210_SOURCE))
	@$(call patchin, $(GLIB1210))
	touch $@

# ----------------------------------------------------------------------------
# Prepare
# ----------------------------------------------------------------------------

glib1210_prepare: $(STATEDIR)/glib1210.prepare

#
# dependencies
#
glib1210_prepare_deps = \
	$(STATEDIR)/glib1210.extract \
	$(STATEDIR)/virtual-xchain.install

GLIB1210_PATH	=  PATH=$(CROSS_PATH)
GLIB1210_ENV 	=  $(CROSS_ENV)
GLIB1210_ENV	+= CFLAGS="-O2 -fomit-frame-pointer"
GLIB1210_ENV	+= PKG_CONFIG_PATH=$(CROSS_LIB_DIR)/lib/pkgconfig:$(CROSS_LIB_DIR)/lib/pkgconfig
#ifdef PTXCONF_XFREE430
#GLIB1210_ENV	+= LDFLAGS=-Wl,-rpath-link,$(CROSS_LIB_DIR)/lib
#endif

#
# autoconf
#
GLIB1210_AUTOCONF = \
	--build=$(GNU_HOST) \
	--host=$(PTXCONF_GNU_TARGET) \
	--prefix=/usr \
	--with-threads=posix \
	--enable-shared \
	--disable-static \
	--sysconfdir=/etc

ifdef PTXCONF_XFREE430
GLIB1210_AUTOCONF += --x-includes=$(CROSS_LIB_DIR)/include
GLIB1210_AUTOCONF += --x-libraries=$(CROSS_LIB_DIR)/lib
endif

$(STATEDIR)/glib1210.prepare: $(glib1210_prepare_deps)
	@$(call targetinfo, $@)
	@$(call clean, $(GLIB1210_DIR)/config.cache)
ifdef PTXCONF_ARCH_ARM
	cp -a $(TOPDIR)/rules/arm-linux $(GLIB1210_DIR)/config.cache
endif
	cd $(GLIB1210_DIR) && \
		$(GLIB1210_PATH) $(GLIB1210_ENV) \
		./configure $(GLIB1210_AUTOCONF)
	touch $@

# ----------------------------------------------------------------------------
# Compile
# ----------------------------------------------------------------------------

glib1210_compile: $(STATEDIR)/glib1210.compile

glib1210_compile_deps = $(STATEDIR)/glib1210.prepare

$(STATEDIR)/glib1210.compile: $(glib1210_compile_deps)
	@$(call targetinfo, $@)
	$(GLIB1210_PATH) $(MAKE) -C $(GLIB1210_DIR)
	touch $@

# ----------------------------------------------------------------------------
# Install
# ----------------------------------------------------------------------------

glib1210_install: $(STATEDIR)/glib1210.install

$(STATEDIR)/glib1210.install: $(STATEDIR)/glib1210.compile
	@$(call targetinfo, $@)
	$(GLIB1210_PATH) $(MAKE) -C $(GLIB1210_DIR) DESTDIR=$(GLIB1210_IPKG_TMP) install
	cp -a  $(GLIB1210_IPKG_TMP)/usr/include/* $(CROSS_LIB_DIR)/include
	cp -a  $(GLIB1210_IPKG_TMP)/usr/lib/*     $(CROSS_LIB_DIR)/lib
	cp -a  $(GLIB1210_IPKG_TMP)/usr/share/aclocal/*   $(CROSS_LIB_DIR)/share/aclocal
	cp -a  $(GLIB1210_IPKG_TMP)/usr/bin/*     $(PTXCONF_PREFIX)/bin
	rm -rf $(GLIB1210_IPKG_TMP)
	perl -p -i -e "s/\/usr/`echo $(PTXCONF_PREFIX)/$(PTXCONF_GNU_TARGET) | sed -e '/\//s//\\\\\//g'`/g" $(PTXCONF_PREFIX)/bin/glib-config
	perl -p -i -e "s/\/usr\/lib/`echo $(PTXCONF_PREFIX)/$(PTXCONF_GNU_TARGET)/lib | sed -e '/\//s//\\\\\//g'`/g" $(PTXCONF_PREFIX)/$(PTXCONF_GNU_TARGET)/lib/libglib.la
	perl -p -i -e "s/\/usr\/lib/`echo $(PTXCONF_PREFIX)/$(PTXCONF_GNU_TARGET)/lib | sed -e '/\//s//\\\\\//g'`/g" $(PTXCONF_PREFIX)/$(PTXCONF_GNU_TARGET)/lib/libgmodule.la
	perl -p -i -e "s/\/usr\/lib/`echo $(PTXCONF_PREFIX)/$(PTXCONF_GNU_TARGET)/lib | sed -e '/\//s//\\\\\//g'`/g" $(PTXCONF_PREFIX)/$(PTXCONF_GNU_TARGET)/lib/libgthread.la
	perl -p -i -e "s/\/usr/`echo $(PTXCONF_PREFIX)/$(PTXCONF_GNU_TARGET) | sed -e '/\//s//\\\\\//g'`/g" $(PTXCONF_PREFIX)/$(PTXCONF_GNU_TARGET)/lib/pkgconfig/glib.pc
	perl -p -i -e "s/\/usr/`echo $(PTXCONF_PREFIX)/$(PTXCONF_GNU_TARGET) | sed -e '/\//s//\\\\\//g'`/g" $(PTXCONF_PREFIX)/$(PTXCONF_GNU_TARGET)/lib/pkgconfig/gmodule.pc
	perl -p -i -e "s/\/usr/`echo $(PTXCONF_PREFIX)/$(PTXCONF_GNU_TARGET) | sed -e '/\//s//\\\\\//g'`/g" $(PTXCONF_PREFIX)/$(PTXCONF_GNU_TARGET)/lib/pkgconfig/gthread.pc
	touch $@

# ----------------------------------------------------------------------------
# Target-Install
# ----------------------------------------------------------------------------

glib1210_targetinstall: $(STATEDIR)/glib1210.targetinstall

glib1210_targetinstall_deps = $(STATEDIR)/glib1210.compile

$(STATEDIR)/glib1210.targetinstall: $(glib1210_targetinstall_deps)
	@$(call targetinfo, $@)
	$(GLIB1210_PATH) $(MAKE) -C $(GLIB1210_DIR) DESTDIR=$(GLIB1210_IPKG_TMP) install
	rm -rf $(GLIB1210_IPKG_TMP)/usr/bin
	rm -rf $(GLIB1210_IPKG_TMP)/usr/include
	rm -rf $(GLIB1210_IPKG_TMP)/usr/info
	rm -rf $(GLIB1210_IPKG_TMP)/usr/man
	rm -rf $(GLIB1210_IPKG_TMP)/usr/share
	rm -rf $(GLIB1210_IPKG_TMP)/usr/lib/glib
	rm -rf $(GLIB1210_IPKG_TMP)/usr/lib/pkgconfig
	rm -f  $(GLIB1210_IPKG_TMP)/usr/lib/*.la
	$(CROSSSTRIP) $(GLIB1210_IPKG_TMP)/usr/lib/*.so
	mkdir -p $(GLIB1210_IPKG_TMP)/CONTROL
	echo "Package: glib"	 			>$(GLIB1210_IPKG_TMP)/CONTROL/control
	echo "Priority: optional" 			>>$(GLIB1210_IPKG_TMP)/CONTROL/control
	echo "Section: Libraries" 			>>$(GLIB1210_IPKG_TMP)/CONTROL/control
	echo "Maintainer: Alexander Chukov <sash@pdaXrom.org>" >>$(GLIB1210_IPKG_TMP)/CONTROL/control
	echo "Architecture: $(SHORT_TARGET)" 		>>$(GLIB1210_IPKG_TMP)/CONTROL/control
	echo "Version: $(GLIB1210_VERSION)" 		>>$(GLIB1210_IPKG_TMP)/CONTROL/control
	echo "Depends: " 				>>$(GLIB1210_IPKG_TMP)/CONTROL/control
	echo "Description: generated with pdaXrom builder">>$(GLIB1210_IPKG_TMP)/CONTROL/control
	cd $(FEEDDIR) && $(XMKIPKG) $(GLIB1210_IPKG_TMP)
	touch $@

# ----------------------------------------------------------------------------
# Image-Install
# ----------------------------------------------------------------------------

ifdef PTXCONF_GLIB1210_INSTALL
ROMPACKAGES += $(STATEDIR)/glib1210.imageinstall
endif

glib1210_imageinstall_deps = $(STATEDIR)/glib1210.targetinstall \
	$(STATEDIR)/virtual-image.install

$(STATEDIR)/glib1210.imageinstall: $(glib1210_imageinstall_deps)
	@$(call targetinfo, $@)
	cd $(FEEDDIR) && $(XIPKG) install glib
	touch $@

# ----------------------------------------------------------------------------
# Clean
# ----------------------------------------------------------------------------

glib1210_clean:
	rm -rf $(STATEDIR)/glib1210.*
	rm -rf $(GLIB1210_DIR)

# vim: syntax=make
