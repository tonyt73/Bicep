// scope
targetScope = 'resourceGroup'

// parameters
param metadata object
@allowed([
  'Basic'  
  'Standard'
  'Premium'
])
param sku string = 'Standard'

var tags = {
  Created: metadata.created
  Owner: metadata.owner
  Environment: metadata.env
  RegionCode: metadata.regionCode
  Project: metadata.project
  Group: 'messaging'
}

resource sb 'Microsoft.ServiceBus/namespaces@2021-01-01-preview' = {
  name: 'sb-${metadata.baseName}'
  location: metadata.location
  tags: tags
  sku: {
    name: sku
  }
  properties: {
  }
}

output name string = sb.name
output id string = sb.id
