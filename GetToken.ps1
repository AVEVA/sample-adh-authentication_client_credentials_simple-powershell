# Step 1: get needed variables
$Appsettings = Get-Content -Path appsettings.json | ConvertFrom-Json
$TenantId = $Appsettings.TenantId
$ApiVersion = $Appsettings.ApiVersion
$Resource = $Appsettings.Resource
$ClientId = $Appsettings.ClientId
$ClientSecret = $Appsettings.ClientSecret


# Step 2: get the authentication endpoint from the discovery URL
$DiscoveryUrlRequest = Invoke-WebRequest -Uri ($Resource + "/identity/.well-known/openid-configuration") -Method Get -UseBasicParsing
$DiscoveryBody = $DiscoveryUrlRequest.Content | ConvertFrom-Json
$TokenUrl = $DiscoveryBody.token_endpoint

# Step 3: use the client ID and Secret to get the needed bearer token
$TokenForm = @{
    client_id = $ClientId
    client_secret = $ClientSecret
    grant_type = "client_credentials"
}

$TokenRequest = Invoke-WebRequest -Uri $TokenUrl -Body $TokenForm -Method Post -ContentType "application/x-www-form-urlencoded" -UseBasicParsing
$TokenBody = $TokenRequest | ConvertFrom-Json

# Step 4: test token by calling the base tenant endpoint
$AuthHeader = @{
    Authorization = "Bearer " + $TokenBody.access_token
}
$TenantRequest = Invoke-WebRequest -Uri ($Resource + "/api/" + $ApiVersion + "/Tenants/" + $TenantId) -Method Get -Headers $AuthHeader -UseBasicParsing

$TenantRequest
