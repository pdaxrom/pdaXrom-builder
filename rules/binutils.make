# -*-makefile-*-
# $Id: binutils.make,v 1.6 2003/11/20 10:09:39 robert Exp $
#
# Copyright (C) 2002, 2003 by Pengutronix e.K., Hildesheim, Germany
# See CREDITS for details about who has contributed to this project. 
#
# For further information about the PTXdist project and license conditions
# see the README file.
#

ifdef PTXCONF_LIBBFD
PACKAGES += binutils
endif

#
# Paths and names 
#
ifdef PTXCONF_BINUTILS_2_15_91_0_2
  BINUTILS		= binutils-2.15.91.0.2
  BINUTILS_URL		= http://ftp.kernel.org/pub/linux/devel/binutils/$(BINUTILS).tar.bz2
  BINUTILSX_VERSION	= 2.15.91.0.2
else
  BINUTILS		= binutils-$(BINUTILS_VERSION)
  BINUTILS_URL		= http://ftp.gnu.org/gnu/binutils/$(BINUTILS).tar.bz2
  BINUTILSX_VERSION	= $(BINUTILS_VERSION)
endif

BINUTILS_SOURCE		= $(SRCDIR)/$(BINUTILS).tar.bz2
BINUTILS_DIR		= $(BUILDDIR)/$(BINUTILS)
BINUTILS_BUILDDIR	= $(BINUTILS_DIR)-build

# ----------------------------------------------------------------------------
# Get
# ----------------------------------------------------------------------------

binutils_get: $(STATEDIR)/binutils.get

binutils_get_deps = \
	$(BINUTILS_SOURCE) \
	$(STATEDIR)/binutils-patches.get

$(STATEDIR)/binutils.get: $(binutils_get_deps)
	@$(call targetinfo, $@)
	touch $@

$(STATEDIR)/binutils-patches.get:
	@$(call targetinfo, $@)
	@$(call get_patches, $(BINUTILS))
	touch $@

$(BINUTILS_SOURCE):
	@$(call targetinfo, $@)
	@$(call get, $(BINUTILS_URL))

# ----------------------------------------------------------------------------
# Extract
# ----------------------------------------------------------------------------

binutils_extract: $(STATEDIR)/binutils.extract

$(STATEDIR)/binutils.extract: $(STATEDIR)/binutils.get
	@$(call targetinfo, $@)
	@$(call clean, $(BINUTILS_DIR))
	@$(call extract, $(BINUTILS_SOURCE))
	@$(call patchin, $(BINUTILS))
	touch $@

# ----------------------------------------------------------------------------
# Prepare
# ----------------------------------------------------------------------------

binutils_prepare: $(STATEDIR)/binutils.prepare

binutils_prepare_deps = \
	$(STATEDIR)/virtual-xchain.install \
	$(STATEDIR)/binutils.extract

BINUTILS_AUTOCONF = \
	--target=$(PTXCONF_GNU_TARGET) \
	--host=$(PTXCONF_GNU_TARGET) \
	--build=$(GNU_HOST) \
	--enable-targets=$(PTXCONF_GNU_TARGET) \
	--prefix=/usr \
	--disable-nls \
	--enable-shared \
	--enable-commonbfdlib \
	--enable-install-libiberty \
	--disable-multilib

BINUTILS_ENV	= $(CROSS_ENV)
BINUTILS_PATH	= PATH=$(CROSS_PATH)

$(STATEDIR)/binutils.prepare: $(binutils_prepare_deps)
	@$(call targetinfo, $@)
	@$(call clean, $(BINUTILS_BUILDDIR))
	mkdir -p $(BINUTILS_BUILDDIR)
	cd $(BINUTILS_BUILDDIR) && $(BINUTILS_PATH) $(BINUTILS_ENV) \
		$(BINUTILS_DIR)/configure $(BINUTILS_AUTOCONF)
	touch $@

# ----------------------------------------------------------------------------
# Compile
# ----------------------------------------------------------------------------

binutils_compile: $(STATEDIR)/binutils.compile

$(STATEDIR)/binutils.compile: $(STATEDIR)/binutils.prepare 
	@$(call targetinfo, $@)
#
# the libiberty part is compiled for the host system
#
# don't pass target CFLAGS to it, so override them and call the configure script
#
	$(BINUTILS_PATH) $(MAKE) -C $(BINUTILS_BUILDDIR) CFLAGS='' CXXFLAGS='' configure-build-libiberty

#
# the chew tool is needed later during installation, compile it now
# else it will fail cause it gets target CFLAGS
#
	$(BINUTILS_PATH) $(MAKE) -C $(BINUTILS_BUILDDIR)/bfd/doc CFLAGS='' CXXFLAGS='' chew

#
# now do the _real_ compiling :-)
#
	$(BINUTILS_PATH) $(MAKE) -C $(BINUTILS_BUILDDIR)

	touch $@

# ----------------------------------------------------------------------------
# Install
# ----------------------------------------------------------------------------

binutils_install: $(STATEDIR)/binutils.install

$(STATEDIR)/binutils.install: $(STATEDIR)/binutils.compile
	@$(call targetinfo, $@)
	$(BINUTILS_PATH) $(MAKE) -C $(BINUTILS_BUILDDIR)/bfd DESTDIR=$(CROSS_LIB_DIR) prefix='' install 
	touch $@

# ----------------------------------------------------------------------------
# Target-Install
# ----------------------------------------------------------------------------

binutils_targetinstall: $(STATEDIR)/binutils.targetinstall

$(STATEDIR)/binutils.targetinstall: $(STATEDIR)/binutils.install
	@$(call targetinfo, $@)
	install -d $(ROOTDIR)/usr/lib
	cp -d $(BINUTILS_BUILDDIR)/bfd/.libs/libbfd*.so $(ROOTDIR)/usr/lib
	touch $@

# ----------------------------------------------------------------------------
# Clean
# ----------------------------------------------------------------------------

binutils_clean: 
	rm -rf $(STATEDIR)/binutils-* $(BINUTILS_DIR)

# vim: syntax=make
