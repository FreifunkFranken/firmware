include $(TOPDIR)/rules.mk

PKG_NAME:=fff-wireless
PKG_VERSION:=0.0.1
PKG_RELEASE:=1

PKG_BUILD_DIR:=$(BUILD_DIR)/fff-wireless

include $(INCLUDE_DIR)/package.mk

define Package/fff-wireless
    SECTION:=base
    CATEGORY:=Freifunk
    TITLE:= Freifunk-Franken wireless configuration
    URL:=http://www.freifunk-franken.de
    DEPENDS:=+@ATH_USER_REGD +wireless-tools
endef

define Package/fff-wireless/description
    This package configures the wireless interfaces.
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

define Package/fff-wireless/install
    $(CP) ./files/* $(1)/
endef

$(eval $(call BuildPackage,fff-wireless))
