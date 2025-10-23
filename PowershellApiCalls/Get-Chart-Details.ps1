# Get Bar Chart Details from UI Created Chart
$SupersetUrl = "http://localhost:8080"
$Username = "admin"
$Password = "admin"

# Get fresh access token
$loginBody = @{
    username = $Username
    password = $Password
    provider = "db"
    refresh = $true
} | ConvertTo-Json

$loginResponse = Invoke-RestMethod -Uri "$SupersetUrl/api/v1/security/login" -Method POST -Body $loginBody -ContentType "application/json"
$accessToken = $loginResponse.access_token

$headers = @{
    "Authorization" = "Bearer $accessToken"
    "Content-Type" = "application/json"
}

Write-Host "Getting chart details for ID 1047..." -ForegroundColor Yellow

try {
    $chartDetails = Invoke-RestMethod -Uri "$SupersetUrl/api/v1/chart/1047" -Headers $headers
    
    Write-Host "Chart Name: $($chartDetails.result.slice_name)" -ForegroundColor Green
    Write-Host "Viz Type: $($chartDetails.result.viz_type)" -ForegroundColor Green
    Write-Host "Datasource ID: $($chartDetails.result.datasource_id)" -ForegroundColor Green
    
    Write-Host "`nParams (JSON):" -ForegroundColor Yellow
    $chartDetails.result.params | ConvertTo-Json -Depth 10
    
    Write-Host "`nQuery Context:" -ForegroundColor Yellow  
    $chartDetails.result.query_context | ConvertTo-Json -Depth 10
    
} catch {
    Write-Host "FAILED to get chart details: $($_.Exception.Message)" -ForegroundColor Red
}