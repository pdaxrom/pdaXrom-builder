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
ifdef PTXCONF_GROFF
PACKAGES += groff
endif

#
# Paths and names
#
GROFF_VERSION		= 1.19.1
GROFF			= groff-$(GROFF_VERSION)
GROFF_SUFFIX		= tar.gz
GROFF_URL		= ftp://ftp.gnu.org/gnu/groff/$(GROFF).$(GROFF_SUFFIX)
GROFF_SOURCE		= $(SRCDIR)/$(GROFF).$(GROFF_SUFFIX)
GROFF_DIR		= $(BUILDDIR)/$(GROFF)
GROFF_IPKG_TMP		= $(GROFF_DIR)/ipkg_tmp

# ----------------------------------------------------------------------------
# Get
# ----------------------------------------------------------------------------

groff_get: $(STATEDIR)/groff.get

groff_get_deps = $(GROFF_SOURCE)

$(STATEDIR)/groff.get: $(groff_get_deps)
	@$(call targetinfo, $@)
	@$(call get_patches, $(GROFF))
	touch $@

$(GROFF_SOURCE):
	@$(call targetinfo, $@)
	@$(call get, $(GROFF_URL))

# ----------------------------------------------------------------------------
# Extract
# ----------------------------------------------------------------------------

groff_extract: $(STATEDIR)/groff.extract

groff_extract_deps = $(STATEDIR)/groff.get

$(STATEDIR)/groff.extract: $(groff_extract_deps)
	@$(call targetinfo, $@)
	@$(call clean, $(GROFF_DIR))
	@$(call extract, $(GROFF_SOURCE))
	@$(call patchin, $(GROFF))
	touch $@

# ----------------------------------------------------------------------------
# Prepare
# ----------------------------------------------------------------------------

groff_prepare: $(STATEDIR)/groff.prepare

#
# dependencies
#
groff_prepare_deps = \
	$(STATEDIR)/groff.extract \
	$(STATEDIR)/virtual-xchain.install

GROFF_PATH	=  PATH=$(CROSS_PATH)
GROFF_ENV 	=  $(CROSS_ENV)
#GROFF_ENV	+=
GROFF_ENV	+= PKG_CONFIG_PATH=$(CROSS_LIB_DIR)/lib/pkgconfig:$(CROSS_LIB_DIR)/lib/pkgconfig
#ifdef PTXCONF_XFREE430
#GROFF_ENV	+= LDFLAGS=-Wl,-rpath-link,$(CROSS_LIB_DIR)/lib
#endif

#
# autoconf
#
GROFF_AUTOCONF = \
	--build=$(GNU_HOST) \
	--host=$(PTXCONF_GNU_TARGET) \
	--prefix=/usr

ifdef PTXCONF_XFREE430
GROFF_AUTOCONF += --x-includes=$(CROSS_LIB_DIR)/include
GROFF_AUTOCONF += --x-libraries=$(CROSS_LIB_DIR)/lib
endif

$(STATEDIR)/groff.prepare: $(groff_prepare_deps)
	@$(call targetinfo, $@)
	@$(call clean, $(GROFF_DIR)/config.cache)
	cd $(GROFF_DIR) && \
		$(GROFF_PATH) $(GROFF_ENV) \
		./configure $(GROFF_AUTOCONF)
	touch $@

# ----------------------------------------------------------------------------
# Compile
# ----------------------------------------------------------------------------

groff_compile: $(STATEDIR)/groff.compile

groff_compile_deps = $(STATEDIR)/groff.prepare

$(STATEDIR)/groff.compile: $(groff_compile_deps)
	@$(call targetinfo, $@)
	$(GROFF_PATH) $(MAKE) -C $(GROFF_DIR)
	touch $@

# ----------------------------------------------------------------------------
# Install
# ----------------------------------------------------------------------------

groff_install: $(STATEDIR)/groff.install

$(STATEDIR)/groff.install: $(STATEDIR)/groff.compile
	@$(call targetinfo, $@)
	$(GROFF_PATH) $(MAKE) -C $(GROFF_DIR) install
	touch $@

# ----------------------------------------------------------------------------
# Target-Install
# ----------------------------------------------------------------------------

groff_targetinstall: $(STATEDIR)/groff.targetinstall

groff_targetinstall_deps = $(STATEDIR)/groff.compile

$(STATEDIR)/groff.targetinstall: $(groff_targetinstall_deps)
	@$(call targetinfo, $@)
	mkdir -p $(GROFF_IPKG_TMP)/usr/bin
	$(GROFF_PATH) $(MAKE) -C $(GROFF_DIR) prefix=$(GROFF_IPKG_TMP)/usr install GROFF_HOST=true
	rm -rf $(GROFF_IPKG_TMP)/usr/info
	rm -rf $(GROFF_IPKG_TMP)/usr/man
	rm -rf $(GROFF_IPKG_TMP)/usr/share/doc
	for FILE in `find $(GROFF_IPKG_TMP)/usr/ -type f`; do		\
	    ZZZ=`file $$FILE | grep 'ELF 32-bit'`;			\
	    if [  "$$ZZZ" != "" ]; then					\
		$(CROSSSTRIP) $$FILE;					\
	    fi;								\
	done
	mkdir -p $(GROFF_IPKG_TMP)/CONTROL
	echo "Package: groff" 								>$(GROFF_IPKG_TMP)/CONTROL/control
	echo "Priority: optional" 							>>$(GROFF_IPKG_TMP)/CONTROL/control
	echo "Section: Utilities" 							>>$(GROFF_IPKG_TMP)/CONTROL/control
	echo "Maintainer: Alexander Chukov <sash@pdaXrom.org>" 				>>$(GROFF_IPKG_TMP)/CONTROL/control
	echo "Architecture: $(SHORT_TARGET)" 						>>$(GROFF_IPKG_TMP)/CONTROL/control
	echo "Version: $(GROFF_VERSION)" 						>>$(GROFF_IPKG_TMP)/CONTROL/control
	echo "Depends: " 								>>$(GROFF_IPKG_TMP)/CONTROL/control
	echo "Description: THE groff (GNU Troff) software is a typesetting package which reads plain text mixed with formatting commands and produces formatted output." >>$(GROFF_IPKG_TMP)/CONTROL/control
	cd $(FEEDDIR) && $(XMKIPKG) $(GROFF_IPKG_TMP)
	touch $@

# ----------------------------------------------------------------------------
# Image-Install
# ----------------------------------------------------------------------------

ifdef PTXCONF_GROFF_INSTALL
ROMPACKAGES += $(STATEDIR)/groff.imageinstall
endif

groff_imageinstall_deps = $(STATEDIR)/groff.targetinstall \
	$(STATEDIR)/virtual-image.install

$(STATEDIR)/groff.imageinstall: $(groff_imageinstall_deps)
	@$(call targetinfo, $@)
	cd $(FEEDDIR) && $(XIPKG) install groff
	touch $@

# ----------------------------------------------------------------------------
# Clean
# ----------------------------------------------------------------------------

groff_clean:
	rm -rf $(STATEDIR)/groff.*
	rm -rf $(GROFF_DIR)

# vim: syntax=make
