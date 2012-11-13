#!/bin/sh

killall /usr/local/bin/minikonoha
./dse.k -DPORT=8080
