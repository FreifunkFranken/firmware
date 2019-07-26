include $(TOPDIR)/rules.mk

PKG_NAME:=fff-config
PKG_RELEASE:=2

PKG_BUILD_DIR:=$(BUILD_DIR)/$(PKG_NAME)

include $(INCLUDE_DIR)/package.mk

define Package/$(PKG_NAME)
	SECTION:=base
	CATEGORY:=Freifunk
	TITLE:=Freifunk-Franken Config
	URL:=http://www.freifunk-franken.de
	DEPENDS:=+fff-boardname
endef

define Package/$(PKG_NAME)/description
	This is the Freifunk Franken Firmware Config package.
	This packages provides utilities for a central FFF config file.
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

define Package/$(PKG_NAME)/install
	$(CP) ./files/* $(1)/
endef

$(eval $(call BuildPackage,$(PKG_NAME)))
