# NAT configuration

```sh
# Route all dns lookups through local dns server
# Scope to requests that originated in the network; do not expose dns server to external network
chain=srcnat action=masquerade protocol=udp src-address=192.168.88.0/24 dst-address=LOCAL_DNS dst-port=53 log=no log-prefix=""
chain=dstnat action=dst-nat to-addresses=LOCAL_DNS protocol=tcp src-address=!LOCAL_DNS dst-address=!LOCAL_DNS in-interface-list=LAN dst-port=53 log=no log-prefix=""
chain=srcnat action=masquerade protocol=tcp src-address=192.168.88.0/24 dst-address=LOCAL_DNS dst-port=53 log=no log-prefix=""
chain=dstnat action=dst-nat to-addresses=LOCAL_DNS protocol=udp src-address=!LOCAL_DNS dst-address=!LOCAL_DNS in-interface-list=LAN dst-port=53 log=no log-prefix=""

# Port forward 80 and 443 for external web access
chain=dstnat action=dst-nat to-addresses=LOCAL_WEBSERVER to-ports=8000 protocol=tcp in-interface=ether1 dst-port=80 log=no log-prefix=""
chain=dstnat action=dst-nat to-addresses=LOCAL_WEBSERVER to-ports=8000 protocol=tcp in-interface=ether1 dst-port=443 log=no log-prefix=""
```