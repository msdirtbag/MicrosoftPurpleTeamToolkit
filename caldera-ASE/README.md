# Azure App Service Caldera Deployment

This project deploys a Caldera server on Azure App Service for Breach and Attack Simulation.

## Overview

This deploys the following resources:

- Azure App Service 
- Azure Automation Account (for deploying Caldera Agents)
- Log Analytics Workspace (for logging)
- Storage Account (for scripts)

## Deployment

1. Hit blue "Deploy" button.

[![Deploy to Azure](https://aka.ms/deploytoazurebutton)](https://portal.azure.com/#create/Microsoft.Template/uri/https%3A%2F%2Fraw.githubusercontent.com%2Fmsdirtbag%2FMicrosoftPurpleTeamToolkit%2Fmain%2Fcaldera-ASE%2Fcalderaase.json)

   ![Deploy](./images/clone-repo.png)

2. Specify your Azure Subscription and Resource Group.

3. Critical! Set up Authentication with Entra ID.

   ![Auth](./images/navigate-directory.png)

4. Set the Caldera Agents URL.

   ![Set URL](./images/navigate-directory.png)   

