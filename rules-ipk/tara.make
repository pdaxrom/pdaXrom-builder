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
ifdef PTXCONF_TARA
PACKAGES += tar
endif

#
# Paths and names
#
TARA_VERSION		= 1.13.25
TARA			= tar-$(TARA_VERSION)
TARA_SUFFIX		= tar.gz
TARA_URL		= http://http.us.debian.org/debian/pool/main/t/tar/tar_1.13.25.orig.$(TARA_SUFFIX)
TARA_SOURCE		= $(SRCDIR)/tar_1.13.25.orig.$(TARA_SUFFIX)
TARA_DIR		= $(BUILDDIR)/$(TARA)

# ----------------------------------------------------------------------------
# Get
# ----------------------------------------------------------------------------

tar_get: $(STATEDIR)/tar.get

tar_get_deps = $(TARA_SOURCE)

$(STATEDIR)/tar.get: $(tar_get_deps)
	@$(call targetinfo, $@)
	@$(call get_patches, $(TARA))
	touch $@

$(TARA_SOURCE):
	@$(call targetinfo, $@)
	@$(call get, $(TARA_URL))

# ----------------------------------------------------------------------------
# Extract
# ----------------------------------------------------------------------------

tar_extract: $(STATEDIR)/tar.extract

tar_extract_deps = $(STATEDIR)/tar.get

$(STATEDIR)/tar.extract: $(tar_extract_deps)
	@$(call targetinfo, $@)
	@$(call clean, $(TARA_DIR))
	@$(call extract, $(TARA_SOURCE))
	@$(call patchin, $(TARA))
	touch $@

# ----------------------------------------------------------------------------
# Prepare
# ----------------------------------------------------------------------------

tar_prepare: $(STATEDIR)/tar.prepare

#
# dependencies
#
tar_prepare_deps = \
	$(STATEDIR)/tar.extract \
	$(STATEDIR)/virtual-xchain.install

ifdef PTXCONF_LIBICONV
tar_prepare_deps += $(STATEDIR)/libiconv.install
endif

TARA_PATH	=  PATH=$(CROSS_PATH)
TARA_ENV 	=  $(CROSS_ENV)
#TARA_ENV	+=

#
# autoconf
#
TARA_AUTOCONF = \
	--build=$(GNU_HOST) \
	--host=$(PTXCONF_GNU_TARGET) \
	--prefix=$(CROSS_LIB_DIR)

ifdef PTXCONF_LIBICONV
TARA_AUTOCONF += --with-libiconv-prefix=$(CROSS_LIB_DIR)
TARA_ENV += LDFLAGS=" -liconv"
else
TARA_ENV	+= am_cv_func_iconv=no
endif

$(STATEDIR)/tar.prepare: $(tar_prepare_deps)
	@$(call targetinfo, $@)
	@$(call clean, $(TARA_DIR)/config.cache)
	cd $(TARA_DIR) && \
		$(TARA_PATH) $(TARA_ENV) \
		./configure $(TARA_AUTOCONF)
	touch $@

# ----------------------------------------------------------------------------
# Compile
# ----------------------------------------------------------------------------

tar_compile: $(STATEDIR)/tar.compile

tar_compile_deps = $(STATEDIR)/tar.prepare

$(STATEDIR)/tar.compile: $(tar_compile_deps)
	@$(call targetinfo, $@)
	$(TARA_PATH) $(MAKE) -C $(TARA_DIR)
	touch $@

# ----------------------------------------------------------------------------
# Install
# ----------------------------------------------------------------------------

tar_install: $(STATEDIR)/tar.install

$(STATEDIR)/tar.install: $(STATEDIR)/tar.compile
	@$(call targetinfo, $@)
	touch $@

# ----------------------------------------------------------------------------
# Target-Install
# ----------------------------------------------------------------------------

tar_targetinstall: $(STATEDIR)/tar.targetinstall

tar_targetinstall_deps = $(STATEDIR)/tar.compile

ifdef PTXCONF_LIBICONV
tar_targetinstall_deps += $(STATEDIR)/libiconv.targetinstall
endif

$(STATEDIR)/tar.targetinstall: $(tar_targetinstall_deps)
	@$(call targetinfo, $@)
	install -D -m 755 $(TARA_DIR)/src/tar	$(TARA_DIR)/ipk/bin/tar
	$(CROSSSTRIP) -R .note -R .comment	$(TARA_DIR)/ipk/bin/tar
	mkdir -p $(TARA_DIR)/ipk/CONTROL
	echo "Package: tar" 						 >$(TARA_DIR)/ipk/CONTROL/control
	echo "Priority: optional" 					>>$(TARA_DIR)/ipk/CONTROL/control
	echo "Section: Utilities" 					>>$(TARA_DIR)/ipk/CONTROL/control
	echo "Maintainer: Alexander Chukov <sash@pdaXrom.org>" 		>>$(TARA_DIR)/ipk/CONTROL/control
	echo "Architecture: $(SHORT_TARGET)" 				>>$(TARA_DIR)/ipk/CONTROL/control
	echo "Version: $(TARA_VERSION)" 				>>$(TARA_DIR)/ipk/CONTROL/control
ifdef PTXCONF_LIBICONV
	echo "Depends: libiconv"	 				>>$(TARA_DIR)/ipk/CONTROL/control
else
	echo "Depends: "		 				>>$(TARA_DIR)/ipk/CONTROL/control
endif
	echo "Description: generated with pdaXrom builder"		>>$(TARA_DIR)/ipk/CONTROL/control
	cd $(FEEDDIR) && $(XMKIPKG) $(TARA_DIR)/ipk
	touch $@

# ----------------------------------------------------------------------------
# Image-Install
# ----------------------------------------------------------------------------

ifdef PTXCONF_TARA_INSTALL
ROMPACKAGES += $(STATEDIR)/tar.imageinstall
endif

tar_imageinstall_deps = $(STATEDIR)/tar.targetinstall \
	$(STATEDIR)/virtual-image.install

$(STATEDIR)/tar.imageinstall: $(tar_imageinstall_deps)
	@$(call targetinfo, $@)
	cd $(FEEDDIR) && $(XIPKG) install tar
	touch $@

# ----------------------------------------------------------------------------
# Clean
# ----------------------------------------------------------------------------

tar_clean:
	rm -rf $(STATEDIR)/tar.*
	rm -rf $(TARA_DIR)

# vim: syntax=make
