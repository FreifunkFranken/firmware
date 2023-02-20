firmware
========

# Was ist Freifunk?
Freifunk ist eine nicht-kommerzielle Initiative für freie Funknetzwerke. Jeder Nutzer im Freifunk-Netz stellt einen günstigen WLAN-Router für sich selbst und den Datentransfer der anderen Teilnehmer zur Verfügung. Dieses Netzwerk kann von jedem genutzt werden.

Weitere Informationen gibt es auf <https://freifunk.net/> und auf <https://wiki.freifunk-franken.de/w/Hauptseite>.

# Firmware selbst kompilieren
## Voraussetzungen
* `apt-get install zlib1g-dev lua5.2 build-essential unzip libncurses-dev gawk git subversion libssl-dev` (Sicherlich müssen noch mehr Abhängigkeiten installiert werden, diese Liste wird sich hoffentlich nach und nach füllen. Ein erster Ansatzpunkt sind die Abhängigkeiten von OpenWrt selbst)
* `git clone https://git.freifunk-franken.de/freifunk-franken/firmware.git`
* `cd firmware`

## Erste Schritte
Je nachdem, für welche Hardware die Firmware gebaut werden soll, muss das BSP gewählt werden:
* `./buildscript selectbsp bsp/ath79-generic.bsp`
* Um die vorhandenen BSPs zu sehen, kann `./buildscript selectbsp help` ausgeführt werden.

## Was ist ein BSP?
Ein BSP (Board-Support-Package) beschreibt, was zu tun ist, damit ein Firmware Image für eine spezielle Hardware gebaut werden kann.
Typischerweise besteht ein bsp aus:
* target-subtarget.bsp
* target-subtarget/.config

Die Daten des BSP werden nie alleine verwendet. Zuerst werden immer die Daten aus dem "default"-BSP zum Ziel kopiert, erst danach werden die Daten des eigentlichen BSPs dazu kopiert. Durch diesen Effekt kann ein BSP die "default" Daten überschreiben.

## Die Verwendung des Buildscripts
Die BSP-Datei wird durch das Buildscript automatisch als dot-Script geladen, somit stehen dort alle Funktionen zur Verfügung.
Das Buildscript generiert ein dynamisches sed-Script. Dies geschieht, damit die Templates mit den richtigen Werten gefüllt werden können.

### `./buildscript selectvariant`
Hier wählt man aus ob man Node Firmware oder Layer3 Firmware bauen möchte:
* `./buildscript selectvariant [node/layer3]`
* Um die verschiedenen Varianten zu sehen, kann `./buildscript selectvariant help` ausgeführt werden.

### `./buildscript prepare`
* Sourcen werden in einen separaten src-Folder geladen, sofern diese nicht schon da sind. Zu den Sourcen zählen folgende Komponenten:
  * OpenWrt
  * Sämtliche Packages (ggf. werden Patches angewandt)
* Eine OpenWrt Feed-Config wird mit dem lokalen Source Verzeichnis als Quelle angelegt
* Die Feeds werden geladen
* Spezielle Auswahl an Paketen wird geladen
* Patches werden angewandt
* board_prepare() aus dem BSP wird aufgerufen (wird z.B. für Patches für eine bestimmte Hardware verwendet)

### `./buildscript config openwrt`
Um das Arbeiten mit den .config-Dateien von OpenWrt zu vereinfachen, bietet das Buildscript die Möglichkeit das `menuconfig` von OpenWrt aufzurufen. Nachdem man die gewünschten Einstellungen vorgenommen hat, hat man die Möglichkeit, die frisch editierte Konfiguration in das BSP zu übernehmen.
Dieses Kommando arbeitet folgendermaßen:
* prebuild
* OpenWrt: `make menuconfig`
* Speichern, y/n?
* Config-Format vereinfachen
* Config ins BSP zurück speichern

### `./buildscript updatefeeds`
Aktualisiert die OpenWrt Feeds für zusätzliche Pakete, die in die Firmware eingebaut werden. Dabei werden die Referenzen im build/ Verzeichnis aktualisiert. Dieser Schritt wird bereits von `./buildscript prepare` übernommen, daher ist dies nur bei manuellen Änderungen der Feeds nötig.

### `./buildscript build`
Sollte man am besten mit Hilfe des Tools 'screen' oder ähnlichem laufen lassen um einen Abbruch des Builds bei Verbindungsproblemen oder ähnlichem zu verhindern.
* prebuild
  * $target/files aufräumen
    * (In $target/files liegen Dateien, die später direkt im Ziel-Image landen)
  * Files aus default-bsp und bsp kopieren
  * OpenWrt- und Kernel-Config kopieren
  * board_prebuild() aus dem BSP wird aufgerufen
* Templates transformieren
* GIT Versionen speichern: $target/files/etc/firmware_release
* OpenWrt: make
* postbuild
  * board_postbuild() wird aufgerufen

### `./buildscript buildall`
Kann verwendet werden um für alle BSPs Firmware zu bauen. Das kann jedoch mehrere Stunden dauern.

## Erweiterung eines BSPs
Beispielhaftes Vorgehen um den WR1043V2 zu unterstützen.

### Repository auschecken
```
git clone https://git.freifunk-franken.de/freifunk-franken/firmware.git
cd firmware
```

### Erste Images erzeugen
Du fügst die Dateinamen der Images, die zusätzlich kopiert werden sollen, in das `images`-Array ein. Hierbei können Wildcards verwendet werden, um z.B. sysupgrade.bin und ggf. meherere factory.bin Ergebnisse aus dem OpenWrt Buildverzeichnis in unser Buildverzeichnis zu kopieren.

```
vim bsp/ath79-generic.bsp
images=(
    // ...
    openwrt-${chipset}-${subtarget}-tl-wr1043nd-v2-squashfs-*"
    // ...
)
```

Dann muss auf jeden Fall noch das Netzwerk richtig konfiguriert werden. Dazu muss man den Router sehr gut kennen, i.d.R. lernt man den erst beim Verwenden kennen, daher ist ein guter Startpunkt die Config vom v1 zu kopieren und erstmal zu gucken was passiert.
Wichtig: Zur Laufzeit wird (wenn keine Anpassung in fff-boardname vorgenommen wurde) die Datei `network.$(cat /var/sysinfo/board_name)` geladen. Um den richtigen Dateinamen zu bestimmen kann zunächst ein normales OpenWrt in der gleichen Version auf den Router installiert werden; dort kan man sich dann diese Datei ansehen.
```
cd src/packages/fff/fff-network/mips
cp network.tplink,wr1043nd-v1 network.tplink,wr1043nd-v2
```

Anschließend kann ein erstes Image erzeugt werden:
```
./buildscript selectbsp bsp/ath79-generic.bsp

./buildscript prepare
./buildscript build
```
Jetzt gehst du n Kaffee trinken.

### Netzwerkeinstellungen korrekt setzen
Am Ende sollte im bin/ Verzeichnis unter anderem das Image für v1 und v2 liegen. Das v2 Image wird auf den Router geflasht. Achtung: Eventuell ist das Netzwerk jetzt so falsch eingestellt, dass man nicht mehr über Netzwerk auf den Router zugreifen kann. Am einfachsten ist es den Router dann über eine serielle Konsole zu verwenden. Alternativ kann aber auch der OpenWrt Failsafe Modus verwendet werden, dort werden unsere Netzwerkeinstellungen nicht angewendet. Außerdem kann man an den unterschiedlichen LAN-Ports mit der IPv6 Link-Local aus der MAC Adresse des Geräts versuchen drauf zu kommen. Es kann auch sein, dass die IPv6 +/- 1 am Ende hat. Letztlich kann das funktionieren, die serielle Konsole ist hier aber häufig einfacher!
Wenn man dann auf dem Router drauf ist, muss als erstes festgestellt werden, welches Ethernet-Device für den WAN Port zuständig ist. Mir sind da folgende Möglichkeiten bekannt. a) WAN ist eth0, b) WAN ist eth1, c) WAN ist teil vom Switch eth0. Dementsprechend wird das WANDEV auf dem Router in der /etc/network.tl-wr1043nd-v2 konfiguriert. Wenn WAN ein eigenes ethX hat, dann muss WAN_PORTS="" sein. Dann muss eingestellt werden welches Ethernet-Device an dem internen Switch angeschlossen ist (swconfig list). Dieses wird als SWITCHDEV konfiguriert. Es muss noch eingestellt werden, welches Ethernet oder Wifi Device die MAC Adresse hat, die auch unter dem Gerät steht. Dieses Device wird als ROUTERMAC eingetragen. Nun ist es an der Zeit die Einstellungen zu testen, dafür muss die falsche Netzwerk-Config zurück gesetzt werden:
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
Wenn jetzt die Ports immer noch alle korrekt funktionieren kann man die Datei auf den eigenen PC kopieren:
```
scp root@[ipv6ll%scope]:/etc/network.tl-wr1043nd-v2 /path/to/git/firmware/bsp/wr1043nd/root_file_system/etc/network.tl-wr1043nd-v2
```

### BSP commiten und Patch erzeugen
Nun kann man mit `git status` die Änderungen sehen.

Damit man an mehreren Änderungen gleichzeitig arbeiten kann, sollte zunächst mit `git checkout -b mein-neues-feature` ein neuer Branch erzeugt werden. Dann können die Änderungen mit `git add` gestaged und danach mit `git commit` eingecheckt werden.

Die so erzeugten Änderungen können dann mit einem Pull Request im [Gitea](https://git.freifunk-franken.de/freifunk-franken/firmware) submitted werden. Dafür ist ein [Account](https://docs.freifunk-franken.de/services/git.freifunk-franken/#anmeldung) nötig. Dazu muss das Firmware-Repository zunächst geforkt werden. Die SSH-Adresse des Forks (steht oben rechts) kann dann mit `git remote set-url origin gitea@git.freifunk-franken.de:meinname/firmware.git` in das lokale Repository eingetragen werden. Danach kann der weiter oben erstellte Branch mit `git push origin mein-neues-feature` in den Fork hochgeladen werden. Nun kann der Pull Request im Freifunk Franken Repository [angelegt](https://git.freifunk-franken.de/freifunk-franken/firmware/pulls) werden.

Soll der Pull Request später geändert werden, dann müssen zunächst die nötigen Änderungen gemacht und danach mit `git commit --amend` in den bereits bestehenden Commit eingefügt werden. Dies kann dann mit `git push --force origin mein-neues-feature` in den Fork hochgeladen werden. Force ist hierbei nötig, da bereits bestehende Commits geändert werden. Der Pull Request wird dann automatisch aktualisiert. Um Reviews zu erleichtern sollten die Änderungen im Pull Request als Kommentar beschrieben werden.

Auf der Mailingliste franken-dev@freifunk.net kannst du natürlich jederzeit Fragen stellen, falls etwas nicht klar sein sollte.

## Hinzufügen von Paketen zum Image
Das Hinzufügen von Paketen sollte mit Bedacht erfolgen, da dies (bei unvorsichtiger Konfiguration) den Betrieb des Routers und eventuell des Freifunk-Netzes beeinträchtigen könnte.
Mit dem Firmware-Verzeichnis als Arbeitsverzeichnis kann mittels des Befehls `./build/<target>/scripts/feeds install <paket>` ein Paket zur menuconfig hinzugefügt werden.
Mittels des schon bekannten `./buildscript config openwrt` kann das Paket dann ausgewählt werden. Es wird beim anschließenden Build zum Image hinzugefügt.
