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
ifdef PTXCONF_STARTUP-NOTIFICATION
PACKAGES += startup-notification
endif

#
# Paths and names
#
STARTUP-NOTIFICATION_VERSION		= 0.7
###STARTUP-NOTIFICATION_VERSION		= 0.5
STARTUP-NOTIFICATION			= startup-notification-$(STARTUP-NOTIFICATION_VERSION)
STARTUP-NOTIFICATION_SUFFIX		= tar.gz
STARTUP-NOTIFICATION_URL		= http://freedesktop.org/Software/startup-notification/releases/$(STARTUP-NOTIFICATION).$(STARTUP-NOTIFICATION_SUFFIX)
STARTUP-NOTIFICATION_SOURCE		= $(SRCDIR)/$(STARTUP-NOTIFICATION).$(STARTUP-NOTIFICATION_SUFFIX)
STARTUP-NOTIFICATION_DIR		= $(BUILDDIR)/$(STARTUP-NOTIFICATION)
STARTUP-NOTIFICATION_IPKG_TMP		= $(STARTUP-NOTIFICATION_DIR)/ipkg_tmp

# ----------------------------------------------------------------------------
# Get
# ----------------------------------------------------------------------------

startup-notification_get: $(STATEDIR)/startup-notification.get

startup-notification_get_deps = $(STARTUP-NOTIFICATION_SOURCE)

$(STATEDIR)/startup-notification.get: $(startup-notification_get_deps)
	@$(call targetinfo, $@)
	@$(call get_patches, $(STARTUP-NOTIFICATION))
	touch $@

$(STARTUP-NOTIFICATION_SOURCE):
	@$(call targetinfo, $@)
	@$(call get, $(STARTUP-NOTIFICATION_URL))

# ----------------------------------------------------------------------------
# Extract
# ----------------------------------------------------------------------------

startup-notification_extract: $(STATEDIR)/startup-notification.extract

startup-notification_extract_deps = $(STATEDIR)/startup-notification.get

$(STATEDIR)/startup-notification.extract: $(startup-notification_extract_deps)
	@$(call targetinfo, $@)
	@$(call clean, $(STARTUP-NOTIFICATION_DIR))
	@$(call extract, $(STARTUP-NOTIFICATION_SOURCE))
	@$(call patchin, $(STARTUP-NOTIFICATION))
	touch $@

# ----------------------------------------------------------------------------
# Prepare
# ----------------------------------------------------------------------------

startup-notification_prepare: $(STATEDIR)/startup-notification.prepare

#
# dependencies
#
startup-notification_prepare_deps = \
	$(STATEDIR)/startup-notification.extract \
	$(STATEDIR)/virtual-xchain.install

STARTUP-NOTIFICATION_PATH	=  PATH=$(CROSS_PATH)
STARTUP-NOTIFICATION_ENV 	=  $(CROSS_ENV)
#STARTUP-NOTIFICATION_ENV	+=

#
# autoconf
#
STARTUP-NOTIFICATION_AUTOCONF = \
	--build=$(GNU_HOST) \
	--host=$(PTXCONF_GNU_TARGET) \
	--prefix=/usr \
	--x-includes=$(CROSS_LIB_DIR)/include \
	--x-libraries=$(CROSS_LIB_DIR)/lib
	#$(CROSS_LIB_DIR)

$(STATEDIR)/startup-notification.prepare: $(startup-notification_prepare_deps)
	@$(call targetinfo, $@)
	@$(call clean, $(STARTUP-NOTIFICATION_DIR)/config.cache)
	#cp -f $(TOPDIR)/rules/arm-linux $(STARTUP-NOTIFICATION_DIR)/config.cache
	cd $(STARTUP-NOTIFICATION_DIR) && \
		$(STARTUP-NOTIFICATION_PATH) $(STARTUP-NOTIFICATION_ENV) \
		lf_cv_sane_realloc=yes \
		./configure $(STARTUP-NOTIFICATION_AUTOCONF) \
			--disable-debug --enable-shared --disable-static
	touch $@

# ----------------------------------------------------------------------------
# Compile
# ----------------------------------------------------------------------------

startup-notification_compile: $(STATEDIR)/startup-notification.compile

startup-notification_compile_deps = $(STATEDIR)/startup-notification.prepare

$(STATEDIR)/startup-notification.compile: $(startup-notification_compile_deps)
	@$(call targetinfo, $@)
	$(STARTUP-NOTIFICATION_PATH) $(MAKE) -C $(STARTUP-NOTIFICATION_DIR)
	touch $@

# ----------------------------------------------------------------------------
# Install
# ----------------------------------------------------------------------------

startup-notification_install: $(STATEDIR)/startup-notification.install

$(STATEDIR)/startup-notification.install: $(STATEDIR)/startup-notification.compile
	@$(call targetinfo, $@)
	$(STARTUP-NOTIFICATION_PATH) $(MAKE) -C $(STARTUP-NOTIFICATION_DIR) install \
	    prefix=$(CROSS_LIB_DIR)
	perl -p -i -e "s/\/usr\/lib/`echo $(PTXCONF_PREFIX)/$(PTXCONF_GNU_TARGET)/lib | sed -e '/\//s//\\\\\//g'`/g" $(PTXCONF_PREFIX)/$(PTXCONF_GNU_TARGET)/lib/libstartup-notification-1.la
	perl -p -i -e "s/\/usr/`echo $(PTXCONF_PREFIX)/$(PTXCONF_GNU_TARGET) | sed -e '/\//s//\\\\\//g'`/g" $(PTXCONF_PREFIX)/$(PTXCONF_GNU_TARGET)/lib/pkgconfig/libstartup-notification-1.0.pc
	touch $@

# ----------------------------------------------------------------------------
# Target-Install
# ----------------------------------------------------------------------------

startup-notification_targetinstall: $(STATEDIR)/startup-notification.targetinstall

startup-notification_targetinstall_deps = $(STATEDIR)/startup-notification.compile

$(STATEDIR)/startup-notification.targetinstall: $(startup-notification_targetinstall_deps)
	@$(call targetinfo, $@)
	mkdir -p $(STARTUP-NOTIFICATION_IPKG_TMP)/usr/lib
	cp -af $(PTXCONF_PREFIX)/$(PTXCONF_GNU_TARGET)/lib/libstartup-notification-1.so* \
			    $(STARTUP-NOTIFICATION_IPKG_TMP)/usr/lib
	$(CROSSSTRIP) $(STARTUP-NOTIFICATION_IPKG_TMP)/usr/lib/libstartup-notification-1.so*
	mkdir -p $(STARTUP-NOTIFICATION_IPKG_TMP)/CONTROL
	echo "Package: startup-notification" 		 >$(STARTUP-NOTIFICATION_IPKG_TMP)/CONTROL/control
	echo "Priority: optional" 			>>$(STARTUP-NOTIFICATION_IPKG_TMP)/CONTROL/control
	echo "Section: X11"	 			>>$(STARTUP-NOTIFICATION_IPKG_TMP)/CONTROL/control
	echo "Maintainer: Alexander Chukov <sash@pdaXrom.org>">>$(STARTUP-NOTIFICATION_IPKG_TMP)/CONTROL/control
	echo "Architecture: $(SHORT_TARGET)" 		>>$(STARTUP-NOTIFICATION_IPKG_TMP)/CONTROL/control
	echo "Version: $(STARTUP-NOTIFICATION_VERSION)" >>$(STARTUP-NOTIFICATION_IPKG_TMP)/CONTROL/control
	echo "Depends: xfree430" 			>>$(STARTUP-NOTIFICATION_IPKG_TMP)/CONTROL/control
	echo "Description: Startup notification library">>$(STARTUP-NOTIFICATION_IPKG_TMP)/CONTROL/control
	cd $(FEEDDIR) && $(XMKIPKG) $(STARTUP-NOTIFICATION_IPKG_TMP)
	touch $@

# ----------------------------------------------------------------------------
# Clean
# ----------------------------------------------------------------------------

startup-notification_clean:
	rm -rf $(STATEDIR)/startup-notification.*
	rm -rf $(STARTUP-NOTIFICATION_DIR)

# vim: syntax=make
