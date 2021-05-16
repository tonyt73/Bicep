// scope
targetScope = 'resourceGroup'

// parameters
param metadata object
param vnet object
param fileshares array

@minLength(3)
@maxLength(18)
param name string

@allowed([
  'FileStorage'
  'Storage'
  'StorageV2'
])
param kind string

@allowed([
  'Standard_LRS'
  'Standard_GRS'
  'Standard_RAGRS'
  'Standard_ZRS'
  'Premium_LRS'
  'Premium_ZRS'
  'Standard_GZRS'
  'Standard_RAGZRS'
])
param storageSKU string = 'Standard_LRS'

var tags = {
  Created: metadata.created
  Owner: metadata.owner
  Environment: metadata.env
  RegionCode: metadata.regionCode
  Project: metadata.project
  Group: 'storage'
}

// resource definition
resource stg 'Microsoft.Storage/storageAccounts@2021-02-01' = {
  name: name
  location: metadata.location
  tags: tags
  kind: kind
  sku: {
    name: storageSKU
    tier: 'Standard'
  }
  properties: {
    accessTier: 'Hot'    
    supportsHttpsTrafficOnly: true
    minimumTlsVersion: 'TLS1_2'
    allowBlobPublicAccess: false
    allowSharedKeyAccess: true
    networkAcls: {
      bypass: 'AzureServices'
      defaultAction: 'Deny'
      virtualNetworkRules: [
        {
          id: vnet.subnetId
          action: 'Allow'
        }
      ]
    }
  }

  resource fileservices 'fileServices' = {
    name: 'default'
    properties: {      
    }

    resource shares 'shares' = [for fs in fileshares: {
      name: fs
      properties: {
        accessTier: 'TransactionOptimized'
        enabledProtocols: 'SMB'
      }
    }]
  }
}


output endpoint object = stg.properties.primaryEndpoints
output id string = stg.id
