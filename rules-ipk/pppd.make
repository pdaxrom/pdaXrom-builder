# -*-makefile-*-
# $Id: pppd.make,v 1.4 2003/10/23 15:01:19 mkl Exp $
#
# Copyright (C) 2003 by Marc Kleine-Budde <kleine-budde@gmx.de> for
#             GYRO net GmbH <info@gyro-net.de>, Hannover, Germany
# See CREDITS for details about who has contributed to this project. 
#
# For further information about the PTXdist project and license conditions
# see the README file.
#

#
# We provide this package
#
ifdef PTXCONF_PPP
PACKAGES += ppp
endif

#
# Paths and names 
#
PPP_VERSION	= 2.4.2
PPP		= ppp-$(PPP_VERSION)
PPP_URL		= ftp://ftp.samba.org/pub/ppp/$(PPP).tar.gz
PPP_SOURCE	= $(SRCDIR)/$(PPP).tar.gz
PPP_DIR		= $(BUILDDIR)/$(PPP)

# ----------------------------------------------------------------------------
# Get
# ----------------------------------------------------------------------------

ppp_get:	$(STATEDIR)/ppp.get

ppp_get_deps	= $(PPP_SOURCE)

$(STATEDIR)/ppp.get: $(ppp_get_deps)
	@$(call targetinfo, $@)
	@$(call get_patches, $(PPP))
	touch $@

$(PPP_SOURCE):
	@$(call targetinfo, $@)
	@$(call get, $(PPP_URL))

# ----------------------------------------------------------------------------
# Extract
# ----------------------------------------------------------------------------

ppp_extract: $(STATEDIR)/ppp.extract

$(STATEDIR)/ppp.extract: $(STATEDIR)/ppp.get
	@$(call targetinfo, $@)
	@$(call clean, $(PPP_DIR))
	@$(call extract, $(PPP_SOURCE))
	@$(call patchin, $(PPP))
	touch $@

# ----------------------------------------------------------------------------
# Prepare
# ----------------------------------------------------------------------------

ppp_prepare: $(STATEDIR)/ppp.prepare

PPP_PATH	= PATH=$(CROSS_PATH)
PPP_MAKEVARS	= CROSS=$(CROSS_ENV)

$(STATEDIR)/ppp.prepare: \
		$(STATEDIR)/virtual-xchain.install \
		$(STATEDIR)/ppp.extract
	@$(call targetinfo, $@)
	cd $(PPP_DIR) && \
		./configure
ifdef PTXCONF_PPP_MS_CHAP
	@$(call enable_sh,$(PPP_DIR)/pppd/Makefile,CHAPMS=y)
	@$(call enable_sh,$(PPP_DIR)/pppd/Makefile,USE_CRYPT=y)
else
	@$(call disable_sh,$(PPP_DIR)/pppd/Makefile,CHAPMS=y)
	@$(call disable_sh,$(PPP_DIR)/pppd/Makefile,USE_CRYPT=y)
endif

ifdef PTXCONF_PPP_SHADOW
	@$(call enable_sh,$(PPP_DIR)/pppd/Makefile,HAS_SHADOW=y)
else
	@$(call disable_sh,$(PPP_DIR)/pppd/Makefile,HAS_SHADOW=y)
endif

ifdef PTXCONF_PPP_PLUGINS
	@$(call enable_sh,$(PPP_DIR)/pppd/Makefile,PLUGIN=y)
else
	@$(call disable_sh,$(PPP_DIR)/pppd/Makefile,PLUGIN=y)
endif

ifdef PTXCONF_PPP_PCAP
	@$(call enable_sh,$(PPP_DIR)/pppd/Makefile,FILTER=y)
else
	@$(call disable_sh,$(PPP_DIR)/pppd/Makefile,FILTER=y)
endif

ifndef PTXCONF_PPP_IPX
	@perl -p -i -e 's/-DIPX_CHANGE //' $(PPP_DIR)/pppd/Makefile
	@perl -p -i -e 's/ipxcp.o //' $(PPP_DIR)/pppd/Makefile
endif

ifndef PTXCONF_PPP_MULTILINK
	@perl -p -i -e 's/-DHAVE_MULTILINK //' $(PPP_DIR)/pppd/Makefile
	@perl -p -i -e 's/multilink.o //' $(PPP_DIR)/pppd/Makefile
endif
	touch $@

# ----------------------------------------------------------------------------
# Compile
# ----------------------------------------------------------------------------

ppp_compile: $(STATEDIR)/ppp.compile

ppp_compile_deps =  $(STATEDIR)/ppp.prepare

$(STATEDIR)/ppp.compile: $(ppp_compile_deps) 
	@$(call targetinfo, $@)
	cd $(PPP_DIR) && \
		$(PPP_PATH) $(PPP_MAKEVARS) $(MAKE) $(PPP_MAKEVARS)
	touch $@

# ----------------------------------------------------------------------------
# Install
# ----------------------------------------------------------------------------

ppp_install: $(STATEDIR)/ppp.install

$(STATEDIR)/ppp.install: $(STATEDIR)/ppp.compile
	@$(call targetinfo, $@)
	touch $@

# ----------------------------------------------------------------------------
# Target-Install
# ----------------------------------------------------------------------------

ppp_targetinstall: $(STATEDIR)/ppp.targetinstall

$(STATEDIR)/ppp.targetinstall: $(STATEDIR)/ppp.compile
	@$(call targetinfo, $@)

	rm -rf $(PPP_DIR)/ipkg/
	mkdir -p $(PPP_DIR)/ipkg/usr/sbin
	install $(PPP_DIR)/pppd/pppd 		$(PPP_DIR)/ipkg/usr/sbin/
	$(CROSSSTRIP) -R .note -R .comment 	$(PPP_DIR)/ipkg/usr/sbin/pppd

	install $(PPP_DIR)/chat/chat 		$(PPP_DIR)/ipkg/usr/sbin/
	$(CROSSSTRIP) -R .note -R .comment 	$(PPP_DIR)/ipkg/usr/sbin/chat

	mkdir -p $(PPP_DIR)/ipkg/CONTROL
	echo "Package: ppp" 							 >$(PPP_DIR)/ipkg/CONTROL/control
	echo "Priority: optional" 						>>$(PPP_DIR)/ipkg/CONTROL/control
	echo "Section: Network" 						>>$(PPP_DIR)/ipkg/CONTROL/control
	echo "Maintainer: Alexander Chukov <sash@pdaXrom.org>" 			>>$(PPP_DIR)/ipkg/CONTROL/control
	echo "Architecture: $(SHORT_TARGET)" 					>>$(PPP_DIR)/ipkg/CONTROL/control
	echo "Version: $(PPP_VERSION)" 						>>$(PPP_DIR)/ipkg/CONTROL/control
	echo "Depends: " 							>>$(PPP_DIR)/ipkg/CONTROL/control
	echo "Description: Point-to-Point Protocol (PPP) daemon"		>>$(PPP_DIR)/ipkg/CONTROL/control
	cd $(FEEDDIR) && $(XMKIPKG) $(PPP_DIR)/ipkg

	rm -rf $(PPP_DIR)/ipkg/
	mkdir -p $(PPP_DIR)/ipkg/usr/bin
	install  $(PPP_DIR)/pppstats/pppstats 	$(PPP_DIR)/ipkg/usr/bin/
	$(CROSSSTRIP) -R .note -R .comment 	$(PPP_DIR)/ipkg/usr/bin/pppstats

	mkdir -p $(PPP_DIR)/ipkg/CONTROL
	echo "Package: pppstats" 						 >$(PPP_DIR)/ipkg/CONTROL/control
	echo "Priority: optional" 						>>$(PPP_DIR)/ipkg/CONTROL/control
	echo "Section: Network" 						>>$(PPP_DIR)/ipkg/CONTROL/control
	echo "Maintainer: Alexander Chukov <sash@pdaXrom.org>" 			>>$(PPP_DIR)/ipkg/CONTROL/control
	echo "Architecture: $(SHORT_TARGET)" 					>>$(PPP_DIR)/ipkg/CONTROL/control
	echo "Version: $(PPP_VERSION)" 						>>$(PPP_DIR)/ipkg/CONTROL/control
	echo "Depends: ppp" 							>>$(PPP_DIR)/ipkg/CONTROL/control
	echo "Description: print PPP statistics"				>>$(PPP_DIR)/ipkg/CONTROL/control
	cd $(FEEDDIR) && $(XMKIPKG) $(PPP_DIR)/ipkg

	touch $@

# ----------------------------------------------------------------------------
# Image-Install
# ----------------------------------------------------------------------------

ifdef PTXCONF_PPP_INSTALL
ROMPACKAGES += $(STATEDIR)/ppp.imageinstall
endif

ppp_imageinstall_deps = $(STATEDIR)/ppp.targetinstall \
	$(STATEDIR)/virtual-image.install

$(STATEDIR)/ppp.imageinstall: $(ppp_imageinstall_deps)
	@$(call targetinfo, $@)
	cd $(FEEDDIR) && $(XIPKG) install ppp
	touch $@

# ----------------------------------------------------------------------------
# Clean
# ----------------------------------------------------------------------------

ppp_clean: 
	-rm -rf $(STATEDIR)/ppp* 
	-rm -rf $(PPP_DIR) 

# vim: syntax=make