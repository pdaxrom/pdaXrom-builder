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
ifdef PTXCONF_DILLO-XFT
PACKAGES += dillo-xft
endif

#
# Paths and names
#
DILLO-XFT_VERSION	= 0.8.0
DILLO-XFT		= dillo-$(DILLO-XFT_VERSION)
DILLO-XFT_SUFFIX	= tar.bz2
DILLO-XFT_URL		= http://www.dillo.org/download/$(DILLO-XFT).$(DILLO-XFT_SUFFIX)
DILLO-XFT_SOURCE	= $(SRCDIR)/$(DILLO-XFT).$(DILLO-XFT_SUFFIX)
DILLO-XFT_DIR		= $(BUILDDIR)/$(DILLO-XFT)
DILLO-XFT_IPKG_TMP	= $(DILLO-XFT_DIR)/ipkg_tmp

# ----------------------------------------------------------------------------
# Get
# ----------------------------------------------------------------------------

dillo-xft_get: $(STATEDIR)/dillo-xft.get

dillo-xft_get_deps = $(DILLO-XFT_SOURCE)

$(STATEDIR)/dillo-xft.get: $(dillo-xft_get_deps)
	@$(call targetinfo, $@)
	@$(call get_patches, $(DILLO-XFT))
	touch $@

$(DILLO-XFT_SOURCE):
	@$(call targetinfo, $@)
	@$(call get, $(DILLO-XFT_URL))

# ----------------------------------------------------------------------------
# Extract
# ----------------------------------------------------------------------------

dillo-xft_extract: $(STATEDIR)/dillo-xft.extract

dillo-xft_extract_deps = $(STATEDIR)/dillo-xft.get

$(STATEDIR)/dillo-xft.extract: $(dillo-xft_extract_deps)
	@$(call targetinfo, $@)
	@$(call clean, $(DILLO-XFT_DIR))
	@$(call extract, $(DILLO-XFT_SOURCE))
	@$(call patchin, $(DILLO-XFT))
	touch $@

# ----------------------------------------------------------------------------
# Prepare
# ----------------------------------------------------------------------------

dillo-xft_prepare: $(STATEDIR)/dillo-xft.prepare

#
# dependencies
#
dillo-xft_prepare_deps = \
	$(STATEDIR)/dillo-xft.extract \
	$(STATEDIR)/gtk1210.install \
	$(STATEDIR)/jpeg.install \
	$(STATEDIR)/libpng125.install \
	$(STATEDIR)/openssl.install \
	$(STATEDIR)/virtual-xchain.install

ifdef PTXCONF_LIBICONV
dillo-xft_prepare_deps += $(STATEDIR)/libiconv.install
endif

DILLO-XFT_PATH	=  PATH=$(CROSS_PATH)
DILLO-XFT_ENV 	=  $(CROSS_ENV)
DILLO-XFT_ENV	+= CFLAGS="-O2 -fomit-frame-pointer"
DILLO-XFT_ENV	+= PKG_CONFIG_PATH=$(CROSS_LIB_DIR)/lib/pkgconfig:$(CROSS_LIB_DIR)/lib/pkgconfig
#ifdef PTXCONF_XFREE430
#DILLO-XFT_ENV	+= LDFLAGS="-Wl,-rpath-link,$(CROSS_LIB_DIR)/lib"
#endif
DILLO-XFT_ENV	+= LIBICONV=-liconv

#
# autoconf
#
DILLO-XFT_AUTOCONF = \
	--build=$(GNU_HOST) \
	--host=$(PTXCONF_GNU_TARGET) \
	--prefix=/usr \
	--disable-debug \
	--enable-meta-refresh \
	--enable-user-agent \
	--without-libiconv-prefix \
	--sysconfdir=/usr/lib/dillo

ifdef PTXCONF_XFREE430
DILLO-XFT_AUTOCONF += --x-includes=$(CROSS_LIB_DIR)/include
DILLO-XFT_AUTOCONF += --x-libraries=$(CROSS_LIB_DIR)/lib
endif

$(STATEDIR)/dillo-xft.prepare: $(dillo-xft_prepare_deps)
	@$(call targetinfo, $@)
	@$(call clean, $(DILLO-XFT_DIR)/config.cache)
	#cd $(DILLO-XFT_DIR) && $(DILLO-XFT_PATH) aclocal
	#cd $(DILLO-XFT_DIR) && $(DILLO-XFT_PATH) automake --add-missing
	#cd $(DILLO-XFT_DIR) && $(DILLO-XFT_PATH) autoconf
	cd $(DILLO-XFT_DIR) && \
		$(DILLO-XFT_PATH) $(DILLO-XFT_ENV) \
		./configure $(DILLO-XFT_AUTOCONF)
	###cp -f $(PTXCONF_PREFIX)/bin/libtool $(DILLO-XFT_DIR)
	touch $@

# ----------------------------------------------------------------------------
# Compile
# ----------------------------------------------------------------------------

dillo-xft_compile: $(STATEDIR)/dillo-xft.compile

dillo-xft_compile_deps = $(STATEDIR)/dillo-xft.prepare

$(STATEDIR)/dillo-xft.compile: $(dillo-xft_compile_deps)
	@$(call targetinfo, $@)
	$(DILLO-XFT_PATH) $(MAKE) -C $(DILLO-XFT_DIR)
	touch $@

# ----------------------------------------------------------------------------
# Install
# ----------------------------------------------------------------------------

dillo-xft_install: $(STATEDIR)/dillo-xft.install

$(STATEDIR)/dillo-xft.install: $(STATEDIR)/dillo-xft.compile
	@$(call targetinfo, $@)
	touch $@

# ----------------------------------------------------------------------------
# Target-Install
# ----------------------------------------------------------------------------

dillo-xft_targetinstall: $(STATEDIR)/dillo-xft.targetinstall

dillo-xft_targetinstall_deps = $(STATEDIR)/dillo-xft.compile \
	$(STATEDIR)/jpeg.targetinstall \
	$(STATEDIR)/libpng125.targetinstall \
	$(STATEDIR)/openssl.targetinstall \
	$(STATEDIR)/gtk1210.targetinstall

ifdef PTXCONF_LIBICONV
dillo-xft_targetinstall_deps += $(STATEDIR)/libiconv.targetinstall
endif

$(STATEDIR)/dillo-xft.targetinstall: $(dillo-xft_targetinstall_deps)
	@$(call targetinfo, $@)
	$(DILLO-XFT_PATH) $(MAKE) -C $(DILLO-XFT_DIR) DESTDIR=$(DILLO-XFT_IPKG_TMP) install
	for FILE in `find $(DILLO-XFT_IPKG_TMP)/usr -type f`; do	\
	    ZZZ=`file $$FILE | grep 'ELF 32-bit'`;			\
	    if [  "$$ZZZ" != "" ]; then					\
		$(CROSSSTRIP) $$FILE;					\
	    fi;								\
	done
	rm -rf   $(DILLO-XFT_IPKG_TMP)/usr/share/locale
	mkdir -p $(DILLO-XFT_IPKG_TMP)/usr/share/applications
	mkdir -p $(DILLO-XFT_IPKG_TMP)/usr/share/pixmaps
	cp -f $(TOPDIR)/config/pics/hyperborea-dillo.desktop $(DILLO-XFT_IPKG_TMP)/usr/share/applications
	cp -f $(TOPDIR)/config/pics/dillo.png                $(DILLO-XFT_IPKG_TMP)/usr/share/pixmaps
	perl -p -i -e "s/640x550/620x440/g" 		     $(DILLO-XFT_IPKG_TMP)/usr/lib/dillo/dillorc
	mkdir -p $(DILLO-XFT_IPKG_TMP)/home/root/.dillo
	cp -f $(TOPDIR)/config/pics/dillorc 		     $(DILLO-XFT_IPKG_TMP)/home/root/.dillo/
	mkdir -p $(DILLO-XFT_IPKG_TMP)/CONTROL
	echo "Package: dillo-xft" 				>$(DILLO-XFT_IPKG_TMP)/CONTROL/control
	echo "Priority: optional" 				>>$(DILLO-XFT_IPKG_TMP)/CONTROL/control
	echo "Section: Network" 				>>$(DILLO-XFT_IPKG_TMP)/CONTROL/control
	echo "Maintainer: Alexander Chukov <sash@pdaXrom.org>" 	>>$(DILLO-XFT_IPKG_TMP)/CONTROL/control
	echo "Architecture: $(SHORT_TARGET)" 			>>$(DILLO-XFT_IPKG_TMP)/CONTROL/control
	echo "Version: $(DILLO-XFT_VERSION)" 			>>$(DILLO-XFT_IPKG_TMP)/CONTROL/control
ifdef PTXCONF_LIBICONV
	echo "Depends: gtk, libiconv, libjpeg, libpng, openssl" >>$(DILLO-XFT_IPKG_TMP)/CONTROL/control
else
	echo "Depends: gtk, libjpeg, libpng, openssl" >>$(DILLO-XFT_IPKG_TMP)/CONTROL/control
endif
	echo "Description: Dillo is a web browser project completely written in C.">>$(DILLO-XFT_IPKG_TMP)/CONTROL/control
	cd $(FEEDDIR) && $(XMKIPKG) $(DILLO-XFT_IPKG_TMP)
	touch $@

# ----------------------------------------------------------------------------
# Image-Install
# ----------------------------------------------------------------------------

ifdef PTXCONF_DILLO-XFT_INSTALL
ROMPACKAGES += $(STATEDIR)/dillo-xft.imageinstall
endif

dillo-xft_imageinstall_deps = $(STATEDIR)/dillo-xft.targetinstall \
	$(STATEDIR)/virtual-image.install

$(STATEDIR)/dillo-xft.imageinstall: $(dillo-xft_imageinstall_deps)
	@$(call targetinfo, $@)
	cd $(FEEDDIR) && $(XIPKG) install dillo-xft
	touch $@

# ----------------------------------------------------------------------------
# Clean
# ----------------------------------------------------------------------------

dillo-xft_clean:
	rm -rf $(STATEDIR)/dillo-xft.*
	rm -rf $(DILLO-XFT_DIR)

# vim: syntax=make
