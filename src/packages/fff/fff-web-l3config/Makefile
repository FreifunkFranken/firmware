include $(TOPDIR)/rules.mk

PKG_NAME:=fff-web-l3config
PKG_RELEASE:=1

include $(INCLUDE_DIR)/package.mk

define Package/fff-web-l3config
	SECTION:=base
	CATEGORY:=Freifunk
	TITLE:=Freifunk-Franken layer3 config webui
	URL:=http://www.freifunk-franken.de
	DEPENDS:= \
		+fff-layer3-config \
		+fff-web-ui
endef

define Package/fff-web-l3config/description
	Configure a layer3 router via a web UI
endef

define Build/Compile
	# nothing
endef

define Package/fff-web-l3config/install
	$(CP) ./files/* $(1)/
endef

$(eval $(call BuildPackage,fff-web-l3config))
