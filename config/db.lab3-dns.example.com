$TTL    604800
@       IN      SOA     ns1.lab3-dns.example.com. root.lab3-dns.example.com. (
                              4         ; Serial
                         604800         ; Refresh
                          86400         ; Retry
                        2419200         ; Expire
                         604800 )       ; Negative Cache TTL
;
; name servers - NS records
@       IN      NS      ns1.lab3-dns.example.com.
ns1.lab3-dns.example.com.     IN      A     127.0.0.1


@       IN      A       10.0.0.1
