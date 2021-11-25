# Keycloak Authorization Resources

The following use cases will demonstrate how to create various broker authorization resources, policies, and permissions and test them via kafka consumer/producer tools. 

For each of the use cases below we will walk through in how to define them. 

We will add authorization rules on the `Admin` LDAP group we synchronized earlier. Observing the users in the group we see the group has two users, `kermit` and `fozzie`. 

To begin, select from the "Clients" tab, `kafka`, then select `Authorization`. 

From there you will be able to add/update additional resources, policies, and permissions. 

# Policies

## Admin Group Policy

**Resources**: `Group:*` 

**Form Fields**: 

- Name/Description: `Admin Group Policy`
- Groups: `Admin`
- Policy Type: `Group`

![](assets/keycloak-setup-006.png)

# Permissions 

## Admin Group Policy has full access to manage and affect consumer groups

**Resources**: `Group:*`

**Policies**: `Admin Group Policy`

**Form Fields**: 

- Name/Description: `Admin Group Policy has full access to manage and affect consumer groups`
- Type: `Resource`
- Resource: `Group:*`
- Policy: `Admin Group Policy`
- Decision Strategy: `Unanimous`

![](assets/keycloak-setup-007.png)

## Admin Group Policy has full access to manage and affect producer topics

**Resources**: `Topic:*`

**Policies**: `Admin Group Policy`

**Form Fields**: 

- Name/Description: `Admin Group Policy has full access to manage and affect producer topics`
- Type: `Resource`
- Resource: `Topic:*`
- Policy: `Admin Group Policy`
- Decision Strategy: `Unanimous`

![](assets/keycloak-setup-008.png)

## Admin Group Policy has full access to config on any cluster

**Resources**: `Cluster:*`

**Policies**: `Admin Group Policy`

**Form Fields**: 

- Name/Description: `Admin Group Policy has full access to config on any cluster`
- Type: `Resource`
- Resource: `Cluster:*`
- Policy: `Admin Group Policy`
- Decision Strategy: `Unanimous`

![](assets/keycloak-setup-009.png)