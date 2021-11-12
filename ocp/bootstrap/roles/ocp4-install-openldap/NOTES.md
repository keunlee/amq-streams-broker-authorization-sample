```bash
# install
oc new-app --docker-image=openshift/openldap-2441-centos7 --name=openldap-server --param=OPENLDAP_ROOT_PASSWORD=admin --param=OPENLDAP_ROOT_DN_SUFFIX=dc=example,dc=org --param=OPENLDAP_ROOT_DN_PREFIX=cn=admin --param=OPENLDAP_LISTEN_URIS=ldap://openldap-server.openldap:389 


```