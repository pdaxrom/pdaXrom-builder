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
ifdef PTXCONF_OPENSSH
PACKAGES += openssh
endif

#
# Paths and names
#
OPENSSH_VERSION		= 3.7.1p2
OPENSSH			= openssh-$(OPENSSH_VERSION)
OPENSSH_SUFFIX		= tar.gz
OPENSSH_URL		= ftp://ftp.openbsd.org/pub/OpenBSD/OpenSSH/portable/$(OPENSSH).$(OPENSSH_SUFFIX)
OPENSSH_SOURCE		= $(SRCDIR)/$(OPENSSH).$(OPENSSH_SUFFIX)
OPENSSH_DIR		= $(BUILDDIR)/$(OPENSSH)
OPENSSH_IPKG_TMP	= $(OPENSSH_DIR)/ipkg_tmp

# ----------------------------------------------------------------------------
# Get
# ----------------------------------------------------------------------------

openssh_get: $(STATEDIR)/openssh.get

openssh_get_deps = $(OPENSSH_SOURCE)

$(STATEDIR)/openssh.get: $(openssh_get_deps)
	@$(call targetinfo, $@)
	@$(call get_patches, $(OPENSSH))
	touch $@

$(OPENSSH_SOURCE):
	@$(call targetinfo, $@)
	@$(call get, $(OPENSSH_URL))

# ----------------------------------------------------------------------------
# Extract
# ----------------------------------------------------------------------------

openssh_extract: $(STATEDIR)/openssh.extract

openssh_extract_deps = $(STATEDIR)/openssh.get \
	$(STATEDIR)/openssl.install

$(STATEDIR)/openssh.extract: $(openssh_extract_deps)
	@$(call targetinfo, $@)
	@$(call clean, $(OPENSSH_DIR))
	@$(call extract, $(OPENSSH_SOURCE))
	@$(call patchin, $(OPENSSH))
	OPENSSL_VERSION_NUMBER="`sed -n -e 's/.*OPENSSL_VERSION_NUMBER.*0x[0]*\([0-9a-f]*\)L/\1/p' \
		$(CROSS_LIB_DIR)/include/openssl/opensslv.h`" \
	OPENSSL_VERSION_TEXT="`sed -n -e 's/.*OPENSSL_VERSION_TEXT.*"\(.*\)"/\1/p' \
		$(CROSS_LIB_DIR)/include/openssl/opensslv.h`" && \
	perl -i -p -e "s/ssl_library_ver=\"VERSION\"/ssl_library_ver=\"$$OPENSSL_VERSION_NUMBER ($$OPENSSL_VERSION_TEXT)\"/g" \
		$(OPENSSH_DIR)/configure.ac && \
	perl -i -p -e "s/ssl_header_ver=\"VERSION\"/ssl_header_ver=\"$$OPENSSL_VERSION_NUMBER ($$OPENSSL_VERSION_TEXT)\"/g" \
		$(OPENSSH_DIR)/configure.ac

	#cd $(OPENSSH_DIR) && PATH=$(PTXCONF_PREFIX)/$(AUTOCONF257)/bin:$$PATH autoconf
	cd $(OPENSSH_DIR) && PATH=$(PTXCONF_PREFIX)/bin:$$PATH autoconf
	touch $@

# ----------------------------------------------------------------------------
# Prepare
# ----------------------------------------------------------------------------

openssh_prepare: $(STATEDIR)/openssh.prepare

#
# dependencies
#
openssh_prepare_deps = \
	$(STATEDIR)/openssh.extract \
	$(STATEDIR)/zlib.install \
	$(STATEDIR)/virtual-xchain.install

OPENSSH_PATH	=  PATH=$(CROSS_PATH)
OPENSSH_ENV	= \
	$(CROSS_ENV_AR) \
	$(CORSS_ENV_AS) \
	$(CROSS_ENV_CXX) \
	$(CROSS_ENV_CC) \
	$(CROSS_ENV_NM) \
	$(CROSS_ENV_OBJCOPY) \
	$(CROSS_ENV_RANLIB) \
	$(CROSS_ENV_STRIP) \
	LD=$(PTXCONF_GNU_TARGET)-gcc

OPENSSH_ENV	+= PKG_CONFIG_PATH=$(CROSS_LIB_DIR)/lib/pkgconfig:$(CROSS_LIB_DIR)/lib/pkgconfig
#ifdef PTXCONF_XFREE430
#OPENSSH_ENV	+= LDFLAGS=-Wl,-rpath-link,$(CROSS_LIB_DIR)/lib
#endif

#
# autoconf
#
OPENSSH_AUTOCONF = \
	--build=$(GNU_HOST) \
	--host=$(PTXCONF_GNU_TARGET) \
	--prefix=/usr \
	--libexecdir=/usr/sbin \
	--sysconfdir=/etc/ssh \
	--without-pam \
	--with-ipv4-default \
	--disable-etc-default-login

ifdef PTXCONF_XFREE430
OPENSSH_AUTOCONF += --x-includes=$(CROSS_LIB_DIR)/include
OPENSSH_AUTOCONF += --x-libraries=$(CROSS_LIB_DIR)/lib
endif

$(STATEDIR)/openssh.prepare: $(openssh_prepare_deps)
	@$(call targetinfo, $@)
	@$(call clean, $(OPENSSH_DIR)/config.cache)
	cd $(OPENSSH_DIR) && \
		$(OPENSSH_PATH) $(OPENSSH_ENV) \
		LDFLAGS="-ldl" ./configure $(OPENSSH_AUTOCONF)
	touch $@

# ----------------------------------------------------------------------------
# Compile
# ----------------------------------------------------------------------------

openssh_compile: $(STATEDIR)/openssh.compile

openssh_compile_deps = $(STATEDIR)/openssh.prepare

$(STATEDIR)/openssh.compile: $(openssh_compile_deps)
	@$(call targetinfo, $@)
	$(OPENSSH_PATH) $(MAKE) -C $(OPENSSH_DIR)
	touch $@

# ----------------------------------------------------------------------------
# Install
# ----------------------------------------------------------------------------

openssh_install: $(STATEDIR)/openssh.install

$(STATEDIR)/openssh.install: $(STATEDIR)/openssh.compile
	@$(call targetinfo, $@)
	$(OPENSSH_PATH) $(MAKE) -C $(OPENSSH_DIR) install
	touch $@

# ----------------------------------------------------------------------------
# Target-Install
# ----------------------------------------------------------------------------

openssh_targetinstall: $(STATEDIR)/openssh.targetinstall

openssh_targetinstall_deps = $(STATEDIR)/openssh.compile \
	$(STATEDIR)/zlib.targetinstall \
	$(STATEDIR)/openssl.targetinstall

$(STATEDIR)/openssh.targetinstall: $(openssh_targetinstall_deps)
	@$(call targetinfo, $@)
	install -m 644 -D $(OPENSSH_DIR)/ssh_config.out $(OPENSSH_IPKG_TMP)/etc/ssh/ssh_config
	install -m 755 -D $(OPENSSH_DIR)/ssh 		$(OPENSSH_IPKG_TMP)/usr/bin/ssh
	$(CROSSSTRIP) -R .notes -R .comment 		$(OPENSSH_IPKG_TMP)/usr/bin/ssh
	install -m 644 -D $(OPENSSH_DIR)/moduli.out 	$(OPENSSH_IPKG_TMP)/etc/ssh/moduli
	install -m 644 -D $(OPENSSH_DIR)/sshd_config.out $(OPENSSH_IPKG_TMP)/etc/ssh/sshd_config
	install -m 644 -D $(OPENSSH_DIR)/scard/Ssh.bin 	$(OPENSSH_IPKG_TMP)/usr/share/Ssh.bin
	install -m 755 -D $(OPENSSH_DIR)/sshd 		$(OPENSSH_IPKG_TMP)/usr/sbin/sshd
	$(CROSSSTRIP) -R .notes -R .comment 		$(OPENSSH_IPKG_TMP)/usr/sbin/sshd
	install -m 755 -D $(OPENSSH_DIR)/scp 		$(OPENSSH_IPKG_TMP)/usr/bin/scp
	$(CROSSSTRIP) -R .notes -R .comment 		$(OPENSSH_IPKG_TMP)/usr/bin/scp
	install -m 755 -D $(OPENSSH_DIR)/sftp-server 	$(OPENSSH_IPKG_TMP)/usr/sbin/sftp-server
	$(CROSSSTRIP) -R .notes -R .comment 		$(OPENSSH_IPKG_TMP)/usr/sbin/sftp-server
	install -m 755 -D $(OPENSSH_DIR)/ssh-keygen 	$(OPENSSH_IPKG_TMP)/usr/bin/ssh-keygen
	$(CROSSSTRIP) -R .notes -R .comment 		$(OPENSSH_IPKG_TMP)/usr/bin/ssh-keygen
	install -m 755 -D $(OPENSSH_DIR)/ssh-keyscan 	$(OPENSSH_IPKG_TMP)/usr/bin/ssh-keyscan
	$(CROSSSTRIP) -R .notes -R .comment 		$(OPENSSH_IPKG_TMP)/usr/bin/ssh-keyscan
	install -m 755 -D $(OPENSSH_DIR)/ssh-add 	$(OPENSSH_IPKG_TMP)/usr/bin/ssh-add
	$(CROSSSTRIP) -R .notes -R .comment 		$(OPENSSH_IPKG_TMP)/usr/bin/ssh-add
	install -m 755 -D $(OPENSSH_DIR)/ssh-agent 	$(OPENSSH_IPKG_TMP)/usr/bin/ssh-agent
	$(CROSSSTRIP) -R .notes -R .comment 		$(OPENSSH_IPKG_TMP)/usr/bin/ssh-agent
	install -m 755 -D $(OPENSSH_DIR)/sftp	 	$(OPENSSH_IPKG_TMP)/usr/bin/sftp
	$(CROSSSTRIP) -R .notes -R .comment 		$(OPENSSH_IPKG_TMP)/usr/bin/sftp
	ln -sf ssh 					$(OPENSSH_IPKG_TMP)/usr/bin/slogin
	install -d $(OPENSSH_IPKG_TMP)/var/empty
	mkdir -p $(OPENSSH_IPKG_TMP)/CONTROL
	echo "Package: openssh" 			>$(OPENSSH_IPKG_TMP)/CONTROL/control
	echo "Priority: optional" 			>>$(OPENSSH_IPKG_TMP)/CONTROL/control
	echo "Section: Utils"	 			>>$(OPENSSH_IPKG_TMP)/CONTROL/control
	echo "Maintainer: Alexander Chukov <sash@pdaXrom.org>" >>$(OPENSSH_IPKG_TMP)/CONTROL/control
	echo "Architecture: $(SHORT_TARGET)" 		>>$(OPENSSH_IPKG_TMP)/CONTROL/control
	echo "Version: $(OPENSSH_VERSION)" 		>>$(OPENSSH_IPKG_TMP)/CONTROL/control
	echo "Depends: openssl" 			>>$(OPENSSH_IPKG_TMP)/CONTROL/control
	echo "Description: generated with pdaXrom builder">>$(OPENSSH_IPKG_TMP)/CONTROL/control
	echo "#!/bin/sh" 				>$(OPENSSH_IPKG_TMP)/CONTROL/postinst
	echo "/etc/rc.d/init.d/ssh start" 		>>$(OPENSSH_IPKG_TMP)/CONTROL/postinst
	chmod 755 $(OPENSSH_IPKG_TMP)/CONTROL/postinst
	rm -rf    $(OPENSSH_IPKG_TMP)/usr/man
	$(INSTALL) -m 755 -D $(OPENSSH_DIR)/contrib/cacko/rc.ssh $(OPENSSH_IPKG_TMP)/etc/rc.d/init.d/ssh
	$(INSTALL) -m 644 $(TOPDIR)/config/pdaXrom/sshd_config $(OPENSSH_IPKG_TMP)/etc/ssh
	$(INSTALL) -d $(OPENSSH_IPKG_TMP)/etc/rc.d/rc3.d
	$(INSTALL) -d $(OPENSSH_IPKG_TMP)/etc/rc.d/rc4.d
	$(INSTALL) -d $(OPENSSH_IPKG_TMP)/etc/rc.d/rc5.d
	ln -sf ../init.d/ssh $(OPENSSH_IPKG_TMP)/etc/rc.d/rc5.d/S17ssh
	ln -sf ../init.d/ssh $(OPENSSH_IPKG_TMP)/etc/rc.d/rc4.d/S17ssh
	ln -sf ../init.d/ssh $(OPENSSH_IPKG_TMP)/etc/rc.d/rc3.d/S17ssh
	cd $(FEEDDIR) && $(XMKIPKG) $(OPENSSH_IPKG_TMP)
	touch $@

# ----------------------------------------------------------------------------
# Image-Install
# ----------------------------------------------------------------------------

ifdef PTXCONF_OPENSSH_INSTALL
ROMPACKAGES += $(STATEDIR)/openssh.imageinstall
endif

openssh_imageinstall_deps = $(STATEDIR)/openssh.targetinstall \
	$(STATEDIR)/virtual-image.install

$(STATEDIR)/openssh.imageinstall: $(openssh_imageinstall_deps)
	@$(call targetinfo, $@)
	cd $(FEEDDIR) && $(XIPKG) install openssh
	touch $@

# ----------------------------------------------------------------------------
# Clean
# ----------------------------------------------------------------------------

openssh_clean:
	rm -rf $(STATEDIR)/openssh.*
	rm -rf $(OPENSSH_DIR)

# vim: syntax=make
