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
ifdef PTXCONF_NTP
PACKAGES += zoneinfo ntp
endif

#
# Paths and names
#
NTP_VENDOR_VERSION	= 2
NTP_VERSION		= 4.2.0
NTP			= ntp-$(NTP_VERSION)
NTP_SUFFIX		= tar.gz
NTP_URL			= http://www.eecis.udel.edu/~ntp/ntp_spool/ntp4/$(NTP).$(NTP_SUFFIX)
NTP_SOURCE		= $(SRCDIR)/$(NTP).$(NTP_SUFFIX)
NTP_DIR			= $(BUILDDIR)/$(NTP)
NTP_IPKG_TMP		= $(NTP_DIR)/ipkg_tmp

# ----------------------------------------------------------------------------
# Get
# ----------------------------------------------------------------------------

ntp_get: $(STATEDIR)/ntp.get

ntp_get_deps = $(NTP_SOURCE)

$(STATEDIR)/ntp.get: $(ntp_get_deps)
	@$(call targetinfo, $@)
	@$(call get_patches, $(NTP))
	touch $@

$(NTP_SOURCE):
	@$(call targetinfo, $@)
	@$(call get, $(NTP_URL))

# ----------------------------------------------------------------------------
# Extract
# ----------------------------------------------------------------------------

ntp_extract: $(STATEDIR)/ntp.extract

ntp_extract_deps = $(STATEDIR)/ntp.get

$(STATEDIR)/ntp.extract: $(ntp_extract_deps)
	@$(call targetinfo, $@)
	@$(call clean, $(NTP_DIR))
	@$(call extract, $(NTP_SOURCE))
	@$(call patchin, $(NTP))
	touch $@

# ----------------------------------------------------------------------------
# Prepare
# ----------------------------------------------------------------------------

ntp_prepare: $(STATEDIR)/ntp.prepare

#
# dependencies
#
ntp_prepare_deps = \
	$(STATEDIR)/ntp.extract \
	$(STATEDIR)/virtual-xchain.install

NTP_PATH	=  PATH=$(CROSS_PATH)
NTP_ENV 	=  $(CROSS_ENV)
#NTP_ENV	+=
NTP_ENV	+= PKG_CONFIG_PATH=$(CROSS_LIB_DIR)/lib/pkgconfig:$(CROSS_LIB_DIR)/lib/pkgconfig
#ifdef PTXCONF_XFREE430
#NTP_ENV	+= LDFLAGS=-Wl,-rpath-link,$(CROSS_LIB_DIR)/lib
#endif

#
# autoconf
#
NTP_AUTOCONF = \
	--build=$(GNU_HOST) \
	--host=$(PTXCONF_GNU_TARGET) \
	--prefix=/usr

ifdef PTXCONF_XFREE430
NTP_AUTOCONF += --x-includes=$(CROSS_LIB_DIR)/include
NTP_AUTOCONF += --x-libraries=$(CROSS_LIB_DIR)/lib
endif

$(STATEDIR)/ntp.prepare: $(ntp_prepare_deps)
	@$(call targetinfo, $@)
	@$(call clean, $(NTP_DIR)/config.cache)
	cd $(NTP_DIR) && \
		$(NTP_PATH) $(NTP_ENV) \
		./configure $(NTP_AUTOCONF)
	touch $@

# ----------------------------------------------------------------------------
# Compile
# ----------------------------------------------------------------------------

ntp_compile: $(STATEDIR)/ntp.compile

ntp_compile_deps = $(STATEDIR)/ntp.prepare

$(STATEDIR)/ntp.compile: $(ntp_compile_deps)
	@$(call targetinfo, $@)
	$(NTP_PATH) $(MAKE) -C $(NTP_DIR)/ntpdate 
	$(NTP_PATH) $(MAKE) -C $(NTP_DIR)/ntpd
	touch $@

# ----------------------------------------------------------------------------
# Install
# ----------------------------------------------------------------------------

ntp_install: $(STATEDIR)/ntp.install

$(STATEDIR)/ntp.install: $(STATEDIR)/ntp.compile
	@$(call targetinfo, $@)
	touch $@

# ----------------------------------------------------------------------------
# Target-Install
# ----------------------------------------------------------------------------

ntp_targetinstall: $(STATEDIR)/ntp.targetinstall

ntp_targetinstall_deps = $(STATEDIR)/ntp.compile

$(STATEDIR)/ntp.targetinstall: $(ntp_targetinstall_deps)
	@$(call targetinfo, $@)
	rm -rf $(NTP_IPKG_TMP)
	$(INSTALL) -D -m 755 $(NTP_DIR)/ntpdate/ntpdate $(NTP_IPKG_TMP)/usr/bin/ntpdate
	$(CROSSSTRIP) $(NTP_IPKG_TMP)/usr/bin/ntpdate
	mkdir -p $(NTP_IPKG_TMP)/CONTROL
	echo "Package: ntpdate" 						>$(NTP_IPKG_TMP)/CONTROL/control
	echo "Priority: optional" 						>>$(NTP_IPKG_TMP)/CONTROL/control
	echo "Section: Utilities" 						>>$(NTP_IPKG_TMP)/CONTROL/control
	echo "Maintainer: Alexander Chukov <sash@pdaXrom.org>" 			>>$(NTP_IPKG_TMP)/CONTROL/control
	echo "Architecture: $(SHORT_TARGET)" 					>>$(NTP_IPKG_TMP)/CONTROL/control
	echo "Version: $(NTP_VERSION)-$(NTP_VENDOR_VERSION)" 			>>$(NTP_IPKG_TMP)/CONTROL/control
	echo "Depends: timezones" 						>>$(NTP_IPKG_TMP)/CONTROL/control
	echo "Description: Network time protocol support"			>>$(NTP_IPKG_TMP)/CONTROL/control
	cd $(FEEDDIR) && $(XMKIPKG) $(NTP_IPKG_TMP)

	rm -rf $(NTP_IPKG_TMP)
	$(INSTALL) -D -m 755 $(NTP_DIR)/ntpd/ntpd $(NTP_IPKG_TMP)/usr/bin/ntpd
	$(CROSSSTRIP) $(NTP_IPKG_TMP)/usr/bin/ntpd
	mkdir -p $(NTP_IPKG_TMP)/etc/rc.d/init.d
	mkdir -p $(NTP_IPKG_TMP)/etc/rc.d/rc0.d
	mkdir -p $(NTP_IPKG_TMP)/etc/rc.d/rc1.d
	mkdir -p $(NTP_IPKG_TMP)/etc/rc.d/rc2.d
	mkdir -p $(NTP_IPKG_TMP)/etc/rc.d/rc3.d
	mkdir -p $(NTP_IPKG_TMP)/etc/rc.d/rc4.d
	mkdir -p $(NTP_IPKG_TMP)/etc/rc.d/rc5.d
	mkdir -p $(NTP_IPKG_TMP)/etc/rc.d/rc6.d
	$(INSTALL) -m 755 $(TOPDIR)/config/pics/ntpd $(NTP_IPKG_TMP)/etc/rc.d/init.d/
	ln -sf ../init.d/ntpd $(NTP_IPKG_TMP)/etc/rc.d/rc0.d/K51ntpd
	ln -sf ../init.d/ntpd $(NTP_IPKG_TMP)/etc/rc.d/rc1.d/K51ntpd
	ln -sf ../init.d/ntpd $(NTP_IPKG_TMP)/etc/rc.d/rc3.d/S49ntpd
	ln -sf ../init.d/ntpd $(NTP_IPKG_TMP)/etc/rc.d/rc4.d/S49ntpd
	ln -sf ../init.d/ntpd $(NTP_IPKG_TMP)/etc/rc.d/rc5.d/S49ntpd
	ln -sf ../init.d/ntpd $(NTP_IPKG_TMP)/etc/rc.d/rc6.d/K51ntpd
	mkdir -p $(NTP_IPKG_TMP)/CONTROL
	echo "Package: ntpd" 							>$(NTP_IPKG_TMP)/CONTROL/control
	echo "Priority: optional" 						>>$(NTP_IPKG_TMP)/CONTROL/control
	echo "Section: Utilities" 						>>$(NTP_IPKG_TMP)/CONTROL/control
	echo "Maintainer: Alexander Chukov <sash@pdaXrom.org>" 			>>$(NTP_IPKG_TMP)/CONTROL/control
	echo "Architecture: $(SHORT_TARGET)" 					>>$(NTP_IPKG_TMP)/CONTROL/control
	echo "Version: $(NTP_VERSION)-$(NTP_VENDOR_VERSION)" 			>>$(NTP_IPKG_TMP)/CONTROL/control
	echo "Depends: timezones" 						>>$(NTP_IPKG_TMP)/CONTROL/control
	echo "Description: Network time protocol support daemon"		>>$(NTP_IPKG_TMP)/CONTROL/control

	echo "#!/bin/sh"							>$(NTP_IPKG_TMP)/CONTROL/postinst
	echo "/etc/rc.d/init.d/ntpd start"					>>$(NTP_IPKG_TMP)/CONTROL/postinst

	chmod 755 $(NTP_IPKG_TMP)/CONTROL/postinst

	cd $(FEEDDIR) && $(XMKIPKG) $(NTP_IPKG_TMP)

	touch $@

# ----------------------------------------------------------------------------
# Image-Install
# ----------------------------------------------------------------------------

ifdef PTXCONF_NTP_INSTALL
ROMPACKAGES += $(STATEDIR)/ntp.imageinstall
endif

ntp_imageinstall_deps = $(STATEDIR)/ntp.targetinstall \
	$(STATEDIR)/virtual-image.install

$(STATEDIR)/ntp.imageinstall: $(ntp_imageinstall_deps)
	@$(call targetinfo, $@)
	cd $(FEEDDIR) && $(XIPKG) install ntpdate
	touch $@

# ----------------------------------------------------------------------------
# Image-Install
# ----------------------------------------------------------------------------

ifdef PTXCONF_NTP_INSTALL_NTPD
ROMPACKAGES += $(STATEDIR)/ntpd.imageinstall
endif

ntpd_imageinstall_deps = $(STATEDIR)/ntp.targetinstall \
	$(STATEDIR)/virtual-image.install

$(STATEDIR)/ntpd.imageinstall: $(ntpd_imageinstall_deps)
	@$(call targetinfo, $@)
	cd $(FEEDDIR) && $(XIPKG) install ntpd
	touch $@

# ----------------------------------------------------------------------------
# Clean
# ----------------------------------------------------------------------------

ntp_clean:
	rm -rf $(STATEDIR)/ntp.*
	rm -rf $(NTP_DIR)

# vim: syntax=make
