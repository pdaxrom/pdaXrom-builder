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
ifdef PTXCONF_APMD
PACKAGES += xchain-libtool apmd
endif

#
# Paths and names
#
APMD_VERSION		= 3.2.1.orig
APMD			= apmd-$(APMD_VERSION)
APMD_SUFFIX		= tar.gz
APMD_URL		= http://http.us.debian.org/debian/pool/main/a/apmd/apmd_$(APMD_VERSION).$(APMD_SUFFIX)
APMD_SOURCE		= $(SRCDIR)/apmd_$(APMD_VERSION).$(APMD_SUFFIX)
APMD_DIR		= $(BUILDDIR)/$(APMD)

# ----------------------------------------------------------------------------
# Get
# ----------------------------------------------------------------------------

apmd_get: $(STATEDIR)/apmd.get

apmd_get_deps = $(APMD_SOURCE)

$(STATEDIR)/apmd.get: $(apmd_get_deps)
	@$(call targetinfo, $@)
	@$(call get_patches, $(APMD))
	touch $@

$(APMD_SOURCE):
	@$(call targetinfo, $@)
	@$(call get, $(APMD_URL))

# ----------------------------------------------------------------------------
# Extract
# ----------------------------------------------------------------------------

apmd_extract: $(STATEDIR)/apmd.extract

apmd_extract_deps = $(STATEDIR)/apmd.get

$(STATEDIR)/apmd.extract: $(apmd_extract_deps)
	@$(call targetinfo, $@)
	@$(call clean, $(APMD_DIR))
	@$(call extract, $(APMD_SOURCE))
	@$(call patchin, $(APMD))
	touch $@

# ----------------------------------------------------------------------------
# Prepare
# ----------------------------------------------------------------------------

apmd_prepare: $(STATEDIR)/apmd.prepare

#
# dependencies
#
apmd_prepare_deps = \
	$(STATEDIR)/apmd.extract \
	$(STATEDIR)/virtual-xchain.install

APMD_PATH	=  PATH=$(CROSS_PATH)
APMD_ENV 	=  $(CROSS_ENV)
#APMD_ENV	+=

#
# autoconf
#
APMD_AUTOCONF = \
	--build=$(GNU_HOST) \
	--host=$(PTXCONF_GNU_TARGET) \
	--prefix=$(CROSS_LIB_DIR)

$(STATEDIR)/apmd.prepare: $(apmd_prepare_deps)
	@$(call targetinfo, $@)
	@$(call clean, $(APMD_DIR)/config.cache)
	#cd $(APMD_DIR) && \
	#	$(APMD_PATH) $(APMD_ENV) \
	#	./configure $(APMD_AUTOCONF)
	touch $@

# ----------------------------------------------------------------------------
# Compile
# ----------------------------------------------------------------------------

apmd_compile: $(STATEDIR)/apmd.compile

apmd_compile_deps = $(STATEDIR)/apmd.prepare

$(STATEDIR)/apmd.compile: $(apmd_compile_deps)
	@$(call targetinfo, $@)
	#$(APMD_PATH) $(APMD_ENV) $(MAKE) -C $(APMD_DIR) libapm
#ifdef PTXCONF_APMD_APM
	$(APMD_PATH) $(APMD_ENV) $(MAKE) -C $(APMD_DIR) \
	    CFLAGS="$(TARGET_OPT_CFLAGS)" \
	    LIBTOOL="libtool --quiet --tag=CC" \
	    apm
#endif
#ifdef PTXCONF_APMD_APMD
#	$(APMD_PATH) $(APMD_ENV) $(MAKE) -C $(APMD_DIR) CFLAGS="$(TARGET_OPT_CFLAGS)" apmd
#endif
	touch $@

# ----------------------------------------------------------------------------
# Install
# ----------------------------------------------------------------------------

apmd_install: $(STATEDIR)/apmd.install

$(STATEDIR)/apmd.install: $(STATEDIR)/apmd.compile
	@$(call targetinfo, $@)
	$(INSTALL) -m 644 $(APMD_DIR)/apm.h 			$(CROSS_LIB_DIR)/include
	$(INSTALL) -m 755 $(APMD_DIR)/.libs/libapm.so.1.0.0 	$(CROSS_LIB_DIR)/lib
	ln -sf libapm.so.1.0.0 $(CROSS_LIB_DIR)/lib/libapm.so.1
	ln -sf libapm.so.1.0.0 $(CROSS_LIB_DIR)/lib/libapm.so
	touch $@

# ----------------------------------------------------------------------------
# Target-Install
# ----------------------------------------------------------------------------

apmd_targetinstall: $(STATEDIR)/apmd.targetinstall

apmd_targetinstall_deps = $(STATEDIR)/apmd.compile

$(STATEDIR)/apmd.targetinstall: $(apmd_targetinstall_deps)
	@$(call targetinfo, $@)
	rm -rf $(APMD_DIR)/ipk
	$(INSTALL) -D -m 755 $(APMD_DIR)/.libs/libapm.so.1.0.0 	$(APMD_DIR)/ipk/usr/lib/libapm.so.1.0.0
	$(CROSSSTRIP) -R .note -R .comment 			$(APMD_DIR)/ipk/usr/lib/libapm.so.1.0.0
	ln -sf libapm.so.1.0.0 					$(APMD_DIR)/ipk/usr/lib/libapm.so.1
	$(INSTALL) -D -m 755 $(APMD_DIR)/.libs/apm 		$(APMD_DIR)/ipk/usr/bin/apm
	$(CROSSSTRIP) -R .note -R .comment 			$(APMD_DIR)/ipk/usr/bin/apm
ifdef PTXCONF_APMD_APM_PCMCIA_FIX
	if [ ! -f $(APMD_DIR)/ipk/usr/bin/apm.x ]; then						\
	    mv $(APMD_DIR)/ipk/usr/bin/apm $(APMD_DIR)/ipk/usr/bin/apm.x		;	\
	    $(INSTALL) -m 755 $(TOPDIR)/config/pdaXrom/apm $(APMD_DIR)/ipk/usr/bin	;	\
	fi
endif
	mkdir -p $(APMD_DIR)/ipk/CONTROL
	echo "Package: apm" 						 >$(APMD_DIR)/ipk/CONTROL/control
	echo "Priority: optional" 					>>$(APMD_DIR)/ipk/CONTROL/control
	echo "Section: Utilities"	 				>>$(APMD_DIR)/ipk/CONTROL/control
	echo "Maintainer: Alexander Chukov <sash@pdaXrom.org>"		>>$(APMD_DIR)/ipk/CONTROL/control
	echo "Architecture: $(SHORT_TARGET)" 				>>$(APMD_DIR)/ipk/CONTROL/control
	echo "Version: $(APMD_VERSION)" 				>>$(APMD_DIR)/ipk/CONTROL/control
	echo "Depends: "			 			>>$(APMD_DIR)/ipk/CONTROL/control
	echo "Description: Query APM BIOS."				>>$(APMD_DIR)/ipk/CONTROL/control
	cd $(FEEDDIR) && $(XMKIPKG) $(APMD_DIR)/ipk

#	rm -rf $(APMD_DIR)/ipk
#	$(INSTALL) -D -m 755 $(APMD_DIR)/.libs/apmd 	$(APMD_DIR)/ipk/usr/bin/apmd
#	$(CROSSSTRIP) -R .note -R .comment 		$(APMD_DIR)/ipk/usr/bin/apmd
#	mkdir -p $(APMD_DIR)/ipk/CONTROL
#	echo "Package: apmd" 						 >$(APMD_DIR)/ipk/CONTROL/control
#	echo "Priority: optional" 					>>$(APMD_DIR)/ipk/CONTROL/control
#	echo "Section: Utilities"	 				>>$(APMD_DIR)/ipk/CONTROL/control
#	echo "Maintainer: Alexander Chukov <sash@pdaXrom.org>"		>>$(APMD_DIR)/ipk/CONTROL/control
#	echo "Architecture: $(SHORT_TARGET)" 				>>$(APMD_DIR)/ipk/CONTROL/control
#	echo "Version: $(APMD_VERSION)" 				>>$(APMD_DIR)/ipk/CONTROL/control
#	echo "Depends: apm"			 			>>$(APMD_DIR)/ipk/CONTROL/control
#	echo "Description: APM daemon."					>>$(APMD_DIR)/ipk/CONTROL/control
#	cd $(FEEDDIR) && $(XMKIPKG) $(APMD_DIR)/ipk
	touch $@

# ----------------------------------------------------------------------------
# Image-Install
# ----------------------------------------------------------------------------

ifdef PTXCONF_APMD_APM_INSTALL
ROMPACKAGES += $(STATEDIR)/apmd_apm.imageinstall
endif

apmd_apm_imageinstall_deps = $(STATEDIR)/apmd.targetinstall \
	$(STATEDIR)/virtual-image.install

$(STATEDIR)/apmd_apm.imageinstall: $(apmd_apm_imageinstall_deps)
	@$(call targetinfo, $@)
	cd $(FEEDDIR) && $(XIPKG) install apm
	touch $@

ifdef PTXCONF_APMD_APMD_INSTALL
ROMPACKAGES += $(STATEDIR)/apmd.imageinstall
endif

apmd_imageinstall_deps = $(STATEDIR)/apmd.targetinstall \
	$(STATEDIR)/virtual-image.install

$(STATEDIR)/apmd.imageinstall: $(apmd_imageinstall_deps)
	@$(call targetinfo, $@)
	cd $(FEEDDIR) && $(XIPKG) install apmd
	touch $@

# ----------------------------------------------------------------------------
# Clean
# ----------------------------------------------------------------------------

apmd_clean:
	rm -rf $(STATEDIR)/apmd.*
	rm -rf $(APMD_DIR)

# vim: syntax=make
