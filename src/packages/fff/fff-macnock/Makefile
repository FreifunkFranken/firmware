include $(TOPDIR)/rules.mk

PKG_NAME:=fff-macnock
PKG_RELEASE:=1

PKG_SOURCE_PROTO:=git
PKG_SOURCE_URL:=https://github.com/FreifunkFranken/macnocker.git
PKG_SOURCE_DATE:=2020-04-23
PKG_SOURCE_VERSION:=ce01c3253b7f6acb1e25a26e8de4e013aed52bb0

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
	DEPENDS:=+fff-network +tc
endef

define Package/$(PKG_NAME)/install
	$(INSTALL_DIR) $(1)/usr/sbin
	$(INSTALL_BIN) $(PKG_BUILD_DIR)/macnock $(1)/usr/sbin/macnock
	$(CP) ./files/* $(1)/
endef

$(eval $(call BuildPackage,$(PKG_NAME)))
