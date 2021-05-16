// scope
targetScope = 'resourceGroup'

// parameters
param metadata object
param identity object
param vnetRules array
param secrets array

// variables
var tags = {
  Created: metadata.created
  Owner: metadata.owner
  Environment: metadata.env
  RegionCode: metadata.regionCode
  Project: metadata.project
  Group: 'security'
}

@minLength(3)
@maxLength(24)
param kvName string = 'kv-${metadata.baseName}'

// resource definition
resource kv 'Microsoft.KeyVault/vaults@2021-04-01-preview' = {
  name: kvName
  location: metadata.location
  tags: tags
  properties: {
    tenantId: identity.tenantId
    accessPolicies: [
      {
        tenantId: identity.tenantId
        objectId: identity.principalId
        permissions: {
          secrets: [
            'get'
          ]
        }
      }
    ]
    sku: {
      family: 'A'
      name: 'standard'
    }
    enabledForDeployment: true
    enabledForTemplateDeployment: true
    enableSoftDelete: true
    softDeleteRetentionInDays: 14
    networkAcls: {
      bypass: 'AzureServices'
      defaultAction: 'Deny'
      virtualNetworkRules: vnetRules
    }
  }

  // store secrets
  resource kvs 'secrets' = [for secret in secrets: {
    name: secret.name
    properties: {
      value: secret.value
    }
  }]
}

output kvUri string = kv.properties.vaultUri
