/***
* DATABASE SQL MANAGED INSTANCE
*   An azure sql managed instance implementation of databases
*   Resources:
*     list resources
*/

// scope
targetScope = 'subscription'

// parameters
param metadata object
param properties object

// variables
var dbName = 'sql-mi-${metadata.baseName}'
var rgName = 'rg-${metadata.baseName}-databases' // BCP120

// database resource group
//
module rg '../../Modules/Resources/resource-groups.bicep' = {
  name: rgName
  params: {
    metadata: metadata
    name: rgName
  }
}

// database sql managed instance server
//
//module db '../../Modules/Databases/azure-sql.bicep' = {
//  name: '${metadata.baseName}-database-azuresql-server'
//  scope: resourceGroup(rg.name)
//  params: {
//    metadata: metadata
//    maxDbDtu: properties.maxDbDtu
//    maxServerDtu: properties.maxServerDtu
//    elasticPools: properties.elasticPools
//  }
//}
//
//// sql server private endpoint
////
//module sqlpep '../../Modules/Networking/private-endpoint.bicep' = {
//  name: '${metadata.baseName}-database-sqlserver-privateendpoint'
//  scope: resourceGroup(rg.name)
//  params: {
//    metadata: metadata
//    vnet: properties.vnet
//    endpoint: {
//      service: 'sql'
//      linkName: 'privatelink.database.windows.net'
//      linkId: db.outputs.id
//      groupIds: [
//        'sqlServer'
//      ]
//    }
//  }
//}

//output id string = db.outputs.id
