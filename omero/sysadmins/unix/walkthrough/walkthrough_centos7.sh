#!/bin/bash
set -e -u -x
source settings.env

#start-step01: As root, install dependencies

yum -y install epel-release

# installed for convenience
yum -y install unzip wget bc

# install Java
yum -y install java-1.8.0-openjdk

# install dependencies

yum -y install \
	python-pip python-devel python-virtualenv \
	python-yaml python-jinja2 \
	python-pillow numpy scipy python-tables
pip install --upgrade pip

pip install -r requirements.txt
# install Ice
#start-recommended-ice
cd /etc/yum.repos.d
wget https://zeroc.com/download/rpm/zeroc-ice-el7.repo

yum -y install gcc-c++
yum -y install libdb-utils
yum -y install openssl-devel bzip2-devel expat-devel

yum -y install ice-all-runtime ice-all-devel

pip install "zeroc-ice>3.5,<3.7"
#end-recommended-ice
#start-supported-ice
curl -o /etc/yum.repos.d/zeroc-ice-el7.repo \
http://download.zeroc.com/Ice/3.5/el7/zeroc-ice-el7.repo

yum -y install ice ice-python ice-servers
#end-supported-ice


# install Postgres
# Postgres, reconfigure to allow TCP connections
yum -y install http://yum.postgresql.org/9.6/redhat/rhel-7-x86_64/pgdg-centos96-9.6-3.noarch.rpm
yum -y install postgresql96-server postgresql96

PGSETUP_INITDB_OPTIONS=--encoding=UTF8 /usr/pgsql-9.6/bin/postgresql96-setup initdb

sed -i.bak -re 's/^(host.*)ident/\1md5/' /var/lib/pgsql/9.6/data/pg_hba.conf
systemctl start postgresql-9.6.service

systemctl enable postgresql-9.6.service

#end-step01

#start-step02: As root, create an omero system user and directory for the OMERO repository
useradd -m omero
chmod a+X ~omero

mkdir -p "$OMERO_DATA_DIR"
chown omero "$OMERO_DATA_DIR"
#end-step02

#start-step03: As root, create a database user and a database

echo "CREATE USER $OMERO_DB_USER PASSWORD '$OMERO_DB_PASS'" | su - postgres -c psql
su - postgres -c "createdb -E UTF8 -O '$OMERO_DB_USER' '$OMERO_DB_NAME'"

psql -P pager=off -h localhost -U "$OMERO_DB_USER" -l
#end-step03

#start-step04: As the omero system user, install the OMERO.server
#start-copy-omeroscript
cp settings.env step04_all_omero.sh setup_omero_db.sh ~omero 
#end-copy-omeroscript
#start-release-ice35
cd ~omero
SERVER=http://downloads.openmicroscopy.org/latest/omero5.2/server-ice35.zip
wget $SERVER -O OMERO.server-ice35.zip
unzip -q OMERO.server*
#end-release-ice35
#start-release-ice36
cd ~omero
SERVER=http://downloads.openmicroscopy.org/latest/omero5.2/server-ice36.zip
wget $SERVER -O OMERO.server-ice36.zip
unzip -q OMERO.server*
#end-release-ice36
ln -s OMERO.server-*/ OMERO.server
OMERO.server/bin/omero config set omero.data.dir "$OMERO_DATA_DIR"
OMERO.server/bin/omero config set omero.db.name "$OMERO_DB_NAME"
OMERO.server/bin/omero config set omero.db.user "$OMERO_DB_USER"
OMERO.server/bin/omero config set omero.db.pass "$OMERO_DB_PASS"
OMERO.server/bin/omero db script -f OMERO.server/db.sql --password "$OMERO_ROOT_PASS"
psql -h localhost -U "$OMERO_DB_USER" "$OMERO_DB_NAME" < OMERO.server/db.sql
#end-step04

#start-step05: As root, install Nginx
#start-nginx

#install nginx
yum -y install nginx

file=~omero/OMERO.server/share/web/requirements-py27-nginx.txt
pip install -r $file
#start-configure-nginx: As the omero system user, configure OMERO.web
OMERO.server/bin/omero config set omero.web.application_server wsgi-tcp
OMERO.server/bin/omero web config nginx --http "$OMERO_WEB_PORT" > OMERO.server/nginx.conf.tmp
#end-configure-nginx
sed -i.bak -re 's/( default_server.*)/; #\1/' /etc/nginx/nginx.conf

cp ~omero/OMERO.server/nginx.conf.tmp /etc/nginx/conf.d/omero-web.conf

systemctl enable nginx

systemctl start nginx
#end-nginx

#end-step05

#start-step06: As root, run the scripts to start OMERO and OMERO.web automatically
#end-step06

#start-step07: As root, secure OMERO
chmod go-rwx ~omero/OMERO.server/etc ~omero/OMERO.server/var

# Optionally restrict access to the OMERO data directory
#chmod go-rwx "$OMERO_DATA_DIR"
#end-step07

#start-step08: As root, perform regular tasks
#start-omeroweb-cron
OMERO_USER=omero
OMERO_SERVER=/home/omero/OMERO.server
su - ${OMERO_USER} -c "${OMERO_SERVER}/bin/omero web clearsessions"
#end-omeroweb-cron
#Copy omero-web-cron into the appropriate location
#start-copy-omeroweb-cron

cp omero-web-cron /etc/cron.daily/omero-web
chmod a+x /etc/cron.daily/omero-web
#end-copy-omeroweb-cron
#end-step08
#start-selinux

if [ $(getenforce) != Disabled ]; then
    yum -y install policycoreutils-python
    setsebool -P httpd_read_user_content 1
    setsebool -P httpd_enable_homedirs 1
    semanage port -a -t http_port_t -p tcp 4080
fi
#end-selinux
