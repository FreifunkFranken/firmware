include $(TOPDIR)/rules.mk

PKG_NAME:=fff-macnock
PKG_VERSION:=0.1
PKG_RELEASE:=1
PKG_REV:=ffd1a64515709d75afaab0f990308fd164dc4cc6

PKG_SOURCE:=$(PKG_NAME)-$(PKG_VERSION).tar.bz2
PKG_SOURCE_URL:=https://github.com/FreifunkFranken/macnocker.git
PKG_SOURCE_PROTO:=git
PKG_SOURCE_SUBDIR:=$(PKG_NAME)-$(PKG_VERSION)
PKG_SOURCE_VERSION:=$(PKG_REV)

include $(INCLUDE_DIR)/package.mk
include $(INCLUDE_DIR)/cmake.mk

CMAKE_OPTIONS:=-DMACNOCK_DEBUG=ON

define Package/$(PKG_NAME)
    SECTION:=base
    CATEGORY:=Freifunk
    TITLE:= Freifunk-Franken mac nocker
    URL:=http://www.freifunk-franken.de
    KCONFIG:= \
        CONFIG_NET_EMATCH=y \
        CONFIG_NET_EMATCH_U32=y \
        CONFIG_NET_CLS_BASIC=y \
        CONFIG_NET_CLS_ACT=y \
        CONFIG_NET_ACT_GACT=y \
        CONFIG_NET_CLS_U32=y
    DEPENDS:=+fff-network
endef

define Package/$(PKG_NAME)/install
	$(INSTALL_DIR) $(1)/usr/sbin
	$(INSTALL_BIN) $(PKG_BUILD_DIR)/macnock $(1)/usr/sbin/macnock
	$(CP) ./files/* $(1)/
endef

$(eval $(call BuildPackage,$(PKG_NAME)))
