// scope
targetScope = 'resourceGroup'

// parameters
param metadata object
param maxServerDtu int
param maxDbDtu int
param elasticPools array

var tags = {
  Created: metadata.created
  Owner: metadata.owner
  Environment: metadata.env
  RegionCode: metadata.regionCode
  Project: metadata.project
  Group: 'databases'
}

// azure sql server
//
resource sql 'Microsoft.Sql/servers@2020-11-01-preview' = {
  name: 'sql-${metadata.baseName}'
  location: metadata.location
  tags: tags
  properties: {
    administratorLogin: 'comtrac'
    administratorLoginPassword: 'YQiaLbyMQmNJD8lUSrSV'
    minimalTlsVersion: '1.2'
    publicNetworkAccess: 'Enabled'
    administrators: {
      administratorType: 'ActiveDirectory'
      principalType: 'Group'
      login: 'Database Admins'
      sid: '189f737b-4e54-411c-97ad-ef883468d9bd'
      tenantId: 'c5d4d98e-21d2-4775-8c96-e7df1607d0db'
      azureADOnlyAuthentication: false
    }    
  }

  // azure sql elastic pool(s)
  //
  resource ep 'elasticPools' = [for ep in elasticPools: {
    name: 'ep-${ep.name}'
    location: metadata.location
    tags: tags
    sku: {
      name: ep.sku
      tier: ep.tier
      capacity: maxServerDtu
    }
    properties: {
      maxSizeBytes: 53687091200
      perDatabaseSettings: {
        minCapacity: 0
        maxCapacity: maxDbDtu
      }
      zoneRedundant: false
    }
  }]
}

output id string = sql.id
