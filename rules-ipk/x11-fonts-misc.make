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
ifdef PTXCONF_X11-FONTS-MISC
PACKAGES += x11-fonts-misc
endif

#
# Paths and names
#
X11-FONTS-MISC_VERSION		= 1.0.0
X11-FONTS-MISC			= x11-fonts-misc
X11-FONTS-MISC_SUFFIX		= tar.bz2
X11-FONTS-MISC_URL		= http://www.pdaXrom.org/src/$(X11-FONTS-MISC).$(X11-FONTS-MISC_SUFFIX)
X11-FONTS-MISC_SOURCE		= $(SRCDIR)/$(X11-FONTS-MISC).$(X11-FONTS-MISC_SUFFIX)
X11-FONTS-MISC_DIR		= $(BUILDDIR)/$(X11-FONTS-MISC)
X11-FONTS-MISC_IPKG_TMP		= $(X11-FONTS-MISC_DIR)

# ----------------------------------------------------------------------------
# Get
# ----------------------------------------------------------------------------

x11-fonts-misc_get: $(STATEDIR)/x11-fonts-misc.get

x11-fonts-misc_get_deps = $(X11-FONTS-MISC_SOURCE)

$(STATEDIR)/x11-fonts-misc.get: $(x11-fonts-misc_get_deps)
	@$(call targetinfo, $@)
	@$(call get_patches, $(X11-FONTS-MISC))
	touch $@

$(X11-FONTS-MISC_SOURCE):
	@$(call targetinfo, $@)
	@$(call get, $(X11-FONTS-MISC_URL))

# ----------------------------------------------------------------------------
# Extract
# ----------------------------------------------------------------------------

x11-fonts-misc_extract: $(STATEDIR)/x11-fonts-misc.extract

x11-fonts-misc_extract_deps = $(STATEDIR)/x11-fonts-misc.get

$(STATEDIR)/x11-fonts-misc.extract: $(x11-fonts-misc_extract_deps)
	@$(call targetinfo, $@)
	@$(call clean, $(X11-FONTS-MISC_DIR))
	@$(call extract, $(X11-FONTS-MISC_SOURCE))
	@$(call patchin, $(X11-FONTS-MISC))
	touch $@

# ----------------------------------------------------------------------------
# Prepare
# ----------------------------------------------------------------------------

x11-fonts-misc_prepare: $(STATEDIR)/x11-fonts-misc.prepare

#
# dependencies
#
x11-fonts-misc_prepare_deps = \
	$(STATEDIR)/x11-fonts-misc.extract \
	$(STATEDIR)/virtual-xchain.install

X11-FONTS-MISC_PATH	=  PATH=$(CROSS_PATH)
X11-FONTS-MISC_ENV 	=  $(CROSS_ENV)
#X11-FONTS-MISC_ENV	+=
X11-FONTS-MISC_ENV	+= PKG_CONFIG_PATH=$(CROSS_LIB_DIR)/lib/pkgconfig:$(CROSS_LIB_DIR)/lib/pkgconfig
#ifdef PTXCONF_XFREE430
#X11-FONTS-MISC_ENV	+= LDFLAGS=-Wl,-rpath-link,$(CROSS_LIB_DIR)/lib
#endif

#
# autoconf
#
X11-FONTS-MISC_AUTOCONF = \
	--build=$(GNU_HOST) \
	--host=$(PTXCONF_GNU_TARGET) \
	--prefix=/usr

ifdef PTXCONF_XFREE430
X11-FONTS-MISC_AUTOCONF += --x-includes=$(CROSS_LIB_DIR)/include
X11-FONTS-MISC_AUTOCONF += --x-libraries=$(CROSS_LIB_DIR)/lib
endif

$(STATEDIR)/x11-fonts-misc.prepare: $(x11-fonts-misc_prepare_deps)
	@$(call targetinfo, $@)
	@$(call clean, $(X11-FONTS-MISC_DIR)/config.cache)
	#cd $(X11-FONTS-MISC_DIR) && \
	#	$(X11-FONTS-MISC_PATH) $(X11-FONTS-MISC_ENV) \
	#	./configure $(X11-FONTS-MISC_AUTOCONF)
	touch $@

# ----------------------------------------------------------------------------
# Compile
# ----------------------------------------------------------------------------

x11-fonts-misc_compile: $(STATEDIR)/x11-fonts-misc.compile

x11-fonts-misc_compile_deps = $(STATEDIR)/x11-fonts-misc.prepare

$(STATEDIR)/x11-fonts-misc.compile: $(x11-fonts-misc_compile_deps)
	@$(call targetinfo, $@)
	touch $@

# ----------------------------------------------------------------------------
# Install
# ----------------------------------------------------------------------------

x11-fonts-misc_install: $(STATEDIR)/x11-fonts-misc.install

$(STATEDIR)/x11-fonts-misc.install: $(STATEDIR)/x11-fonts-misc.compile
	@$(call targetinfo, $@)
	touch $@

# ----------------------------------------------------------------------------
# Target-Install
# ----------------------------------------------------------------------------

x11-fonts-misc_targetinstall: $(STATEDIR)/x11-fonts-misc.targetinstall

x11-fonts-misc_targetinstall_deps = $(STATEDIR)/x11-fonts-misc.compile

$(STATEDIR)/x11-fonts-misc.targetinstall: $(x11-fonts-misc_targetinstall_deps)
	@$(call targetinfo, $@)
	mkdir -p $(X11-FONTS-MISC_IPKG_TMP)/CONTROL
	echo "Package: x11-fonts-misc" 					>$(X11-FONTS-MISC_IPKG_TMP)/CONTROL/control
	echo "Priority: optional" 					>>$(X11-FONTS-MISC_IPKG_TMP)/CONTROL/control
	echo "Section: X11"			 			>>$(X11-FONTS-MISC_IPKG_TMP)/CONTROL/control
	echo "Maintainer: Alexander Chukov <sash@pdaXrom.org>" 		>>$(X11-FONTS-MISC_IPKG_TMP)/CONTROL/control
	echo "Architecture: $(SHORT_TARGET)" 				>>$(X11-FONTS-MISC_IPKG_TMP)/CONTROL/control
	echo "Version: $(X11-FONTS-MISC_VERSION)" 			>>$(X11-FONTS-MISC_IPKG_TMP)/CONTROL/control
	echo "Depends: xfree430" 					>>$(X11-FONTS-MISC_IPKG_TMP)/CONTROL/control
	echo "Description: X11 misc fonts - fixed fonts ISO8859-1/2, KOI8-R">>$(X11-FONTS-MISC_IPKG_TMP)/CONTROL/control
	echo "#!/bin/sh"				 >$(X11-FONTS-MISC_IPKG_TMP)/CONTROL/postinst
	echo "if [ \$$DISPLAY ]; then"			>>$(X11-FONTS-MISC_IPKG_TMP)/CONTROL/postinst
	echo " xset fp+ /usr/X11R6/lib/X11/fonts/misc"	>>$(X11-FONTS-MISC_IPKG_TMP)/CONTROL/postinst
	echo "fi"					>>$(X11-FONTS-MISC_IPKG_TMP)/CONTROL/postinst
	chmod 755 $(X11-FONTS-MISC_IPKG_TMP)/CONTROL/postinst
	cd $(FEEDDIR) && $(XMKIPKG) $(X11-FONTS-MISC_IPKG_TMP)
	touch $@

# ----------------------------------------------------------------------------
# Image-Install
# ----------------------------------------------------------------------------

ifdef PTXCONF_X11-FONTS-MISC_INSTALL
ROMPACKAGES += $(STATEDIR)/x11-fonts-misc.imageinstall
endif

x11-fonts-misc_imageinstall_deps = $(STATEDIR)/x11-fonts-misc.targetinstall \
	$(STATEDIR)/virtual-image.install

$(STATEDIR)/x11-fonts-misc.imageinstall: $(x11-fonts-misc_imageinstall_deps)
	@$(call targetinfo, $@)
	cd $(FEEDDIR) && $(XIPKG) install x11-fonts-misc
	touch $@

# ----------------------------------------------------------------------------
# Clean
# ----------------------------------------------------------------------------

x11-fonts-misc_clean:
	rm -rf $(STATEDIR)/x11-fonts-misc.*
	rm -rf $(X11-FONTS-MISC_DIR)

# vim: syntax=make
