# -*-makefile-*-
# $Id: template,v 1.10 2003/10/26 21:59:07 mkl Exp $
#
# Copyright (C) 2003 by Alexander Chukov <sash@cacko.biz>
#          
# See CREDITS for details about who has contributed to this project.
#
# For further information about the PTXdist project and license conditions
# see the README file.
#

#
# We provide this package
#
ifdef PTXCONF_MODUTILS
PACKAGES += modutils
endif

#
# Paths and names
#
MODUTILS_VERSION	= 2.4.26
MODUTILS		= modutils-$(MODUTILS_VERSION)
MODUTILS_SUFFIX		= tar.bz2
MODUTILS_URL		= http://ftp.kernel.org/pub/linux/utils/kernel/modutils/v2.4/$(MODUTILS).$(MODUTILS_SUFFIX)
MODUTILS_SOURCE		= $(SRCDIR)/$(MODUTILS).$(MODUTILS_SUFFIX)
MODUTILS_DIR		= $(BUILDDIR)/$(MODUTILS)

# ----------------------------------------------------------------------------
# Get
# ----------------------------------------------------------------------------

modutils_get: $(STATEDIR)/modutils.get

modutils_get_deps = $(MODUTILS_SOURCE)

$(STATEDIR)/modutils.get: $(modutils_get_deps)
	@$(call targetinfo, $@)
	touch $@

$(MODUTILS_SOURCE):
	@$(call targetinfo, $@)
	@$(call get, $(MODUTILS_URL))

# ----------------------------------------------------------------------------
# Extract
# ----------------------------------------------------------------------------

modutils_extract: $(STATEDIR)/modutils.extract

modutils_extract_deps = $(STATEDIR)/modutils.get

$(STATEDIR)/modutils.extract: $(modutils_extract_deps)
	@$(call targetinfo, $@)
	@$(call clean, $(MODUTILS_DIR))
	@$(call extract, $(MODUTILS_SOURCE))
	touch $@

# ----------------------------------------------------------------------------
# Prepare
# ----------------------------------------------------------------------------

modutils_prepare: $(STATEDIR)/modutils.prepare

#
# dependencies
#
modutils_prepare_deps = \
	$(STATEDIR)/modutils.extract \
	$(STATEDIR)/virtual-xchain.install

MODUTILS_PATH	=  PATH=$(CROSS_PATH)
MODUTILS_ENV 	=  $(CROSS_ENV)
#MODUTILS_ENV	+=

#
# autoconf
#
MODUTILS_AUTOCONF = \
	--build=$(GNU_HOST) \
	--host=$(PTXCONF_GNU_TARGET) \
	--prefix=$(CROSS_LIB_DIR)

$(STATEDIR)/modutils.prepare: $(modutils_prepare_deps)
	@$(call targetinfo, $@)
	@$(call clean, $(MODUTILS_DIR)/config.cache)
	cd $(MODUTILS_DIR) && \
		$(MODUTILS_PATH) $(MODUTILS_ENV) \
		./configure $(MODUTILS_AUTOCONF)
	touch $@

# ----------------------------------------------------------------------------
# Compile
# ----------------------------------------------------------------------------

modutils_compile: $(STATEDIR)/modutils.compile

modutils_compile_deps = $(STATEDIR)/modutils.prepare

$(STATEDIR)/modutils.compile: $(modutils_compile_deps)
	@$(call targetinfo, $@)
	$(MODUTILS_PATH) $(MAKE) -C $(MODUTILS_DIR) BUILDCC=gcc
	touch $@

# ----------------------------------------------------------------------------
# Install
# ----------------------------------------------------------------------------

modutils_install: $(STATEDIR)/modutils.install

$(STATEDIR)/modutils.install: $(STATEDIR)/modutils.compile
	@$(call targetinfo, $@)
	touch $@

# ----------------------------------------------------------------------------
# Target-Install
# ----------------------------------------------------------------------------

modutils_targetinstall: $(STATEDIR)/modutils.targetinstall

modutils_targetinstall_deps = $(STATEDIR)/modutils.compile

$(STATEDIR)/modutils.targetinstall: $(modutils_targetinstall_deps)
	@$(call targetinfo, $@)
	install -D $(MODUTILS_DIR)/genksyms/genksyms $(MODUTILS_DIR)/ipkg/sbin/genksyms
	$(CROSSSTRIP) -R .note -R .comment $(MODUTILS_DIR)/ipkg/sbin/genksyms
	###install -D $(MODUTILS_DIR)/genksyms/makecrc32 $(MODUTILS_DIR)/ipkg/sbin/makecrc32
	###$(CROSSSTRIP) -R .note -R .comment $(MODUTILS_DIR)/ipkg/sbin/makecrc32
	install -D $(MODUTILS_DIR)/depmod/depmod $(MODUTILS_DIR)/ipkg/sbin/depmod
	$(CROSSSTRIP) -R .note -R .comment $(MODUTILS_DIR)/ipkg/sbin/depmod
	install -D $(MODUTILS_DIR)/insmod/insmod $(MODUTILS_DIR)/ipkg/sbin/insmod
	$(CROSSSTRIP) -R .note -R .comment $(MODUTILS_DIR)/ipkg/sbin/insmod
	install -D $(MODUTILS_DIR)/insmod/modinfo $(MODUTILS_DIR)/ipkg/sbin/modinfo
	$(CROSSSTRIP) -R .note -R .comment $(MODUTILS_DIR)/ipkg/sbin/modinfo
	install -D $(MODUTILS_DIR)/insmod/insmod_ksymoops_clean $(MODUTILS_DIR)/ipkg/sbin/insmod_ksymoops_clean
	install -D $(MODUTILS_DIR)/insmod/kernelversion $(MODUTILS_DIR)/ipkg/sbin/kernelversion
	cd $(MODUTILS_DIR)/ipkg/sbin && ln -sf insmod kallsyms
	cd $(MODUTILS_DIR)/ipkg/sbin && ln -sf insmod ksyms
	cd $(MODUTILS_DIR)/ipkg/sbin && ln -sf insmod lsmod
	cd $(MODUTILS_DIR)/ipkg/sbin && ln -sf insmod modprobe
	cd $(MODUTILS_DIR)/ipkg/sbin && ln -sf insmod rmmod
	mkdir -p $(MODUTILS_DIR)/ipkg/CONTROL
	echo "Package: modutils" 						 >$(MODUTILS_DIR)/ipkg/CONTROL/control
	echo "Priority: optional" 						>>$(MODUTILS_DIR)/ipkg/CONTROL/control
	echo "Section: Utilities" 						>>$(MODUTILS_DIR)/ipkg/CONTROL/control
	echo "Maintainer: Alexander Chukov <sash@pdaXrom.org>" 			>>$(MODUTILS_DIR)/ipkg/CONTROL/control
	echo "Architecture: $(SHORT_TARGET)" 					>>$(MODUTILS_DIR)/ipkg/CONTROL/control
	echo "Version: $(MODUTILS_VERSION)" 					>>$(MODUTILS_DIR)/ipkg/CONTROL/control
	echo "Depends: " 							>>$(MODUTILS_DIR)/ipkg/CONTROL/control
	echo "Description: These utilities are intended to make a Linux modular kernel manageable for all users, administrators and distribution maintainers.">>$(MODUTILS_DIR)/ipkg/CONTROL/control
	cd $(FEEDDIR) && $(XMKIPKG) $(MODUTILS_DIR)/ipkg
	touch $@

# ----------------------------------------------------------------------------
# Image-Install
# ----------------------------------------------------------------------------

ifdef PTXCONF_MODUTILS_INSTALL
ROMPACKAGES += $(STATEDIR)/modutils.imageinstall
endif

modutils_imageinstall_deps = $(STATEDIR)/modutils.targetinstall \
	$(STATEDIR)/virtual-image.install

$(STATEDIR)/modutils.imageinstall: $(modutils_imageinstall_deps)
	@$(call targetinfo, $@)
	cd $(FEEDDIR) && $(XIPKG) install modutils
	touch $@

# ----------------------------------------------------------------------------
# Clean
# ----------------------------------------------------------------------------

modutils_clean:
	rm -rf $(STATEDIR)/modutils.*
	rm -rf $(MODUTILS_DIR)

# vim: syntax=make
