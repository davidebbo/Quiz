# Registers applications in AAD for service-to-service communications (daemon scenario)
#

[CmdletBinding()]
Param(
  [Parameter(Mandatory=$True)]
  [string]$AADTenantName, # example: yourdomain.onmicrosoft.com
 
  [Parameter(Mandatory=$True)]
  [string]$QuizAPIName,

  [Parameter(Mandatory=$True)]
  [string]$ClientPassword
  
)

# Register Quiz API itself as application in AAD:
$ADAPIApp = New-AzureRmADApplication -DisplayName "$QuizAPIName" `
    -IdentifierUris "https://$QuizAPIName.azurewebsites.net" `
    -HomePage "https://$QuizAPIName.azurewebsites.net" `
    -ReplyUrls "https://$QuizAPIName.azurewebsites.net" `
    -AvailableToOtherTenants $false

# Register a client for Quiz API as an application in AAD:
$ADAPIClient = New-AzureRmADApplication -DisplayName "$($QuizAPIName)Client" `
    -IdentifierUris "https://$($QuizAPIName)Client" `
    -HomePage "https://$($QuizAPIName)Client" `
    -ReplyUrls "https://$($QuizAPIName)Client" `
    -AvailableToOtherTenants $false

# Create client credentials for both: 
New-AzureRmADAppCredential -ApplicationId $ADAPIApp.ApplicationId -Password $ClientPassword
New-AzureRmADAppCredential -ApplicationId $ADAPIClient.ApplicationId -Password $ClientPassword

# Create service principles for both:
New-AzureRmADServicePrincipal -ApplicationId $ADAPIApp.ApplicationId
New-AzureRmADServicePrincipal -ApplicationId $ADAPIClient.ApplicationId

# Prepare roles to change manifest with:
$guidForQuizMaker = [System.Guid]::NewGuid().ToString()
$guidForQuizTaker = [System.Guid]::NewGuid().ToString()

$roles = 
"{ `
    `"allowedMemberTypes`": [`"Application`"], `
    `"description`": `"Applications can administer quizzes`", `
    `"displayName`": `"QuizMaker`", `
    `"isEnabled`": true, `
    `"value`": `"quizmaker`", `
    `"id`": `"$guidForQuizMaker`"
}, `
{ `
    `"allowedMemberTypes`": [`"Application`"], `
    `"description`": `"Applications can take attempts on quizzes`", `
    `"displayName`": `"QuizTaker`", `
    `"isEnabled`": true, `
    `"value`": `"quiztaker`", `
    `"id`": `"$guidForQuizTaker`" ` 
}"

$roles | clip