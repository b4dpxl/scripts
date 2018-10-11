#! /bin/sh

# Really simples script to get whois for an IP by domain, not the whois of the domain itself

ip=`nslookup $1 | grep -P "Address: \d" | head -n1 | awk '{print $2}'`
whois $ip
