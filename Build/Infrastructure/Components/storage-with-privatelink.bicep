/***
* UPLOADS STORAGE
*   The storage of uploaded files for all tenants
*   Resources:
*     uploads resource group
*     uploads storage account
*     storage account private endpoint
*/

// scope
targetScope = 'subscription'

// parameters
param metadata object
param properties object

// variables
var saName = replace('sa-${metadata.baseName}-${properties.name}', '-', '')
var rgName = 'rg-${metadata.baseName}-${properties.name}'

// uploads resource group
module rg '../../Modules/Resources/resource-groups.bicep' = {
  name: rgName
  params: {
    metadata: metadata
    name: rgName
  }
}

// uploads storage account
module sa '../../Modules/Storage/storage-account.bicep' = {
  name: saName
  scope: resourceGroup(rg.name)
  params: {
    metadata: metadata
    name: saName
    fileshares: properties.fileshares
    kind: properties.kind
    storageSKU: properties.storageSKU
    vnet: properties.vnet
  }
}

// storage account private endpoint
//
module sapep '../../Modules/Networking/private-endpoint.bicep' = {
  name: '${metadata.baseName}-uploads-storageaccount-privatendpoint'
  scope: resourceGroup(rg.name)
  params: {
    metadata: metadata
    vnet: properties.vnet
    endpoint: {
      service: 'sa'
      linkName: 'privatelink.file.core.windows.net'
      linkId: sa.outputs.id
      registrationEnabled: false
      groupIds: [
        'file'
      ]
    }
  }
}
