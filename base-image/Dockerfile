FROM centos:7
RUN yum install -y epel-release
RUN yum install -y vim git tree
RUN mkdir /root/bin
COPY bashrc /root/bin/
RUN echo -e "\n. $HOME/bin/bashrc" > /root/.bashrc
RUN rm -f /etc/rc3.d/*
COPY rc/* /etc/rc3.d/
COPY bootstrap /
CMD ["/bootstrap"]
