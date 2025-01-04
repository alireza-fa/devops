# Installation Ansible

````
Install dependencies and configure Ansible Repository
````
````
Install ansible dependencies by running the following apt command,
````
````
sudo apt install -y software-properties-common
````

Once the dependencies are installed then configure PPA repository for ansible, run
````
sudo add-apt-repository --yes --update ppa:ansible/ansible
````

Now update repository by running beneath apt command.
````
sudo apt update
````

Install latest version of ansible
Now we are ready to install latest version of Ansible on Ubuntu 20.04 LTS / 21.04, run following command.
````
sudo apt install -y ansible
````

After the successful installation of Ansible, verify its version by executing the command
````
ansible --version
````

توضیحات:

کانفیگ ansible در آدرس زیر قرار می گیرد:
````
~/.ansible/ansible.cfg
````
یا اینکه در این آدرس قرار می گیرد:
````
/etc/ansible/ansible.cfg
````

اگه کانفیگتون رو توی ~/.ansible/ansible.cfg بذارید اعمال میشه. اگه توی /etc/ansible/ansible.cfg هم بذارید
هم اعمال میشه منتها برای همه ی یوزر هاتون.

همچنین میتونید per project یک فایل ansible جدا داشته باشید و داخل پروژتون یک فایل ansible.cfg رار م دید.

معمولا اولین کاری که میکنیم اینه پینگ میگیریم ببینیم ansible وضعیتش چجوری هستش:

ansible localhost -m ping

این پینگ گرفتن شبیه پینگ معول که میگیریم نیست. انسیبل میره چک میکنه و به اون ادرسی که مشخص
کردیم ssh میزنه و اگه اوکی بود به ما پینگ رو برمیگردونه.

برای اجرای دستور ping روی hosts.yml:
````
ansible all -i inventory/hosts.yml -m ping
````

کپی کردن یک فایل از لوکال هاست در نود ها:
````
asnible-playbook -i inventory/hosts.yml playbook.yml
````

## Gather facts
وقتی ansible به یه هاست ssh میزنه بصورت پیشفرض میره و کلی gather fact میاره که یه سری متغیر هایی هستش که اون
هاست داره.
مثلا os اون هاست چیه. میتونیم بیایم بر اساس os فیلتر کنیم که توی اونی که مثلا لینوکسه فلان 
حرتو بزن روی اونی که ویندوزه فلان حرکت.

از طریق دستور زیر میتونیم gather fact هارو ببینیم:
````
ansible localhost -m setup
````

فیلتر کردن gather fact ها:
````
ansible localhost -m setup -a "filter=ansible_os_family"
````

نکته:

توی کامند ها با -m ماژول رو میدیم و با -a آپشن های ماژول رو میدیم.
با استفاده از -i میایم inventory رو مشخص می کنیم.
