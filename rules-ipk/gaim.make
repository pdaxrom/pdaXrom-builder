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
ifdef PTXCONF_GAIM
PACKAGES += gaim
endif

#
# Paths and names
#
#GAIM_VERSION		= 1.0.3
GAIM_VERSION		= 1.1.1
GAIM			= gaim-$(GAIM_VERSION)
GAIM_SUFFIX		= tar.bz2
GAIM_URL		= http://ovh.dl.sourceforge.net/sourceforge/gaim/$(GAIM).$(GAIM_SUFFIX)
GAIM_SOURCE		= $(SRCDIR)/$(GAIM).$(GAIM_SUFFIX)
GAIM_DIR		= $(BUILDDIR)/$(GAIM)
GAIM_IPKG_TMP		= $(GAIM_DIR)/ipkg_tmp

# ----------------------------------------------------------------------------
# Get
# ----------------------------------------------------------------------------

gaim_get: $(STATEDIR)/gaim.get

gaim_get_deps = $(GAIM_SOURCE)

$(STATEDIR)/gaim.get: $(gaim_get_deps)
	@$(call targetinfo, $@)
	@$(call get_patches, $(GAIM))
	touch $@

$(GAIM_SOURCE):
	@$(call targetinfo, $@)
	@$(call get, $(GAIM_URL))

# ----------------------------------------------------------------------------
# Extract
# ----------------------------------------------------------------------------

gaim_extract: $(STATEDIR)/gaim.extract

gaim_extract_deps = \
	$(STATEDIR)/gaim.get \
	$(STATEDIR)/audiofile.install \
	$(STATEDIR)/libao.install \
	$(STATEDIR)/gtk22.install \
	$(STATEDIR)/gnutls.install

ifdef PTXCONF_LIBICONV
gaim_extract_deps += $(STATEDIR)/libiconv.install
endif

$(STATEDIR)/gaim.extract: $(gaim_extract_deps)
	@$(call targetinfo, $@)
	@$(call clean, $(GAIM_DIR))
	@$(call extract, $(GAIM_SOURCE))
	@$(call patchin, $(GAIM))
	touch $@

# ----------------------------------------------------------------------------
# Prepare
# ----------------------------------------------------------------------------

gaim_prepare: $(STATEDIR)/gaim.prepare

#
# dependencies
#
gaim_prepare_deps = \
	$(STATEDIR)/gaim.extract \
	$(STATEDIR)/virtual-xchain.install

GAIM_PATH	=  PATH=$(CROSS_PATH)
GAIM_ENV 	=  $(CROSS_ENV)
GAIM_ENV	+= CFLAGS="$(TARGET_OPT_CFLAGS)"
GAIM_ENV	+= CXXFLAGS="$(TARGET_OPT_CFLAGS)"
GAIM_ENV	+= PKG_CONFIG_PATH=$(CROSS_LIB_DIR)/lib/pkgconfig:$(CROSS_LIB_DIR)/lib/pkgconfig
#ifdef PTXCONF_XFREE430
#GAIM_ENV	+= LDFLAGS=-Wl,-rpath-link,$(CROSS_LIB_DIR)/lib
#endif

#
# autoconf
#
GAIM_AUTOCONF = \
	--build=$(GNU_HOST) \
	--host=$(PTXCONF_GNU_TARGET) \
	--prefix=/usr \
	--with-gnutls-includes=$(CROSS_LIB_DIR)/include \
	--with-gnutls-libs=$(CROSS_LIB_DIR)/lib \
	--with-ao=$(CROSS_LIB_DIR) \
	--enable-nss=no \
	--disable-perl \
	--disable-tcl \
	--disable-tk

ifdef PTXCONF_XFREE430
GAIM_AUTOCONF += --x-includes=$(CROSS_LIB_DIR)/include
GAIM_AUTOCONF += --x-libraries=$(CROSS_LIB_DIR)/lib
endif

$(STATEDIR)/gaim.prepare: $(gaim_prepare_deps)
	@$(call targetinfo, $@)
	@$(call clean, $(GAIM_DIR)/config.cache)
	#cd $(GAIM_DIR) && aclocal
	#cd $(GAIM_DIR) && automake --add-missing
	#cd $(GAIM_DIR) && autoconf
	cd $(GAIM_DIR) && \
		$(GAIM_PATH) $(GAIM_ENV) \
		./configure $(GAIM_AUTOCONF)
	cp -f $(PTXCONF_PREFIX)/bin/libtool $(GAIM_DIR)
	cp -a $(GAIM_DIR)/mkinstalldirs $(GAIM_DIR)/po
	touch $@

# ----------------------------------------------------------------------------
# Compile
# ----------------------------------------------------------------------------

gaim_compile: $(STATEDIR)/gaim.compile

gaim_compile_deps = $(STATEDIR)/gaim.prepare

$(STATEDIR)/gaim.compile: $(gaim_compile_deps)
	@$(call targetinfo, $@)
	$(GAIM_PATH) $(MAKE) -C $(GAIM_DIR)
	touch $@

# ----------------------------------------------------------------------------
# Install
# ----------------------------------------------------------------------------

gaim_install: $(STATEDIR)/gaim.install

$(STATEDIR)/gaim.install: $(STATEDIR)/gaim.compile
	@$(call targetinfo, $@)
	touch $@

# ----------------------------------------------------------------------------
# Target-Install
# ----------------------------------------------------------------------------

gaim_targetinstall: $(STATEDIR)/gaim.targetinstall

gaim_targetinstall_deps = \
	$(STATEDIR)/gaim.compile \
	$(STATEDIR)/libao.targetinstall \
	$(STATEDIR)/audiofile.targetinstall \
	$(STATEDIR)/gtk22.targetinstall \
	$(STATEDIR)/gnutls.targetinstall

ifdef PTXCONF_LIBICONV
gaim_targetinstall_deps += $(STATEDIR)/libiconv.targetinstall
endif

$(STATEDIR)/gaim.targetinstall: $(gaim_targetinstall_deps)
	@$(call targetinfo, $@)
	$(GAIM_PATH) $(MAKE) -C $(GAIM_DIR) DESTDIR=$(GAIM_IPKG_TMP) install
	$(CROSSSTRIP) $(GAIM_IPKG_TMP)/usr/bin/*
	rm -rf $(GAIM_IPKG_TMP)/usr/include
	rm -rf $(GAIM_IPKG_TMP)/usr/lib/*.*a
	rm -rf $(GAIM_IPKG_TMP)/usr/lib/pkgconfig
	$(CROSSSTRIP) $(GAIM_IPKG_TMP)/usr/lib/*.so
	rm -rf $(GAIM_IPKG_TMP)/usr/lib/gaim/*.*a
	$(CROSSSTRIP) $(GAIM_IPKG_TMP)/usr/lib/gaim/*.so
	rm -rf $(GAIM_IPKG_TMP)/usr/man
	rm -rf $(GAIM_IPKG_TMP)/usr/share/locale
	mkdir -p $(GAIM_IPKG_TMP)/CONTROL
	echo "Package: gaim" 				>$(GAIM_IPKG_TMP)/CONTROL/control
	echo "Priority: optional" 			>>$(GAIM_IPKG_TMP)/CONTROL/control
	echo "Section: Internet" 			>>$(GAIM_IPKG_TMP)/CONTROL/control
	echo "Maintainer: Alexander Chukov <sash@pdaXrom.org>">>$(GAIM_IPKG_TMP)/CONTROL/control
	echo "Architecture: $(SHORT_TARGET)" 		>>$(GAIM_IPKG_TMP)/CONTROL/control
	echo "Version: $(GAIM_VERSION)" 		>>$(GAIM_IPKG_TMP)/CONTROL/control
	echo "Depends: libao, audiofile, gnutls, gtk2" 	>>$(GAIM_IPKG_TMP)/CONTROL/control
	echo "Description: IM client that supports many protocols.">>$(GAIM_IPKG_TMP)/CONTROL/control
	cd $(FEEDDIR) && $(XMKIPKG) $(GAIM_IPKG_TMP)
	touch $@

# ----------------------------------------------------------------------------
# Image-Install
# ----------------------------------------------------------------------------

ifdef PTXCONF_GAIM_INSTALL
ROMPACKAGES += $(STATEDIR)/gaim.imageinstall
endif

gaim_imageinstall_deps = $(STATEDIR)/gaim.targetinstall \
	$(STATEDIR)/virtual-image.install

$(STATEDIR)/gaim.imageinstall: $(gaim_imageinstall_deps)
	@$(call targetinfo, $@)
	cd $(FEEDDIR) && $(XIPKG) install gaim
	touch $@

# ----------------------------------------------------------------------------
# Clean
# ----------------------------------------------------------------------------

gaim_clean:
	rm -rf $(STATEDIR)/gaim.*
	rm -rf $(GAIM_DIR)

# vim: syntax=make
