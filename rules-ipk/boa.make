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
ifdef PTXCONF_BOA
PACKAGES += boa
endif

#
# Paths and names
#
BOA_VERSION	= 0.94.14rc20
BOA		= boa-$(BOA_VERSION)
BOA_SUFFIX	= tar.gz
BOA_URL		= http://www.boa.org/$(BOA).$(BOA_SUFFIX)
BOA_SOURCE	= $(SRCDIR)/$(BOA).$(BOA_SUFFIX)
BOA_DIR		= $(BUILDDIR)/$(BOA)
BOA_IPKG_TMP	= $(BOA_DIR)/ipkg_tmp

# ----------------------------------------------------------------------------
# Get
# ----------------------------------------------------------------------------

boa_get: $(STATEDIR)/boa.get

boa_get_deps = $(BOA_SOURCE)

$(STATEDIR)/boa.get: $(boa_get_deps)
	@$(call targetinfo, $@)
	@$(call get_patches, $(BOA))
	touch $@

$(BOA_SOURCE):
	@$(call targetinfo, $@)
	@$(call get, $(BOA_URL))

# ----------------------------------------------------------------------------
# Extract
# ----------------------------------------------------------------------------

boa_extract: $(STATEDIR)/boa.extract

boa_extract_deps = $(STATEDIR)/boa.get

$(STATEDIR)/boa.extract: $(boa_extract_deps)
	@$(call targetinfo, $@)
	@$(call clean, $(BOA_DIR))
	@$(call extract, $(BOA_SOURCE))
	@$(call patchin, $(BOA))
	touch $@

# ----------------------------------------------------------------------------
# Prepare
# ----------------------------------------------------------------------------

boa_prepare: $(STATEDIR)/boa.prepare

#
# dependencies
#
boa_prepare_deps = \
	$(STATEDIR)/boa.extract \
	$(STATEDIR)/virtual-xchain.install

BOA_PATH	=  PATH=$(CROSS_PATH)
BOA_ENV 	=  $(CROSS_ENV)
#BOA_ENV	+=
BOA_ENV	+= PKG_CONFIG_PATH=$(CROSS_LIB_DIR)/lib/pkgconfig:$(CROSS_LIB_DIR)/lib/pkgconfig
#ifdef PTXCONF_XFREE430
#BOA_ENV	+= LDFLAGS=-Wl,-rpath-link,$(CROSS_LIB_DIR)/lib
#endif

#
# autoconf
#
BOA_AUTOCONF = \
	--build=$(GNU_HOST) \
	--host=$(PTXCONF_GNU_TARGET) \
	--prefix=/usr

ifdef PTXCONF_XFREE430
BOA_AUTOCONF += --x-includes=$(CROSS_LIB_DIR)/include
BOA_AUTOCONF += --x-libraries=$(CROSS_LIB_DIR)/lib
endif

$(STATEDIR)/boa.prepare: $(boa_prepare_deps)
	@$(call targetinfo, $@)
	@$(call clean, $(BOA_DIR)/config.cache)
	cd $(BOA_DIR) && \
		$(BOA_PATH) $(BOA_ENV) \
		./configure $(BOA_AUTOCONF)
	touch $@

# ----------------------------------------------------------------------------
# Compile
# ----------------------------------------------------------------------------

boa_compile: $(STATEDIR)/boa.compile

boa_compile_deps = $(STATEDIR)/boa.prepare

$(STATEDIR)/boa.compile: $(boa_compile_deps)
	@$(call targetinfo, $@)
	$(BOA_PATH) $(MAKE) -C $(BOA_DIR)
	touch $@

# ----------------------------------------------------------------------------
# Install
# ----------------------------------------------------------------------------

boa_install: $(STATEDIR)/boa.install

$(STATEDIR)/boa.install: $(STATEDIR)/boa.compile
	@$(call targetinfo, $@)
	$(BOA_PATH) $(MAKE) -C $(BOA_DIR) install
	touch $@

# ----------------------------------------------------------------------------
# Target-Install
# ----------------------------------------------------------------------------

boa_targetinstall: $(STATEDIR)/boa.targetinstall

boa_targetinstall_deps = $(STATEDIR)/boa.compile

$(STATEDIR)/boa.targetinstall: $(boa_targetinstall_deps)
	@$(call targetinfo, $@)

	mkdir -p $(BOA_IPKG_TMP)/usr/sbin
	mkdir -p $(BOA_IPKG_TMP)/home/httpd/{html,cgi-bin}
	mkdir -p $(BOA_IPKG_TMP)/var/log/boa
	mkdir -p $(BOA_IPKG_TMP)/usr/lib/boa
	mkdir -p $(BOA_IPKG_TMP)/etc/rc.d/init.d
	mkdir -p $(BOA_IPKG_TMP)/etc/boa

	$(INSTALL) -m 755 $(BOA_DIR)/src/boa			$(BOA_IPKG_TMP)/usr/sbin/
	$(CROSSSTRIP) $(BOA_IPKG_TMP)/usr/sbin/boa
	$(INSTALL) -m 755 $(BOA_DIR)/src/boa_indexer		$(BOA_IPKG_TMP)/usr/lib/boa/
	$(CROSSSTRIP) $(BOA_IPKG_TMP)/usr/lib/boa/boa_indexer
	$(INSTALL) -m 644 $(BOA_DIR)/contrib/rpm/boa.conf	$(BOA_IPKG_TMP)/etc/boa/

	$(INSTALL) -m 755 $(BOA_DIR)/contrib/rpm/boa.init-redhat $(BOA_IPKG_TMP)/etc/rc.d/init.d/boa
	mkdir -p $(BOA_IPKG_TMP)/etc/{boa,logrotate.d}
	$(INSTALL) -m 644 $(BOA_DIR)/contrib/rpm/boa.logrotate	$(BOA_IPKG_TMP)/etc/logrotate.d/boa

	touch $(BOA_IPKG_TMP)/var/log/boa/{error,access}_log

	mkdir -p $(BOA_IPKG_TMP)/etc/rc.d/rc0.d
	mkdir -p $(BOA_IPKG_TMP)/etc/rc.d/rc1.d
	mkdir -p $(BOA_IPKG_TMP)/etc/rc.d/rc2.d
	mkdir -p $(BOA_IPKG_TMP)/etc/rc.d/rc3.d
	mkdir -p $(BOA_IPKG_TMP)/etc/rc.d/rc4.d
	mkdir -p $(BOA_IPKG_TMP)/etc/rc.d/rc5.d
	mkdir -p $(BOA_IPKG_TMP)/etc/rc.d/rc6.d

	ln -sf ../init.d/boa $(BOA_IPKG_TMP)/etc/rc.d/rc0.d/K50boa
	ln -sf ../init.d/boa $(BOA_IPKG_TMP)/etc/rc.d/rc1.d/K50boa
	ln -sf ../init.d/boa $(BOA_IPKG_TMP)/etc/rc.d/rc3.d/S50boa
	ln -sf ../init.d/boa $(BOA_IPKG_TMP)/etc/rc.d/rc4.d/S50boa
	ln -sf ../init.d/boa $(BOA_IPKG_TMP)/etc/rc.d/rc5.d/S50boa
	ln -sf ../init.d/boa $(BOA_IPKG_TMP)/etc/rc.d/rc6.d/K50boa

	mkdir -p $(BOA_IPKG_TMP)/CONTROL
	echo "Package: boa" 							>$(BOA_IPKG_TMP)/CONTROL/control
	echo "Priority: optional" 						>>$(BOA_IPKG_TMP)/CONTROL/control
	echo "Section: Internet" 						>>$(BOA_IPKG_TMP)/CONTROL/control
	echo "Maintainer: Alexander Chukov <sash@pdaXrom.org>" 			>>$(BOA_IPKG_TMP)/CONTROL/control
	echo "Architecture: $(SHORT_TARGET)" 					>>$(BOA_IPKG_TMP)/CONTROL/control
	echo "Version: $(BOA_VERSION)" 						>>$(BOA_IPKG_TMP)/CONTROL/control
	echo "Depends: " 							>>$(BOA_IPKG_TMP)/CONTROL/control
	echo "Description: Boa is a single-tasking HTTP server."		>>$(BOA_IPKG_TMP)/CONTROL/control

	echo "#!/bin/sh"							>$(BOA_IPKG_TMP)/CONTROL/postinst
	echo "chmod 600           /var/log/boa/error_log /var/log/boa/access_log" >>$(BOA_IPKG_TMP)/CONTROL/postinst
	echo "chown nobody:nobody /var/log/boa/error_log /var/log/boa/access_log" >>$(BOA_IPKG_TMP)/CONTROL/postinst
	echo "touch /etc/mime.types"						>>$(BOA_IPKG_TMP)/CONTROL/postinst
	echo "/etc/rc.d/init.d/boa start"					>>$(BOA_IPKG_TMP)/CONTROL/postinst
	chmod 755 $(BOA_IPKG_TMP)/CONTROL/postinst

	echo "#!/bin/sh"							>$(BOA_IPKG_TMP)/CONTROL/prerm
	echo "/etc/rc.d/init.d/boa stop"					>>$(BOA_IPKG_TMP)/CONTROL/prerm
	chmod 755 $(BOA_IPKG_TMP)/CONTROL/prerm
	
	cd $(FEEDDIR) && $(XMKIPKG) $(BOA_IPKG_TMP)
	touch $@

# ----------------------------------------------------------------------------
# Image-Install
# ----------------------------------------------------------------------------

ifdef PTXCONF_BOA_INSTALL
ROMPACKAGES += $(STATEDIR)/boa.imageinstall
endif

boa_imageinstall_deps = $(STATEDIR)/boa.targetinstall \
	$(STATEDIR)/virtual-image.install

$(STATEDIR)/boa.imageinstall: $(boa_imageinstall_deps)
	@$(call targetinfo, $@)
	cd $(FEEDDIR) && $(XIPKG) install boa
	touch $@

# ----------------------------------------------------------------------------
# Clean
# ----------------------------------------------------------------------------

boa_clean:
	rm -rf $(STATEDIR)/boa.*
	rm -rf $(BOA_DIR)

# vim: syntax=make
