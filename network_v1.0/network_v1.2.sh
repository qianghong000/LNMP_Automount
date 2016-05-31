#!/bin/sh
#准备环境
INS_PATH=/usr/local
mkdir -p $INS_PATH/src/Packages
cp -r Packages/* $INS_PATH/src/Packages/
cp -r Conf $INS_PATH/src/
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
cd $INS_PATH/src/Packages
tar zxvf cmake-3.0.2.tar.gz
cd cmake-3.0.2
./configure
make && make install

#配置安装mysql
groupadd mysql
useradd -g mysql mysql -s /bin/false
mkdir -p /data/mysql
chown -R mysql:mysql /data/mysql
mkdir -p $INS_PATH/mysql
cd $INS_PATH/src/Packages
tar zxvf mysql-5.6.22.tar.gz
cd mysql-5.6.22
cmake -DCMAKE_INSTALL_PREFIX=$INS_PATH/mysql -DMYSQL_DATADIR=/data/mysql -DSYSCONFDIR=/etc -DENABLE_DOWNLOADS=1
make &&make install
rm -rf /etc/my.cnf
cd $INS_PATH/mysql
./scripts/mysql_install_db --user=mysql --basedir=$INS_PATH/mysql --datadir=/data/mysql
ln -s $INS_PATH/mysql/my.cnf /etc/my.cnf
cp ./support-files/mysql.server  /etc/rc.d/init.d/mysqld
chmod 755 /etc/init.d/mysqld
chkconfig --level 2345 mysqld on
echo 'basedir=$INS_PATH/mysql/' >> /etc/rc.d/init.d/mysqld
echo 'datadir=/data/mysql/' >>/etc/rc.d/init.d/mysqld
echo 'export PATH=$PATH:/usr/local/mysql/bin' >> /etc/profile
source  /etc/profile
mkdir $INS_PATH/mysql/lib/mysql
ln -s $INS_PATH/mysql/lib/mysql /usr/lib/mysql
ln -s $INS_PATH/mysql/bin/mysql /usr/bin/
ln -s $INS_PATH/mysql/include/mysql /usr/include/mysql
mkdir /var/lib/mysql
ln -s /tmp/mysql.sock  /var/lib/mysql/mysql.sock
rm -rf /data/mysql/*
echo 'innodb_buffer_pool_size = 32M' >> $INS_PATH/mysql/my.cnf
cd $INS_PATH/mysql
./scripts/mysql_install_db --user=mysql --basedir=$INS_PATH/mysql --datadir=/data/mysql
service mysqld start
#设置mysql密码
$INS_PATH/mysql/bin/mysqld_safe --user=mysql &
$INS_PATH/mysql/bin/mysqladmin -uroot password 123

#mysql_end　＆＆nginx_start
#安装pcre
cd $INS_PATH/src/Packages
mkdir $INS_PATH/pcre
tar zxvf pcre-8.36.tar.gz
cd pcre-8.36
./configure --prefix=$INS_PATH/pcre
make && make install
#安装openssl
cd $INS_PATH/src/Packages
mkdir $INS_PATH/openssl
tar zxvf openssl-1.0.1j.tar.gz
cd openssl-1.0.1j
./config --prefix=$INS_PATH/openssl
make && make install
echo 'export PATH=$PATH:/usr/local/openssl/bin' >> /etc/profile
source  /etc/profile
#安装zlib
cd $INS_PATH/src/Packages
mkdir $INS_PATH/zlib
tar zxvf zlib-1.2.8.tar.gz
cd zlib-1.2.8
./configure --prefix=$INS_PATH/zlib
make && make install
#安装libunwind
cd $INS_PATH/src/Packages
tar zxvf libunwind-1.1.tar.gz
cd libunwind-1.1
./configure
make && make install
#配置安装nginx
groupadd www
useradd -s /bin/bash -g www -M www
cd $INS_PATH/src/Packages
tar zxvf nginx-1.6.2.tar.gz
cd nginx-1.6.2
./configure --prefix=$INS_PATH/nginx  --without-http_memcached_module --user=www --group=www --with-http_stub_status_module --with-http_sub_module  --with-http_ssl_module  --with-http_gzip_static_module  --with-openssl=$INS_PATH/src/Packages/openssl-1.0.1j --with-zlib=$INS_PATH/src/Packages/zlib-1.2.8 --with-pcre=$INS_PATH/src/Packages/pcre-8.36
make && make install
$INS_PATH/nginx/sbin/nginx
cp $INS_PATH/src/Conf/nginx  /etc/rc.d/init.d/nginx
chmod 775 /etc/rc.d/init.d/nginx
chkconfig --level 2345 nginx on
/etc/rc.d/init.d/nginx restart

#nginx_end＆＆php_start
#安装yasm
cd  $INS_PATH/src/Packages
tar zxvf yasm-1.3.0.tar.gz
cd yasm-1.3.0
./configure
make && make install
#安装libmcrypt
cd $INS_PATH/src/Packages
tar zxvf libmcrypt-2.5.8.tar.gz
cd libmcrypt-2.5.8
./configure
make && make install
#安装libvpx
cd  $INS_PATH/src/Packages
tar xvf libvpx-v1.3.0.tar.bz2
cd libvpx-v1.3.0
./configure --prefix=$INS_PATH/libvpx --enable-shared --enable-vp9
make && make install
#安装tiff
cd  $INS_PATH/src/Packages
tar zxvf tiff-4.0.3.tar.gz
cd tiff-4.0.3
./configure --prefix=$INS_PATH/tiff --enable-shared
make && make install
#安装libpng
cd  $INS_PATH/src/Packages
tar zxvf libpng-1.6.15.tar.gz
cd libpng-1.6.15
./configure  --prefix=$INS_PATH/libpng --enable-shared
make && make install
#安装freetype
cd  $INS_PATH/src/Packages
tar zxvf freetype-2.5.4.tar.gz
cd  freetype-2.5.4
./configure --prefix=$INS_PATH/freetype --enable-shared -without-png
make && make install
#安装jpeg
cd  $INS_PATH/src/Packages
tar zxvf jpegsrc.v9a.tar.gz
cd jpeg-9a
./configure --prefix=$INS_PATH/jpeg --enable-shared
make && make install
#安装libgd
cd $INS_PATH/src/Packages
tar zxvf libgd-2.1.0.tar.gz
cd libgd-2.1.0
./configure  --prefix=$INS_PATH/libgd  --enable-shared  --with-jpeg=$INS_PATH/jpeg  --with-png=$INS_PATH/libpng  --with-freetype=$INS_PATH/freetype  --with-fontconfig=$INS_PATH/freetype  --with-tiff=$INS_PATH/tiff  --with-vpx=$INS_PATH/libvpx  --with-xpm=/usr/
make && make install
#安装t1lib
cd $INS_PATH/src/Packages
tar zxvf t1lib-5.1.2.tar.gz
cd t1lib-5.1.2
./configure --prefix=$INS_PATH/t1lib --enable-shared
make without_doc && make install
#安装libiconv
cd $INS_PATH/src/Packages
tar zxvf libiconv-1.14.tar.gz
cd libiconv-1.14
./configure --prefix=$INS_PATH/libiconv
make && make install
#安装配置php
mv /usr/lib/libltdl.so  /usr/lib/libltdl.so-bak
\cp -frp /usr/lib64/libltdl.so*  /usr/lib/
\cp -frp /usr/lib64/libXpm.so*   /usr/lib/
export LD_LIBRARY_PATH=$INS_PATH/libgd/lib
cd $INS_PATH/src/Packages
tar -zvxf php-5.6.3.tar.gz
cd php-5.6.3
sed -i 's/return "unknown";/ return "9a";/g' $INS_PATH/src/Packages/php-5.6.3/ext/gd/libgd/gd_jpeg.c
./configure --prefix=$INS_PATH/php --with-config-file-path=$INS_PATH/php/etc --with-mysql=$INS_PATH/mysql --with-mysqli=$INS_PATH/mysql/bin/mysql_config --with-mysql-sock=/tmp/mysql.sock --with-pdo-mysql=$INS_PATH/mysql --with-gd --with-png-dir=$INS_PATH/libpng --with-jpeg-dir=$INS_PATH/jpeg --with-freetype-dir=$INS_PATH/freetype --with-xpm-dir=/usr/ --with-vpx-dir=$INS_PATH/libvpx/ --with-zlib-dir=$INS_PATH/zlib --with-t1lib=$INS_PATH/t1lib --with-iconv --enable-libxml --enable-xml --enable-bcmath --enable-shmop --enable-sysvsem --enable-inline-optimization --enable-opcache --enable-mbregex --enable-fpm --enable-mbstring --enable-ftp --enable-gd-native-ttf --with-openssl --enable-pcntl --enable-sockets --with-xmlrpc --enable-zip --enable-soap --without-pear --with-gettext --enable-session --with-mcrypt --with-curl --enable-ctype --disable-fileinfo
make && make install
cp php.ini-production $INS_PATH/php/etc/php.ini
rm -rf /etc/php.ini
ln -s $INS_PATH/php/etc/php.ini /etc/php.ini
cp $INS_PATH/php/etc/php-fpm.conf.default  $INS_PATH/php/etc/php-fpm.conf
ln -s $INS_PATH/php/etc/php-fpm.conf /etc/php-fpm.conf
cp $INS_PATH/src/Packages/php-5.6.3/sapi/fpm/init.d.php-fpm  /etc/rc.d/init.d/php-fpm
chmod +x /etc/rc.d/init.d/php-fpm
chkconfig --level 2345 php-fpm on
sed -i '/\[global\]/a pid = run/php-fpm.pid' $INS_PATH/php/etc/php-fpm.conf
sed -i 's/user = nobody/ user = www /g' $INS_PATH/php/etc/php-fpm.conf
sed -i 's/group = nobody/ group = www /g' $INS_PATH/php/etc/php-fpm.conf
sed -i 's/;date.timezone =/ date.timezone = PRC /g' $INS_PATH/php/etc/php.ini
sed -i 's/expose_php = On/ expose_php = Off /g' $INS_PATH/php/etc/php.ini
sed -i 's/short_open_tag = Off/ short_open_tag = On /g' $INS_PATH/php/etc/php.ini
sed -i 's/disable_functions =/ disable_functions = passthru,exec,system,chroot,scandir,chgrp,chown,shell_exec,proc_open,proc_get_status,ini_alter,ini_alter,ini_restore,dl,openlog,syslog,readlink,symlink,popepassthru,stream_socket_server,escapeshellcmd,dll,popen,disk_free_space,checkdnsrr,checkdnsrr,getservbyname,getservbyport,disk_total_space,posix_ctermid,posix_get_last_error,posix_getcwd, posix_getegid,posix_geteuid,posix_getgid, posix_getgrgid,posix_getgrnam,posix_getgroups,posix_getlogin,posix_getpgid,posix_getpgrp,posix_getpid, posix_getppid,posix_getpwnam,posix_getpwuid, posix_getrlimit, posix_getsid,posix_getuid,posix_isatty, posix_kill,posix_mkfifo,posix_setegid,posix_seteuid,posix_setgid, posix_setpgid,posix_setsid,posix_setuid,posix_strerror,posix_times,posix_ttyname,posix_uname /g' $INS_PATH/php/etc/php.ini
sed -i '/#user  nobody;/a\user www www;' $INS_PATH/nginx/conf/nginx.conf
sed -i 's/index  index.html index.htm;/ index  index.html index.htm index.php; /g' $INS_PATH/nginx/conf/nginx.conf
sed -i '/# pass the PHP scripts to FastCGI server listening on 127.0.0.1:9000/a }' $INS_PATH/nginx/conf/nginx.conf
sed -i '/# pass the PHP scripts to FastCGI server listening on 127.0.0.1:9000/a include fastcgi_params;' $INS_PATH/nginx/conf/nginx.conf
sed -i '/# pass the PHP scripts to FastCGI server listening on 127.0.0.1:9000/a fastcgi_param SCRIPT_FILENAME $document_root$fastcgi_script_name;' $INS_PATH/nginx/conf/nginx.conf
sed -i '/# pass the PHP scripts to FastCGI server listening on 127.0.0.1:9000/a fastcgi_index index.php;' $INS_PATH/nginx/conf/nginx.conf
sed -i '/# pass the PHP scripts to FastCGI server listening on 127.0.0.1:9000/a fastcgi_pass 127.0.0.1:9000;' $INS_PATH/nginx/conf/nginx.conf
sed -i '/# pass the PHP scripts to FastCGI server listening on 127.0.0.1:9000/a root html;' $INS_PATH/nginx/conf/nginx.conf
sed -i '/# pass the PHP scripts to FastCGI server listening on 127.0.0.1:9000/a location ~ \.php$ {' $INS_PATH/nginx/conf/nginx.conf
rm -rf $INS_PATH/nginx/html/*
echo -e "<?php\nphpinfo();\n?>" > $INS_PATH/nginx/html/index.php
/etc/init.d/nginx restart
service php-fpm  start

#php_end　＆＆php-ext_start
ln -s $INS_PATH/php/lib/php/extensions /usr/lib64/extensions
#安装PHP加密工具
cd $INS_PATH/src/Packages
tar zxvf ioncube_loaders_lin_x86-64.tar.gz
mkdir $INS_PATH/ioncube
\cp -rf ioncube/*  $INS_PATH/ioncube
sed -i '$a [ionCube Loader] ' $INS_PATH/php/etc/php.ini
sed -i '$a zend_extension="/usr/local/ioncube/ioncube_loader_lin_5.6.so" ' $INS_PATH/php/etc/php.ini
#安装PHP程序的保护系统
cd $INS_PATH/src/Packages
tar zxvf suhosin-suhosin-0.9.36.tar.gz
cd suhosin-suhosin-0.9.36
$INS_PATH/php/bin/phpize
./configure  --with-php-config=$INS_PATH/php/bin/php-config
make && make install
sed -i '$a extension="suhosin.so" ' $INS_PATH/php/etc/php.ini
#安装memcache
cd $INS_PATH/src/Packages
tar zxvf memcache-2.2.7.tgz
cd memcache-2.2.7
$INS_PATH/php/bin/phpize
./configure  --with-php-config=$INS_PATH/php/bin/php-config
make && make install
sed -i '$a extension="memcache.so" ' $INS_PATH/php/etc/php.ini
#安装re2c（re2c是一个将正则表达式转化成基于C语言标识的预处理器）
cd $INS_PATH/src/Packages
tar -zxvf re2c-0.13.5.tar.gz
cd re2c-0.13.5
./configure
make && make install
#安装ImageMagick
cd $INS_PATH/src/Packages
tar zxvf ImageMagick-7.0.1-7.tar.gz
cd ImageMagick-7.0.1-7
./configure --prefix=$INS_PATH/imagemagick
make && make install
export PKG_CONFIG_PATH=$INS_PATH/imagemagick/lib/pkgconfig/
ln -s $INS_PATH/imagemagick/bin/convert /usr/bin/convert
#安装imagick
cd $INS_PATH/src/Packages
tar zxvf imagick-3.1.2.tgz
cd imagick-3.1.2
$INS_PATH/php/bin/phpize
./configure  --with-php-config=$INS_PATH/php/bin/php-config --with-imagick=$INS_PATH/imagemagick
make && make install
sed -i '$a extension="imagick.so" ' $INS_PATH/php/etc/php.ini
#安装MagickWand
cd $INS_PATH/src/Packages
tar zxvf MagickWandForPHP-1.0.9-2.tar.gz
cd MagickWandForPHP-1.0.9
$INS_PATH/php/bin/phpize
./configure  --with-php-config=$INS_PATH/php/bin/php-config --with-magickwand=$INS_PATH/imagemagick
make && make install
sed -i '$a extension="magickwand.so" ' $INS_PATH/php/etc/php.ini
#安装phpredis
cd $INS_PATH/src/Packages
tar zxvf phpredis-2.2.6.tar.gz
cd phpredis-2.2.6
$INS_PATH/php/bin/phpize
./configure --with-php-config=$INS_PATH/php/bin/php-config
make && make install
sed -i '$a extension="redis.so" ' $INS_PATH/php/etc/php.ini
#安装mongo
cd $INS_PATH/src/Packages
tar  zxvf mongo-1.5.8.tgz
cd mongo-1.5.8
$INS_PATH/php/bin/phpize
./configure --with-php-config=$INS_PATH/php/bin/php-config
make && make install
sed -i '$a extension="mongo.so" ' $INS_PATH/php/etc/php.ini
service php-fpm restart

#替换配置文件
cd $INS_PATH/src
cp Conf/index.php  $INS_PATH/nginx/html/index.php
cp Conf/gd.php  $INS_PATH/nginx/html/gd.php
cp Conf/server.php  $INS_PATH/nginx/html/server.php
cp Conf/phpinfo.php  $INS_PATH/nginx/html/phpinfo.php
chown www.www $INS_PATH/nginx/html/ -R
chmod 700 $INS_PATH/nginx/html/ -R
mv $INS_PATH/nginx/conf/nginx.conf $INS_PATH/nginx/conf/nginx.conf.bak
cp Conf/nginx.conf  $INS_PATH/nginx/conf/nginx.conf
cp Conf/rewrite.conf  $INS_PATH/nginx/conf/rewrite.conf
mkdir $INS_PATH/nginx/conf/vhost
cp Conf/localhost.conf $INS_PATH/nginx/conf/vhost/localhost.conf

#安装完成
iptables -A INPUT -p tcp -m multiport --dport 80,3306,9000 -j ACCEPT
service iptables save
service iptables restart
service mysqld restart
service php-fpm restart
service nginx restart
rm -rf /usr/local/src &&echo "LNMP环境安装已完成！"