include $(TOPDIR)/rules.mk

PKG_NAME:=fff-uradvd
PKG_VERSION:=1
PKG_RELEASE:=1

PKG_BUILD_DIR:=$(BUILD_DIR)/fff-uradvd

include $(INCLUDE_DIR)/package.mk

define Package/fff-uradvd
    SECTION:=base
    CATEGORY:=Freifunk
    TITLE:= Freifunk-Franken uradvd
    URL:=http://www.freifunk-franken.de
    DEPENDS:=+uradvd
endef

define Package/fff-uradvd/description
    This is the uradvd wrapper for the Freifunk Franken Firmware
    It is used to configure and start the uradvd daemon.
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

define Package/fff-uradvd/install
    $(CP) ./files/* $(1)/
endef

$(eval $(call BuildPackage,fff-uradvd))
