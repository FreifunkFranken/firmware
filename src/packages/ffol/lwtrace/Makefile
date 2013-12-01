#
# Copyright (C) 2006-2010 OpenWrt.org
#
# This is free software, licensed under the GNU General Public License v2.
# See /LICENSE for more information.
#

include $(TOPDIR)/rules.mk

PKG_NAME:=lwtrace
PKG_VERSION:=1.1
PKG_RELEASE:=1

PKG_BUILD_DIR:=$(BUILD_DIR)/$(PKG_NAME)-$(PKG_VERSION)
PKG_SOURCE:=$(PKG_NAME)-$(PKG_VERSION).tar.gz
PKG_SOURCE_URL:=http://dev.freifunk-ol.de/packages
PKG_MD5SUM:=bbe4e339daf69efe0b6c325f799c3e0b

include $(INCLUDE_DIR)/package.mk

define Package/lwtrace
  SECTION:=utilities
  CATEGORY:=Utilities
  TITLE:=Tool that uses the libwlocate library to get a position wireless
  URL:=http://sourceforge.net/projects/libwlocate/
  DEPENDS:=+libwlocate
endef

define Package/lwtrace/description
	libwlocate is a shared library that can be used for location-based services.
	It checks for WLAN-networks that are available near to a user and retrieves the
	current geographic position out of them.
	Thus no GPS is needed for positioning. This WLAN-based geolocation happens
	without using any of the commercial services that do the same but track the users
	position and data. libwlocate instead bases on the free OpenWLANMap project.
endef

define Build/InstallDev
	$(INSTALL_DIR) $(1)/usr/bin
	$(CP) $(PKG_BUILD_DIR)/lwtrace $(1)/usr/bin/
endef

define Package/lwtrace/install
	$(INSTALL_DIR) $(1)/usr/bin
	$(CP) $(PKG_BUILD_DIR)/lwtrace $(1)/usr/bin/
endef

$(eval $(call BuildPackage,lwtrace))