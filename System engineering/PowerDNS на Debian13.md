Статьи с подсказками:
- [Настройка кластера PowerDNS на Rocky Linux](https://www.dmosk.ru/instruktions.php?object=powerdns-cluster)
- [altlinux.org/PowerDNS](https://www.altlinux.org/PowerDNS)
---------
<br/>


#  Установка 
Переходим на оф. ресурс https://repo.powerdns.com/ и смотрим примеры установок. В нашем случае - stable установка.

## PowerDNS Authoritative Server - version 5.0.X (stable)

Create the file **'/etc/apt/sources.list.d/pdns.list'** with this content:
```
deb [signed-by=/etc/apt/keyrings/auth-50-pub.asc] http://repo.powerdns.com/debian trixie-auth-50 main
```
Put this in **'/etc/apt/preferences.d/auth-50'**:
```
Package: pdns-*
Pin: origin repo.powerdns.com
Pin-Priority: 600
```

and execute the following commands:
```
sudo install -d /etc/apt/keyrings; curl https://repo.powerdns.com/FD380FBB-pub.asc | sudo tee /etc/apt/keyrings/auth-50-pub.asc &&
sudo apt-get update &&
sudo apt-get install pdns-server
```







