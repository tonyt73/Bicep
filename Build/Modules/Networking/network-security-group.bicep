// scope
targetScope = 'resourceGroup'

// parameters
param metadata object
param instance string = ''
param securityRules array = [
]

var tags = {
  Created: metadata.created
  Owner: metadata.owner
  Environment: metadata.env
  RegionCode: metadata.regionCode
  Project: metadata.project
  Group: 'network'
}

var baseName = 'nsg-${metadata.baseName}'

resource nsg 'Microsoft.Network/networkSecurityGroups@2020-11-01' = {
  name: empty(instance) ? baseName : '${baseName}-${instance}'
  location: metadata.location
  tags: tags
  properties: {
    securityRules: securityRules
  }
}

output id string = nsg.id
