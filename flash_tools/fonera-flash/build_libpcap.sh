#!/bin/bash

tar xfvz ./libpcap-0.8.1.tar.gz
cp ./libpcap-shared.patch ./libpcap-0.8.1/
cd libpcap-0.8.1/
patch -Np1 -i libpcap-shared.patch
sed -i -e "s/@MAJOR@/`awk -F '.' '{ print $1 }' VERSION`/"          -e "s/@MINOR@/`awk -F '.' '{ print $2 }' VERSION`/"  -e "s/@SUBMINOR@/`awk -F '.' '{ print $3 }' VERSION`/"  -e "s/@VERSION@/`cat VERSION`/" Makefile.in
./configure
make
mkdir pkg
make DESTDIR=./pkg install 
cp ./pkg/usr/local/lib/libpcap.so.0.8 ./
cd ..