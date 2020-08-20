# docker-puppet

A docker-puppet composition that allows you deploy puppet configurations from a puppet master
node to a puppet agent node using docker containers; where each container acts as a separate 
puppet node.  

## Usage

1. Update r10k.yaml to point to specific puppet control repository.
2. Look at Development to run. 

```bash
     ●───────●──────●────●───────────────────────────────●─────────────────●
             │      │    │                               │                  
             │      │    │                               │                  
  ┌──────────┼──────┼────┼───────────────────────────────┼─────────────────┐
  │  ┌───────┼──────┴────┼────────┐        ┌─────────────┴──────────────┐  │
  │  │  ┌────┴───┐  ┌────┴───┐    │        │                            │  │
  │  │  │ Puppet │  │ Puppet │    │        │                            │  │
  │  │  │ Master │  │ Agent  │    │        │          Subject           │  │
  │  │  └────────┘  └────────┘    │        │    (Control Repository)    │  │
  │  │                            │        │                            │  │
  │  │                            │        │                            │  │
  │  └────────────────────────────┘        └────────────────────────────┘  │
  └────────────────────────────────────────────────────────────────────────┘
```

# Development

1. Build docker images and start up docker containers 
    ```bash
    # use --build to rebuild an existing image with tweaks made
    docker-compose up -d [--build]
    ```

2. Open interactive docker container in terminal for puppet server
    - Check r10k.yaml is pointing to the correct control repository
    - Deploy 'specific' environment from 'specific' branch & check code has been cloned
    ```bash
    partiban@ubuntu:~$ docker exec -it docker-puppet_puppetmaster_1 bash
    
    [root@puppetmaster ~]# systemctl enable puppetserver
    [root@puppetmaster ~]# cat r10k.yaml
    ---
    :cachedir: /var/cache/r10k
    :sources:
      :local:
    remote: https://github.com/../control.git
    basedir: /etc/puppetlabs/code/environments

    [root@puppetmaster ~]# r10k deploy environment production
    [root@puppetmaster ~]# ls /etc/puppetlabs/code/environments/production/
    total 44
    drwxr-xr-x  6 root root 4096 Aug 18 15:37 .
    drwxr-xr-x  3 root root 4096 Aug 18 14:29 ..
    drwxr-xr-x  8 root root 4096 Aug 18 14:29 .git
    -rw-r--r--  1 root root 1530 Aug 18 15:37 .r10k-deploy.json
    -rw-r--r--  1 root root  955 Aug 18 14:29 Puppetfile
    -rw-r--r--  1 root root   97 Aug 18 14:29 README
    drwxr-xr-x  3 root root 4096 Aug 18 14:29 data
    -rw-r--r--  1 root root  125 Aug 18 14:29 hiera.yaml
    drwxr-xr-x  2 root root 4096 Aug 18 14:29 manifests
    drwxr-xr-x 14 root root 4096 Aug 18 14:30 modules
    -rw-r--r--  1 root root  152 Aug 18 14:29 r10k.yaml
    ```

3. Open interactive docker container in terminal for puppet agent
    - Deploy puppet master to puppet agent
    ```bash    
    partiban@ubuntu:~$ docker exec -it docker-puppet_puppetagent_1 bash
    
    [root@puppetagent ~]# puppet agent -t    
    ```



5. Helpful commands
    ```bash
    # list running docker containers 
    docker ps

    # kill all running docker containers
    docker container kill $(docker ps -q)

    # remove all docker containers
    docker container rm $(docker ps -a -q)
   
    # remove image
    docker image rm docker-puppet_puppet...
    ```

### Extra things to note

1. If you kill and remove docker containers. On the next docker-compose, you must 
create the certs again:
    ```bash
    # Create certs
    [root@puppetmsater ~]# systemctl enable puppetserver

    [root@puppetagent ~]# puppet agent -t
    ```
   
2. Changing the 'service' & 'hostname' on the docker-compose file will require the 
'certname' & 'server' names specified in the Dockerfiles to also change. (Don't 
use _/underscores in name)
    ```bash
    # docker-compose.yaml
    services:
      puppetmaster-centos:
        hostname: puppetmaster-centos.local
        ...
      puppetagent-centos-one:
        hostname: puppetagent-centos-one.local 
        ...
     
    # puppetmaster-image/Dockerfile
    ...
    RUN echo -e "\n[main]\ncertname = puppetmaster-centos\nserver = puppetmaster-centos" >> /etc/puppetlabs/puppet/puppet.conf
    ...
   
    # puppetagent-image/Dockerfile
    ...
    RUN echo -e "\n[main]\ncertname = puppetagent-centos-one\nserver = puppetmaster-centos" >> /etc/puppetlabs/puppet/puppet.conf
    ...
    ```
