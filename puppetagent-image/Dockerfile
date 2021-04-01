FROM centos/systemd
RUN yum install -y epel-release
RUN yum install -y vim git tree
RUN rpm --import https://yum.puppetlabs.com/RPM-GPG-KEY-puppet
RUN yum install -y https://yum.puppet.com/puppet6-release-el-7.noarch.rpm
#RUN rpm -Uvh https://yum.puppetlabs.com/puppet5/puppet5-release-el-7.noarch.rpm
RUN yum install -y puppet-agent
RUN echo "export PATH=$PATH:/opt/puppetlabs/bin" >> /root/.bashrc
# RUN echo -e "\n[main]\ncertname = puppetagent\nserver = puppetmaster" >> /etc/puppetlabs/puppet/puppet.conf
RUN echo -e "\n[main]\nserver = puppetmaster" >> /etc/puppetlabs/puppet/puppet.conf

# facter dir# creating external fact `pp_role`
# ARG FACT_LOCATION=/etc/puppetlabs/facter/facts.d
ARG FACT_LOCATION=/etc/facter/facts.d/
RUN mkdir -p ${FACT_LOCATION} && \
    chown root:root ${FACT_LOCATION} && \
    chmod 700 ${FACT_LOCATION}
# change role depending on what you're testing
ARG ROLE="roles::artefact_repository"
RUN touch ${FACT_LOCATION}/pp_role.txt && \
    chown root:root ${FACT_LOCATION}/pp_role.txt && \
    chmod 644 ${FACT_LOCATION}/pp_role.txt && \
    echo -e "pp_role=${ROLE}" >> ${FACT_LOCATION}/pp_role.txt

CMD ["/usr/sbin/init"]
