FROM centos/systemd
RUN yum install -y epel-release
RUN yum install -y vim git tree
COPY bashrc /root/.bashrc
CMD ["/usr/sbin/init"]
