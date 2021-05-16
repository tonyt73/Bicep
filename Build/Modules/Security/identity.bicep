
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
  Group: 'security'
}

// identity
resource identity 'Microsoft.ManagedIdentity/userAssignedIdentities@2018-11-30' = {
  name: 'id-${metadata.baseName}'
  tags: tags
  location: metadata.location
}

output id string = identity.id
output identity object = identity.properties
