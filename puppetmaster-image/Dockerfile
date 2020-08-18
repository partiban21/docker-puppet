FROM centos/systemd
RUN yum install -y epel-release
RUN yum install -y vim git tree
RUN rpm --import https://yum.puppetlabs.com/RPM-GPG-KEY-puppet
RUN yum install -y https://yum.puppet.com/puppet6-release-el-7.noarch.rpm
#RUN rpm -Uvh https://yum.puppetlabs.com/puppet5/puppet5-release-el-7.noarch.rpm
RUN yum install -y puppetserver
RUN echo -e "*" > /etc/puppetlabs/puppet/autosign.conf
RUN echo "export PATH=$PATH:/opt/puppetlabs/bin" >> /root/.bashrc
RUN echo -e "\n[main]\ncertname = puppetmaster\nserver = puppetmaster" >> /etc/puppetlabs/puppet/puppet.conf
RUN /opt/puppetlabs/puppet/bin/gem install r10k
RUN systemctl enable puppetserver
EXPOSE 8041
