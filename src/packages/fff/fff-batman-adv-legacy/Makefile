include $(TOPDIR)/rules.mk

PKG_NAME:=fff-batman-adv-legacy
PKG_VERSION:=1
PKG_RELEASE:=1

PKG_BUILD_DIR:=$(BUILD_DIR)/fff-batman-adv-legacy

include $(INCLUDE_DIR)/package.mk

define Package/fff-batman-adv-legacy
    SECTION:=base
    CATEGORY:=Freifunk
    TITLE:=Freifunk-Franken batman-adv-legacy
    URL:=http://www.freifunk-franken.de
    DEPENDS:=+@PACKAGE_kmod-batman-adv-legacy \
             +@KMOD_BATMAN_ADV_LEGACY_BLA \
             +@KMOD_BATMAN_ADV_LEGACY_DAT \
             +@KMOD_BATMAN_ADV_LEGACY_NC \
             +@KMOD_BATMAN_ADV_LEGACY_BATCTL
endef

define Package/fff-batman-adv-legacy/description
    This is the batman-adv-legacy for the Freifunk Franken Firmware
    It is used to configure batman-adv-legacy.
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

define Package/fff-batman-adv-legacy/install
	$(CP) ./files/* $(1)/
endef

$(eval $(call BuildPackage,fff-batman-adv-legacy))
