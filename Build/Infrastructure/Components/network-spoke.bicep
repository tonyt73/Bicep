/***
* SPOKE NETWORK
*   A spoke network implementation
*     spokes are connected to a hub via vnet peering and can contain
*     custom routing, nsgs, asgs etc
*   Resources:
*     networking resource group
*     a default nsg (deny all)
*     main virtual network
*       subnets:
*         snet-vms: hosting
*         snet-aks: containers
*         snet-agw: application gateway (might name to fed - for 'front end')
*         AzureBastionSubnet: has to be named this for bastion to register with\
*     bastion host for remote connections
*/

// scope
targetScope = 'subscription'

// parameters
param metadata object
param properties object

// variables
var vnName = 'vn-${metadata.baseName}'
var nsgName = 'nsg-${metadata.baseName}'
var rgName = 'rg-${metadata.baseName}-networking'

// networking resource group
//
module rg '../../Modules/Resources/resource-groups.bicep' = {
  name: rgName
  params: {
    metadata: metadata
    name: rgName
  }
}

// default network security group
//
module nsg '../../Modules/Networking/network-security-group.bicep' = {
  name: '${metadata.baseName}-networking-networksecuritygroup'
  scope: resourceGroup(rg.name)
  params: {
    metadata: metadata
    securityRules: properties.securityRules
  }
}

// main virtual network
//
var vnetName = 'vnet-${metadata.baseName}'
module vn '../../Modules/Networking/virtual-network.bicep' = {
  name: '${metadata.baseName}-networking-spoke-virtualnetwork'
  scope: resourceGroup(rg.name)
  params: {
    metadata: metadata
    properties: {
      addressSpace: {
        addressPrefixes: [
          '${properties.subIpRange}.0.0/22'  // 1024 - 0.0 - 3.255
        ]
      }
      subnets: [
        {
          name: 'snet-vms'
          properties: {
            addressPrefix: '${properties.subIpRange}.0.0/27'  // (32) (vms) application (iis, smss hosts)
            privateEndpointNetworkPolicies: 'Disabled'
            serviceEndpoints: [
              {
                service: 'Microsoft.KeyVault'
              }
              {
                service: 'Microsoft.Storage'
              }
              {
                service: 'Microsoft.ServiceBus'
              }
              {
                service: 'Microsoft.Sql'
              }
            ]          
            networkSecurityGroup: {
              id: nsg.outputs.id
            }
          }
        }
        {
          name: 'snet-aks'
          properties: {
            addressPrefix: '${properties.subIpRange}.1.0/27'  // (32) (aks) azure containers  (eg. virus scanner)
            delegations: [
              {
                name: 'containers'
                properties: {
                  serviceName: 'Microsoft.ContainerInstance/containerGroups'
                }
              }
            ]
          }
        }
        {
          name: 'snet-agw'
          properties: {
            addressPrefix: '${properties.subIpRange}.2.0/28'  // (16) (agw) application gateway
            serviceEndpoints: [
                {
                  service: 'Microsoft.KeyVault'
                }
            ]
          }
        }
        {
          name: 'AzureBastionSubnet'
          properties: {
            addressPrefix: '${properties.subIpRange}.3.0/28'  // (16) (bas) bastion
          }
        }
      ]
    }
  }
}

// bastion host
//  TODO: Might only put bastion on the hub network
module bh '../../Modules/Networking/bastion-host.bicep' = {
  name: '${metadata.baseName}-networking-spoke-bastionhost'
  scope: resourceGroup(rg.name)
  params: {
    metadata: metadata
    vnetId: vn.outputs.subnetIds[3][0]
  }
}

output vnetId string = vn.outputs.vnetId
output subnetIds array = vn.outputs.subnetIds
