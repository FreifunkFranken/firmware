include $(TOPDIR)/rules.mk

PKG_NAME:=fff-gateway
PKG_VERSION:=1
PKG_RELEASE:=1

PKG_BUILD_DIR:=$(BUILD_DIR)/fff-gateway

include $(INCLUDE_DIR)/package.mk

define Package/fff-gateway
	SECTION:=base
	CATEGORY:=Freifunk
	TITLE:= Freifunk-Franken gateway configuration
	URL:=https://www.freifunk-franken.de
endef

define Package/fff-gateway/description
	This package configures the gateway
endef

define Build/Prepare
	echo "all: " > $(PKG_BUILD_DIR)/Makefile
endef

define Build/Configure
	# nothing
endef

define Build/Compile
	# nothing
endef

define Package/fff-gateway/install
	$(CP) ./files/* $(1)/
endef

$(eval $(call BuildPackage,fff-gateway))
