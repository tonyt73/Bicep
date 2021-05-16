targetScope = 'subscription'

// parameters
param created string = utcNow('yyyy-MM-dd')


// variables
var metadata = {
  location: '<location>'
  regionCode: 'xxyy'              // xx:country yy:state
  owner: '<owner acronym>'        // 3 letter owner code
  env: '<environment acronym>'    // 3-4 letter environment code, ie. test, dev, poc, prod etc
  project: '<your project name>'  // A project name
  created: created
  baseName: 'xxyy-<owner>-<env>'  // concat of the above values to use as a base resource name
}

//
//
// COMPONENTS
//

// virtual network component
//
var subnetVms = 0
var subnetKcs = 1
var subnetAgw = 2
var subnetBas = 3
module network 'Components/network-spoke.bicep' = {
  name: '${metadata.baseName}-network-spoke'
  params: {
    metadata: metadata
    properties: {
      subIpRange: '10.10'
      securityRules: []
    }
  }
}

// storage component
//
module storage 'Components/storage-with-privatelink.bicep' = {
  name: '${metadata.baseName}-storage'
  params: {
    metadata: metadata
    properties: {
      name: 'files'
      storageSKU: 'Standard_LRS'
      kind: 'StorageV2'
      vnet: {
        id: network.outputs.vnetId
        subnetId: network.outputs.subnetIds[subnetVms][0] // vms subnet
      }
      fileshares: [
        '<file share names>'
      ]
    }
  }
}

// database component
//
module database 'Components/database-azuresql-elasticpool.bicep' = {
  name: '${metadata.baseName}-database'
  params: {
    metadata: metadata
    properties: {
      maxServerDtu: 100
      maxDbDtu: 50
      elasticPools: [
        {
          name: 'pool'
          sku: 'StandardPool'
          tier: 'Standard'
        }
        {
          name: 'another-pool'
          sku: 'StandardPool'
          tier: 'Standard'
        }
      ]
      vnet: {
        id: network.outputs.vnetId
        subnetId: network.outputs.subnetIds[subnetVms][0] // vms subnet
      }
    }
  }
}

// application host
//
module host 'Components/hosting.bicep' = {
  name: '${metadata.baseName}-hosting'
  params: {
    metadata: metadata
    properties: {
      vm: { // TODO: convert this to an array for multiple vms
        instance: '01'
        size: 'Standard_B2s'
        subNetId: network.outputs.subnetIds[subnetVms][0]
      }
    }
  }
}

