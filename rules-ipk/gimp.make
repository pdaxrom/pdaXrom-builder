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
ifdef PTXCONF_GIMP
PACKAGES += gimp
endif

#
# Paths and names
#
GIMP_VERSION		= 2.0.5
GIMP			= gimp-$(GIMP_VERSION)
GIMP_SUFFIX		= tar.bz2
GIMP_URL		= http://www.pdaXrom.org/src/$(GIMP).$(GIMP_SUFFIX)
GIMP_SOURCE		= $(SRCDIR)/$(GIMP).$(GIMP_SUFFIX)
GIMP_DIR		= $(BUILDDIR)/$(GIMP)
GIMP_IPKG_TMP		= $(GIMP_DIR)/ipkg_tmp

# ----------------------------------------------------------------------------
# Get
# ----------------------------------------------------------------------------

gimp_get: $(STATEDIR)/gimp.get

gimp_get_deps = $(GIMP_SOURCE)

$(STATEDIR)/gimp.get: $(gimp_get_deps)
	@$(call targetinfo, $@)
	@$(call get_patches, $(GIMP))
	touch $@

$(GIMP_SOURCE):
	@$(call targetinfo, $@)
	@$(call get, $(GIMP_URL))

# ----------------------------------------------------------------------------
# Extract
# ----------------------------------------------------------------------------

gimp_extract: $(STATEDIR)/gimp.extract

gimp_extract_deps = $(STATEDIR)/gimp.get

$(STATEDIR)/gimp.extract: $(gimp_extract_deps)
	@$(call targetinfo, $@)
	@$(call clean, $(GIMP_DIR))
	@$(call extract, $(GIMP_SOURCE))
	@$(call patchin, $(GIMP))
	touch $@

# ----------------------------------------------------------------------------
# Prepare
# ----------------------------------------------------------------------------

gimp_prepare: $(STATEDIR)/gimp.prepare

#
# dependencies
#
gimp_prepare_deps = \
	$(STATEDIR)/gimp.extract \
	$(STATEDIR)/gtk22.install \
	$(STATEDIR)/libart_lgpl.install \
	$(STATEDIR)/librsvg.install \
	$(STATEDIR)/virtual-xchain.install

GIMP_PATH	=  PATH=$(CROSS_PATH)
GIMP_ENV 	=  $(CROSS_ENV)
GIMP_ENV	+= CFLAGS="$(TARGET_OPT_CFLAGS)"
GIMP_ENV	+= PKG_CONFIG_PATH=$(CROSS_LIB_DIR)/lib/pkgconfig:$(CROSS_LIB_DIR)/lib/pkgconfig
#ifdef PTXCONF_XFREE430
GIMP_ENV	+= LDFLAGS="-Wl,-rpath-link,$(GIMP_DIR)/libgimpmodule/.libs -Wl,-rpath-link,$(GIMP_DIR)/libgimp/.libs -Wl,-rpath-link,$(GIMP_DIR)/libgimpcolor/.libs -Wl,-rpath-link,$(GIMP_DIR)/libgimpmath/.libs -Wl,-rpath-link,$(GIMP_DIR)/libgimpthumb/.libs -Wl,-rpath-link,$(GIMP_DIR)/libgimpwidgets/.libs"
#endif

#
# autoconf
#
GIMP_AUTOCONF = \
	--build=$(GNU_HOST) \
	--host=$(PTXCONF_GNU_TARGET) \
	--prefix=/usr \
	--without-libtiff \
	--disable-print \
	--enable-shared \
	--disable-static \
	--sysconfdir=/etc

ifdef PTXCONF_XFREE430
GIMP_AUTOCONF += --x-includes=$(CROSS_LIB_DIR)/include
GIMP_AUTOCONF += --x-libraries=$(CROSS_LIB_DIR)/lib
endif

$(STATEDIR)/gimp.prepare: $(gimp_prepare_deps)
	@$(call targetinfo, $@)
	@$(call clean, $(GIMP_DIR)/config.cache)
	cd $(GIMP_DIR) && \
		$(GIMP_PATH) $(GIMP_ENV) \
		./configure $(GIMP_AUTOCONF)
	cp -f $(PTXCONF_PREFIX)/bin/libtool $(GIMP_DIR)
	touch $@

# ----------------------------------------------------------------------------
# Compile
# ----------------------------------------------------------------------------

gimp_compile: $(STATEDIR)/gimp.compile

gimp_compile_deps = $(STATEDIR)/gimp.prepare

$(STATEDIR)/gimp.compile: $(gimp_compile_deps)
	@$(call targetinfo, $@)
	$(GIMP_PATH) $(MAKE) -C $(GIMP_DIR)
	touch $@

# ----------------------------------------------------------------------------
# Install
# ----------------------------------------------------------------------------

gimp_install: $(STATEDIR)/gimp.install

$(STATEDIR)/gimp.install: $(STATEDIR)/gimp.compile
	@$(call targetinfo, $@)
	###$(GIMP_PATH) $(MAKE) -C $(GIMP_DIR) install
	touch $@

# ----------------------------------------------------------------------------
# Target-Install
# ----------------------------------------------------------------------------

gimp_targetinstall: $(STATEDIR)/gimp.targetinstall

gimp_targetinstall_deps = $(STATEDIR)/gimp.compile \
	$(STATEDIR)/gtk22.targetinstall \
	$(STATEDIR)/libart_lgpl.targetinstall \
	$(STATEDIR)/librsvg.targetinstall

$(STATEDIR)/gimp.targetinstall: $(gimp_targetinstall_deps)
	@$(call targetinfo, $@)
	rm -rf $(GIMP_IPKG_TMP)
	$(GIMP_PATH) $(MAKE) -C $(GIMP_DIR) DESTDIR=$(GIMP_IPKG_TMP) install
	rm -rf $(GIMP_IPKG_TMP)/usr/bin/gimptool-*
	rm -rf $(GIMP_IPKG_TMP)/usr/include
	rm -rf $(GIMP_IPKG_TMP)/usr/lib/pkgconfig
	rm -rf $(GIMP_IPKG_TMP)/usr/lib/*.*a
	rm -rf $(GIMP_IPKG_TMP)/usr/lib/gimp/2.0/modules/*.*a
	rm -rf $(GIMP_IPKG_TMP)/usr/man
	rm -rf $(GIMP_IPKG_TMP)/usr/share/aclocal
	rm -rf $(GIMP_IPKG_TMP)/usr/share/gtk-doc
	rm -rf $(GIMP_IPKG_TMP)/usr/share/locale
	for FILE in `find $(GIMP_IPKG_TMP)/usr/ -type f`; do		\
	    ZZZ=`file $$FILE | grep 'ELF 32-bit'`;			\
	    if [  "$$ZZZ" != "" ]; then					\
		$(CROSSSTRIP) $$FILE;					\
	    fi;								\
	done
	mkdir -p $(GIMP_IPKG_TMP)/usr/share/applications
	cp -a $(GIMP_IPKG_TMP)/usr/share/gimp/2.0/misc/gimp.desktop $(GIMP_IPKG_TMP)/usr/share/applications
	perl -p -i -e "s/gimp-remote-2.0 \%U/gimp-2.0/g"            $(GIMP_IPKG_TMP)/usr/share/applications/gimp.desktop
	mkdir -p $(GIMP_IPKG_TMP)/CONTROL
	echo "Package: gimp" 							 >$(GIMP_IPKG_TMP)/CONTROL/control
	echo "Priority: optional" 						>>$(GIMP_IPKG_TMP)/CONTROL/control
	echo "Section: X11"	 						>>$(GIMP_IPKG_TMP)/CONTROL/control
	echo "Maintainer: Alexander Chukov <sash@pdaXrom.org>" 			>>$(GIMP_IPKG_TMP)/CONTROL/control
	echo "Architecture: $(SHORT_TARGET)" 					>>$(GIMP_IPKG_TMP)/CONTROL/control
	echo "Version: $(GIMP_VERSION)" 					>>$(GIMP_IPKG_TMP)/CONTROL/control
	echo "Depends: gtk2, libart-lgpl, librsvg" 				>>$(GIMP_IPKG_TMP)/CONTROL/control
	echo "Description: The GNU Image Manipulation Program"			>>$(GIMP_IPKG_TMP)/CONTROL/control
	cd $(FEEDDIR) && $(XMKIPKG) $(GIMP_IPKG_TMP)
	touch $@

# ----------------------------------------------------------------------------
# Image-Install
# ----------------------------------------------------------------------------

ifdef PTXCONF_GIMP_INSTALL
ROMPACKAGES += $(STATEDIR)/gimp.imageinstall
endif

gimp_imageinstall_deps = $(STATEDIR)/gimp.targetinstall \
	$(STATEDIR)/virtual-image.install

$(STATEDIR)/gimp.imageinstall: $(gimp_imageinstall_deps)
	@$(call targetinfo, $@)
	cd $(FEEDDIR) && $(XIPKG) install gimp
	touch $@

# ----------------------------------------------------------------------------
# Clean
# ----------------------------------------------------------------------------

gimp_clean:
	rm -rf $(STATEDIR)/gimp.*
	rm -rf $(GIMP_DIR)

# vim: syntax=make
