#!/bin/bash -x
bash -ex << "TRY"
   EFS_ENDPOINT="fs-27f9217e.efs.eu-central-1.amazonaws.com"
   # update
   yum -y update
   
   # install httpd v2.4, php7. php70-mysqlnd (extension required by php to connect to mysql db), php70-opcach (optimise)
   yum -y install httpd24 php70 php70-mysqlnd php70-opcache
   
   # wait until EFS file system is available
   while ! nc -z ${EFS_ENDPOINT} 2049; do sleep 10; done
   sleep 10
   
   # mount EFS file system
   echo "${EFS_ENDPOINT}:/ /var/www/  nfs4 nfsvers=4.1,rsize=1048576,wsize=1048576,hard,timeo=600,retrans=2,_netdev 0 0" >> /etc/fstab
   mount -a
   
   # install wordpress
   cd /var/www/html
   wget https://wordpress.org/latest.zip 
   chown -R apache:apache /var/www/html/
   chmod 2775 /var/www
   find /var/www -type d -exec chmod 2755 {} \;

   # config opcache
   sed -i 's/;opcache.revalidate_freq=2/opcache.revalidate_freq=300/g' /etc/php-7.0.d/10-opcache.ini

   # config httpd
   perl -i -0pe 's/<Directory "\/var\/www">\n\s*AllowOverride None\n/<Directory "\/var\/www">\n    AllowOverride All\n/' /etc/httpd/conf/httpd.conf
   chkconfig httpd on

   # config opcache
   sed -i 's/;opcache.revalidate_freq=2/opcache.revalidate_freq=300/g' /etc/php-7.0.d/10-opcache.ini

   # config httpd
   perl -i -0pe 's/<Directory "\/var\/www">\n\s*AllowOverride None\n/<Directory "\/var\/www">\n    AllowOverride All\n/' /etc/httpd/conf/httpd.conf
   chkconfig httpd on
   
   # start httpd
   service httpd start
   
TRY



