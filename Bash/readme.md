
## Prerequisites

* Azure CLI
* apt-get install jq


# Results

On Success:
```json
{
  "@odata.context": "https://graph.microsoft.com/beta/$metadata#roleManagement/directory/roleAssignments/$entity",
  "directoryScopeId": "/",
  "id": "5xxx_mJe20exxXXxxJo4sTXX_xxxxxxxxxxxxxxxx_k-1",
  "principalId": "xxxxxxxx-xxxx-xxxx-xxxx-xxxxxxxxxxxx",
  "resourceScope": "/",
  "roleDefinitionId": "xxxxxxxx-xxxx-xxxx-xxxx-xxxxxxxxxxxx"
}
```

Adding role assignment which already exists:

```json
Bad Request({
  "error": {
    "code": "Request_BadRequest",
    "message": "A conflicting object with one or more of the specified property values is present in the directory.",
    "innerError": {
      "date": "2021-03-30T05:21:20",
      "request-id": "xxxxxxxx-xxxx-xxxx-xxxx-xxxxxxxxxxxx",
      "client-request-id": "xxxxxxxx-xxxx-xxxx-xxxx-xxxxxxxxxxxx"
    }
  }
})
```