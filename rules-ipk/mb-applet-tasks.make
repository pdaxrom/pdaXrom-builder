# -*-makefile-*-
# $Id: template,v 1.10 2004/01/24 15:50:34 mkl Exp $
#
# Copyright (C) 2004 by Alexander Chukov <Sash@pdaXrom.org>
#          
# See CREDITS for details about who has contributed to this project.
#
# For further information about the PTXdist project and license conditions
# see the README file.
#

#
# We provide this package
#
ifdef PTXCONF_MB-APPLET-TASKS
PACKAGES += libmatchbox libwnck mb-applet-tasks
endif

#
# Paths and names
#
MB-APPLET-TASKS_VERSION		= 1.0.0
MB-APPLET-TASKS			= mb-applet-tasks-$(MB-APPLET-TASKS_VERSION)
MB-APPLET-TASKS_SUFFIX		= tar.bz2
MB-APPLET-TASKS_URL		= http://www.pdaXrom.org/src/$(MB-APPLET-TASKS).$(MB-APPLET-TASKS_SUFFIX)
MB-APPLET-TASKS_SOURCE		= $(SRCDIR)/$(MB-APPLET-TASKS).$(MB-APPLET-TASKS_SUFFIX)
MB-APPLET-TASKS_DIR		= $(BUILDDIR)/$(MB-APPLET-TASKS)
MB-APPLET-TASKS_IPKG_TMP	= $(MB-APPLET-TASKS_DIR)/ipkg_tmp

# ----------------------------------------------------------------------------
# Get
# ----------------------------------------------------------------------------

mb-applet-tasks_get: $(STATEDIR)/mb-applet-tasks.get

mb-applet-tasks_get_deps = $(MB-APPLET-TASKS_SOURCE)

$(STATEDIR)/mb-applet-tasks.get: $(mb-applet-tasks_get_deps)
	@$(call targetinfo, $@)
	@$(call get_patches, $(MB-APPLET-TASKS))
	touch $@

$(MB-APPLET-TASKS_SOURCE):
	@$(call targetinfo, $@)
	@$(call get, $(MB-APPLET-TASKS_URL))

# ----------------------------------------------------------------------------
# Extract
# ----------------------------------------------------------------------------

mb-applet-tasks_extract: $(STATEDIR)/mb-applet-tasks.extract

mb-applet-tasks_extract_deps = $(STATEDIR)/mb-applet-tasks.get

$(STATEDIR)/mb-applet-tasks.extract: $(mb-applet-tasks_extract_deps)
	@$(call targetinfo, $@)
	@$(call clean, $(MB-APPLET-TASKS_DIR))
	@$(call extract, $(MB-APPLET-TASKS_SOURCE))
	@$(call patchin, $(MB-APPLET-TASKS))
	touch $@

# ----------------------------------------------------------------------------
# Prepare
# ----------------------------------------------------------------------------

mb-applet-tasks_prepare: $(STATEDIR)/mb-applet-tasks.prepare

#
# dependencies
#
mb-applet-tasks_prepare_deps = \
	$(STATEDIR)/mb-applet-tasks.extract \
	$(STATEDIR)/virtual-xchain.install

MB-APPLET-TASKS_PATH	=  PATH=$(CROSS_PATH)
MB-APPLET-TASKS_ENV 	=  $(CROSS_ENV)
#MB-APPLET-TASKS_ENV	+=
MB-APPLET-TASKS_ENV	+= PKG_CONFIG_PATH=$(CROSS_LIB_DIR)/lib/pkgconfig:$(CROSS_LIB_DIR)/lib/pkgconfig
#ifdef PTXCONF_XFREE430
#MB-APPLET-TASKS_ENV	+= LDFLAGS=-Wl,-rpath-link,$(CROSS_LIB_DIR)/lib
#endif

#
# autoconf
#
MB-APPLET-TASKS_AUTOCONF = \
	--build=$(GNU_HOST) \
	--host=$(PTXCONF_GNU_TARGET) \
	--prefix=/usr

ifdef PTXCONF_XFREE430
MB-APPLET-TASKS_AUTOCONF += --x-includes=$(CROSS_LIB_DIR)/include
MB-APPLET-TASKS_AUTOCONF += --x-libraries=$(CROSS_LIB_DIR)/lib
endif

$(STATEDIR)/mb-applet-tasks.prepare: $(mb-applet-tasks_prepare_deps)
	@$(call targetinfo, $@)
	@$(call clean, $(MB-APPLET-TASKS_DIR)/config.cache)
	#cd $(MB-APPLET-TASKS_DIR) && \
	#	$(MB-APPLET-TASKS_PATH) $(MB-APPLET-TASKS_ENV) \
	#	./configure $(MB-APPLET-TASKS_AUTOCONF)
	touch $@

# ----------------------------------------------------------------------------
# Compile
# ----------------------------------------------------------------------------

mb-applet-tasks_compile: $(STATEDIR)/mb-applet-tasks.compile

mb-applet-tasks_compile_deps = $(STATEDIR)/mb-applet-tasks.prepare

$(STATEDIR)/mb-applet-tasks.compile: $(mb-applet-tasks_compile_deps)
	@$(call targetinfo, $@)
	$(MB-APPLET-TASKS_PATH) $(MB-APPLET-TASKS_ENV) $(MAKE) -C $(MB-APPLET-TASKS_DIR)
	touch $@

# ----------------------------------------------------------------------------
# Install
# ----------------------------------------------------------------------------

mb-applet-tasks_install: $(STATEDIR)/mb-applet-tasks.install

$(STATEDIR)/mb-applet-tasks.install: $(STATEDIR)/mb-applet-tasks.compile
	@$(call targetinfo, $@)
	touch $@

# ----------------------------------------------------------------------------
# Target-Install
# ----------------------------------------------------------------------------

mb-applet-tasks_targetinstall: $(STATEDIR)/mb-applet-tasks.targetinstall

mb-applet-tasks_targetinstall_deps = $(STATEDIR)/mb-applet-tasks.compile

$(STATEDIR)/mb-applet-tasks.targetinstall: $(mb-applet-tasks_targetinstall_deps)
	@$(call targetinfo, $@)
	$(MB-APPLET-TASKS_PATH) $(MAKE) -C $(MB-APPLET-TASKS_DIR) DESTDIR=$(MB-APPLET-TASKS_IPKG_TMP) install
	$(CROSSSTRIP) $(MB-APPLET-TASKS_IPKG_TMP)/usr/bin/*
	mkdir -p $(MB-APPLET-TASKS_IPKG_TMP)/CONTROL
	echo "Package: mb-applet-tasks" 						>$(MB-APPLET-TASKS_IPKG_TMP)/CONTROL/control
	echo "Priority: optional" 							>>$(MB-APPLET-TASKS_IPKG_TMP)/CONTROL/control
	echo "Section: Matchbox" 							>>$(MB-APPLET-TASKS_IPKG_TMP)/CONTROL/control
	echo "Maintainer: Alexander Chukov <Sash@pdaXrom.org>" 				>>$(MB-APPLET-TASKS_IPKG_TMP)/CONTROL/control
	echo "Architecture: $(SHORT_TARGET)" 						>>$(MB-APPLET-TASKS_IPKG_TMP)/CONTROL/control
	echo "Version: $(MB-APPLET-TASKS_VERSION)" 					>>$(MB-APPLET-TASKS_IPKG_TMP)/CONTROL/control
	echo "Depends: libmatchbox, libwnck" 						>>$(MB-APPLET-TASKS_IPKG_TMP)/CONTROL/control
	echo "Description: matchbox panel active tasks applet"				>>$(MB-APPLET-TASKS_IPKG_TMP)/CONTROL/control
	cd $(FEEDDIR) && $(XMKIPKG) $(MB-APPLET-TASKS_IPKG_TMP)
	touch $@

# ----------------------------------------------------------------------------
# Image-Install
# ----------------------------------------------------------------------------

ifdef PTXCONF_MB-APPLET-TASKS_INSTALL
ROMPACKAGES += $(STATEDIR)/mb-applet-tasks.imageinstall
endif

mb-applet-tasks_imageinstall_deps = $(STATEDIR)/mb-applet-tasks.targetinstall \
	$(STATEDIR)/virtual-image.install

$(STATEDIR)/mb-applet-tasks.imageinstall: $(mb-applet-tasks_imageinstall_deps)
	@$(call targetinfo, $@)
	cd $(FEEDDIR) && $(XIPKG) install mb-applet-tasks
	touch $@

# ----------------------------------------------------------------------------
# Clean
# ----------------------------------------------------------------------------

mb-applet-tasks_clean:
	rm -rf $(STATEDIR)/mb-applet-tasks.*
	rm -rf $(MB-APPLET-TASKS_DIR)

# vim: syntax=make
