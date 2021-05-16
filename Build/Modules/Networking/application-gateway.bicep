// scope
targetScope = 'resourceGroup'

// parameters
param metadata object
param subnetId string
param sku object
param backendIp string
param identityId string
param sslCert object

var tags = {
  Created: metadata.created
  Owner: metadata.owner
  Environment: metadata.env
  RegionCode: metadata.regionCode
  Project: metadata.project
  Group: 'networking'
}

var agw_name = 'agw-${metadata.baseName}'
var pip_name = 'agw-pip-${metadata.baseName}'

module pip 'public-ip-addresses.bicep' = {
  name: pip_name
  params: {
    metadata: metadata
    name: pip_name
  }
}

resource network 'Microsoft.Network/applicationGateways@2020-07-01' = {
  name: agw_name
  location: metadata.location
  tags: tags
  identity: {
    type:'UserAssigned'
    userAssignedIdentities: {
      '${identityId}': {        
      }
    }
  }  
  properties: {
    sku: sku
    sslPolicy: {
      policyType: 'Predefined'
      policyName: 'AppGwSslPolicy20170401S'
    }
    sslCertificates: [
      {
        name: 'appGatewaySslCert'
        properties: {
          data: sslCert.data
          password: sslCert.password
        }
      }
    ]
    frontendIPConfigurations: [
      {
        name: 'agwPublicFrontendIp'
        properties: {
          privateIPAllocationMethod: 'Dynamic'
          publicIPAddress: {
            id: pip.outputs.pip.properties.ipAddress
          }
        }
      }
    ]
    frontendPorts: [
      {
        name: 'port_80'
        properties: {
          port: 80
        }
      }
      {
        name: 'port_443'
        properties: {
          port: 443
        }
      }
    ]
    backendAddressPools: [
      {
        name: 'backend-${metadata.owner}-${metadata.env}'
        properties: {
          backendAddresses: [
            {
              ipAddress: backendIp
            }
          ]
        }
      }
    ]
    backendHttpSettingsCollection: [
      {
        name: 'default-http'
        properties: {
          port: 80
          protocol: 'Http'
          cookieBasedAffinity: 'Disabled'
          pickHostNameFromBackendAddress: false
          affinityCookieName: 'AppGatewayAffinity'
          requestTimeout: 20
        }
      }
      {
        name: 'default-https'
        properties: {
          port: 443
          protocol: 'Https'
          cookieBasedAffinity: 'Disabled'
          pickHostNameFromBackendAddress: false
          affinityCookieName: 'AppGatewayAffinity'
          requestTimeout: 20
        }
      }
    ]
    httpListeners: [
      {
        name: 'agwHttpListener'
        properties: {
          frontendIPConfiguration: {
            id: resourceId('Microsoft.Network/applicationGateways/frontendIPConfigurations', agw_name, 'agwPublicFrontendIp')
          }
          frontendPort: {
            id: resourceId('Microsoft.Network/applicationGateways/frontendPorts', agw_name, 'port_80')
          }
          protocol: 'Http'
        }
      }
      {
        name: 'agwHttpsListener'
        properties: {
          frontendIPConfiguration: {
            id: resourceId('Microsoft.Network/applicationGateways/frontendIPConfigurations', agw_name, 'agwPublicFrontendIp')
          }
          frontendPort: {
            id: resourceId('Microsoft.Network/applicationGateways/frontendPorts', agw_name, 'port_443')
          }
          protocol: 'Https'
          sslCertificate: {
            id: resourceId('Microsoft.Network/applicationGateways/sslCertificates', agw_name, 'appGatewaySslCert')
          }
        }
      }
    ]
    gatewayIPConfigurations: [
      {
        name: 'appGatewayIpConfig'
        properties: {
          subnet: {
            id: subnetId
          }
        }
      }
    ]
    requestRoutingRules: [
      {
        name: 'http'
        properties: {
          ruleType: 'Basic'
          httpListener: {
            id: resourceId('Microsoft.Network/applicationGateways/httpListeners', agw_name, 'agwHttpListener')
          }
          backendAddressPool: {
            id: resourceId('Microsoft.Network/applicationGateways/backendAddressPools', agw_name, 'backend-${metadata.owner}-${metadata.env}')
          }
          backendHttpSettings: {
            id: resourceId('Microsoft.Network/applicationGateways/backendHttpSettingsCollection', agw_name, 'default-http')
          }
        }
      }
      {
        name: 'https'
        properties: {
          ruleType: 'Basic'
          httpListener: {
            id: resourceId('Microsoft.Network/applicationGateways/httpListeners', agw_name, 'agwHttpsListener')
          }
          backendAddressPool: {
            id: resourceId('Microsoft.Network/applicationGateways/backendAddressPools', agw_name, 'backend-${metadata.owner}-${metadata.env}')
          }
          backendHttpSettings: {
            id: resourceId('Microsoft.Network/applicationGateways/backendHttpSettingsCollection', agw_name, 'default-https')
          }
        }
      }
    ]
  }
}
