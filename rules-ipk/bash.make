# -*-makefile-*-
# $Id: bash.make,v 1.6 2003/10/23 15:01:19 mkl Exp $
#
# Copyright (C) 2003 by Pengutronix e.K., Hildesheim, Germany
# See CREDITS for details about who has contributed to this project. 
#
# For further information about the PTXdist project and license conditions
# see the README file.
#

#
# We provide this package
#
ifeq (y, $(PTXCONF_BASH))
PACKAGES += ncurses bash
endif

#
# Paths and names 
#
###BASH			= bash-2.05b
BASH_VERSION		= 3.0
BASH			= bash-$(BASH_VERSION)
BASH_URL		= ftp://ftp.gnu.org/pub/gnu/bash/$(BASH).tar.gz 
BASH_SOURCE		= $(SRCDIR)/$(BASH).tar.gz
BASH_DIR		= $(BUILDDIR)/$(BASH)

# ----------------------------------------------------------------------------
# Get
# ----------------------------------------------------------------------------

bash_get: $(STATEDIR)/bash.get

$(STATEDIR)/bash.get: $(BASH_SOURCE)
	@$(call targetinfo, $@)
	@$(call get_patches, $(BASH))
	touch $@

$(BASH_SOURCE):
	@$(call targetinfo, $@)
	@$(call get, $(BASH_URL))

# ----------------------------------------------------------------------------
# Extract
# ----------------------------------------------------------------------------

openssh_extract_deps = \
	$(STATEDIR)/autoconf257.install \
	$(STATEDIR)/ncurses.install \
	$(STATEDIR)/bash.get

bash_extract: $(STATEDIR)/bash.extract

$(STATEDIR)/bash.extract: $(openssh_extract_deps)
	@$(call targetinfo, $@)
	@$(call clean $(BASH_DIR))
	@$(call extract, $(BASH_SOURCE))
	@$(call patchin, $(BASH))
	touch $@

# ----------------------------------------------------------------------------
# Prepare
# ----------------------------------------------------------------------------

bash_prepare: $(STATEDIR)/bash.prepare

BASH_AUTOCONF	=  --build=$(GNU_HOST)
BASH_AUTOCONF	+= --host=$(PTXCONF_GNU_TARGET)
BASH_AUTOCONF	+= --target=$(PTXCONF_GNU_TARGET)
#BASH_AUTOCONF	+= --disable-sanity-checks
BASH_AUTOCONF	+= --prefix=/usr --bindir=/bin
BASH_PATH	=  PATH=$(PTXCONF_PREFIX)/$(AUTOCONF257)/bin:$(CROSS_PATH)
BASH_ENV	=  ac_cv_func_setvbuf_reversed=no bash_cv_have_mbstate_t=yes bash_cv_job_control_missing=no
BASH_ENV	+= $(CROSS_ENV)

BASH_AUTOCONF	+= --with-curses
BASH_AUTOCONF	+= --disable-static-link

#
# dependencies
#
bash_prepare_deps = \
	$(STATEDIR)/virtual-xchain.install \
	$(STATEDIR)/bash.extract

$(STATEDIR)/bash.prepare: $(bash_prepare_deps)
	@$(call targetinfo, $@)
	cp $(TOPDIR)/rules/arm-linux $(BASH_DIR)/config.cache
	cd $(BASH_DIR) && \
	    $(BASH_PATH) autoconf
	cd $(BASH_DIR) && \
		$(BASH_PATH) $(BASH_ENV) \
		./configure $(BASH_AUTOCONF)
	touch $@

# ----------------------------------------------------------------------------
# Compile
# ----------------------------------------------------------------------------

bash_compile: $(STATEDIR)/bash.compile

$(STATEDIR)/bash.compile: $(STATEDIR)/bash.prepare 
	@$(call targetinfo, $@)
	$(BASH_PATH) $(MAKE) -C $(BASH_DIR)
	touch $@

# ----------------------------------------------------------------------------
# Install
# ----------------------------------------------------------------------------

bash_install: $(STATEDIR)/bash.install

$(STATEDIR)/bash.install: $(STATEDIR)/bash.compile
	@$(call targetinfo, $@)
	touch $@

# ----------------------------------------------------------------------------
# Target-Install
# ----------------------------------------------------------------------------

bash_targetinstall: $(STATEDIR)/bash.targetinstall \
	$(STATEDIR)/ncurses.targetinstall

$(STATEDIR)/bash.targetinstall: $(STATEDIR)/bash.compile
	@$(call targetinfo, $@)
	mkdir -p $(BASH_DIR)/ipk/bin
	install $(BASH_DIR)/bash 		$(BASH_DIR)/ipk/bin/bash
	ln -sf  bash 				$(BASH_DIR)/ipk/bin/sh
	$(CROSS_STRIP) -R .note -R .comment 	$(BASH_DIR)/ipk/bin/bash
	mkdir -p $(BASH_DIR)/ipk/CONTROL
	echo "Package: bash" 							 >$(BASH_DIR)/ipk/CONTROL/control
	echo "Priority: optional" 						>>$(BASH_DIR)/ipk/CONTROL/control
	echo "Section: Console" 						>>$(BASH_DIR)/ipk/CONTROL/control
	echo "Maintainer: Alexander Chukov <sash@pdaXrom.org>" 			>>$(BASH_DIR)/ipk/CONTROL/control
	echo "Architecture: $(SHORT_TARGET)" 					>>$(BASH_DIR)/ipk/CONTROL/control
	echo "Version: $(BASH_VERSION)" 					>>$(BASH_DIR)/ipk/CONTROL/control
	echo "Depends: ncurses" 						>>$(BASH_DIR)/ipk/CONTROL/control
	echo "Description: An sh-compatible command language interpreter."	>>$(BASH_DIR)/ipk/CONTROL/control
	cd $(FEEDDIR) && $(XMKIPKG) $(BASH_DIR)/ipk
	touch $@

# ----------------------------------------------------------------------------
# Image-Install
# ----------------------------------------------------------------------------

ifdef PTXCONF_BASH_INSTALL
ROMPACKAGES += $(STATEDIR)/bash.imageinstall
endif

bash_imageinstall_deps = $(STATEDIR)/bash.targetinstall \
	$(STATEDIR)/virtual-image.install

$(STATEDIR)/bash.imageinstall: $(bash_imageinstall_deps)
	@$(call targetinfo, $@)
	cd $(FEEDDIR) && $(XIPKG) install bash
	touch $@

# ----------------------------------------------------------------------------
# Clean
# ----------------------------------------------------------------------------

bash_clean: 
	rm -rf $(STATEDIR)/bash.* $(BASH_DIR)

# vim: syntax=make
