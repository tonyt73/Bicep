// scope
targetScope = 'subscription'

// parameters
param metadata object
param properties object

var vmName = 'vm-${metadata.owner}-${metadata.env}-${properties.vm.instance}'
var rgName = 'rg-${metadata.baseName}-vm-${properties.vm.instance}' // BCP120

// variables
module rg '../../Modules/Resources/resource-groups.bicep' = {
  name: rgName
  params: {
    metadata: metadata
    name: rgName
  }
}

module vm '../../Modules/Compute/virtual-machine.bicep' = {
  name: vmName
  scope: resourceGroup(rg.name)
  params: {
    metadata: metadata
    vmName: vmName
    properties: properties
  }
}

output hostIp string = vm.outputs.hostIp
