/*
 * This is a Components template
 *  A component is the definition for a collection of modules that 
 *  help to define a collection of resources.
 *
 *  Common examples are:
 *    An SQL server and its associated resources
 *      ie. the server, the elastic pool, private end point, etc
 *
 *  How to use:
 *    1. replace <group> with the name of your resource grouping id
 *    2. replace <resource type> with the resource 2-3 letter code
 *    3. implement the resource module if needed
 *    4. add any additional modules where required
 *    5. Delete this header
 *    6. Fill out the component definition header
 */

 /***
  * COMPONENT NAME
  *   describe your components implementation
  *   Resources:
  *     list resources
  */

// scope
targetScope = 'subscription'

// parameters
param metadata object
param properties object

// variables
var name = '<resource type>-${metadata.baseName}'
var rgName = 'rg-${metadata.baseName}-<group>' // BCP120

// <group> resource group
//
module rg '../../Modules/Resources/resource-groups.bicep' = {
  name: rgName
  params: {
    metadata: metadata
    name: rgName
  }
}

// <group> resource
//
module sb '../../Modules/<group>/<resource>.bicep' = {
  name: '${metadata.baseName}-<group> OR <full resource name>'
  scope: resourceGroup(rg.name)
  params: {
    metadata: metadata
    properties: properties
  }
}
