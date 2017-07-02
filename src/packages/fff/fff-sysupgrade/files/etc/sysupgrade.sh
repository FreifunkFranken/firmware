#!/bin/sh
cd /tmp/

. /etc/firmware_release

. /etc/community.cfg

BOARD=$(uci get board.model.name)

#decide SOC
case $BOARD in
    tl-wdr4900-v1 )
        SOC="mpc85xx" ;;
    * )
        SOC="ar71xx" ;;
esac
echo ""
echo "Hardware: $BOARD"

#rewrite BOARD
case $BOARD in
    cpe210 )
        BOARD="cpe210-220" ;;
    cpe510 )
        BOARD="cpe510-520" ;;
    wr841nd-v7 )
        BOARD="wr841-v7" ;;
    wr841n-v8 )
        BOARD="wr841-v8" ;;
    wr841n-v9 )
        BOARD="wr841-v9" ;;
    wr841n-v10 )
        BOARD="wr841-v10" ;;
    wr841n-v11 )
        BOARD="wr841-v11" ;;
esac

wget "${UPGRADE_PATH}/release.nfo"
if [ ! -f release.nfo ]; then
  echo "Latest release information not found. Please try to update manually."
  echo ""
  exit 1
fi
VERSION=$(awk -F: '/VERSION:/ { print $2 }' release.nfo)
rm -f release.nfo
echo "Firmware found on server: $VERSION"

if [ "$VERSION" -eq "$FIRMWARE_VERSION" ]; then
  echo "The installed firmware version is already the current version."
  echo ""

  if [ "$1" = "--script" ]; then
    exit 1
  fi

  while true; do
    echo "Do you want to reinstall the current version? [y/N]"
    read DO_UPDATE
    case $DO_UPDATE in
      [yY]*|[Jj]*)
        break
        ;;
      [nN]*|"")
        exit 1
        ;;
      *)
        echo "Invalid input"
        ;;
    esac
  done
fi

if [ "$FIRMWARE_COMMUNITY" = "franken" ]; then
    FIRMWARE_COMMUNITY="fff"
fi

FILE="${FIRMWARE_COMMUNITY}-${VERSION}-${SOC}-g-${BOARD}-squashfs-sysupgrade.bin"
echo "Downloading $FILE"
echo ""
wget "${UPGRADE_PATH}/${FILE}"
wget "${UPGRADE_PATH}/${FILE}.sha256"

sum=$(sha256sum -c "${FILE}.sha256")
ret=$?
echo ""
echo "done. Comparing sha256 sums: $sum"
echo
if [ $ret -ne 0 ]; then
  echo "sha256 sums do not match. Try restarting this script to redownload the firmware."
  echo ""
  rm -f "${FILE}" "${FILE}.sha256"
  exit 1
else
  if [ "$1" = "--script" ]; then
    echo ""
    echo "Starting firmware upgrade. Don't touch me until I reboot."
    echo ""
    echo ""
    sysupgrade "${FILE}"
  fi
  while true; do
    read -p "sha256 sums correct. Should I start upgrading the firmware (y/N)? " yn
    case $yn in
        [Yy]*|[Jj]*)
            echo ""
            echo "Starting firmware upgrade. Don't touch me until I reboot."
            echo ""
            echo ""
            sysupgrade "${FILE}"
            break;;
        *)
            echo ""
            echo "Aborting firmware upgrade."
            echo ""
            rm -f "${FILE}" "${FILE}.sha256"
            exit 0;;
    esac
  done
fi
