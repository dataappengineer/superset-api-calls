# Superset Virtual Dataset Creation Test Script  
# Tests creating a virtual dataset with custom SQL query

# Configuration
$SupersetUrl = "http://localhost:8080"
$Username = "admin"
$Password = "admin"

Write-Host "Starting Superset Virtual Dataset Creation Test..." -ForegroundColor Yellow
Write-Host "Superset URL: $SupersetUrl" -ForegroundColor Gray

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

# Get available databases
$databases = Invoke-RestMethod -Uri "$SupersetUrl/api/v1/database/" -Headers $headers
$databaseId = $databases.result[0].id
$databaseName = $databases.result[0].database_name

Write-Host "Using Database: ID=$databaseId, Name=$databaseName" -ForegroundColor Cyan

$timestamp = Get-Date -Format 'HHmmss'

# Create virtual dataset with custom SQL
Write-Host "`nCreating virtual dataset with custom SQL..." -ForegroundColor Yellow

$virtualDatasetData = @{
    database = $databaseId
    schema = $null
    sql = "SELECT 'test' as test_column, 1 as test_number, date('now') as test_date"
    table_name = "virtual_dataset_$timestamp"
    owners = @(1)
} | ConvertTo-Json -Depth 10

try {
    Write-Host "Attempting to create virtual dataset: virtual_dataset_$timestamp" -ForegroundColor Cyan
    $datasetResponse = Invoke-RestMethod -Uri "$SupersetUrl/api/v1/dataset/" -Method POST -Headers $headers -Body $virtualDatasetData
    
    Write-Host "SUCCESS: Virtual Dataset created!" -ForegroundColor Green
    Write-Host "Dataset ID: $($datasetResponse.id)" -ForegroundColor Green
    Write-Host "Dataset Name: virtual_dataset_$timestamp" -ForegroundColor Green
    Write-Host "Database: $databaseName (ID: $databaseId)" -ForegroundColor Green
    
    $createdDatasetId = $datasetResponse.id
    
    # Get the created dataset details
    Write-Host "`nGetting virtual dataset details..." -ForegroundColor Yellow
    $datasetDetails = Invoke-RestMethod -Uri "$SupersetUrl/api/v1/dataset/$createdDatasetId" -Headers $headers
    
    Write-Host "Virtual Dataset Details:" -ForegroundColor Cyan
    Write-Host "  - Dataset ID: $($datasetDetails.result.id)" -ForegroundColor White
    Write-Host "  - Table Name: $($datasetDetails.result.table_name)" -ForegroundColor White
    Write-Host "  - Database ID: $($datasetDetails.result.database.id)" -ForegroundColor White
    Write-Host "  - Database Name: $($datasetDetails.result.database.database_name)" -ForegroundColor White
    Write-Host "  - Schema: $($datasetDetails.result.schema)" -ForegroundColor White
    Write-Host "  - SQL: $($datasetDetails.result.sql)" -ForegroundColor White
    Write-Host "  - Is SQL Lab View: $($datasetDetails.result.is_sqllab_view)" -ForegroundColor White
    Write-Host "  - Kind: $($datasetDetails.result.kind)" -ForegroundColor White
    Write-Host "  - Columns Count: $($datasetDetails.result.columns.Count)" -ForegroundColor White
    Write-Host "  - Metrics Count: $($datasetDetails.result.metrics.Count)" -ForegroundColor White
    
    if ($datasetDetails.result.columns.Count -gt 0) {
        Write-Host "`nColumns in virtual dataset:" -ForegroundColor Yellow
        $datasetDetails.result.columns | ForEach-Object {
            Write-Host "    - $($_.column_name) ($($_.type)) - Groupable: $($_.groupby)" -ForegroundColor Gray
        }
    }
    
    if ($datasetDetails.result.metrics.Count -gt 0) {
        Write-Host "`nAvailable metrics:" -ForegroundColor Yellow
        $datasetDetails.result.metrics | ForEach-Object {
            Write-Host "    - $($_.metric_name): $($_.expression)" -ForegroundColor Gray
        }
    }
    
    # Test creating a chart with the new virtual dataset
    Write-Host "`nTesting chart creation with virtual dataset..." -ForegroundColor Yellow
    
    $chartData = @{
        datasource_id = $createdDatasetId
        datasource_type = "table"
        slice_name = "Test Chart - Virtual Dataset $createdDatasetId - $timestamp"
        viz_type = "table"
        params = "{`"datasource`":{`"id`":$createdDatasetId,`"type`":`"table`"},`"viz_type`":`"table`",`"all_columns`":[`"test_column`",`"test_number`",`"test_date`"],`"row_limit`":10}"
    } | ConvertTo-Json -Depth 10
    
    try {
        $chartResponse = Invoke-RestMethod -Uri "$SupersetUrl/api/v1/chart/" -Method POST -Headers $headers -Body $chartData
        Write-Host "SUCCESS: Chart created with ID $($chartResponse.id) using virtual dataset!" -ForegroundColor Green
        
        # Show the complete workflow
        Write-Host "`n=== COMPLETE WORKFLOW SUCCESSFUL ===" -ForegroundColor Green
        Write-Host "1. Virtual Dataset Created: ID $createdDatasetId" -ForegroundColor White
        Write-Host "2. Chart Created: ID $($chartResponse.id)" -ForegroundColor White
        Write-Host "3. Dataset can be used for any chart type!" -ForegroundColor White
        
    } catch {
        Write-Host "Chart creation failed: $($_.Exception.Message)" -ForegroundColor Red
    }
    
} catch {
    Write-Host "FAILED to create virtual dataset: $($_.Exception.Message)" -ForegroundColor Red
    
    # Try to get more detailed error information
    if ($_.Exception.Response) {
        try {
            $errorStream = $_.Exception.Response.GetResponseStream()
            $reader = New-Object System.IO.StreamReader($errorStream)
            $errorBody = $reader.ReadToEnd()
            Write-Host "Error details: $errorBody" -ForegroundColor Red
        } catch {
            Write-Host "Could not read error details" -ForegroundColor Red
        }
    }
}

Write-Host "`nTest completed at $(Get-Date)" -ForegroundColor Cyan

# Show the API call structure for future reference
Write-Host "`n" -ForegroundColor White
Write-Host "=== VIRTUAL DATASET API STRUCTURE ===" -ForegroundColor Yellow
Write-Host "Virtual Dataset Creation:" -ForegroundColor Cyan
Write-Host @"
{
  "database": 1,
  "schema": null,
  "sql": "SELECT 'test' as column1, 1 as column2",
  "table_name": "my_virtual_dataset",
  "owners": [1]
}
"@ -ForegroundColor Gray

Write-Host ""
Write-Host "Physical Table Dataset Creation:" -ForegroundColor Cyan
Write-Host @"
{
  "database": 1,
  "table_name": "existing_table_name",
  "schema": null,
  "owners": [1]
}
"@ -ForegroundColor Gray