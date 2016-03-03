#!/bin/sh
#准备环境
mkdir -p /usr/local/install/src/Packages
cp -r Packages/* /usr/local/install/src/Packages/
cp -r Conf /usr/local/install/src/
#关闭SELINUX
sed -i 's/SELINUX=enforcing/#SELINUX=enforcing/g' /etc/selinux/config
sed -i 's/SELINUXTYPE=targeted/#SELINUXTYPE=targeted/g' /etc/selinux/config
sed -i '$a SELINUX=disabled' /etc/selinux/config
setenforce 0
#yum安装lnmp环境包
yum install -y apr* autoconf xcb-util automake bison bzip2 bzip2* cloog-ppl ncurses-devel bison compat* cpp curl curl-devel fontconfig fontconfig-devel freetype freetype* freetype-devel gcc gcc-c++ gtk+-devel gd gettext gettext-devel glibc kernel kernel-headers keyutils keyutils-libs-devel krb5-devel libcom_err-devel libpng* libpng-devel libjpeg* libsepol-devel libselinux-devel libstdc++-devel libtool* libgomp libxml2 libxml2-devel libXpm* libX* libtiff libtiff*  make mpfr ncurses* openssl nasm nasm* openssl-devel patch pcre-devel perl php-common php-gd policycoreutils ppl telnet t1lib t1lib*  wget zlib-devel
#同步本地时间
/usr/sbin/ntpdate cn.pool.ntp.org
#setup_end &&mysql_start
#安装cmake
cd /usr/local/install/src/Packages
tar zxvf cmake-3.0.2.tar.gz
cd cmake-3.0.2
./configure
make && make install

#配置安装mysql
groupadd mysql
useradd -g mysql mysql -s /bin/false
mkdir -p /data/mysql
chown -R mysql:mysql /data/mysql
mkdir -p /usr/local/install/mysql
cd /usr/local/install/src/Packages
tar zxvf mysql-5.6.22.tar.gz
cd mysql-5.6.22
cmake -DCMAKE_INSTALL_PREFIX=/usr/local/install/mysql -DMYSQL_DATADIR=/data/mysql -DSYSCONFDIR=/etc -DENABLE_DOWNLOADS=1
make &&make install
rm -rf /etc/my.cnf
cd /usr/local/install/mysql
./scripts/mysql_install_db --user=mysql --basedir=/usr/local/install/mysql --datadir=/data/mysql
ln -s /usr/local/install/mysql/my.cnf /etc/my.cnf
cp ./support-files/mysql.server  /etc/rc.d/init.d/mysqld
chmod 755 /etc/init.d/mysqld
chkconfig --level 2345 mysqld on
echo 'basedir=/usr/local/install/mysql/' >> /etc/rc.d/init.d/mysqld
echo 'datadir=/data/mysql/' >>/etc/rc.d/init.d/mysqld
echo 'export PATH=$PATH:/usr/local/install/mysql/bin' >> /etc/profile
source  /etc/profile
mkdir /usr/local/install/mysql/lib/mysql
ln -s /usr/local/install/mysql/lib/mysql /usr/lib/mysql
ln -s /usr/local/install/mysql/include/mysql /usr/include/mysql
mkdir /var/lib/mysql
ln -s /tmp/mysql.sock  /var/lib/mysql/mysql.sock
rm -rf /data/mysql/*
echo 'innodb_buffer_pool_size = 32M' >> /usr/local/install/mysql/my.cnf
cd /usr/local/install/mysql
./scripts/mysql_install_db --user=mysql --basedir=/usr/local/install/mysql --datadir=/data/mysql
service mysqld restart
#设置mysql密码
/usr/local/install/mysql/bin/mysqld_safe --user=mysql &
/usr/local/install/mysql/bin/mysqladmin -uroot password 123

#mysql_end　＆＆nginx_start
#安装pcre
cd /usr/local/install/src/Packages
mkdir /usr/local/install/pcre
tar zxvf pcre-8.36.tar.gz
cd pcre-8.36
./configure --prefix=/usr/local/install/pcre
make && make install
#安装openssl
cd /usr/local/install/src/Packages
mkdir /usr/local/install/openssl
tar zxvf openssl-1.0.1j.tar.gz
cd openssl-1.0.1j
./config --prefix=/usr/local/install/openssl
make && make install
echo 'export PATH=$PATH:/usr/local/install/openssl/bin' >> /etc/profile
source  /etc/profile
#安装zlib
cd /usr/local/install/src/Packages
mkdir /usr/local/install/zlib
tar zxvf zlib-1.2.8.tar.gz
cd zlib-1.2.8
./configure --prefix=/usr/local/install/zlib
make && make install
#安装libunwind
cd /usr/local/install/src/Packages
tar zxvf libunwind-1.1.tar.gz
cd libunwind-1.1
./configure
make && make install
#配置安装nginx
groupadd www
useradd -s /bin/bash -g www -M www
cd /usr/local/install/src/Packages
tar zxvf nginx-1.6.2.tar.gz
cd nginx-1.6.2
./configure --prefix=/usr/local/install/nginx  --without-http_memcached_module --user=www --group=www --with-http_stub_status_module --with-http_sub_module  --with-http_ssl_module  --with-http_gzip_static_module  --with-openssl=/usr/local/install/src/Packages/openssl-1.0.1j --with-zlib=/usr/local/install/src/Packages/zlib-1.2.8 --with-pcre=/usr/local/install/src/Packages/pcre-8.36
make && make install
/usr/local/install/nginx/sbin/nginx
cp /usr/local/install/src/Conf/nginx  /etc/rc.d/init.d/nginx
chmod 775 /etc/rc.d/init.d/nginx
chkconfig --level 2345 nginx on
/etc/rc.d/init.d/nginx restart

#nginx_end＆＆php_start
#安装yasm
cd  /usr/local/install/src/Packages
tar zxvf yasm-1.3.0.tar.gz
cd yasm-1.3.0
./configure
make && make install
#安装libmcrypt
cd /usr/local/install/src/Packages
tar zxvf libmcrypt-2.5.8.tar.gz
cd libmcrypt-2.5.8
./configure
make && make install
#安装libvpx
cd  /usr/local/install/src/Packages
tar xvf libvpx-v1.3.0.tar.bz2
cd libvpx-v1.3.0
./configure --prefix=/usr/local/install/libvpx --enable-shared --enable-vp9
make && make install
#安装tiff
cd  /usr/local/install/src/Packages
tar zxvf tiff-4.0.3.tar.gz
cd tiff-4.0.3
./configure --prefix=/usr/local/install/tiff --enable-shared
make && make install
#安装libpng
cd  /usr/local/install/src/Packages
tar zxvf libpng-1.6.15.tar.gz
cd libpng-1.6.15
./configure  --prefix=/usr/local/install/libpng --enable-shared
make && make install
#安装freetype
cd  /usr/local/install/src/Packages
tar zxvf freetype-2.5.4.tar.gz
cd  freetype-2.5.4
./configure --prefix=/usr/local/install/freetype --enable-shared -without-png
make && make install
#安装jpeg
cd  /usr/local/install/src/Packages
tar zxvf jpegsrc.v9a.tar.gz
cd jpeg-9a
./configure --prefix=/usr/local/install/jpeg --enable-shared
make && make install
#安装libgd
cd /usr/local/install/src/Packages
tar zxvf libgd-2.1.0.tar.gz
cd libgd-2.1.0
./configure  --prefix=/usr/local/install/libgd  --enable-shared  --with-jpeg=/usr/local/install/jpeg  --with-png=/usr/local/install/libpng  --with-freetype=/usr/local/install/freetype  --with-fontconfig=/usr/local/install/freetype  --with-tiff=/usr/local/install/tiff  --with-vpx=/usr/local/install/libvpx  --with-xpm=/usr/
make && make install
#安装t1lib
cd /usr/local/install/src/Packages
tar zxvf t1lib-5.1.2.tar.gz
cd t1lib-5.1.2
./configure --prefix=/usr/local/install/t1lib --enable-shared
make without_doc && make install
#安装libiconv
cd /usr/local/install/src/Packages
tar zxvf libiconv-1.14.tar.gz
cd libiconv-1.14
./configure --prefix=/usr/local/install/libiconv
make && make install
#安装配置php
mv /usr/lib/libltdl.so  /usr/lib/libltdl.so-bak
\cp -frp /usr/lib64/libltdl.so*  /usr/lib/
\cp -frp /usr/lib64/libXpm.so*   /usr/lib/
export LD_LIBRARY_PATH=/usr/local/install/libgd/lib
cd /usr/local/install/src/Packages
tar -zvxf php-5.6.3.tar.gz
cd php-5.6.3
sed -i 's/return "unknown";/ return "9a";/g' /usr/local/install/src/Packages/php-5.6.3/ext/gd/libgd/gd_jpeg.c
./configure --prefix=/usr/local/install/php --with-config-file-path=/usr/local/install/php/etc --with-mysql=/usr/local/install/mysql --with-mysqli=/usr/local/install/mysql/bin/mysql_config --with-mysql-sock=/tmp/mysql.sock --with-pdo-mysql=/usr/local/install/mysql --with-gd --with-png-dir=/usr/local/install/libpng --with-jpeg-dir=/usr/local/install/jpeg --with-freetype-dir=/usr/local/install/freetype --with-xpm-dir=/usr/ --with-vpx-dir=/usr/local/install/libvpx/ --with-zlib-dir=/usr/local/install/zlib --with-t1lib=/usr/local/install/t1lib --with-iconv --enable-libxml --enable-xml --enable-bcmath --enable-shmop --enable-sysvsem --enable-inline-optimization --enable-opcache --enable-mbregex --enable-fpm --enable-mbstring --enable-ftp --enable-gd-native-ttf --with-openssl --enable-pcntl --enable-sockets --with-xmlrpc --enable-zip --enable-soap --without-pear --with-gettext --enable-session --with-mcrypt --with-curl --enable-ctype --disable-fileinfo
make && make install
cp php.ini-production /usr/local/install/php/etc/php.ini
rm -rf /etc/php.ini
ln -s /usr/local/install/php/etc/php.ini /etc/php.ini
cp /usr/local/install/php/etc/php-fpm.conf.default  /usr/local/install/php/etc/php-fpm.conf
ln -s /usr/local/install/php/etc/php-fpm.conf /etc/php-fpm.conf
cp /usr/local/install/src/Packages/php-5.6.3/sapi/fpm/init.d.php-fpm  /etc/rc.d/init.d/php-fpm
chmod +x /etc/rc.d/init.d/php-fpm
chkconfig --level 2345 php-fpm on
sed -i '/\[global\]/a pid = run/php-fpm.pid' /usr/local/install/php/etc/php-fpm.conf
sed -i 's/user = nobody/ user = www /g' /usr/local/install/php/etc/php-fpm.conf
sed -i 's/group = nobody/ group = www /g' /usr/local/install/php/etc/php-fpm.conf
sed -i 's/;date.timezone =/ date.timezone = PRC /g' /usr/local/install/php/etc/php.ini
sed -i 's/expose_php = On/ expose_php = Off /g' /usr/local/install/php/etc/php.ini
sed -i 's/short_open_tag = Off/ short_open_tag = On /g' /usr/local/install/php/etc/php.ini
sed -i 's/disable_functions =/ disable_functions = passthru,exec,system,chroot,scandir,chgrp,chown,shell_exec,proc_open,proc_get_status,ini_alter,ini_alter,ini_restore,dl,openlog,syslog,readlink,symlink,popepassthru,stream_socket_server,escapeshellcmd,dll,popen,disk_free_space,checkdnsrr,checkdnsrr,getservbyname,getservbyport,disk_total_space,posix_ctermid,posix_get_last_error,posix_getcwd, posix_getegid,posix_geteuid,posix_getgid, posix_getgrgid,posix_getgrnam,posix_getgroups,posix_getlogin,posix_getpgid,posix_getpgrp,posix_getpid, posix_getppid,posix_getpwnam,posix_getpwuid, posix_getrlimit, posix_getsid,posix_getuid,posix_isatty, posix_kill,posix_mkfifo,posix_setegid,posix_seteuid,posix_setgid, posix_setpgid,posix_setsid,posix_setuid,posix_strerror,posix_times,posix_ttyname,posix_uname /g' /usr/local/install/php/etc/php.ini
sed -i '/#user  nobody;/a\user www www;' /usr/local/install/nginx/conf/nginx.conf
sed -i 's/index  index.html index.htm;/ index  index.html index.htm index.php; /g' /usr/local/install/nginx/conf/nginx.conf
sed -i '/# pass the PHP scripts to FastCGI server listening on 127.0.0.1:9000/a }' /usr/local/install/nginx/conf/nginx.conf
sed -i '/# pass the PHP scripts to FastCGI server listening on 127.0.0.1:9000/a include fastcgi_params;' /usr/local/install/nginx/conf/nginx.conf
sed -i '/# pass the PHP scripts to FastCGI server listening on 127.0.0.1:9000/a fastcgi_param SCRIPT_FILENAME $document_root$fastcgi_script_name;' /usr/local/install/nginx/conf/nginx.conf
sed -i '/# pass the PHP scripts to FastCGI server listening on 127.0.0.1:9000/a fastcgi_index index.php;' /usr/local/install/nginx/conf/nginx.conf
sed -i '/# pass the PHP scripts to FastCGI server listening on 127.0.0.1:9000/a fastcgi_pass 127.0.0.1:9000;' /usr/local/install/nginx/conf/nginx.conf
sed -i '/# pass the PHP scripts to FastCGI server listening on 127.0.0.1:9000/a root html;' /usr/local/install/nginx/conf/nginx.conf
sed -i '/# pass the PHP scripts to FastCGI server listening on 127.0.0.1:9000/a location ~ \.php$ {' /usr/local/install/nginx/conf/nginx.conf
rm -rf /usr/local/install/nginx/html/*
echo -e "<?php\nphpinfo();\n?>" > /usr/local/install/nginx/html/index.php
/etc/init.d/nginx restart
service php-fpm  start

#php_end　＆＆php-ext_start
ln -s /usr/local/install/php/lib/php/extensions /usr/lib64/extensions
#安装PHP加密工具
cd /usr/local/install/src/Packages
tar zxvf ioncube_loaders_lin_x86-64.tar.gz
mkdir /usr/local/install/ioncube
\cp -rf ioncube/*  /usr/local/install/ioncube
sed -i '$a [ionCube Loader] ' /usr/local/install/php/etc/php.ini
sed -i '$a zend_extension="/usr/local/install/ioncube/ioncube_loader_lin_5.6.so" ' /usr/local/install/php/etc/php.ini
#安装PHP程序的保护系统
cd /usr/local/install/src/Packages
tar zxvf suhosin-suhosin-0.9.36.tar.gz
cd suhosin-suhosin-0.9.36
/usr/local/install/php/bin/phpize
./configure  --with-php-config=/usr/local/install/php/bin/php-config
make && make install
sed -i '$a extension="suhosin.so" ' /usr/local/install/php/etc/php.ini
#安装memcache
cd /usr/local/install/src/Packages
tar zxvf memcache-2.2.7.tgz
cd memcache-2.2.7
/usr/local/install/php/bin/phpize
./configure  --with-php-config=/usr/local/install/php/bin/php-config
make && make install
sed -i '$a extension="memcache.so" ' /usr/local/install/php/etc/php.ini
#安装re2c（re2c是一个将正则表达式转化成基于C语言标识的预处理器）
cd /usr/local/install/src/Packages
tar -zxvf re2c-0.13.5.tar.gz
cd re2c-0.13.5
./configure
make && make install
#安装ImageMagick
cd /usr/local/install/src/Packages
tar zxvf ImageMagick-6.8.9-3.tar.gz
cd ImageMagick-6.8.9-3
./configure --prefix=/usr/local/install/imagemagick
make && make install
export PKG_CONFIG_PATH=/usr/local/install/imagemagick/lib/pkgconfig/
#安装imagick
cd /usr/local/install/src/Packages
tar zxvf imagick-3.1.2.tgz
cd imagick-3.1.2
/usr/local/install/php/bin/phpize
./configure  --with-php-config=/usr/local/install/php/bin/php-config --with-imagick=/usr/local/install/imagemagick
make && make install
sed -i '$a extension="imagick.so" ' /usr/local/install/php/etc/php.ini
#安装MagickWand
cd /usr/local/install/src/Packages
tar zxvf MagickWandForPHP-1.0.9-2.tar.gz
cd MagickWandForPHP-1.0.9
/usr/local/install/php/bin/phpize
./configure  --with-php-config=/usr/local/install/php/bin/php-config --with-magickwand=/usr/local/install/imagemagick
make && make install
sed -i '$a extension="magickwand.so" ' /usr/local/install/php/etc/php.ini
#安装phpredis
cd /usr/local/install/src/Packages
tar zxvf phpredis-2.2.6.tar.gz
cd phpredis-2.2.6
/usr/local/install/php/bin/phpize
./configure --with-php-config=/usr/local/install/php/bin/php-config
make && make install
sed -i '$a extension="redis.so" ' /usr/local/install/php/etc/php.ini
#安装mongo
cd /usr/local/install/src/Packages
tar  zxvf mongo-1.5.8.tgz
cd mongo-1.5.8
/usr/local/install/php/bin/phpize
./configure --with-php-config=/usr/local/install/php/bin/php-config
make && make install
sed -i '$a extension="mongo.so" ' /usr/local/install/php/etc/php.ini
service php-fpm restart

#替换配置文件
cd /usr/local/install/src
cp -rf Conf/index.php  /usr/local/install/nginx/html/index.php
cp -rf Conf/gd.php  /usr/local/install/nginx/html/gd.php
cp -rf Conf/server.php  /usr/local/install/nginx/html/server.php
cp -rf Conf/phpinfo.php  /usr/local/install/nginx/html/phpinfo.php
chown www.www /usr/local/install/nginx/html/ -R
chmod 700 /usr/local/install/nginx/html/ -R
mv /usr/local/install/nginx/conf/nginx.conf /usr/local/install/nginx/conf/nginx.conf.bak
cp -rf Conf/nginx.conf  /usr/local/install/nginx/conf/nginx.conf
cp -rf Conf/rewrite.conf  /usr/local/install/nginx/conf/rewrite.conf
mkdir /usr/local/install/nginx/conf/vhost
cp -rf Conf/localhost.conf /usr/local/install/nginx/conf/vhost/localhost.conf

#安装完成
iptables -A INPUT -p tcp -m multiport --dport 80,3306,9000 -j ACCEPT
service iptables save
service iptables restart
service mysqld restart
service php-fpm restart
service nginx restart
echo "LNMP环境安装已完成！" &&sleep 10