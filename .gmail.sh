#!/bin/bash
 
key=$(base64 -d $HOME/.mypass);
#curl -u abhijeet.1989:$key --silent "https://mail.google.com/mail/feed/atom" | tr -d '\n' | awk -F '<entry>' '{for (i=2; i<=NF; i++) {print $i}}' | perl -pe 's/^<title>(.*)<\/title>.*<name>(.*)<\/name>.*$/$2 - $1/' | wc -l
