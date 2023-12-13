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

Create service priciple for git hub action , scoped at the api level, with the first custom role created in step 1

```
az ad sp create-for-rbac --name "<<sp name>>" --role "Conference API Manager" --scopes /subscriptions/<<subid>>/resourceGroups/<<resource-group>>/providers/Microsoft.ApiManagement/service/<<apim-name>>/apis/<<api-name>> --json-auth
```
Copy the details and save it as github secret.

## Step 3

Assign Deployment Manager role created in the first step to the service priciple and use this service principle to deploy the api.

<img width="386" alt="image" src="https://github.com/grnisha/apim-rbac-roles/assets/11030157/d60244d7-bef7-4c46-853f-8a0b555dfb64">
