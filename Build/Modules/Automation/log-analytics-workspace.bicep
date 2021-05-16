// scope
targetScope = 'resourceGroup'

// parameters
param metadata object
param aaId string

var tags = {
  Created: metadata.created
  Owner: metadata.owner
  Environment: metadata.env
  RegionCode: metadata.regionCode
  Project: metadata.project
  Group: 'automation'
}

var location = 'australiasoutheast'
var wsName = 'ws-${metadata.baseName}-ase'
resource ws 'Microsoft.OperationalInsights/workspaces@2020-10-01' = {
  name: wsName
  location: location
  properties: {
    sku: {
      name: 'PerGB2018'
    }
  }
}

output id string = ws.id
