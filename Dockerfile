FROM centos/systemd:latest

RUN yum update -y && yum -y install openssh openssh-server openssh-clients sudo initscripts

#include known_hosts
ADD authorized_keys /

# Install requirements.
RUN yum makecache fast \
 && yum -y install deltarpm epel-release initscripts \
 && yum -y update \
 && yum -y install \
      sudo \
      openssh-server \
      openssh-client \
      wget \
      git \
      htop \
      vim \
      which \
      python-pip \
 && yum clean all

# Upgrade Pip to latest version working properly with Python2
RUN python -m pip install --no-cache-dir --upgrade "pip < 21.0"

# Install Ansible via Pip.
RUN python -m pip install --no-cache-dir ansible

# Disable requiretty.
RUN sed -i -e 's/^\(Defaults\s*requiretty\)/#--- \1/'  /etc/sudoers

#create wheel group and give sudoless password permissions
RUN echo '%wheel ALL=(ALL) NOPASSWD:ALL' >> /etc/sudoers

#create user
RUN useradd ansible && \
    usermod -a -G wheel ansible

#change workdir to ansible user
WORKDIR /home/ansible

#Authorize SSH Hosts
RUN mkdir -p .ssh/ && \
    chmod 0700 .ssh/ && \
    mv /authorized_keys .ssh/ && \
    chmod 600 .ssh/authorized_keys && \
    chown -R ansible:wheel .ssh/

# Generate keys
RUN ssh-keygen -q -N "" -t rsa -f /etc/ssh/ssh_host_rsa_key
RUN ssh-keygen -q -N "" -t rsa -f /root/.ssh/id_rsa
RUN cp /root/.ssh/id_rsa.pub /root/.ssh/authorized_keys

#start ssh service 
RUN systemctl enable sshd

#expose port 22
EXPOSE 22

#run ssh service  forever
CMD ["/usr/sbin/sshd", "-D"] 
