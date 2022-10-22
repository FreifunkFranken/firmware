include $(TOPDIR)/rules.mk

PKG_NAME:=fff-base
PKG_RELEASE:=$(COMMITCOUNT)

include $(INCLUDE_DIR)/package.mk

define Package/fff-base
	SECTION:=base
	CATEGORY:=Freifunk
	TITLE:=Freifunk-Franken base dependencies
	URL:=https://www.freifunk-franken.de
	DEFAULT:=y
	DEPENDS:= \
		+iptables-legacy \
		+ip6tables-legacy \
		+micrond \
		+odhcp6c \
		+fff-config \
		+fff-network \
		+fff-nodewatcher \
		+fff-simple-tc \
		+fff-support \
		+fff-sysupgrade \
		+fff-timeserver \
		+fff-web-ui \
		+fff-wireless
endef

define Package/fff-variant/description
	This package includes base packages used in the Freifunk-Franken firmware
endef

$(eval $(call BuildPackage,fff-base))
