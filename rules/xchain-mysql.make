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
ifdef PTXCONF_XCHAIN_MYSQL
PACKAGES += xchain-mysql
endif

#
# Paths and names
#
XCHAIN_MYSQL			= mysql-$(MYSQL_VERSION)
XCHAIN_MYSQL_DIR		= $(XCHAIN_BUILDDIR)/$(XCHAIN_MYSQL)

# ----------------------------------------------------------------------------
# Get
# ----------------------------------------------------------------------------

xchain-mysql_get: $(STATEDIR)/xchain-mysql.get

xchain-mysql_get_deps = $(XCHAIN_MYSQL_SOURCE)

$(STATEDIR)/xchain-mysql.get: $(xchain-mysql_get_deps)
	@$(call targetinfo, $@)
	@$(call get_patches, $(MYSQL))
	touch $@

$(XCHAIN_MYSQL_SOURCE):
	@$(call targetinfo, $@)
	@$(call get, $(MYSQL_URL))

# ----------------------------------------------------------------------------
# Extract
# ----------------------------------------------------------------------------

xchain-mysql_extract: $(STATEDIR)/xchain-mysql.extract

xchain-mysql_extract_deps = $(STATEDIR)/xchain-mysql.get

$(STATEDIR)/xchain-mysql.extract: $(xchain-mysql_extract_deps)
	@$(call targetinfo, $@)
	@$(call clean,   $(XCHAIN_MYSQL_DIR))
	@$(call extract, $(MYSQL_SOURCE), $(XCHAIN_BUILDDIR))
	@$(call patchin, $(MYSQL), $(XCHAIN_MYSQL_DIR))
	touch $@

# ----------------------------------------------------------------------------
# Prepare
# ----------------------------------------------------------------------------

xchain-mysql_prepare: $(STATEDIR)/xchain-mysql.prepare

#
# dependencies
#
xchain-mysql_prepare_deps = \
	$(STATEDIR)/xchain-mysql.extract

XCHAIN_MYSQL_PATH	=  PATH=$(CROSS_PATH)
XCHAIN_MYSQL_ENV 	=  $(HOSTCC_ENV)
#XCHAIN_MYSQL_ENV	+=

#
# autoconf
#
XCHAIN_MYSQL_AUTOCONF = \
	--prefix=$(PTXCONF_PREFIX) \
	--build=$(GNU_HOST)
# 	--host=$(GNU_HOST)
# 	--target=$(PTXCONF_GNU_TARGET)

$(STATEDIR)/xchain-mysql.prepare: $(xchain-mysql_prepare_deps)
	@$(call targetinfo, $@)
	@$(call clean, $(XCHAIN_MYSQL_DIR)/config.cache)
	perl -i -p -e "s,\@CROSS_LIB_DIR@,$(NATIVE_SDK_FILES_PREFIX),g" $(XCHAIN_MYSQL_DIR)/configure.in
	cd $(XCHAIN_MYSQL_DIR) && $(XCHAIN_MYSQL_PATH) aclocal
	cd $(XCHAIN_MYSQL_DIR) && $(XCHAIN_MYSQL_PATH) automake --add-missing
	cd $(XCHAIN_MYSQL_DIR) && $(XCHAIN_MYSQL_PATH) autoconf
	cd $(XCHAIN_MYSQL_DIR) && \
		$(XCHAIN_MYSQL_PATH) $(XCHAIN_MYSQL_ENV) \
		./configure $(XCHAIN_MYSQL_AUTOCONF)
	touch $@

# ----------------------------------------------------------------------------
# Compile
# ----------------------------------------------------------------------------

xchain-mysql_compile: $(STATEDIR)/xchain-mysql.compile

xchain-mysql_compile_deps = $(STATEDIR)/xchain-mysql.prepare

$(STATEDIR)/xchain-mysql.compile: $(xchain-mysql_compile_deps)
	@$(call targetinfo, $@)
	$(XCHAIN_MYSQL_PATH) $(MAKE) -C $(XCHAIN_MYSQL_DIR)
	touch $@

# ----------------------------------------------------------------------------
# Install
# ----------------------------------------------------------------------------

xchain-mysql_install: $(STATEDIR)/xchain-mysql.install

$(STATEDIR)/xchain-mysql.install: $(STATEDIR)/xchain-mysql.compile
	@$(call targetinfo, $@)
	$(XCHAIN_MYSQL_PATH) $(MAKE) -C $(XCHAIN_MYSQL_DIR) install
	touch $@

# ----------------------------------------------------------------------------
# Target-Install
# ----------------------------------------------------------------------------

xchain-mysql_targetinstall: $(STATEDIR)/xchain-mysql.targetinstall

xchain-mysql_targetinstall_deps = $(STATEDIR)/xchain-mysql.compile

$(STATEDIR)/xchain-mysql.targetinstall: $(xchain-mysql_targetinstall_deps)
	@$(call targetinfo, $@)
	touch $@

# ----------------------------------------------------------------------------
# Clean
# ----------------------------------------------------------------------------

xchain-mysql_clean:
	rm -rf $(STATEDIR)/xchain-mysql.*
	rm -rf $(XCHAIN_MYSQL_DIR)

# vim: syntax=make
