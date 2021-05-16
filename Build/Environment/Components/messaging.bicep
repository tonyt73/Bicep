/*
* MESSAGING
*   Implements the messaging system required
*   Resources:
*     messaging resource group
*     messaging service (service bus)
*     private end point (optional and requires a premium service bus)
*/

// scope
targetScope = 'subscription'

// parameters
param metadata object
param properties object

// variables
var rgName = 'rg-${metadata.baseName}-messaging' // BCP120

// messaging resource group
//
module rg '../../Modules/Resources/resource-groups.bicep' = {
  name: rgName
  params: {
    metadata: metadata
    name: rgName
  }
}

// messaging service
//
module sb '../../Modules/Messaging/service-bus.bicep' = {
  name: 'messaging-servicebus-${metadata.baseName}'
  scope: resourceGroup(rg.name)
  params: {
    metadata: metadata
    sku: properties.sku
  }
  dependsOn: [
    rg
  ]
}

// service bus private endpoint
//
module sbpep '../../Modules/Networking/private-endpoint.bicep' = if (properties.sku ==  'Premium') {
  name: '${metadata.baseName}-messaging-servicebus-privateendpoint'
  scope: resourceGroup(rg.name)
  params: {
    metadata: metadata
    vnet: properties.vnet
    endpoint: {
      service: 'sb'
      linkName: 'privatelink.servicebus.windows.net'
      linkId: sb.outputs.id
      registrationEnabled: false
      groupIds: [
        'namespace'
      ]
    }
  }
}
