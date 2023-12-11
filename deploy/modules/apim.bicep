@description('The name of the API Management service instance')
param apiManagementServiceName string = 'apiservice${uniqueString(resourceGroup().id)}'

@description('The email address of the owner of the service')
@minLength(1)
param publisherEmail string

@description('Application Insights name')
param aiName string

@description('The name of the owner of the service')
@minLength(1)
param publisherName string

@description('Repo base url')
@minLength(1)
param repoBaseUrl string

@description('The pricing tier of this API Management service')
@allowed([
  'Developer'
  'Standard'
  'Premium'
])
param sku string = 'Developer'

@description('The instance size of this API Management service.')
@allowed([
  1
  2
])
param skuCount int = 1

@description('Location for all resources.')
param location string = resourceGroup().location

resource apiManagementService 'Microsoft.ApiManagement/service@2021-08-01' = {
  name: apiManagementServiceName
  location: location
  sku: {
    name: sku
    capacity: skuCount
  }
  properties: {
    publisherEmail: publisherEmail
    publisherName: publisherName
  }
}

resource apimPolicy 'Microsoft.ApiManagement/service/policies@2019-12-01' = {
  name: '${apiManagementServiceName}/policy'
  //  properties:{ 
  //    format: 'rawxml-link'
  //    value: '${repoBaseUrl}?path=/deploy/modules/policy/apimpolicy.xml'
  // }
  properties:{
    format: 'rawxml'
    value: '<policies><inbound /><backend><forward-request /></backend><outbound /><on-error /></policies>'
  }
}

// Create Application Insights
resource ai 'Microsoft.Insights/components@2015-05-01' = {
  name: aiName
  location: resourceGroup().location
  kind: 'web'
  properties:{
    Application_Type:'web'
  }
}

// Create Logger and link logger
resource apimLogger 'Microsoft.ApiManagement/service/loggers@2019-12-01' = {
  name: '${apiManagementService.name}/${apiManagementService.name}-logger'
  properties:{
    resourceId: ai.id
    loggerType: 'applicationInsights'
    credentials:{
      instrumentationKey: ai.properties.InstrumentationKey
    }
  }
}
