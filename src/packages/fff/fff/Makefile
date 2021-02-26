include $(TOPDIR)/rules.mk

PKG_NAME:=fff
PKG_RELEASE:=$(COMMITCOUNT)

include $(INCLUDE_DIR)/package.mk

define Package/fff-variant/default
	SECTION:=base
	CATEGORY:=Freifunk
	URL:=https://www.freifunk-franken.de
	DEFAULT:=$(if $(filter fff-variant-$(FFF_VARIANT),$(1)),y,n)
	DEPENDS:= \
		+iptables \
		+ip6tables \
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

define Package/fff-variant/default/description
	This package is used to switch one of the variants on by default
endef

define Package/fff-variant-layer3
	$(Package/fff-variant/default)
	TITLE:=Freifunk-Franken Layer3 Variant
	DEPENDS+=+fff-layer3
	VARIANT:=layer3
endef

define Package/fff-variant-layer3/description
	$(Package/fff-variant/default/description)
endef

define Package/fff-variant-node
	$(Package/fff-variant/default)
	TITLE:=Freifunk-Franken Node Variant
	DEPENDS+=+fff-node
	VARIANT:=node
endef

define Package/fff-variant-node/description
	$(Package/fff-variant/default/description)
endef

$(eval $(call BuildPackage,fff-variant-layer3))
$(eval $(call BuildPackage,fff-variant-node))
