#!/bin/bash
sudo setenforce 0
sudo sed -i 's/SELINUX=enforcing/SELINUX=disabled/g' /etc/sysconfig/selinux
sudo yum install -y httpd
sudo sh -c 'echo > /var/www/html/health.html'
sudo sh -c 'cat >> /etc/httpd/conf/httpd.conf <<EOF

<VirtualHost *:80> 
ServerName 20.39.192.42
ErrorLog logs/counterjp.fureweb.com-error_log 
ProxyRequests Off
ProxyPreserveHost On 

<Proxy *> 
Order deny,allow
Allow from all
</Proxy> 

ProxyPass /petclinic http://192.168.2.4:8080/petclinic
ProxyPassMatch ^/(.*\.do)$ http://192.168.2.4:8080/ 
ProxyPassMatch ^/(.*\.jsp)$ http://192.168.2.4:8080/ 
ProxyPassReverse / http://192.168.2.4:8080/ 
</VirtualHost>
EOF
'
sudo systemctl restart httpd
sudo systemctl enable httpd