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
ifdef PTXCONF_READLINE
PACKAGES += readline
endif

#
# Paths and names
#
READLINE_VERSION	= 4.3
READLINE		= readline-$(READLINE_VERSION)
READLINE_SUFFIX		= tar.gz
READLINE_URL		= ftp://ftp.cwru.edu/pub/bash/$(READLINE).$(READLINE_SUFFIX)
READLINE_SOURCE		= $(SRCDIR)/$(READLINE).$(READLINE_SUFFIX)
READLINE_DIR		= $(BUILDDIR)/$(READLINE)
READLINE_IPKG_TMP	= $(READLINE_DIR)/ipkg_tmp

# ----------------------------------------------------------------------------
# Get
# ----------------------------------------------------------------------------

readline_get: $(STATEDIR)/readline.get

readline_get_deps = $(READLINE_SOURCE)

$(STATEDIR)/readline.get: $(readline_get_deps)
	@$(call targetinfo, $@)
	@$(call get_patches, $(READLINE))
	touch $@

$(READLINE_SOURCE):
	@$(call targetinfo, $@)
	@$(call get, $(READLINE_URL))

# ----------------------------------------------------------------------------
# Extract
# ----------------------------------------------------------------------------

readline_extract: $(STATEDIR)/readline.extract

readline_extract_deps = $(STATEDIR)/readline.get

$(STATEDIR)/readline.extract: $(readline_extract_deps)
	@$(call targetinfo, $@)
	@$(call clean, $(READLINE_DIR))
	@$(call extract, $(READLINE_SOURCE))
	@$(call patchin, $(READLINE))
	touch $@

# ----------------------------------------------------------------------------
# Prepare
# ----------------------------------------------------------------------------

readline_prepare: $(STATEDIR)/readline.prepare

#
# dependencies
#
readline_prepare_deps = \
	$(STATEDIR)/readline.extract \
	$(STATEDIR)/virtual-xchain.install

READLINE_PATH	=  PATH=$(CROSS_PATH)
READLINE_ENV 	=  $(CROSS_ENV)
#READLINE_ENV	+=
READLINE_ENV	+= PKG_CONFIG_PATH=$(CROSS_LIB_DIR)/lib/pkgconfig:$(CROSS_LIB_DIR)/lib/pkgconfig
#ifdef PTXCONF_XFREE430
#READLINE_ENV	+= LDFLAGS=-Wl,-rpath-link,$(CROSS_LIB_DIR)/lib
#endif
READLINE_ENV	+=  bash_cv_have_mbstate_t=yes

#
# autoconf
#
READLINE_AUTOCONF = \
	--build=$(GNU_HOST) \
	--host=$(PTXCONF_GNU_TARGET) \
	--prefix=/usr \
	--disable-static \
	--enable-shared

ifdef PTXCONF_XFREE430
READLINE_AUTOCONF += --x-includes=$(CROSS_LIB_DIR)/include
READLINE_AUTOCONF += --x-libraries=$(CROSS_LIB_DIR)/lib
endif

$(STATEDIR)/readline.prepare: $(readline_prepare_deps)
	@$(call targetinfo, $@)
	@$(call clean, $(READLINE_DIR)/config.cache)
	cd $(READLINE_DIR) && \
		$(READLINE_PATH) $(READLINE_ENV) \
		./configure $(READLINE_AUTOCONF)
	touch $@

# ----------------------------------------------------------------------------
# Compile
# ----------------------------------------------------------------------------

readline_compile: $(STATEDIR)/readline.compile

readline_compile_deps = $(STATEDIR)/readline.prepare

$(STATEDIR)/readline.compile: $(readline_compile_deps)
	@$(call targetinfo, $@)
	$(READLINE_PATH) $(MAKE) -C $(READLINE_DIR)
	touch $@

# ----------------------------------------------------------------------------
# Install
# ----------------------------------------------------------------------------

readline_install: $(STATEDIR)/readline.install

$(STATEDIR)/readline.install: $(STATEDIR)/readline.compile
	@$(call targetinfo, $@)
	rm -rf $(READLINE_IPKG_TMP)
	$(READLINE_PATH) $(MAKE) -C $(READLINE_DIR) DESTDIR=$(READLINE_IPKG_TMP) install
	cp -a  $(READLINE_IPKG_TMP)/usr/include/* $(CROSS_LIB_DIR)/include
	cp -a  $(READLINE_IPKG_TMP)/usr/lib/*     $(CROSS_LIB_DIR)/lib
	ln -sf readline/readline.h $(CROSS_LIB_DIR)/include/readline.h
	touch $@

# ----------------------------------------------------------------------------
# Target-Install
# ----------------------------------------------------------------------------

readline_targetinstall: $(STATEDIR)/readline.targetinstall

readline_targetinstall_deps = $(STATEDIR)/readline.compile

$(STATEDIR)/readline.targetinstall: $(readline_targetinstall_deps)
	@$(call targetinfo, $@)
	rm -rf $(READLINE_IPKG_TMP)
	$(READLINE_PATH) $(MAKE) -C $(READLINE_DIR) DESTDIR=$(READLINE_IPKG_TMP) install
	rm -rf $(READLINE_IPKG_TMP)/usr/include
	rm -rf $(READLINE_IPKG_TMP)/usr/info
	rm -rf $(READLINE_IPKG_TMP)/usr/man
	$(CROSSSTRIP) $(READLINE_IPKG_TMP)/usr/lib/*.so.4.3
	mkdir -p $(READLINE_IPKG_TMP)/CONTROL
	echo "Package: readline" 			>$(READLINE_IPKG_TMP)/CONTROL/control
	echo "Priority: optional" 			>>$(READLINE_IPKG_TMP)/CONTROL/control
	echo "Section: Libraries" 			>>$(READLINE_IPKG_TMP)/CONTROL/control
	echo "Maintainer: Alexander Chukov <sash@pdaXrom.org>">>$(READLINE_IPKG_TMP)/CONTROL/control
	echo "Architecture: $(SHORT_TARGET)" 		>>$(READLINE_IPKG_TMP)/CONTROL/control
	echo "Version: $(READLINE_VERSION)" 		>>$(READLINE_IPKG_TMP)/CONTROL/control
	echo "Depends: " 				>>$(READLINE_IPKG_TMP)/CONTROL/control
	echo "Description: The GNU Readline library provides a set of functions for use by applications that allow users to edit command lines as they are typed in.">>$(READLINE_IPKG_TMP)/CONTROL/control
	cd $(FEEDDIR) && $(XMKIPKG) $(READLINE_IPKG_TMP)
	touch $@

# ----------------------------------------------------------------------------
# Image-Install
# ----------------------------------------------------------------------------

ifdef PTXCONF_READLINE_INSTALL
ROMPACKAGES += $(STATEDIR)/readline.imageinstall
endif

readline_imageinstall_deps = $(STATEDIR)/readline.targetinstall \
	$(STATEDIR)/virtual-image.install

$(STATEDIR)/readline.imageinstall: $(readline_imageinstall_deps)
	@$(call targetinfo, $@)
	cd $(FEEDDIR) && $(XIPKG) install readline
	touch $@

# ----------------------------------------------------------------------------
# Clean
# ----------------------------------------------------------------------------

readline_clean:
	rm -rf $(STATEDIR)/readline.*
	rm -rf $(READLINE_DIR)

# vim: syntax=make
