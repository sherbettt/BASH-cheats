[Настройка Bind как кэширующего или перенаправляющего DNS-сервера в Ubuntu 14.04](https://www.8host.com/blog/nastrojka-bind-kak-keshiruyushhego-ili-perenapravlyayushhego-dns-servera-v-ubuntu-14-04/)

### 1. установка:
```bash
sudo apt-get update
sudo apt-get install bind9 bind9utils bind9-doc
```

### 2. настройка:
отредактировать `/etc/bind/named.conf.options`, итоговые файл будет выглядет так:
```bash
acl goodclients {
192.168.56.2;
192.168.56.3;
localhost;
localnets;
};

options {
	directory "/var/cache/bind";
	recursion yes;
	allow-query { goodclients; };
	allow-query-cache { goodclients; };
	forwarders {
	 # Public DNS servers
	8.8.8.8;
	8.8.4.4;
	1.1.1.1;
	77.88.55.66;
	77.88.55.60;
	};
	// If there is a firewall between you and nameservers you want
	// to talk to, you may need to fix the firewall to allow multiple
	// ports to talk.  See http://www.kb.cert.org/vuls/id/800113

	// If your ISP provided one or more IP addresses for stable 
	// nameservers, you probably want to use them as forwarders.  
	// Uncomment the following block, and insert the addresses replacing 
	// the all-0's placeholder.

	// forwarders {
	// 	0.0.0.0;
	// };

	//========================================================================
	// If BIND logs error messages about the root key being expired,
	// you will need to update your keys.  See https://www.isc.org/bind-keys
	//========================================================================
	#dnssec-enable yes;
	dnssec-validation auto;
	auth-nxdomain no;    # conform to RFC1035
	listen-on { any; };
	listen-on-v6 { any; };
	#version "not currently available";         # Hide Real server version
	#hostname "hidden";                         # Hide Server name
	#server-id "none";                          # Hide Server ID
};
```

### 3. проверка:
```bash
cd /etc/bind/
named-checkconf
systemctl restart named.service
tail -f /var/log/syslog
```




