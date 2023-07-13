#### SSHTunnel traffic control and monitoring [[https://img.shields.io/badge/V%201%200-8A2BE2]](https://img.shields.io/badge/just%20the%20message-8A2BE2)
setting up traffic usage limit and checking the status base on username in ssh-tunnel VPN

  - Remember to run the script with root privileges to access the necessary iptables and iproute2 commands

#### Running the script with following command
```
wget -4 https://raw.githubusercontent.com/opiran-club/ssh-traffic-limit/main/Usage-limit.sh && chmod +x Usage-limit.sh && ./Usage-limit.sh
```

#### to modify the data limit or checking the status of usage
```
./Usage-limit.sh
```
