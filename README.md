firmware
========

# Was ist Freifunk?
Freifunk ist eine nicht-kommerzielle Initiative für freie Funknetzwerke. Jeder Nutzer im Freifunk-Netz stellt einen günstigen WLAN-Router für sich selbst und den Datentransfer der anderen Teilnehmer zur Verfügung. Dieses Netzwerk kann von jedem genutzt werden.

# Firmware selbst kompilieren

## Benutzung des Buildscripts
### Prerequisites
* `apt-get install zlib1g-dev lua5.2 build-essential unzip libncurses-dev gawk git subversion` (Sicherlich müssen noch mehr Abhängigkeiten Installiert werden, diese Liste wird sich hoffentlich nach und nach Füllen. Ein erster Ansatzpunkt sind die Abhängigkeiten von OpenWRT selbst)
* `git clone https://github.com/FreifunkFranken/firmware.git`
* `cd firmware`

### Erste Schritte
Mit Hilfe der Community-Files werden Parameter, wie die ESSID, der Kanal sowie z.B. die Netmon-IP gesetzt. Diese Einstellungen sind Community weit einheitlich und müssen i.d.R. nicht geändert werden.
* `./buildscript selectcommunity community/franken.cfg`
Je nach dem, für welche Hardware die Firmware gebaut werden soll muss das BSP gewählt werden:
* `./buildscript selectbsp bsp/board wr1043nd.bsp`
* `./buildscript`

## Was ist ein BSP?
Ein BSP beschreibt, was zu tun ist, damit ein Firmware Image für eine spezielle Hardware gebaut werden kann.
Typischerweise ist eine folgene Ordner-Struktur vorhanden:
* .config
* root_file_system/
  * etc/
    * rc.local.board
    * config/
      * board
      * network
      * system
    * crontabs/
      * root

Die Daten des BSP werden nie alleine verwendet. Zu erst werden immer die Daten aus dem "default"-BSP zum Ziel kopiert, erst danach werden die Daten des eigentlichen BSPs dazu kopiert. Durch diesen Effekt kann ein BSP die "default" Daten überschreiben.

## Der Verwendung des Buildscripts
Das BSP file durch das Buildscript automatisch als dot-Script geladen, somit stehen dort alle Funktionen zur Verfügung.
Das Buildscript lädt ebenfalls automatisch das Community file und generiert ein dynamisches sed-Script, dies geschieht, damit die Templates mit den richtigen Werten gefüllt werden können.

### `./buildscript prepare`
* Sourcen werden in einen separaten src-Folder geladen, sofern diese noch schont da sind. Zu den Sourcen zählen folgende Komponenten:
  * OpenWRT
  * Sämtliche Packages (ggfs werden Patches angewandt)

* Ein ggfs altes Target wird gelöscht
* OpenWRT wird ins Target exportiert (kopiert)
* Eine OpenWRT Feed-Config wird mit dem lokalen Source Verzeichnis als Quelle angelegt
* Die Feeds werden geladen
* Spezielle Auswahl an Paketen wird geladen
* Patches werden angewandt
* board_prepare() aus dem BSP wird aufgerufen (wird. z.B. fur Patches für eine bestimmte HW verwendet)

### `./buildscript build`
* prebuild
  * $target/files aufräumen
    * (In $target/files liegen Dateien, die später direkt im Ziel-Image landen)
  * Files aus default-bsp und bsp kopieren
  * OpenWRT- und Kernel-Config kopieren
  * board_prebuild() aus dem BSP wird aufgerufen
* Templates transformieren
* GIT Versionen speichern: $target/files/etc/firmware_release
* OpenWRT: make
* postbuild
  * board_postbuild() wird aufgerufen

### `./buildscript config`
Um das Arbeiten mit den OpenWRT .config's zu vereinfachen bietet das Buildscript die Möglichkeit die OpenWRT menuconfig und die OpenWRT kernel_menuconfig aufzurufen. Im Anschluss hat man die Möglichkeit die frisch editierten Configs in das BSP zu übernehmen.
* prebuild
* OpenWRT: `make menuconfig ; make kernel_menuconfig`
* Speichern, y/n?
* Config-Format vereinfachen
* Config ins BSP zurück speichern

## Erweiterung eines BSPs
Beispielhaftes Vorgehen um den WR1043V2 zu unterstützen.

### Repository auschecken
```
git clone https://github.com/FreifunkFranken/firmware.git
cd firmware
```

### Erstes Images erzeugen
Du fügst im board_postbuild ein, dass auch die Images für den wr1043v2 kopiert werden:
```
vim bsp/board_wr1043nd.bsp
board_postbuild() {
    cp $target/bin/ar71xx/openwrt-ar71xx-generic-tl-wr1043nd-v1-squashfs-factory.bin ./bin/
    cp $target/bin/ar71xx/openwrt-ar71xx-generic-tl-wr1043nd-v1-squashfs-sysupgrade.bin ./bin/
    cp $target/bin/ar71xx/openwrt-ar71xx-generic-tl-wr1043nd-v2-squashfs-factory.bin ./bin/
    cp $target/bin/ar71xx/openwrt-ar71xx-generic-tl-wr1043nd-v2-squashfs-sysupgrade.bin ./bin/
}
```

Dann muss auf jeden Fall noch das Netzwerk richtig konfiguriert werden. Dazu muss man den Router sehr gut kennen, i.d.R. lernt man den erst beim Verwenden kennen, daher ist ein guter Startpunkt die Config vom v1 zu kopieren und erstmal zu gucken was passiert:
```
cp bsp/wr1043nd/root_file_system/etc/network.tl-wr1043nd-v1 bsp/wr1043nd/root_file_system/etc/network.tl-wr1043nd-v2
```
Anschließend kann ein erstes Image erzeugt werden:
```
./buildscript selectbsp bsp/board_wr1043nd.bsp
./buildscript selectcommunity community/franken.cfg

./buildscript prepare
./buildscript build
```
Jetzt gehst du n Kaffee trinken.

### Netzwerkeinstellungen korrekt setzen
Am Ende sollte im bin/ Verzeichnis das Image für v1 und v2 liegen. Das v2 Image wird auf den Router geflasht. Achtung: Eventuell ist das Netzwerk jetzt so falsch eingestellt, dass man nicht mehr über Netzwerk auf den Router zugreifen kann. Am einfachsten ist es den Router dann über eine serielle Konsole zu verwenden. Theoretisch kann man an den unterschiedlichen LAN-Ports mit der IPv6 Link-Local aus der MAC Adresse des Geräts versuchen drauf zu kommen. Es kann auch sein, dass die IPv6 +/- 1 am Ende hat. Letztlich kann das funktionieren, ist aber aufwändig und da am LAN Einstellungen verändert werden sollen, ist die serielle Konsole das Mittel der Wahl!
Wenn man dann auf dem Router drauf ist, muss als erstes festgestellt werden, welches Ethernet-Device für den WAN Port zuständig ist. Mir sind da folgende Möglichkeiten bekannt. a) WAN ist eth0, b) WAN ist eth1, c) WAN ist teil vom Switch eth0. Dementsprechend wird das WANDEV auf dem Router in der /etc/network.tl-wr1043nd-v2 konfiguriert. Wenn WAN ein eigenes ethX hat, dann muss WAN_PORTS="" sein. Dann muss eingestellt werden welches Ethernet-Device an dem internen Switch angeschlossen ist (swconfig list). Dieses wird als SWITCHDEV konfiguriert. Ich glaub CLIENTIF musst nicht angepasst werden. Aber es muss noch eingestellt werden, welches Ethernet oder Wifi Device die MAC Adresse hat, die auch unter dem Gerät steht. Dieses Device wird als ROUTERMAC eingetragen. Nun ist es an der Zeit die Einstellungen zu testen, dafür muss die falsche Netzwerk-Config zurück gesetzt werden:
```
cp /rom/etc/config/network /etc/config/network
reboot
```

### Switch konfigurieren
Wenn der Router wieder hochgefahren ist, sollten die Einstellungen sein, so wie sie konfiguriert wurden. Gegebenenfalls muss man hier noch mal eine Runde drehen, wenn etwas nicht richtig war. Ansonsten ist es jetzt an der Zeit den Switch einzustellen. Das geht am einfachsten, wenn man die Einstellungen nun direkt in der /etc/config/network vornimmt. Dabei ist eth0_2 der WAN Port (sofern er über den Switch läuft). eth0_1 sind die Client-Ports und eth0_3 sind die Ports um Batman Knoten zu verbinden. Am Anfang weiß man meist noch nicht welcher Switch Port wirklich am Router wo rausgeführt ist. Manchmal kann es helfen einen Port nach dem anderen aktiv zu schalten (Rechner anstecken) und die Ausgabe von swconfig anzugucken (z.B. `swconfig dev switch0 show`). Das ganze ist manchmal ein wenig try-and-error. :( Aber wenn man denkt es passt, prüft man alles durch. Tauchen BATMAN Nachbarn in `batctl o` auf und aktualisiert sich die Anzeige, wenn ein anderer Knoten an dem Batman-Port angeschlossen wird? Funktioniert das mit beiden Ports? Taucht ein PC in `/etc/showmacs.sh br-mesh` auf, den man an die Client-Ports angeschlossen hat? Wenn am Ende alles passt, übernimmt man die Switch-Config in die /etc/network.tl-wr1043nd-v2 und probiert das ganze nochmal aus:
```
cp /rom/etc/config/network /etc/config/network
reboot
```

### Einstellungen testen und ins BSP übernehmen
Wenn jetzt die Ports immer noch alle korrekt funktionieren kann man die datei auf den eigenen PC kopieren:
```
scp root@[ipv6ll%scope]:/etc/network.tl-wr1043nd-v2 /path/to/git/firmware/bsp/wr1043nd/root_file_system/etc/network.tl-wr1043nd-v2
```

### BSP commiten und Patch erzeugen
Nun kann man mit `git status` die Änderungen sehen. Mit `git add` staged man diese und mit `git commit` checkt man sie ein. `git format-patch origin/HEAD` erzeugt dann aus deinen Commits ein (oder mehr) Patches. Diese schickst du dann mit `git send-email --to franken-dev@freifunk.net *.patch` an unsere Liste. Dort nimmt sich jemand die Zeit und schaut kurz drüber und wenn alles passt finden deine Änderungen in den Hauptentwicklungszweig und sind ab dann Teil der Freifunk-Franken-Firmware.

### Patch schicken
Auf der Mailingliste franken-dev@freifunk.net kannst du natürlich jederzeit Fragen stellen, falls etwas nicht klar sein sollte.
