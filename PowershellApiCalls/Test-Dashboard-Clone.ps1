# Superset Dashboard Creation Test Script - Clone Dashboard 11
# Tests dashboard API by cloning the "Slack Dashboard" structure

# Configuration
$SupersetUrl = "http://localhost:8080"
$Username = "admin"
$Password = "admin"
$SourceDashboardId = 11

Write-Host "Starting Superset Dashboard Clone Test..." -ForegroundColor Yellow
Write-Host "Superset URL: $SupersetUrl" -ForegroundColor Gray
Write-Host "Source Dashboard ID: $SourceDashboardId" -ForegroundColor Gray

# Get fresh access token
Write-Host "`nAuthenticating..." -ForegroundColor Yellow

$loginBody = @{
    username = $Username
    password = $Password
    provider = "db"
    refresh = $true
} | ConvertTo-Json

try {
    $loginResponse = Invoke-RestMethod -Uri "$SupersetUrl/api/v1/security/login" -Method POST -Body $loginBody -ContentType "application/json"
    $accessToken = $loginResponse.access_token
    Write-Host "Authentication successful!" -ForegroundColor Green
} catch {
    Write-Host "Authentication failed: $($_.Exception.Message)" -ForegroundColor Red
    exit 1
}

$headers = @{
    "Authorization" = "Bearer $accessToken"
    "Content-Type" = "application/json"
}

# Get source dashboard details
Write-Host "`nFetching source dashboard..." -ForegroundColor Yellow
try {
    $sourceDashboard = Invoke-RestMethod -Uri "$SupersetUrl/api/v1/dashboard/$SourceDashboardId" -Headers $headers
    Write-Host "Source dashboard fetched: $($sourceDashboard.result.dashboard_title)" -ForegroundColor Green
} catch {
    Write-Host "Failed to fetch source dashboard: $($_.Exception.Message)" -ForegroundColor Red
    exit 1
}

$timestamp = Get-Date -Format 'HHmmss'

# Prepare clone dashboard data - simplified structure
$cloneDashboardData = @{
    dashboard_title = "CLONED - $($sourceDashboard.result.dashboard_title) - $timestamp"
    slug = ""  # Let Superset auto-generate
    position_json = $sourceDashboard.result.position_json
    json_metadata = if ($sourceDashboard.result.json_metadata) { $sourceDashboard.result.json_metadata } else { "{}" }
    css = if ($sourceDashboard.result.css) { $sourceDashboard.result.css } else { "" }
    published = $false
} | ConvertTo-Json -Depth 10

Write-Host "`nClone dashboard data prepared:" -ForegroundColor Cyan
Write-Host "Title: CLONED - $($sourceDashboard.result.dashboard_title) - $timestamp" -ForegroundColor White

# Create cloned dashboard - try minimal approach first
Write-Host "`nCreating minimal dashboard first..." -ForegroundColor Yellow

$minimalDashboard = @{
    dashboard_title = "CLONED - $($sourceDashboard.result.dashboard_title) - $timestamp"
    published = $false
} | ConvertTo-Json -Depth 10

try {
    $minimalResponse = Invoke-RestMethod -Uri "$SupersetUrl/api/v1/dashboard/" -Method POST -Headers $headers -Body $minimalDashboard
    $clonedDashboardId = $minimalResponse.id
    
    Write-Host "SUCCESS: Minimal dashboard created with ID: $clonedDashboardId" -ForegroundColor Green
    
    # Now update it with the full structure
    Write-Host "`nUpdating dashboard with full structure..." -ForegroundColor Yellow
    
    $updateData = @{
        position_json = $sourceDashboard.result.position_json
        json_metadata = if ($sourceDashboard.result.json_metadata) { $sourceDashboard.result.json_metadata } else { "{}" }
        css = if ($sourceDashboard.result.css) { $sourceDashboard.result.css } else { "" }
    } | ConvertTo-Json -Depth 10
    
    $updateResponse = Invoke-RestMethod -Uri "$SupersetUrl/api/v1/dashboard/$clonedDashboardId" -Method PUT -Headers $headers -Body $updateData
    
    Write-Host "SUCCESS: Dashboard updated with full structure!" -ForegroundColor Green
    Write-Host "Dashboard URL: $SupersetUrl/superset/dashboard/$clonedDashboardId/" -ForegroundColor Green
    
    # Get chart IDs from the source dashboard
    $chartIds = @()
    $positionData = $sourceDashboard.result.position_json | ConvertFrom-Json
    
    # Extract chart IDs from position_json
    $positionData.PSObject.Properties | ForEach-Object {
        if ($_.Value.meta -and $_.Value.meta.chartId) {
            $chartIds += $_.Value.meta.chartId
        }
    }
    
    Write-Host "`nChart IDs to associate: $($chartIds -join ', ')" -ForegroundColor Cyan
    
    # Associate charts with the new dashboard
    if ($chartIds.Count -gt 0) {
        Write-Host "`nAssociating charts with cloned dashboard..." -ForegroundColor Yellow
        
        foreach ($chartId in $chartIds) {
            try {
                # Get current chart data
                $chartData = Invoke-RestMethod -Uri "$SupersetUrl/api/v1/chart/$chartId" -Headers $headers
                
                # Add new dashboard to chart's dashboard list
                $currentDashboards = @($chartData.result.dashboards | ForEach-Object { $_.id })
                if ($clonedDashboardId -notin $currentDashboards) {
                    $currentDashboards += $clonedDashboardId
                }
                
                # Update chart with new dashboard association
                $updateChartData = @{
                    dashboards = $currentDashboards
                } | ConvertTo-Json -Depth 10
                
                $updateResponse = Invoke-RestMethod -Uri "$SupersetUrl/api/v1/chart/$chartId" -Method PUT -Headers $headers -Body $updateChartData
                Write-Host "  Chart $chartId associated successfully" -ForegroundColor Green
                
            } catch {
                Write-Host "  Failed to associate chart $chartId : $($_.Exception.Message)" -ForegroundColor Red
            }
        }
    }
    
    Write-Host "`nCloning process completed!" -ForegroundColor Green
    Write-Host "Original Dashboard: $SupersetUrl/superset/dashboard/$SourceDashboardId/" -ForegroundColor White
    Write-Host "Cloned Dashboard: $SupersetUrl/superset/dashboard/$clonedDashboardId/" -ForegroundColor White
    
} catch {
    Write-Host "FAILED to create dashboard: $($_.Exception.Message)" -ForegroundColor Red
    Write-Host "Response details: $($_.Exception.Response)" -ForegroundColor Red
    
    # Try to get more detailed error information
    if ($_.Exception.Response) {
        try {
            $errorStream = $_.Exception.Response.GetResponseStream()
            $reader = New-Object System.IO.StreamReader($errorStream)
            $errorBody = $reader.ReadToEnd()
            Write-Host "Error body: $errorBody" -ForegroundColor Red
        } catch {
            Write-Host "Could not read error details" -ForegroundColor Red
        }
    }
}

Write-Host "`nTest completed at $(Get-Date)" -ForegroundColor Cyan