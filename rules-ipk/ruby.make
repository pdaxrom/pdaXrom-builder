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
ifdef PTXCONF_RUBY
PACKAGES += ruby
endif

#
# Paths and names
#
RUBY_VERSION	= 1.8.1
RUBY		= ruby-$(RUBY_VERSION)
RUBY_SUFFIX	= tar.gz
RUBY_URL	= ftp://ftp.ruby-lang.org/pub/ruby/$(RUBY).$(RUBY_SUFFIX)
RUBY_SOURCE	= $(SRCDIR)/$(RUBY).$(RUBY_SUFFIX)
RUBY_DIR	= $(BUILDDIR)/$(RUBY)
RUBY_IPKG_TMP	= $(RUBY_DIR)/ipkg_tmp

# ----------------------------------------------------------------------------
# Get
# ----------------------------------------------------------------------------

ruby_get: $(STATEDIR)/ruby.get

ruby_get_deps = $(RUBY_SOURCE)

$(STATEDIR)/ruby.get: $(ruby_get_deps)
	@$(call targetinfo, $@)
	@$(call get_patches, $(RUBY))
	touch $@

$(RUBY_SOURCE):
	@$(call targetinfo, $@)
	@$(call get, $(RUBY_URL))

# ----------------------------------------------------------------------------
# Extract
# ----------------------------------------------------------------------------

ruby_extract: $(STATEDIR)/ruby.extract

ruby_extract_deps = $(STATEDIR)/ruby.get

$(STATEDIR)/ruby.extract: $(ruby_extract_deps)
	@$(call targetinfo, $@)
	@$(call clean, $(RUBY_DIR))
	@$(call extract, $(RUBY_SOURCE))
	@$(call patchin, $(RUBY))
	touch $@

# ----------------------------------------------------------------------------
# Prepare
# ----------------------------------------------------------------------------

ruby_prepare: $(STATEDIR)/ruby.prepare

#
# dependencies
#
ruby_prepare_deps = \
	$(STATEDIR)/ruby.extract \
	$(STATEDIR)/virtual-xchain.install

RUBY_PATH	=  PATH=$(CROSS_PATH)
RUBY_ENV 	=  $(CROSS_ENV)
#RUBY_ENV	+=
RUBY_ENV	+= PKG_CONFIG_PATH=$(CROSS_LIB_DIR)/lib/pkgconfig:$(CROSS_LIB_DIR)/lib/pkgconfig
#ifdef PTXCONF_XFREE430
#RUBY_ENV	+= LDFLAGS=-Wl,-rpath-link,$(CROSS_LIB_DIR)/lib
#endif

#
# autoconf
#
RUBY_AUTOCONF = \
	--build=$(GNU_HOST) \
	--host=$(PTXCONF_GNU_TARGET) \
	--prefix=/usr

ifdef PTXCONF_XFREE430
RUBY_AUTOCONF += --x-includes=$(CROSS_LIB_DIR)/include
RUBY_AUTOCONF += --x-libraries=$(CROSS_LIB_DIR)/lib
endif

$(STATEDIR)/ruby.prepare: $(ruby_prepare_deps)
	@$(call targetinfo, $@)
	@$(call clean, $(RUBY_DIR)/config.cache)
	cd $(RUBY_DIR) && \
		$(RUBY_PATH) $(RUBY_ENV) \
		./configure $(RUBY_AUTOCONF)
	touch $@

# ----------------------------------------------------------------------------
# Compile
# ----------------------------------------------------------------------------

ruby_compile: $(STATEDIR)/ruby.compile

ruby_compile_deps = $(STATEDIR)/ruby.prepare

$(STATEDIR)/ruby.compile: $(ruby_compile_deps)
	@$(call targetinfo, $@)
	$(RUBY_PATH) $(MAKE) -C $(RUBY_DIR)
	touch $@

# ----------------------------------------------------------------------------
# Install
# ----------------------------------------------------------------------------

ruby_install: $(STATEDIR)/ruby.install

$(STATEDIR)/ruby.install: $(STATEDIR)/ruby.compile
	@$(call targetinfo, $@)
	###$(RUBY_PATH) $(MAKE) -C $(RUBY_DIR) install
	asdasd
	touch $@

# ----------------------------------------------------------------------------
# Target-Install
# ----------------------------------------------------------------------------

ruby_targetinstall: $(STATEDIR)/ruby.targetinstall

ruby_targetinstall_deps = $(STATEDIR)/ruby.compile

$(STATEDIR)/ruby.targetinstall: $(ruby_targetinstall_deps)
	@$(call targetinfo, $@)
	$(RUBY_PATH) $(MAKE) -C $(RUBY_DIR) DESTDIR=$(RUBY_IPKG_TMP) install
	mkdir -p $(RUBY_IPKG_TMP)/CONTROL
	echo "Package: ruby" 				>$(RUBY_IPKG_TMP)/CONTROL/control
	echo "Priority: optional" 			>>$(RUBY_IPKG_TMP)/CONTROL/control
	echo "Section: Development" 			>>$(RUBY_IPKG_TMP)/CONTROL/control
	echo "Maintainer: Alexander Chukov <sash@pdaXrom.org>">>$(RUBY_IPKG_TMP)/CONTROL/control
	echo "Architecture: $(SHORT_TARGET)" 		>>$(RUBY_IPKG_TMP)/CONTROL/control
	echo "Version: $(RUBY_VERSION)" 		>>$(RUBY_IPKG_TMP)/CONTROL/control
	echo "Depends: " 				>>$(RUBY_IPKG_TMP)/CONTROL/control
	echo "Description: ">>$(RUBY_IPKG_TMP)/CONTROL/control
	asdads
	cd $(FEEDDIR) && $(XMKIPKG) $(RUBY_IPKG_TMP)
	touch $@

# ----------------------------------------------------------------------------
# Clean
# ----------------------------------------------------------------------------

ruby_clean:
	rm -rf $(STATEDIR)/ruby.*
	rm -rf $(RUBY_DIR)

# vim: syntax=make
