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
ifdef PTXCONF_ROX-CLIB
PACKAGES += ROX-CLib
endif

#
# Paths and names
#
ROX-CLIB_VERSION	= 2.1.1
ROX-CLIB		= ROX-CLib-$(ROX-CLIB_VERSION)
ROX-CLIB_SUFFIX		= tar.gz
ROX-CLIB_URL		= http://www.kerofin.demon.co.uk/rox/$(ROX-CLIB).$(ROX-CLIB_SUFFIX)
ROX-CLIB_SOURCE		= $(SRCDIR)/$(ROX-CLIB).$(ROX-CLIB_SUFFIX)
ROX-CLIB_DIR		= $(BUILDDIR)/ROX-CLib
ROX-CLIB_IPKG_TMP	= $(ROX-CLIB_DIR)-ipkg_tmp

# ----------------------------------------------------------------------------
# Get
# ----------------------------------------------------------------------------

ROX-CLib_get: $(STATEDIR)/ROX-CLib.get

ROX-CLib_get_deps = $(ROX-CLIB_SOURCE)

$(STATEDIR)/ROX-CLib.get: $(ROX-CLib_get_deps)
	@$(call targetinfo, $@)
	@$(call get_patches, $(ROX-CLIB))
	touch $@

$(ROX-CLIB_SOURCE):
	@$(call targetinfo, $@)
	@$(call get, $(ROX-CLIB_URL))

# ----------------------------------------------------------------------------
# Extract
# ----------------------------------------------------------------------------

ROX-CLib_extract: $(STATEDIR)/ROX-CLib.extract

ROX-CLib_extract_deps = $(STATEDIR)/ROX-CLib.get

$(STATEDIR)/ROX-CLib.extract: $(ROX-CLib_extract_deps)
	@$(call targetinfo, $@)
	@$(call clean, $(ROX-CLIB_DIR))
	@$(call extract, $(ROX-CLIB_SOURCE))
	@$(call patchin, $(ROX-CLIB), $(ROX-CLIB_DIR))
	touch $@

# ----------------------------------------------------------------------------
# Prepare
# ----------------------------------------------------------------------------

ROX-CLib_prepare: $(STATEDIR)/ROX-CLib.prepare

#
# dependencies
#
ROX-CLib_prepare_deps = \
	$(STATEDIR)/ROX-CLib.extract \
	$(STATEDIR)/gtk22.install \
	$(STATEDIR)/glib22.install \
	$(STATEDIR)/libxml2.install \
	$(STATEDIR)/virtual-xchain.install

ROX-CLIB_PATH	=  PATH=$(CROSS_PATH)
ROX-CLIB_ENV 	=  $(CROSS_ENV)
ROX-CLIB_ENV	+= CFLAGS="-O2 -fomit-frame-pointer"
ROX-CLIB_ENV	+= PKG_CONFIG_PATH=$(CROSS_LIB_DIR)/lib/pkgconfig:$(CROSS_LIB_DIR)/lib/pkgconfig
#ifdef PTXCONF_XFREE430
#ROX-CLIB_ENV	+= LDFLAGS=-Wl,-rpath-link,$(CROSS_LIB_DIR)/lib
#endif

#
# autoconf
#
ROX-CLIB_AUTOCONF = \
	--build=$(GNU_HOST) \
	--host=$(PTXCONF_GNU_TARGET) \
	--disable-debug \
	--with-platform=Linux-$(PTXCONF_ARCH) \
	--disable-static \
	--enable-shared

ifdef PTXCONF_XFREE430
ROX-CLIB_AUTOCONF += --x-includes=$(CROSS_LIB_DIR)/include
ROX-CLIB_AUTOCONF += --x-libraries=$(CROSS_LIB_DIR)/lib
endif

$(STATEDIR)/ROX-CLib.prepare: $(ROX-CLib_prepare_deps)
	@$(call targetinfo, $@)
	@$(call clean, $(ROX-CLIB_DIR)/config.cache)
	#cd $(ROX-CLIB_DIR)/src && aclocal
	#cd $(ROX-CLIB_DIR)/src && automake --add-missing
	#cd $(ROX-CLIB_DIR)/src && autoconf
	cd $(ROX-CLIB_DIR)/src && \
		$(ROX-CLIB_PATH) $(ROX-CLIB_ENV) \
		./configure $(ROX-CLIB_AUTOCONF)
	###cp -f $(PTXCONF_PREFIX)/bin/libtool $(ROX-CLIB_DIR)/src
	perl -p -i -e "s/sys_lib_search_path_spec\=\"\//sys_lib_search_path_spec\=\"\"\ \#/g" 			$(ROX-CLIB_DIR)/src/libtool
	perl -p -i -e "s/sys_lib_dlsearch_path_spec\=\"\//sys_lib_dlsearch_path_spec\=\"\"\ \#/g" 		$(ROX-CLIB_DIR)/src/libtool
	perl -p -i -e "s/\@PREFIX\@/`echo $(PTXCONF_PREFIX)/$(PTXCONF_GNU_TARGET) | sed -e '/\//s//\\\\\//g'`/g" 	$(ROX-CLIB_DIR)/src/ROX-CLib.pc
	touch $@

# ----------------------------------------------------------------------------
# Compile
# ----------------------------------------------------------------------------

ROX-CLib_compile: $(STATEDIR)/ROX-CLib.compile

ROX-CLib_compile_deps = $(STATEDIR)/ROX-CLib.prepare

$(STATEDIR)/ROX-CLib.compile: $(ROX-CLib_compile_deps)
	@$(call targetinfo, $@)
	$(ROX-CLIB_PATH) $(ROX-CLIB_ENV) $(MAKE) -C $(ROX-CLIB_DIR)/src
	touch $@

# ----------------------------------------------------------------------------
# Install
# ----------------------------------------------------------------------------

ROX-CLib_install: $(STATEDIR)/ROX-CLib.install

$(STATEDIR)/ROX-CLib.install: $(STATEDIR)/ROX-CLib.compile
	@$(call targetinfo, $@)
	cp -a  $(ROX-CLIB_DIR)/Linux-$(PTXCONF_ARCH)/include/* 			$(CROSS_LIB_DIR)/include
	cp -a  $(ROX-CLIB_DIR)/Linux-$(PTXCONF_ARCH)/lib/librox-clib.so*	$(CROSS_LIB_DIR)/lib
	cp -a  $(ROX-CLIB_DIR)/src/ROX-CLib.pc					$(CROSS_LIB_DIR)/lib/pkgconfig
	touch $@

# ----------------------------------------------------------------------------
# Target-Install
# ----------------------------------------------------------------------------

ROX-CLib_targetinstall: $(STATEDIR)/ROX-CLib.targetinstall

ROX-CLib_targetinstall_deps = $(STATEDIR)/ROX-CLib.compile \
	$(STATEDIR)/gtk22.targetinstall \
	$(STATEDIR)/glib22.targetinstall \
	$(STATEDIR)/libxml2.targetinstall

$(STATEDIR)/ROX-CLib.targetinstall: $(ROX-CLib_targetinstall_deps)
	@$(call targetinfo, $@)
	rm -rf $(ROX-CLIB_DIR)/Linux-$(PTXCONF_ARCH)/lib/.libs
	rm -rf $(ROX-CLIB_IPKG_TMP)
	mkdir -p $(ROX-CLIB_IPKG_TMP)/usr/lib
	cp -a $(ROX-CLIB_DIR) $(ROX-CLIB_IPKG_TMP)/usr/lib
	rm -rf $(ROX-CLIB_IPKG_TMP)/usr/lib/ROX-CLib/src
	rm  -f $(ROX-CLIB_IPKG_TMP)/usr/lib/ROX-CLib/Linux-$(PTXCONF_ARCH)/lib/*.*a
	rm  -f $(ROX-CLIB_IPKG_TMP)/usr/lib/ROX-CLib/.cvsignore
	$(CROSSSTRIP) $(ROX-CLIB_IPKG_TMP)/usr/lib/ROX-CLib/Linux-$(PTXCONF_ARCH)/bin/pkg
	$(CROSSSTRIP) $(ROX-CLIB_IPKG_TMP)/usr/lib/ROX-CLib/Linux-$(PTXCONF_ARCH)/bin/rox_pinboard
	$(CROSSSTRIP) $(ROX-CLIB_IPKG_TMP)/usr/lib/ROX-CLib/Linux-$(PTXCONF_ARCH)/bin/test
	$(CROSSSTRIP) $(ROX-CLIB_IPKG_TMP)/usr/lib/ROX-CLib/Linux-$(PTXCONF_ARCH)/lib/*.so*
	mkdir -p $(ROX-CLIB_IPKG_TMP)/CONTROL
	echo "Package: rox-clib" 					>$(ROX-CLIB_IPKG_TMP)/CONTROL/control
	echo "Priority: optional" 					>>$(ROX-CLIB_IPKG_TMP)/CONTROL/control
	echo "Section: ROX"	 					>>$(ROX-CLIB_IPKG_TMP)/CONTROL/control
	echo "Maintainer: Alexander Chukov <sash@pdaXrom.org>"		>>$(ROX-CLIB_IPKG_TMP)/CONTROL/control
	echo "Architecture: $(SHORT_TARGET)" 				>>$(ROX-CLIB_IPKG_TMP)/CONTROL/control
	echo "Version: $(ROX-CLIB_VERSION)"		 		>>$(ROX-CLIB_IPKG_TMP)/CONTROL/control
	echo "Depends: libxml2, glib2, gtk2" 				>>$(ROX-CLIB_IPKG_TMP)/CONTROL/control
	echo "Description: C library for ROX apps"			>>$(ROX-CLIB_IPKG_TMP)/CONTROL/control
	cd $(FEEDDIR) && $(XMKIPKG) $(ROX-CLIB_IPKG_TMP)
	rm -rf $(ROX-CLIB_IPKG_TMP)
	touch $@

# ----------------------------------------------------------------------------
# Image-Install
# ----------------------------------------------------------------------------

ifdef PTXCONF_ROX-CLIB_INSTALL
ROMPACKAGES += $(STATEDIR)/ROX-CLib.imageinstall
endif

ROX-CLib_imageinstall_deps = $(STATEDIR)/ROX-CLib.targetinstall \
	$(STATEDIR)/virtual-image.install

$(STATEDIR)/ROX-CLib.imageinstall: $(ROX-CLib_imageinstall_deps)
	@$(call targetinfo, $@)
	cd $(FEEDDIR) && $(XIPKG) install rox-clib
	touch $@

# ----------------------------------------------------------------------------
# Clean
# ----------------------------------------------------------------------------

ROX-CLib_clean:
	rm -rf $(STATEDIR)/ROX-CLib.*
	rm -rf $(ROX-CLIB_DIR)

# vim: syntax=make
