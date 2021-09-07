# docker-centosserver
contianer which can be used for testing with ansible, ssh enabled.

in order to reach the container run
``sudo firewall-cmd --zone=public --add-port=10010/tcp --permanent``

place your public ssh key in ``authorized_keys`` and run 
``docker-compose up -d``.

if the container needs to be restarted and all the configuration done by 
ansible for example reversed, run ``docker-compose restart``

the container is started attaching to a NFS share and ``cd``s into it upon login

docker-compose can be installed using the ansible role:
[go to github](https://github.com/joengelh/ansible-kvm/tree/main/roles/docker-compose)
