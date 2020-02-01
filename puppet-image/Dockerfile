FROM base:latest
RUN rpm --import https://yum.puppetlabs.com/RPM-GPG-KEY-puppet
RUN yum install -y https://yum.puppet.com/puppet6-release-el-7.noarch.rpm
RUN yum install -y puppetserver
RUN echo -e "*" > /etc/puppetlabs/puppet/autosign.conf
COPY rc/* /etc/rc3.d/
EXPOSE 8041
