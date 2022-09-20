# Input bindings are passed in via param block.
param($Timer)

# Get the current universal time in the default string format
$currentUTCtime = (Get-Date).ToUniversalTime()

# The 'IsPastDue' porperty is 'true' when the current function invocation is later than scheduled.
if ($Timer.IsPastDue) {
    Write-Host "PowerShell timer is running late!"
}

# Write an information log with the current time.
Write-Host "PowerShell timer trigger function ran! TIME: $currentUTCtime";

# Initialise Dynamics 365 API client
$CustomerId = $env:WORKSPACE_ID  

$timeSeriesTable = "CUSTOMLOG002"
#$forecastTable = "SentinelCustomAnalytics_Prediction"

try {
    $workpace = Get-AzOperationalInsightsWorkspace | Where-Object CustomerId -eq $CustomerId -ErrorAction SilentlyContinue
    if (!($workpace)) {
        throw "Workspace not found error"
    }
    $SharedKey = (Get-AzOperationalInsightsWorkspaceSharedKey -ResourceGroupName $workpace.ResourceGroupName -Name $workpace.Name -ErrorAction SilentlyContinue).PrimarySharedKey
    if (!($SharedKey)) {
        throw "Could not obtain workspace key, check permissions"
    }
}
catch {
    Write-Error $error[0] 
}

function Get-LastUpdatedTimestamp ($tableName) {
    $customLog = $tableName + '_CL'
    $query = "$customLog | summarize LatestEvent = max(TimeGenerated)"
    $command = Invoke-AzOperationalInsightsQuery -WorkspaceId $CustomerId -Query $query -ErrorAction SilentlyContinue
    $results = $command.Results
    if ($results) {
        return $results.LatestEvent
    }
    else {
        return "1970-01-01T00:00:00.000Z"
    }
}
function Get-TimeSeriesData ($LastUpdatedTimestamp) {
    $resultObj = @()
    try {
        $query = "GetTimeSeriesData | where TimeBin >= todatetime('$LastUpdatedTimestamp')"
        $command = Invoke-AzOperationalInsightsQuery -WorkspaceId $CustomerId -Query $query
        foreach ($record in $command.Results) {
            $resultObj += [PSCustomObject]@{
                User      = $record.User
                Source    = $record.Source
                Hostname  = $record.Hostname
                SrcIpAddr = $record.SrcIpAddr
                Activity  = $record.Activity
                TimeBin   = $record.TimeBin
                Count     = $record.Count -as [int]
            }
        }
        return $resultObj | ConvertTo-Json
    }
    catch {
        Write-Error ("Error: " + $Error[0])
    }
}

function Get-ForecastData ($LastUpdatedTimestamp) {
    $resultObj = @()
    try {
        $query = "GetForecastData | where TimeBin >= todatetime('$LastUpdatedTimestamp')"
        $command = Invoke-AzOperationalInsightsQuery -WorkspaceId $CustomerId -Query $query
        foreach ($record in $command.Results) {
            $resultObj += [PSCustomObject]@{
                Source          = $record.Source
                Hostname        = $record.Hostname
                User            = $record.User              
                SrcIpAddr       = $record.SrcIpAddr
                Activity        = $record.Activity
                TimeBin         = $record.TimeBin
                Count           = $record.Count -as [int]
                CountForecasted = $record.CountForecasted -as [int]
                CountTukeyUpper = $record.CountTukeyUpper -as [int]
                Sum             = $record.Sum -as [int]
                SumForecasted   = $record.SumForecasted -as [int]
                SumTukeyUpper   = $record.SumTukeyUpper -as [int]
                ForecastType    = $record.ForecastType
            }
        }
        return $resultObj | ConvertTo-Json
    }
    catch {
        Write-Error ("Error: " + $Error[0])
    }
}

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

$data = Get-TimeSeriesData(Get-LastUpdatedTimestamp($timeSeriesTable))

#$data = ConvertTo-Json (Get-TimeSeriesData(Get-LastUpdatedTimestamp($timeSeriesTable)))
Send-LogAnalyticsData -customerId $CustomerId -sharedKey $SharedKey -body ([System.Text.Encoding]::UTF8.GetBytes($data)) -LogName $timeSeriesTable
    
# #     $json = Export-Dataverse ($instanceUrl[$i]).ToLower()
# #     # Submit the data to the API endpoint
# #     Send-LogAnalyticsData -customerId $customerId -sharedKey $sharedKey -body ([System.Text.Encoding]::UTF8.GetBytes($json)) -LogName $LogName
# # }
# $resourceURI = "https://api.loganalytics.io"
# $tokenAuthURI = $env:IDENTITY_ENDPOINT + "?resource=$resourceURI&api-version=2019-08-01"
# $tokenResponse = Invoke-RestMethod -Method Get -Headers @{"X-IDENTITY-HEADER" = "$env:IDENTITY_HEADER" } -Uri $tokenAuthURI
# $headerParams = @{'Authorization'="$($tokenResponse.token_type) $($tokenResponse.access_token)"}
# $url = "https://api.loganalytics.io/v1/workspaces/$CustomerId/query"
# $body = @{query = 'GetTimeSeriesData' } | ConvertTo-Json
# $webresults = Invoke-RestMethod -UseBasicParsing -Headers $headerParams -Uri $url -Method Post -Body $body -ContentType "application/json"
# Write-Host $webresults