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
ifdef PTXCONF_XCHAIN_QT-X11
PACKAGES += xchain-qt-x11
endif

#
# Paths and names
#
XCHAIN_QT-X11			= $(QT-X11)
XCHAIN_QT-X11_DIR		= $(XCHAIN_BUILDDIR)/qt-$(QT-X11_VERSION)

# ----------------------------------------------------------------------------
# Get
# ----------------------------------------------------------------------------

xchain-qt-x11_get: $(STATEDIR)/xchain-qt-x11.get

xchain-qt-x11_get_deps = $(XCHAIN_QT-X11_SOURCE)

$(STATEDIR)/xchain-qt-x11.get: $(xchain-qt-x11_get_deps)
	@$(call targetinfo, $@)
	@$(call get_patches, $(QT-X11))
	touch $@

$(XCHAIN_QT-X11_SOURCE):
	@$(call targetinfo, $@)
	@$(call get, $(QT-X11_URL))

# ----------------------------------------------------------------------------
# Extract
# ----------------------------------------------------------------------------

xchain-qt-x11_extract: $(STATEDIR)/xchain-qt-x11.extract

xchain-qt-x11_extract_deps = $(STATEDIR)/xchain-qt-x11.get

$(STATEDIR)/xchain-qt-x11.extract: $(xchain-qt-x11_extract_deps)
	@$(call targetinfo, $@)
	@$(call clean, $(XCHAIN_QT-X11_DIR))
	@$(call extract, $(QT-X11_SOURCE), $(XCHAIN_BUILDDIR))
	@$(call patchin, $(QT-X11), $(XCHAIN_QT-X11_DIR))
	touch $@

# ----------------------------------------------------------------------------
# Prepare
# ----------------------------------------------------------------------------

xchain-qt-x11_prepare: $(STATEDIR)/xchain-qt-x11.prepare

#
# dependencies
#
xchain-qt-x11_prepare_deps = \
	$(STATEDIR)/xchain-qt-x11.extract

XCHAIN_QT-X11_PATH	=  PATH=$(CROSS_PATH)
XCHAIN_QT-X11_ENV 	=  $(HOSTCC_ENV)
XCHAIN_QT-X11_ENV	+= QTDIR=$(XCHAIN_QT-X11_DIR)

#
# autoconf
#
XCHAIN_QT-X11_AUTOCONF =

$(STATEDIR)/xchain-qt-x11.prepare: $(xchain-qt-x11_prepare_deps)
	@$(call targetinfo, $@)
	@$(call clean, $(XCHAIN_QT-X11_DIR)/config.cache)
	perl -i -p -e "s,\/usr/X11R6,$(NATIVE_SDK_FILES_PREFIX),g" $(XCHAIN_QT-X11_DIR)/configs/linux-g++-static
	perl -p -i -e "s/sub-tutorial\ sub-examples//g" $(XCHAIN_QT-X11_DIR)/Makefile
	cd $(XCHAIN_QT-X11_DIR) && \
		echo yes | \
		$(XCHAIN_QT-X11_PATH) $(XCHAIN_QT-X11_ENV) \
		./configure -static -xft -no-g++-exceptions -system-zlib -system-libpng -system-jpeg -gif \
			    -I`pkg-config freetype2 --cflags | sed -e 's/^-I//'`
	touch $@

# ----------------------------------------------------------------------------
# Compile
# ----------------------------------------------------------------------------

xchain-qt-x11_compile: $(STATEDIR)/xchain-qt-x11.compile

xchain-qt-x11_compile_deps = $(STATEDIR)/xchain-qt-x11.prepare

$(STATEDIR)/xchain-qt-x11.compile: $(xchain-qt-x11_compile_deps)
	@$(call targetinfo, $@)
	$(XCHAIN_QT-X11_PATH) $(MAKE) -C $(XCHAIN_QT-X11_DIR)
	touch $@

# ----------------------------------------------------------------------------
# Install
# ----------------------------------------------------------------------------

xchain-qt-x11_install: $(STATEDIR)/xchain-qt-x11.install

$(STATEDIR)/xchain-qt-x11.install: $(STATEDIR)/xchain-qt-x11.compile
	@$(call targetinfo, $@)
	install -s -m 755 $(XCHAIN_QT-X11_DIR)/bin/uic		$(PTXCONF_PREFIX)/bin/uic-2.3.2
	install -s -m 755 $(XCHAIN_QT-X11_DIR)/bin/designer	$(PTXCONF_PREFIX)/bin/designer-2.3.2
	touch $@

# ----------------------------------------------------------------------------
# Target-Install
# ----------------------------------------------------------------------------

xchain-qt-x11_targetinstall: $(STATEDIR)/xchain-qt-x11.targetinstall

xchain-qt-x11_targetinstall_deps = $(STATEDIR)/xchain-qt-x11.compile

$(STATEDIR)/xchain-qt-x11.targetinstall: $(xchain-qt-x11_targetinstall_deps)
	@$(call targetinfo, $@)
	touch $@

# ----------------------------------------------------------------------------
# Clean
# ----------------------------------------------------------------------------

xchain-qt-x11_clean:
	rm -rf $(STATEDIR)/xchain-qt-x11.*
	rm -rf $(XCHAIN_QT-X11_DIR)

# vim: syntax=make
