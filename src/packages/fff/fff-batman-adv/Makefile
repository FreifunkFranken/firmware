include $(TOPDIR)/rules.mk

PKG_NAME:=fff-batman-adv
PKG_RELEASE:=$(COMMITCOUNT)

include $(INCLUDE_DIR)/package.mk

define Package/$(PKG_NAME)
	SECTION:=base
	CATEGORY:=Freifunk
	TITLE:=Freifunk-Franken batman-adv
	URL:=https://www.freifunk-franken.de
	DEPENDS:=+kmod-batman-adv \
			 +@BATMAN_ADV_BATMAN_V \
			 +@BATMAN_ADV_NC \
			 +batctl
endef

define Package/$(PKG_NAME)/description
	This is the batman-adv for the Freifunk Franken Firmware
	It is used to configure batman-adv.
endef

define Build/Compile
	# nothing
endef

define Package/$(PKG_NAME)/install
	$(CP) ./files/* $(1)/
endef

$(eval $(call BuildPackage,$(PKG_NAME)))
