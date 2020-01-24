FROM centos:7
RUN yum install -y https://yum.puppet.com/puppet6-release-el-7.noarch.rpm
RUN yum install -y vim git tree puppetserver
RUN echo -e "*.local" > /etc/puppetlabs/puppet/autosign.conf
RUN rm -f /etc/rc3.d/*
COPY rc/* /etc/rc3.d/
COPY bootstrap /
CMD /bootstrap
EXPOSE 8041
