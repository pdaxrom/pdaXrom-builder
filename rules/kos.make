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
ifdef PTXCONF_KOS
PACKAGES += kos
endif

#
# Paths and names
#
KOS_VERSION		= 20041113
KOS			= kos-snapshot-$(KOS_VERSION)
KOS-PORTS		= kos-ports-snapshot-$(KOS_VERSION)
KOS_SUFFIX		= tar.bz2
KOS_URL			= http://cadcdev.sourceforge.net/svn/snapshots/$(KOS).$(KOS_SUFFIX)
KOS-PORTS_URL		= http://cadcdev.sourceforge.net/svn/snapshots/$(KOS-PORTS).$(KOS_SUFFIX)
KOS_SOURCE		= $(SRCDIR)/$(KOS).$(KOS_SUFFIX)
KOS-PORTS_SOURCE	= $(SRCDIR)/$(KOS-PORTS).$(KOS_SUFFIX)
KOS_DIR			= $(BUILDDIR)/kos
KOS-PORTS_DIR		= $(BUILDDIR)/kos-ports

# ----------------------------------------------------------------------------
# Get
# ----------------------------------------------------------------------------

kos_get: $(STATEDIR)/kos.get

kos_get_deps = $(KOS_SOURCE)

$(STATEDIR)/kos.get: $(kos_get_deps)
	@$(call targetinfo, $@)
	@$(call get_patches, $(KOS))
	@$(call get_patches, $(KOS-PORTS))
	touch $@

$(KOS_SOURCE):
	@$(call targetinfo, $@)
	@$(call get, $(KOS_URL))
	@$(call get, $(KOS-PORTS_URL))

# ----------------------------------------------------------------------------
# Extract
# ----------------------------------------------------------------------------

kos_extract: $(STATEDIR)/kos.extract

kos_extract_deps = $(STATEDIR)/kos.get

$(STATEDIR)/kos.extract: $(kos_extract_deps)
	@$(call targetinfo, $@)
	@$(call clean,   $(KOS_DIR))
	@$(call extract, $(KOS_SOURCE))
	@$(call patchin, $(KOS), $(KOS_DIR))

	@$(call clean,   $(KOS-PORTS_DIR))
	@$(call extract, $(KOS-PORTS_SOURCE))
	@$(call patchin, $(KOS-PORTS), $(KOS-PORTS_DIR))
	touch $@

# ----------------------------------------------------------------------------
# Prepare
# ----------------------------------------------------------------------------

kos_prepare: $(STATEDIR)/kos.prepare

#
# dependencies
#
kos_prepare_deps = \
	$(STATEDIR)/kos.extract \
	$(STATEDIR)/newlib.install

KOS_PATH	=  PATH=$(CROSS_PATH):$(KOS_DIR)/utils/gnu_wrappers:$(KOS_DIR)/utils/genromfs
#KOS_ENV 	=  $(CROSS_ENV)
KOS_ENV		=

KOS_ENV		+= KOS_LIB_PATHS="-L$(KOS_DIR)/lib/$(PTXCONF_KOS_ARCH) -L$(KOS_DIR)/addons/lib/$(PTXCONF_KOS_ARCH)"
KOS_ENV		+= KOS_ARCH=$(PTXCONF_KOS_ARCH)
KOS_ENV		+= KOS_BASE="$(KOS_DIR)"
KOS_ENV		+= KOS_INC_PATHS="-I$(KOS_DIR)/include -I$(KOS_DIR)/kernel/arch/$(PTXCONF_KOS_ARCH)/include -I$(KOS_DIR)/addons/include"
KOS_ENV		+= KOS_INC_PATHS_CPP="-I$(KOS_DIR)/include -I$(KOS_DIR)/kernel/arch/$(PTXCONF_KOS_ARCH)/include -I$(KOS_DIR)/addons/include"
KOS_ENV		+= KOS_LIBS="-Wl,--start-group -lkallisti -lc -lgcc -Wl,--end-group"

ifdef PTXCONF_KOS_DREAMCAST
KOS_ENV		+= KOS_SUBARCH="pristine"

###KOS_ENV		+= KOS_CFLAGS	= "$(PTXCONF_KOS_CFLAGS) -ml -m4-single-only -fno-crossjumping"
###KOS_ENV		+= KOS_LDFLAGS	= "$(PTXCONF_KOS_LDFLAGS) -ml -m4-single-only -Wl,-Ttext=0x8c010000"

KOS_ENV		+= KOS_AFLAGS="$(PTXCONF_KOS_AFLAGS) -little"
KOS_ENV		+= KOS_CFLAGS="$(PTXCONF_KOS_CFLAGS) -I$(KOS_DIR)/include -I$(KOS_DIR)/kernel/arch/$(PTXCONF_KOS_ARCH)/include -I$(KOS_DIR)/addons/include \
		    -ml -m4-single-only -fno-crossjumping -D_arch_$(PTXCONF_KOS_ARCH) -D_arch_sub_$(KOS_SUBARCH) -Wall -g -fno-builtin -fno-strict-aliasing"
KOS_ENV		+= KOS_CPPFLAGS="$(PTXCONF_KOS_CPPFLAGS) -I$(KOS_DIR)/include -I$(KOS_DIR)/kernel/arch/$(PTXCONF_KOS_ARCH)/include -I$(KOS_DIR)/addons/include \
		    -fno-operator-names -fno-rtti -fno-exceptions"
KOS_ENV		+= KOS_LDFLAGS="$(PTXCONF_KOS_LDFLAGS) -ml -m4-single-only -Wl,-Ttext=0x8c010000 -nostartfiles -nostdlib \
		    -L$(KOS_DIR)/lib/$(PTXCONF_KOS_ARCH) -L$(KOS_DIR)/addons/lib/$(PTXCONF_KOS_ARCH)"


KOS_ENV		+= DC_ARM_CC="$(PTXCONF_KOS_ARM_TOOLS)gcc"
KOS_ENV		+= DC_ARM_AS="$(PTXCONF_KOS_ARM_TOOLS)as"
KOS_ENV		+= DC_ARM_AR="$(PTXCONF_KOS_ARM_TOOLS)ar"
KOS_ENV		+= DC_ARM_LD="$(PTXCONF_KOS_ARM_TOOLS)ld"
KOS_ENV		+= DC_ARM_OBJCOPY="$(PTXCONF_KOS_ARM_TOOLS)objcopy"

KOS_ENV		+= DC_ARM_CFLAGS="-mcpu=arm7 -Wall -O2"
KOS_ENV		+= DC_ARM_AFLAGS="-marm7"
endif

KOS_ENV		+= KOS_CC=$(PTXCONF_GNU_TARGET)-gcc
KOS_ENV		+= KOS_CCPLUS=$(PTXCONF_GNU_TARGET)-g++
KOS_ENV		+= KOS_AS=$(PTXCONF_GNU_TARGET)-as
KOS_ENV		+= KOS_AR=$(PTXCONF_GNU_TARGET)-ar
KOS_ENV		+= KOS_LD=$(PTXCONF_GNU_TARGET)-ld
KOS_ENV		+= KOS_OBJCOPY=$(PTXCONF_GNU_TARGET)-objcopy
KOS_ENV		+= KOS_RANLIB=$(PTXCONF_GNU_TARGET)-ranlib
KOS_ENV		+= KOS_STRIP=$(PTXCONF_GNU_TARGET)-strip
KOS_ENV		+= KOS_MAKE=$(MAKE)
KOS_ENV		+= KOS_GENROMFS=genromfs

#KOS_ENV		+= KOS_CFLAGS="$(KOS_CFLAGS) -D_arch_$(PTXCONF_KOS_ARCH) -D_arch_sub_$(KOS_SUBARCH) -Wall -g -fno-builtin -fno-strict-aliasing"
#KOS_ENV		+= KOS_CPPFLAGS="$(PTXCONF_KOS_CPPFLAGS) -fno-operator-names -fno-rtti -fno-exceptions"
#KOS_ENV		+= KOS_LDFLAGS="$(KOS_LDFLAGS) -nostartfiles -nostdlib $KOS_LIB_PATHS"

KOS_ENV		+= KOS_ARCH_DIR="$(KOS_DIR)/kernel/arch/$(PTXCONF_KOS_ARCH)"
KOS_ENV		+= KOS_START="$(KOS_DIR)/kernel/arch/$(PTXCONF_KOS_ARCH)/kernel/startup.o"

#
# autoconf
#
KOS_AUTOCONF = \
	--build=$(GNU_HOST) \
	--host=$(PTXCONF_GNU_TARGET) \
	--prefix=$(CROSS_LIB_DIR)

$(STATEDIR)/kos.prepare: $(kos_prepare_deps)
	@$(call targetinfo, $@)
	@$(call clean, $(KOS_DIR)/config.cache)
	cp -a $(KOS-PORTS_DIR)/* $(KOS_DIR)/addons/
	touch $@

# ----------------------------------------------------------------------------
# Compile
# ----------------------------------------------------------------------------

kos_compile: $(STATEDIR)/kos.compile

kos_compile_deps = $(STATEDIR)/kos.prepare

$(STATEDIR)/kos.compile: $(kos_compile_deps)
	@$(call targetinfo, $@)
	$(KOS_PATH) $(KOS_ENV) $(MAKE) -C $(KOS_DIR)
	touch $@

# ----------------------------------------------------------------------------
# Install
# ----------------------------------------------------------------------------

kos_install: $(STATEDIR)/kos.install

$(STATEDIR)/kos.install: $(STATEDIR)/kos.compile
	@$(call targetinfo, $@)
	###$(KOS_PATH) $(MAKE) -C $(KOS_DIR) install
	echo "#!/bin/bash"						 >$(PTXCONF_PREFIX)/kos_env.sh
	echo "echo 'Type exit for leave KOS environment.'"		>>$(PTXCONF_PREFIX)/kos_env.sh

	echo "export $(KOS_PATH)"					>>$(PTXCONF_PREFIX)/kos_env.sh

ifdef PTXCONF_KOS_DREAMCAST
	$(KOS_ENV) ;echo "export DC_ARM_CC=\"$$DC_ARM_CC\""			>>$(PTXCONF_PREFIX)/kos_env.sh
	$(KOS_ENV) ;echo "export DC_ARM_AS=\"$$DC_ARM_AS\""			>>$(PTXCONF_PREFIX)/kos_env.sh
	$(KOS_ENV) ;echo "export DC_ARM_AR=\"$$DC_ARM_AR\""			>>$(PTXCONF_PREFIX)/kos_env.sh
	$(KOS_ENV) ;echo "export DC_ARM_OBJCOPY=\"$$DC_ARM_OBJCOPY\""		>>$(PTXCONF_PREFIX)/kos_env.sh
	$(KOS_ENV) ;echo "export DC_ARM_LD=\"$$DC_ARM_LD\""			>>$(PTXCONF_PREFIX)/kos_env.sh
	$(KOS_ENV) ;echo "export DC_ARM_CFLAGS=\"$$DC_ARM_CFLAGS\""		>>$(PTXCONF_PREFIX)/kos_env.sh
	$(KOS_ENV) ;echo "export DC_ARM_AFLAGS=\"$$DC_ARM_AFLAGS\""		>>$(PTXCONF_PREFIX)/kos_env.sh
endif

	$(KOS_ENV) ;echo "export KOS_BASE=\"$$KOS_BASE\""			>>$(PTXCONF_PREFIX)/kos_env.sh
	$(KOS_ENV) ;echo "export KOS_ARCH=\"$$KOS_ARCH\""			>>$(PTXCONF_PREFIX)/kos_env.sh
	$(KOS_ENV) ;echo "export KOS_SUBARCH=\"$$KOS_SUBARCH\""			>>$(PTXCONF_PREFIX)/kos_env.sh
	$(KOS_ENV) ;echo "export KOS_LIB_PATHS=\"$$KOS_LIB_PATHS\""		>>$(PTXCONF_PREFIX)/kos_env.sh
	$(KOS_ENV) ;echo "export KOS_INC_PATHS=\"$$KOS_INC_PATHS\""		>>$(PTXCONF_PREFIX)/kos_env.sh
	$(KOS_ENV) ;echo "export KOS_INC_PATHS_CPP=\"$$KOS_INC_PATHS_CPP\""	>>$(PTXCONF_PREFIX)/kos_env.sh
	$(KOS_ENV) ;echo "export KOS_LIBS=\"$$KOS_LIBS\""			>>$(PTXCONF_PREFIX)/kos_env.sh
	$(KOS_ENV) ;echo "export KOS_START=\"$$KOS_START\""			>>$(PTXCONF_PREFIX)/kos_env.sh
	$(KOS_ENV) ;echo "export KOS_ARCH_DIR=\"$$KOS_ARCH_DIR\""		>>$(PTXCONF_PREFIX)/kos_env.sh

	$(KOS_ENV) ;echo "export KOS_CC=\"$$KOS_CC\""				>>$(PTXCONF_PREFIX)/kos_env.sh
	$(KOS_ENV) ;echo "export KOS_CCPLUS=\"$$KOS_CCPLUS\""			>>$(PTXCONF_PREFIX)/kos_env.sh
	$(KOS_ENV) ;echo "export KOS_AS=\"$$KOS_AS\""				>>$(PTXCONF_PREFIX)/kos_env.sh
	$(KOS_ENV) ;echo "export KOS_AR=\"$$KOS_AR\""				>>$(PTXCONF_PREFIX)/kos_env.sh
	$(KOS_ENV) ;echo "export KOS_LD=\"$$KOS_LD\""				>>$(PTXCONF_PREFIX)/kos_env.sh
	$(KOS_ENV) ;echo "export KOS_OBJCOPY=\"$$KOS_OBJCOPY\""			>>$(PTXCONF_PREFIX)/kos_env.sh
	$(KOS_ENV) ;echo "export KOS_RANLIB=\"$$KOS_RANLIB\""			>>$(PTXCONF_PREFIX)/kos_env.sh
	$(KOS_ENV) ;echo "export KOS_STRIP=\"$$KOS_STRIP\""			>>$(PTXCONF_PREFIX)/kos_env.sh
	$(KOS_ENV) ;echo "export KOS_MAKE=\"$$KOS_MAKE\""			>>$(PTXCONF_PREFIX)/kos_env.sh
	$(KOS_ENV) ;echo "export KOS_GENROMFS=\"$$KOS_GENROMFS\""		>>$(PTXCONF_PREFIX)/kos_env.sh

	$(KOS_ENV) ;echo "export KOS_CFLAGS=\"$$KOS_CFLAGS\""			>>$(PTXCONF_PREFIX)/kos_env.sh
	$(KOS_ENV) ;echo "export KOS_CPPFLAGS=\"$$KOS_CPPFLAGS\""		>>$(PTXCONF_PREFIX)/kos_env.sh
	$(KOS_ENV) ;echo "export KOS_AFLAGS=\"$$KOS_AFLAGS\""			>>$(PTXCONF_PREFIX)/kos_env.sh
	$(KOS_ENV) ;echo "export KOS_LDFLAGS=\"$$KOS_LDFLAGS\""			>>$(PTXCONF_PREFIX)/kos_env.sh

	echo "/bin/bash"							>>$(PTXCONF_PREFIX)/kos_env.sh
	chmod 755 $(PTXCONF_PREFIX)/kos_env.sh
	touch $@

# ----------------------------------------------------------------------------
# Target-Install
# ----------------------------------------------------------------------------

kos_targetinstall: $(STATEDIR)/kos.targetinstall

kos_targetinstall_deps = $(STATEDIR)/kos.compile

$(STATEDIR)/kos.targetinstall: $(kos_targetinstall_deps)
	@$(call targetinfo, $@)
	touch $@

# ----------------------------------------------------------------------------
# Clean
# ----------------------------------------------------------------------------

kos_clean:
	rm -rf $(STATEDIR)/kos.*
	rm -rf $(KOS_DIR)

# vim: syntax=make
