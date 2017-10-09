include $(TOPDIR)/rules.mk

PKG_NAME:=fff-tunneldigger
PKG_VERSION:=1
PKG_RELEASE:=1

PKG_BUILD_DIR:=$(BUILD_DIR)/fff-tunneldigger

include $(INCLUDE_DIR)/package.mk

define Package/fff-tunneldigger
    SECTION:=base
    CATEGORY:=Freifunk
    TITLE:= Freifunk-Franken tunneldigger
    URL:=http://www.freifunk-franken.de
    DEPENDS:=+tunneldigger
endef

define Package/fff-tunneldigger/description
    This is tunneldigger for the Freifunk Franken Firmware
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

define Package/fff-tunneldigger/install
        $(CP) ./files/* $(1)/
endef

$(eval $(call BuildPackage,fff-tunneldigger))
