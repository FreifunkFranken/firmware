include $(TOPDIR)/rules.mk

PKG_NAME:=fff-simple-tc
PKG_RELEASE:=$(COMMITCOUNT)

include $(INCLUDE_DIR)/package.mk

define Package/$(PKG_NAME)
	SECTION:=base
	CATEGORY:=Freifunk
	TITLE:=Freifunk-Franken simple-tc config
	URL:=https://www.freifunk-franken.de
	DEPENDS:=+simple-tc
endef

define Package/$(PKG_NAME)/description
	This meta-package configures simple-tc for FFF
endef

define Build/Compile
	# nothing
endef

define Package/$(PKG_NAME)/install
	$(CP) ./files/* $(1)/
endef

$(eval $(call BuildPackage,$(PKG_NAME)))
