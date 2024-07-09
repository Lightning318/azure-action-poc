az group create --name 'v2xTest' --location 'eastus'
az stack group create --name v2xStack --resource-group 'v2xTest' --template-file 'bicep/main.bicep' --action-on-unmanage 'deleteAll' --deny-settings-mode 'none'
