# Azure App Service Caldera Deployment

This project deploys a Caldera server on Azure App Service for Breach and Attack Simulation.

## Overview

The Bicep script deploys the following resources:

- Azure App Service 
- Azure Automation Account (for deploying Caldera Agents)
- Log Analytics Workspace (for logging)
- Storage Account (for scripts)

## Deployment

1. Hit blue "Deploy" button.

2. Specify your Azure Subscription and Resource Group.

3. DO NOT FORGET TO SET UP AUTHENTICATION WITH ENTRA ID.


## Getting Started Guide

This section provides a step-by-step guide for deploying the CalderaASE.

1. **Step 1: Deploy to Azure**

   ![Deploy](./images/clone-repo.png)

2. **Step 2: Set up Authentication with Entra ID**

   ![Auth](./images/navigate-directory.png)

3. **Step 3: Set the C2 URL**

   ![Set URL](./images/run-command.png)
