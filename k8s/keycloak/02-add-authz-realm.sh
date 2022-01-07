KEYCLOAK_POD=$(kubectl get po -l app=keycloak -o custom-columns=:metadata.name)
KEYCLOAK_POD=`echo $KEYCLOAK_POD | xargs`
echo $KEYCLOAK_POD

REALM=kafka-authz

kubectl exec -ti $KEYCLOAK_POD -- /bin/bash -c "cd ~/keycloak/bin; chmod +x kcadm.sh"

kubectl cp keycloak/10-kafka-authz-realm.json $KEYCLOAK_POD:/tmp
kubectl cp keycloak/11-kafka-authz-realm.json $KEYCLOAK_POD:/tmp
kubectl cp keycloak/12-kafka-authz-realm.json $KEYCLOAK_POD:/tmp
kubectl cp keycloak/20-kafka-authz-realm-kafka-client.json $KEYCLOAK_POD:/tmp

kubectl exec -ti $KEYCLOAK_POD -- /bin/bash -c "~/keycloak/bin/kcadm.sh config credentials --server http://keycloak.keycloak:8080/auth --realm master --user admin --password admin"
kubectl exec -ti $KEYCLOAK_POD -- /bin/bash -c "~/keycloak/bin/kcadm.sh create realms -s realm=$REALM -s enabled=true"
kubectl exec -ti $KEYCLOAK_POD -- /bin/bash -c "~/keycloak/bin/kcadm.sh create partialImport -r $REALM -s ifResourceExists=SKIP -o -f /tmp/10-kafka-authz-realm.json"
kubectl exec -ti $KEYCLOAK_POD -- /bin/bash -c "~/keycloak/bin/kcadm.sh create partialImport -r $REALM -s ifResourceExists=SKIP -o -f /tmp/11-kafka-authz-realm.json"
kubectl exec -ti $KEYCLOAK_POD -- /bin/bash -c "~/keycloak/bin/kcadm.sh create partialImport -r $REALM -s ifResourceExists=SKIP -o -f /tmp/12-kafka-authz-realm.json"

# Sync Ldap Users
kubectl exec -ti $KEYCLOAK_POD -- /bin/bash -c "~/keycloak/bin/kcadm.sh create components -r $REALM -s name=ldap -s providerId=ldap -s providerType=org.keycloak.storage.UserStorageProvider -s 'config.editMode=[\"WRITABLE\"]' -s 'config.syncRegistrations=[\"false\"]' -s 'config.vendor=[\"rhds\"]' -s 'config.usernameLDAPAttribute=[\"uid\"]' -s 'config.rdnLDAPAttribute=[\"uid\"]' -s 'config.uuidLDAPAttribute=[\"uid\"]' -s 'config.userObjectClasses=[\"inetOrgPerson\"]' -s 'config.connectionUrl=[\"ldap://openldap-server.openldap:389\"]'  -s 'config.usersDn=[\"ou=users,dc=example,dc=org\"]' -s 'config.authType=[\"simple\"]' -s 'config.bindDn=[\"cn=admin,dc=example,dc=org\"]' -s 'config.bindCredential=[\"admin\"]'"
LDAP_COMPONENT=$(kubectl exec -ti $KEYCLOAK_POD -- /bin/bash -c "~/keycloak/bin/kcadm.sh get components -r $REALM -q type=org.keycloak.storage.UserStorageProvider"  | jq '.[] | .id'  | sed -e 's/^"//' -e 's/"$//')
kubectl exec -ti $KEYCLOAK_POD -- /bin/bash -c "~/keycloak/bin/kcadm.sh create -r $REALM user-storage/$LDAP_COMPONENT/sync?action=triggerFullSync"

# Sync Ldap Groups
kubectl exec -ti $KEYCLOAK_POD -- /bin/bash -c "~/keycloak/bin/kcadm.sh create components -r $REALM -s name=ldap-groups -s providerId=group-ldap-mapper -s providerType=org.keycloak.storage.ldap.mappers.LDAPStorageMapper -s parentId=$LDAP_COMPONENT  -s 'config.\"groups.dn\"=[\"ou=groups,dc=example,dc=org\"]' -s 'config.\"group.name.ldap.attribute\"=[\"cn\"]' -s 'config.\"group.object.classes\"=[\"groupOfUniqueNames\"]' -s 'config.\"preserve.group.inheritance\"=[\"true\"]' -s 'config.\"membership.ldap.attribute\"=[\"uniqueMember\"]' -s 'config.\"membership.attribute.type\"=[\"DN\"]' -s 'config.\"groups.ldap.filter\"=[]' -s 'config.mode=[\"LDAP_ONLY\"]' -s 'config.\"user.roles.retrieve.strategy\"=[\"LOAD_GROUPS_BY_MEMBER_ATTRIBUTE\"]' -s 'config.membership=[\"memberOf\"]'"
LDAP_GROUP_COMPONENT=$(kubectl exec -ti $KEYCLOAK_POD -- /bin/bash -c "~/keycloak/bin/kcadm.sh get components -r $REALM  -q name=ldap-groups"  | jq '.[] | .id'  | sed -e 's/^"//' -e 's/"$//')
kubectl exec -ti $KEYCLOAK_POD -- /bin/bash -c "~/keycloak/bin/kcadm.sh create -r $REALM user-storage/$LDAP_COMPONENT/mappers/$LDAP_GROUP_COMPONENT/sync?direction=fedToKeycloak"

kubectl exec -ti $KEYCLOAK_POD -- /bin/bash -c "~/keycloak/bin/kcadm.sh create partialImport -r $REALM -s ifResourceExists=OVERWRITE -o -f /tmp/20-kafka-authz-realm-kafka-client.json"


