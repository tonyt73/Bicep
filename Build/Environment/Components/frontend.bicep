/***
* FRONT-END
*   The front end resources used to connect to the application
*   Resources:
*     frontend resource group
*     frontend service (application gateway)
*       could be frontdoor in the future
*/

// scope
targetScope = 'subscription'

// parameters
param metadata object
param properties object

// variables
var name = 'agw-${metadata.baseName}'
var rgName = 'rg-${metadata.baseName}-frontend'

// frontend resource group
//
module rg '../../Modules/Resources/resource-groups.bicep' =  {
  name: rgName
  params: {
    metadata: metadata
    name: rgName
  }
}

// application gateway
//
module agw '../../Modules/Networking/application-gateway.bicep' = {
  name: '${metadata.baseName}-frontend-applicationgateway'
  scope: resourceGroup(rg.name)
  params: {
    metadata: metadata
    sku: properties.sku
    backendIp: properties.vnet.backendIp
    subnetId: properties.vnet.subnetId
    identityId: properties.security.identity.id
    sslCert: properties.security.sslCert
  }
}
