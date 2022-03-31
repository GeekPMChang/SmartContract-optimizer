import ssl
from urllib.request import urlopen

print(urlopen('https://www.howsmyssl.com/a/check', context=ssl._create_unverified_context()).read())