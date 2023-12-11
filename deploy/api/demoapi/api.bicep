@description('The name of the API Management instance to deploy this API to.')
param serviceName string 

resource apimService 'Microsoft.ApiManagement/service@2022-04-01-preview' existing = {
  name: serviceName
}

resource apiDefinition 'Microsoft.ApiManagement/service/apis@2022-04-01-preview' = {
  name: 'demoapi'
  parent: apimService
  properties: {
    path: 'demoapi'
    description: 'demo api'
    displayName: 'Demo Api'
    format: 'openapi+json'
    value: loadTextContent('./demo.json')
    subscriptionRequired: true
    type: 'http'
    protocols: [ 'https' ]
    serviceUrl: 'https://conferenceapi.azurewebsites.net/'
  }
}

resource apiPolicy 'Microsoft.ApiManagement/service/apis/policies@2022-04-01-preview' = {
  name: 'policy'
  parent: apiDefinition
  properties: {
    format: 'rawxml'
    value: loadTextContent('./policy.xml')
  }
}
