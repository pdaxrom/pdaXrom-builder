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
ifdef PTXCONF_XSETTINGS-CLIENT
PACKAGES += Xsettings-client
endif

#
# Paths and names
#
XSETTINGS-CLIENT_VERSION	= 0.10
XSETTINGS-CLIENT		= Xsettings-client-$(XSETTINGS-CLIENT_VERSION)
XSETTINGS-CLIENT_SUFFIX		= tar.gz
XSETTINGS-CLIENT_URL		= http://handhelds.org/~mallum/downloadables/$(XSETTINGS-CLIENT).$(XSETTINGS-CLIENT_SUFFIX)
XSETTINGS-CLIENT_SOURCE		= $(SRCDIR)/$(XSETTINGS-CLIENT).$(XSETTINGS-CLIENT_SUFFIX)
XSETTINGS-CLIENT_DIR		= $(BUILDDIR)/$(XSETTINGS-CLIENT)
XSETTINGS-CLIENT_IPKG_TMP	= $(XSETTINGS-CLIENT_DIR)/ipkg_tmp

# ----------------------------------------------------------------------------
# Get
# ----------------------------------------------------------------------------

Xsettings-client_get: $(STATEDIR)/Xsettings-client.get

Xsettings-client_get_deps = $(XSETTINGS-CLIENT_SOURCE)

$(STATEDIR)/Xsettings-client.get: $(Xsettings-client_get_deps)
	@$(call targetinfo, $@)
	@$(call get_patches, $(XSETTINGS-CLIENT))
	touch $@

$(XSETTINGS-CLIENT_SOURCE):
	@$(call targetinfo, $@)
	@$(call get, $(XSETTINGS-CLIENT_URL))

# ----------------------------------------------------------------------------
# Extract
# ----------------------------------------------------------------------------

Xsettings-client_extract: $(STATEDIR)/Xsettings-client.extract

Xsettings-client_extract_deps = $(STATEDIR)/Xsettings-client.get

$(STATEDIR)/Xsettings-client.extract: $(Xsettings-client_extract_deps)
	@$(call targetinfo, $@)
	@$(call clean, $(XSETTINGS-CLIENT_DIR))
	@$(call extract, $(XSETTINGS-CLIENT_SOURCE))
	@$(call patchin, $(XSETTINGS-CLIENT))
	touch $@

# ----------------------------------------------------------------------------
# Prepare
# ----------------------------------------------------------------------------

Xsettings-client_prepare: $(STATEDIR)/Xsettings-client.prepare

#
# dependencies
#
Xsettings-client_prepare_deps = \
	$(STATEDIR)/Xsettings-client.extract \
	$(STATEDIR)/libpng125.install \
	$(STATEDIR)/zlib.install \
	$(STATEDIR)/jpeg.install \
	$(STATEDIR)/xfree430.install \
	$(STATEDIR)/virtual-xchain.install

XSETTINGS-CLIENT_PATH	=  PATH=$(CROSS_PATH)
XSETTINGS-CLIENT_ENV 	=  $(CROSS_ENV)
#XSETTINGS-CLIENT_ENV	+=

#
# autoconf
#
XSETTINGS-CLIENT_AUTOCONF = \
	--build=$(GNU_HOST) \
	--host=$(PTXCONF_GNU_TARGET) \
	--prefix=/usr \
	--x-includes=$(CROSS_LIB_DIR)/include \
	--x-libraries=$(CROSS_LIB_DIR)/lib
	#$(CROSS_LIB_DIR)

$(STATEDIR)/Xsettings-client.prepare: $(Xsettings-client_prepare_deps)
	@$(call targetinfo, $@)
	@$(call clean, $(XSETTINGS-CLIENT_DIR)/config.cache)
	cd $(XSETTINGS-CLIENT_DIR) && \
		$(XSETTINGS-CLIENT_PATH) $(XSETTINGS-CLIENT_ENV) \
		./configure $(XSETTINGS-CLIENT_AUTOCONF) \
			--disable-debug --enable-shared --disable-static
	touch $@

# ----------------------------------------------------------------------------
# Compile
# ----------------------------------------------------------------------------

Xsettings-client_compile: $(STATEDIR)/Xsettings-client.compile

Xsettings-client_compile_deps = $(STATEDIR)/Xsettings-client.prepare

$(STATEDIR)/Xsettings-client.compile: $(Xsettings-client_compile_deps)
	@$(call targetinfo, $@)
	$(XSETTINGS-CLIENT_PATH) $(MAKE) -C $(XSETTINGS-CLIENT_DIR) \
	    CFLAGS="-I$(CROSS_LIB_DIR)/include -O3 -fomit-frame-pointer" \
	    LDFLAGS=-L$(CROSS_LIB_DIR)/lib
	touch $@

# ----------------------------------------------------------------------------
# Install
# ----------------------------------------------------------------------------

Xsettings-client_install: $(STATEDIR)/Xsettings-client.install

$(STATEDIR)/Xsettings-client.install: $(STATEDIR)/Xsettings-client.compile
	@$(call targetinfo, $@)
	$(XSETTINGS-CLIENT_PATH) $(MAKE) -C $(XSETTINGS-CLIENT_DIR) install \
		prefix=$(PTXCONF_PREFIX)/$(PTXCONF_GNU_TARGET)
	perl -p -i -e "s/\/usr\/lib/`echo $(PTXCONF_PREFIX)/$(PTXCONF_GNU_TARGET)/lib | sed -e '/\//s//\\\\\//g'`/g" $(PTXCONF_PREFIX)/$(PTXCONF_GNU_TARGET)/lib/libXsettings-client.la
	touch $@

# ----------------------------------------------------------------------------
# Target-Install
# ----------------------------------------------------------------------------

Xsettings-client_targetinstall: $(STATEDIR)/Xsettings-client.targetinstall

Xsettings-client_targetinstall_deps = $(STATEDIR)/Xsettings-client.compile

$(STATEDIR)/Xsettings-client.targetinstall: $(Xsettings-client_targetinstall_deps)
	@$(call targetinfo, $@)
	mkdir -p $(XSETTINGS-CLIENT_IPKG_TMP)/usr/lib
	cp -af $(PTXCONF_PREFIX)/$(PTXCONF_GNU_TARGET)/lib/libXsettings-client.so* \
			    $(XSETTINGS-CLIENT_IPKG_TMP)/usr/lib
	$(CROSSSTRIP) $(XSETTINGS-CLIENT_IPKG_TMP)/usr/lib/libXsettings-client.so*
	mkdir -p $(XSETTINGS-CLIENT_IPKG_TMP)/CONTROL
	echo "Package: x11settings-client"			 >$(XSETTINGS-CLIENT_IPKG_TMP)/CONTROL/control
	echo "Priority: optional" 				>>$(XSETTINGS-CLIENT_IPKG_TMP)/CONTROL/control
	echo "Section: X11"	 				>>$(XSETTINGS-CLIENT_IPKG_TMP)/CONTROL/control
	echo "Maintainer: Alexander Chukov <sash@pdaXrom.org>"	>>$(XSETTINGS-CLIENT_IPKG_TMP)/CONTROL/control
	echo "Architecture: $(SHORT_TARGET)" 			>>$(XSETTINGS-CLIENT_IPKG_TMP)/CONTROL/control
	echo "Version: $(XSETTINGS-CLIENT_VERSION)" 		>>$(XSETTINGS-CLIENT_IPKG_TMP)/CONTROL/control
	echo "Depends: xfree430"		 		>>$(XSETTINGS-CLIENT_IPKG_TMP)/CONTROL/control
	echo "Description: X11 settings client library"		>>$(XSETTINGS-CLIENT_IPKG_TMP)/CONTROL/control
	cd $(FEEDDIR) && $(XMKIPKG) $(XSETTINGS-CLIENT_IPKG_TMP)

	touch $@

# ----------------------------------------------------------------------------
# Clean
# ----------------------------------------------------------------------------

Xsettings-client_clean:
	rm -rf $(STATEDIR)/Xsettings-client.*
	rm -rf $(XSETTINGS-CLIENT_DIR)

# vim: syntax=make
