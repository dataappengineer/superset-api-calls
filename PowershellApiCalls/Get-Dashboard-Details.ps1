param(
    [Parameter(Mandatory=$true)]
    [int]$DashboardId
)

# Get Dashboard Details from UI Created Dashboard
$SupersetUrl = "http://localhost:8080"
$Username = "admin"
$Password = "admin"

Write-Host "Getting dashboard details for ID $DashboardId..." -ForegroundColor Yellow

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

    $dashboardDetails = Invoke-RestMethod -Uri "$SupersetUrl/api/v1/dashboard/$DashboardId" -Headers $headers
    
    Write-Host "Dashboard Name: $($dashboardDetails.result.dashboard_title)" -ForegroundColor Green
    Write-Host "Slug: $($dashboardDetails.result.slug)" -ForegroundColor Green
    Write-Host "Published: $($dashboardDetails.result.published)" -ForegroundColor Green
    Write-Host "Charts Count: $($dashboardDetails.result.charts.Count)" -ForegroundColor Green
    
    Write-Host "`nChart IDs in Dashboard:" -ForegroundColor Yellow
    foreach ($chart in $dashboardDetails.result.charts) {
        Write-Host "  - Chart ID: $($chart.id) - Name: $($chart.slice_name)" -ForegroundColor White
    }
    
    Write-Host "`nPosition JSON:" -ForegroundColor Yellow
    Write-Host $dashboardDetails.result.position_json
    
    Write-Host "`nJSON Metadata:" -ForegroundColor Yellow
    Write-Host $dashboardDetails.result.json_metadata
    
    Write-Host "`nCSS:" -ForegroundColor Yellow
    Write-Host $dashboardDetails.result.css
    
    # Parse position_json to understand ROOT_ID structure
    $positionData = $dashboardDetails.result.position_json | ConvertFrom-Json
    
    Write-Host "`nROOT Structure Analysis:" -ForegroundColor Cyan
    Write-Host "ROOT_ID exists: $(if ($positionData.ROOT_ID) { 'YES' } else { 'NO' })" -ForegroundColor White
    
    if ($positionData.ROOT_ID) {
        Write-Host "ROOT_ID content:" -ForegroundColor White
        Write-Host "  Type: $($positionData.ROOT_ID.type)" -ForegroundColor White
        Write-Host "  Children: $($positionData.ROOT_ID.children -join ', ')" -ForegroundColor White
    }
    
    Write-Host "`nAll Position Keys:" -ForegroundColor Cyan
    $positionData.PSObject.Properties | ForEach-Object {
        $key = $_.Name
        $value = $_.Value
        Write-Host "  Key: $key" -ForegroundColor White
        if ($value.type) {
            Write-Host "    Type: $($value.type)" -ForegroundColor Gray
        }
        if ($value.children) {
            Write-Host "    Children: $($value.children -join ', ')" -ForegroundColor Gray
        }
        if ($value.meta -and $value.meta.chartId) {
            Write-Host "    Chart ID: $($value.meta.chartId)" -ForegroundColor Green
        }
    }
    
} catch {
    Write-Host "FAILED to get dashboard details: $($_.Exception.Message)" -ForegroundColor Red
    Write-Host "Response: $($_.Exception.Response)" -ForegroundColor Red
}