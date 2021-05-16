// scope
targetScope = 'resourceGroup'

// parameters
param metadata object
param properties object

var tags = {
  Created: metadata.created
  Owner: metadata.owner
  Environment: metadata.env
  RegionCode: metadata.regionCode
  Project: metadata.project
  Group: 'networking'
}

var vnetName = 'vnet-${metadata.baseName}'

resource watcher 'Microsoft.Network/networkWatchers@2020-07-01' = {
  name: vnetName
  location: metadata.location
  tags: tags
  properties: {}
}

resource network 'Microsoft.Network/virtualNetworks@2020-07-01' = {
  name: vnetName
  location: metadata.location
  tags: tags
  properties: properties
}

// resource id of the vnet
output vnetId string = network.id
// get the resource id's of all the subnets
output subnetIds array = [for subnet in properties.subnets: [
  resourceId('Microsoft.Network/virtualNetworks/subnets', vnetName, subnet.name)
]]  // this is returning an array of arrays???

