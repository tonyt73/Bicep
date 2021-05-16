
// scope
targetScope = 'resourceGroup'

// parameters
param metadata object
param name string

var tags = {
  Created: metadata.created
  Owner: metadata.owner
  Environment: metadata.env
  RegionCode: metadata.regionCode
  Project: metadata.project
  Group: 'networking'
}

resource pip 'Microsoft.Network/publicIPAddresses@2020-07-01' = {
  name: name
  location: metadata.location
  tags: tags
  sku: {
    name: 'Basic'
    tier: 'Regional'    
  }
  properties: {    
    publicIPAllocationMethod: 'Dynamic'
    publicIPAddressVersion: 'IPv4'
    idleTimeoutInMinutes: 4    
  }
}

output pip object = pip
