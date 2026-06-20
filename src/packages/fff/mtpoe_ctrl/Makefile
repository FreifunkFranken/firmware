#
# Copyright (C) 2018 adron@yapic.net
#

include $(TOPDIR)/rules.mk

PKG_NAME:=mtpoe_ctrl
PKG_SOURCE_VERSION:=d4dfc54f4fe8c6565d585b6a27730e4980b3103d
PKG_MIRROR_HASH:=c69117be380956c2a49fdeb63a285dffb39824c9b6b6d4d9a771f5eec8e06132
PKG_VERSION:=1.15.2
PKG_RELEASE:=21

PKG_SOURCE_PROTO:=git
PKG_SOURCE_URL:=https://github.com/fblaese/mtpoe_ctrl.git
PKG_SOURCE:=$(PKG_NAME)-$(PKG_VERSION).tar.gz
PKG_SOURCE_SUBDIR:=$(PKG_NAME)-$(PKG_VERSION)

PKG_MAINTAINER:=Sergey Sergeev <adron@yapic.net>
PKG_LICENSE:=GPL-2.0

include $(INCLUDE_DIR)/package.mk

define Package/mtpoe_ctrl
  SECTION:=utils
  CATEGORY:=Utilities
  DEPENDS:=+libuci +kmod-spi-dev
  TITLE:=Management utility for Mikrotiks PoE V2/V3/V4
  URL:=https://github.com/adron-s/mtpoe_ctrl.git
endef

define Package/mtpoe_ctrl/description
	Management utility for Mikrotiks PoE V2/V3/V4
endef

define Package/mtpoe_ctrl/install
	$(INSTALL_DIR) $(1)/usr/bin
	$(INSTALL_BIN) $(PKG_BUILD_DIR)/bins/mtpoe_ctrl $(1)/usr/bin/
	$(INSTALL_DIR) $(1)/etc/init.d
	$(INSTALL_BIN) ./files/99-mtpoe_ctrl $(1)/etc/init.d/
endef

$(eval $(call BuildPackage,mtpoe_ctrl))
