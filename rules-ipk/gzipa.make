# -*-makefile-*-
# $Id: template,v 1.10 2004/01/24 15:50:34 mkl Exp $
#
# Copyright (C) 2004 by Alexander Chukov <sash@cacko.biz>
#          
# See CREDITS for details about who has contributed to this project.
#
# For further information about the PTXdist project and license conditions
# see the README file.
#

#
# We provide this package
#
ifdef PTXCONF_GZIPA
PACKAGES += gzip
endif

#
# Paths and names
#
GZIPA_VERSION		= 1.3.5.orig
GZIPA			= gzip-1.3.5
GZIPA_SUFFIX		= tar.gz
GZIPA_URL		= http://http.us.debian.org/debian/pool/main/g/gzip/gzip_$(GZIPA_VERSION).$(GZIPA_SUFFIX)
GZIPA_SOURCE		= $(SRCDIR)/gzip_$(GZIPA_VERSION).$(GZIPA_SUFFIX)
GZIPA_DIR		= $(BUILDDIR)/$(GZIPA)

# ----------------------------------------------------------------------------
# Get
# ----------------------------------------------------------------------------

gzip_get: $(STATEDIR)/gzip.get

gzip_get_deps = $(GZIPA_SOURCE)

$(STATEDIR)/gzip.get: $(gzip_get_deps)
	@$(call targetinfo, $@)
	@$(call get_patches, $(GZIPA))
	touch $@

$(GZIPA_SOURCE):
	@$(call targetinfo, $@)
	@$(call get, $(GZIPA_URL))

# ----------------------------------------------------------------------------
# Extract
# ----------------------------------------------------------------------------

gzip_extract: $(STATEDIR)/gzip.extract

gzip_extract_deps = $(STATEDIR)/gzip.get

$(STATEDIR)/gzip.extract: $(gzip_extract_deps)
	@$(call targetinfo, $@)
	@$(call clean, $(GZIPA_DIR))
	@$(call extract, $(GZIPA_SOURCE))
	@$(call patchin, $(GZIPA))
	touch $@

# ----------------------------------------------------------------------------
# Prepare
# ----------------------------------------------------------------------------

gzip_prepare: $(STATEDIR)/gzip.prepare

#
# dependencies
#
gzip_prepare_deps = \
	$(STATEDIR)/gzip.extract \
	$(STATEDIR)/virtual-xchain.install

GZIPA_PATH	=  PATH=$(CROSS_PATH)
GZIPA_ENV 	=  $(CROSS_ENV)
#GZIPA_ENV	+=

#
# autoconf
#
GZIPA_AUTOCONF = \
	--build=$(GNU_HOST) \
	--host=$(PTXCONF_GNU_TARGET) \
	--prefix=$(CROSS_LIB_DIR)

$(STATEDIR)/gzip.prepare: $(gzip_prepare_deps)
	@$(call targetinfo, $@)
	@$(call clean, $(GZIPA_DIR)/config.cache)
	cd $(GZIPA_DIR) && \
		$(GZIPA_PATH) $(GZIPA_ENV) \
		./configure $(GZIPA_AUTOCONF)
	touch $@

# ----------------------------------------------------------------------------
# Compile
# ----------------------------------------------------------------------------

gzip_compile: $(STATEDIR)/gzip.compile

gzip_compile_deps = $(STATEDIR)/gzip.prepare

$(STATEDIR)/gzip.compile: $(gzip_compile_deps)
	@$(call targetinfo, $@)
	$(GZIPA_PATH) $(MAKE) -C $(GZIPA_DIR)
	touch $@

# ----------------------------------------------------------------------------
# Install
# ----------------------------------------------------------------------------

gzip_install: $(STATEDIR)/gzip.install

$(STATEDIR)/gzip.install: $(STATEDIR)/gzip.compile
	@$(call targetinfo, $@)
	touch $@

# ----------------------------------------------------------------------------
# Target-Install
# ----------------------------------------------------------------------------

gzip_targetinstall: $(STATEDIR)/gzip.targetinstall

gzip_targetinstall_deps = $(STATEDIR)/gzip.compile

$(STATEDIR)/gzip.targetinstall: $(gzip_targetinstall_deps)
	@$(call targetinfo, $@)
	install -D -m 755 $(GZIPA_DIR)/gzip	$(GZIPA_DIR)/ipk/bin/gzip
	$(CROSSSTRIP) -R .note -R .comment	$(GZIPA_DIR)/ipk/bin/gzip
	ln -sf gzip 				$(GZIPA_DIR)/ipk/bin/zcat
	ln -sf gzip 				$(GZIPA_DIR)/ipk/bin/gunzip
	mkdir -p $(GZIPA_DIR)/ipk/CONTROL
	echo "Package: gzip"	 				 >$(GZIPA_DIR)/ipk/CONTROL/control
	echo "Priority: optional" 				>>$(GZIPA_DIR)/ipk/CONTROL/control
	echo "Section: Utilities"	 			>>$(GZIPA_DIR)/ipk/CONTROL/control
	echo "Maintainer: Alexander Chukov <sash@pdaXrom.org>" 	>>$(GZIPA_DIR)/ipk/CONTROL/control
	echo "Architecture: $(SHORT_TARGET)" 			>>$(GZIPA_DIR)/ipk/CONTROL/control
	echo "Version: $(GZIPA_VERSION)" 			>>$(GZIPA_DIR)/ipk/CONTROL/control
	echo "Depends: "		 			>>$(GZIPA_DIR)/ipk/CONTROL/control
	echo "Description: Compress utility."			>>$(GZIPA_DIR)/ipk/CONTROL/control
	cd $(FEEDDIR) && $(XMKIPKG) $(GZIPA_DIR)/ipk
	touch $@

# ----------------------------------------------------------------------------
# Image-Install
# ----------------------------------------------------------------------------

ifdef PTXCONF_GZIPA_INSTALL
ROMPACKAGES += $(STATEDIR)/gzip.imageinstall
endif

gzip_imageinstall_deps = $(STATEDIR)/gzip.targetinstall \
	$(STATEDIR)/virtual-image.install

$(STATEDIR)/gzip.imageinstall: $(gzip_imageinstall_deps)
	@$(call targetinfo, $@)
	cd $(FEEDDIR) && $(XIPKG) install gzip
	touch $@

# ----------------------------------------------------------------------------
# Clean
# ----------------------------------------------------------------------------

gzip_clean:
	rm -rf $(STATEDIR)/gzip.*
	rm -rf $(GZIPA_DIR)

# vim: syntax=make
