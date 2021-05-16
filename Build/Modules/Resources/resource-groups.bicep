targetScope = 'subscription'

param metadata object
param name string

var tags = {
  Created: metadata.created
  Owner: metadata.owner
  Environment: metadata.env
  RegionCode: metadata.regionCode
  Project: metadata.project
  Group: 'resources'
}

resource rg 'Microsoft.Resources/resourceGroups@2020-06-01' = {
  name: name
  location: metadata.location
  tags: tags
}

