// scope
targetScope = 'resourceGroup'

// parameters
param metadata object
param vnetId string

// variables
var tags = {
  Created: metadata.created
  Owner: metadata.owner
  Environment: metadata.env
  RegionCode: metadata.regionCode
  Project: metadata.project
  Group: 'networking'
}

// private ip address for bastion host
//
resource pip 'Microsoft.Network/publicIPAddresses@2020-11-01' = {
  name: 'bastion-${metadata.baseName}-pip'
  location: metadata.location
  sku: {
    name: 'Standard'
    tier: 'Regional'
  }
  properties: {
    publicIPAllocationMethod: 'Static'
    publicIPAddressVersion: 'IPv4'
  }
}

// bastion host
//
resource bastion 'Microsoft.Network/bastionHosts@2020-07-01' = {
  name: 'bastion-${metadata.baseName}'
  location: metadata.location
  tags: tags
  properties: {
    ipConfigurations: [
      {
        name: 'bastion-${metadata.baseName}-ipcfg'
        properties: {
          privateIPAllocationMethod: 'Dynamic'
          publicIPAddress: {
            id: pip.id
          }
          subnet: {
            id: vnetId
          }
        }
      }
    ]
  }
}
