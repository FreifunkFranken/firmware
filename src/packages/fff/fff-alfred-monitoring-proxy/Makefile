include $(TOPDIR)/rules.mk

PKG_NAME:=fff-alfred-monitoring-proxy
PKG_RELEASE:=4

PKG_BUILD_DIR:=$(BUILD_DIR)/fff-alfred-monitoring-proxy

include $(INCLUDE_DIR)/package.mk

define Package/fff-alfred-monitoring-proxy
	SECTION:=base
	CATEGORY:=Freifunk
	TITLE:=Freifunk-Franken Alfred-Monitoring-Proxy
	URL:=https://www.freifunk-franken.de/
	DEPENDS:=+curl +micrond +alfred-json +fff-alfred +fff-random
endef

define Package/fff-alfred-monitoring-proxy/description
	The Alfred-Monitoring-Proxy is used
	to send node status information to
	https://monitoring.freifunk-franken.de/
endef

define Build/Compile
	# nothing
endef

define Package/fff-alfred-monitoring-proxy/install
	$(CP) ./files/* $(1)/
endef

$(eval $(call BuildPackage,fff-alfred-monitoring-proxy))
