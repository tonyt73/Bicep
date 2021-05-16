# MODULES OVERVIEW
Modules are a collection of resources.

### Scope: Resource Group

## Usage
Modules are stored by **group**. A group is really just a name for generic resource type to describe your collection. Examples for groups are:
* Compute
  * used for machine base compute resources
* Networking
  * Networking modules like, virtual network, network interfaces (nic), network security groups etc
* Databases
  * Database modules like, sql, sql mi, mySql, redis, CosmosDB etc
* Messaging
  * Messaging services like, service bus, event hubs, event grids, storage queues etc

## Rules for creating a module
* Use a noun to describe the **group** folder
* Module name should be the resource type name using `-` for a space
  * `'Microsoft.Network/networkInterfaces@2020-07-01'` is `network-interfaces`
  * please split the names
* You need to accept a generic `properties` parameter
  * Use *param* identifiers if you need to decorator them with constraints.
     ```@allowed([
     'Basic'
     'Standard'
     'Premium'
     ])
     param sku string
     ```
