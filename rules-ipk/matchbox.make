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
ifdef PTXCONF_MATCHBOX
PACKAGES += xfree430 matchbox
endif

#
# Paths and names
#
MATCHBOX_VERSION	= 0.7.2+cvs20040129
MATCHBOX		= matchbox-$(MATCHBOX_VERSION)
MATCHBOX_SUFFIX		= tar.gz
MATCHBOX_URL		= http://handhelds.org/~mallum/downloadables/$(MATCHBOX).$(MATCHBOX_SUFFIX)
MATCHBOX_SOURCE		= $(SRCDIR)/$(MATCHBOX).$(MATCHBOX_SUFFIX)
MATCHBOX_DIR		= $(BUILDDIR)/$(MATCHBOX)

# ----------------------------------------------------------------------------
# Get
# ----------------------------------------------------------------------------

matchbox_get: $(STATEDIR)/matchbox.get

matchbox_get_deps = $(MATCHBOX_SOURCE)

$(STATEDIR)/matchbox.get: $(matchbox_get_deps)
	@$(call targetinfo, $@)
	@$(call get_patches, $(MATCHBOX))
	touch $@

$(MATCHBOX_SOURCE):
	@$(call targetinfo, $@)
	@$(call get, $(MATCHBOX_URL))

# ----------------------------------------------------------------------------
# Extract
# ----------------------------------------------------------------------------

matchbox_extract: $(STATEDIR)/matchbox.extract

matchbox_extract_deps = $(STATEDIR)/matchbox.get

$(STATEDIR)/matchbox.extract: $(matchbox_extract_deps)
	@$(call targetinfo, $@)
	@$(call clean, $(MATCHBOX_DIR))
	@$(call extract, $(MATCHBOX_SOURCE))
	@$(call patchin, $(MATCHBOX))
	touch $@

# ----------------------------------------------------------------------------
# Prepare
# ----------------------------------------------------------------------------

matchbox_prepare: $(STATEDIR)/matchbox.prepare

#
# dependencies
#
matchbox_prepare_deps = \
	$(STATEDIR)/matchbox.extract \
	$(STATEDIR)/libpng125.install \
	$(STATEDIR)/jpeg.install \
	$(STATEDIR)/Xsettings-client.install \
	$(STATEDIR)/startup-notification.install \
	$(STATEDIR)/virtual-xchain.install

MATCHBOX_PATH	=  PATH=$(CROSS_PATH)
MATCHBOX_ENV 	=  $(CROSS_ENV)
MATCHBOX_ENV	+= PKG_CONFIG_PATH=$(CROSS_LIB_DIR)/lib/pkgconfig:$(CROSS_LIB_DIR)/lib/pkgconfig
#MATCHBOX_ENV	+= LDFLAGS=-Wl,-rpath-link,$(CROSS_LIB_DIR)/lib

#
# autoconf
#
MATCHBOX_AUTOCONF = \
	--build=$(GNU_HOST) \
	--host=$(PTXCONF_GNU_TARGET) \
	--prefix=/usr \
	--x-includes=$(CROSS_LIB_DIR)/include \
	--x-libraries=$(CROSS_LIB_DIR)/lib

$(STATEDIR)/matchbox.prepare: $(matchbox_prepare_deps)
	@$(call targetinfo, $@)
	@$(call clean, $(MATCHBOX_DIR)/config.cache)
	cd $(MATCHBOX_DIR) && \
		$(MATCHBOX_PATH) $(MATCHBOX_ENV) \
		./configure $(MATCHBOX_AUTOCONF)  \
		--enable-xft --enable-png --enable-xsettings \
		--enable-dnotify --enable-expat --enable-libsn \
		--enable-jpg --enable-nls --disable-static --enable-shared
	touch $@

# ----------------------------------------------------------------------------
# Compile
# ----------------------------------------------------------------------------

matchbox_compile: $(STATEDIR)/matchbox.compile

matchbox_compile_deps = $(STATEDIR)/matchbox.prepare

$(STATEDIR)/matchbox.compile: $(matchbox_compile_deps)
	@$(call targetinfo, $@)
	$(MATCHBOX_PATH) $(MAKE) -C $(MATCHBOX_DIR)
	touch $@

# ----------------------------------------------------------------------------
# Install
# ----------------------------------------------------------------------------

matchbox_install: $(STATEDIR)/matchbox.install

$(STATEDIR)/matchbox.install: $(STATEDIR)/matchbox.compile
	@$(call targetinfo, $@)
	touch $@

# ----------------------------------------------------------------------------
# Target-Install
# ----------------------------------------------------------------------------

matchbox_targetinstall: $(STATEDIR)/matchbox.targetinstall

matchbox_targetinstall_deps = $(STATEDIR)/matchbox.compile \
	$(STATEDIR)/libpng125.targetinstall \
	$(STATEDIR)/jpeg.targetinstall \
	$(STATEDIR)/Xsettings-client.targetinstall \
	$(STATEDIR)/startup-notification.targetinstall


$(STATEDIR)/matchbox.targetinstall: $(matchbox_targetinstall_deps)
	@$(call targetinfo, $@)
	$(MATCHBOX_PATH) $(MAKE) -C $(MATCHBOX_DIR) install DESTDIR=$(ROOTDIR)
	cp -af  $(ROOTDIR)/usr/include       $(CROSS_LIB_DIR)
	cp -af  $(ROOTDIR)/usr/lib/pkgconfig $(CROSS_LIB_DIR)/lib
	cp -af $(ROOTDIR)/usr/lib/libmb.*    $(CROSS_LIB_DIR)/lib
	rm -rf  $(ROOTDIR)/usr/include
	rm -rf  $(ROOTDIR)/usr/lib/pkgconfig
	rm -f   $(ROOTDIR)/usr/lib/libmb.la
	perl -p -i -e "s/\/usr\/lib/`echo $(PTXCONF_PREFIX)/$(PTXCONF_GNU_TARGET)/lib | sed -e '/\//s//\\\\\//g'`/g" $(PTXCONF_PREFIX)/$(PTXCONF_GNU_TARGET)/lib/libmb.la
	perl -p -i -e "s/\/usr/`echo $(PTXCONF_PREFIX)/$(PTXCONF_GNU_TARGET) | sed -e '/\//s//\\\\\//g'`/g" $(PTXCONF_PREFIX)/$(PTXCONF_GNU_TARGET)/lib/pkgconfig/libmb.pc
	$(CROSSSTRIP) $(ROOTDIR)/usr/lib/libmb.so.1.0.0
	$(CROSSSTRIP) $(ROOTDIR)/usr/bin/matchbox
	$(CROSSSTRIP) $(ROOTDIR)/usr/bin/mbcontrol
	$(CROSSSTRIP) $(ROOTDIR)/usr/bin/mbdesktop
	$(CROSSSTRIP) $(ROOTDIR)/usr/bin/mbdock
	$(CROSSSTRIP) $(ROOTDIR)/usr/bin/mbmenu
	$(CROSSSTRIP) $(ROOTDIR)/usr/bin/miniapm
	$(CROSSSTRIP) $(ROOTDIR)/usr/bin/minisys
	$(CROSSSTRIP) $(ROOTDIR)/usr/bin/minitime
	$(CROSSSTRIP) $(ROOTDIR)/usr/bin/minivol
	$(CROSSSTRIP) $(ROOTDIR)/usr/bin/miniwave
	$(CROSSSTRIP) $(ROOTDIR)/usr/bin/monolaunch
	rm -rf $(ROOTDIR)/usr/man
	mv -f $(ROOTDIR)/etc/X11/xinit/xinitrc $(ROOTDIR)/etc/X11/xinit/xinitrc.orig
	ln -sf /usr/bin/mbsession $(ROOTDIR)/etc/X11/xinit/xinitrc
	touch $@

# ----------------------------------------------------------------------------
# Clean
# ----------------------------------------------------------------------------

matchbox_clean:
	rm -rf $(STATEDIR)/matchbox.*
	rm -rf $(MATCHBOX_DIR)

# vim: syntax=make
