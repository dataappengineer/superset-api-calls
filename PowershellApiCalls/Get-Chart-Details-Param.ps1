param(
    [Parameter(Mandatory=$true)]
    [int]$ChartId
)

# Get Chart Details from UI Created Chart with Parameter
$SupersetUrl = "http://localhost:8080"
$Username = "admin"
$Password = "admin"

Write-Host "Getting chart details for ID $ChartId..." -ForegroundColor Yellow

# Get fresh access token
$loginBody = @{
    username = $Username
    password = $Password
    provider = "db"
    refresh = $true
} | ConvertTo-Json

try {
    $loginResponse = Invoke-RestMethod -Uri "$SupersetUrl/api/v1/security/login" -Method POST -Body $loginBody -ContentType "application/json"
    $accessToken = $loginResponse.access_token

    $headers = @{
        "Authorization" = "Bearer $accessToken"
        "Content-Type" = "application/json"
    }

    $chartDetails = Invoke-RestMethod -Uri "$SupersetUrl/api/v1/chart/$ChartId" -Headers $headers
    
    Write-Host "Chart Name: $($chartDetails.result.slice_name)" -ForegroundColor Green
    Write-Host "Viz Type: $($chartDetails.result.viz_type)" -ForegroundColor Green
    Write-Host "Datasource ID: $($chartDetails.result.datasource_id)" -ForegroundColor Green
    
    Write-Host "`nParams (JSON):" -ForegroundColor Yellow
    Write-Host $chartDetails.result.params
    
    Write-Host "`nQuery Context:" -ForegroundColor Yellow  
    Write-Host $chartDetails.result.query_context
    
} catch {
    Write-Host "FAILED to get chart details: $($_.Exception.Message)" -ForegroundColor Red
}