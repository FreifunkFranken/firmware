include $(TOPDIR)/rules.mk

PKG_NAME:=fff-extra
PKG_RELEASE:=$(COMMITCOUNT)

include $(INCLUDE_DIR)/package.mk

define Package/fff-extra
	SECTION:=base
	CATEGORY:=Freifunk
	TITLE:=Freifunk-Franken gateway configuration
	URL:=https://www.freifunk-franken.de
	DEPENDS:=+bmon \
	         +ethtool-full \
	         +htop \
	         +mtr \
	         +procps-ng \
	         +procps-ng-vmstat \
	         +sysstat
endef

define Package/fff-extra/description
	This package selects useful packages for devices with enough disk space available
endef

$(eval $(call BuildPackage,fff-extra))
