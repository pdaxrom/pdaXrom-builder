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
ifdef PTXCONF_XCHAIN-LIBTOOL
PACKAGES += xchain-libtool
endif

#
# Paths and names
#
XCHAIN_LIBTOOL_VERSION		= 1.5
XCHAIN_LIBTOOL			= libtool-$(XCHAIN_LIBTOOL_VERSION)
XCHAIN_LIBTOOL_SUFFIX		= tar.gz
XCHAIN_LIBTOOL_URL		= http://ftp.club.cc.cmu.edu/pub/gnu/libtool/$(XCHAIN_LIBTOOL).$(XCHAIN_LIBTOOL_SUFFIX)
XCHAIN_LIBTOOL_SOURCE		= $(SRCDIR)/$(XCHAIN_LIBTOOL).$(XCHAIN_LIBTOOL_SUFFIX)
XCHAIN_LIBTOOL_DIR		= $(XCHAIN_BUILDDIR)/$(XCHAIN_LIBTOOL)

# ----------------------------------------------------------------------------
# Get
# ----------------------------------------------------------------------------

xchain-libtool_get: $(STATEDIR)/xchain-libtool.get

xchain-libtool_get_deps = $(XCHAIN_LIBTOOL_SOURCE)

$(STATEDIR)/xchain-libtool.get: $(xchain-libtool_get_deps)
	@$(call targetinfo, $@)
	@$(call get_patches, $(XCHAIN_LIBTOOL))
	touch $@

$(XCHAIN_LIBTOOL_SOURCE):
	@$(call targetinfo, $@)
	@$(call get, $(XCHAIN_LIBTOOL_URL))

# ----------------------------------------------------------------------------
# Extract
# ----------------------------------------------------------------------------

xchain-libtool_extract: $(STATEDIR)/xchain-libtool.extract

xchain-libtool_extract_deps = $(STATEDIR)/xchain-libtool.get

$(STATEDIR)/xchain-libtool.extract: $(xchain-libtool_extract_deps)
	@$(call targetinfo, $@)
	@$(call clean, $(XCHAIN_LIBTOOL_DIR))
	@$(call extract, $(XCHAIN_LIBTOOL_SOURCE), $(XCHAIN_BUILDDIR))
	@$(call patchin, $(XCHAIN_LIBTOOL), $(XCHAIN_LIBTOOL_DIR))
	touch $@

# ----------------------------------------------------------------------------
# Prepare
# ----------------------------------------------------------------------------

xchain-libtool_prepare: $(STATEDIR)/xchain-libtool.prepare

#
# dependencies
#
xchain-libtool_prepare_deps = \
	$(STATEDIR)/xchain-libtool.extract

XCHAIN_LIBTOOL_PATH	=  PATH=$(CROSS_PATH)
XCHAIN_LIBTOOL_ENV 	=  $(HOSTCC_ENV)
#XCHAIN_LIBTOOL_ENV	+=

#
# autoconf
#
XCHAIN_LIBTOOL_AUTOCONF = \
	--prefix=$(PTXCONF_PREFIX) \
	--build=$(GNU_HOST) \
 	--host=$(PTXCONF_GNU_TARGET) \
 	--target=$(PTXCONF_GNU_TARGET)

$(STATEDIR)/xchain-libtool.prepare: $(xchain-libtool_prepare_deps)
	@$(call targetinfo, $@)
	@$(call clean, $(XCHAIN_LIBTOOL_DIR)/config.cache)
	cd $(XCHAIN_LIBTOOL_DIR) && \
		$(XCHAIN_LIBTOOL_PATH) \
		./configure $(XCHAIN_LIBTOOL_AUTOCONF) --disable-ltdl-install
	touch $@

# ----------------------------------------------------------------------------
# Compile
# ----------------------------------------------------------------------------

xchain-libtool_compile: $(STATEDIR)/xchain-libtool.compile

xchain-libtool_compile_deps = $(STATEDIR)/xchain-libtool.prepare

$(STATEDIR)/xchain-libtool.compile: $(xchain-libtool_compile_deps)
	@$(call targetinfo, $@)
	$(XCHAIN_LIBTOOL_PATH) $(MAKE) -C $(XCHAIN_LIBTOOL_DIR)
	#mv $(XCHAIN_LIBTOOL_DIR)/libtool    $(XCHAIN_LIBTOOL_DIR)/libtool.safe
	#mv $(XCHAIN_LIBTOOL_DIR)/libtoolize $(XCHAIN_LIBTOOL_DIR)/libtoolize.safe
	#cat $(XCHAIN_LIBTOOL_DIR)/libtool.safe | sed -e 's,sys_lib_search_path_spec="/lib /usr/lib /usr/local/lib",sys_lib_search_path_spec="$$CROSS_LIB_DIR/lib",g; s/^hardcode_libdir_flag_spec.*$$/hardcode_libdir_flag_spec=" -D__LIBTOOL_IS_A_FOOL__ "/' -e '/^archive_cmds="/s/"$$/ \\$$deplibs"/' > $(XCHAIN_LIBTOOL_DIR)/libtool
	#cat $(XCHAIN_LIBTOOL_DIR)/libtoolize.safe | sed -e 's,\(^prefix.*=.*$$\),[ -z "\$$prefix" ] \&\& \1,g' -e  's,\(^datadir.*=.*$$\),[ -z "\$$datadir" ] \&\& \1,g' -e 's,\(^pkgdatadir.*=.*$$\),[ -z "\$$pkgdatadir" ] \&\& \1,g' -e 's,\(^aclocaldir.*=.*$$\),[ -z "\$$aclocaldir" ] \&\& \1,g'> $(XCHAIN_LIBTOOL_DIR)/libtoolize
	touch $@

# ----------------------------------------------------------------------------
# Install
# ----------------------------------------------------------------------------

xchain-libtool_install: $(STATEDIR)/xchain-libtool.install

$(STATEDIR)/xchain-libtool.install: $(STATEDIR)/xchain-libtool.compile
	@$(call targetinfo, $@)
	$(XCHAIN_LIBTOOL_PATH) $(MAKE) -C $(XCHAIN_LIBTOOL_DIR) install
	touch $@

# ----------------------------------------------------------------------------
# Target-Install
# ----------------------------------------------------------------------------

xchain-libtool_targetinstall: $(STATEDIR)/xchain-libtool.targetinstall

xchain-libtool_targetinstall_deps = $(STATEDIR)/xchain-libtool.compile

$(STATEDIR)/xchain-libtool.targetinstall: $(xchain-libtool_targetinstall_deps)
	@$(call targetinfo, $@)
	$(XCHAIN_LIBTOOL_PATH) $(MAKE) -C $(XCHAIN_LIBTOOL_DIR) install
	touch $@

# ----------------------------------------------------------------------------
# Clean
# ----------------------------------------------------------------------------

xchain-libtool_clean:
	rm -rf $(STATEDIR)/xchain-libtool.*
	rm -rf $(XCHAIN_LIBTOOL_DIR)

# vim: syntax=make
