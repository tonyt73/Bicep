// scope
targetScope = 'resourceGroup'

// parameters
param metadata object
param properties object
 @minLength(1)
 @maxLength(15)
 param vmName string

// variables
var tags = {
  Created: metadata.created
  Owner: metadata.owner
  Environment: metadata.env
  RegionCode: metadata.regionCode
  Project: metadata.project
  Group: 'compute'
}

// resources
//
// the network interface
module nic '../Networking/network-interfaces.bicep' = {
  name: '${vmName}-nic'
  params: {
    metadata: metadata
    subNetId: properties.vm.subNetId
    instance: 'vm-${properties.vm.instance}'
  }
}

// TODO: 
//  * possibly look at a data drive for storing comtrac
//    separate to the OS drive

// the virtual machine
resource vm 'Microsoft.Compute/virtualMachines@2020-12-01' = {
  name: vmName
  location: metadata.location
  tags: tags
  properties: {
    hardwareProfile: {
      vmSize: properties.vm.size
    }
    storageProfile: {
      imageReference: {
        publisher: 'MicrosoftWindowsServer'
        offer: 'WindowsServer'
        sku: '2019-DataCenter'
        version: 'latest'
      }
      osDisk: {
        osType: 'Windows'
        name: '${vmName}-disk-os'
        createOption: 'FromImage'
        caching: 'ReadWrite'
        managedDisk: {
          storageAccountType: 'StandardSSD_LRS'
        }
        diskSizeGB: 127
      }
    }
    osProfile: {
      computerName: vmName
      adminUsername: properties.security.administratorLogin
      adminPassword: properties.security.administratorLoginPassword
      windowsConfiguration: {
        provisionVMAgent: true
        enableAutomaticUpdates: true
        patchSettings: {
          patchMode: 'AutomaticByOS'
        }
        winRM: {
          listeners: [
            {
              protocol: 'Http'
            }
          ]
        }
      }
    }
    networkProfile: {
      networkInterfaces: [
        {
          id: nic.outputs.id
        }
      ]
    }
  }
  //resource ext 'extensions@2020-12-01' = {
  //  name: 'serverDsc'
  //  location: metadata.location
  //  properties: {
  //    publisher: 'Microsoft.Powershell'
  //    type: 'DSC'
  //    typeHandlerVersion: '2.77'
  //    autoUpgradeMinorVersion: true
  //    forceUpdateTag: '2'
  //    settings: {
  //      configuration: {
  //        url: 'https://saaueaimahubdsc.blob.core.windows.net/dsc/ComtracServer.zip'
  //        script: 'ComtracServer.ps1'
  //        function: 'ComtracServer'
  //      }
  //      configurationArguments: {
  //        ApiKey: properties.octopus.apiKey
  //        Environments: properties.octopus.environment
  //        Roles: properties.octopus.roles
  //        ServerPort: 10943
  //      }
  //    }
  //    protectedSettings: {
  //      configurationUrlSasToken: properties.security.storageAccountSasToken
  //    }
  //  }
  //}
}

output hostIp string = nic.outputs.pip
