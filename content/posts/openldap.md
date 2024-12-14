---
title: "OpenLDAP"
date: 2024-12-14T10:27:11-05:00
draft: false
author: "Tom Ratcliff"
toc: true
summary: Local OpenLDAP Exploration
tags: ["OpenLDAP", "Containers", "Python"]
categories: ["LDAP"]
---

# Intro
I don't know LDAP very well. Had a project to connect our KubeFlow
instance in K8S to a local Active Directory. The setup involved wiring
our Dex configmap to AD. Official Dex docs <a href="https://dexidp.io/docs/connectors/ldap/" target="_blank">here</a>.

The main info we needed were a service account to bind and the correct DNs for
binding and searching. In order to learn some of these topics, figured it would
be best to spin up my own instance and experiment. 

I found a great article on <a href="https://medium.com/@amrutha_20595/setting-up-openldap-server-with-docker-d38781c259b2" target="_blank">Medium</a>.
Thanks to Amrutha for this write-up! However, it needed to be altered slightly
in order to use a newer version of OpenLDAP on dockerhub (bitnami vs osisix). 

Git repo <a href="https://github.com/ltratcliff/OpenLDAP-Example" target="_blank">here</a>
if you want to follow along.


# Create the OpenLDAP container
First step is to create our OpenLDAP instance we will be exploring

```shell
docker run --rm --name ldap \
  --env LDAP_ADMIN_PASSWORD=admin \
  --env LDAP_ROOT='dc=example,dc=in' \
  --env LDAP_PORT_NUMBER=389 \
  --publish 389:389 \
  --volume "./ldifs/:/ldifs/" \
  --volume "./schemas/:/schemas/" \
  --hostname 'ldap.example.in' \
  bitnami/openldap:latest
```

# Explore

Now we can play!

## Exec into container
```shell
docker exec -it ldap /bin/bash
```
## Interact with LDAP

### Create OUs (orgainaization Units).

Create a devops OU
```shell
ldapadd -x -w admin -D "cn=admin,dc=example,dc=in" << EOF
# LDIF file to add organizational unit "ou=devops" under "dc=example,dc=in"
dn: ou=devops,dc=example,dc=in
objectClass: organizationalUnit
ou: devops

EOF
```

Create an appdev OU
```shell
# LDIF file to add organizational unit "ou=appdev" under "dc=example,dc=in"
ldapadd -x -w admin -D "cn=admin,dc=example,dc=in" << EOF
dn: ou=appdev,dc=example,dc=in
objectClass: organizationalUnit
ou: appdev

EOF
```


### Create User accounts.

Create my account
```shell
ldapadd -x -w admin -D "cn=admin,dc=example,dc=in" << EOF
# LDIF file to Create user "ltratcliff" in "ou=appdev" under "dc=example,dc=in"
dn: cn=ltratcliff,ou=appdev,dc=example,dc=in
objectClass: person
cn: ltratcliff
sn: Tom
userPassword: Password1

EOF
```

Create co-workers account
```shell
# LDIF file to Create user "dave" in "ou=devops" under "dc=example,dc=in"
ldapadd -x -w admin -D "cn=admin,dc=example,dc=in" << EOF
dn: cn=dave,ou=devops,dc=example,dc=in
objectClass: inetOrgPerson
cn: dave
sn: Dave
userPassword: Dave@123
EOF
```


### Create Groups
```shell
ldapadd -x -w admin -D "cn=admin,dc=example,dc=in" << EOF
# Group: appdev-team
dn: cn=appdev-team,dc=example,dc=in
objectClass: top
objectClass: groupOfNames
cn: appdev-team
description: App Development Team
member: cn=ltratcliff,ou=appdev,dc=example,dc=in
member: cn=dave,ou=devops,dc=example,dc=in

# Group: devops-team
dn: cn=devops-team,dc=example,dc=in
objectClass: top
objectClass: groupOfNames
cn: devops-team
description: DevOps Team
member: cn=dave,ou=devops,dc=example,dc=in
EOF
```


### Modify and apply MemberOf attribute to Users in Groups.
```shell
ldapadd -x -w admin -D "cn=admin,dc=example,dc=in" << EOF
dn: cn=ltratcliff,ou=appdev,dc=example,dc=in
changetype: modify
add: memberOf
memberOf: cn=devops-team,dc=example,dc=in

EOF
```



## Search

### Search from ldapsearch
```shell
ldapsearch -x -b dc=example,dc=in -D "cn=admin,dc=example,dc=in" -w admin -s sub "objectclass=*"
```

### Search from python
```python
from ldap3 import Server, Connection, ALL

server = Server('localhost', get_info=ALL)
dn = "cn=ltratcliff, ou=devops, dc=example, dc=in"
conn = Connection(server, dn, password='Password1', auto_bind=True)

#conn.search('dc=example,dc=in', '(cn=*)', attributes=['*'])
conn.search('dc=example,dc=in', '(cn=ltratcliff)', attributes=['*'])

for entry in conn.entries:
    print(entry)
```

## Modify ACLs
Check oclAccess permission.
```shell
ldapsearch -Y EXTERNAL -Q -H ldapi:/// -LLL -o ldif-wrap=no -b cn=config '(objectClass=olcDatabaseConfig)' olcAccess
```

Modification to grant read access to the user "ltratcliff"
```shell
ldapmodify -H ldapi:/// -Y EXTERNAL << EOF
dn: olcDatabase={1}mdb,cn=config
changetype: modify
add: olcAccess
olcAccess: {2}to * by dn="cn=ltratcliff,ou=devops,dc=example,dc=in" read
EOF
```
