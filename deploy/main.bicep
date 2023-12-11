param buildNumber string
param apiManagementServiceName string = 'apim-demonp-dev-01'

param publisherEmail string = 'test@test.com'

param aiName string = 'ins-demonp-dev-01'

param publisherName string = 'test'

param repoBaseUrl string = 'https://github.com/grnisha/apim-rbac-roles'

param sku string = 'Developer'

param skuCount int = 1

@description('Location for all resources.')
param location string = resourceGroup().location

module apimModule 'modules/apim.bicep' = {
  name: 'apim-${buildNumber}'
  params: {
    aiName: aiName
    apiManagementServiceName: apiManagementServiceName
    location: location
    publisherEmail: publisherEmail
    publisherName: publisherName
    repoBaseUrl: repoBaseUrl
    sku: sku
    skuCount: skuCount
  }
}

module productsModule 'modules/products/premium.product.bicep' = {
  name: 'products-${buildNumber}'
  params: {
    apiManagementServiceName: apiManagementServiceName
    repoBaseUrl: repoBaseUrl
  }
  dependsOn:[
    apimModule
  ]
}
