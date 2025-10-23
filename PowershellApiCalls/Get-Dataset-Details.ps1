param(
    [Parameter(Mandatory=$true)]
    [int]$DatasetId
)

# Get Dataset Details from UI Created Dataset with Parameter
$SupersetUrl = "http://localhost:8080"
$Username = "admin"
$Password = "admin"

Write-Host "Getting dataset details for ID $DatasetId..." -ForegroundColor Yellow

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

    $datasetDetails = Invoke-RestMethod -Uri "$SupersetUrl/api/v1/dataset/$DatasetId" -Headers $headers
    
    Write-Host "Dataset Name: $($datasetDetails.result.table_name)" -ForegroundColor Green
    Write-Host "Database ID: $($datasetDetails.result.database.id)" -ForegroundColor Green
    Write-Host "Database Name: $($datasetDetails.result.database.database_name)" -ForegroundColor Green
    Write-Host "Schema: $($datasetDetails.result.schema)" -ForegroundColor Green
    Write-Host "SQL: $($datasetDetails.result.sql)" -ForegroundColor Green
    Write-Host "Columns Count: $($datasetDetails.result.columns.Count)" -ForegroundColor Green
    
    Write-Host "`nDataset Structure:" -ForegroundColor Yellow
    Write-Host "ID: $($datasetDetails.result.id)" -ForegroundColor White
    Write-Host "Table Name: $($datasetDetails.result.table_name)" -ForegroundColor White
    Write-Host "Datasource Type: $($datasetDetails.result.datasource_type)" -ForegroundColor White
    Write-Host "Is SQL Lab View: $($datasetDetails.result.is_sqllab_view)" -ForegroundColor White
    Write-Host "Template Parameters: $($datasetDetails.result.template_params)" -ForegroundColor White
    
    Write-Host "`nFirst 10 columns:" -ForegroundColor Yellow
    $datasetDetails.result.columns | Select-Object -First 10 | ForEach-Object {
        Write-Host "  - $($_.column_name) ($($_.type)) - Groupable: $($_.groupby) - Filterable: $($_.filterable)" -ForegroundColor White
    }
    
    Write-Host "`nMetrics available:" -ForegroundColor Yellow
    $datasetDetails.result.metrics | ForEach-Object {
        Write-Host "  - $($_.metric_name) ($($_.metric_type)) - Expression: $($_.expression)" -ForegroundColor White
    }
    
    Write-Host "`nDatabase Connection Details:" -ForegroundColor Yellow
    Write-Host "  Database ID: $($datasetDetails.result.database.id)" -ForegroundColor White
    Write-Host "  Database Name: $($datasetDetails.result.database.database_name)" -ForegroundColor White
    Write-Host "  Backend: $($datasetDetails.result.database.backend)" -ForegroundColor White
    Write-Host "  Allow Run Async: $($datasetDetails.result.database.allow_run_async)" -ForegroundColor White
    
    Write-Host "`nOwnership:" -ForegroundColor Yellow
    Write-Host "  Owners: $($datasetDetails.result.owners -join ', ')" -ForegroundColor White
    Write-Host "  Created On: $($datasetDetails.result.created_on)" -ForegroundColor White
    Write-Host "  Changed On: $($datasetDetails.result.changed_on)" -ForegroundColor White
    
    Write-Host "`nFull JSON Response (for API reference):" -ForegroundColor Cyan
    $datasetDetails.result | ConvertTo-Json -Depth 10
    
} catch {
    Write-Host "FAILED to get dataset details: $($_.Exception.Message)" -ForegroundColor Red
    Write-Host "Response: $($_.Exception.Response)" -ForegroundColor Red
}