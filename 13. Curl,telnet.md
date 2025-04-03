§ Соединение по сети.
1) `telnet example.com 80`

2) `curl http://example.com -i`    #вывести заголовок
	- `curl http://example.com -I`   #убрать тело в запросе
	- `curl -X GET http://example.com -I`   #равносильно методу GET в telnet
	- `curl -X POST http://example.com -I`
	- `curl -X GET cheat.sh`
	- `curl cht.sh/:styles`
	- `curl -I ya.ru`
	
Сертификаты:
1) `openssl s_client --showcerts --servername www.ya.ru --connect www.ya.ru:443`
	- `openssl s_client --showcerts --servername www.ya.ru --connect www.ya.ru:443 | openssl x509 --dates` , где x509 - сертификаты

https://httpbin.org/post
<br/> https://httpbin.org/get
