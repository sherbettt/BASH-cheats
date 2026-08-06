Простой пример motd в Debian12.

```bash
root@semaphore:~# ls -la /etc/update-motd.d/
total 16
drwxr-xr-x  2 root root 4096 Sep 26  2025 .
drwxr-xr-x 78 root root 4096 May 18 13:45 ..
-rwxr-xr-x  1 root root  363 Sep 26  2025 10-uname
-rwxr-xr-x  1 root root  589 Sep 26  2025 20-memory
root@semaphore:~# ccat /etc/update-motd.d/10-uname 
#!/bin/sh

# Memory and disk info
echo -e "\033[1;34mResources:\033[0m"
echo -e "  > Memory: \033[1;32m$(free -h | awk '/Mem:/ {print $3 " / " $2 " used"}')\033[0m"
echo -e "  > Disk: \033[1;32m$(df -h / | awk 'NR==2 {print $4 " free of " $2 " (" $5 " used)"}')\033[0m"
echo -e "  > Load: \033[1;33m$(cat /proc/loadavg | awk '{print $1 ", " $2 ", " $3}')\033[0m"
root@semaphore:~# ccat /etc/update-motd.d/20-memory 
#!/bin/sh
#uname -snrvm

# System information (short version)
echo -e "\033[1;34mSystem info:\033[0m"
echo -e "  > User: \033[1;93m$(whoami)\033[0m@\033[1;92m$(hostname)\033[0m"
echo -e "  > OS: \033[1;36m$(grep PRETTY_NAME /etc/os-release 2>/dev/null | cut -d= -f2 | tr -d '"' || uname -s)\033[0m"
echo -e "  > Kernel: \033[1;35m$(uname -r)\033[0m"
echo -e "  > Architecture: \033[1;35m$(uname -m)\033[0m"
echo -e "  > Uptime: \033[1;33m$(uptime -p 2>/dev/null | sed 's/up //' || uptime)\033[0m"
echo -e "  > Shell: \033[1;36m$SHELL\033[0m"
echo -e "  > Terminal: \033[1;36m$TERM\033[0m"
```

