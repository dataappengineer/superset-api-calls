# Guida Postman - Creazione Grafici Superset

Questa guida fornisce esempi di chiamate Postman per creare diversi tipi di grafici in Apache Superset, equivalenti al file `Test-All-Charts-Clean.ps1`.

## Setup Iniziale

### 1. Autenticazione
Prima di tutto, devi autenticarti per ottenere un token di accesso.

**POST** `{{superset_url}}/api/v1/security/login`

**Headers:**
```
Content-Type: application/json
```

**Body (raw JSON):**
```json
{
    "username": "admin",
    "password": "admin",
    "provider": "db",
    "refresh": true
}
```

**Risposta:**
Salva il valore `access_token` dalla risposta per usarlo nelle chiamate successive.

### 2. Variabili Postman
Configura queste variabili nella tua collection o environment:
- `superset_url`: http://localhost:8080
- `access_token`: [token ottenuto dal login]
- `timestamp`: {{$timestamp}} (per nomi univoci)

## Esempi di Creazione Grafici

### 1. Tabella (RAW)

**POST** `{{superset_url}}/api/v1/chart/`

**Headers:**
```
Authorization: Bearer {{access_token}}
Content-Type: application/json
```

**Body:**
```json
{
    "datasource_id": 17,
    "datasource_type": "table",
    "slice_name": "1. Tabella RAW - Test {{timestamp}}",
    "viz_type": "table",
    "params": "{\"datasource\":{\"id\":17,\"type\":\"table\"},\"viz_type\":\"table\",\"adhoc_filters\":[{\"expressionType\":\"SIMPLE\",\"subject\":\"daily_members_posting_messages\",\"operator\":\">\",\"comparator\":1,\"clause\":\"WHERE\"}],\"all_columns\":[\"date\",\"daily_members_posting_messages\"],\"row_limit\":100}"
}
```

### 2. Tabella (AGGREGATA)

**POST** `{{superset_url}}/api/v1/chart/`

**Headers:**
```
Authorization: Bearer {{access_token}}
Content-Type: application/json
```

**Body:**
```json
{
    "datasource_id": 17,
    "datasource_type": "table",
    "slice_name": "2. Tabella Aggregata - Test {{timestamp}}",
    "viz_type": "table",
    "params": "{\"datasource\":{\"id\":17,\"type\":\"table\"},\"viz_type\":\"table\",\"query_mode\":\"aggregate\",\"groupby\":[\"date\"],\"metrics\":[\"count\"],\"adhoc_filters\":[],\"row_limit\":100,\"order_desc\":true}"
}
```

### 3. Tabella Pivot (Metriche su RIGHE)

**POST** `{{superset_url}}/api/v1/chart/`

**Headers:**
```
Authorization: Bearer {{access_token}}
Content-Type: application/json
```

**Body:**
```json
{
    "datasource_id": 17,
    "datasource_type": "table",
    "slice_name": "3. Pivot Tabella Righe - Test {{timestamp}}",
    "viz_type": "pivot_table_v2",
    "params": "{\"datasource\":{\"id\":17,\"type\":\"table\"},\"viz_type\":\"pivot_table_v2\",\"groupbyRows\":[\"date\"],\"groupbyColumns\":[],\"metrics\":[\"count\"],\"metricsLayout\":\"ROWS\",\"adhoc_filters\":[],\"row_limit\":10000,\"aggregateFunction\":\"Sum\"}"
}
```

### 4. Grafico a Torta

**POST** `{{superset_url}}/api/v1/chart/`

**Headers:**
```
Authorization: Bearer {{access_token}}
Content-Type: application/json
```

**Body:**
```json
{
    "datasource_id": 17,
    "datasource_type": "table",
    "slice_name": "5. Grafico a Torta - Test {{timestamp}}",
    "viz_type": "pie",
    "params": "{\"datasource\":{\"id\":17,\"type\":\"table\"},\"viz_type\":\"pie\",\"groupby\":[\"date\"],\"metric\":\"count\",\"adhoc_filters\":[],\"row_limit\":50,\"color_scheme\":\"bnbColors\",\"donut\":false,\"show_labels\":true,\"labels_outside\":false,\"outerRadius\":70,\"innerRadius\":30}"
}
```

### 5. Grafico a Linee

**POST** `{{superset_url}}/api/v1/chart/`

**Headers:**
```
Authorization: Bearer {{access_token}}
Content-Type: application/json
```

**Body:**
```json
{
    "datasource_id": 17,
    "datasource_type": "table",
    "slice_name": "6. Grafico a Linee - Test {{timestamp}}",
    "viz_type": "echarts_timeseries_line",
    "params": "{\"datasource\":{\"id\":17,\"type\":\"table\"},\"viz_type\":\"echarts_timeseries_line\",\"granularity_sqla\":\"date\",\"metrics\":[\"count\"],\"groupby\":[],\"adhoc_filters\":[],\"row_limit\":1000,\"color_scheme\":\"bnbColors\",\"show_legend\":true,\"rich_tooltip\":true}"
}
```

### 6. Grafico a Barre

**POST** `{{superset_url}}/api/v1/chart/`

**Headers:**
```
Authorization: Bearer {{access_token}}
Content-Type: application/json
```

**Body:**
```json
{
    "datasource_id": 9,
    "datasource_type": "table",
    "slice_name": "7. Grafico a Barre - Test {{timestamp}}",
    "viz_type": "echarts_timeseries_bar",
    "params": "{\"datasource\":{\"id\":9,\"type\":\"table\"},\"viz_type\":\"echarts_timeseries_bar\",\"x_axis\":\"order_date\",\"time_grain_sqla\":\"P1M\",\"x_axis_sort_asc\":true,\"x_axis_sort_series\":\"name\",\"x_axis_sort_series_ascending\":true,\"metrics\":[\"count\"],\"groupby\":[\"deal_size\"],\"adhoc_filters\":[{\"clause\":\"WHERE\",\"subject\":\"order_date\",\"operator\":\"TEMPORAL_RANGE\",\"comparator\":\"No filter\",\"expressionType\":\"SIMPLE\"}],\"order_desc\":true,\"row_limit\":10000,\"truncate_metric\":true,\"show_empty_columns\":true,\"comparison_type\":\"values\",\"annotation_layers\":[],\"forecastPeriods\":10,\"forecastInterval\":0.8,\"orientation\":\"vertical\",\"x_axis_title_margin\":15,\"y_axis_title_margin\":15,\"y_axis_title_position\":\"Left\",\"sort_series_type\":\"sum\",\"color_scheme\":\"supersetColors\",\"only_total\":true,\"show_legend\":true,\"legendType\":\"scroll\",\"legendOrientation\":\"top\",\"x_axis_time_format\":\"smart_date\",\"y_axis_format\":\"SMART_NUMBER\",\"truncateXAxis\":true,\"y_axis_bounds\":[null,null],\"rich_tooltip\":true,\"tooltipTimeFormat\":\"smart_date\",\"extra_form_data\":{},\"dashboards\":[]}"
}
```

### 7. Heatmap

**POST** `{{superset_url}}/api/v1/chart/`

**Headers:**
```
Authorization: Bearer {{access_token}}
Content-Type: application/json
```

**Body:**
```json
{
    "datasource_id": 9,
    "datasource_type": "table",
    "slice_name": "8. Heatmap - Test {{timestamp}}",
    "viz_type": "heatmap_v2",
    "params": "{\"datasource\":{\"id\":9,\"type\":\"table\"},\"viz_type\":\"heatmap_v2\",\"x_axis\":\"product_line\",\"time_grain_sqla\":\"P1D\",\"groupby\":\"deal_size\",\"metric\":\"count\",\"adhoc_filters\":[{\"clause\":\"WHERE\",\"subject\":\"order_date\",\"operator\":\"TEMPORAL_RANGE\",\"comparator\":\"No filter\",\"expressionType\":\"SIMPLE\"}],\"row_limit\":10000,\"sort_x_axis\":\"alpha_asc\",\"sort_y_axis\":\"alpha_asc\",\"normalize_across\":\"heatmap\",\"legend_type\":\"continuous\",\"linear_color_scheme\":\"superset_seq_1\",\"xscale_interval\":-1,\"yscale_interval\":-1,\"left_margin\":\"auto\",\"bottom_margin\":\"auto\",\"value_bounds\":[null,null],\"y_axis_format\":\"SMART_NUMBER\",\"x_axis_time_format\":\"smart_date\",\"show_legend\":true,\"show_percentage\":true,\"show_values\":true,\"extra_form_data\":{},\"dashboards\":[],\"annotation_layers\":[]}"
}
```

### 8. Big Number

**POST** `{{superset_url}}/api/v1/chart/`

**Headers:**
```
Authorization: Bearer {{access_token}}
Content-Type: application/json
```

**Body:**
```json
{
    "datasource_id": 9,
    "datasource_type": "table",
    "slice_name": "11. Big Number - Test {{timestamp}}",
    "viz_type": "big_number_total",
    "params": "{\"datasource\":{\"id\":9,\"type\":\"table\"},\"viz_type\":\"big_number_total\",\"metric\":\"count\",\"adhoc_filters\":[{\"clause\":\"WHERE\",\"subject\":\"order_date\",\"operator\":\"TEMPORAL_RANGE\",\"comparator\":\"No filter\",\"expressionType\":\"SIMPLE\"}],\"header_font_size\":0.4,\"subheader_font_size\":0.15,\"y_axis_format\":\"SMART_NUMBER\",\"time_format\":\"smart_date\",\"extra_form_data\":{},\"dashboards\":[],\"annotation_layers\":[]}"
}
```

## Note Importanti

1. **ID Datasource**: Assicurati di utilizzare l'ID datasource corretto (17, 9, 20 negli esempi)
2. **Parametri**: I parametri JSON sono passati come stringhe nel campo `params`
3. **Timestamp**: Usa `{{$timestamp}}` per nomi univoci dei grafici
4. **Token**: Il token di accesso ha una durata limitata, rinnovalo se necessario

## Verifica Risultati

Dopo aver creato un grafico, puoi verificarlo con:

**GET** `{{superset_url}}/api/v1/chart/{{chart_id}}`

**Headers:**
```
Authorization: Bearer {{access_token}}
```

Questo restituirà i dettagli completi del grafico creato.