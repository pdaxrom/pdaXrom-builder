# -*-makefile-*-
# $Id: template,v 1.10 2003/10/26 21:59:07 mkl Exp $
#
# Copyright (C) 2003 by Alexander Chukov
#          
# See CREDITS for details about who has contributed to this project.
#
# For further information about the PTXdist project and license conditions
# see the README file.
#

#
# We provide this package
#
ifdef PTXCONF_INITSCRIPTS
PACKAGES += popt initscripts
endif

#
# Paths and names
#
INITSCRIPTS_VERSION	= 6.40-1
INITSCRIPTS		= initscripts-$(INITSCRIPTS_VERSION)
INITSCRIPTS_SUFFIX	= tar.gz
INITSCRIPTS_URL		= http://www.zaurus.com/dev/tools/downloads/commands//$(INITSCRIPTS).$(INITSCRIPTS_SUFFIX)
INITSCRIPTS_SOURCE	= $(SRCDIR)/$(INITSCRIPTS).$(INITSCRIPTS_SUFFIX)
INITSCRIPTS_DIR		= $(BUILDDIR)/$(INITSCRIPTS)/src

# ----------------------------------------------------------------------------
# Get
# ----------------------------------------------------------------------------

initscripts_get: $(STATEDIR)/initscripts.get

initscripts_get_deps = $(INITSCRIPTS_SOURCE)

$(STATEDIR)/initscripts.get: $(initscripts_get_deps)
	@$(call targetinfo, $@)
	@$(call get_patches, $(INITSCRIPTS))
	touch $@

$(INITSCRIPTS_SOURCE):
	@$(call targetinfo, $@)
	@$(call get, $(INITSCRIPTS_URL))

# ----------------------------------------------------------------------------
# Extract
# ----------------------------------------------------------------------------

initscripts_extract: $(STATEDIR)/initscripts.extract

initscripts_extract_deps = $(STATEDIR)/initscripts.get

$(STATEDIR)/initscripts.extract: $(initscripts_extract_deps)
	@$(call targetinfo, $@)
	@$(call clean, $(INITSCRIPTS_DIR))
	@$(call extract, $(INITSCRIPTS_SOURCE))
	@$(call patchin, $(INITSCRIPTS))
	touch $@

# ----------------------------------------------------------------------------
# Prepare
# ----------------------------------------------------------------------------

initscripts_prepare: $(STATEDIR)/initscripts.prepare

#
# dependencies
#
initscripts_prepare_deps = \
	$(STATEDIR)/initscripts.extract \
	$(STATEDIR)/virtual-xchain.install

INITSCRIPTS_PATH	=  PATH=$(CROSS_PATH)
INITSCRIPTS_ENV 	=  $(CROSS_ENV)
#INITSCRIPTS_ENV	+=

#
# autoconf
#
INITSCRIPTS_AUTOCONF = \
	--build=$(GNU_HOST) \
	--host=$(PTXCONF_GNU_TARGET) \
	--prefix=$(CROSS_LIB_DIR)

$(STATEDIR)/initscripts.prepare: $(initscripts_prepare_deps)
	@$(call targetinfo, $@)
	@$(call clean, $(INITSCRIPTS_DIR)/config.cache)
	touch $@

# ----------------------------------------------------------------------------
# Compile
# ----------------------------------------------------------------------------

ifdef PTXCONF_ARM_ARCH_PXA
 NEW_CFLAGS=CFLAGS="-O2 -fomit-frame-pointer -Wall -D_GNU_SOURCE -mcpu=xscale -mtune=xscale"
else
 ifdef PTXCONF_ARM_ARCH_ARM7500FE
  NEW_CFLAGS=CFLAGS="-O2 -Wall -D_GNU_SOURCE -mcpu=arm7500fe -mtune=arm7500fe -mshort-load-bytes"
 else
   ifdef PTXCONF_ARM_ARCH_ARM7
    NEW_CFLAGS=CFLAGS="-O2 -Wall -D_GNU_SOURCE -mcpu=arm7 -mtune=arm7 -mshort-load-bytes"
   else
    ifdef PTXCONF_ARM_ARCH_LE
      NEW_CFLAGS=CFLAGS="-O2 -Wall -D_GNU_SOURCE -mcpu=strongarm -mtune=strongarm -mshort-load-bytes"
    else
      NEW_CFLAGS=CFLAGS="-Wall -D_GNU_SOURCE -g"
    endif    
   endif
 endif
endif

initscripts_compile: $(STATEDIR)/initscripts.compile

initscripts_compile_deps = $(STATEDIR)/initscripts.prepare

$(STATEDIR)/initscripts.compile: $(initscripts_compile_deps)
	@$(call targetinfo, $@)
ifdef PTXCONF_INITSCRIPTS_INITLOG
	$(INITSCRIPTS_PATH) $(CROSS_ENV) $(MAKE) -C $(INITSCRIPTS_DIR) initlog $(NEW_CFLAGS)
endif
ifdef PTXCONF_INITSCRIPTS_USLEEP
	$(INITSCRIPTS_PATH) $(CROSS_ENV) $(MAKE) -C $(INITSCRIPTS_DIR) usleep $(NEW_CFLAGS)
endif
	touch $@

# ----------------------------------------------------------------------------
# Install
# ----------------------------------------------------------------------------

initscripts_install: $(STATEDIR)/initscripts.install

$(STATEDIR)/initscripts.install: $(STATEDIR)/initscripts.compile
	@$(call targetinfo, $@)
	touch $@

# ----------------------------------------------------------------------------
# Target-Install
# ----------------------------------------------------------------------------

initscripts_targetinstall: $(STATEDIR)/initscripts.targetinstall

initscripts_targetinstall_deps = $(STATEDIR)/initscripts.compile

$(STATEDIR)/initscripts.targetinstall: $(initscripts_targetinstall_deps)
	@$(call targetinfo, $@)
ifdef PTXCONF_INITSCRIPTS_INITLOG
	#$(INSTALL) -m 644 -D $(INITSCRIPTS_DIR)/initlog.conf $(INITSCRIPTS_DIR)/ipkg/etc/initlog.conf
	$(INSTALL) -m 755 -D $(INITSCRIPTS_DIR)/initlog $(INITSCRIPTS_DIR)/ipkg/sbin/initlog
	$(CROSSSTRIP) -R .note -R .comment $(INITSCRIPTS_DIR)/ipkg/sbin/initlog
endif
ifdef PTXCONF_INITSCRIPTS_USLEEP
	$(INSTALL) -m 755 -D $(INITSCRIPTS_DIR)/usleep $(INITSCRIPTS_DIR)/ipkg/bin/usleep
	$(CROSSSTRIP) -R .note -R .comment $(INITSCRIPTS_DIR)/ipkg/bin/usleep
endif
	mkdir -p $(INITSCRIPTS_DIR)/ipkg/CONTROL
	echo "Package: initscripts" 						 >$(INITSCRIPTS_DIR)/ipkg/CONTROL/control
	echo "Priority: optional" 						>>$(INITSCRIPTS_DIR)/ipkg/CONTROL/control
	echo "Section: Utilities" 						>>$(INITSCRIPTS_DIR)/ipkg/CONTROL/control
	echo "Maintainer: Alexander Chukov <sash@pdaXrom.org>" 			>>$(INITSCRIPTS_DIR)/ipkg/CONTROL/control
	echo "Architecture: $(SHORT_TARGET)" 					>>$(INITSCRIPTS_DIR)/ipkg/CONTROL/control
	echo "Version: $(INITSCRIPTS_VERSION)" 					>>$(INITSCRIPTS_DIR)/ipkg/CONTROL/control
	echo "Depends: popt" 							>>$(INITSCRIPTS_DIR)/ipkg/CONTROL/control
	echo "Description: SysV init scripts"					>>$(INITSCRIPTS_DIR)/ipkg/CONTROL/control
	cd $(FEEDDIR) && $(XMKIPKG) $(INITSCRIPTS_DIR)/ipkg
	touch $@

# ----------------------------------------------------------------------------
# Image-Install
# ----------------------------------------------------------------------------

ifdef PTXCONF_INITSCRIPTS_INSTALL
ROMPACKAGES += $(STATEDIR)/initscripts.imageinstall
endif

initscripts_imageinstall_deps = $(STATEDIR)/initscripts.targetinstall \
	$(STATEDIR)/virtual-image.install

$(STATEDIR)/initscripts.imageinstall: $(initscripts_imageinstall_deps)
	@$(call targetinfo, $@)
	cd $(FEEDDIR) && $(XIPKG) install initscripts
	touch $@

# ----------------------------------------------------------------------------
# Clean
# ----------------------------------------------------------------------------

initscripts_clean:
	rm -rf $(STATEDIR)/initscripts.*
	rm -rf $(INITSCRIPTS_DIR)

# vim: syntax=make
