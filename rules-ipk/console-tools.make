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
ifdef PTXCONF_CONSOLE-TOOLS
PACKAGES += console-tools
endif

#
# Paths and names
#
#CONSOLE-TOOLS_VERSION		= 0.2.3
CONSOLE-TOOLS_VERSION		= 0.3.2
CONSOLE-TOOLS			= console-tools-$(CONSOLE-TOOLS_VERSION)
CONSOLE-TOOLS_SUFFIX		= tar.gz
CONSOLE-TOOLS_URL		= http://voxel.dl.sourceforge.net/sourceforge/lct/$(CONSOLE-TOOLS).$(CONSOLE-TOOLS_SUFFIX)
CONSOLE-TOOLS_SOURCE		= $(SRCDIR)/$(CONSOLE-TOOLS).$(CONSOLE-TOOLS_SUFFIX)
CONSOLE-TOOLS_DIR		= $(BUILDDIR)/$(CONSOLE-TOOLS)
CONSOLE-TOOLS_IPKG_TMP		= $(CONSOLE-TOOLS_DIR)/ipkg_tmp

# ----------------------------------------------------------------------------
# Get
# ----------------------------------------------------------------------------

console-tools_get: $(STATEDIR)/console-tools.get

console-tools_get_deps = $(CONSOLE-TOOLS_SOURCE)

$(STATEDIR)/console-tools.get: $(console-tools_get_deps)
	@$(call targetinfo, $@)
	@$(call get_patches, $(CONSOLE-TOOLS))
	touch $@

$(CONSOLE-TOOLS_SOURCE):
	@$(call targetinfo, $@)
	@$(call get, $(CONSOLE-TOOLS_URL))

# ----------------------------------------------------------------------------
# Extract
# ----------------------------------------------------------------------------

console-tools_extract: $(STATEDIR)/console-tools.extract

console-tools_extract_deps = $(STATEDIR)/console-tools.get

$(STATEDIR)/console-tools.extract: $(console-tools_extract_deps)
	@$(call targetinfo, $@)
	@$(call clean, $(CONSOLE-TOOLS_DIR))
	@$(call extract, $(CONSOLE-TOOLS_SOURCE))
	@$(call patchin, $(CONSOLE-TOOLS))
	touch $@

# ----------------------------------------------------------------------------
# Prepare
# ----------------------------------------------------------------------------

console-tools_prepare: $(STATEDIR)/console-tools.prepare

#
# dependencies
#
console-tools_prepare_deps = \
	$(STATEDIR)/console-tools.extract \
	$(STATEDIR)/virtual-xchain.install

CONSOLE-TOOLS_PATH	=  PATH=$(CROSS_PATH)
CONSOLE-TOOLS_ENV 	=  $(CROSS_ENV)
#CONSOLE-TOOLS_ENV	+=
CONSOLE-TOOLS_ENV	+= PKG_CONFIG_PATH=$(CROSS_LIB_DIR)/lib/pkgconfig:$(CROSS_LIB_DIR)/lib/pkgconfig
#ifdef PTXCONF_XFREE430
#CONSOLE-TOOLS_ENV	+= LDFLAGS=-Wl,-rpath-link,$(CROSS_LIB_DIR)/lib
#endif

#
# autoconf
#
CONSOLE-TOOLS_AUTOCONF = \
	--build=$(GNU_HOST) \
	--host=$(PTXCONF_GNU_TARGET) \
	--prefix=/usr \
	--enable-shared \
	--disable-static

ifdef PTXCONF_XFREE430
CONSOLE-TOOLS_AUTOCONF += --x-includes=$(CROSS_LIB_DIR)/include
CONSOLE-TOOLS_AUTOCONF += --x-libraries=$(CROSS_LIB_DIR)/lib
endif

$(STATEDIR)/console-tools.prepare: $(console-tools_prepare_deps)
	@$(call targetinfo, $@)
	@$(call clean, $(CONSOLE-TOOLS_DIR)/config.cache)
	#mkdir -p $(CONSOLE-TOOLS_DIR)/config
	#cp -f $(TOPDIR)/config/pics/config-console-tools/*.m4 $(CONSOLE-TOOLS_DIR)/config
	#cd $(CONSOLE-TOOLS_DIR) && $(CONSOLE-TOOLS_PATH) aclocal -I config
	#cd $(CONSOLE-TOOLS_DIR) && $(CONSOLE-TOOLS_PATH) automake --add-missing
	#cd $(CONSOLE-TOOLS_DIR) && $(CONSOLE-TOOLS_PATH) autoconf
	cd $(CONSOLE-TOOLS_DIR) && \
		$(CONSOLE-TOOLS_PATH) $(CONSOLE-TOOLS_ENV) \
		./configure $(CONSOLE-TOOLS_AUTOCONF)
	touch $@

# ----------------------------------------------------------------------------
# Compile
# ----------------------------------------------------------------------------

console-tools_compile: $(STATEDIR)/console-tools.compile

console-tools_compile_deps = $(STATEDIR)/console-tools.prepare

$(STATEDIR)/console-tools.compile: $(console-tools_compile_deps)
	@$(call targetinfo, $@)
	$(CONSOLE-TOOLS_PATH) $(MAKE) -C $(CONSOLE-TOOLS_DIR)
	touch $@

# ----------------------------------------------------------------------------
# Install
# ----------------------------------------------------------------------------

console-tools_install: $(STATEDIR)/console-tools.install

$(STATEDIR)/console-tools.install: $(STATEDIR)/console-tools.compile
	@$(call targetinfo, $@)
	touch $@

# ----------------------------------------------------------------------------
# Target-Install
# ----------------------------------------------------------------------------

console-tools_targetinstall: $(STATEDIR)/console-tools.targetinstall

console-tools_targetinstall_deps = $(STATEDIR)/console-tools.compile

$(STATEDIR)/console-tools.targetinstall: $(console-tools_targetinstall_deps)
	@$(call targetinfo, $@)
	$(CONSOLE-TOOLS_PATH) $(MAKE) -C $(CONSOLE-TOOLS_DIR) DESTDIR=$(CONSOLE-TOOLS_IPKG_TMP)-all install
	rm -rf $(CONSOLE-TOOLS_IPKG_TMP)-all/usr/include
	rm -rf $(CONSOLE-TOOLS_IPKG_TMP)-all/usr/lib/*.*a
	rm -rf $(CONSOLE-TOOLS_IPKG_TMP)-all/usr/man
	for FILE in `find $(CONSOLE-TOOLS_IPKG_TMP)-all/usr/ -type f`; do	\
	    ZZZ=`file $$FILE | grep 'ELF 32-bit'`;				\
	    if [  "$$ZZZ" != "" ]; then						\
		$(CROSSSTRIP) $$FILE;						\
	    fi;									\
	done
	
	rm -rf $(CONSOLE-TOOLS_IPKG_TMP)
	cp -a  $(CONSOLE-TOOLS_IPKG_TMP)-all $(CONSOLE-TOOLS_IPKG_TMP)
	rm -rf $(CONSOLE-TOOLS_IPKG_TMP)/usr/bin
	mkdir -p $(CONSOLE-TOOLS_IPKG_TMP)/CONTROL
	echo "Package: console-tools-libs" 					>$(CONSOLE-TOOLS_IPKG_TMP)/CONTROL/control
	echo "Priority: optional" 						>>$(CONSOLE-TOOLS_IPKG_TMP)/CONTROL/control
	echo "Section: Console" 						>>$(CONSOLE-TOOLS_IPKG_TMP)/CONTROL/control
	echo "Maintainer: Alexander Chukov <sash@pdaXrom.org>" 			>>$(CONSOLE-TOOLS_IPKG_TMP)/CONTROL/control
	echo "Architecture: $(SHORT_TARGET)" 					>>$(CONSOLE-TOOLS_IPKG_TMP)/CONTROL/control
	echo "Version: $(CONSOLE-TOOLS_VERSION)" 				>>$(CONSOLE-TOOLS_IPKG_TMP)/CONTROL/control
	echo "Depends: " 							>>$(CONSOLE-TOOLS_IPKG_TMP)/CONTROL/control
	echo "Description: The Linux Console Tools (libraries)"			>>$(CONSOLE-TOOLS_IPKG_TMP)/CONTROL/control
	cd $(FEEDDIR) && $(XMKIPKG) $(CONSOLE-TOOLS_IPKG_TMP)

	rm -rf $(CONSOLE-TOOLS_IPKG_TMP)
	mkdir -p $(CONSOLE-TOOLS_IPKG_TMP)/usr/bin
	cp -a  $(CONSOLE-TOOLS_IPKG_TMP)-all/usr/bin/loadkeys $(CONSOLE-TOOLS_IPKG_TMP)/usr/bin/
	mkdir -p $(CONSOLE-TOOLS_IPKG_TMP)/CONTROL
	echo "Package: console-tools-loadkeys"	 				>$(CONSOLE-TOOLS_IPKG_TMP)/CONTROL/control
	echo "Priority: optional" 						>>$(CONSOLE-TOOLS_IPKG_TMP)/CONTROL/control
	echo "Section: Console" 						>>$(CONSOLE-TOOLS_IPKG_TMP)/CONTROL/control
	echo "Maintainer: Alexander Chukov <sash@pdaXrom.org>" 			>>$(CONSOLE-TOOLS_IPKG_TMP)/CONTROL/control
	echo "Architecture: $(SHORT_TARGET)" 					>>$(CONSOLE-TOOLS_IPKG_TMP)/CONTROL/control
	echo "Version: $(CONSOLE-TOOLS_VERSION)" 				>>$(CONSOLE-TOOLS_IPKG_TMP)/CONTROL/control
	echo "Depends: console-tools-libs" 					>>$(CONSOLE-TOOLS_IPKG_TMP)/CONTROL/control
	echo "Description: The Linux Console Tools (loadkeys)"			>>$(CONSOLE-TOOLS_IPKG_TMP)/CONTROL/control
	cd $(FEEDDIR) && $(XMKIPKG) $(CONSOLE-TOOLS_IPKG_TMP)

	rm -rf $(CONSOLE-TOOLS_IPKG_TMP)
	mkdir -p $(CONSOLE-TOOLS_IPKG_TMP)/usr/bin
	cp -a  $(CONSOLE-TOOLS_IPKG_TMP)-all/usr/bin/* $(CONSOLE-TOOLS_IPKG_TMP)/usr/bin/
	rm -f $(CONSOLE-TOOLS_IPKG_TMP)/usr/bin/loadkeys
	mkdir -p $(CONSOLE-TOOLS_IPKG_TMP)/CONTROL
	echo "Package: console-tools"		 				>$(CONSOLE-TOOLS_IPKG_TMP)/CONTROL/control
	echo "Priority: optional" 						>>$(CONSOLE-TOOLS_IPKG_TMP)/CONTROL/control
	echo "Section: Console" 						>>$(CONSOLE-TOOLS_IPKG_TMP)/CONTROL/control
	echo "Maintainer: Alexander Chukov <sash@pdaXrom.org>" 			>>$(CONSOLE-TOOLS_IPKG_TMP)/CONTROL/control
	echo "Architecture: $(SHORT_TARGET)" 					>>$(CONSOLE-TOOLS_IPKG_TMP)/CONTROL/control
	echo "Version: $(CONSOLE-TOOLS_VERSION)" 				>>$(CONSOLE-TOOLS_IPKG_TMP)/CONTROL/control
	echo "Depends: console-tools-libs, console-tools-loadkeys" 		>>$(CONSOLE-TOOLS_IPKG_TMP)/CONTROL/control
	echo "Description: The Linux Console Tools"				>>$(CONSOLE-TOOLS_IPKG_TMP)/CONTROL/control
	cd $(FEEDDIR) && $(XMKIPKG) $(CONSOLE-TOOLS_IPKG_TMP)

	touch $@

# ----------------------------------------------------------------------------
# Image-Install
# ----------------------------------------------------------------------------

ifdef PTXCONF_CONSOLE-TOOLS_INSTALL
ROMPACKAGES += $(STATEDIR)/console-tools.imageinstall
endif

console-tools_imageinstall_deps = $(STATEDIR)/console-tools.targetinstall \
	$(STATEDIR)/virtual-image.install

$(STATEDIR)/console-tools.imageinstall: $(console-tools_imageinstall_deps)
	@$(call targetinfo, $@)
ifdef PTXCONF_CONSOLE-TOOLS-LOADKEYS_INSTALL
	cd $(FEEDDIR) && $(XIPKG) install console-tools-loadkeys
else
	cd $(FEEDDIR) && $(XIPKG) install console-tools
endif
	touch $@

# ----------------------------------------------------------------------------
# Clean
# ----------------------------------------------------------------------------

console-tools_clean:
	rm -rf $(STATEDIR)/console-tools.*
	rm -rf $(CONSOLE-TOOLS_DIR)

# vim: syntax=make
