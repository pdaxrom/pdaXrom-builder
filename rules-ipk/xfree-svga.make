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
ifdef PTXCONF_XFREE-SVGA
PACKAGES += xfree-svga
endif

#
# Paths and names
#
XFREE-SVGA_VERSION		= 4.3.99.902
XFREE-SVGA			= XFree86-$(XFREE-SVGA_VERSION)
XFREE-SVGA_SUFFIX		= tar.bz2
XFREE-SVGA_URL			= http://www.pdaXrom.org/src/$(XFREE-SVGA).$(XFREE-SVGA_SUFFIX)
XFREE-SVGA_SOURCE		= $(SRCDIR)/$(XFREE-SVGA).$(XFREE-SVGA_SUFFIX)
XFREE-SVGA_DIR			= $(BUILDDIR)/$(XFREE-SVGA)/xc
XFREE-SVGA_IPKG_TMP		= $(XFREE-SVGA_DIR)/ipkg_tmp

# ----------------------------------------------------------------------------
# Get
# ----------------------------------------------------------------------------

xfree-svga_get: $(STATEDIR)/xfree-svga.get

xfree-svga_get_deps = $(XFREE-SVGA_SOURCE)

$(STATEDIR)/xfree-svga.get: $(xfree-svga_get_deps)
	@$(call targetinfo, $@)
	@$(call get_patches, $(XFREE-SVGA))
	touch $@

$(XFREE-SVGA_SOURCE):
	@$(call targetinfo, $@)
	@$(call get, $(XFREE-SVGA_URL))

# ----------------------------------------------------------------------------
# Extract
# ----------------------------------------------------------------------------

xfree-svga_extract: $(STATEDIR)/xfree-svga.extract

xfree-svga_extract_deps = $(STATEDIR)/xfree-svga.get

$(STATEDIR)/xfree-svga.extract: $(xfree-svga_extract_deps)
	@$(call targetinfo, $@)
	@$(call clean, $(XFREE-SVGA_DIR))
	@$(call extract, $(XFREE-SVGA_SOURCE), $(BUILDDIR)/$(XFREE-SVGA))
	@$(call patchin, $(XFREE-SVGA), $(XFREE-SVGA_DIR))
	touch $@

# ----------------------------------------------------------------------------
# Prepare
# ----------------------------------------------------------------------------

xfree-svga_prepare: $(STATEDIR)/xfree-svga.prepare

#
# dependencies
#
xfree-svga_prepare_deps = \
	$(STATEDIR)/xfree-svga.extract \
	$(STATEDIR)/xfree430.install \
	$(STATEDIR)/virtual-xchain.install

XFREE-SVGA_PATH	=  PATH=$(CROSS_PATH)
XFREE-SVGA_ENV 	=  $(CROSS_ENV)
#XFREE-SVGA_ENV	+=
XFREE-SVGA_ENV	+= PKG_CONFIG_PATH=$(CROSS_LIB_DIR)/lib/pkgconfig:$(CROSS_LIB_DIR)/lib/pkgconfig
#ifdef PTXCONF_XFREE430
#XFREE-SVGA_ENV	+= LDFLAGS=-Wl,-rpath-link,$(CROSS_LIB_DIR)/lib
#endif

#
# autoconf
#
XFREE-SVGA_AUTOCONF = \
	--build=$(GNU_HOST) \
	--host=$(PTXCONF_GNU_TARGET) \
	--prefix=/usr

ifdef PTXCONF_XFREE430
XFREE-SVGA_AUTOCONF += --x-includes=$(CROSS_LIB_DIR)/include
XFREE-SVGA_AUTOCONF += --x-libraries=$(CROSS_LIB_DIR)/lib
endif

$(STATEDIR)/xfree-svga.prepare: $(xfree-svga_prepare_deps)
	@$(call targetinfo, $@)
	@$(call clean, $(XFREE-SVGA_DIR)/config.cache)
	#cd $(XFREE-SVGA_DIR) && \
	#	$(XFREE-SVGA_PATH) $(XFREE-SVGA_ENV) \
	#	./configure $(XFREE-SVGA_AUTOCONF)
	ln -sf $(PTXCONF_PREFIX)/bin/$(PTXCONF_GNU_TARGET)-cpp $(PTXCONF_PREFIX)/$(PTXCONF_GNU_TARGET)/bin/cpp
	ln -sf $(PTXCONF_PREFIX)/bin/$(PTXCONF_GNU_TARGET)-gcc $(PTXCONF_PREFIX)/$(PTXCONF_GNU_TARGET)/bin/cc
	cp -a $(TOPDIR)/config/xfree/SVGA-host.def $(XFREE-SVGA_DIR)/config/cf/host.def
	perl -i -p -e "s,\@FREETYPE2DIR@,`$(PTXCONF_PREFIX)/bin/freetype-config --prefix`,g" $(XFREE-SVGA_DIR)/config/cf/host.def
	perl -i -p -e "s,\@FONTCONFIGDIR@,$(CROSS_LIB_DIR),g" $(XFREE-SVGA_DIR)/config/cf/host.def
	perl -i -p -e "s,\@EXPATDIR@,$(CROSS_LIB_DIR),g" $(XFREE-SVGA_DIR)/config/cf/host.def
	perl -i -p -e "s,\@LIBPNGDIR@,$(CROSS_LIB_DIR),g" $(XFREE-SVGA_DIR)/config/cf/host.def
	touch $(XFREE-SVGA_DIR)/xf86Date.h
	touch $(XFREE-SVGA_DIR)/xf86Version.h
	touch $@

# ----------------------------------------------------------------------------
# Compile
# ----------------------------------------------------------------------------

xfree-svga_compile: $(STATEDIR)/xfree-svga.compile

xfree-svga_compile_deps = $(STATEDIR)/xfree-svga.prepare

$(STATEDIR)/xfree-svga.compile: $(xfree-svga_compile_deps)
	@$(call targetinfo, $@)
	cd $(XFREE-SVGA_DIR) && \
		$(XFREE-SVGA_ENV) $(MAKE) World CROSSCOMPILEDIR=$(PTXCONF_PREFIX)/$(PTXCONF_GNU_TARGET)/bin
	touch $@

# ----------------------------------------------------------------------------
# Install
# ----------------------------------------------------------------------------

xfree-svga_install: $(STATEDIR)/xfree-svga.install

$(STATEDIR)/xfree-svga.install: $(STATEDIR)/xfree-svga.compile
	@$(call targetinfo, $@)
	touch $@

# ----------------------------------------------------------------------------
# Target-Install
# ----------------------------------------------------------------------------

xfree-svga_targetinstall: $(STATEDIR)/xfree-svga.targetinstall

xfree-svga_targetinstall_deps = $(STATEDIR)/xfree-svga.compile

$(STATEDIR)/xfree-svga.targetinstall: $(xfree-svga_targetinstall_deps)
	@$(call targetinfo, $@)
	cd $(XFREE-SVGA_DIR) && \
		$(XFREE-SVGA_ENV) $(MAKE) CROSSCOMPILEDIR=$(PTXCONF_PREFIX)/$(PTXCONF_GNU_TARGET)/bin \
		DESTDIR=$(XFREE-SVGA_IPKG_TMP) install
	rm -rf $(XFREE-SVGA_IPKG_TMP)/usr/include
	rm -rf $(XFREE-SVGA_IPKG_TMP)/usr/X11R6/include
	rm -rf $(XFREE-SVGA_IPKG_TMP)/usr/X11R6/lib/*.*a

	for FILE in `find $(XFREE-SVGA_IPKG_TMP)/usr/X11R6/bin -type f`; do	\
	    ZZZ=`file $$FILE | grep 'ELF 32-bit'`;				\
	    if [  "$$ZZZ" != "" ]; then						\
		$(CROSSSTRIP) $$FILE;						\
	    fi;									\
	done

	mkdir -p $(XFREE-SVGA_IPKG_TMP)/etc/rc.d/init.d
	mkdir -p $(XFREE-SVGA_IPKG_TMP)/etc/rc.d/rc5.d
	cp -a $(TOPDIR)/config/pdaXrom-x86/xdetect $(XFREE-SVGA_IPKG_TMP)/etc/rc.d/init.d
	ln -sf ../init.d/xdetect $(XFREE-SVGA_IPKG_TMP)/etc/rc.d/rc5.d/S80xdetect
	
	perl -i -p -e "s,\@PTXCONF_PREFIX@,$(PTXCONF_NATIVE_PREFIX),g"	$(XFREE-SVGA_IPKG_TMP)/etc/rc.d/init.d/xdetect

	mkdir -p $(XFREE-SVGA_IPKG_TMP)/CONTROL
	echo "Package: xfree-svga-server" 				>$(XFREE-SVGA_IPKG_TMP)/CONTROL/control
	echo "Priority: optional" 					>>$(XFREE-SVGA_IPKG_TMP)/CONTROL/control
	echo "Section: X11" 						>>$(XFREE-SVGA_IPKG_TMP)/CONTROL/control
	echo "Maintainer: Alexander Chukov <sash@pdaXrom.org>" 		>>$(XFREE-SVGA_IPKG_TMP)/CONTROL/control
	echo "Architecture: $(SHORT_TARGET)" 				>>$(XFREE-SVGA_IPKG_TMP)/CONTROL/control
	echo "Version: $(XFREE-SVGA_VERSION)" 				>>$(XFREE-SVGA_IPKG_TMP)/CONTROL/control
	echo "Depends: " 						>>$(XFREE-SVGA_IPKG_TMP)/CONTROL/control
	echo "Description: X11 SVGA server"				>>$(XFREE-SVGA_IPKG_TMP)/CONTROL/control
	
	echo "#!/bin/sh"						>$(XFREE-SVGA_IPKG_TMP)/CONTROL/preinst
	echo 'rm -f      $$PKG_ROOT/usr/X11R6/bin/X'			>>$(XFREE-SVGA_IPKG_TMP)/CONTROL/preinst
	
	echo "#!/bin/sh"						>$(XFREE-SVGA_IPKG_TMP)/CONTROL/postinst
	echo 'chmod 4755 $$PKG_ROOT/usr/X11R6/bin/X'			>>$(XFREE-SVGA_IPKG_TMP)/CONTROL/postinst

	echo "#!/bin/sh"						>$(XFREE-SVGA_IPKG_TMP)/CONTROL/postrm
	echo 'ln -sf Xfbdev $$PKG_ROOT/usr/X11R6/bin/X'			>>$(XFREE-SVGA_IPKG_TMP)/CONTROL/postrm

	chmod 755 $(XFREE-SVGA_IPKG_TMP)/CONTROL/{preinst,postinst,postrm}

	cd $(FEEDDIR) && $(XMKIPKG) $(XFREE-SVGA_IPKG_TMP)
	touch $@

# ----------------------------------------------------------------------------
# Image-Install
# ----------------------------------------------------------------------------

ifdef PTXCONF_XFREE-SVGA_INSTALL
ROMPACKAGES += $(STATEDIR)/xfree-svga.imageinstall
endif

xfree-svga_imageinstall_deps = $(STATEDIR)/xfree-svga.targetinstall \
	$(STATEDIR)/virtual-image.install

$(STATEDIR)/xfree-svga.imageinstall: $(xfree-svga_imageinstall_deps)
	@$(call targetinfo, $@)
	cd $(FEEDDIR) && $(XIPKG) install xfree-svga-server
	touch $@

# ----------------------------------------------------------------------------
# Clean
# ----------------------------------------------------------------------------

xfree-svga_clean:
	rm -rf $(STATEDIR)/xfree-svga.*
	rm -rf $(XFREE-SVGA_DIR)

# vim: syntax=make
