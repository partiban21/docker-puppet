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

## Development

1. Build docker images and start up docker containers 
    ```bash
    # use --build to rebuild an existing image with tweaks made
    docker-compose up -d [--build]
    ```

2. Open interactive docker container in terminal for puppet server
    - Check r10k.yaml is pointing to the correct control repository
    - Deploy 'specific' environment from 'specific' branch & check code has been cloned
    - Check puppet server is 'active(running)' if not enable puppetserver 
    ```bash
    partiban@ubuntu:~$ docker exec -it puppetmaster bash

    # check r10k is correctly configured
    [root@puppetmaster ~]# cat r10k.yaml
    ---
    :cachedir: /var/cache/r10k
    :sources:
      :local:
    remote: https://github.com/partiban21/control.git
    basedir: /etc/puppetlabs/code/environments

    # retrieve puppet control repository. 
    # `-p` option used to pull puppet forge modules
    [root@puppetmaster ~]# r10k deploy environment production -p

    # check everything environment contains expected data
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

    # check status of puppet server
    [root@puppetmaster ~]# systemctl status puppetserver.service
    [root@puppetmaster ~]# systemctl enable puppetserver
   
    When developing control repo
    -----------------------------
    # update environemnt changes in control repo 
    [root@puppetmaster ~]# r10k deploy environment production
    # update Puppetfile changes in control repo
    [root@puppetmaster ~]# r10k deploy environment production -p
    ```

3. Open interactive docker container in terminal for puppet agent
    - Deploy puppet master to puppet agent
    ```bash    
    partiban@ubuntu:~$ docker exec -it puppetagent_1 bash
    
    [root@puppetagent ~]# puppet agent -t    
    ```



5. Helpful commands
    ```bash
    # kill & rm all related containers
    docker-compose down
     
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

1. Puppet must have a 'production' environment.

2. If you kill and remove (only) the puppetagent docker container. On the next docker-compose, you must 
erase and create the certs again:
    ```
    partiban@ubuntu:~$ docker stop puppetagent_1
    partiban@ubuntu:~$ docker rm $(docker ps -a -f status=exited -q)
   
    [root@puppetagent ~]# puppet agent -t
    Info: csr_attributes file loading from /etc/puppetlabs/puppet/csr_attributes.yaml
    Info: Creating a new SSL certificate request for puppetagent
    Info: Certificate Request fingerprint (SHA256): CD:F3:5F:CE:A2:B9:EC:3F:69:02:FB:8B:8D:E9:3E:BA:59:11:E4:A0:C8:F0:56:59:C0:4F:36:36:4D:84:B9:02
    Info: Downloaded certificate for puppetagent from https://puppetmaster:8140/puppet-ca/v1
    Error: The certificate for 'CN=puppetagent' does not match its private key
    Error: Could not run: The certificate for 'CN=puppetagent' does not match its private key
    
    # remove exisitng puppetagent cert
    [root@puppetmaster ~]# puppetserver ca clean --certname puppetagent
    
    # Create cert
    [root@puppetagent ~]# puppet agent -t    
    ```
3. If you've killed the puppet agent, but not removed container this error will come up
    ```bash
    [root@puppetagent ~]# puppet agent -t  
    Error: Connection to https://puppetmaster:8140/puppet/v3 failed, trying next route: Request to https://puppetmaster:8140/puppet/v3 failed after 0.058 seconds: SSL_connect returned=1 errno=0 state=error: sslv3 alert certificate unknown
    Wrapped exception:
    SSL_connect returned=1 errno=0 state=error: sslv3 alert certificate unknown
    Warning: Unable to fetch my node definition, but the agent run will continue:
    Warning: No more routes to puppet
   
    partiban@ubuntu:~$ docker rm $(docker ps -a -f status=exited -q)
    partiban@ubuntu:~$ docker-compose up -d
    # follow the steps above (note 2)
    ```
  
4. Changing the 'service' & 'hostname' on the docker-compose file will require the 
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

5. Stopping and removing all docker containers created from docker-compose.
   ```bash
   # Stop all docker images where name begins with 'docker-puppet_'
   partiban@ubuntu:~$ docker stop $( docker ps -a -q --filter="name=docker-puppet_")
   # Remove all docker images where name begins with 'docker-puppet_'
   partiban@ubuntu:~$ docker rm $( docker ps -a -q --filter="name=docker-puppet_")
   ```
