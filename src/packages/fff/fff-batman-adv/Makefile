include $(TOPDIR)/rules.mk

PKG_NAME:=fff-batman-adv
PKG_VERSION:=1
PKG_RELEASE:=1

PKG_BUILD_DIR:=$(BUILD_DIR)/fff-batman-adv

include $(INCLUDE_DIR)/package.mk

define Package/fff-batman-adv
    SECTION:=base
    CATEGORY:=Freifunk
    TITLE:=Freifunk-Franken batman-adv
    URL:=http://www.freifunk-franken.de
    DEPENDS:=+kmod-batman-adv \
             +@KMOD_BATMAN_ADV_BATMAN_V \
             +@KMOD_BATMAN_ADV_NC \
             +batctl
endef

define Package/fff-batman-adv/description
    This is the batman-adv for the Freifunk Franken Firmware
    It is used to configure batman-adv.
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

define Package/fff-batman-adv/install
	$(CP) ./files/* $(1)/
endef

$(eval $(call BuildPackage,fff-batman-adv))
