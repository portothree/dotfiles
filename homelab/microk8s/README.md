# microk8s

## Used addons

```
dns storage metallb
```

-   `metallb`
    Finding IP address pool as metallb need some IPV4 addresses:

    ```
    $ ip a s
    1: ens160: <BROADCAST,MULTICAST,UP,LOWER_UP> mtu 1500 qdisc mq state UP group default qlen 1000
       [...]
      inet 10.240.1.59/24 brd 10.240.1.255 scope global dynamic noprefixroute ens160
         valid_lft 425669sec preferred_lft 421269sec
    	[...]
    ```

    The ens160 is my control-plane network interface and as you see its ip range is 10.240.1.59/24 so i'm going to assign a set of ip address in this network:

    ```
    $ sipcalc 10.240.1.59/24
    -[ipv4 : 10.240.1.59/24] - 0

    [CIDR]
    Host address            - 10.240.1.59
    Host address (decimal)  - 183500115
    Host address (hex)      - AF0031B
    Network address         - 10.240.1.0
    Network mask            - 255.255.255.0
    Network mask (bits)     - 24
    Network mask (hex)      - FFFFF000
    Broadcast address       - 10.240.1.255
    Cisco wildcard          - 0.0.0.255
    Addresses in network    - 256
    Network range           - 10.240.1.0 - 10.240.1.255
    Usable range            - 10.240.1.1 - 10.240.1.254
    ```

    now i'm going to take 10 ip addresses from the Usable range and assign it to MetalLB.

    `microk8s enable metallb:10.240.1.100-10.240.1.110`

    Currently in the `192.168.1.100` cluster the range for metallb is `192.168.1.200-192.168.1.500`.
