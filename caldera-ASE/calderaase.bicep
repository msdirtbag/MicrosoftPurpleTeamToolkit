//Caldera-ASE
//Version: 0.0.5
//This bicep deploys the Caldera App Service Environment.

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
  name: 'asp-caldera-${environmentid}'
  location: location
  properties: {
    reserved: true
  }
  sku: {
    tier: 'PremiumV3'
    name: 'P1v3'
  }
  kind: 'linux'
}

//Diagnostic settings for App Service Plan.
resource appserviceplandiag 'Microsoft.Insights/diagnosticSettings@2021-05-01-preview' = {
  name: 'Monitor-ASP'
  scope: appserviceplan
  properties: {
    metrics: [
      {
        category: 'allMetrics'
        enabled: true
      }
    ]
    workspaceId: laworkspace.id
  }
}

//This deploys the User Assigned Managed Identity.  
resource umi 'Microsoft.ManagedIdentity/userAssignedIdentities@2023-01-31' = {
  name: 'umi-caldera-${environmentid}'
  location: location
}

//This deploys the Azure App Service.
resource calappservice 'Microsoft.Web/sites@2022-09-01' = {
  name: 'ase-caldera-${environmentid}'
  location: location
  kind: 'container'
  identity: {
    type: 'UserAssigned'
    userAssignedIdentities: {
      '${umi.id}': {}
    }
  }
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
      linuxFxVersion: 'DOCKER|msdirtbag/calderaase'
      alwaysOn: true
      use32BitWorkerProcess: false
      minTlsVersion: '1.2'
      ftpsState:'Disabled'
    }
  }
}

//Diagnostic settings for App Service.
resource calappservicediag 'Microsoft.Insights/diagnosticSettings@2021-05-01-preview' = {
  name: 'Monitor-CalAppService'
  scope: calappservice
  properties: {
    logs: [
      {
        categoryGroup: 'allLogs'
        enabled: true
      }
    ]
    metrics: [
      {
        category: 'allMetrics'
        enabled: true
      }
    ]
    workspaceId: laworkspace.id
  }
}

//This deploys the App Settings
resource calappsettings 'Microsoft.Web/sites/config@2022-09-01' = {
  name: 'appsettings'
  kind: 'calappsettings'
  parent: calappservice
  properties: {
    SERVER_URL: calappservice.properties.defaultHostName
  }
}


//This deploys the Azure Automation Account.
resource automation 'Microsoft.Automation/automationAccounts@2023-11-01' = {
  name: 'auto-caldera-${environmentid}'
  location: location
  identity: {
    type: 'UserAssigned'
    userAssignedIdentities: {
      '${umi.id}': {}
    }
  }
  properties: {
    disableLocalAuth: true
    publicNetworkAccess: true
    sku: {
      name: 'basic'
    }
  }
}

//This deploys the Nuget Module
resource nugetmodule 'Microsoft.Automation/automationAccounts/modules@2020-01-13-preview' = {
  parent: automation
  name: 'NuGet'
  properties: {
    contentLink: {
      uri: 'https://devopsgallerystorage.blob.core.windows.net/packages/nuget.1.3.3.nupkg'
    }
  }
} 

//This deploys the YAML Module
resource yamlmodule 'Microsoft.Automation/automationAccounts/modules@2020-01-13-preview' = {
  parent: automation
  name: 'powershell-yaml'
  properties: {
    contentLink: {
      uri: 'https://devopsgallerystorage.blob.core.windows.net:443/packages/powershell-yaml.0.4.7.nupkg'
    }
  }
} 

//This deploys the Invoke-AtomicRedTeam Module
resource invokeatomicmodule 'Microsoft.Automation/automationAccounts/modules@2020-01-13-preview' = {
  parent: automation
  name: 'Invoke-AtomicRedTeam'
  properties: {
    contentLink: {
      uri: 'https://devopsgallerystorage.blob.core.windows.net:443/packages/invoke-atomicredteam.2.0.4.nupkg'
    }
  }
  dependsOn: [
    yamlmodule
  ]
}

//This deploys the Sample Runbook
resource samplerunbook 'Microsoft.Automation/automationAccounts/runbooks@2023-11-01' = {
  parent: automation
  name: 'sampleinvokerunbook'
  location: location
  properties: {
    logVerbose: true
    logProgress: true
    runbookType: 'PowerShell'
    publishContentLink: {
      uri: 'https://github.com/msdirtbag/MicrosoftPurpleTeamToolkit/blob/dcfa463de519d39dfe85719f6e85193c4f78a24a/caldera-ASE/sampleinvokerunbook.ps1'
    }
  }
}


//Diagnostic settings
resource automationdiag 'Microsoft.Insights/diagnosticSettings@2021-05-01-preview' = {
  name: 'Monitor-Auto'
  scope: automation
  properties: {
    logs: [
      {
        categoryGroup: 'allLogs'
        enabled: true
      }
    ]
    metrics: [
      {
        category: 'allMetrics'
        enabled: true
      }
    ]
    workspaceId: laworkspace.id
  }
}

//This deploys the Log Analytics Workspace.
resource laworkspace 'Microsoft.OperationalInsights/workspaces@2022-10-01' = {
  name: 'log-caldera-${environmentid}'
  location: location
  identity: {
    type: 'UserAssigned'
    userAssignedIdentities: {
      '${umi.id}': {}
    }
  }
  properties: {
    features: {
      enableDataExport: true
    }
    publicNetworkAccessForIngestion: 'Enabled'
    publicNetworkAccessForQuery: 'Enabled'
    retentionInDays: 30
    sku: {
      name: 'PerGB2018'
    }
  }
}

//Diagnostic settings
resource laworkspacediag 'Microsoft.Insights/diagnosticSettings@2021-05-01-preview' = {
  name: 'Monitor-LA'
  scope: laworkspace
  properties: {
    logs: [
      {
        categoryGroup: 'allLogs'
        enabled: true
      }
    ]
    metrics: [
      {
        category: 'allMetrics'
        enabled: true
      }
    ]
    workspaceId: laworkspace.id
  }
}

//This deploys the Storage Account.
resource storage01 'Microsoft.Storage/storageAccounts@2023-01-01' = {
  name: 'stcal${environmentid}'
  location: location
  identity: {
    type: 'UserAssigned'
    userAssignedIdentities: {
      '${umi.id}': {}
    }
  }
  kind: 'StorageV2'
  sku: {
    name: 'Standard_LRS'
  }
  properties: {
    encryption: {
      keySource: 'Microsoft.Storage'
      requireInfrastructureEncryption: true
      services: {
        blob: {
          enabled: true
        }
        file: {
          enabled: true
        }
        queue: {
          enabled: true
          keyType: 'Service'
        }
        table: {
          enabled: true
          keyType: 'Service'
        }
      }
    }
    networkAcls: {
      bypass: 'AzureServices'
      defaultAction: 'Deny'
    }
    allowBlobPublicAccess: true
    supportsHttpsTrafficOnly: true
    publicNetworkAccess: 'Enabled'
    minimumTlsVersion: 'TLS1_2'
  }
}

//This deploys the Blob Service.
resource blobserv 'Microsoft.Storage/storageAccounts/blobServices@2022-09-01' = {
  name: 'default'
  parent: storage01
  properties: {
  }
}

//This deploys the Public Read-only Container for Scripts.
resource ps1blob 'Microsoft.Storage/storageAccounts/blobServices/containers@2022-09-01' = {
  name: 'ps1'
  parent: blobserv
  properties: {
    publicAccess: 'Blob'
  }
}

//This deploys the Container for Script Output.
resource outputblob 'Microsoft.Storage/storageAccounts/blobServices/containers@2022-09-01' = {
  name: 'output'
  parent: blobserv
  properties: {
    publicAccess: 'None'
  }
}

//Outputs
output calappservicename string = calappservice.name

