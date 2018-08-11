include $(TOPDIR)/rules.mk

PKG_NAME:=fff-alfred-monitoring-proxy
PKG_VERSION:=0.0.1
PKG_RELEASE:=1

PKG_BUILD_DIR:=$(BUILD_DIR)/fff-alfred-monitoring-proxy

include $(INCLUDE_DIR)/package.mk

define Package/fff-alfred-monitoring-proxy
    SECTION:=base
    CATEGORY:=Freifunk
    TITLE:= Freifunk-Franken Alfred-Monitoring-Proxy
    URL:=https://www.freifunk-franken.de/
    DEPENDS:=+micrond +fff-random +curl +alfred-json +fff-nodewatcher
endef

define Package/fff-alfred-monitoring-proxy/description
 The Alfred-Monitoring-Proxy is used
 to send node status information to https://monitoring.freifunk-franken.de/
endef

define Build/Prepare
    echo "all: " > $(PKG_BUILD_DIR)/Makefile
endef

define Package/fff-alfred-monitoring-proxy/install
    $(CP) ./files/* $(1)/
endef

$(eval $(call BuildPackage,fff-alfred-monitoring-proxy))
