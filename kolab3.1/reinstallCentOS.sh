#!/bin/bash
# this script will remove Kolab, and DELETE all YOUR data!!!
# it will reinstall Kolab, from Kolab 3.1 Updates
# you can optionally install the patches from TBits, see bottom of script reinstall.sh

#check that dirsrv will have write permissions to /dev/shm
if [[ $(( `stat --format=%a /dev/shm` % 10 & 2 )) -eq 0 ]]
then
	# it seems that group also need write access, not only other; therefore a+w
	echo "please run: chmod a+w /dev/shm"
	exit 1
fi

echo "this script will remove Kolab, and DELETE all YOUR data!!!"
read -p "Are you sure? Type y or Ctrl-C " -r
echo 
if [[ ! $REPLY =~ ^[Yy]$ ]]
then
    exit 1
fi

if [ -z $1 ]
then
  echo "please call $0 <distribution version as on OBS>"
  exit 1
fi
OBS_repo_OS=$1

service kolabd stop
service kolab-saslauthd stop
service cyrus-imapd stop
service dirsrv stop
service wallace stop
service httpd stop

yum -y remove 389\* cyrus-imapd\* postfix\* mysql-server\* roundcube\* pykolab\* kolab\* libkolab\* kolab-3\*

echo "deleting files..."
rm -Rf \
    /etc/dirsrv \
    /etc/kolab \
    /etc/postfix \
    /etc/roundcubemail \
    /usr/lib64/dirsrv \
    /usr/share/kolab-webadmin \
    /usr/share/roundcubemail \
    /usr/share/kolab-syncroton \
    /usr/share/kolab \
    /usr/share/dirsrv \
    /var/cache/dirsrv \
    /var/cache/kolab-webadmin \
    /var/lock/dirsrv \
    /var/log/kolab* \
    /var/log/dirsrv \
    /var/log/roundcube \
    /var/log/maillog \
    /var/lib/dirsrv \
    /var/lib/imap \
    /var/lib/kolab \
    /var/lib/mysql \
    /tmp/*-Net_LDAP2_Schema.cache \
    /var/spool/imap \
    /var/spool/postfix

/etc/init.d/rsyslog restart

rm -f epel*rpm
wget http://ftp.uni-kl.de/pub/linux/fedora-epel/6/i386/epel-release-6-8.noarch.rpm
yum -y localinstall --nogpgcheck epel-release-6-8.noarch.rpm
rm -f epel*rpm

cd /etc/yum.repos.d
rm -Rf obs-tpokorra-nightly-kolab.repo
#wget http://obs.kolabsys.com:82/home:/tpokorra:/branches:/Kolab:/Development/$OBS_repo_OS/home:tpokorra:branches:Kolab:Development.repo -O obs-tpokorra-nightly-kolab.repo
wget http://obs.kolabsys.com:82/Kolab:/3.1/$OBS_repo_OS/Kolab:3.1.repo -O kolab-3.1.repo
wget http://obs.kolabsys.com:82/Kolab:/3.1:/Updates/$OBS_repo_OS/Kolab:3.1:Updates.repo -O kolab-3.1-updates.repo
cd -

yum clean metadata
yum install kolab patch unzip

