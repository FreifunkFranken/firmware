include $(TOPDIR)/rules.mk

PKG_NAME:=fff-network
PKG_VERSION:=0.0.1
PKG_RELEASE:=2

PKG_BUILD_DIR:=$(BUILD_DIR)/fff-network

include $(INCLUDE_DIR)/package.mk

define Package/fff-network
    SECTION:=base
    CATEGORY:=Freifunk
    TITLE:= Freifunk-Franken network configuration
    URL:=http://www.freifunk-franken.de
    DEPENDS:=+fff-uradvd +fff-boardname
endef

define Package/fff-network/description
    This package configures the network interfaces
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

define Package/fff-network/install
	$(CP) ./files/* $(1)/
endef

$(eval $(call BuildPackage,fff-network))
