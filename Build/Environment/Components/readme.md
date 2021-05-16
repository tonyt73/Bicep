# COMPONENTS OVERVIEW
Components are a collection of modules that bring together a collection of resources that are commonly created together and needed for correct operation of those resources.

### Scope: Subscription

## Usage
We use components to build our environments or base infrastructure.
They present a simplier view of the items needed to build out the infrastructure.

## Rules for creating a component
 * Use the `template.bicep` file to create components
 *  Naming is simply
    *  `<group>-<specialization>.bicep`
    *  **group** names should be *nouns*
 *  Ideally there should always be a resource group defined as the first item
    *  do not modify the default implmentation of `rg`
    *  referencing `rg.name` will add the build dependency required for correct resource deployment order
 * Remember to redefine outputs from child modules that may be needed later on
 * Components are defined at the *subscription* level and you use `scope:` resource groups when calling **modules**
 * You should pass 2 parameters:
   * required: `metadata`
   * optional: `properties`
     * This is usually the final object to use on a resource
     * You can also create a custom object and re-use parts in the component that are then passed to the modules

