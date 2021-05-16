# Bicep
A Bicep component and module implementation

This project uses a system of components and modules written in bicep to help organise infrastructure deployments in a tidy fashion.

## How to Use
 * Define an infrastructure project file
   * `Build\Infrastructure\<infra project>.bicep`
   * You can use the `template.bicep` file to create a new infrastructure file

## How to do a deploy
Use the Azure CLI tool to deploy your infrastructure
```
az deployment sub create --location <your azure location> -f .\Infrastructure\<infra project >.bicep {--parameters .\Infrastructure\params.json}
```
* Parameters are optional; though any good infrastructure definition will need them.
* Parameters are only way to interface with the Azure key vault to retrieve secrets.
  * You can't write Bicep code yet to retrieve a key vault secret

