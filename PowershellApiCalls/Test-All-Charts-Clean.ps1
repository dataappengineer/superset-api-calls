# Superset Chart Creation Test Script - VALIDATED Chart Types + UI Clones
# Tests 20 visualization types with Superset v6 API (validated + working UI clones)
# All configurations match API_Chart_Creation_Reference.md documentation

# Configuration
$SupersetUrl = "http://localhost:8080"
$Username = "admin"
$Password = "admin"

Write-Host "Starting Superset Chart Testing..." -ForegroundColor Yellow
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

$timestamp = Get-Date -Format 'HHmmss'

# Chart definitions - Only VALIDATED and DOCUMENTED chart types
$charts = @(
    @{
        name = "1. Table (RAW)"
        type = "table"
        params = "{`"datasource`":{`"id`":17,`"type`":`"table`"},`"viz_type`":`"table`",`"adhoc_filters`":[{`"expressionType`":`"SIMPLE`",`"subject`":`"daily_members_posting_messages`",`"operator`":`">`",`"comparator`":1,`"clause`":`"WHERE`"}],`"all_columns`":[`"date`",`"daily_members_posting_messages`"],`"row_limit`":100}"
    },
    @{
        name = "2. Table (AGGREGATE)"
        type = "table"
        params = "{`"datasource`":{`"id`":17,`"type`":`"table`"},`"viz_type`":`"table`",`"query_mode`":`"aggregate`",`"groupby`":[`"date`"],`"metrics`":[`"count`"],`"adhoc_filters`":[],`"row_limit`":100,`"order_desc`":true}"
    },
    @{
        name = "3. Pivot Table (Metrics on ROWS)"
        type = "pivot_table_v2"
        params = "{`"datasource`":{`"id`":17,`"type`":`"table`"},`"viz_type`":`"pivot_table_v2`",`"groupbyRows`":[`"date`"],`"groupbyColumns`":[],`"metrics`":[`"count`"],`"metricsLayout`":`"ROWS`",`"adhoc_filters`":[],`"row_limit`":10000,`"aggregateFunction`":`"Sum`"}"
    },
    @{
        name = "4. Pivot Table (Metrics on COLUMNS)"
        type = "pivot_table_v2"
        params = "{`"datasource`":{`"id`":17,`"type`":`"table`"},`"viz_type`":`"pivot_table_v2`",`"groupbyRows`":[],`"groupbyColumns`":[`"date`"],`"metrics`":[`"count`"],`"metricsLayout`":`"COLUMNS`",`"adhoc_filters`":[],`"row_limit`":10000,`"aggregateFunction`":`"Sum`"}"
    },
    @{
        name = "5. Pie Chart"
        type = "pie"
        params = "{`"datasource`":{`"id`":17,`"type`":`"table`"},`"viz_type`":`"pie`",`"groupby`":[`"date`"],`"metric`":`"count`",`"adhoc_filters`":[],`"row_limit`":50,`"color_scheme`":`"bnbColors`",`"donut`":false,`"show_labels`":true,`"labels_outside`":false,`"outerRadius`":70,`"innerRadius`":30}"
    },
    @{
        name = "6. Line Chart"
        type = "echarts_timeseries_line"
        params = "{`"datasource`":{`"id`":17,`"type`":`"table`"},`"viz_type`":`"echarts_timeseries_line`",`"granularity_sqla`":`"date`",`"metrics`":[`"count`"],`"groupby`":[],`"adhoc_filters`":[],`"row_limit`":1000,`"color_scheme`":`"bnbColors`",`"show_legend`":true,`"rich_tooltip`":true}"
    },
    @{
        name = "7. Bar Chart"
        type = "echarts_timeseries_bar"
        datasource_id = 9
        params = "{`"datasource`":{`"id`":9,`"type`":`"table`"},`"viz_type`":`"echarts_timeseries_bar`",`"x_axis`":`"order_date`",`"time_grain_sqla`":`"P1M`",`"x_axis_sort_asc`":true,`"x_axis_sort_series`":`"name`",`"x_axis_sort_series_ascending`":true,`"metrics`":[`"count`"],`"groupby`":[`"deal_size`"],`"adhoc_filters`":[{`"clause`":`"WHERE`",`"subject`":`"order_date`",`"operator`":`"TEMPORAL_RANGE`",`"comparator`":`"No filter`",`"expressionType`":`"SIMPLE`"}],`"order_desc`":true,`"row_limit`":10000,`"truncate_metric`":true,`"show_empty_columns`":true,`"comparison_type`":`"values`",`"annotation_layers`":[],`"forecastPeriods`":10,`"forecastInterval`":0.8,`"orientation`":`"vertical`",`"x_axis_title_margin`":15,`"y_axis_title_margin`":15,`"y_axis_title_position`":`"Left`",`"sort_series_type`":`"sum`",`"color_scheme`":`"supersetColors`",`"only_total`":true,`"show_legend`":true,`"legendType`":`"scroll`",`"legendOrientation`":`"top`",`"x_axis_time_format`":`"smart_date`",`"y_axis_format`":`"SMART_NUMBER`",`"truncateXAxis`":true,`"y_axis_bounds`":[null,null],`"rich_tooltip`":true,`"tooltipTimeFormat`":`"smart_date`",`"extra_form_data`":{},`"dashboards`":[]}"
    },
    @{
        name = "8. Heat Map"
        type = "heatmap_v2"
        datasource_id = 9
        params = "{`"datasource`":{`"id`":9,`"type`":`"table`"},`"viz_type`":`"heatmap_v2`",`"x_axis`":`"product_line`",`"time_grain_sqla`":`"P1D`",`"groupby`":`"deal_size`",`"metric`":`"count`",`"adhoc_filters`":[{`"clause`":`"WHERE`",`"subject`":`"order_date`",`"operator`":`"TEMPORAL_RANGE`",`"comparator`":`"No filter`",`"expressionType`":`"SIMPLE`"}],`"row_limit`":10000,`"sort_x_axis`":`"alpha_asc`",`"sort_y_axis`":`"alpha_asc`",`"normalize_across`":`"heatmap`",`"legend_type`":`"continuous`",`"linear_color_scheme`":`"superset_seq_1`",`"xscale_interval`":-1,`"yscale_interval`":-1,`"left_margin`":`"auto`",`"bottom_margin`":`"auto`",`"value_bounds`":[null,null],`"y_axis_format`":`"SMART_NUMBER`",`"x_axis_time_format`":`"smart_date`",`"show_legend`":true,`"show_percentage`":true,`"show_values`":true,`"extra_form_data`":{},`"dashboards`":[],`"annotation_layers`":[]}"
    },
    @{
        name = "9. Tree Chart"
        type = "tree_chart"
        datasource_id = 20
        params = "{`"datasource`":{`"id`":20,`"type`":`"table`"},`"viz_type`":`"tree_chart`",`"id`":`"id`",`"parent`":`"parent`",`"name`":`"name`",`"root_node_id`":`"1`",`"metric`":`"count`",`"adhoc_filters`":[],`"row_limit`":1000,`"layout`":`"radial`",`"node_label_position`":`"top`",`"child_label_position`":`"top`",`"symbol`":`"emptyCircle`",`"symbolSize`":7,`"roam`":false,`"extra_form_data`":{},`"dashboards`":[],`"annotation_layers`":[]}"
    },
    @{
        name = "10. Scatter Plot"
        type = "echarts_timeseries_scatter"
        datasource_id = 9
        params = "{`"datasource`":{`"id`":9,`"type`":`"table`"},`"viz_type`":`"echarts_timeseries_scatter`",`"x_axis`":`"order_date`",`"time_grain_sqla`":`"P1D`",`"x_axis_sort_asc`":true,`"x_axis_sort_series`":`"name`",`"x_axis_sort_series_ascending`":true,`"metrics`":[`"count`"],`"groupby`":[`"deal_size`"],`"adhoc_filters`":[{`"clause`":`"WHERE`",`"subject`":`"order_date`",`"operator`":`"TEMPORAL_RANGE`",`"comparator`":`"No filter`",`"expressionType`":`"SIMPLE`"}],`"order_desc`":true,`"row_limit`":10000,`"truncate_metric`":true,`"show_empty_columns`":true,`"comparison_type`":`"values`",`"annotation_layers`":[],`"forecastPeriods`":10,`"forecastInterval`":0.8,`"x_axis_title_margin`":15,`"y_axis_title_margin`":15,`"y_axis_title_position`":`"Left`",`"sort_series_type`":`"sum`",`"color_scheme`":`"supersetColors`",`"only_total`":true,`"markerSize`":6,`"show_legend`":true,`"legendType`":`"scroll`",`"legendOrientation`":`"top`",`"x_axis_time_format`":`"smart_date`",`"rich_tooltip`":true,`"tooltipTimeFormat`":`"smart_date`",`"y_axis_format`":`"SMART_NUMBER`",`"truncateXAxis`":true,`"y_axis_bounds`":[null,null],`"extra_form_data`":{},`"dashboards`":[]}"
    },
    @{
        name = "11. Big Number"
        type = "big_number_total"
        datasource_id = 9
        params = "{`"datasource`":{`"id`":9,`"type`":`"table`"},`"viz_type`":`"big_number_total`",`"metric`":`"count`",`"adhoc_filters`":[{`"clause`":`"WHERE`",`"subject`":`"order_date`",`"operator`":`"TEMPORAL_RANGE`",`"comparator`":`"No filter`",`"expressionType`":`"SIMPLE`"}],`"header_font_size`":0.4,`"subheader_font_size`":0.15,`"y_axis_format`":`"SMART_NUMBER`",`"time_format`":`"smart_date`",`"extra_form_data`":{},`"dashboards`":[],`"annotation_layers`":[]}"
    },
    @{
        name = "12. Gauge Chart"
        type = "gauge_chart"
        datasource_id = 9
        params = "{`"datasource`":{`"id`":9,`"type`":`"table`"},`"viz_type`":`"gauge_chart`",`"groupby`":[`"deal_size`"],`"metric`":`"count`",`"adhoc_filters`":[{`"clause`":`"WHERE`",`"subject`":`"order_date`",`"operator`":`"TEMPORAL_RANGE`",`"comparator`":`"No filter`",`"expressionType`":`"SIMPLE`"}],`"start_angle`":225,`"end_angle`":-45,`"color_scheme`":`"supersetColors`",`"font_size`":13,`"number_format`":`"SMART_NUMBER`",`"value_formatter`":`"{value}%`",`"show_pointer`":true,`"animation`":true,`"show_axis_label`":true,`"show_progress`":true,`"overlap`":true,`"round_cap`":false,`"row_limit`":10}"
    },
    @{
        name = "13. Area Chart"
        type = "echarts_area"
        datasource_id = 9
        params = "{`"datasource`":{`"id`":9,`"type`":`"table`"},`"viz_type`":`"echarts_area`",`"x_axis`":`"order_date`",`"time_grain_sqla`":`"P1W`",`"x_axis_sort_asc`":true,`"x_axis_sort_series`":`"name`",`"x_axis_sort_series_ascending`":true,`"metrics`":[`"count`"],`"groupby`":[`"deal_size`"],`"adhoc_filters`":[{`"clause`":`"WHERE`",`"subject`":`"order_date`",`"operator`":`"TEMPORAL_RANGE`",`"comparator`":`"No filter`",`"expressionType`":`"SIMPLE`"}],`"order_desc`":true,`"row_limit`":10000,`"truncate_metric`":true,`"show_empty_columns`":true,`"comparison_type`":`"values`",`"annotation_layers`":[],`"forecastPeriods`":10,`"forecastInterval`":0.8,`"x_axis_title_margin`":15,`"y_axis_title_margin`":15,`"y_axis_title_position`":`"Left`",`"sort_series_type`":`"sum`",`"color_scheme`":`"supersetColors`",`"seriesType`":`"echarts_timeseries_line`",`"opacity`":0.2,`"only_total`":true,`"markerSize`":6,`"show_legend`":true,`"legendType`":`"scroll`",`"legendOrientation`":`"top`",`"x_axis_time_format`":`"smart_date`",`"rich_tooltip`":true,`"tooltipTimeFormat`":`"smart_date`",`"y_axis_format`":`"SMART_NUMBER`",`"truncateXAxis`":true,`"y_axis_bounds`":[null,null],`"extra_form_data`":{},`"dashboards`":[]}"
    },
    @{
        name = "14. Waterfall Chart"
        type = "waterfall"
        datasource_id = 9
        params = "{`"datasource`":{`"id`":9,`"type`":`"table`"},`"viz_type`":`"waterfall`",`"x_axis`":`"order_date`",`"time_grain_sqla`":`"P3M`",`"groupby`":[],`"metric`":`"count`",`"adhoc_filters`":[{`"clause`":`"WHERE`",`"subject`":`"order_date`",`"operator`":`"TEMPORAL_RANGE`",`"comparator`":`"No filter`",`"expressionType`":`"SIMPLE`"}],`"row_limit`":10000,`"show_value`":true,`"increase_color`":{`"r`":90,`"g`":193,`"b`":137,`"a`":1},`"decrease_color`":{`"r`":224,`"g`":67,`"b`":85,`"a`":1},`"total_color`":{`"r`":102,`"g`":102,`"b`":102,`"a`":1},`"x_axis_time_format`":`"smart_date`",`"x_ticks_layout`":`"auto`",`"y_axis_format`":`"SMART_NUMBER`",`"extra_form_data`":{},`"dashboards`":[],`"annotation_layers`":[]}"
    },
    @{
        name = "15. Histogram"
        type = "histogram_v2"
        datasource_id = 9
        params = "{`"datasource`":{`"id`":9,`"type`":`"table`"},`"viz_type`":`"histogram_v2`",`"column`":`"quantity_ordered`",`"groupby`":[`"deal_size`"],`"adhoc_filters`":[{`"clause`":`"WHERE`",`"subject`":`"order_date`",`"operator`":`"TEMPORAL_RANGE`",`"comparator`":`"No filter`",`"expressionType`":`"SIMPLE`"}],`"row_limit`":10000,`"bins`":10,`"normalize`":false,`"color_scheme`":`"supersetColors`",`"show_value`":false,`"show_legend`":true,`"extra_form_data`":{},`"dashboards`":[],`"annotation_layers`":[]}"
    },
    @{
        name = "16. Funnel Chart"
        type = "funnel"
        datasource_id = 9
        params = "{`"datasource`":{`"id`":9,`"type`":`"table`"},`"viz_type`":`"funnel`",`"groupby`":[`"deal_size`"],`"metric`":`"count`",`"adhoc_filters`":[{`"clause`":`"WHERE`",`"subject`":`"order_date`",`"operator`":`"TEMPORAL_RANGE`",`"comparator`":`"No filter`",`"expressionType`":`"SIMPLE`"}],`"row_limit`":10,`"sort_by_metric`":true,`"percent_calculation_type`":`"first_step`",`"color_scheme`":`"supersetColors`",`"show_legend`":true,`"legendOrientation`":`"top`",`"legendMargin`":50,`"tooltip_label_type`":5,`"number_format`":`"SMART_NUMBER`",`"show_labels`":true,`"show_tooltip_labels`":true,`"extra_form_data`":{},`"dashboards`":[],`"annotation_layers`":[]}"
    },
    @{
        name = "17. Bullet Chart"
        type = "bullet"
        datasource_id = 9
        params = "{`"datasource`":{`"id`":9,`"type`":`"table`"},`"viz_type`":`"bullet`",`"metric`":`"count`",`"adhoc_filters`":[{`"clause`":`"WHERE`",`"subject`":`"order_date`",`"operator`":`"TEMPORAL_RANGE`",`"comparator`":`"No filter`",`"expressionType`":`"SIMPLE`"}],`"ranges`":`"3000`",`"range_labels`":`"Target Range`",`"markers`":`"2000`",`"marker_labels`":`"Current Value`",`"marker_lines`":`"`",`"marker_line_labels`":`"`",`"extra_form_data`":{},`"dashboards`":[]}"
    },
    @{
        name = "18. Mixed Chart"
        type = "mixed_timeseries"
        datasource_id = 9
        params = "{`"datasource`":{`"id`":9,`"type`":`"table`"},`"viz_type`":`"mixed_timeseries`",`"x_axis`":`"order_date`",`"time_grain_sqla`":`"P1M`",`"metrics`":[`"count`"],`"groupby`":[],`"adhoc_filters`":[{`"clause`":`"WHERE`",`"subject`":`"order_date`",`"operator`":`"TEMPORAL_RANGE`",`"comparator`":`"No filter`",`"expressionType`":`"SIMPLE`"}],`"order_desc`":true,`"row_limit`":10000,`"truncate_metric`":true,`"comparison_type`":`"values`",`"metrics_b`":[`"count`"],`"groupby_b`":[],`"adhoc_filters_b`":[{`"clause`":`"WHERE`",`"subject`":`"order_date`",`"operator`":`"TEMPORAL_RANGE`",`"comparator`":`"No filter`",`"expressionType`":`"SIMPLE`"}],`"order_desc_b`":true,`"row_limit_b`":10000,`"truncate_metric_b`":true,`"comparison_type_b`":`"values`",`"annotation_layers`":[],`"x_axis_title_margin`":15,`"y_axis_title_margin`":15,`"y_axis_title_position`":`"Left`",`"color_scheme`":`"supersetColors`",`"seriesType`":`"bar`",`"opacity`":0.2,`"markerSize`":6,`"yAxisIndex`":1,`"sort_series_type`":`"sum`",`"seriesTypeB`":null,`"opacityB`":0.2,`"markerSizeB`":6,`"yAxisIndexB`":0,`"sort_series_typeB`":`"sum`",`"show_legend`":true,`"legendType`":`"scroll`",`"legendOrientation`":`"top`",`"x_axis_time_format`":`"smart_date`",`"rich_tooltip`":true,`"tooltipTimeFormat`":`"smart_date`",`"truncateXAxis`":true,`"y_axis_bounds`":[null,null],`"y_axis_format`":`"SMART_NUMBER`",`"y_axis_bounds_secondary`":[null,null],`"y_axis_format_secondary`":`"SMART_NUMBER`",`"extra_form_data`":{},`"dashboards`":[]}"
    },
    @{
        name = "19. Country Map"
        type = "country_map"
        datasource_id = 9
        params = "{`"datasource`":{`"id`":9,`"type`":`"table`"},`"viz_type`":`"country_map`",`"entity`":`"deal_size`",`"metric`":`"count`",`"select_country`":`"usa`",`"row_limit`":50000,`"adhoc_filters`":[{`"clause`":`"WHERE`",`"subject`":`"order_date`",`"operator`":`"TEMPORAL_RANGE`",`"comparator`":`"No filter`",`"expressionType`":`"SIMPLE`"}],`"extra_form_data`":{},`"dashboards`":[],`"annotation_layers`":[]}"
    },
    @{
        name = "20. Deck.gl Scatterplot"
        type = "deck_scatter"
        datasource_id = 9
        params = "{`"datasource`":{`"id`":9,`"type`":`"table`"},`"viz_type`":`"deck_scatter`",`"spatial`":{`"latCol`":`"latitude`",`"lonCol`":`"longitude`",`"type`":`"latlong`"},`"size`":`"count`",`"point_radius_fixed`":{`"type`":`"metric`",`"value`":`"count`"},`"color_picker`":{`"r`":205,`"g`":0,`"b`":3,`"a`":0.82},`"mapbox_style`":`"https://tile.openstreetmap.org/{z}/{x}/{y}.png`",`"viewport`":{`"latitude`":37.7893,`"longitude`":-122.4261,`"zoom`":12.7,`"bearing`":0,`"pitch`":0},`"point_unit`":`"square_m`",`"min_radius`":1,`"max_radius`":250,`"multiplier`":10,`"row_limit`":5000,`"adhoc_filters`":[{`"clause`":`"WHERE`",`"subject`":`"order_date`",`"operator`":`"TEMPORAL_RANGE`",`"comparator`":`"No filter`",`"expressionType`":`"SIMPLE`"}],`"extra_form_data`":{},`"dashboards`":[],`"annotation_layers`":[]}"
    }
)

# Test each chart type
$results = @()
$headers = @{
    "Authorization" = "Bearer $accessToken"
    "Content-Type" = "application/json"
}

Write-Host "`nTesting chart types..." -ForegroundColor Yellow

foreach ($chart in $charts) {
    $chartName = "$($chart.name) - Test $timestamp"
    
    Write-Host "`nTesting: $($chart.name)" -ForegroundColor Cyan
    
    # Use datasource_id from chart definition if available, otherwise default to 17
    $datasourceId = if ($chart.datasource_id) { $chart.datasource_id } else { 17 }
    
    # Use EXACT same format as Quick-Test.ps1
    $body = @{
        datasource_id = $datasourceId
        datasource_type = "table"
        slice_name = $chartName
        viz_type = $chart.type
        params = $chart.params
    } | ConvertTo-Json -Depth 10
    
    $result = @{
        Name = $chart.name
        Status = ""
        ChartID = ""
        Error = ""
    }
    
    try {
        $response = Invoke-RestMethod -Uri "$SupersetUrl/api/v1/chart/" -Method POST -Headers $headers -Body $body
        $result.Status = "SUCCESS"
        $result.ChartID = $response.id
        Write-Host "   SUCCESS: Chart created with ID $($response.id)" -ForegroundColor Green
    } catch {
        $result.Status = "FAILED"
        $result.Error = $_.Exception.Message
        Write-Host "   FAILED: $($_.Exception.Message)" -ForegroundColor Red
    }
    
    $results += $result
    Start-Sleep -Milliseconds 500  # Small delay between requests
}

# Summary Report
Write-Host "`nSUMMARY REPORT" -ForegroundColor Cyan
Write-Host "==================" -ForegroundColor Cyan

$successful = $results | Where-Object { $_.Status -eq "SUCCESS" }
$failed = $results | Where-Object { $_.Status -eq "FAILED" }

Write-Host "Successful: $($successful.Count)/$($results.Count)" -ForegroundColor Green
Write-Host "Failed: $($failed.Count)/$($results.Count)" -ForegroundColor Red

if ($successful.Count -gt 0) {
    Write-Host "`nSuccessful Charts:" -ForegroundColor Green
    foreach ($success in $successful) {
        Write-Host "   - $($success.Name) - ID: $($success.ChartID)" -ForegroundColor White
    }
}

if ($failed.Count -gt 0) {
    Write-Host "`nFailed Charts:" -ForegroundColor Red
    foreach ($failure in $failed) {
        Write-Host "   - $($failure.Name) - Error: $($failure.Error)" -ForegroundColor White
    }
}

Write-Host "`nTest completed at $(Get-Date)" -ForegroundColor Cyan