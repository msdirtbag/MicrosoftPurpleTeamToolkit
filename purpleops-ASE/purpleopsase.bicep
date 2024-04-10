//PurpleOps-ASE
//Version: 0.0.5
//This bicep deploys the PurpleOps App Service Environment.

//Scope
targetScope = 'resourceGroup'

//Variables
var environmentid = uniqueString(subscription().id, resourceGroup().id, tenant().tenantId, env)

//Parameters
@description('Chose a variable for the environment. Example: dev, test, soc')
param env string
@description('Chose a location for the deployment. Example: eastus, westus')
param location string

//Resources

//This deploys the App Service Plan.
resource appserviceplan 'Microsoft.Web/serverfarms@2022-09-01' = {
  name: 'asp-purpleops-${environmentid}'
  location: location
  properties: {
    reserved: true
  }
  sku: {
    tier: 'PremiumV3'
    name: 'P0v3'
  }
  kind: 'linux'
}

//This deploys the Azure App Service.
resource purpleopsappservice 'Microsoft.Web/sites@2022-09-01' = {
  name: 'ase-purpleops-${environmentid}'
  location: location
  kind: 'container'
  properties: {
    serverFarmId: appserviceplan.id
    publicNetworkAccess: 'Enabled'
    httpsOnly: true
    siteConfig: {  
      ipSecurityRestrictionsDefaultAction: 'Allow'
      healthCheckPath: '/'
      scmIpSecurityRestrictionsDefaultAction: 'Deny'
      http20Enabled: true
      remoteDebuggingEnabled: false
      scmMinTlsVersion: '1.2'
      linuxFxVersion: 'COMPOSE|dmVyc2lvbjogJzMuOCcKCnNlcnZpY2VzOgogIG1vbmdvZGI6CiAgICBpbWFnZTogbW9uZ286bGF0ZXN0CiAgICBjb250YWluZXJfbmFtZTogbW9uZ29kYgogICAgcG9ydHM6CiAgICAgIC0gMjcwMTcKICAgIHZvbHVtZXM6CiAgICAgIC0gJHtXRUJBUFBfU1RPUkFHRV9IT01FfS9tb25nb2RiX2RhdGEvZGF0YS9kYgogIHB1cnBsZW9wczoKICAgIGltYWdlOiBtc2RpcnRiYWcvcHVycGxlb3BzYXNlOmxhdGVzdAogICAgY29udGFpbmVyX25hbWU6IHB1cnBsZW9wcwogICAgY29tbWFuZDogZ3VuaWNvcm4gLS1iaW5kIDAuMC4wLjA6ODAgcHVycGxlb3BzOmFwcAogICAgcG9ydHM6CiAgICAgIC0gIjgwOjgwIgogICAgZGVwZW5kc19vbjoKICAgICAgLSBtb25nb2RiCiAgICB2b2x1bWVzOgogICAgICAtICR7V0VCQVBQX1NUT1JBR0VfSE9NRX0vcHVycGxlb3BzX2RhdGEvdXNyL3NyYy9hcHAvCiAgICBlbnZpcm9ubWVudDoKICAgICAgLSBNT05HT19EQj1hc3Nlc3NtZW50czMKICAgICAgLSBNT05HT19IT1NUPW1vbmdvZGIKICAgICAgLSBNT05HT19QT1JUPTI3MDE3CiAgICAgIC0gRkxBU0tfREVCVUc9VHJ1ZQogICAgICAtIEZMQVNLX01GQT1GYWxzZQogICAgICAtIEhPU1Q9MC4wLjAuMAogICAgICAtIFBPUlQ9ODg4OAogICAgICAtIE5BTUU9ZGV2CnZvbHVtZXM6CiAgbW9uZ29kYl9kYXRhOgogIHB1cnBsZW9wc19kYXRhOg=='
      alwaysOn: true
      use32BitWorkerProcess: false
      minTlsVersion: '1.2'
      ftpsState:'Disabled'
    }
  }
}

//This deploys the App Settings
resource purpleopsappsettings 'Microsoft.Web/sites/config@2022-09-01' = {
  name: 'appsettings'
  kind: 'calappsettings'
  parent: purpleopsappservice
  properties: {
    WEBSITES_ENABLE_APP_SERVICE_STORAGE: 'true'
  }
}
