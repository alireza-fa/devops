برای راه‌اندازی HTTP پروکسی در کنار Outline، می‌توانید از ابزارهایی مانند Squid یا HAProxy استفاده کنید. مراحل زیر را برای نصب و پیکربندی Squid به عنوان HTTP پروکسی دنبال کنید:

1. نصب Squid:
sudo apt update
sudo apt install squid -y

2. پیکربندی Squid:
فایل پیکربندی Squid را باز کنید:
sudo nano /etc/squid/squid.conf

3. تنظیمات زیر را به فایل اضافه کنید (یا تنظیمات موجود را ویرایش کنید):
http_port 3128
http_access allow all

4. دسترسی از راه دور را فعال کنید - قسمت http_access allow لازم است تا بتوانید از سیستم‌های دیگر به آن متصل شوید.

5. سرویس Squid را راه‌اندازی مجدد کنید:
sudo systemctl restart squid

6. از باز بودن پورت در فایروال اطمینان حاصل کنید:
sudo ufw allow 3128/tcp

برای استفاده در سیستم‌های دیگر، متغیر محیطی HTTP_PROXY را به صورت زیر تنظیم کنید:
export HTTP_PROXY=http://IP_SERVER:3128
export HTTPS_PROXY=http://IP_SERVER:3128


1. خطر فیلتر شدن: بله، استفاده از HTTP پروکسی به صورت باز می‌تواند خطر شناسایی و فیلتر شدن را داشته باشد. پروکسی HTTP استاندارد رمزگذاری نمی‌شود و ترافیک آن قابل شناسایی است. برای کاهش این خطر، می‌توانید:
   - از HTTPS پروکسی استفاده کنید
   - پورت غیراستاندارد انتخاب کنید
   - محدودیت IP اعمال کنید

2. اضافه کردن احراز هویت: بله، می‌توانید به Squid احراز هویت اضافه کنید:

# ایجاد فایل پسورد
sudo apt install apache2-utils
sudo touch /etc/squid/passwords
sudo htpasswd -c /etc/squid/passwords username

سپس تنظیمات زیر را به فایل squid.conf اضافه کنید:

auth_param basic program /usr/lib/squid/basic_ncsa_auth /etc/squid/passwords
auth_param basic realm Squid proxy-caching web server
acl authenticated proxy_auth REQUIRED
http_access allow authenticated
http_access deny all

برای استفاده با نام کاربری و رمز عبور:
export HTTP_PROXY=http://username:password@IP_SERVER:3128
export HTTPS_PROXY=http://username:password@IP_SERVER:3128

3. استفاده از دامنه: بله، می‌توانید از Nginx به عنوان reverse proxy استفاده کنید:

sudo apt install nginx

ایجاد فایل پیکربندی برای دامنه:

sudo nano /etc/nginx/sites-available/asir.example.com

محتوای فایل:

server {
    listen 80;
    server_name asir.example.com;

    location / {
        proxy_pass http://127.0.0.1:3128;
        proxy_set_header Host $host;
        proxy_set_header X-Real-IP $remote_addr;
        proxy_set_header X-Forwarded-For $proxy_add_x_forwarded_for;
        proxy_set_header X-Forwarded-Proto $scheme;
    }
}

سپس آن را فعال کنید:

sudo ln -s /etc/nginx/sites-available/asir.example.com /etc/nginx/sites-enabled/
sudo nginx -t
sudo systemctl restart nginx

شما همچنین نیاز به نصب Let's Encrypt برای رمزگذاری HTTPS خواهید داشت:

sudo apt install certbot python3-certbot-nginx
sudo certbot --nginx -d asir.example.com

با این تنظیمات، درخواست‌های ارسال شده به asir.example.com به پروکسی Squid شما در پورت 3128 هدایت می‌شوند و ارتباط با SSL رمزگذاری می‌شود، که امنیت را افزایش می‌دهد.