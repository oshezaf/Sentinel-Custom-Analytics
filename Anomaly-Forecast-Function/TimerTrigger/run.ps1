# Input bindings are passed in via param block.
param($Timer)

# Get the current universal time in the default string format
$currentUTCtime = (Get-Date).ToUniversalTime()

# The 'IsPastDue' porperty is 'true' when the current function invocation is later than scheduled.
if ($Timer.IsPastDue) {
    Write-Host "PowerShell timer is running late!"
}

# Write an information log with the current time.
Write-Host "PowerShell timer trigger function ran! TIME: $currentUTCtime"

# Initialise Dynamics 365 API client
$CustomerId = $env:WORKSPACE_ID  

$LogName = "RANDOMTEST01"

try {
    $workpace = Get-AzOperationalInsightsWorkspace | Where-Object CustomerId -eq $CustomerId
    if (!($workpace)) {
        throw "Workspace not found error"
    }
}
catch {
    write-host $error[0] 
}
finally {
    $SharedKey = (Get-AzOperationalInsightsWorkspaceSharedKey -ResourceGroupName $workpace.ResourceGroupName -Name $workpace.Name).PrimarySharedKey
}

gunction Get-LastForecastData() {
    $query = "SigninLogs | summarize LatestEvent = max(TimeGenerated)"
    $command = Invoke-AzOperationalInsightsQuery -WorkspaceId $CustomerId -Query $query
    $results = $command.Results
    return $results.LatestEvent
}

function Get-LastUpdatedTimestamp () {
    $query = "SigninLogs | summarize LatestEvent = max(TimeGenerated)"
    $command = Invoke-AzOperationalInsightsQuery -WorkspaceId $CustomerId -Query $query -ErrorAction SilentlyContinue
    $results = $command.Results
    if ($results) {
        return $results.LatestEvent
    }
    else {
        return "1970-01-01T00:00:00.000Z"
    }
}
function Get-ForecastData ($LastUpdatedTimestamp) {
    try {
        $query = "SigninLogs | where TimeGenerated >= $LastUpdatedTimestamp | project Hostname = UserId, User = UserPrincipalName, SrcIpAddr = IPAddress, Activity = AppDisplayName | limit 1"
        $command = Invoke-AzOperationalInsightsQuery -WorkspaceId $CustomerId -Query $query
        $results = $command.Results
        return $results
    }
    catch {
        Write-Error ("Error: " + $Error[0])
    }
}
# Function to create the authorization signature
Function Build-Signature ($CustomerId, $SharedKey, $date, $contentLength, $method, $contentType, $resource) {
    $xHeaders = "x-ms-date:" + $date
    $stringToHash = $method + "`n" + $contentLength + "`n" + $contentType + "`n" + $xHeaders + "`n" + $resource
    $bytesToHash = [Text.Encoding]::UTF8.GetBytes($stringToHash)
    $keyBytes = [Convert]::FromBase64String($sharedKey)
    $sha256 = New-Object System.Security.Cryptography.HMACSHA256
    $sha256.Key = $keyBytes
    $calculatedHash = $sha256.ComputeHash($bytesToHash)
    $encodedHash = [Convert]::ToBase64String($calculatedHash)
    $authorization = 'SharedKey {0}:{1}' -f $customerId, $encodedHash
    return $authorization
}

# Function to create and post the request
Function Send-LogAnalyticsData($CustomerId, $SharedKey, $body, $LogName) {
    $method = "POST"
    $contentType = "application/json"
    $resource = "/api/logs"
    $rfc1123date = [DateTime]::UtcNow.ToString("r")
    $contentLength = $body.Length
    $signature = Build-Signature `
        -customerId $customerId `
        -sharedKey $sharedKey `
        -date $rfc1123date `
        -contentLength $contentLength `
        -method $method `
        -contentType $contentType `
        -resource $resource
    $uri = "https://" + $customerId + ".ods.opinsights.azure.com" + $resource + "?api-version=2016-04-01"

    $headers = @{
        "Authorization" = $signature;
        "Log-Type"      = $LogName;
        "x-ms-date"     = $rfc1123date;
        # "time-generated-field" = $TimeStampField;
    }

    $response = Invoke-WebRequest -Uri $uri -Method $method -ContentType $contentType -Headers $headers -Body $body -UseBasicParsing
    return $response.StatusCode
}

$data = ConvertTo-Json (Get-ForecastData(Get-LastUpdatedTimestamp))
Send-LogAnalyticsData -customerId $CustomerId -sharedKey $SharedKey -body ([System.Text.Encoding]::UTF8.GetBytes($data)) -LogName $LogName
# for ($i = 0; $i -lt $instanceUrl.Count; $i++) {
    
#     $json = Export-Dataverse ($instanceUrl[$i]).ToLower()
    
#     # Submit the data to the API endpoint
#     Send-LogAnalyticsData -customerId $customerId -sharedKey $sharedKey -body ([System.Text.Encoding]::UTF8.GetBytes($json)) -LogName $LogName
# }