# Minimal Azure Environment Stack

You can use this stack to spin up a private network as well as
resource classes that will let you provision resources in that
network.

# Installation

Requirements:
* Crossplane should be installed.
* [Azure Stack][stack-azure] should be installed and its version should be at least 0.5.0

If you have [crossplane-cli][crossplane-cli] installed, you can use the following command to install:

```bash
# Do not forget to change <version> with the correct version.
kubectl crossplane stack install --cluster -n crossplane-system 'crossplane/stack-minimal-azure:<version>' minimal-azure
```

If you don't have [crossplane-cli][crossplane-cli] installed, you need to create the following YAML to install:

```yaml
apiVersion: stacks.crossplane.io/v1alpha1
kind: ClusterStackInstall
metadata:
  name: "minimal-azure"
  namespace: crossplane-system
spec:
  package: "crossplane/stack-minimal-azure:<version>"
```

# Usage Instructions

You can create the following YAML to trigger creation of:
* [`Virtual Network`][virtual-network]
* [`Subnet`][subnet]
* [`Resource Group`][security-group]
* [`Provider`][provider] that points to credentials secret reference you supply

and the following resource classes with minimal hardware requirements that will let you create instances that are connected to that network.

* [`AKSClusterClass`][akscluster-class]
* [`SQLServerClass`][sqlserver-class]
* [`RedisClass`][redis-class]

```yaml
# you can find this in example.yaml
apiVersion: azure.resourcepacks.crossplane.io/v1alpha1
kind: MinimalAzure
metadata:
  name: test
spec:
  location: West US
  credentialsSecretRef:
    name: azure-account-creds
    namespace: crossplane-system
    key: credentials

```

In Crossplane, the resource classes that are annotated with `resourceclass.crossplane.io/is-default-class: "true"` are used as default if the claim doesn't specify a resource class selector. The resource classes you create via the `MinimalAzure` instance above will deploy all of its resource classes as default. If you'd like those defaulting annotations to be removed, you need to add the following to `MinimalAzure` instance above:

```yaml
templatestacks.crossplane.io/remove-defaulting-annotations: true
```

### VNetRule Exception

In Azure, for your cluster to connect to the MySQL Server resource, there needs to be a MySQL Server Virtual Network Rule that is created with the name of the MySQLServer, which is determined only after the MySQL Server resource is created. So, after you create a `MySQLServer` resource from the `SQLServerClass` that this stack creates, you need to create the following `MySQLServerVirtualNetworkRule` resource with correct values:

```yaml
# you can find this in vnet.yaml
apiVersion: database.azure.crossplane.io/v1alpha3
kind: MySQLServerVirtualNetworkRule
metadata:
  name: test-vnetrule
spec:
  name: test-vnetrule
  serverName: <fill with mysqlserver.azure.crossplane.io instance name>
  resourceGroupNameRef:
    name: test-resourcegroup
  properties:
    virtualNetworkSubnetIdRef:
      name: test-subnet
  reclaimPolicy: Delete
  providerRef:
    name: test-azure-provider
```

The value of `spec.serverName` should be populated with the name of the `MySQLServer` resource you have, for example `default-test-mysqlserver-4sds5`.

Other thing is that `spec.providerRef`, `spec.properties.virtualNetworkSubnetIdRef` and `spec.resourceGroupNameRef` have `test-` prefix which is how the resources are named if you deploy the example in this repo. If you choose to create `MinimalAzure` instance with a different name, do not forget to use `<MinimalAzure name>-` prefix instead of `test-`

Since this `MySQLServerVirtualNetworkRule` is created manually, it won't be cleaned up when you delete your `MinimalAzure` instance.

## Build

Run `make`

## Test Locally

### Minikube

Run `make` and then run the following command to copy the image into your minikube node's image registry:

```bash
# Do not forget to specify <version>
docker save "crossplane/stack-minimal-azure:<version>" | (eval "$(minikube docker-env --shell bash)" && docker load)
```

After running this, you can use the [installation](#installation) command and the image loaded into minikube node will be picked up. 

[stack-azure]: https://github.com/crossplane/stack-azure
[crossplane-cli]: https://github.com/crossplane/crossplane-cli

[virtual-network]: kustomize/azure/network/virtualnetwork.yaml
[subnet]: kustomize/azure/network/subnet.yaml
[resource-group]: kustomize/azure/resourcegroup.yaml
[provider]: kustomize/azure/provider.yaml
[akscluster-class]: kustomize/azure/compute/aksclusterclass.yaml
[redis-class]: kustomize/azure/cache/redisclass.yaml
[sqlserver-class]: kustomize/azure/database/sqlserverclass.yaml
