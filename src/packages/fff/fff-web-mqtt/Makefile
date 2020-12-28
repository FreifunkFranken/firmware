include $(TOPDIR)/rules.mk

PKG_NAME:=fff-web-mqtt
PKG_RELEASE:=1

PKG_BUILD_DIR:=$(BUILD_DIR)/$(PKG_NAME)

include $(INCLUDE_DIR)/package.mk

define Package/fff-web-mqtt
	SECTION:=base
	CATEGORY:=Freifunk
	TITLE:=Freifunk-Franken mqtt config webui
	URL:=https://www.freifunk-franken.de
	DEPENDS:= \
		+fff-mqtt \
		+fff-web-ui
endef

define Package/fff-web-mqtt/description
	Configure mqtt via a web UI
endef

define Build/Compile
	# nothing
endef

define Package/fff-web-mqtt/install
	$(CP) ./files/* $(1)/
endef

$(eval $(call BuildPackage,fff-web-mqtt))
