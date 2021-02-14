include $(TOPDIR)/rules.mk

PKG_NAME:=fff-babel-bird2
PKG_RELEASE:=1

include $(INCLUDE_DIR)/package.mk

define Package/fff-babel-bird2
	SECTION:=base
	CATEGORY:=Freifunk
	TITLE:=Freifunk-Franken babel-bird2
	URL:=https://www.freifunk-franken.de
	DEPENDS:=+bird2 +bird2c +owipcalc
	PROVIDES:=fff-babel-implementation
	CONFLICTS:=fff-babeld
endef

define Package/fff-babel-bird2/description
	This is the Freifunk Franken Firmware babel-bird2 package.
endef

define Build/Compile
	# nothing
endef

define Package/fff-babel-bird2/install
	$(CP) ./files/* $(1)/
endef

$(eval $(call BuildPackage,fff-babel-bird2))
