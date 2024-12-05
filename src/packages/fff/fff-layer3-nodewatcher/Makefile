include $(TOPDIR)/rules.mk

PKG_NAME:=fff-layer3-nodewatcher
PKG_RELEASE:=$(COMMITCOUNT)

include $(INCLUDE_DIR)/package.mk

define Package/fff-layer3-nodewatcher
	SECTION:=base
	CATEGORY:=Freifunk
	TITLE:=Freifunk-Franken Nodewatcher-Monitoring-Proxy
	URL:=https://www.freifunk-franken.de
	DEPENDS:=+curl +micrond +fff-random +fff-nodewatcher
endef

define Package/fff-layer3-nodewatcher/description
	The Nodewatcher-Monitoring-Proxy is used
	to send node status information to
	https://monitoring.freifunk-franken.de/
endef

define Build/Compile
	# nothing
endef

define Package/fff-layer3-nodewatcher/install
	$(CP) ./files/* $(1)/
endef

$(eval $(call BuildPackage,fff-layer3-nodewatcher))
