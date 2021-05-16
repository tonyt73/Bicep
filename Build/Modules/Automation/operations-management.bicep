// scope
targetScope = 'resourceGroup'

// parameters
param metadata object
param wsId string

var tags = {
  Created: metadata.created
  Owner: metadata.owner
  Environment: metadata.env
  RegionCode: metadata.regionCode
  Project: metadata.project
  Group: 'automation'
}

var location = 'australiasoutheast'
var omName = 'Updates(${metadata.baseName}-ase)'
resource om 'Microsoft.OperationsManagement/solutions@2015-11-01-preview' = {
  name: omName
  location: location
  plan: {
    name: '${omName}-plan'
    product: 'OMSGallery/Updates'
    publisher: 'Microsoft'
  }
  properties: {
    workspaceResourceId: wsId
    //containedResources: [
    //  '${wsId}/views/${omName}'
    //]
  }
}

output id string = om.id
