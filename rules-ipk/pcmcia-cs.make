# -*-makefile-*-
# $Id: pcmcia-cs.make,v 1.2 2003/10/23 15:01:19 mkl Exp $
#
# Copyright (C) 2003 by Robert Schwebel <r.schwebel@pengutronix.de>
#          
# See CREDITS for details about who has contributed to this project.
#
# For further information about the PTXdist project and license conditions
# see the README file.
#

#
# We provide this package
#
ifdef PTXCONF_PCMCIA-CS
PACKAGES += pcmcia-cs
endif

#
# Paths and names
#
#PCMCIA-CS_VERSION_VENDOR = -2
#PCMCIA-CS_VERSION	= 3.2.7
PCMCIA-CS_VERSION_VENDOR = -2
PCMCIA-CS_VERSION	= 3.2.8
PCMCIA-CS		= pcmcia-cs-$(PCMCIA-CS_VERSION)
PCMCIA-CS_SUFFIX	= tar.gz
PCMCIA-CS_URL		= http://pcmcia-cs.sourceforge.net/ftp/$(PCMCIA-CS).$(PCMCIA-CS_SUFFIX)
PCMCIA-CS_SOURCE	= $(SRCDIR)/$(PCMCIA-CS).$(PCMCIA-CS_SUFFIX)
PCMCIA-CS_DIR		= $(BUILDDIR)/$(PCMCIA-CS)

# ----------------------------------------------------------------------------
# Get
# ----------------------------------------------------------------------------

pcmcia-cs_get: $(STATEDIR)/pcmcia-cs.get

pcmcia-cs_get_deps	=  $(PCMCIA-CS_SOURCE)

$(STATEDIR)/pcmcia-cs.get: $(pcmcia-cs_get_deps)
	@$(call targetinfo, $@)
	@$(call get_patches, $(PCMCIA-CS))
	touch $@

$(PCMCIA-CS_SOURCE):
	@$(call targetinfo, $@)
	@$(call get, $(PCMCIA-CS_URL))

# ----------------------------------------------------------------------------
# Extract
# ----------------------------------------------------------------------------

pcmcia-cs_extract: $(STATEDIR)/pcmcia-cs.extract

pcmcia-cs_extract_deps	=  $(STATEDIR)/pcmcia-cs.get

$(STATEDIR)/pcmcia-cs.extract: $(pcmcia-cs_extract_deps)
	@$(call targetinfo, $@)
	@$(call clean, $(PCMCIA-CS_DIR))
	@$(call extract, $(PCMCIA-CS_SOURCE))
	@$(call patchin, $(PCMCIA-CS))
	touch $@

# ----------------------------------------------------------------------------
# Prepare
# ----------------------------------------------------------------------------

pcmcia-cs_prepare: $(STATEDIR)/pcmcia-cs.prepare

#
# dependencies
#
pcmcia-cs_prepare_deps =  \
	$(STATEDIR)/pcmcia-cs.extract \
	$(STATEDIR)/virtual-xchain.install

PCMCIA-CS_PATH	=  PATH=$(PTXCONF_PREFIX)/$(PTXCONF_GNU_TARGET)/bin:$(CROSS_PATH)
PCMCIA-CS_ENV 	=  $(CROSS_ENV)
#PCMCIA-CS_ENV	+=

$(STATEDIR)/pcmcia-cs.prepare: $(pcmcia-cs_prepare_deps)
	@$(call targetinfo, $@)
	@$(call clean, $(PCMCIA-CS_BUILDDIR))
ifdef PTXCONF_ARCH_ARM
ifdef PTXCONF_KERNEL_EXTERNAL_GCC
	cd $(PCMCIA-CS_DIR) && \
		    $(PCMCIA-CS_PATH) $(PCMCIA-CS_ENV) \
		    ./Configure --kernel=$(KERNEL_DIR) --noprompt --nocardbus \
		    --arch=arm --ucc=$(PTXCONF_KERNEL_EXTERNAL_GCC_PATH)/arm-linux-gcc \
		    --rcdir=/etc/rc.d --sysv --nopnp --kflags="-Os -D__KERNEL__ -DMODULE -march=armv4 -mtune=strongarm1100"
else
	cd $(PCMCIA-CS_DIR) && \
		    $(PCMCIA-CS_PATH) $(PCMCIA-CS_ENV) \
		    ./Configure --kernel=$(KERNEL_DIR) --noprompt --nocardbus \
		    --arch=arm --ucc=arm-linux-gcc \
		    --rcdir=/etc/rc.d --sysv --nopnp
endif
endif
ifdef PTXCONF_ARCH_X86
	cd $(PCMCIA-CS_DIR) && \
		    $(PCMCIA-CS_PATH) $(PCMCIA-CS_ENV) \
		    ./Configure --kernel=$(KERNEL_DIR) --noprompt \
		    --rcdir=/etc/rc.d --sysv
endif
	touch $@

# ----------------------------------------------------------------------------
# Compile
# ----------------------------------------------------------------------------

pcmcia-cs_compile: $(STATEDIR)/pcmcia-cs.compile

pcmcia-cs_compile_deps =  $(STATEDIR)/pcmcia-cs.prepare

$(STATEDIR)/pcmcia-cs.compile: $(pcmcia-cs_compile_deps)
	@$(call targetinfo, $@)
	$(PCMCIA-CS_PATH) $(PCMCIA-CS_ENV) $(MAKE) -C $(PCMCIA-CS_DIR) all
	$(PCMCIA-CS_PATH) $(PCMCIA-CS_ENV) $(MAKE) -C $(PCMCIA-CS_DIR)/wireless
	#$(PCMCIA-CS_PATH) $(PCMCIA-CS_ENV) $(MAKE) -C $(PCMCIA-CS_DIR)/clients \
	#    LD=$(PTXCONF_KERNEL_EXTERNAL_GCC_PATH)/arm-linux-ld \
	#    pcnet_cs.o 3c589_cs.o nmclan_cs.o fmvj18x_cs.o smc91c92_cs.o \
	#    xirc2ps_cs.o 3c574_cs.o axnet_cs.o 8390.o
	touch $@

# ----------------------------------------------------------------------------
# Install
# ----------------------------------------------------------------------------

pcmcia-cs_install: $(STATEDIR)/pcmcia-cs.install

$(STATEDIR)/pcmcia-cs.install: $(STATEDIR)/pcmcia-cs.compile
	@$(call targetinfo, $@)
	touch $@

# ----------------------------------------------------------------------------
# Target-Install
# ----------------------------------------------------------------------------

pcmcia-cs_targetinstall: $(STATEDIR)/pcmcia-cs.targetinstall

pcmcia-cs_targetinstall_deps	=  $(STATEDIR)/pcmcia-cs.compile

$(STATEDIR)/pcmcia-cs.targetinstall: $(pcmcia-cs_targetinstall_deps)
	@$(call targetinfo, $@)
	$(PCMCIA-CS_PATH) $(PCMCIA-CS_ENV) $(MAKE) -C $(PCMCIA-CS_DIR) DIRS="cardmgr flash" PREFIX=$(PCMCIA-CS_DIR)/ipkg_tmp HAS_XPM= install
	#$(PCMCIA-CS_PATH) $(PCMCIA-CS_ENV) $(MAKE) -C $(PCMCIA-CS_DIR)/clients \
	#    MODULES="pcnet_cs.o 3c589_cs.o nmclan_cs.o fmvj18x_cs.o smc91c92_cs.o xirc2ps_cs.o 3c574_cs.o axnet_cs.o" \
	#    PREFIX=$(PCMCIA-CS_DIR)/ipkg_tmp HAS_XPM= install
	$(CROSSSTRIP) -R .note -R .comment $(PCMCIA-CS_DIR)/ipkg_tmp/sbin/cardctl
	$(CROSSSTRIP) -R .note -R .comment $(PCMCIA-CS_DIR)/ipkg_tmp/sbin/cardmgr
	$(CROSSSTRIP) -R .note -R .comment $(PCMCIA-CS_DIR)/ipkg_tmp/sbin/ftl_check
	$(CROSSSTRIP) -R .note -R .comment $(PCMCIA-CS_DIR)/ipkg_tmp/sbin/ftl_format
	$(CROSSSTRIP) -R .note -R .comment $(PCMCIA-CS_DIR)/ipkg_tmp/sbin/ide_info
	$(CROSSSTRIP) -R .note -R .comment $(PCMCIA-CS_DIR)/ipkg_tmp/sbin/ifport
	$(CROSSSTRIP) -R .note -R .comment $(PCMCIA-CS_DIR)/ipkg_tmp/sbin/ifuser
	$(INSTALL) -m 755 -d $(PCMCIA-CS_DIR)/ipkg_tmp/etc/rc.d/init.d         $(PCMCIA-CS_DIR)/ipkg_tmp/etc/pcmcia/cis
	$(INSTALL) -m 755 -D $(PCMCIA-CS_DIR)/etc/rc.pcmcia     $(PCMCIA-CS_DIR)/ipkg_tmp/etc/rc.d/init.d/pcmcia
	$(INSTALL) -m 644 -D $(PCMCIA-CS_DIR)/etc/cis/*.dat     $(PCMCIA-CS_DIR)/ipkg_tmp/etc/pcmcia/cis
	$(INSTALL) -m 644 -D $(PCMCIA-CS_DIR)/etc/config        $(PCMCIA-CS_DIR)/ipkg_tmp/etc/pcmcia/config
	$(INSTALL) -m 644 -D $(PCMCIA-CS_DIR)/etc/config.opts   $(PCMCIA-CS_DIR)/ipkg_tmp/etc/pcmcia/config.opts
	$(INSTALL) -m 755 -D $(PCMCIA-CS_DIR)/etc/ftl           $(PCMCIA-CS_DIR)/ipkg_tmp/etc/pcmcia/ftl
	$(INSTALL) -m 644 -D $(PCMCIA-CS_DIR)/etc/ftl.opts      $(PCMCIA-CS_DIR)/ipkg_tmp/etc/pcmcia/ftl.opts
	$(INSTALL) -m 755 -D $(PCMCIA-CS_DIR)/etc/ide           $(PCMCIA-CS_DIR)/ipkg_tmp/etc/pcmcia/ide
	$(INSTALL) -m 644 -D $(PCMCIA-CS_DIR)/etc/ide.opts      $(PCMCIA-CS_DIR)/ipkg_tmp/etc/pcmcia/ide.opts
	$(INSTALL) -m 755 -D $(PCMCIA-CS_DIR)/etc/ieee1394      $(PCMCIA-CS_DIR)/ipkg_tmp/etc/pcmcia/ieee1394
	$(INSTALL) -m 644 -D $(PCMCIA-CS_DIR)/etc/ieee1394.opts $(PCMCIA-CS_DIR)/ipkg_tmp/etc/pcmcia/ieee1394.opts
	$(INSTALL) -m 755 -D $(PCMCIA-CS_DIR)/etc/memory        $(PCMCIA-CS_DIR)/ipkg_tmp/etc/pcmcia/memory
	$(INSTALL) -m 644 -D $(PCMCIA-CS_DIR)/etc/memory.opts   $(PCMCIA-CS_DIR)/ipkg_tmp/etc/pcmcia/memory.opts
	$(INSTALL) -m 755 -D $(PCMCIA-CS_DIR)/etc/parport       $(PCMCIA-CS_DIR)/ipkg_tmp/etc/pcmcia/parport
	$(INSTALL) -m 644 -D $(PCMCIA-CS_DIR)/etc/parport.opts  $(PCMCIA-CS_DIR)/ipkg_tmp/etc/pcmcia/parport.opts
	$(INSTALL) -m 755 -D $(PCMCIA-CS_DIR)/etc/scsi          $(PCMCIA-CS_DIR)/ipkg_tmp/etc/pcmcia/scsi
	$(INSTALL) -m 644 -D $(PCMCIA-CS_DIR)/etc/scsi.opts     $(PCMCIA-CS_DIR)/ipkg_tmp/etc/pcmcia/scsi.opts
	$(INSTALL) -m 755 -D $(PCMCIA-CS_DIR)/etc/serial        $(PCMCIA-CS_DIR)/ipkg_tmp/etc/pcmcia/serial
	$(INSTALL) -m 644 -D $(PCMCIA-CS_DIR)/etc/serial.opts   $(PCMCIA-CS_DIR)/ipkg_tmp/etc/pcmcia/serial.opts
	$(INSTALL) -m 644 -D $(PCMCIA-CS_DIR)/etc/shared        $(PCMCIA-CS_DIR)/ipkg_tmp/etc/pcmcia/shared
	$(INSTALL) -m 755 -D $(PCMCIA-CS_DIR)/etc/network       $(PCMCIA-CS_DIR)/ipkg_tmp/etc/pcmcia/network
	$(INSTALL) -m 644 -D $(PCMCIA-CS_DIR)/etc/network.opts  $(PCMCIA-CS_DIR)/ipkg_tmp/etc/pcmcia/network.opts
	$(INSTALL) -m 755 -D $(PCMCIA-CS_DIR)/etc/wireless      $(PCMCIA-CS_DIR)/ipkg_tmp/etc/pcmcia/wireless
	$(INSTALL) -m 644 -D $(PCMCIA-CS_DIR)/etc/wireless.opts $(PCMCIA-CS_DIR)/ipkg_tmp/etc/pcmcia/wireless.opts
	$(INSTALL) -m 644 -D $(PCMCIA-CS_DIR)/etc/hermes.conf  $(PCMCIA-CS_DIR)/ipkg_tmp/etc/pcmcia/hermes.conf
	$(INSTALL) -m 755 -D $(PCMCIA-CS_DIR)/etc/hermes        $(PCMCIA-CS_DIR)/ipkg_tmp/etc/pcmcia/hermes
	$(INSTALL) -m 755 -D $(PCMCIA-CS_DIR)/etc/hostap        $(PCMCIA-CS_DIR)/ipkg_tmp/etc/pcmcia/hostap
	$(INSTALL) -m 755 -D $(PCMCIA-CS_DIR)/etc/spectrum      $(PCMCIA-CS_DIR)/ipkg_tmp/etc/pcmcia/spectrum
	$(INSTALL) -m 644 -D $(PCMCIA-CS_DIR)/etc/spectrum.conf $(PCMCIA-CS_DIR)/ipkg_tmp/etc/pcmcia/spectrum.conf
	$(INSTALL) -d $(PCMCIA-CS_DIR)/ipkg_tmp/etc/rc.d/rc0.d
	$(INSTALL) -d $(PCMCIA-CS_DIR)/ipkg_tmp/etc/rc.d/rc1.d
	$(INSTALL) -d $(PCMCIA-CS_DIR)/ipkg_tmp/etc/rc.d/rc2.d
	$(INSTALL) -d $(PCMCIA-CS_DIR)/ipkg_tmp/etc/rc.d/rc3.d
	$(INSTALL) -d $(PCMCIA-CS_DIR)/ipkg_tmp/etc/rc.d/rc4.d
	$(INSTALL) -d $(PCMCIA-CS_DIR)/ipkg_tmp/etc/rc.d/rc5.d
	$(INSTALL) -d $(PCMCIA-CS_DIR)/ipkg_tmp/etc/rc.d/rc6.d
	cd $(PCMCIA-CS_DIR)/ipkg_tmp/etc/rc.d/rc0.d && ln -sf ../init.d/pcmcia K94pcmcia
	cd $(PCMCIA-CS_DIR)/ipkg_tmp/etc/rc.d/rc1.d && ln -sf ../init.d/pcmcia K94pcmcia
	cd $(PCMCIA-CS_DIR)/ipkg_tmp/etc/rc.d/rc3.d && ln -sf ../init.d/pcmcia S06pcmcia
	cd $(PCMCIA-CS_DIR)/ipkg_tmp/etc/rc.d/rc4.d && ln -sf ../init.d/pcmcia S06pcmcia
	cd $(PCMCIA-CS_DIR)/ipkg_tmp/etc/rc.d/rc5.d && ln -sf ../init.d/pcmcia S06pcmcia
	cd $(PCMCIA-CS_DIR)/ipkg_tmp/etc/rc.d/rc6.d && ln -sf ../init.d/pcmcia K94pcmcia
ifdef PTXCONF_KERNEL_RMK_PXA_EMBEDIX_SLC
	perl -p -i -e "s/ide-cs/ide_cs/g" $(PCMCIA-CS_DIR)/ipkg_tmp/etc/pcmcia/config
endif
ifdef PTXCONF_KERNEL_RMK_PXA_EMBEDIX_SL5500
	perl -p -i -e "s/ide-cs/ide_cs/g" $(PCMCIA-CS_DIR)/ipkg_tmp/etc/pcmcia/config
endif
	mkdir -p $(PCMCIA-CS_DIR)/ipkg_tmp/CONTROL
	echo "Package: pcmcia-cs" 						 >$(PCMCIA-CS_DIR)/ipkg_tmp/CONTROL/control
	echo "Priority: optional" 						>>$(PCMCIA-CS_DIR)/ipkg_tmp/CONTROL/control
	echo "Section: Utilities" 						>>$(PCMCIA-CS_DIR)/ipkg_tmp/CONTROL/control
	echo "Maintainer: Alexander Chukov <sash@pdaXrom.org>" 			>>$(PCMCIA-CS_DIR)/ipkg_tmp/CONTROL/control
	echo "Architecture: $(SHORT_TARGET)" 					>>$(PCMCIA-CS_DIR)/ipkg_tmp/CONTROL/control
	echo "Version: $(PCMCIA-CS_VERSION)$(PCMCIA-CS_VERSION_VENDOR)" 	>>$(PCMCIA-CS_DIR)/ipkg_tmp/CONTROL/control
	echo "Depends: " 							>>$(PCMCIA-CS_DIR)/ipkg_tmp/CONTROL/control
	echo "Description: Utilities and system configuration files for the Linux PCMCIA card services"	>>$(PCMCIA-CS_DIR)/ipkg_tmp/CONTROL/control
	cd $(FEEDDIR) && $(XMKIPKG) $(PCMCIA-CS_DIR)/ipkg_tmp
	touch $@

# ----------------------------------------------------------------------------
# Image-Install
# ----------------------------------------------------------------------------

ifdef PTXCONF_PCMCIA-CS_INSTALL
ROMPACKAGES += $(STATEDIR)/pcmcia-cs.imageinstall
endif

pcmcia-cs_imageinstall_deps = $(STATEDIR)/pcmcia-cs.targetinstall \
	$(STATEDIR)/virtual-image.install

$(STATEDIR)/pcmcia-cs.imageinstall: $(pcmcia-cs_imageinstall_deps)
	@$(call targetinfo, $@)
	cd $(FEEDDIR) && $(XIPKG) install pcmcia-cs
	touch $@

# ----------------------------------------------------------------------------
# Clean
# ----------------------------------------------------------------------------

pcmcia-cs_clean:
	rm -rf $(STATEDIR)/pcmcia-cs.*
	rm -rf $(PCMCIA-CS_DIR)

# vim: syntax=make
