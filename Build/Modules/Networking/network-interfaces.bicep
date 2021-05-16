// scope
targetScope = 'resourceGroup'

// parameters
param metadata object
param subNetId string
param instance string

var tags = {
  Created: metadata.created
  Owner: metadata.owner
  Environment: metadata.env
  RegionCode: metadata.regionCode
  Project: metadata.project
  Group: 'networking'
}

// variables
var nic_name = 'nic-${metadata.baseName}-${instance}'

resource nic 'Microsoft.Network/networkInterfaces@2020-07-01' = {
  name: nic_name
  location: metadata.location
  tags: tags
  properties: {
    ipConfigurations: [
      {
        name: 'ipc-${metadata.baseName}'
        properties: {
          primary: true
          privateIPAllocationMethod: 'Dynamic'
          privateIPAddressVersion: 'IPv4'
          subnet: {
            id: subNetId
          }
        }
      }
    ]
    enableAcceleratedNetworking: false
    enableIPForwarding: false
  }
}

output id string = nic.id
output pip string = nic.properties.ipConfigurations[0].properties.privateIPAddress
