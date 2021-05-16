/***
* SECURITY
*   A place for secure secrets and identities
*   Resources:
*     security resource group
*     default user managed identity
*     master key vault
*/

// scope
targetScope = 'subscription'

// parameters
param metadata object
param properties object

// variables
var kvName = 'kv-${metadata.baseName}'
var rgName = 'rg-${metadata.baseName}-security' // BCP120

// security resource group
//
module rg '../../Modules/Resources/resource-groups.bicep' = {
  name: rgName
  params: {
    metadata: metadata
    name: rgName
  }
}

// default user managed identity
//
module id '../../Modules/Security/identity.bicep' = {
  name: '${metadata.baseName}-security-usermanagedidentity'
  scope: resourceGroup(rg.name)
  params: {
    metadata: metadata
  }
}

// master key vault
//
module kv '../../Modules/Security/key-vault.bicep' = {
  name: '${metadata.baseName}-security-keyvault'
  scope: resourceGroup(rg.name)
  params: {
    metadata: metadata
    identity: id.outputs.identity
    vnetRules: properties.vnetRules
    secrets: properties.secrets
  }
}

output identity object = id.outputs.identity
output kvUri string = kv.outputs.kvUri
