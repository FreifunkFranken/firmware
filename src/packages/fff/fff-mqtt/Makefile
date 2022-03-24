include $(TOPDIR)/rules.mk

PKG_NAME:=fff-mqtt
PKG_RELEASE:=$(COMMITCOUNT)

PKG_BUILD_DIR:=$(BUILD_DIR)/fff-mqtt

include $(INCLUDE_DIR)/package.mk

define Package/fff-mqtt
	SECTION:=base
	CATEGORY:=Freifunk
	TITLE:=Freifunk-Franken mqtt configuration
	URL:=https://www.freifunk-franken.de
	DEPENDS:= \
		+fff-config \
		+libmosquitto-nossl \
		+mosquitto-client-nossl
endef

define Package/fff-mqtt/description
	This package provides mosquitto and settings
endef

define Build/Compile
	# nothing
endef

define Package/fff-mqtt/install
	$(CP) ./files/* $(1)/
endef

$(eval $(call BuildPackage,fff-mqtt))
