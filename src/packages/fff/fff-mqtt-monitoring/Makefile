include $(TOPDIR)/rules.mk

PKG_NAME:=fff-mqtt-monitoring
PKG_RELEASE:=$(COMMITCOUNT)

PKG_BUILD_DIR:=$(BUILD_DIR)/fff-mqtt-monitoring

include $(INCLUDE_DIR)/package.mk

define Package/fff-mqtt-monitoring
	SECTION:=base
	CATEGORY:=Freifunk
	TITLE:=Freifunk-Franken mqtt configuration
	URL:=https://www.freifunk-franken.de
	DEPENDS:= \
		+fff-mqtt \
		+fff-nodewatcher \
		+micrond
endef

define Package/fff-mqtt-monitoring/description
	This package send monitoring informations to
	the mqtt broker
endef

define Build/Compile
	# nothing
endef

define Package/fff-mqtt-monitoring/install
	$(CP) ./files/* $(1)/
endef

$(eval $(call BuildPackage,fff-mqtt-monitoring))
