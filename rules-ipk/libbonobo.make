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
ifdef PTXCONF_LIBBONOBO
PACKAGES += libbonobo
endif

#
# Paths and names
#
LIBBONOBO_VERSION	= 2.4.3
###LIBBONOBO_VERSION	= 2.6.0
LIBBONOBO		= libbonobo-$(LIBBONOBO_VERSION)
LIBBONOBO_SUFFIX	= tar.bz2
LIBBONOBO_URL		= ftp://ftp.acc.umu.se/pub/GNOME/sources/libbonobo/2.6/$(LIBBONOBO).$(LIBBONOBO_SUFFIX)
LIBBONOBO_SOURCE	= $(SRCDIR)/$(LIBBONOBO).$(LIBBONOBO_SUFFIX)
LIBBONOBO_DIR		= $(BUILDDIR)/$(LIBBONOBO)
LIBBONOBO_IPKG_TMP	= $(LIBBONOBO_DIR)/ipkg_tmp

# ----------------------------------------------------------------------------
# Get
# ----------------------------------------------------------------------------

libbonobo_get: $(STATEDIR)/libbonobo.get

libbonobo_get_deps = $(LIBBONOBO_SOURCE)

$(STATEDIR)/libbonobo.get: $(libbonobo_get_deps)
	@$(call targetinfo, $@)
	@$(call get_patches, $(LIBBONOBO))
	touch $@

$(LIBBONOBO_SOURCE):
	@$(call targetinfo, $@)
	@$(call get, $(LIBBONOBO_URL))

# ----------------------------------------------------------------------------
# Extract
# ----------------------------------------------------------------------------

libbonobo_extract: $(STATEDIR)/libbonobo.extract

libbonobo_extract_deps = $(STATEDIR)/libbonobo.get

$(STATEDIR)/libbonobo.extract: $(libbonobo_extract_deps)
	@$(call targetinfo, $@)
	@$(call clean, $(LIBBONOBO_DIR))
	@$(call extract, $(LIBBONOBO_SOURCE))
	@$(call patchin, $(LIBBONOBO))
	touch $@

# ----------------------------------------------------------------------------
# Prepare
# ----------------------------------------------------------------------------

libbonobo_prepare: $(STATEDIR)/libbonobo.prepare

#
# dependencies
#
libbonobo_prepare_deps = \
	$(STATEDIR)/libbonobo.extract \
	$(STATEDIR)/glib22.install \
	$(STATEDIR)/ORBit2.install \
	$(STATEDIR)/virtual-xchain.install

LIBBONOBO_PATH	=  PATH=$(CROSS_PATH)
LIBBONOBO_ENV 	=  $(CROSS_ENV)
LIBBONOBO_ENV	+= CFLAGS="-O2 -fomit-frame-pointer"
LIBBONOBO_ENV	+= PKG_CONFIG_PATH=$(CROSS_LIB_DIR)/lib/pkgconfig:$(CROSS_LIB_DIR)/lib/pkgconfig
#ifdef PTXCONF_XFREE430
#LIBBONOBO_ENV	+= LDFLAGS=-Wl,-rpath-link,$(CROSS_LIB_DIR)/lib
#endif

#
# autoconf
#
LIBBONOBO_AUTOCONF = \
	--build=$(GNU_HOST) \
	--host=$(PTXCONF_GNU_TARGET) \
	--prefix=/usr \
	--enable-shared \
	--disable-static \
	--sysconfdir=/etc \
	--libexecdir=/usr/bin \
	--disable-debug

ifdef PTXCONF_XFREE430
LIBBONOBO_AUTOCONF += --x-includes=$(CROSS_LIB_DIR)/include
LIBBONOBO_AUTOCONF += --x-libraries=$(CROSS_LIB_DIR)/lib
endif

$(STATEDIR)/libbonobo.prepare: $(libbonobo_prepare_deps)
	@$(call targetinfo, $@)
	@$(call clean, $(LIBBONOBO_DIR)/config.cache)
	cd $(LIBBONOBO_DIR) && \
		$(LIBBONOBO_PATH) $(LIBBONOBO_ENV) \
		./configure $(LIBBONOBO_AUTOCONF)
	touch $@

# ----------------------------------------------------------------------------
# Compile
# ----------------------------------------------------------------------------

libbonobo_compile: $(STATEDIR)/libbonobo.compile

libbonobo_compile_deps = $(STATEDIR)/libbonobo.prepare

$(STATEDIR)/libbonobo.compile: $(libbonobo_compile_deps)
	@$(call targetinfo, $@)
	$(LIBBONOBO_PATH) $(MAKE) -C $(LIBBONOBO_DIR)
	touch $@

# ----------------------------------------------------------------------------
# Install
# ----------------------------------------------------------------------------

libbonobo_install: $(STATEDIR)/libbonobo.install

$(STATEDIR)/libbonobo.install: $(STATEDIR)/libbonobo.compile
	@$(call targetinfo, $@)
	$(LIBBONOBO_PATH) $(MAKE) -C $(LIBBONOBO_DIR) DESTDIR=$(LIBBONOBO_IPKG_TMP) install
	cp -a  $(LIBBONOBO_IPKG_TMP)/usr/include/* $(CROSS_LIB_DIR)/include
	cp -a  $(LIBBONOBO_IPKG_TMP)/usr/lib/*     $(CROSS_LIB_DIR)/lib
	rm -rf $(LIBBONOBO_IPKG_TMP)/usr/share/gtk-doc
	rm -rf $(LIBBONOBO_IPKG_TMP)/usr/share/locale
	cp -a  $(LIBBONOBO_IPKG_TMP)/usr/share/*   $(CROSS_LIB_DIR)/share
	perl -p -i -e "s/\/usr\/lib/`echo $(PTXCONF_PREFIX)/$(PTXCONF_GNU_TARGET)/lib | sed -e '/\//s//\\\\\//g'`/g" $(PTXCONF_PREFIX)/$(PTXCONF_GNU_TARGET)/lib/libbonobo-2.la
	perl -p -i -e "s/\/usr\/lib/`echo $(PTXCONF_PREFIX)/$(PTXCONF_GNU_TARGET)/lib | sed -e '/\//s//\\\\\//g'`/g" $(PTXCONF_PREFIX)/$(PTXCONF_GNU_TARGET)/lib/libbonobo-activation.la
	perl -p -i -e "s/\/usr/`echo $(PTXCONF_PREFIX)/$(PTXCONF_GNU_TARGET) | sed -e '/\//s//\\\\\//g'`/g" $(PTXCONF_PREFIX)/$(PTXCONF_GNU_TARGET)/lib/pkgconfig/libbonobo-2.0.pc
	perl -p -i -e "s/\/usr/`echo $(PTXCONF_PREFIX)/$(PTXCONF_GNU_TARGET) | sed -e '/\//s//\\\\\//g'`/g" $(PTXCONF_PREFIX)/$(PTXCONF_GNU_TARGET)/lib/pkgconfig/bonobo-activation-2.0.pc
	rm -rf $(LIBBONOBO_IPKG_TMP)
	touch $@

# ----------------------------------------------------------------------------
# Target-Install
# ----------------------------------------------------------------------------

libbonobo_targetinstall: $(STATEDIR)/libbonobo.targetinstall

libbonobo_targetinstall_deps = \
	$(STATEDIR)/libbonobo.compile \
	$(STATEDIR)/glib22.targetinstall \
	$(STATEDIR)/ORBit2.targetinstall

$(STATEDIR)/libbonobo.targetinstall: $(libbonobo_targetinstall_deps)
	@$(call targetinfo, $@)
	$(LIBBONOBO_PATH) $(MAKE) -C $(LIBBONOBO_DIR) DESTDIR=$(LIBBONOBO_IPKG_TMP) install
	rm -rf $(LIBBONOBO_IPKG_TMP)/usr/include
	rm -rf $(LIBBONOBO_IPKG_TMP)/usr/lib/*.*a
	rm -rf $(LIBBONOBO_IPKG_TMP)/usr/lib/bonobo/monikers/*.a
	###rm -rf $(LIBBONOBO_IPKG_TMP)/usr/lib/bonobo/monikers/*.la
	##rm -rf $(LIBBONOBO_IPKG_TMP)/usr/lib/bonobo-2.0/samples/*.*a
	###rm -rf $(LIBBONOBO_IPKG_TMP)/usr/lib/orbit-2.0/*.la
	rm -rf $(LIBBONOBO_IPKG_TMP)/usr/lib/pkgconfig
	rm -rf $(LIBBONOBO_IPKG_TMP)/usr/man
	rm -rf $(LIBBONOBO_IPKG_TMP)/usr/share/gtk-doc
	rm -rf $(LIBBONOBO_IPKG_TMP)/usr/share/locale
	for FILE in `find $(LIBBONOBO_IPKG_TMP)/usr/ -type f`; do	\
	    ZZZ=`file $$FILE | grep 'ELF 32-bit'`;			\
	    if [  "$$ZZZ" != "" ]; then					\
		$(CROSSSTRIP) $$FILE;					\
	    fi;								\
	done
	mkdir -p $(LIBBONOBO_IPKG_TMP)/CONTROL
	echo "Package: libbonobo" 			>$(LIBBONOBO_IPKG_TMP)/CONTROL/control
	echo "Priority: optional" 			>>$(LIBBONOBO_IPKG_TMP)/CONTROL/control
	echo "Section: Gnome"	 			>>$(LIBBONOBO_IPKG_TMP)/CONTROL/control
	echo "Maintainer: Alexander Chukov <sash@pdaXrom.org>">>$(LIBBONOBO_IPKG_TMP)/CONTROL/control
	echo "Architecture: $(SHORT_TARGET)" 		>>$(LIBBONOBO_IPKG_TMP)/CONTROL/control
	echo "Version: $(LIBBONOBO_VERSION)" 		>>$(LIBBONOBO_IPKG_TMP)/CONTROL/control
	echo "Depends: gtk2, orbit2" 				>>$(LIBBONOBO_IPKG_TMP)/CONTROL/control
	echo "Description: Bonobo is a set of language and system independant CORBA interfaces for creating reusable components, controls and creating compound documents.">>$(LIBBONOBO_IPKG_TMP)/CONTROL/control
	cd $(FEEDDIR) && $(XMKIPKG) $(LIBBONOBO_IPKG_TMP)
	touch $@

# ----------------------------------------------------------------------------
# Clean
# ----------------------------------------------------------------------------

libbonobo_clean:
	rm -rf $(STATEDIR)/libbonobo.*
	rm -rf $(LIBBONOBO_DIR)

# vim: syntax=make
