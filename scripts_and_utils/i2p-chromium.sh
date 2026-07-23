#!/bin/bash
chromium --proxy-server="http=127.0.0.1:4444" --proxy-bypass-list="<-loopback>" --user-data-dir="$HOME/.config/chromium-i2p"
