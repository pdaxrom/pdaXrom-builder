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
ifdef PTXCONF_GETTEXT
PACKAGES += gettext
endif

#
# Paths and names
#
GETTEXT_VERSION		= 0.14.1
GETTEXT			= gettext-$(GETTEXT_VERSION)
GETTEXT_SUFFIX		= tar.gz
GETTEXT_URL		= http://ftp.gnu.org/pub/gnu/gettext/$(GETTEXT).$(GETTEXT_SUFFIX)
GETTEXT_SOURCE		= $(SRCDIR)/$(GETTEXT).$(GETTEXT_SUFFIX)
GETTEXT_DIR		= $(BUILDDIR)/$(GETTEXT)
GETTEXT_IPKG_TMP	= $(GETTEXT_DIR)/ipkg_tmp

# ----------------------------------------------------------------------------
# Get
# ----------------------------------------------------------------------------

gettext_get: $(STATEDIR)/gettext.get

gettext_get_deps = $(GETTEXT_SOURCE)

$(STATEDIR)/gettext.get: $(gettext_get_deps)
	@$(call targetinfo, $@)
	@$(call get_patches, $(GETTEXT))
	touch $@

$(GETTEXT_SOURCE):
	@$(call targetinfo, $@)
	@$(call get, $(GETTEXT_URL))

# ----------------------------------------------------------------------------
# Extract
# ----------------------------------------------------------------------------

gettext_extract: $(STATEDIR)/gettext.extract

gettext_extract_deps = $(STATEDIR)/gettext.get

$(STATEDIR)/gettext.extract: $(gettext_extract_deps)
	@$(call targetinfo, $@)
	@$(call clean, $(GETTEXT_DIR))
	@$(call extract, $(GETTEXT_SOURCE))
	@$(call patchin, $(GETTEXT))
	touch $@

# ----------------------------------------------------------------------------
# Prepare
# ----------------------------------------------------------------------------

gettext_prepare: $(STATEDIR)/gettext.prepare

#
# dependencies
#
gettext_prepare_deps = \
	$(STATEDIR)/gettext.extract \
	$(STATEDIR)/virtual-xchain.install

GETTEXT_PATH	=  PATH=$(CROSS_PATH)
GETTEXT_ENV 	=  $(CROSS_ENV)
#GETTEXT_ENV	+=
GETTEXT_ENV	+= PKG_CONFIG_PATH=$(CROSS_LIB_DIR)/lib/pkgconfig:$(CROSS_LIB_DIR)/lib/pkgconfig
#ifdef PTXCONF_XFREE430
#GETTEXT_ENV	+= LDFLAGS=-Wl,-rpath-link,$(CROSS_LIB_DIR)/lib
#endif

#
# autoconf
#
GETTEXT_AUTOCONF = \
	--build=$(GNU_HOST) \
	--host=$(PTXCONF_GNU_TARGET) \
	--prefix=$(PTXCONF_NATIVE_PREFIX) \
	--enable-shared \
	--disable-static

ifdef PTXCONF_XFREE430
GETTEXT_AUTOCONF += --x-includes=$(CROSS_LIB_DIR)/include
GETTEXT_AUTOCONF += --x-libraries=$(CROSS_LIB_DIR)/lib
endif

$(STATEDIR)/gettext.prepare: $(gettext_prepare_deps)
	@$(call targetinfo, $@)
	@$(call clean, $(GETTEXT_DIR)/config.cache)
	cd $(GETTEXT_DIR) && \
		$(GETTEXT_PATH) $(GETTEXT_ENV) \
		./configure $(GETTEXT_AUTOCONF)
	cp -f $(PTXCONF_PREFIX)/bin/libtool $(GETTEXT_DIR)/
	cp -f $(PTXCONF_PREFIX)/bin/libtool $(GETTEXT_DIR)/gettext-tools
	cp -f $(PTXCONF_PREFIX)/bin/libtool $(GETTEXT_DIR)/gettext-runtime
	touch $@

# ----------------------------------------------------------------------------
# Compile
# ----------------------------------------------------------------------------

gettext_compile: $(STATEDIR)/gettext.compile

gettext_compile_deps = $(STATEDIR)/gettext.prepare

$(STATEDIR)/gettext.compile: $(gettext_compile_deps)
	@$(call targetinfo, $@)
	$(GETTEXT_PATH) $(MAKE) -C $(GETTEXT_DIR)
	touch $@

# ----------------------------------------------------------------------------
# Install
# ----------------------------------------------------------------------------

gettext_install: $(STATEDIR)/gettext.install

$(STATEDIR)/gettext.install: $(STATEDIR)/gettext.compile
	@$(call targetinfo, $@)
	###$(GETTEXT_PATH) $(MAKE) -C $(GETTEXT_DIR) install
	asdasd
	touch $@

# ----------------------------------------------------------------------------
# Target-Install
# ----------------------------------------------------------------------------

gettext_targetinstall: $(STATEDIR)/gettext.targetinstall

gettext_targetinstall_deps = $(STATEDIR)/gettext.compile

$(STATEDIR)/gettext.targetinstall: $(gettext_targetinstall_deps)
	@$(call targetinfo, $@)
	$(GETTEXT_PATH) $(MAKE) -C $(GETTEXT_DIR) DESTDIR=$(GETTEXT_IPKG_TMP) install
	rm -rf $(GETTEXT_IPKG_TMP)$(PTXCONF_NATIVE_PREFIX)/include
	rm -rf $(GETTEXT_IPKG_TMP)$(PTXCONF_NATIVE_PREFIX)/info
	rm -rf $(GETTEXT_IPKG_TMP)$(PTXCONF_NATIVE_PREFIX)/lib/*.*a
	rm -rf $(GETTEXT_IPKG_TMP)$(PTXCONF_NATIVE_PREFIX)/share/{doc,emacs,locale,man}
	for FILE in `find $(GETTEXT_IPKG_TMP)$(PTXCONF_NATIVE_PREFIX)/ -type f`; do		\
	    ZZZ=`file $$FILE | grep 'ELF 32-bit'`;			\
	    if [  "$$ZZZ" != "" ]; then					\
		$(CROSSSTRIP) $$FILE;					\
	    fi;								\
	done
	mkdir -p $(GETTEXT_IPKG_TMP)/CONTROL
	echo "Package: gettext" 						>$(GETTEXT_IPKG_TMP)/CONTROL/control
	echo "Priority: optional" 						>>$(GETTEXT_IPKG_TMP)/CONTROL/control
	echo "Section: Utilities" 						>>$(GETTEXT_IPKG_TMP)/CONTROL/control
	echo "Maintainer: Alexander Chukov <sash@pdaXrom.org>" 			>>$(GETTEXT_IPKG_TMP)/CONTROL/control
	echo "Architecture: $(SHORT_TARGET)" 					>>$(GETTEXT_IPKG_TMP)/CONTROL/control
	echo "Version: $(GETTEXT_VERSION)" 					>>$(GETTEXT_IPKG_TMP)/CONTROL/control
	echo "Depends: " 							>>$(GETTEXT_IPKG_TMP)/CONTROL/control
	echo "Description: This is the GNU gettext package."			>>$(GETTEXT_IPKG_TMP)/CONTROL/control
	cd $(FEEDDIR) && $(XMKIPKG) $(GETTEXT_IPKG_TMP)
	touch $@

# ----------------------------------------------------------------------------
# Image-Install
# ----------------------------------------------------------------------------

ifdef PTXCONF_GETTEXT_INSTALL
ROMPACKAGES += $(STATEDIR)/gettext.imageinstall
endif

gettext_imageinstall_deps = $(STATEDIR)/gettext.targetinstall \
	$(STATEDIR)/virtual-image.install

$(STATEDIR)/gettext.imageinstall: $(gettext_imageinstall_deps)
	@$(call targetinfo, $@)
	cd $(FEEDDIR) && $(XIPKG) install gettext
	touch $@

# ----------------------------------------------------------------------------
# Clean
# ----------------------------------------------------------------------------

gettext_clean:
	rm -rf $(STATEDIR)/gettext.*
	rm -rf $(GETTEXT_DIR)

# vim: syntax=make
