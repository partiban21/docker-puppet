FROM jrei/systemd-ubuntu:18.04

ADD "https://apt.puppetlabs.com/puppet6-release-bionic.deb" /puppet6.deb
RUN dpkg -i /puppet6.deb && \
    rm /puppet6.deb && \
    apt-get update && \
    apt-get install --no-install-recommends -y ca-certificates \
        vim \
        git \
        tree \
        lsb-release \
        puppet-agent && \
    apt-get autoremove -y && \
    apt-get clean && \
    rm -rf /var/lib/apt/lists/*

RUN echo "export PATH=$PATH:/opt/puppetlabs/bin" >> /root/.bashrc
RUN echo "\n[main]\nserver = puppetmaster" >> /etc/puppetlabs/puppet/puppet.conf
