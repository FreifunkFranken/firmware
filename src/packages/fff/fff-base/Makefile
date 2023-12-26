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
		+@BUSYBOX_CONFIG_FEATURE_REVERSE_SEARCH \
		+@BUSYBOX_CONFIG_FEATURE_TOP_SMP_CPU \
		+@BUSYBOX_CONFIG_WATCH \
		+@BUSYBOX_CONFIG_FEATURE_EDITING_SAVEHISTORY \
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
