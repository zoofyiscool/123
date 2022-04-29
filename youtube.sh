#!/bin/sh
# This script will fetch the Googlevideo ad domains and append them to the Pi-hole block list.
# Run this script daily with a cron job (don't forget to chmod +x)
# More info here: https://discourse.pi-hole.net/t/how-do-i-block-ads-on-youtube/253/136

# File to store the YT ad domains
FILE=/etc/pihole/youtube.hosts

# Fetch the list of domains, remove the ip's and save them
curl 'https://api.hackertarget.com/hostsearch/?q=googlevideo.com' \
| awk -F, 'NR>1{print $1}' \
| grep -vE "redirector|manifest" > $FILE

# Replace r*.sn*.googlevideo.com URLs to r*---sn-*.googlevideo.com
# and add those to the list too
cat $FILE | sed -r 's/(^r[[:digit:]]+)(\.)(sn)/\1---\3-/' >> $FILE

# Scan log file for previously accessed domains
grep '^r.*googlevideo\.com' /var/log/pihole*.log \
| awk '{print $8}' \
| grep -vE "redirector|manifest" \
| sort | uniq >> $FILE

# Add to Pi-hole adlists if it's not there already
if ! grep $FILE < /etc/pihole/adlists.list; then echo "file://$FILE" >> /etc/pihole/adlists.list; fi;
