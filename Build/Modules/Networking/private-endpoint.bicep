// scope
targetScope = 'resourceGroup'

// parameters
param metadata object
param vnet object
param endpoint object

var tags = {
  Created: metadata.created
  Owner: metadata.owner
  Environment: metadata.env
  RegionCode: metadata.regionCode
  Project: metadata.project
  Group: 'networking'
}

var nic_name = 'nic-${metadata.baseName}-${endpoint.service}'
var pep_name = 'pep-${metadata.baseName}-${endpoint.service}'
var ipc_name = 'ipc-${metadata.baseName}-${endpoint.service}'
var dzg_name = 'dgz-${metadata.baseName}-${endpoint.service}'
var lnk_name = 'lnk-${metadata.baseName}-${endpoint.service}'

module nic 'network-interfaces.bicep' = {
  name: nic_name
  params: {
    metadata: metadata
    instance: endpoint.service
    subNetId: vnet.subnetId
  }
}

resource dnszone 'Microsoft.Network/privateDnsZones@2020-06-01' = {
  name: endpoint.linkName
  location: 'global'
  tags: tags
  properties: {
  }

  resource zoneA 'A' = {
    name: '${endpoint.service}-${metadata.baseName}'
    properties: {
      metadata: {
        creator: 'created by private end deployment'
      }
      ttl: 10
      aRecords: [
        {
          ipv4Address: nic.outputs.pip
        }
      ]
    }
  }

  resource zoneSOA 'SOA' = {
    name: '@'
    properties: {
      ttl: 3600
      soaRecord: {
        email: 'azureprivatedns-host.microsoft.com'
        'expireTime': 2419200
        'host': 'azureprivatedns.net'
        'minimumTtl': 10
        'refreshTime': 3600
        'retryTime': 300
        'serialNumber': 1
      }
    }
  }

  resource virtualNetworkLink 'virtualNetworkLinks' = {
    name: lnk_name
    location: 'global'
    properties: {
      registrationEnabled: endpoint.registrationEnabled
      virtualNetwork: {
        id: vnet.Id
      }
    }
  }
}

resource pep 'Microsoft.Network/privateEndpoints@2020-07-01' = {
  name: pep_name
  location: metadata.location
  tags: tags
  properties: {
    subnet: {
      id: vnet.subnetId
    }
    privateLinkServiceConnections: [
      {
        name: lnk_name
        properties: {
          privateLinkServiceId: endpoint.linkId
          groupIds: endpoint.groupIds
        }
      }
    ]
  }

  resource dzg 'privateDnsZoneGroups' = {
    name: dzg_name
    properties: {
      privateDnsZoneConfigs: [
        {
          name: replace(pep.name, '.', '-')
          properties: {
            privateDnsZoneId: dnszone.id
          }
        }
      ]
    }
  }
}
