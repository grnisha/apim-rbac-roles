@description('The name of the API Management service instance')
param apiManagementServiceName string
@description('Repo base url')
param repoBaseUrl string

// Create a product
resource apimProduct 'Microsoft.ApiManagement/service/products@2019-12-01' = {
  name: '${apiManagementServiceName}/premium'
  properties: {
    approvalRequired: true
    subscriptionRequired: true
    displayName: 'Premium product'
    state: 'published'
  }
}

// Add custom policy to product
resource apimProductPolicy 'Microsoft.ApiManagement/service/products/policies@2019-12-01' = {
  name: '${apimProduct.name}/policy'
  // properties: {
  //   format: 'rawxml-link'
  //   value: '${repoBaseUrl}?path=/deploy/modules/products/policy/premium.product.policy.xml'
  // }
  properties: {
    format: 'rawxml'
    value: '<policies><inbound><base /></inbound><backend><base /></backend><outbound><set-header name="Server" exists-action="delete" /><set-header name="X-Powered-By" exists-action="delete" /><set-header name="X-AspNet-Version" exists-action="delete" /><base /></outbound><on-error><base /></on-error></policies>'
  }
}

// Add Subscription
resource apimSubscription 'Microsoft.ApiManagement/service/subscriptions@2019-12-01' = {
  name: '${apiManagementServiceName}/premiumsubscription'
  properties: {
    displayName: 'Premium Subscription'
    primaryKey: 'premium-primary-key-${uniqueString(resourceGroup().id)}'
    secondaryKey: 'premium-secondary-key-${uniqueString(resourceGroup().id)}'
    state: 'active'
    scope: '/products/${apimProduct.id}'
  }
}
