/***
* AUTOMATION
*   Automation resource
*   Resources:
*     automation resource group
*     automation account
*     log analytics workspace
*     operations management (updates)
*/

// scope
targetScope = 'subscription'

// parameters
param metadata object

var rgName = 'rg-${metadata.baseName}-automation' // BCP120

// resource group for automation resources
//    log analytics workspace, automation account etc
//
module rg '../../Modules/Resources/resource-groups.bicep' = {
  name: rgName
  params: {
    metadata: metadata
    name: rgName
  }
}

// automation account
//
module aa '../../Modules/Automation/automation-account.bicep' = {
  name: '${metadata.baseName}-automation-account'
  scope: resourceGroup(rg.name)
  params: {
    metadata: metadata
  }
}

// log analytics workspace
//
module ws '../../Modules/Automation/log-analytics-workspace.bicep' = {
  name: '${metadata.baseName}-log-analytics-workspace'
  scope: resourceGroup(rg.name)
  params: {
    metadata: metadata
    aaId: aa.outputs.id
  }
}

// operations management (updates)
//
//module om '../../Modules/Automation/operations-management.bicep' = {
//  name: '${metadata.baseName}-operations-management'
//  scope: resourceGroup(rg.name)
//  params: {
//    metadata: metadata
//    wsId: ws.outputs.id
//  }
//}
