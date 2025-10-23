
# 📊 Riferimento API per Creazione Chart Superset

## 🎯 Obiettivo
Documentazione dettagliata dei parametri API e esempi pratici per la creazione automatica di chart e dashboard in Superset tramite chiamate REST.

> 📋 **Stato Validazione**: **20 tipi di chart completamente validati e testati** con Superset v6 API
> - ✅ Table (RAW e AGGREGATE)
> - ✅ Pivot Table (ROWS e COLUMNS) 
> - ✅ Bar Chart (echarts_timeseries_bar) - **Versione Corretta con Dataset Specifico**
> - ✅ Pie Chart
> - ✅ Line Chart (echarts_timeseries_line)
> - ✅ Heat Map (heatmap_v2)
> - ✅ Tree Chart (tree_chart)
> - ✅ Scatter Plot (echarts_timeseries_scatter)
> - ✅ Big Number (big_number_total)
> - ✅ Gauge Chart (gauge_chart) - **NUOVO**
> - ✅ Area Chart (echarts_area) - **NUOVO**
> - ✅ Waterfall Chart (waterfall) - **NUOVO**
> - ✅ Histogram (histogram_v2) - **NUOVO**
> - ✅ Funnel Chart (funnel) - **NUOVO**
> - ✅ Bullet Chart (bullet) - **NUOVO**
> - ✅ Mixed Chart (mixed_timeseries) - **NUOVO**
> - ✅ Country Map (country_map) - **NUOVO**
> - ✅ Deck.gl Scatterplot (deck_scatter) - **NUOVO**

---
## 📑 Indice

- [🔑 Autenticazione (comune a tutte le chiamate)](#-autenticazione-comune-a-tutte-le-chiamate)
- [� Ottenere l'ID del Chart Creato](#-ottenere-lid-del-chart-creato)
- [�📋 Creazione Chart](#-creazione-chart)
  - [1. Table - Tabella Base](#1-table---tabella-base)
  - [2. Pivot Table - Tabella Pivot](#2-pivot-table---tabella-pivot)
  - [3. Bar Chart - Grafico a Barre](#3-bar-chart---grafico-a-barre)
  - [4. Pie Chart - Grafico a Torta](#4-pie-chart---grafico-a-torta)
  - [5. Line Chart - Grafico a Linee](#5-line-chart---grafico-a-linee)
  - [6. Heat Map - Mappa di Calore](#6-heat-map---mappa-di-calore)
  - [7. Tree Chart - Grafico ad Albero](#7-tree-chart---grafico-ad-albero)
  - [8. Scatter Plot - Grafico a Dispersione](#8-scatter-plot---grafico-a-dispersione)
  - [9. Big Number - Numero Grande](#9-big-number---numero-grande)
  - [10. Gauge Chart - Grafico a Indicatore](#10-gauge-chart---grafico-a-indicatore)
  - [11. Area Chart - Grafico ad Area](#11-area-chart---grafico-ad-area)
  - [12. Waterfall Chart - Grafico a Cascata](#12-waterfall-chart---grafico-a-cascata)
  - [13. Histogram - Istogramma](#13-histogram---istogramma)
  - [14. Funnel Chart - Grafico a Imbuto](#14-funnel-chart---grafico-a-imbuto)
  - [15. Bullet Chart - Grafico a Proiettile](#15-bullet-chart---grafico-a-proiettile)
  - [16. Mixed Chart - Grafico Combinato](#16-mixed-chart---grafico-combinato)
  - [17. Country Map - Mappa Paesi](#17-country-map---mappa-paesi)
  - [18. Deck.gl Scatterplot - Mappa Scatter](#18-deckgl-scatterplot---mappa-scatter)
  - [🔧 Schema Base e Parametri Comuni](#-schema-base-della-richiesta-post-apiv1chart)
- [📊 Creazione Dashboard con Filtri](#-creazione-dashboard-con-filtri-tramite-api)
  - [📋 Panoramica e Parametri Obbligatori](#panoramica-e-parametri-obbligatori)
  - [🔄 Workflow delle Chiamate API](#workflow-delle-chiamate-api-per-la-creazione-di-dashboard)
  - [⚠️ Note Tecniche Importanti](#note-tecniche-importanti)
  - [🎯 Creazione della Dashboard (Step-by-Step)](#creazione-della-dashboard-step-by-step)
    - [Step 1: Creazione della Dashboard](#1-creazione-della-dashboard)
    - [Step 2: Esempi Parametri Obbligatori](#2-esempi-pratici-di-parametri-obbligatori)
    - [Step 3: Chiamata POST Completa](#3-esempio-completo-di-chiamata-post-apiv1dashboard)
    - [Step 4: Aggiornamento Posizione (Opzionale)](#4-opzionale-aggiornamento-posizione-grafici)
    - [Step 5: Associazione Grafici (Opzionale)](#5-opzionale-associazione-esplicita-dei-grafici-alla-dashboard)
    - [Step 6: Verifica Finale](#6-verifica-finale)
- [🗄️ Creazione Dataset](#-creazione-dataset)

---
## 🔑 Autenticazione (comune a tutte le chiamate)

Prima di effettuare qualsiasi chiamata alle API di Superset, è necessario autenticarsi per ottenere un token JWT. Questo token va incluso nell'header `Authorization` di tutte le richieste successive.

- **API_BASE**: URL base delle API REST di Superset (es: `http://localhost:8080/api/v1`)
- **Token di autenticazione**: Token JWT ottenuto tramite login (`/security/login`)

**Endpoint:**  
`POST /api/v1/security/login`

**Body:**
```json
{
  "username": "NOME_UTENTE",
  "password": "PASSWORD",
  "provider": "db",
  "refresh": true
}
```

**Risposta:**  
Riceverai un oggetto JSON con il token di accesso (`access_token`).  
**Esempio header da usare nelle chiamate successive:**
```
Authorization: Bearer <access_token>
```

---

## 🔍 Ottenere l'ID del Chart Creato

Dopo ogni chiamata `POST /api/v1/chart/` con successo, la risposta contiene l'**ID del chart appena creato**:

**Struttura risposta di successo:**
```json
{
  "id": 123,
  "result": {
    "cache_timeout": null,
    "certification_details": null,
    "certified_by": null,
    "changed_by": {
      "first_name": "Admin",
      "id": 1,
      "last_name": "User"
    },
    "changed_by_name": "Admin User",
    "changed_on": "2024-01-15T10:30:00.000000",
    "changed_on_delta_humanized": "few seconds ago",
    "datasource_id": 9,
    "datasource_name_text": "orders",
    "datasource_type": "table",
    "datasource_url": "/datasource/table/9/",
    "description": null,
    "description_markeddown": "",
    "edit_url": "/chart/edit/123",
    "form_data": {...},
    "id": 123,
    "is_managed_externally": false,
    "last_saved_at": "2024-01-15T10:30:00.000000",
    "last_saved_by": {
      "first_name": "Admin",
      "id": 1,
      "last_name": "User"
    },
    "modified": "few seconds ago",
    "owners": [1],
    "params": "{...}",
    "query_context": {...},
    "slice_name": "My Chart Name",
    "slice_url": "/superset/explore/?form_data={...}",
    "thumbnail_url": "/api/v1/chart/123/thumbnail/",
    "url": "/chart/edit/123",
    "viz_type": "table"
  }
}
```

**Come estrarre l'ID:**
- L'**ID principale** si trova nel campo `id` a livello root della risposta
- È anche disponibile in `result.id` (stesso valore)
- Questo ID può essere utilizzato per operazioni successive come:
  - Modifica chart: `PUT /api/v1/chart/{id}`
  - Cancellazione: `DELETE /api/v1/chart/{id}`
  - Ottenere dettagli: `GET /api/v1/chart/{id}`

**Esempio di estrazione ID (PowerShell):**
```powershell
$response = Invoke-RestMethod -Uri "$SupersetUrl/api/v1/chart/" -Method POST -Headers $headers -Body $jsonBody -ContentType "application/json"
$chartId = $response.id
Write-Host "Chart creato con ID: $chartId"
```

---

## 📋 Creazione Chart

### 1. **Table** - Tabella Base

**Endpoint:**  
`POST /api/v1/chart/`


**Modalità RAW** (per visualizzare record effettivi):

**Parametri indispensabili per Superset v6:**
- `datasource_id`: ID numerico del dataset (**obbligatorio**)
- `datasource_type`: "table" (**obbligatorio**)
- `slice_name`: Nome del chart (**obbligatorio**)
- `viz_type`: "table" (**obbligatorio**)
- `params`: Stringa JSON con configurazione chart (**obbligatorio**)

**Parametri chiave in params (modalità RAW):**
- `all_columns`: Array con nomi delle colonne da visualizzare (es. ["colonna1","colonna2"]) (**obbligatorio**)
- `adhoc_filters`: Filtri sui dati (default: [])
- `row_limit`: Limite righe da visualizzare (default: 100)

**API d'esempio (v6) - versione validata e funzionante**:
```json
{
  "datasource_id": DATASET_ID,
  "datasource_type": "table",
  "slice_name": "Nome del Chart",
  "viz_type": "table",
  "params": "{\"datasource\":{\"id\":DATASET_ID,\"type\":\"table\"},\"viz_type\":\"table\",\"adhoc_filters\":[],\"all_columns\":[\"colonna1\",\"colonna2\",\"colonna3\"],\"row_limit\":100}"
}
```

> ⚠️ **IMPORTANTE per v6:**
> - Il campo `params` deve essere una **stringa JSON**, non un oggetto JSON
> - Il campo `datasource` dentro params usa la struttura `{"id": NUMBER, "type": "table"}`

**Parametri opzionali in params (v6):**
- `adhoc_filters`: Filtri sui dati in formato array (default: [])
  - **Formato corretto v6**: `[{"expressionType":"SIMPLE","subject":"colonna","operator":">","comparator":100,"clause":"WHERE"}]`
  - **Esempio**: `"comparator":100` con `"operator":">"` genera `WHERE colonna > 100`
  - Operatori: `>`, `<`, `>=`, `<=`, `==`, `!=`
- `row_limit`: Numero massimo di righe (default: 100)

**Esempio validato con filtro (FUNZIONANTE):**
```json
{
  "datasource_id": 17,
  "datasource_type": "table",
  "slice_name": "Table RAW with Filter",
  "viz_type": "table",
  "params": "{\"datasource\":{\"id\":17,\"type\":\"table\"},\"viz_type\":\"table\",\"adhoc_filters\":[{\"expressionType\":\"SIMPLE\",\"subject\":\"daily_members_posting_messages\",\"operator\":\">\",\"comparator\":1,\"clause\":\"WHERE\"}],\"all_columns\":[\"date\",\"daily_members_posting_messages\"],\"row_limit\":100}"
}
```


> 📝 **NOTA su datasource v6:**
> - L'ID numerico deve corrispondere al dataset esistente in Superset
> - La risposta includerà l'ID del chart creato per riferimenti futuri

> **Modalità AGGREGATE:**
>

**Modalità AGGREGATE** (per metriche aggregate):

**Parametri indispensabili:**
- `query_mode`: "aggregate" (**obbligatorio**)
- `groupby`: Colonne per raggruppamento (es. ["date"]) (**obbligatorio**)
- `metrics`: Metriche aggregate (es. ["count"]) (**obbligatorio**)

**Parametri chiave in params (modalità AGGREGATE):**
- `query_mode`: "aggregate" per attivare modalità aggregata (**obbligatorio**)
- `groupby`: Array con colonne di raggruppamento (es. ["date"]) (**obbligatorio**)
- `metrics`: Array con metriche da calcolare (es. ["count"]) (**obbligatorio**)
- `order_desc`: Ordinamento discendente (default: true)
- `adhoc_filters`: Filtri sui dati (default: [])
- `row_limit`: Limite righe aggregate (default: 100)

**Esempio validato AGGREGATE (FUNZIONANTE):**
```json
{
  "datasource_id": 17,
  "datasource_type": "table",
  "slice_name": "Table AGGREGATE",
  "viz_type": "table",
  "params": "{\"datasource\":{\"id\":17,\"type\":\"table\"},\"viz_type\":\"table\",\"query_mode\":\"aggregate\",\"groupby\":[\"date\"],\"metrics\":[\"count\"],\"adhoc_filters\":[],\"row_limit\":100,\"order_desc\":true}"
}
```

---

### 2. **Pivot Table** - Tabella Pivot

**Endpoint:** `POST /api/v1/chart/`

**Parametri indispensabili:**
- `datasource_id`: ID numerico del dataset (**obbligatorio**)
- `datasource_type`: "table" (**obbligatorio**)
- `slice_name`: Nome del chart (**obbligatorio**)
- `viz_type`: "pivot_table_v2" (**obbligatorio**)
- `params`: Stringa JSON con configurazione (**obbligatorio**)

**Parametri chiave in params:**
- `groupbyRows`: Righe della pivot (es. ["date"])
- `groupbyColumns`: Colonne della pivot (es. [])
- `metrics`: Metriche (es. ["count"])
- `metricsLayout`: "ROWS" o "COLUMNS" per disposizione metriche

**Esempio PIVOT - Metrics on ROWS (FUNZIONANTE):**
```json
{
  "datasource_id": 17,
  "datasource_type": "table",
  "slice_name": "Pivot Table (Metrics on ROWS)",
  "viz_type": "pivot_table_v2",
  "params": "{\"datasource\":{\"id\":17,\"type\":\"table\"},\"viz_type\":\"pivot_table_v2\",\"groupbyRows\":[\"date\"],\"groupbyColumns\":[],\"metrics\":[\"count\"],\"metricsLayout\":\"ROWS\",\"adhoc_filters\":[],\"row_limit\":10000,\"aggregateFunction\":\"Sum\"}"
}
```

**Esempio PIVOT - Metrics on COLUMNS (FUNZIONANTE):**
```json
{
  "datasource_id": 17,
  "datasource_type": "table",
  "slice_name": "Pivot Table (Metrics on COLUMNS)",
  "viz_type": "pivot_table_v2",
  "params": "{\"datasource\":{\"id\":17,\"type\":\"table\"},\"viz_type\":\"pivot_table_v2\",\"groupbyRows\":[],\"groupbyColumns\":[\"date\"],\"metrics\":[\"count\"],\"metricsLayout\":\"COLUMNS\",\"adhoc_filters\":[],\"row_limit\":10000,\"aggregateFunction\":\"Sum\"}"
}
```


### 3. **Bar Chart** - Grafico a Barre

**Endpoint:** `POST /api/v1/chart/`

**Parametri indispensabili:**
- `datasource_id`: ID numerico del dataset (**obbligatorio**)
- `datasource_type`: "table" (**obbligatorio**)
- `slice_name`: Nome del chart (**obbligatorio**)
- `viz_type`: "echarts_timeseries_bar" (**obbligatorio**)
- `params`: Stringa JSON con configurazione (**obbligatorio**)

**Parametri chiave in params:**
- `x_axis`: Colonna per asse X (es. "order_date")
- `metrics`: Metriche per asse Y (es. ["count"])
- `groupby`: Raggrupamenti per serie (es. ["deal_size"])
- `time_grain_sqla`: Granularità temporale - **Esempio**: "P1M" = per mese, "P1D" = per giorno, "P1Y" = per anno
- `orientation`: "vertical" o "horizontal"

**Esempio validato (FUNZIONANTE):**
```json
{
  "datasource_id": 9,
  "datasource_type": "table",
  "slice_name": "Bar Chart - Order Date vs Count by Deal Size",
  "viz_type": "echarts_timeseries_bar",
  "params": "{\"datasource\":{\"id\":9,\"type\":\"table\"},\"viz_type\":\"echarts_timeseries_bar\",\"x_axis\":\"order_date\",\"time_grain_sqla\":\"P1M\",\"x_axis_sort_asc\":true,\"x_axis_sort_series\":\"name\",\"x_axis_sort_series_ascending\":true,\"metrics\":[\"count\"],\"groupby\":[\"deal_size\"],\"adhoc_filters\":[{\"clause\":\"WHERE\",\"subject\":\"order_date\",\"operator\":\"TEMPORAL_RANGE\",\"comparator\":\"No filter\",\"expressionType\":\"SIMPLE\"}],\"order_desc\":true,\"row_limit\":10000,\"truncate_metric\":true,\"show_empty_columns\":true,\"comparison_type\":\"values\",\"annotation_layers\":[],\"forecastPeriods\":10,\"forecastInterval\":0.8,\"orientation\":\"vertical\",\"x_axis_title_margin\":15,\"y_axis_title_margin\":15,\"y_axis_title_position\":\"Left\",\"sort_series_type\":\"sum\",\"color_scheme\":\"supersetColors\",\"only_total\":true,\"show_legend\":true,\"legendType\":\"scroll\",\"legendOrientation\":\"top\",\"x_axis_time_format\":\"smart_date\",\"y_axis_format\":\"SMART_NUMBER\",\"truncateXAxis\":true,\"y_axis_bounds\":[null,null],\"rich_tooltip\":true,\"tooltipTimeFormat\":\"smart_date\",\"extra_form_data\":{},\"dashboards\":[]}"
}
```

> ⚠️ **IMPORTANTE per v6:**
> - Usare `viz_type`: "echarts_timeseries_bar" (non "dist_bar")
> - Il parametro principale è `x_axis` per l'asse X
> - Usare `groupby` per raggruppamenti/serie multiple
> - Il parametro `time_grain_sqla` controlla la granularità temporale
> - Il campo `params` deve essere una stringa JSON

---

### 4. **Pie Chart** - Grafico a Torta

**Endpoint:** `POST /api/v1/chart/`

**Parametri indispensabili:**
- `datasource_id`: ID numerico del dataset (**obbligatorio**)
- `datasource_type`: "table" (**obbligatorio**)
- `slice_name`: Nome del chart (**obbligatorio**)
- `viz_type`: "pie" (**obbligatorio**)
- `params`: Stringa JSON con configurazione (**obbligatorio**)

**Parametri chiave in params:**
- `groupby`: Colonne per categorie spicchi (es. ["date"])
- `metric`: Metrica singola per dimensioni (es. "count")
- `donut`: Stile ciambella (true/false)
- `show_labels`: Mostra etichette sui spicchi

**Esempio validato (FUNZIONANTE):**
```json
{
  "datasource_id": 17,
  "datasource_type": "table",
  "slice_name": "Pie Chart - Distribution by Date",
  "viz_type": "pie",
  "params": "{\"datasource\":{\"id\":17,\"type\":\"table\"},\"viz_type\":\"pie\",\"groupby\":[\"date\"],\"metric\":\"count\",\"adhoc_filters\":[],\"row_limit\":50,\"color_scheme\":\"bnbColors\",\"donut\":false,\"show_labels\":true,\"labels_outside\":false,\"outerRadius\":70,\"innerRadius\":30}"
}
```

> ⚠️ **IMPORTANTE per v6:**
> - Il parametro `metric` deve essere una stringa singola (non array)
> - Usare `groupby` per le categorie dei spicchi
> - Il campo `params` deve essere una stringa JSON

### 5. **Line Chart** - Grafico a Linee

**Endpoint:** `POST /api/v1/chart/`

**Parametri indispensabili:**
- `datasource_id`: ID numerico del dataset (**obbligatorio**)
- `datasource_type`: "table" (**obbligatorio**)
- `slice_name`: Nome del chart (**obbligatorio**)
- `viz_type`: "echarts_timeseries_line" (**obbligatorio**)
- `params`: Stringa JSON con configurazione (**obbligatorio**)

**Parametri chiave in params:**
- `granularity_sqla`: Colonna temporale per asse X (es. "date")
- `metrics`: Metriche per asse Y (es. ["count"])
- `groupby`: Raggrupamenti per serie multiple (es. [])
- `show_legend`: Mostra legenda
- `rich_tooltip`: Tooltip dettagliato

**Esempio validato (FUNZIONANTE):**
```json
{
  "datasource_id": 17,
  "datasource_type": "table",
  "slice_name": "Line Chart - Trend over Time",
  "viz_type": "echarts_timeseries_line",
  "params": "{\"datasource\":{\"id\":17,\"type\":\"table\"},\"viz_type\":\"echarts_timeseries_line\",\"granularity_sqla\":\"date\",\"metrics\":[\"count\"],\"groupby\":[],\"adhoc_filters\":[],\"row_limit\":1000,\"color_scheme\":\"bnbColors\",\"show_legend\":true,\"rich_tooltip\":true}"
}
```

> ⚠️ **IMPORTANTE per v6:**
> - Usare `viz_type`: "echarts_timeseries_line" 
> - Il parametro principale è `granularity_sqla` per l'asse temporale
> - Il campo `params` deve essere una stringa JSON

---

### 6. **Heat Map** - Mappa di Calore

**Endpoint:** `POST /api/v1/chart/`

**Parametri indispensabili:**
- `datasource_id`: ID numerico del dataset (**obbligatorio**)
- `datasource_type`: "table" (**obbligatorio**)
- `slice_name`: Nome del chart (**obbligatorio**)
- `viz_type`: "heatmap_v2" (**obbligatorio**)
- `params`: Stringa JSON con configurazione (**obbligatorio**)

**Parametri chiave in params:**
- `x_axis`: Colonna asse X (es. "product_line") (**obbligatorio**)
- `groupby`: Colonna asse Y (es. "deal_size") (**obbligatorio**)
- `metric`: Metrica per intensità colore (es. "count") (**obbligatorio**)

**Parametri opzionali (default disponibili):**
- `normalize_across`: Normalizzazione (default: "heatmap")
- `xscale_interval`: Intervallo scala X (default: -1)
- `yscale_interval`: Intervallo scala Y (default: -1)
- `legend_type`: Tipo legenda (default: "continuous")
- `linear_color_scheme`: Gradiente colori (default: "superset_seq_1")
- `left_margin`: Margine sinistro (default: "auto")
- `bottom_margin`: Margine inferiore (default: "auto")
- `value_bounds`: Limiti valori (default: [null, null])
- `y_axis_format`: Formato valori (default: "SMART_NUMBER")
- `x_axis_time_format`: Formato asse X temporale (default: "smart_date")
- `show_legend`: Mostra legenda (default: true)
- `show_percentage`: Mostra percentuali (default: true)
- `show_values`: Mostra valori (default: true)
- `row_limit`: Limite righe (default: 10000)

**Esempio validato (FUNZIONANTE):**
```json
{
  "datasource_id": 9,
  "datasource_type": "table",
  "slice_name": "Heat Map Example",
  "viz_type": "heatmap_v2",
  "params": "{\"datasource\":{\"id\":9,\"type\":\"table\"},\"viz_type\":\"heatmap_v2\",\"x_axis\":\"product_line\",\"time_grain_sqla\":\"P1D\",\"groupby\":\"deal_size\",\"metric\":\"count\",\"adhoc_filters\":[{\"clause\":\"WHERE\",\"subject\":\"order_date\",\"operator\":\"TEMPORAL_RANGE\",\"comparator\":\"No filter\",\"expressionType\":\"SIMPLE\"}],\"row_limit\":10000,\"sort_x_axis\":\"alpha_asc\",\"sort_y_axis\":\"alpha_asc\",\"normalize_across\":\"heatmap\",\"legend_type\":\"continuous\",\"linear_color_scheme\":\"superset_seq_1\",\"xscale_interval\":-1,\"yscale_interval\":-1,\"left_margin\":\"auto\",\"bottom_margin\":\"auto\",\"value_bounds\":[null,null],\"y_axis_format\":\"SMART_NUMBER\",\"x_axis_time_format\":\"smart_date\",\"show_legend\":true,\"show_percentage\":true,\"show_values\":true,\"extra_form_data\":{},\"dashboards\":[],\"annotation_layers\":[]}"
}
```

> ⚠️ **IMPORTANTE per v6:**
> - Usare `viz_type`: "heatmap_v2"
> - Il parametro `groupby` deve essere una stringa singola (non array)
> - Il campo `params` deve essere una stringa JSON

---

### 7. **Tree Chart** - Grafico ad Albero


**Endpoint:** `POST /api/v1/chart/`

**Parametri indispensabili:**
- `datasource_id`: ID numerico del dataset (**obbligatorio**)
- `datasource_type`: "table" (**obbligatorio**)
- `slice_name`: Nome del chart (**obbligatorio**)
- `viz_type`: "tree_chart" (**obbligatorio**)
- `params`: Stringa JSON con configurazione (**obbligatorio**)

**Parametri chiave in params:**
- `id`: Colonna ID dei nodi (es. "id") (**obbligatorio**)
- `parent`: Colonna ID del nodo padre (es. "parent") (**obbligatorio**)
- `name`: Colonna nome del nodo (es. "name") (**obbligatorio**)
- `root_node_id`: ID del nodo radice (es. "1") (**obbligatorio**)
- `metric`: Metrica per dimensione nodi (es. "count") (**obbligatorio**)

**Parametri opzionali (default disponibili):**
- `layout`: Tipo layout (default: "radial")
- `node_label_position`: Posizione etichetta nodo (default: "top")
- `child_label_position`: Posizione etichetta figli (default: "top")
- `symbol`: Simbolo nodi (default: "emptyCircle")
- `symbolSize`: Dimensione simboli (default: 7)
- `roam`: Navigazione interattiva (default: false)
- `row_limit`: Limite righe (default: 1000)

**Esempio validato (FUNZIONANTE):**
```json
{
  "datasource_id": 20,
  "datasource_type": "table",
  "slice_name": "Tree Chart Example",
  "viz_type": "tree_chart",
  "params": "{\"datasource\":{\"id\":20,\"type\":\"table\"},\"viz_type\":\"tree_chart\",\"id\":\"id\",\"parent\":\"parent\",\"name\":\"name\",\"root_node_id\":\"1\",\"metric\":\"count\",\"adhoc_filters\":[],\"row_limit\":1000,\"layout\":\"radial\",\"node_label_position\":\"top\",\"child_label_position\":\"top\",\"symbol\":\"emptyCircle\",\"symbolSize\":7,\"roam\":false,\"extra_form_data\":{},\"dashboards\":[],\"annotation_layers\":[]}"
}
```

> ⚠️ **IMPORTANTE per v6:**
> - Usare `viz_type`: "tree_chart" (non "treemap")
> - Richiede dataset con struttura gerarchica (id, parent, name)
> - Il campo `params` deve essere una stringa JSON

---

### 8. **Scatter Plot** - Grafico a Dispersione

> 🔄 **Mappatura UI → API Parameters (echarts_timeseries_scatter):**
> 
**Endpoint:** `POST /api/v1/chart/`

**Parametri indispensabili:**
- `datasource_id`: ID numerico del dataset (**obbligatorio**)
- `datasource_type`: "table" (**obbligatorio**)
- `slice_name`: Nome del chart (**obbligatorio**)
- `viz_type`: "echarts_timeseries_scatter" (**obbligatorio**)
- `params`: Stringa JSON con configurazione (**obbligatorio**)

**Parametri chiave in params:**
- `x_axis`: Colonna asse X (es. "order_date") (**obbligatorio**)
- `metrics`: Metriche per asse Y (es. ["count"]) (**obbligatorio**)
- `groupby`: Raggrupamenti per serie (es. ["deal_size"])

**Parametri opzionali (default disponibili):**
- `time_grain_sqla`: Granularità temporale (default: "P1D")
- `markerSize`: Dimensione marcatori (default: 6)
- `color_scheme`: Schema colori (default: "supersetColors")
- `show_legend`: Mostra legenda (default: true)
- `rich_tooltip`: Tooltip dettagliato (default: true)
- `row_limit`: Limite righe (default: 10000)

**Esempio validato (FUNZIONANTE):**
```json
{
  "datasource_id": 9,
  "datasource_type": "table",
  "slice_name": "Scatter Plot Example",
  "viz_type": "echarts_timeseries_scatter",
  "params": "{\"datasource\":{\"id\":9,\"type\":\"table\"},\"viz_type\":\"echarts_timeseries_scatter\",\"x_axis\":\"order_date\",\"time_grain_sqla\":\"P1D\",\"x_axis_sort_asc\":true,\"x_axis_sort_series\":\"name\",\"x_axis_sort_series_ascending\":true,\"metrics\":[\"count\"],\"groupby\":[\"deal_size\"],\"adhoc_filters\":[{\"clause\":\"WHERE\",\"subject\":\"order_date\",\"operator\":\"TEMPORAL_RANGE\",\"comparator\":\"No filter\",\"expressionType\":\"SIMPLE\"}],\"order_desc\":true,\"row_limit\":10000,\"truncate_metric\":true,\"show_empty_columns\":true,\"comparison_type\":\"values\",\"annotation_layers\":[],\"forecastPeriods\":10,\"forecastInterval\":0.8,\"x_axis_title_margin\":15,\"y_axis_title_margin\":15,\"y_axis_title_position\":\"Left\",\"sort_series_type\":\"sum\",\"color_scheme\":\"supersetColors\",\"only_total\":true,\"markerSize\":6,\"show_legend\":true,\"legendType\":\"scroll\",\"legendOrientation\":\"top\",\"x_axis_time_format\":\"smart_date\",\"rich_tooltip\":true,\"tooltipTimeFormat\":\"smart_date\",\"y_axis_format\":\"SMART_NUMBER\",\"truncateXAxis\":true,\"y_axis_bounds\":[null,null],\"extra_form_data\":{},\"dashboards\":[]}"
}
```

> ⚠️ **IMPORTANTE per v6:**
> - Usare `viz_type`: "echarts_timeseries_scatter" (non "bubble")
> - Simile al bar chart ma con marcatori scatter
> - Il campo `params` deve essere una stringa JSON

---

### 9. **Big Number** - Numero Grande

**Endpoint:** `POST /api/v1/chart/`

**Parametri indispensabili:**
- `datasource_id`: ID numerico del dataset (**obbligatorio**)
- `datasource_type`: "table" (**obbligatorio**)
- `slice_name`: Nome del chart (**obbligatorio**)
- `viz_type`: "big_number_total" (**obbligatorio**)
- `params`: Stringa JSON con configurazione (**obbligatorio**)

**Parametri chiave in params:**
- `metric`: Metrica principale da visualizzare (es. "count") (**obbligatorio**)

**Parametri opzionali (default disponibili):**
- `header_font_size`: Dimensione font titolo (default: 0.4)
- `subheader_font_size`: Dimensione font sottotitolo (default: 0.15)
- `y_axis_format`: Formato del numero (default: "SMART_NUMBER")
- `time_format`: Formato tempo (default: "smart_date")
- `adhoc_filters`: Filtri aggiuntivi (default: [])

**Esempio validato (FUNZIONANTE):**
```json
{
  "datasource_id": 9,
  "datasource_type": "table",
  "slice_name": "Big Number Example",
  "viz_type": "big_number_total",
  "params": "{\"datasource\":{\"id\":9,\"type\":\"table\"},\"viz_type\":\"big_number_total\",\"metric\":\"count\",\"adhoc_filters\":[{\"clause\":\"WHERE\",\"subject\":\"order_date\",\"operator\":\"TEMPORAL_RANGE\",\"comparator\":\"No filter\",\"expressionType\":\"SIMPLE\"}],\"header_font_size\":0.4,\"subheader_font_size\":0.15,\"y_axis_format\":\"SMART_NUMBER\",\"time_format\":\"smart_date\",\"extra_form_data\":{},\"dashboards\":[],\"annotation_layers\":[]}"
}
```

> ⚠️ **IMPORTANTE per v6:**
> - Usare `viz_type`: "big_number_total"
> - Visualizza un singolo valore numerico grande
> - Il campo `params` deve essere una stringa JSON

**API d'esempio (big_number_total):**
```json
{
  "slice_name": "Big Number Example",
  "viz_type": "big_number_total",
  "datasource_id": 1,
  "datasource_type": "table",
  "params": {
    "datasource": "1__table",
    "viz_type": "big_number_total",
    "metric": "count",
    "groupby": "Provincia",
    "time_grain_sqla": "P1D",
    "adhoc_filters": [],
    "row_limit": 10000,
    "y_axis_format": "SMART_NUMBER",
    "show_legend": true,
    "extra_form_data": {},
    "dashboards": []
  },
  "query_context": null
}
```

---

### 10. **Gauge Chart** - Grafico a Indicatore

**Endpoint:** `POST /api/v1/chart/`

**Parametri indispensabili:**
- `datasource_id`: ID numerico del dataset (**obbligatorio**)
- `datasource_type`: "table" (**obbligatorio**)
- `slice_name`: Nome del chart (**obbligatorio**)
- `viz_type`: "gauge_chart" (**obbligatorio**)
- `params`: Stringa JSON con configurazione (**obbligatorio**)

**Parametri chiave in params:**
- `groupby`: Colonne per raggruppamento (es. ["deal_size"]) (**obbligatorio**)
- `metric`: Metrica da visualizzare (es. "count") (**obbligatorio**)

**Parametri opzionali (default disponibili):**
- `start_angle`: Angolo di inizio (default: 225)
- `end_angle`: Angolo di fine (default: -45)
- `color_scheme`: Schema colori (default: "supersetColors")
- `font_size`: Dimensione font (default: 13)
- `number_format`: Formato numerico (default: "SMART_NUMBER")
- `show_pointer`: Mostra puntatore (default: true)
- `animation`: Abilita animazioni (default: true)
- `show_progress`: Mostra progresso (default: true)
- `row_limit`: Limite righe (default: 10)

**Esempio validato (FUNZIONANTE):**
```json
{
  "datasource_id": 9,
  "datasource_type": "table",
  "slice_name": "Gauge Chart Example",
  "viz_type": "gauge_chart",
  "params": "{\"datasource\":{\"id\":9,\"type\":\"table\"},\"viz_type\":\"gauge_chart\",\"groupby\":[\"deal_size\"],\"metric\":\"count\",\"adhoc_filters\":[{\"clause\":\"WHERE\",\"subject\":\"order_date\",\"operator\":\"TEMPORAL_RANGE\",\"comparator\":\"No filter\",\"expressionType\":\"SIMPLE\"}],\"start_angle\":225,\"end_angle\":-45,\"color_scheme\":\"supersetColors\",\"font_size\":13,\"number_format\":\"SMART_NUMBER\",\"value_formatter\":\"{value}%\",\"show_pointer\":true,\"animation\":true,\"show_axis_label\":true,\"show_progress\":true,\"overlap\":true,\"round_cap\":false,\"row_limit\":10}"
}
```

> ⚠️ **IMPORTANTE per v6:**
> - Usare `viz_type`: "gauge_chart"
> - Visualizza dati come indicatore circolare tipo tachimetro
> - Il campo `params` deve essere una stringa JSON

---

### 11. **Area Chart** - Grafico ad Area

**Endpoint:** `POST /api/v1/chart/`

**Parametri indispensabili:**
- `datasource_id`: ID numerico del dataset (**obbligatorio**)
- `datasource_type`: "table" (**obbligatorio**)
- `slice_name`: Nome del chart (**obbligatorio**)
- `viz_type`: "echarts_area" (**obbligatorio**)
- `params`: Stringa JSON con configurazione (**obbligatorio**)

**Parametri chiave in params:**
- `x_axis`: Colonna per asse X (es. "order_date") (**obbligatorio**)
- `metrics`: Metriche da visualizzare (es. ["count"]) (**obbligatorio**)
- `groupby`: Colonne per raggruppamento (es. ["deal_size"])

**Parametri opzionali (default disponibili):**
- `time_grain_sqla`: Granularità temporale (default: "P1W")
- `opacity`: Trasparenza area (default: 0.2)
- `only_total`: Solo totale (default: true)
- `show_legend`: Mostra leggenda (default: true)
- `color_scheme`: Schema colori (default: "supersetColors")
- `y_axis_format`: Formato asse Y (default: "SMART_NUMBER")
- `row_limit`: Limite righe (default: 10000)

**Esempio validato (FUNZIONANTE):**
```json
{
  "datasource_id": 9,
  "datasource_type": "table",
  "slice_name": "Area Chart Example",
  "viz_type": "echarts_area",
  "params": "{\"datasource\":{\"id\":9,\"type\":\"table\"},\"viz_type\":\"echarts_area\",\"x_axis\":\"order_date\",\"time_grain_sqla\":\"P1W\",\"x_axis_sort_asc\":true,\"x_axis_sort_series\":\"name\",\"x_axis_sort_series_ascending\":true,\"metrics\":[\"count\"],\"groupby\":[\"deal_size\"],\"adhoc_filters\":[{\"clause\":\"WHERE\",\"subject\":\"order_date\",\"operator\":\"TEMPORAL_RANGE\",\"comparator\":\"No filter\",\"expressionType\":\"SIMPLE\"}],\"order_desc\":true,\"row_limit\":10000,\"truncate_metric\":true,\"show_empty_columns\":true,\"comparison_type\":\"values\",\"annotation_layers\":[],\"forecastPeriods\":10,\"forecastInterval\":0.8,\"x_axis_title_margin\":15,\"y_axis_title_margin\":15,\"y_axis_title_position\":\"Left\",\"sort_series_type\":\"sum\",\"color_scheme\":\"supersetColors\",\"seriesType\":\"echarts_timeseries_line\",\"opacity\":0.2,\"only_total\":true,\"markerSize\":6,\"show_legend\":true,\"legendType\":\"scroll\",\"legendOrientation\":\"top\",\"x_axis_time_format\":\"smart_date\",\"rich_tooltip\":true,\"tooltipTimeFormat\":\"smart_date\",\"y_axis_format\":\"SMART_NUMBER\",\"truncateXAxis\":true,\"y_axis_bounds\":[null,null],\"extra_form_data\":{},\"dashboards\":[]}"
}
```

> ⚠️ **IMPORTANTE per v6:**
> - Usare `viz_type`: "echarts_area"
> - Simile al line chart ma con area riempita
> - Il campo `params` deve essere una stringa JSON

---

### 12. **Waterfall Chart** - Grafico a Cascata

**Endpoint:** `POST /api/v1/chart/`

**Parametri indispensabili:**
- `datasource_id`: ID numerico del dataset (**obbligatorio**)
- `datasource_type`: "table" (**obbligatorio**)
- `slice_name`: Nome del chart (**obbligatorio**)
- `viz_type`: "waterfall" (**obbligatorio**)
- `params`: Stringa JSON con configurazione (**obbligatorio**)

**Parametri chiave in params:**
- `x_axis`: Colonna per asse X (es. "order_date") (**obbligatorio**)
- `metric`: Metrica da visualizzare (es. "count") (**obbligatorio**)

**Parametri opzionali (default disponibili):**
- `time_grain_sqla`: Granularità temporale (default: "P3M")
- `show_value`: Mostra valori (default: true)
- `increase_color`: Colore incrementi (default: verde)
- `decrease_color`: Colore decrementi (default: rosso)
- `total_color`: Colore totali (default: grigio)
- `x_axis_time_format`: Formato asse X (default: "smart_date")
- `y_axis_format`: Formato asse Y (default: "SMART_NUMBER")
- `row_limit`: Limite righe (default: 10000)

**Esempio validato (FUNZIONANTE):**
```json
{
  "datasource_id": 9,
  "datasource_type": "table",
  "slice_name": "Waterfall Chart Example",
  "viz_type": "waterfall",
  "params": "{\"datasource\":{\"id\":9,\"type\":\"table\"},\"viz_type\":\"waterfall\",\"x_axis\":\"order_date\",\"time_grain_sqla\":\"P3M\",\"groupby\":[],\"metric\":\"count\",\"adhoc_filters\":[{\"clause\":\"WHERE\",\"subject\":\"order_date\",\"operator\":\"TEMPORAL_RANGE\",\"comparator\":\"No filter\",\"expressionType\":\"SIMPLE\"}],\"row_limit\":10000,\"show_value\":true,\"increase_color\":{\"r\":90,\"g\":193,\"b\":137,\"a\":1},\"decrease_color\":{\"r\":224,\"g\":67,\"b\":85,\"a\":1},\"total_color\":{\"r\":102,\"g\":102,\"b\":102,\"a\":1},\"x_axis_time_format\":\"smart_date\",\"x_ticks_layout\":\"auto\",\"y_axis_format\":\"SMART_NUMBER\",\"extra_form_data\":{},\"dashboards\":[],\"annotation_layers\":[]}"
}
```

> ⚠️ **IMPORTANTE per v6:**
> - Usare `viz_type`: "waterfall"
> - Mostra variazioni cumulative nel tempo
> - Il campo `params` deve essere una stringa JSON

---

### 13. **Histogram** - Istogramma

**Endpoint:** `POST /api/v1/chart/`

**Parametri indispensabili:**
- `datasource_id`: ID numerico del dataset (**obbligatorio**)
- `datasource_type`: "table" (**obbligatorio**)
- `slice_name`: Nome del chart (**obbligatorio**)
- `viz_type`: "histogram_v2" (**obbligatorio**)
- `params`: Stringa JSON con configurazione (**obbligatorio**)

**Parametri chiave in params:**
- `column`: Colonna per distribuzione valori (es. "quantity_ordered") (**obbligatorio**)
- `groupby`: Colonne per raggruppamento (es. ["deal_size"])
- `bins`: Numero di intervalli (default: 10)

**Parametri opzionali (default disponibili):**
- `normalize`: Normalizza i valori (default: false)
- `color_scheme`: Schema colori (default: "supersetColors")
- `show_value`: Mostra valori sui bin (default: false)
- `show_legend`: Mostra legenda (default: true)
- `row_limit`: Limite righe (default: 10000)

**Esempio validato (FUNZIONANTE):**
```json
{
  "datasource_id": 9,
  "datasource_type": "table",
  "slice_name": "Histogram Example",
  "viz_type": "histogram_v2",
  "params": "{\"datasource\":{\"id\":9,\"type\":\"table\"},\"viz_type\":\"histogram_v2\",\"column\":\"quantity_ordered\",\"groupby\":[\"deal_size\"],\"adhoc_filters\":[{\"clause\":\"WHERE\",\"subject\":\"order_date\",\"operator\":\"TEMPORAL_RANGE\",\"comparator\":\"No filter\",\"expressionType\":\"SIMPLE\"}],\"row_limit\":10000,\"bins\":10,\"normalize\":false,\"color_scheme\":\"supersetColors\",\"show_value\":false,\"show_legend\":true,\"extra_form_data\":{},\"dashboards\":[],\"annotation_layers\":[]}"
}
```

> ⚠️ **IMPORTANTE per v6:**
> - Usare `viz_type`: "histogram_v2"
> - Visualizza la distribuzione di frequenza dei valori
> - Il campo `params` deve essere una stringa JSON

---

### 14. **Funnel Chart** - Grafico a Imbuto

**Endpoint:** `POST /api/v1/chart/`

**Parametri indispensabili:**
- `datasource_id`: ID numerico del dataset (**obbligatorio**)
- `datasource_type`: "table" (**obbligatorio**)
- `slice_name`: Nome del chart (**obbligatorio**)
- `viz_type`: "funnel" (**obbligatorio**)
- `params`: Stringa JSON con configurazione (**obbligatorio**)

**Parametri chiave in params:**
- `groupby`: Colonne per categorie funnel (es. ["deal_size"]) (**obbligatorio**)
- `metric`: Metrica da visualizzare (es. "count") (**obbligatorio**)
- `sort_by_metric`: Ordina per metrica (default: true)

**Parametri opzionali (default disponibili):**
- `percent_calculation_type`: Tipo calcolo percentuale (default: "first_step")
- `color_scheme`: Schema colori (default: "supersetColors")
- `show_legend`: Mostra legenda (default: true)
- `legendOrientation`: Orientamento legenda (default: "top")
- `legendMargin`: Margine legenda (default: 50)
- `number_format`: Formato numeri (default: "SMART_NUMBER")
- `show_labels`: Mostra etichette (default: true)
- `show_tooltip_labels`: Mostra tooltip (default: true)
- `row_limit`: Limite righe (default: 10)

**Esempio validato (FUNZIONANTE):**
```json
{
  "datasource_id": 9,
  "datasource_type": "table",
  "slice_name": "Funnel Chart Example",
  "viz_type": "funnel",
  "params": "{\"datasource\":{\"id\":9,\"type\":\"table\"},\"viz_type\":\"funnel\",\"groupby\":[\"deal_size\"],\"metric\":\"count\",\"adhoc_filters\":[{\"clause\":\"WHERE\",\"subject\":\"order_date\",\"operator\":\"TEMPORAL_RANGE\",\"comparator\":\"No filter\",\"expressionType\":\"SIMPLE\"}],\"row_limit\":10,\"sort_by_metric\":true,\"percent_calculation_type\":\"first_step\",\"color_scheme\":\"supersetColors\",\"show_legend\":true,\"legendOrientation\":\"top\",\"legendMargin\":50,\"tooltip_label_type\":5,\"number_format\":\"SMART_NUMBER\",\"show_labels\":true,\"show_tooltip_labels\":true,\"extra_form_data\":{},\"dashboards\":[],\"annotation_layers\":[]}"
}
```

> ⚠️ **IMPORTANTE per v6:**
> - Usare `viz_type`: "funnel"
> - Visualizza un processo di conversione attraverso fasi successive
> - Il campo `params` deve essere una stringa JSON

---

### 15. **Bullet Chart** - Grafico a Proiettile

**Endpoint:** `POST /api/v1/chart/`

**Parametri indispensabili:**
- `datasource_id`: ID numerico del dataset (**obbligatorio**)
- `datasource_type`: "table" (**obbligatorio**)
- `slice_name`: Nome del chart (**obbligatorio**)
- `viz_type`: "bullet" (**obbligatorio**)
- `params`: Stringa JSON con configurazione (**obbligatorio**)

**Parametri chiave in params:**
- `metric`: Metrica principale da visualizzare (es. "count") (**obbligatorio**)
- `ranges`: Valori target/obiettivo (es. "3000") (**obbligatorio**)
- `markers`: Valori correnti/attuali (es. "2000") (**obbligatorio**)

**Parametri opzionali (default disponibili):**
- `range_labels`: Etichette per i range (default: "Target Range")
- `marker_labels`: Etichette per i marker (default: "Current Value")
- `marker_lines`: Linee di riferimento aggiuntive (default: "")
- `marker_line_labels`: Etichette linee di riferimento (default: "")

**Esempio validato (FUNZIONANTE):**
```json
{
  "datasource_id": 9,
  "datasource_type": "table",
  "slice_name": "Bullet Chart Example",
  "viz_type": "bullet",
  "params": "{\"datasource\":{\"id\":9,\"type\":\"table\"},\"viz_type\":\"bullet\",\"metric\":\"count\",\"adhoc_filters\":[{\"clause\":\"WHERE\",\"subject\":\"order_date\",\"operator\":\"TEMPORAL_RANGE\",\"comparator\":\"No filter\",\"expressionType\":\"SIMPLE\"}],\"ranges\":\"3000\",\"range_labels\":\"Target Range\",\"markers\":\"2000\",\"marker_labels\":\"Current Value\",\"marker_lines\":\"\",\"marker_line_labels\":\"\",\"extra_form_data\":{},\"dashboards\":[]}"
}
```

> ⚠️ **IMPORTANTE per v6:**
> - Usare `viz_type`: "bullet"
> - Confronta valori attuali con obiettivi/target
> - Il campo `params` deve essere una stringa JSON

---

### 16. **Mixed Chart** - Grafico Combinato

**Endpoint:** `POST /api/v1/chart/`

**Parametri indispensabili:**
- `datasource_id`: ID numerico del dataset (**obbligatorio**)
- `datasource_type`: "table" (**obbligatorio**)
- `slice_name`: Nome del chart (**obbligatorio**)
- `viz_type`: "mixed_timeseries" (**obbligatorio**)
- `params`: Stringa JSON con configurazione (**obbligatorio**)

**Parametri chiave in params:**
- `x_axis`: Colonna per asse X (es. "order_date") (**obbligatorio**)
- `metrics`: Metriche serie A (es. ["count"]) (**obbligatorio**)
- `metrics_b`: Metriche serie B (es. ["count"]) (**obbligatorio**)
- `time_grain_sqla`: Granularità temporale (es. "P1M")

**Parametri opzionali (default disponibili):**
- `seriesType`: Tipo grafico serie A (default: "bar")
- `seriesTypeB`: Tipo grafico serie B (default: null)
- `yAxisIndex`: Indice asse Y serie A (default: 1)
- `yAxisIndexB`: Indice asse Y serie B (default: 0)
- `opacity`: Trasparenza serie A (default: 0.2)
- `opacityB`: Trasparenza serie B (default: 0.2)
- `markerSize`: Dimensione marker serie A (default: 6)
- `markerSizeB`: Dimensione marker serie B (default: 6)
- `color_scheme`: Schema colori (default: "supersetColors")
- `show_legend`: Mostra legenda (default: true)
- `row_limit`: Limite righe (default: 10000)

**Esempio validato (FUNZIONANTE):**
```json
{
  "datasource_id": 9,
  "datasource_type": "table",
  "slice_name": "Mixed Chart Example",
  "viz_type": "mixed_timeseries",
  "params": "{\"datasource\":{\"id\":9,\"type\":\"table\"},\"viz_type\":\"mixed_timeseries\",\"x_axis\":\"order_date\",\"time_grain_sqla\":\"P1M\",\"metrics\":[\"count\"],\"groupby\":[],\"adhoc_filters\":[{\"clause\":\"WHERE\",\"subject\":\"order_date\",\"operator\":\"TEMPORAL_RANGE\",\"comparator\":\"No filter\",\"expressionType\":\"SIMPLE\"}],\"order_desc\":true,\"row_limit\":10000,\"truncate_metric\":true,\"comparison_type\":\"values\",\"metrics_b\":[\"count\"],\"groupby_b\":[],\"adhoc_filters_b\":[{\"clause\":\"WHERE\",\"subject\":\"order_date\",\"operator\":\"TEMPORAL_RANGE\",\"comparator\":\"No filter\",\"expressionType\":\"SIMPLE\"}],\"order_desc_b\":true,\"row_limit_b\":10000,\"truncate_metric_b\":true,\"comparison_type_b\":\"values\",\"annotation_layers\":[],\"x_axis_title_margin\":15,\"y_axis_title_margin\":15,\"y_axis_title_position\":\"Left\",\"color_scheme\":\"supersetColors\",\"seriesType\":\"bar\",\"opacity\":0.2,\"markerSize\":6,\"yAxisIndex\":1,\"sort_series_type\":\"sum\",\"seriesTypeB\":null,\"opacityB\":0.2,\"markerSizeB\":6,\"yAxisIndexB\":0,\"sort_series_typeB\":\"sum\",\"show_legend\":true,\"legendType\":\"scroll\",\"legendOrientation\":\"top\",\"x_axis_time_format\":\"smart_date\",\"rich_tooltip\":true,\"tooltipTimeFormat\":\"smart_date\",\"truncateXAxis\":true,\"y_axis_bounds\":[null,null],\"y_axis_format\":\"SMART_NUMBER\",\"y_axis_bounds_secondary\":[null,null],\"y_axis_format_secondary\":\"SMART_NUMBER\",\"extra_form_data\":{},\"dashboards\":[]}"
}
```

> ⚠️ **IMPORTANTE per v6:**
> - Usare `viz_type`: "mixed_timeseries"
> - Combina diversi tipi di grafico in uno stesso chart
> - Il campo `params` deve essere una stringa JSON

---

### 17. **Country Map** - Mappa Paesi

**Endpoint:** `POST /api/v1/chart/`

**Parametri indispensabili:**
- `datasource_id`: ID numerico del dataset (**obbligatorio**)
- `datasource_type`: "table" (**obbligatorio**)
- `slice_name`: Nome del chart (**obbligatorio**)
- `viz_type`: "country_map" (**obbligatorio**)
- `params`: Stringa JSON con configurazione (**obbligatorio**)

**Parametri chiave in params:**
- `entity`: Colonna con identificatori geografici (es. "deal_size") (**obbligatorio**)
- `metric`: Metrica da visualizzare (es. "count") (**obbligatorio**)
- `select_country`: Paese da visualizzare (es. "usa") (**obbligatorio**)

**Parametri opzionali (default disponibili):**
- `row_limit`: Limite righe (default: 50000)

**Esempio validato (FUNZIONANTE):**
```json
{
  "datasource_id": 9,
  "datasource_type": "table",
  "slice_name": "Country Map Example",
  "viz_type": "country_map",
  "params": "{\"datasource\":{\"id\":9,\"type\":\"table\"},\"viz_type\":\"country_map\",\"entity\":\"deal_size\",\"metric\":\"count\",\"select_country\":\"usa\",\"row_limit\":50000,\"adhoc_filters\":[{\"clause\":\"WHERE\",\"subject\":\"order_date\",\"operator\":\"TEMPORAL_RANGE\",\"comparator\":\"No filter\",\"expressionType\":\"SIMPLE\"}],\"extra_form_data\":{},\"dashboards\":[],\"annotation_layers\":[]}"
}
```

> ⚠️ **IMPORTANTE per v6:**
> - Usare `viz_type`: "country_map"
> - Visualizza dati geografici su mappa del paese selezionato
> - Il campo `params` deve essere una stringa JSON

---

### 18. **Deck.gl Scatterplot** - Mappa Scatter

**Endpoint:** `POST /api/v1/chart/`

**Parametri indispensabili:**
- `datasource_id`: ID numerico del dataset (**obbligatorio**)
- `datasource_type`: "table" (**obbligatorio**)
- `slice_name`: Nome del chart (**obbligatorio**)
- `viz_type`: "deck_scatter" (**obbligatorio**)
- `params`: Stringa JSON con configurazione (**obbligatorio**)

**Parametri chiave in params:**
- `spatial`: Configurazione coordinate (es. {"latCol":"latitude","lonCol":"longitude","type":"latlong"}) (**obbligatorio**)
- `size`: Metrica per dimensione punti (es. "count") (**obbligatorio**)
- `viewport`: Configurazione vista mappa (**obbligatorio**)

**Parametri opzionali (default disponibili):**
- `color_picker`: Colore punti (default: {"r":205,"g":0,"b":3,"a":0.82})
- `mapbox_style`: Stile mappa (default: OpenStreetMap)
- `point_unit`: Unità punti (default: "square_m")
- `min_radius`: Raggio minimo (default: 1)
- `max_radius`: Raggio massimo (default: 250)
- `multiplier`: Moltiplicatore dimensione (default: 10)
- `row_limit`: Limite righe (default: 5000)

**Esempio validato (FUNZIONANTE):**
```json
{
  "datasource_id": 9,
  "datasource_type": "table",
  "slice_name": "Deck.gl Scatterplot Example",
  "viz_type": "deck_scatter",
  "params": "{\"datasource\":{\"id\":9,\"type\":\"table\"},\"viz_type\":\"deck_scatter\",\"spatial\":{\"latCol\":\"latitude\",\"lonCol\":\"longitude\",\"type\":\"latlong\"},\"size\":\"count\",\"point_radius_fixed\":{\"type\":\"metric\",\"value\":\"count\"},\"color_picker\":{\"r\":205,\"g\":0,\"b\":3,\"a\":0.82},\"mapbox_style\":\"https://tile.openstreetmap.org/{z}/{x}/{y}.png\",\"viewport\":{\"latitude\":37.7893,\"longitude\":-122.4261,\"zoom\":12.7,\"bearing\":0,\"pitch\":0},\"point_unit\":\"square_m\",\"min_radius\":1,\"max_radius\":250,\"multiplier\":10,\"row_limit\":5000,\"adhoc_filters\":[{\"clause\":\"WHERE\",\"subject\":\"order_date\",\"operator\":\"TEMPORAL_RANGE\",\"comparator\":\"No filter\",\"expressionType\":\"SIMPLE\"}],\"extra_form_data\":{},\"dashboards\":[],\"annotation_layers\":[]}"
}
```

> ⚠️ **IMPORTANTE per v6:**
> - Usare `viz_type`: "deck_scatter"
> - Visualizza punti su mappa interattiva con coordinate geografiche
> - Richiede colonne con latitudine e longitudine nel dataset
> - Il campo `params` deve essere una stringa JSON



## 📊 Creazione Dashboard con Filtri tramite API

### Panoramica e Parametri Obbligatori

Questa sezione descrive il workflow e i parametri necessari per creare una dashboard in Superset tramite chiamate API REST, includendo uno o più grafici già esistenti e la configurazione di filtri nativi (native filters).

**Parametri obbligatori:**
- **dashboard_title**: Titolo della dashboard da creare.
- **chart_ids**: Lista degli ID dei grafici (charts) già esistenti da includere nella dashboard.
- **native_filters**: Lista di oggetti che definiscono i filtri nativi da applicare alla dashboard (vedi esempio sotto).

---

### Workflow delle chiamate API per la creazione di dashboard

A differenza della creazione di una chart, la creazione di una dashboard in Superset tramite API **richiede un workflow composto da più chiamate** e la compilazione obbligatoria di alcuni parametri fondamentali. Non è sufficiente una semplice chiamata POST con solo il titolo: per ottenere una dashboard realmente utilizzabile e visualizzare correttamente i grafici, è necessario:

- Specificare **position_json**: struttura che definisce il layout e la posizione dei grafici nella dashboard.
- Specificare **json_metadata**: configurazione avanzata, inclusi i filtri nativi (`native_filter_configuration`).
- Associare esplicitamente i grafici tramite i loro ID.

**Esempio di sequenza chiamate:**

1. **POST** `/security/login` → ottieni token
2. **POST** `/dashboard/`  
   - Parametri: `dashboard_title`, `json_metadata` (con filtri), `position_json` (con chart_ids)
3. **PUT** `/dashboard/{dashboard_id}` (opzionale, per aggiornare posizione grafici)
4. **PUT** `/chart/{chart_id}` (opzionale, per ogni chart, per aggiornare campo dashboards)
5. **GET** `/dashboard/{dashboard_id}` (verifica)

---

### Note tecniche importanti

**⚠️ Struttura position_json obbligatoria**  
Durante la sperimentazione è emerso che senza una corretta configurazione del campo `position_json`, **i grafici non risultano visibili** nella dashboard anche se correttamente associati tramite ID. Una dashboard "vuota" o creata solo con il titolo non è funzionante: la struttura deve contenere obbligatoriamente un blocco ROOT, un blocco GRID, uno o più ROW e i blocchi CHART con i relativi ID e metadati minimi. La struttura `position_json` deve includere tutti i grafici che si desidera visualizzare nella dashboard.
Se non si compila correttamente `position_json` (vedi esempio sotto), i grafici **non saranno visibili** nella dashboard, anche se associati. 

**Altre considerazioni:**
- I **filtri nativi** (`native_filters`) devono essere configurati in base alle colonne e ai dataset effettivamente disponibili
- Gli **ID dei grafici** (`chart_ids`) devono riferirsi a grafici già esistenti, creati tramite API o interfaccia grafica  
- Le chiamate `PUT` per aggiornare posizione e associazione sono **opzionali ma fortemente consigliate** per garantire integrità e visualizzazione corretta

---

## Creazione della Dashboard (Step-by-Step)

### 1. Creazione della dashboard

Effettuare una chiamata `POST` a `/api/v1/dashboard/` per creare la dashboard e associare i grafici e i filtri.

**Body obbligatorio:**
```json
{
  "dashboard_title": "Nome della dashboard",
  "json_metadata": "{...}",
  "published": false,
  "position_json": "{...}"
}
```
- **dashboard_title**: stringa, titolo della dashboard.
- **json_metadata**: stringa JSON che include la configurazione dei filtri nativi (`native_filter_configuration`) e altre opzioni (es: `cross_filters_enabled`, `refresh_frequency`).
- **position_json**: stringa JSON che definisce la struttura della dashboard e la posizione dei grafici (ogni chart deve essere referenziato tramite il suo ID).

---

### 2. Esempi pratici di parametri obbligatori

**1. Esempio di json_metadata (struttura organizzata):**
```json
{
  // === CONFIGURAZIONE FILTRI NATIVI ===
  "native_filter_configuration": [
    // Filtro 1: Tipologia Infrastruttura (applicato a tutti i chart)
    {
      "id": "NATIVE_FILTER-0PMZ2rcO9QpIgYzoz5DQP",
      "name": "Tipologia Infrastruttura",
      "filterType": "filter_select",
      "targets": [
        {
          "column": {"name": "Tipologia di infrastruttura"}, 
          "datasetId": 1
        }
      ],
      "controlValues": {
        "multiSelect": true,           // Consente selezione multipla
        "enableEmptyFilter": false,    // Non consente filtro vuoto
        "defaultToFirstItem": false,   // Non seleziona automaticamente il primo elemento
        "searchAllOptions": false,     // Disabilita ricerca nelle opzioni
        "inverseSelection": false      // Disabilita selezione inversa
      },
      "scope": {
        "rootPath": ["ROOT_ID"], 
        "excluded": []
      },
      "type": "NATIVE_FILTER",
      "chartsInScope": [718, 721, 714, 715],  // Tutti i chart della dashboard
      "tabsInScope": []
    },
    
    // Filtro 2: Provincie (applicato solo al chart 718)
    {
      "id": "NATIVE_FILTER-J_MsNmVvtPHmBMjEA-CVm",
      "name": "Provincie",
      "filterType": "filter_select",
      "targets": [
        {
          "column": {"name": "Provincia"}, 
          "datasetId": 1
        }
      ],
      "controlValues": {
        "multiSelect": true,
        "enableEmptyFilter": false,
        "defaultToFirstItem": false,
        "searchAllOptions": false,
        "inverseSelection": false
      },
      "scope": {
        "rootPath": ["ROOT_ID"], 
        "excluded": []
      },
      "type": "NATIVE_FILTER",
      "chartsInScope": [718],  // Solo il chart 718 (Tabella Costi)
      "tabsInScope": []
    },
    
    // Filtro 3: Zona di fornitura (applicato a tutti i chart)
    {
      "id": "NATIVE_FILTER-IhXqLjq_FDkIzTPIHfacu",
      "name": "ZdF",
      "filterType": "filter_select",
      "targets": [
        {
          "column": {"name": "Zona di fornitura"}, 
          "datasetId": 1
        }
      ],
      "controlValues": {
        "multiSelect": true,
        "enableEmptyFilter": false,
        "defaultToFirstItem": false,
        "searchAllOptions": false,
        "inverseSelection": false
      },
      "scope": {
        "rootPath": ["ROOT_ID"], 
        "excluded": []
      },
      "type": "NATIVE_FILTER",
      "chartsInScope": [718, 721, 714, 715],  // Tutti i chart della dashboard
      "tabsInScope": []
    },
    
    // Filtro 4: Rating R3 (applicato a tutti i chart)
    {
      "id": "NATIVE_FILTER-TAyYFAEJ7HgyGPjNLdlWb",
      "name": "R3",
      "filterType": "filter_select",
      "targets": [
        {
          "column": {"name": "Rating R3 (classe)"}, 
          "datasetId": 1
        }
      ],
      "controlValues": {
        "multiSelect": true,
        "enableEmptyFilter": false,
        "defaultToFirstItem": false,
        "searchAllOptions": false,
        "inverseSelection": false
      },
      "scope": {
        "rootPath": ["ROOT_ID"], 
        "excluded": []
      },
      "type": "NATIVE_FILTER",
      "chartsInScope": [718, 721, 714, 715],  // Tutti i chart della dashboard
      "tabsInScope": []
    }
  ],
  
  // === CONFIGURAZIONE CROSS FILTERS ===
  "cross_filters_enabled": true,        // Abilita filtri incrociati tra chart
  "expanded_slices": {},                 // Chart espansi di default (vuoto = nessuno)
  "refresh_frequency": 0,                // Frequenza auto-refresh in secondi (0 = disabilitato)
  
  // === CONFIGURAZIONE CHART SPECIFICI ===
  "chart_configuration": {
    // Chart 714: Distribuzione Investimenti
    "714": {
      "id": 714,
      "crossFilters": {
        "scope": "global",                           // Scope globale dei cross-filter
        "chartsInScope": [715, 718, 721]            // Chart interessati dai cross-filter di questo chart
      }
    },
    
    // Chart 718: Tabella Costi  
    "718": {
      "id": 718,
      "crossFilters": {
        "scope": "global",
        "chartsInScope": [714, 715, 721]            // Chart interessati dai cross-filter di questo chart
      }
    },
    
    // Chart 721: Pivot Table
    "721": {
      "id": 721,
      "crossFilters": {
        "scope": "global",
        "chartsInScope": [714, 715, 718]            // Chart interessati dai cross-filter di questo chart
      }
    }
  },
  
  // === CONFIGURAZIONE GLOBALE CROSS FILTERS ===
  "global_chart_configuration": {
    "scope": {
      "rootPath": ["ROOT_ID"],           // Path radice per scope globale
      "excluded": []                     // Chart esclusi dai cross-filter globali
    },
    "chartsInScope": [714, 715, 718, 721]  // Tutti i chart inclusi nei cross-filter globali
  }
}
```
> 💡 **Note sui Native Filter ID:**
> - Per una nuova dashboard, **genera un ID univoco** con il pattern `NATIVE_FILTER-{NomeDescrittivo}`



**2. Esempio di position_json:**

> 📋 **Spiegazione della Struttura position_json**
>
> Il `position_json` definisce la struttura gerarchica della dashboard e la posizione di ogni elemento. La struttura è ad albero e segue questo pattern:
>
> **🏗️ Componenti Base:**
> - **ROOT_ID**: Elemento radice che contiene tutto il layout della dashboard
> - **GRID_ID**: Container principale che organizza il contenuto in griglia
> - **ROW-{n}**: Righe che contengono i singoli grafici (layout verticale)
> - **CHART-{n}**: Singoli grafici con i loro metadati e posizionamento
>
> **📊 Questo Esempio Contiene 4 Grafici:**
> 1. **CHART-1** (ID: 718): "Tabella Costi" - Tabella con dati grezzi
> 2. **CHART-2** (ID: 721): "Pivot Table" - Tabella pivot aggregata
> 3. **CHART-3** (ID: 714): "Distribuzione Investimenti" - Grafico di distribuzione
> 4. **CHART-4** (ID: 715): "Media Efficacia" - Metrica di performance
>
> **🎯 Parametri di Posizionamento:**
> - `width`: Larghezza del grafico (4 = occupa 4 colonne della griglia)
> - `height`: Altezza del grafico (50 = 50 unità di altezza)
> - `parents`: Gerarchia di appartenenza (ogni elemento sa a chi appartiene)
> - `children`: Elementi contenuti (ogni container sa cosa contiene)
> - `chartId`/`sliceId`: ID univoco del grafico in Superset
> - `uuid`: Identificatore universale del grafico
> - `sliceName`: Nome visualizzato del grafico

```json
{
  "ROOT_ID": {"type": "ROOT", "id": "ROOT_ID", "children": ["GRID_ID"], "meta": {}, "parents": []},
  "GRID_ID": {"type": "GRID", "id": "GRID_ID", "children": ["ROW-1", "ROW-2", "ROW-3", "ROW-4"], "parents": ["ROOT_ID"]},
  "ROW-1": {"type": "ROW", "id": "ROW-1", "children": ["CHART-1"], "meta": {"background": "BACKGROUND_TRANSPARENT"}, "parents": ["ROOT_ID", "GRID_ID"]},
  "CHART-1": {"type": "CHART", "id": "CHART-1", "children": [], "meta": {"chartId": 718, "sliceId": 718, "slice_id": 718, "uuid": "72118fe1-3446-4199-8ddc-22330b013090", "width": 4, "height": 50, "sliceName": "Tabella Costi"}, "parents": ["ROOT_ID", "GRID_ID", "ROW-1"]},
  "ROW-2": {"type": "ROW", "id": "ROW-2", "children": ["CHART-2"], "meta": {"background": "BACKGROUND_TRANSPARENT"}, "parents": ["ROOT_ID", "GRID_ID"]},
  "CHART-2": {"type": "CHART", "id": "CHART-2", "children": [], "meta": {"chartId": 721, "sliceId": 721, "slice_id": 721, "uuid": "7617144d-cc1b-4bb1-a6b0-706ec1ad3dc6", "width": 4, "height": 50, "sliceName": "Pivot Table"}, "parents": ["ROOT_ID", "GRID_ID", "ROW-2"]},
  "ROW-3": {"type": "ROW", "id": "ROW-3", "children": ["CHART-3"], "meta": {"background": "BACKGROUND_TRANSPARENT"}, "parents": ["ROOT_ID", "GRID_ID"]},
  "CHART-3": {"type": "CHART", "id": "CHART-3", "children": [], "meta": {"chartId": 714, "sliceId": 714, "slice_id": 714, "uuid": "61588bd4-f26a-4f47-a1cc-9b77cd47225a", "width": 4, "height": 50, "sliceName": "Distribuzione Investimenti"}, "parents": ["ROOT_ID", "GRID_ID", "ROW-3"]},
  "ROW-4": {"type": "ROW", "id": "ROW-4", "children": ["CHART-4"], "meta": {"background": "BACKGROUND_TRANSPARENT"}, "parents": ["ROOT_ID", "GRID_ID"]},
  "CHART-4": {"type": "CHART", "id": "CHART-4", "children": [], "meta": {"chartId": 715, "sliceId": 715, "slice_id": 715, "uuid": "18d3613b-4d5b-4dfe-a817-b3dddabab928", "width": 4, "height": 50, "sliceName": "Media Efficacia"}, "parents": ["ROOT_ID", "GRID_ID", "ROW-4"]}
}
```




### 3. Esempio completo di chiamata POST /api/v1/dashboard/

**Endpoint:**  
`POST /api/v1/dashboard/`

**Body completo con i parametri dell'esempio sopra:**

> 📝 **Versione Leggibile (per comprensione):**
```json
{
  "dashboard_title": "Dashboard Infrastrutture Regione Puglia",
  "published": false,
  
  // === JSON_METADATA (struttura espansa per leggibilità) ===
  "json_metadata": {
    "native_filter_configuration": [
      {
        "id": "NATIVE_FILTER-0PMZ2rcO9QpIgYzoz5DQP",
        "name": "Tipologia Infrastruttura",
        "filterType": "filter_select",
        "targets": [{"column": {"name": "Tipologia di infrastruttura"}, "datasetId": 1}],
        "controlValues": {"multiSelect": true, "enableEmptyFilter": false},
        "scope": {"rootPath": ["ROOT_ID"], "excluded": []},
        "type": "NATIVE_FILTER",
        "chartsInScope": [718, 721, 714, 715],
        "tabsInScope": []
      },
      {
        "id": "NATIVE_FILTER-J_MsNmVvtPHmBMjEA-CVm", 
        "name": "Provincie",
        "filterType": "filter_select",
        "targets": [{"column": {"name": "Provincia"}, "datasetId": 1}],
        "controlValues": {"multiSelect": true, "enableEmptyFilter": false},
        "scope": {"rootPath": ["ROOT_ID"], "excluded": []},
        "type": "NATIVE_FILTER",
        "chartsInScope": [718],
        "tabsInScope": []
      },
      {
        "id": "NATIVE_FILTER-IhXqLjq_FDkIzTPIHfacu",
        "name": "ZdF", 
        "filterType": "filter_select",
        "targets": [{"column": {"name": "Zona di fornitura"}, "datasetId": 1}],
        "controlValues": {"multiSelect": true, "enableEmptyFilter": false},
        "scope": {"rootPath": ["ROOT_ID"], "excluded": []},
        "type": "NATIVE_FILTER",
        "chartsInScope": [718, 721, 714, 715],
        "tabsInScope": []
      },
      {
        "id": "NATIVE_FILTER-TAyYFAEJ7HgyGPjNLdlWb",
        "name": "R3",
        "filterType": "filter_select", 
        "targets": [{"column": {"name": "Rating R3 (classe)"}, "datasetId": 1}],
        "controlValues": {"multiSelect": true, "enableEmptyFilter": false},
        "scope": {"rootPath": ["ROOT_ID"], "excluded": []},
        "type": "NATIVE_FILTER",
        "chartsInScope": [718, 721, 714, 715],
        "tabsInScope": []
      }
    ],
    "cross_filters_enabled": true,
    "expanded_slices": {},
    "refresh_frequency": 0,
    "chart_configuration": {
      "714": {"id": 714, "crossFilters": {"scope": "global", "chartsInScope": [715, 718, 721]}},
      "718": {"id": 718, "crossFilters": {"scope": "global", "chartsInScope": [714, 715, 721]}},
      "721": {"id": 721, "crossFilters": {"scope": "global", "chartsInScope": [714, 715, 718]}}
    },
    "global_chart_configuration": {
      "scope": {"rootPath": ["ROOT_ID"], "excluded": []},
      "chartsInScope": [714, 715, 718, 721]
    }
  },
  
  // === POSITION_JSON (struttura espansa per leggibilità) ===
  "position_json": {
    "ROOT_ID": {
      "type": "ROOT",
      "id": "ROOT_ID", 
      "children": ["GRID_ID"],
      "meta": {},
      "parents": []
    },
    "GRID_ID": {
      "type": "GRID",
      "id": "GRID_ID",
      "children": ["ROW-1", "ROW-2", "ROW-3", "ROW-4"],
      "parents": ["ROOT_ID"]
    },
    "ROW-1": {
      "type": "ROW",
      "id": "ROW-1",
      "children": ["CHART-1"],
      "meta": {"background": "BACKGROUND_TRANSPARENT"},
      "parents": ["ROOT_ID", "GRID_ID"]
    },
    "CHART-1": {
      "type": "CHART",
      "id": "CHART-1",
      "children": [],
      "meta": {
        "chartId": 718,
        "sliceId": 718,
        "slice_id": 718,
        "uuid": "72118fe1-3446-4199-8ddc-22330b013090",
        "width": 4,
        "height": 50,
        "sliceName": "Tabella Costi"
      },
      "parents": ["ROOT_ID", "GRID_ID", "ROW-1"]
    },
    "ROW-2": {
      "type": "ROW",
      "id": "ROW-2", 
      "children": ["CHART-2"],
      "meta": {"background": "BACKGROUND_TRANSPARENT"},
      "parents": ["ROOT_ID", "GRID_ID"]
    },
    "CHART-2": {
      "type": "CHART",
      "id": "CHART-2",
      "children": [],
      "meta": {
        "chartId": 721,
        "sliceId": 721,
        "slice_id": 721,
        "uuid": "7617144d-cc1b-4bb1-a6b0-706ec1ad3dc6",
        "width": 4,
        "height": 50,
        "sliceName": "Pivot Table"
      },
      "parents": ["ROOT_ID", "GRID_ID", "ROW-2"]
    },
    "ROW-3": {
      "type": "ROW",
      "id": "ROW-3",
      "children": ["CHART-3"],
      "meta": {"background": "BACKGROUND_TRANSPARENT"},
      "parents": ["ROOT_ID", "GRID_ID"]
    },
    "CHART-3": {
      "type": "CHART",
      "id": "CHART-3",
      "children": [],
      "meta": {
        "chartId": 714,
        "sliceId": 714,
        "slice_id": 714,
        "uuid": "61588bd4-f26a-4f47-a1cc-9b77cd47225a",
        "width": 4,
        "height": 50,
        "sliceName": "Distribuzione Investimenti"
      },
      "parents": ["ROOT_ID", "GRID_ID", "ROW-3"]
    },
    "ROW-4": {
      "type": "ROW",
      "id": "ROW-4",
      "children": ["CHART-4"],
      "meta": {"background": "BACKGROUND_TRANSPARENT"},
      "parents": ["ROOT_ID", "GRID_ID"]
    },
    "CHART-4": {
      "type": "CHART", 
      "id": "CHART-4",
      "children": [],
      "meta": {
        "chartId": 715,
        "sliceId": 715,
        "slice_id": 715,
        "uuid": "18d3613b-4d5b-4dfe-a817-b3dddabab928",
        "width": 4,
        "height": 50,
        "sliceName": "Media Efficacia"
      },
      "parents": ["ROOT_ID", "GRID_ID", "ROW-4"]
    }
  }
}
```

> ⚠️ **Versione API Reale (con stringhe escaped):**
```json
{
  "dashboard_title": "Dashboard Infrastrutture Regione Puglia",
  "published": false,
  "json_metadata": "{\"native_filter_configuration\":[{\"id\":\"NATIVE_FILTER-0PMZ2rcO9QpIgYzoz5DQP\",\"name\":\"Tipologia Infrastruttura\",\"filterType\":\"filter_select\",\"targets\":[{\"column\":{\"name\":\"Tipologia di infrastruttura\"},\"datasetId\":1}],\"controlValues\":{\"multiSelect\":true,\"enableEmptyFilter\":false,\"defaultToFirstItem\":false,\"searchAllOptions\":false,\"inverseSelection\":false},\"scope\":{\"rootPath\":[\"ROOT_ID\"],\"excluded\":[]},\"type\":\"NATIVE_FILTER\",\"chartsInScope\":[718,721,714,715],\"tabsInScope\":[]},{\"id\":\"NATIVE_FILTER-J_MsNmVvtPHmBMjEA-CVm\",\"name\":\"Provincie\",\"filterType\":\"filter_select\",\"targets\":[{\"column\":{\"name\":\"Provincia\"},\"datasetId\":1}],\"controlValues\":{\"multiSelect\":true,\"enableEmptyFilter\":false,\"defaultToFirstItem\":false,\"searchAllOptions\":false,\"inverseSelection\":false},\"scope\":{\"rootPath\":[\"ROOT_ID\"],\"excluded\":[]},\"type\":\"NATIVE_FILTER\",\"chartsInScope\":[718],\"tabsInScope\":[]},{\"id\":\"NATIVE_FILTER-IhXqLjq_FDkIzTPIHfacu\",\"name\":\"ZdF\",\"filterType\":\"filter_select\",\"targets\":[{\"column\":{\"name\":\"Zona di fornitura\"},\"datasetId\":1}],\"controlValues\":{\"multiSelect\":true,\"enableEmptyFilter\":false,\"defaultToFirstItem\":false,\"searchAllOptions\":false,\"inverseSelection\":false},\"scope\":{\"rootPath\":[\"ROOT_ID\"],\"excluded\":[]},\"type\":\"NATIVE_FILTER\",\"chartsInScope\":[718,721,714,715],\"tabsInScope\":[]},{\"id\":\"NATIVE_FILTER-TAyYFAEJ7HgyGPjNLdlWb\",\"name\":\"R3\",\"filterType\":\"filter_select\",\"targets\":[{\"column\":{\"name\":\"Rating R3 (classe)\"},\"datasetId\":1}],\"controlValues\":{\"multiSelect\":true,\"enableEmptyFilter\":false,\"defaultToFirstItem\":false,\"searchAllOptions\":false,\"inverseSelection\":false},\"scope\":{\"rootPath\":[\"ROOT_ID\"],\"excluded\":[]},\"type\":\"NATIVE_FILTER\",\"chartsInScope\":[718,221,714,715],\"tabsInScope\":[]}],\"cross_filters_enabled\":true,\"expanded_slices\":{},\"refresh_frequency\":0,\"chart_configuration\":{\"714\":{\"id\":714,\"crossFilters\":{\"scope\":\"global\",\"chartsInScope\":[715,718,721]}},\"718\":{\"id\":718,\"crossFilters\":{\"scope\":\"global\",\"chartsInScope\":[714,715,721]}},\"721\":{\"id\":721,\"crossFilters\":{\"scope\":\"global\",\"chartsInScope\":[714,715,718]}}},\"global_chart_configuration\":{\"scope\":{\"rootPath\":[\"ROOT_ID\"],\"excluded\":[]},\"chartsInScope\":[714,715,718,721]}}",
  "position_json": "{\"ROOT_ID\":{\"type\":\"ROOT\",\"id\":\"ROOT_ID\",\"children\":[\"GRID_ID\"],\"meta\":{},\"parents\":[]},\"GRID_ID\":{\"type\":\"GRID\",\"id\":\"GRID_ID\",\"children\":[\"ROW-1\",\"ROW-2\",\"ROW-3\",\"ROW-4\"],\"parents\":[\"ROOT_ID\"]},\"ROW-1\":{\"type\":\"ROW\",\"id\":\"ROW-1\",\"children\":[\"CHART-1\"],\"meta\":{\"background\":\"BACKGROUND_TRANSPARENT\"},\"parents\":[\"ROOT_ID\",\"GRID_ID\"]},\"CHART-1\":{\"type\":\"CHART\",\"id\":\"CHART-1\",\"children\":[],\"meta\":{\"chartId\":718,\"sliceId\":718,\"slice_id\":718,\"uuid\":\"72118fe1-3446-4199-8ddc-22330b013090\",\"width\":4,\"height\":50,\"sliceName\":\"Tabella Costi\"},\"parents\":[\"ROOT_ID\",\"GRID_ID\",\"ROW-1\"]},\"ROW-2\":{\"type\":\"ROW\",\"id\":\"ROW-2\",\"children\":[\"CHART-2\"],\"meta\":{\"background\":\"BACKGROUND_TRANSPARENT\"},\"parents\":[\"ROOT_ID\",\"GRID_ID\"]},\"CHART-2\":{\"type\":\"CHART\",\"id\":\"CHART-2\",\"children\":[],\"meta\":{\"chartId\":721,\"sliceId\":721,\"slice_id\":721,\"uuid\":\"7617144d-cc1b-4bb1-a6b0-706ec1ad3dc6\",\"width\":4,\"height\":50,\"sliceName\":\"Pivot Table\"},\"parents\":[\"ROOT_ID\",\"GRID_ID\",\"ROW-2\"]},\"ROW-3\":{\"type\":\"ROW\",\"id\":\"ROW-3\",\"children\":[\"CHART-3\"],\"meta\":{\"background\":\"BACKGROUND_TRANSPARENT\"},\"parents\":[\"ROOT_ID\",\"GRID_ID\"]},\"CHART-3\":{\"type\":\"CHART\",\"id\":\"CHART-3\",\"children\":[],\"meta\":{\"chartId\":714,\"sliceId\":714,\"slice_id\":714,\"uuid\":\"61588bd4-f26a-4f47-a1cc-9b77cd47225a\",\"width\":4,\"height\":50,\"sliceName\":\"Distribuzione Investimenti\"},\"parents\":[\"ROOT_ID\",\"GRID_ID\",\"ROW-3\"]},\"ROW-4\":{\"type\":\"ROW\",\"id\":\"ROW-4\",\"children\":[\"CHART-4\"],\"meta\":{\"background\":\"BACKGROUND_TRANSPARENT\"},\"parents\":[\"ROOT_ID\",\"GRID_ID\"]},\"CHART-4\":{\"type\":\"CHART\",\"id\":\"CHART-4\",\"children\":[],\"meta\":{\"chartId\":715,\"sliceId\":715,\"slice_id\":715,\"uuid\":\"18d3613b-4d5b-4dfe-a817-b3dddabab928\",\"width\":4,\"height\":50,\"sliceName\":\"Media Efficacia\"},\"parents\":[\"ROOT_ID\",\"GRID_ID\",\"ROW-4\"]}}"
}
```

> 💡 **Nota Importante**: I campi `json_metadata` e `position_json` devono essere stringhe JSON "escaped" (con i caratteri " sostituiti da \"), come mostrato nell'esempio sopra. Non passare oggetti JSON direttamente, ma stringhe contenenti JSON.

### 4. (Opzionale) Aggiornamento posizione grafici

Se necessario dopo la creazione, effettuare una chiamata `PUT` a `/dashboard/{dashboard_id}` per aggiornare la struttura `position_json` della dashboard.

**Endpoint:**  
`PUT /api/v1/dashboard/{dashboard_id}`

**Body:**
```json
{
  "position_json": "{\"ROOT_ID\": {...}, ...}" // struttura aggiornata con tutti i chart_ids
}
```

### 5. (Opzionale) Associazione esplicita dei grafici alla dashboard

Per ogni grafico, effettuare una chiamata `PUT` a `/chart/{chart_id}` per aggiornare il campo `dashboards` e assicurare l'integrità referenziale.

**Endpoint:**  
`PUT /api/v1/chart/{chart_id}`

**Body:**
```json
{
  "dashboards": [dashboard_id]
}
```

### 6. Verifica finale

Effettuare una chiamata `GET` a `/dashboard/{dashboard_id}` per verificare che la dashboard sia stata creata correttamente e che i grafici risultino associati e visibili.

---


---
## 🗄️ Creazione Dataset

 _Sezione in costruzione: qui verrà documentato come creare un dataset via API, con esempi e parametri._

---

