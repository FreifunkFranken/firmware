include $(TOPDIR)/rules.mk

PKG_NAME:=fff-uradvd
PKG_RELEASE:=$(COMMITCOUNT)

include $(INCLUDE_DIR)/package.mk

define Package/$(PKG_NAME)
	SECTION:=base
	CATEGORY:=Freifunk
	TITLE:=Freifunk-Franken uradvd
	URL:=https://www.freifunk-franken.de
	DEPENDS:=+uradvd
endef

define Package/$(PKG_NAME)/description
	This is the uradvd wrapper for the Freifunk Franken Firmware
	It is used to configure and start the uradvd daemon.
endef

define Build/Compile
	# nothing
endef

define Package/$(PKG_NAME)/install
	$(CP) ./files/* $(1)/
endef

$(eval $(call BuildPackage,$(PKG_NAME)))
