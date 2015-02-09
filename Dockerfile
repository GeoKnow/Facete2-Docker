FROM ubuntu:12.04

MAINTAINER René Pietzsch <rpietzsch@gmail.com>

RUN export DEBIAN_FRONTEND=noninteractive

RUN echo "deb http://archive.ubuntu.com/ubuntu/ precise main restricted universe multiverse" > /etc/apt/sources.list && \
    echo "deb http://archive.ubuntu.com/ubuntu/ precise-updates main restricted universe multiverse" >> /etc/apt/sources.list && \
    echo "deb http://archive.ubuntu.com/ubuntu/ precise-backports main restricted universe multiverse" >> /etc/apt/sources.list && \
    echo "deb http://archive.ubuntu.com/ubuntu/ precise-security main restricted universe multiverse" >> /etc/apt/sources.list

RUN apt-get update
RUN apt-get -y install postgresql supervisor wget openjdk-7-jdk
RUN (echo "deb http://cstadler.aksw.org/repos/apt precise main contrib non-free" > /etc/apt/sources.list.d/cstadler.aksw.org.list)
RUN wget -O - http://cstadler.aksw.org/repos/apt/conf/packages.precise.gpg.key | apt-key add -

# ADD answers/answers
RUN echo "force-confold" >> /etc/dpkg/dpkg.cfg
RUN echo "force-confdef" >> /etc/dpkg/dpkg.cfg
RUN apt-get update

ADD install_facete2.sh /install_facete2.sh
RUN chmod +x /install_facete2.sh
RUN /install_facete2.sh
#RUN service postgresql start
#RUN apt-get -y install facete2-tomcat7
#RUN service postgresql stop

# workaround SHMMAX problem of postgresql in some envs
RUN sed -ie "s&^shared_buffers =.*&shared_buffers = 16MB&" "/etc/postgresql/9.1/main/postgresql.conf"

# configure supervisord
RUN mkdir -p /etc/supervisor/conf.d
ADD supervisord.conf /etc/supervisor/conf.d/supervisord.conf
ADD etc.tomcat7.default /etc/default/tomcat7

EXPOSE 8080

CMD ["/usr/bin/supervisord"]
