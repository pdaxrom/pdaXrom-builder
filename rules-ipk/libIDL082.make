# -*-makefile-*-
# $Id: template,v 1.10 2004/01/24 15:50:34 mkl Exp $
#
# Copyright (C) 2004 by  Alexander Chukov <sash@pdaXrom.org>
#          
# See CREDITS for details about who has contributed to this project.
#
# For further information about the PTXdist project and license conditions
# see the README file.
#

#
# We provide this package
#
ifdef PTXCONF_LIBIDL082
PACKAGES += libIDL082
endif

#
# Paths and names
#
LIBIDL082_VERSION	= 0.8.2
LIBIDL082		= libIDL-$(LIBIDL082_VERSION)
LIBIDL082_SUFFIX	= tar.bz2
LIBIDL082_URL		= http://ftp.gnome.org/pub/GNOME/desktop/2.4/2.4.0/sources/$(LIBIDL082).$(LIBIDL082_SUFFIX)
LIBIDL082_SOURCE	= $(SRCDIR)/$(LIBIDL082).$(LIBIDL082_SUFFIX)
LIBIDL082_DIR		= $(BUILDDIR)/$(LIBIDL082)
LIBIDL082_IPKG_TMP	= $(LIBIDL082_DIR)/ipkg_tmp

# ----------------------------------------------------------------------------
# Get
# ----------------------------------------------------------------------------

libIDL082_get: $(STATEDIR)/libIDL082.get

libIDL082_get_deps = $(LIBIDL082_SOURCE)

$(STATEDIR)/libIDL082.get: $(libIDL082_get_deps)
	@$(call targetinfo, $@)
	@$(call get_patches, $(LIBIDL082))
	touch $@

$(LIBIDL082_SOURCE):
	@$(call targetinfo, $@)
	@$(call get, $(LIBIDL082_URL))

# ----------------------------------------------------------------------------
# Extract
# ----------------------------------------------------------------------------

libIDL082_extract: $(STATEDIR)/libIDL082.extract

libIDL082_extract_deps = $(STATEDIR)/libIDL082.get

$(STATEDIR)/libIDL082.extract: $(libIDL082_extract_deps)
	@$(call targetinfo, $@)
	@$(call clean, $(LIBIDL082_DIR))
	@$(call extract, $(LIBIDL082_SOURCE))
	@$(call patchin, $(LIBIDL082))
	touch $@

# ----------------------------------------------------------------------------
# Prepare
# ----------------------------------------------------------------------------

libIDL082_prepare: $(STATEDIR)/libIDL082.prepare

#
# dependencies
#
libIDL082_prepare_deps = \
	$(STATEDIR)/libIDL082.extract \
	$(STATEDIR)/xchain-libidl082.install \
	$(STATEDIR)/virtual-xchain.install

LIBIDL082_PATH	=  PATH=$(CROSS_PATH)
LIBIDL082_ENV 	=  $(CROSS_ENV)
#LIBIDL082_ENV	+=
LIBIDL082_ENV	+= PKG_CONFIG_PATH=$(CROSS_LIB_DIR)/lib/pkgconfig:$(CROSS_LIB_DIR)/lib/pkgconfig
#ifdef PTXCONF_XFREE430
#LIBIDL082_ENV	+= LDFLAGS=-Wl,-rpath-link,$(CROSS_LIB_DIR)/lib
#endif

#
# autoconf
#
LIBIDL082_AUTOCONF = \
	--build=$(GNU_HOST) \
	--host=$(PTXCONF_GNU_TARGET) \
	--prefix=/usr

ifdef PTXCONF_XFREE430
LIBIDL082_AUTOCONF += --x-includes=$(CROSS_LIB_DIR)/include
LIBIDL082_AUTOCONF += --x-libraries=$(CROSS_LIB_DIR)/lib
endif

LIBIDL082_ENV	+= CFLAGS="-O2 -fomit-frame-pointer"
LIBIDL082_ENV	+= libIDL_cv_long_long_format=ll

LIBIDL082_AUTOCONF	+= --enable-static
LIBIDL082_AUTOCONF	+= --disable-shared

ifdef PTXCONF_LIBIDL082_FOO
LIBIDL082_AUTOCONF	+= --enable-foo
endif

$(STATEDIR)/libIDL082.prepare: $(libIDL082_prepare_deps)
	@$(call targetinfo, $@)
	@$(call clean, $(LIBIDL082_DIR)/config.cache)
	cd $(LIBIDL082_DIR) && \
		$(LIBIDL082_PATH) $(LIBIDL082_ENV) \
		./configure $(LIBIDL082_AUTOCONF)
	touch $@

# ----------------------------------------------------------------------------
# Compile
# ----------------------------------------------------------------------------

libIDL082_compile: $(STATEDIR)/libIDL082.compile

libIDL082_compile_deps = $(STATEDIR)/libIDL082.prepare

$(STATEDIR)/libIDL082.compile: $(libIDL082_compile_deps)
	@$(call targetinfo, $@)
	$(LIBIDL082_PATH) $(MAKE) -C $(LIBIDL082_DIR)
	touch $@

# ----------------------------------------------------------------------------
# Install
# ----------------------------------------------------------------------------

libIDL082_install: $(STATEDIR)/libIDL082.install

$(STATEDIR)/libIDL082.install: $(STATEDIR)/libIDL082.compile
	@$(call targetinfo, $@)
	$(LIBIDL082_PATH) $(MAKE) -C $(LIBIDL082_DIR) DESTDIR=$(LIBIDL082_IPKG_TMP) install
	cp -a  $(LIBIDL082_IPKG_TMP)/usr/include/*        	$(CROSS_LIB_DIR)/include
	cp -a  $(LIBIDL082_IPKG_TMP)/usr/lib/*            	$(CROSS_LIB_DIR)/lib
	cp -a  $(LIBIDL082_IPKG_TMP)/usr/bin/libIDL-config-2	$(PTXCONF_PREFIX)/bin
	perl -p -i -e "s/\/usr/`echo $(PTXCONF_PREFIX)/$(PTXCONF_GNU_TARGET) | sed -e '/\//s//\\\\\//g'`/g" $(PTXCONF_PREFIX)/bin/libIDL-config-2
	perl -p -i -e "s/\/usr\/lib/`echo $(PTXCONF_PREFIX)/$(PTXCONF_GNU_TARGET)/lib | sed -e '/\//s//\\\\\//g'`/g" $(PTXCONF_PREFIX)/$(PTXCONF_GNU_TARGET)/lib/libIDL-2.la
	perl -p -i -e "s/\/usr/`echo $(PTXCONF_PREFIX)/$(PTXCONF_GNU_TARGET) | sed -e '/\//s//\\\\\//g'`/g" $(PTXCONF_PREFIX)/$(PTXCONF_GNU_TARGET)/lib/pkgconfig/libIDL-2.0.pc
	rm -rf $(LIBIDL082_IPKG_TMP)
	touch $@

# ----------------------------------------------------------------------------
# Target-Install
# ----------------------------------------------------------------------------

libIDL082_targetinstall: $(STATEDIR)/libIDL082.targetinstall

libIDL082_targetinstall_deps = $(STATEDIR)/libIDL082.compile

$(STATEDIR)/libIDL082.targetinstall: $(libIDL082_targetinstall_deps)
	@$(call targetinfo, $@)
	$(LIBIDL082_PATH) $(MAKE) -C $(LIBIDL082_DIR) DESTDIR=$(LIBIDL082_IPKG_TMP) install
	mkdir -p $(LIBIDL082_IPKG_TMP)/CONTROL
	echo "Package: libidl2" 							>$(LIBIDL082_IPKG_TMP)/CONTROL/control
	echo "Priority: optional" 							>>$(LIBIDL082_IPKG_TMP)/CONTROL/control
	echo "Section: pdaXrom" 							>>$(LIBIDL082_IPKG_TMP)/CONTROL/control
	echo "Maintainer:  Alexander Chukov <sash@pdaXrom.org>" 			>>$(LIBIDL082_IPKG_TMP)/CONTROL/control
	echo "Architecture: $(SHORT_TARGET)" 						>>$(LIBIDL082_IPKG_TMP)/CONTROL/control
	echo "Version: $(LIBIDL082_VERSION)" 						>>$(LIBIDL082_IPKG_TMP)/CONTROL/control
	echo "Depends: " 								>>$(LIBIDL082_IPKG_TMP)/CONTROL/control
	echo "Description: generated with pdaXrom builder"				>>$(LIBIDL082_IPKG_TMP)/CONTROL/control
	###cd $(FEEDDIR) && $(XMKIPKG) $(LIBIDL082_IPKG_TMP)
	touch $@

# ----------------------------------------------------------------------------
# Image-Install
# ----------------------------------------------------------------------------

ifdef PTXCONF_LIBIDL082_INSTALL
ROMPACKAGES += $(STATEDIR)/libIDL082.imageinstall
endif

libIDL082_imageinstall_deps = $(STATEDIR)/libIDL082.targetinstall \
	$(STATEDIR)/virtual-image.install

$(STATEDIR)/libIDL082.imageinstall: $(libIDL082_imageinstall_deps)
	@$(call targetinfo, $@)
	cd $(FEEDDIR) && $(XIPKG) install libidl2
	touch $@

# ----------------------------------------------------------------------------
# Clean
# ----------------------------------------------------------------------------

libIDL082_clean:
	rm -rf $(STATEDIR)/libIDL082.*
	rm -rf $(LIBIDL082_DIR)

# vim: syntax=make
