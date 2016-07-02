FROM ubuntu:14.04
MAINTAINER Dr. Stefan Schimanski <stefan.schimanski@gmail.com>

ENV DEBIAN_FRONTEND noninteractive

# setup repos
RUN echo "deb http://archive.ubuntu.com/ubuntu trusty main universe" > /etc/apt/sources.list
RUN apt-key adv --recv-keys --keyserver hkp://keyserver.ubuntu.com:80 0xcbcb082a1bb943db
RUN echo 'deb http://ftp.hosteurope.de/mirror/mariadb.org/repo/10.0/ubuntu trusty main' >> /etc/apt/sources.list
RUN apt-get -y update

# install packages
RUN apt-get -y --no-install-recommends --no-install-suggests install host socat unzip ca-certificates wget
RUN apt-get -y install mariadb-galera-server-10.0 galera-3 mariadb-client xtrabackup

# install galera-healthcheck
RUN wget -O /bin/galera-healthcheck 'https://github.com/vixns/galera-healthcheck/releases/download/v20160702/galera-healthcheck_linux_amd64'
RUN test "$(sha256sum /bin/galera-healthcheck | awk '{print $1;}')" = "74cafdeda7a87abbf5e7667b1ad8ce3eecefddf09bdc5aa38a8e9661f15c8f31"
RUN chmod +x /bin/galera-healthcheck

# configure mysqld
RUN sed -i 's/#? *bind-address/# bind-address/' /etc/mysql/my.cnf
RUN sed -i 's/#? *log-error/# log-error/' /etc/mysql/my.cnf
ADD conf.d/utf8.cnf /etc/mysql/conf.d/utf8.cnf
ADD conf.d/galera.cnf /etc/mysql/conf.d/galera.cnf
RUN chmod 0644 /etc/mysql/conf.d/utf8.cnf
RUN chmod 0644 /etc/mysql/conf.d/galera.cnf

EXPOSE 3306 4444 4567 4568
VOLUME ["/var/lib/mysql"]
COPY mysqld.sh /mysqld.sh
COPY start /start
RUN chmod 555 /start /mysqld.sh
ENTRYPOINT ["/start"]
