# APIM deployment with SP scoped at API level

## Step 1

Create 2 custom roles. First one to provide write access to one specific API and the second one to provide resouce deployment access.

```
{
  "Name": "Conference API Manager",
  "IsCustom": true,
  "Description": "Write access to the Conference API.",
  "Actions": [
        "Microsoft.ApiManagement/service/apis/read",
        "Microsoft.ApiManagement/service/apis/write",
        "Microsoft.ApiManagement/service/apis/*/write"
  ],
  "NotActions": [

  ],
  "AssignableScopes": [
"/subscriptions/<<subid>>/resourceGroups/<<resource-group>>/providers/Microsoft.ApiManagement/service/<<apim-name>>/apis/<<api-name>>"
  ]
}

```

```
{
  "Name": "Deployment Manager",
  "IsCustom": true,
  "Description": "Deployment Manager",
  "Actions": [
		"Microsoft.Resources/deployments/validate/action",
		"Microsoft.Resources/deployments/write",
		"Microsoft.Resources/deployments/*/read"
  ],
  "NotActions": [

  ],
  "AssignableScopes": [
		"/subscriptions/<<subid>>/resourceGroups/<<resource-group>>"
  ]
}
```

Use az role command to create the roles from the json files created above.
```
az role definition create --role-definition <<json file>>
```

## Step 2

Create service priciple for Github action , scoped at the api level, with the first custom role created in step 1

```
az ad sp create-for-rbac --name "<<sp name>>" --role "Conference API Manager" --scopes /subscriptions/<<subid>>/resourceGroups/<<resource-group>>/providers/Microsoft.ApiManagement/service/<<apim-name>>/apis/<<api-name>> --json-auth
```
 The command should output a JSON object similar to this:
 ```
      {
        "clientId": "<GUID>",
        "clientSecret": "<GUID>",
        "subscriptionId": "<GUID>",
        "tenantId": "<GUID>",
        "activeDirectoryEndpointUrl": "<URL>",
        "resourceManagerEndpointUrl": "<URL>",
        "activeDirectoryGraphResourceId": "<URL>",
        "sqlManagementEndpointUrl": "<URL>",
        "galleryEndpointUrl": "<URL>",
        "managementEndpointUrl": "<URL>"
      }
   ```
Store the output JSON as the value of a GitHub Actions secret. This is the credential used to deploy to Azure.

## Step 3

Assign Deployment Manager role created in the first step to the service priciple and use this service principle to deploy the api.

<img width="386" alt="image" src="https://github.com/grnisha/apim-rbac-roles/assets/11030157/d60244d7-bef7-4c46-853f-8a0b555dfb64">

### References

[Role-based access control in Azure API Management](https://learn.microsoft.com/en-us/azure/api-management/api-management-role-based-access-control)

[Create or update Azure custom roles](https://learn.microsoft.com/en-us/azure/role-based-access-control/custom-roles-cli)
