```
  ____  ____  ____  _____
 |     |     |        |   Freifunk
 |____ |____ |____    |    Franken
 |     |     |        |     Firmware
 |     |     |        |      Tools
```

In this folder you will find tools which can help you
hacking and building the firmware.


## buildscript-bash-completion

Just source this script or put it in your `/etc/bash_completion.d`
It provides all options and parameters of the buildscript on tab.


## dep-tree

This script collects all fff-package dependencies. You can throw the
output at the graphviz dot-tool to visualize the dependecies-tree. e.g.
```
dep-tree | dot -Tx11
dep-tree | dot -Tpdf > dependencies.pdf
```
