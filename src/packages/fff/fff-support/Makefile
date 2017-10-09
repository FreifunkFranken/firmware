include $(TOPDIR)/rules.mk

PKG_NAME:=fff-support
PKG_VERSION:=0.0.1
PKG_RELEASE:=1

PKG_BUILD_DIR:=$(BUILD_DIR)/fff-support

include $(INCLUDE_DIR)/package.mk

define Package/fff-support
    SECTION:=base
    CATEGORY:=Freifunk
    TITLE:=Freifunk-Franken Support Scripts
    URL:=http://www.freifunk-franken.de
    DEPENDS:=+@BUSYBOX_CONFIG_ASH
endef

define Package/fff-support/description
    This is the Freifunk Franken Firmware support package.
    This packages provides smaller convenience scripts,
    not essential to the operation of the Firmware
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

define Package/fff-support/install
	$(CP) ./files/* $(1)/
	test -d ./$(BOARD) && $(CP) ./$(BOARD)/* $(1)/ || true
endef

$(eval $(call BuildPackage,fff-support))
