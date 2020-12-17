include $(TOPDIR)/rules.mk

PKG_NAME:=fff-babeld
PKG_RELEASE:=5

PKG_BUILD_DIR:=$(BUILD_DIR)/fff-babeld

include $(INCLUDE_DIR)/package.mk

define Package/fff-babeld
	SECTION:=base
	CATEGORY:=Freifunk
	TITLE:=Freifunk-Franken babeld configuration example
	URL:=http://www.freifunk-franken.de
	DEPENDS:=+babeld
endef

define Package/fff-babeld/description
	This is the Freifunk Franken Firmware babeld package.
	This package provides an example babeld configuration.
endef

define Build/Compile
	# nothing
endef

define Package/fff-babeld/install
	$(CP) ./files/* $(1)/
endef

$(eval $(call BuildPackage,fff-babeld))
