# sshd
#
# VERSION               0.0.2

FROM ubuntu:14.04
MAINTAINER Shelan Perera <shelanrc@gmail.com>
RUN useradd --create-home --shell /bin/bash vagrant
RUN echo root:vagrant | chpasswd
RUN echo vagrant:vagrant | chpasswd

ADD https://raw.githubusercontent.com/mitchellh/vagrant/master/keys/vagrant.pub /home/vagrant/.ssh/authorized_keys
RUN chown -R vagrant:vagrant /home/vagrant/.ssh
RUN chmod 0600 /home/vagrant/.ssh/authorized_keys
RUN chmod 0700 /home/vagrant/.ssh

RUN apt-get update
RUN apt-get install -y openssh-server
RUN apt-get -y install curl build-essential libxml2-dev libxslt-dev git
RUN curl -L https://www.opscode.com/chef/install.sh | bash
RUN echo "gem: --no-ri --no-rdoc" > ~/.gemrc
RUN /opt/chef/embedded/bin/gem install berkshelf
RUN apt-get clean

RUN echo "export PATH=/opt/chefdk/embedded/bin:$PATH" >> /home/vagrant/.bashrc

RUN mkdir /var/run/sshd
CMD ["/usr/sbin/sshd", "-D", "-e"]
RUN sed -i 's/PermitRootLogin without-password/PermitRootLogin yes/' /etc/ssh/sshd_config

# SSH login fix. Otherwise user is kicked off after login
RUN sed 's@session\s*required\s*pam_loginuid.so@session optional pam_loginuid.so@g' -i /etc/pam.d/sshd

ADD sudoers.d/01_vagrant /etc/sudoers.d/
RUN chmod 0440 /etc/sudoers.d/01_vagrant
RUN usermod -a -G root vagrant


EXPOSE 22

# Hdfs ports
EXPOSE 50010 50020 50070 50075 50090 8020 9000
# Mapred ports
EXPOSE 19888
#Yarn ports
EXPOSE 8030 8031 8032 8033 8040 8042 8088
#Other ports
EXPOSE 49707 2122