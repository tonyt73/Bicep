// scope
targetScope = 'resourceGroup'

// parameters
param metadata object

var tags = {
  Created: metadata.created
  Owner: metadata.owner
  Environment: metadata.env
  RegionCode: metadata.regionCode
  Project: metadata.project
  Group: 'automation'
}

var location = 'australiasoutheast'
var accName = 'aa-${metadata.baseName}-ase'
resource acc 'Microsoft.Automation/automationAccounts@2020-01-13-preview' = {
  name: accName
  location: location
  properties: {
    sku: {
      name: 'Basic'
    }
    encryption: {
      keySource: 'Microsoft.Automation'
    }
  }
}

output id string = acc.id
