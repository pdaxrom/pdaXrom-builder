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
ifdef PTXCONF_MINIMO
PACKAGES += minimo
endif

#
# Paths and names
#
MINIMO_DIR		= $(MOZILLA_DIR)
MINIMO_IPKG_TMP		= $(MINIMO_DIR)/ipkg_tmp

# ----------------------------------------------------------------------------
# Get
# ----------------------------------------------------------------------------

minimo_get: $(STATEDIR)/minimo.get

minimo_get_deps = $(MOZILLA_SOURCE)

$(STATEDIR)/minimo.get: $(minimo_get_deps)
	@$(call targetinfo, $@)
	@$(call get_patches, $(MOZILLA))
	touch $@

$(MINIMO_SOURCE):
	@$(call targetinfo, $@)
	@$(call get, $(MOZILLA_URL))

# ----------------------------------------------------------------------------
# Extract
# ----------------------------------------------------------------------------

minimo_extract: $(STATEDIR)/minimo.extract

minimo_extract_deps = $(STATEDIR)/minimo.get

$(STATEDIR)/minimo.extract: $(minimo_extract_deps)
	@$(call targetinfo, $@)
	@$(call clean, $(MINIMO_DIR))
	@$(call extract, $(MOZILLA_SOURCE))
	@$(call patchin, $(MOZILLA), $(MINIMO_DIR))
	touch $@

# ----------------------------------------------------------------------------
# Prepare
# ----------------------------------------------------------------------------

minimo_prepare: $(STATEDIR)/minimo.prepare

#
# dependencies
#
minimo_prepare_deps = \
	$(STATEDIR)/minimo.extract \
	$(STATEDIR)/gtk22.install     \
	$(STATEDIR)/libIDL082.install \
	$(STATEDIR)/virtual-xchain.install

MINIMO_PATH	=  PATH=$(CROSS_PATH)
MINIMO_ENV 	=  $(CROSS_ENV)
#MINIMO_ENV	+=
MINIMO_ENV	+= PKG_CONFIG_PATH=$(CROSS_LIB_DIR)/lib/pkgconfig:$(CROSS_LIB_DIR)/lib/pkgconfig
#ifdef PTXCONF_XFREE430
#MINIMO_ENV	+= LDFLAGS=-Wl,-rpath-link,$(CROSS_LIB_DIR)/lib
#endif

#
# autoconf
#
MINIMO_AUTOCONF = \
	--build=$(GNU_HOST) \
	--target=$(PTXCONF_GNU_TARGET) \
	--prefix=/usr/lib/minimo

ifdef PTXCONF_XFREE430
MINIMO_AUTOCONF += --x-includes=$(CROSS_LIB_DIR)/include
MINIMO_AUTOCONF += --x-libraries=$(CROSS_LIB_DIR)/lib
endif

$(STATEDIR)/minimo.prepare: $(minimo_prepare_deps)
	@$(call targetinfo, $@)
	@$(call clean, $(MINIMO_DIR)/config.cache)
ifdef PTXCONF_ARCH_X86
	cp $(TOPDIR)/config/pdaXrom-x86/mozconfig $(MINIMO_DIR)/.mozconfig
else
 ifdef PTXCONF_ARCH_ARM
	cp $(TOPDIR)/config/pdaXrom/minimo/.mozconfig $(MINIMO_DIR)/.mozconfig
 endif
endif
	cd $(MINIMO_DIR) && \
		$(MINIMO_PATH) $(MINIMO_ENV) \
		./configure $(MINIMO_AUTOCONF)
	touch $@

# ----------------------------------------------------------------------------
# Compile
# ----------------------------------------------------------------------------

minimo_compile: $(STATEDIR)/minimo.compile

minimo_compile_deps = $(STATEDIR)/minimo.prepare

$(STATEDIR)/minimo.compile: $(minimo_compile_deps)
	@$(call targetinfo, $@)
	$(MINIMO_PATH) CROSS_COMPILE=1 MINIMO=1 \
	    $(MAKE) -C $(MINIMO_DIR) $(XHOST_LIBIDL2_CFLAGS) $(XHOST_LIBIDL2_LIBS)
	touch $@

# ----------------------------------------------------------------------------
# Install
# ----------------------------------------------------------------------------

minimo_install: $(STATEDIR)/minimo.install

$(STATEDIR)/minimo.install: $(STATEDIR)/minimo.compile
	@$(call targetinfo, $@)
	##$(MINIMO_PATH) $(MAKE) -C $(MINIMO_DIR) install
	aasda
	touch $@

# ----------------------------------------------------------------------------
# Target-Install
# ----------------------------------------------------------------------------

minimo_targetinstall: $(STATEDIR)/minimo.targetinstall

minimo_targetinstall_deps = \
	$(STATEDIR)/minimo.compile \
	$(STATEDIR)/gtk22.targetinstall \
	$(STATEDIR)/libIDL082.targetinstall

$(STATEDIR)/minimo.targetinstall: $(minimo_targetinstall_deps)
	@$(call targetinfo, $@)

	$(MINIMO_PATH) CROSS_COMPILE=1 MINIMO=1 \
	    $(MAKE) -C $(MINIMO_DIR)/embedding/minimo $(XHOST_LIBIDL_CFLAGS) $(XHOST_LIBIDL_LIBS)
	
	cd $(MINIMO_DIR)/embedding/minimo && \
	    MOZ_OBJDIR=$(MINIMO_DIR) ./package.sh
	mkdir -p $(MINIMO_IPKG_TMP)/usr/bin
	mkdir -p $(MINIMO_IPKG_TMP)/usr/lib/minimo
	cp -a $(MINIMO_DIR)/dist/Embed $(MINIMO_IPKG_TMP)/usr/lib/minimo
	mkdir -p $(MINIMO_IPKG_TMP)/usr/share/applications
	mkdir -p $(MINIMO_IPKG_TMP)/usr/share/pixmaps
###ifdef PTXCONF_ARCH_ARM
	cp -a $(TOPDIR)/config/pdaXrom/minimo/minimo.desktop $(MINIMO_IPKG_TMP)/usr/share/applications
	cp -a $(TOPDIR)/config/pdaXrom/minimo/minimo.png     $(MINIMO_IPKG_TMP)/usr/share/pixmaps
###endif
	#cp -a $(TOPDIR)/config/pdaXrom/minimo/pref/* $(MINIMO_IPKG_TMP)/usr/lib/minimo/Embed/defaults/pref
	echo "#!/bin/sh" 					 >$(MINIMO_IPKG_TMP)/usr/bin/minimo
	echo "cd /usr/lib/minimo/Embed" 			>>$(MINIMO_IPKG_TMP)/usr/bin/minimo
	echo "export LD_LIBRARY_PATH=\$$PWD" 			>>$(MINIMO_IPKG_TMP)/usr/bin/minimo
	echo "./Minimo \"\$$@\""				>>$(MINIMO_IPKG_TMP)/usr/bin/minimo
	#echo "./run-mozilla.sh ./TestGtkEmbed"	>>$(MINIMO_IPKG_TMP)/usr/bin/minimo
	chmod 755 $(MINIMO_IPKG_TMP)/usr/bin/minimo
	for FILE in `find $(MINIMO_IPKG_TMP)/usr/ -type f`; do		\
	    ZZZ=`file $$FILE | grep 'ELF 32-bit'`;			\
	    if [  "$$ZZZ" != "" ]; then					\
		$(CROSSSTRIP) $$FILE;					\
	    fi;								\
	done
	mkdir -p $(MINIMO_IPKG_TMP)/CONTROL
	echo "Package: minimo" 						>$(MINIMO_IPKG_TMP)/CONTROL/control
	echo "Priority: optional" 					>>$(MINIMO_IPKG_TMP)/CONTROL/control
	echo "Section: Internet" 					>>$(MINIMO_IPKG_TMP)/CONTROL/control
	echo "Maintainer: Alexander Chukov <sash@pdaXrom.org>" 		>>$(MINIMO_IPKG_TMP)/CONTROL/control
	echo "Architecture: $(SHORT_TARGET)" 				>>$(MINIMO_IPKG_TMP)/CONTROL/control
	echo "Version: $(MOZILLA_VERSION)" 				>>$(MINIMO_IPKG_TMP)/CONTROL/control
	echo "Depends: gtk2" 						>>$(MINIMO_IPKG_TMP)/CONTROL/control
	echo "Description: This is the Embedding distribution of Mozilla.">>$(MINIMO_IPKG_TMP)/CONTROL/control
	cd $(FEEDDIR) && $(XMKIPKG) $(MINIMO_IPKG_TMP)
	touch $@

# ----------------------------------------------------------------------------
# Image-Install
# ----------------------------------------------------------------------------

ifdef PTXCONF_MINIMO_INSTALL
ROMPACKAGES += $(STATEDIR)/minimo.imageinstall
endif

minimo_imageinstall_deps = $(STATEDIR)/minimo.targetinstall \
	$(STATEDIR)/virtual-image.install

$(STATEDIR)/minimo.imageinstall: $(minimo_imageinstall_deps)
	@$(call targetinfo, $@)
	cd $(FEEDDIR) && $(XIPKG) install minimo
	touch $@

# ----------------------------------------------------------------------------
# Clean
# ----------------------------------------------------------------------------

minimo_clean:
	rm -rf $(STATEDIR)/minimo.*
	rm -rf $(MINIMO_DIR)

# vim: syntax=make
