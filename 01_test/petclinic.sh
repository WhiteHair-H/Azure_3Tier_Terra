#!/bin/bash
sudo apt-get update
sudo apt install -y default-jdk
sudo useradd -r -m -U -d /opt/tomcat -s /bin/false tomcat
wget http://www-eu.apache.org/dist/tomcat/tomcat-9/v9.0.56/bin/apache-tomcat-9.0.56.tar.gz -P /tmp
sudo tar xf /tmp/apache-tomcat-9*.tar.gz -C /opt/tomcat
sudo ln -s /opt/tomcat/apache-tomcat-9.0.56 /opt/tomcat/latest
sudo chown -RH tomcat: /opt/tomcat/latest
sudo sh -c 'chmod +x /opt/tomcat/latest/bin/*.sh'
sudo sh -c 'cat > /etc/systemd/system/tomcat.service <<EOF
[Unit]
Description=Tomcat 9 servlet container
After=network.target

[Service]
Type=forking

User=tomcat
Group=tomcat

Environment="JAVA_HOME=/usr/lib/jvm/default-java"
Environment="JAVA_OPTS=-Djava.security.egd=file:///dev/urandom -Djava.awt.headless=true"

Environment="CATALINA_BASE=/opt/tomcat/latest"
Environment="CATALINA_HOME=/opt/tomcat/latest"
Environment="CATALINA_PID=/opt/tomcat/latest/temp/tomcat.pid"
Environment="CATALINA_OPTS=-Xms512M -Xmx1024M -server -XX:+UseParallelGC"

ExecStart=/opt/tomcat/latest/bin/startup.sh
ExecStop=/opt/tomcat/latest/bin/shutdown.sh

[Install]
WantedBy=multi-user.target
EOF'

sudo systemctl daemon-reload
sudo systemctl start tomcat
sudo systemctl enable tomcat
sudo ufw allow 8080/tcp
sudo sh -c 'cat > /opt/tomcat/latest/conf/tomcat-users.xml <<EOF
<?xml version="1.0" encoding="UTF-8"?>
<tomcat-users>
   <role rolename="admin-gui"/>
   <role rolename="manager-gui"/>
   <user username="admin" password="admin_password" roles="admin-gui,manager-gui"/>
</tomcat-users>
EOF'

sudo sed -e '/CookieProcessor className="org.apache.tomcat.util.http.Rfc6265CookieProcessor"/s/^/<!--/g' -i /opt/tomcat/latest/webapps/manager/META-INF/context.xml
sudo sed -e '/Context>/s/^/-->/g' -i /opt/tomcat/latest/webapps/manager/META-INF/context.xml
sudo sed -e '/CookieProcessor className="org.apache.tomcat.util.http.Rfc6265CookieProcessor"/s/^/<!--/g' -i /opt/tomcat/latest/webapps/host-manager/META-INF/context.xml
sudo sed -e '/Context>/s/^/-->/g' -i /opt/tomcat/latest/webapps/host-manager/META-INF/context.xml
sudo systemctl restart tomcat
sudo sh -c 'cat > /opt/tomcat/apache-tomcat-9.0.56/conf/tomcat-users.xml <<EOF
<tomcat-users>
    <role rolename="admin-gui"/>
    <role rolename="manager-script"/>
    <role rolename="manager-gui"/>
    <role rolename="manager-jmx"/>
    <role rolename="manager-status"/>
    <user username="tomcat" password="tomcat" roles="manager-gui,manager-script,manager-status,manager-jmx"/>
</tomcat-users>
EOF'

sudo /opt/tomcat/apache-tomcat-9.0.56/bin/catalina.sh start
git clone https://github.com/SteveKimbespin/petclinic_btc.git 
cd petclinic_btc
./mvnw tomcat7:deploy


sudo sed -i 's,<jdbc.url>jdbc:mysql:/\/\[Change Me]:3306/petclinic?useUnicode=true</jdbc.url>,<jdbc.url>jdbc:mysql:/\/\jwh-db.mysql.database.azure.com:3306/\petclinic?useUnicode=true</jdbc.url>,g' pom.xml
sudo sed -i 's,<jdbc.username>root</jdbc.username>,<jdbc.username>haha@jwh-db</jdbc.username>,g' pom.xml
sudo sed -i 's,<jdbc.password>petclinic</jdbc.password>,<jdbc.password>It12345!</jdbc.password>,g' pom.xml

./mvnw tomcat7:redeploy -P MySQL

