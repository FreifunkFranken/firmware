include $(TOPDIR)/rules.mk

PKG_NAME:=fff-ra
PKG_VERSION:=1
PKG_RELEASE:=1

PKG_BUILD_DIR:=$(BUILD_DIR)/fff-ra

include $(INCLUDE_DIR)/package.mk

define Package/fff-ra
    SECTION:=base
    CATEGORY:=Freifunk
    TITLE:=Freifunk-Franken Router Advertisements
    URL:=https://www.freifunk-franken.de
    DEPENDS:=+odhcpd
endef

define Package/fff-ra/description
    This is the fff-ra for the Freifunk Franken Firmware
    It is used to configure odhcpd to send Router Advertisements for use as gateway.
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

define Package/fff-ra/install
    $(CP) ./files/* $(1)/
endef

$(eval $(call BuildPackage,fff-ra))
