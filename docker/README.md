# Docker Documenation

### نصب داکر
با وارد شدن به آدرس زیر:
````
https://get.docker.com
````
میتونید دستوری که فایل sh نصب داکر روی لینوکس هستش رو بردارید و روی سیستم خودتون 
نصبش کنید.

برای تغییر کانفیگ داکر می تونیم از روش های زیر استفاده کنیم:

- 1: تعییر فایل  daemon.json
````
/etc/docker/daemon.json
````
بصورت پیشفرض وجود ندارد و باید خودتون بسازیدش.

- روش بعدی قرار دادن کانفیگ در systemd هستش:
````
/etc/systemd/system/docker.service.d/
````
داهل این دایکتوری هر فایل با فرمت conf و اسم دلخواهی که قرار بدید overwrite میشه 
روی کانفیگ پیشفرض داکر.

- همچنین با دستور زیر:
````
sudo systemctl edit docker
````
میاد یک فایل کانفیگ در مسیر systemd که بالا گفتیم ایجاد میکنه و هر چی که وارد کنید روی کانفیگ داکر اعمالش میکنه.

مثال:
````
nano /etc/docker/daemon.json
````

```nano
{
    "bip": "127.100.1.0/27"
}
```

systemctl restart docker

systemctl status docker

ifconfif
````
