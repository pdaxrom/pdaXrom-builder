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
ifdef PTXCONF_PSMISC
PACKAGES += psmisc
endif

#
# Paths and names
#
PSMISC_VERSION		= 21.4
PSMISC			= psmisc-$(PSMISC_VERSION)
PSMISC_SUFFIX		= tar.gz
PSMISC_URL		= http://keihanna.dl.sourceforge.net/sourceforge/psmisc/$(PSMISC).$(PSMISC_SUFFIX)
PSMISC_SOURCE		= $(SRCDIR)/$(PSMISC).$(PSMISC_SUFFIX)
PSMISC_DIR		= $(BUILDDIR)/$(PSMISC)

# ----------------------------------------------------------------------------
# Get
# ----------------------------------------------------------------------------

psmisc_get: $(STATEDIR)/psmisc.get

psmisc_get_deps = $(PSMISC_SOURCE)

$(STATEDIR)/psmisc.get: $(psmisc_get_deps)
	@$(call targetinfo, $@)
	@$(call get_patches, $(PSMISC))
	touch $@

$(PSMISC_SOURCE):
	@$(call targetinfo, $@)
	@$(call get, $(PSMISC_URL))

# ----------------------------------------------------------------------------
# Extract
# ----------------------------------------------------------------------------

psmisc_extract: $(STATEDIR)/psmisc.extract

psmisc_extract_deps = $(STATEDIR)/psmisc.get

$(STATEDIR)/psmisc.extract: $(psmisc_extract_deps)
	@$(call targetinfo, $@)
	@$(call clean, $(PSMISC_DIR))
	@$(call extract, $(PSMISC_SOURCE))
	@$(call patchin, $(PSMISC))
	touch $@

# ----------------------------------------------------------------------------
# Prepare
# ----------------------------------------------------------------------------

psmisc_prepare: $(STATEDIR)/psmisc.prepare

#
# dependencies
#
psmisc_prepare_deps = \
	$(STATEDIR)/psmisc.extract \
	$(STATEDIR)/virtual-xchain.install

ifdef PTXCONF_NCURSES
psmisc_prepare_deps += $(STATEDIR)/ncurses.install
else
psmisc_prepare_deps += $(STATEDIR)/termcap.install
endif

PSMISC_PATH	=  PATH=$(CROSS_PATH)
PSMISC_ENV 	=  $(CROSS_ENV)
#PSMISC_ENV	+=

#
# autoconf
#
PSMISC_AUTOCONF = \
	--build=$(GNU_HOST) \
	--host=$(PTXCONF_GNU_TARGET) \
	--prefix=$(CROSS_LIB_DIR)

$(STATEDIR)/psmisc.prepare: $(psmisc_prepare_deps)
	@$(call targetinfo, $@)
	@$(call clean, $(PSMISC_DIR)/config.cache)
	cd $(PSMISC_DIR) && \
		$(PSMISC_PATH) $(PSMISC_ENV) \
		./configure $(PSMISC_AUTOCONF)
	touch $@

# ----------------------------------------------------------------------------
# Compile
# ----------------------------------------------------------------------------

psmisc_compile: $(STATEDIR)/psmisc.compile

psmisc_compile_deps = $(STATEDIR)/psmisc.prepare

$(STATEDIR)/psmisc.compile: $(psmisc_compile_deps)
	@$(call targetinfo, $@)
	$(PSMISC_PATH) $(MAKE) -C $(PSMISC_DIR)
	touch $@

# ----------------------------------------------------------------------------
# Install
# ----------------------------------------------------------------------------

psmisc_install: $(STATEDIR)/psmisc.install

$(STATEDIR)/psmisc.install: $(STATEDIR)/psmisc.compile
	@$(call targetinfo, $@)
	#$(PSMISC_PATH) $(MAKE) -C $(PSMISC_DIR) install
	touch $@

# ----------------------------------------------------------------------------
# Target-Install
# ----------------------------------------------------------------------------

psmisc_targetinstall: $(STATEDIR)/psmisc.targetinstall

psmisc_targetinstall_deps = $(STATEDIR)/psmisc.compile

ifdef PTXCONF_NCURSES
psmisc_targetinstall_deps += $(STATEDIR)/ncurses.targetinstall
endif

$(STATEDIR)/psmisc.targetinstall: $(psmisc_targetinstall_deps)
	@$(call targetinfo, $@)
	$(INSTALL) -d $(PSMISC_DIR)/ipkg/bin
	$(INSTALL) -m 755 $(PSMISC_DIR)/src/fuser $(PSMISC_DIR)/ipkg/bin
	$(CROSSSTRIP) -R .note -R .comment $(PSMISC_DIR)/ipkg/bin/fuser
	$(INSTALL) -m 755 $(PSMISC_DIR)/src/pstree $(PSMISC_DIR)/ipkg/bin
	$(CROSSSTRIP) -R .note -R .comment $(PSMISC_DIR)/ipkg/bin/pstree
ifdef PTXCONF_PSMISC_KILLALL
	$(INSTALL) -m 755 $(PSMISC_DIR)/src/killall $(PSMISC_DIR)/ipkg/bin
	$(CROSSSTRIP) -R .note -R .comment $(PSMISC_DIR)/ipkg/bin/killall
endif
	mkdir -p $(PSMISC_DIR)/ipkg/CONTROL
	echo "Package: psmisc" 							 >$(PSMISC_DIR)/ipkg/CONTROL/control
	echo "Priority: optional" 						>>$(PSMISC_DIR)/ipkg/CONTROL/control
	echo "Section: Utilities" 						>>$(PSMISC_DIR)/ipkg/CONTROL/control
	echo "Maintainer: Alexander Chukov <sash@pdaXrom.org>" 			>>$(PSMISC_DIR)/ipkg/CONTROL/control
	echo "Architecture: $(SHORT_TARGET)" 					>>$(PSMISC_DIR)/ipkg/CONTROL/control
	echo "Version: $(PSMISC_VERSION)" 					>>$(PSMISC_DIR)/ipkg/CONTROL/control
	echo "Depends: " 							>>$(PSMISC_DIR)/ipkg/CONTROL/control
	echo "Description: procfs tools"					>>$(PSMISC_DIR)/ipkg/CONTROL/control
	cd $(FEEDDIR) && $(XMKIPKG) $(PSMISC_DIR)/ipkg
	touch $@

# ----------------------------------------------------------------------------
# Image-Install
# ----------------------------------------------------------------------------

ifdef PTXCONF_PSMISC_INSTALL
ROMPACKAGES += $(STATEDIR)/psmisc.imageinstall
endif

psmisc_imageinstall_deps = $(STATEDIR)/psmisc.targetinstall \
	$(STATEDIR)/virtual-image.install

$(STATEDIR)/psmisc.imageinstall: $(psmisc_imageinstall_deps)
	@$(call targetinfo, $@)
	cd $(FEEDDIR) && $(XIPKG) install psmisc
	touch $@

# ----------------------------------------------------------------------------
# Clean
# ----------------------------------------------------------------------------

psmisc_clean:
	rm -rf $(STATEDIR)/psmisc.*
	rm -rf $(PSMISC_DIR)

# vim: syntax=make
