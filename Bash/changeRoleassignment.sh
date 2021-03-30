#!/bin/bash
[[ -z "$1" ]] && { echo "Action required" ; exit 1; }
[[ -z "$2" ]] && { echo "User Principal Name required" ; exit 1; }
[[ -z "$3" ]] && { echo "Role Assignment Name Required" ; exit 1; }

set -e 

# Source Documentation: https://docs.microsoft.com/en-us/azure/active-directory/roles/custom-assign-graph
delimiter="------------------------------"
echo "Role Assignment Script"
echo $delimiter
echo "Script parameters:"
script_action=$1 && echo "- script_action: ${script_action}"
user_upn=$2 && echo "- user_upn: ${user_upn}"
user_role=$3 && echo "- user_role: ${user_role}"
if [ "$4" == "" ]; then
    role_scope="/"
else 
    role_scope=$4
fi
echo "- role_scope: ${role_scope}"
echo $delimiter

function get_userObjectId() {
    local user_objectID=$(az ad user list --upn $user_upn --query [].objectId -o tsv)
    echo "$user_objectID"
}

function get_roleDefinitionId() {
    # Retreive a list of all role definitions through the Azure Graph API and filter JSON result on DisplayName. 
    # Return directory role ID property of the JSON result.
    local URI=$(echo "https://graph.microsoft.com/beta/directoryRoles");
    local roleDefinitionId=$(az rest --method GET --uri $URI --header Content-Type=application/json | jq --arg displayName "${user_role}"  '.value[] | select(.displayName | contains($displayName))' | jq '.id' -r);
    echo "$roleDefinitionId"
}

function get_roleTemplateId() {
    # Retreive a list of all role definitions through the Azure Graph API and filter JSON result on DisplayName
    
    local URI=$(echo "https://graph.microsoft.com/beta/directoryRoles")
    local roleTemplateIdRaw=$(az rest --method GET --uri $URI --header Content-Type=application/json)

    # Check if we can find the user role in the JSON result, if not JQ generates a pipeline broken error.
    
    if [[ $roleTemplateIdRaw == *"${user_role}"* ]]; then
        # Filter result on displayName and return the role template ID property
        echo $roleTemplateIdRaw | jq --arg displayName "${user_role}" '.value[] | select(.displayName | contains($displayName))' | jq '.roleTemplateId' -r
    else 
        echo ""
    fi
}

function get_roleAssignmentId(){
    # Get all role assignments for user and check if the user is assigned the role template ID
    local URI=$(echo "https://graph.microsoft.com/beta/roleManagement/directory/roleAssignments?\$filter=principalId%20eq%20'${user_objectId}'")
    local roleAssignmentId=$(az rest --method GET --uri $URI --header Content-Type=application/json | jq --arg roleTemplateId ${role_templateId} '.value[] | select(.roleDefinitionId | contains($roleTemplateId))' | jq '.id' -r)
    echo "$roleAssignmentId"
}

function add_roleAssignment(){
    # Fetching user account to retreive object ID property
    user_objectId="$(get_userObjectId)" && echo "- user_objectID: ${user_objectId}"
    if [ "$user_objectId" == "" ]; then
        echo "ERROR: User object not found for UserPrincipalName ${user_upn}";
        exit 1;
    fi

    # Fetching role Definition ID using the Azure Graph API
    roleDefinitionId="$(get_roleDefinitionId)" && echo "- roleDefinitionId: ${roleDefinitionId}"
    if [ "$roleDefinitionId" == "" ]; then
        echo "ERROR: Role definition ID not found for role ${user_role}";
        exit 1;
    fi

    # Endpoint to create a role assignment between a user and a role definition
    URI=$(echo  "https://graph.microsoft.com/beta/roleManagement/directory/roleAssignments")
    # Expexted JSON Payload in request body
    BODY=$( jq -n \
                --arg principalId "$user_objectId" \
                --arg roleDefinitionId "$roleDefinitionId" \
                --arg directoryScopeId "${role_scope}" \
            '{principalId: $principalId, roleDefinitionId: $roleDefinitionId, directoryScopeId: $directoryScopeId}' )  
    az rest --method POST --uri $URI --header Content-Type=application/json --body "$BODY"
}

function remove_roleAssignment(){
    # Fetching user account to retreive object ID property
    user_objectId="$(get_userObjectId)" && echo "- user_objectID: ${user_objectId}"
    if [ "$user_objectId" == "" ]; then
        echo "ERROR: User object not found for UserPrincipalName ${user_upn}";
        exit 1;
    fi
    
    # Fetching the role template ID, which is required to find the role assignment ID
    role_templateId="$(get_roleTemplateId)" && echo "- role_templateId: ${role_templateId}"
    if [ "$role_templateId" == "" ]; then
        echo "ERROR: Role template ID not found for role ${user_role}";
        exit 1;
    fi
    
    # Fetching the role assignment ID for the user in the given role
    role_assignmentId="$(get_roleAssignmentId)" && echo "- role_assignmentId: ${role_assignmentId}"
    if [ "$role_assignmentId" == "" ]; then
        echo "ERROR: Role Assignment ID not found, validate if user is assigned role!";
        exit 1;
    fi

    # Removing role assignment for user"
    URI=$(echo "https://graph.microsoft.com/beta/roleManagement/directory/roleAssignments/${role_assignmentId}")
    az rest --method DELETE --uri $URI --header Content-Type=application/json

}

if [ "$script_action" == "add" ] ;then
    echo "Adding Role Assignment"
    add_roleAssignment
elif [ "$script_action" == "remove" ]; then
    echo "Removing Role Assignment"
    remove_roleAssignment
else 
    echo "Unsupported Action"
fi
