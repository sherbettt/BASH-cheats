#!/usr/bin/python3
import requests

try:
    external_ip = requests.get('https://api.ipify.org').text
    print(f"External IP: {external_ip}")
except Exception as e:
    print(f"Error: {e}")
