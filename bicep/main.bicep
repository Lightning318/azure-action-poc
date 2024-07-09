param location string = resourceGroup().location
param repoOrg string = 'Lightning318'
param repoName string = 'azure-action-poc'
param repoBranch string = 'main'

resource managedId 'Microsoft.ManagedIdentity/userAssignedIdentities@2023-01-31' = {
  name: 'pipelineUser'
  location: location
  
  resource fedCred 'federatedIdentityCredentials' = {
    name: '${repoOrg}-${repoName}-${repoBranch}'
    properties: {
      audiences: ['api://AzureADTokenExchange']
      issuer: 'https://token.actions.githubusercontent.com'
      subject: 'repo:${repoOrg}/${repoName}:ref:refs/heads/${repoBranch}'
    }
  }
}

resource acrResource 'Microsoft.ContainerRegistry/registries@2023-01-01-preview' = {
  name: 'acr${uniqueString(resourceGroup().id)}'
  location: location
  sku: {
    name: 'Basic'
  }
  properties: {
    adminUserEnabled: false
  }
}

resource roleAcrPush 'Microsoft.Authorization/roleDefinitions@2022-05-01-preview' existing = {
  name: '8311e382-0749-4cb8-b61a-304f252e45ec'
}

resource roleAssignment 'Microsoft.Authorization/roleAssignments@2022-04-01' = {
  scope: acrResource
  name: guid(acrResource.id, managedId.id, roleAcrPush.id)
  properties: {
    roleDefinitionId: roleAcrPush.id
    principalId: managedId.properties.principalId
    principalType: 'ServicePrincipal'
  }
}

@description('Output the login server property for later use')
output loginServer string = acrResource.properties.loginServer

