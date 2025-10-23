# 📊 Riferimento API per Creazione Dataset Superset

## 🎯 Obiettivo
Documentazione dettagliata dei parametri API e esempi pratici per la creazione e gestione di dataset in Superset tramite chiamate REST.

> 📋 **Stato Validazione**: **Dataset API completamente validata e testata** con Superset v6
> - ✅ GET Dataset Details (lettura completa struttura dataset)
> - ✅ POST Dataset Creation - Physical Tables (creazione dataset da tabelle esistenti)
> - ✅ POST Dataset Creation - Virtual Datasets (creazione dataset con SQL personalizzato) 
> - ✅ Dataset Structure Analysis (analisi colonne, metriche, e configurazioni)
> - ✅ Database Connection Management (gestione connessioni database)
> - ✅ Complete Chart Integration (integrazione completa con API chart)

---

## 📑 Indice

- [🔑 Autenticazione](#-autenticazione)
- [🔍 Ottenere l'ID del Dataset Creato](#-ottenere-lid-del-dataset-creato)
- [📋 Lettura Dataset Esistente](#-lettura-dataset-esistente)
- [🗄️ Creazione Dataset](#️-creazione-dataset)
  - [Dataset Fisici (Tabelle Database)](#dataset-fisici-tabelle-database)
  - [Dataset Virtuali (SQL Personalizzato)](#dataset-virtuali-sql-personalizzato)
- [🏗️ Struttura Dataset Response](#️-struttura-dataset-response)
- [🔧 Gestione Database Connections](#-gestione-database-connections)
- [🔄 Integrazione con Chart API](#-integrazione-con-chart-api)

---

## 🔑 Autenticazione

Prima di effettuare qualsiasi chiamata alle API di Superset, è necessario autenticarsi per ottenere un token JWT.

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

## 🔍 Ottenere l'ID del Dataset Creato

Dopo ogni chiamata `POST /api/v1/dataset/` con successo, la risposta contiene l'**ID del dataset appena creato**:

**Struttura risposta di successo:**
```json
{
  "id": 26,
  "result": {
    "id": 26,
    "table_name": "virtual_dataset_173513",
    "database": {
      "id": 1,
      "database_name": "examples",
      "backend": "sqlite"
    },
    "schema": null,
    "sql": "SELECT 'test' as test_column, 1 as test_number, date('now') as test_date",
    "datasource_type": "table",
    "kind": "virtual",
    "is_sqllab_view": false,
    "columns": [
      {
        "column_name": "test_column",
        "type": "STRING",
        "groupby": true,
        "filterable": true
      },
      {
        "column_name": "test_number", 
        "type": "INT",
        "groupby": true,
        "filterable": true
      },
      {
        "column_name": "test_date",
        "type": "STRING", 
        "groupby": true,
        "filterable": true
      }
    ],
    "metrics": [
      {
        "metric_name": "count",
        "expression": "COUNT(*)"
      }
    ],
    "created_on": "2025-10-16T17:35:11.829002",
    "changed_on": "2025-10-16T17:35:14.582674"
  }
}
```

**Come estrarre l'ID:**
- L'**ID principale** si trova nel campo `id` a livello root della risposta
- È anche disponibile in `result.id` (stesso valore)
- Questo ID può essere utilizzato per operazioni successive come:
  - Modifica dataset: `PUT /api/v1/dataset/{id}`
  - Cancellazione: `DELETE /api/v1/dataset/{id}`
  - Ottenere dettagli: `GET /api/v1/dataset/{id}`
  - **Creazione chart**: Usare come `datasource_id` nelle chiamate chart

**Esempio di estrazione ID (PowerShell):**
```powershell
$response = Invoke-RestMethod -Uri "$SupersetUrl/api/v1/dataset/" -Method POST -Headers $headers -Body $jsonBody -ContentType "application/json"
$datasetId = $response.id
Write-Host "Dataset creato con ID: $datasetId"

# Verifica immediata del dataset creato
$datasetDetails = Invoke-RestMethod -Uri "$SupersetUrl/api/v1/dataset/$datasetId" -Headers $headers
Write-Host "Columns disponibili: $($datasetDetails.result.columns.Count)"

# Ora puoi usare $datasetId come datasource_id per creare chart
$chartData = @{
    datasource_id = $datasetId
    datasource_type = "table"
    slice_name = "Mio Chart"
    viz_type = "table"
    params = "{`"datasource`":{`"id`":$datasetId,`"type`":`"table`"},`"viz_type`":`"table`",`"all_columns`":[`"colonna1`"],`"row_limit`":100}"
} | ConvertTo-Json
```

---

## 📋 Lettura Dataset Esistente

### Endpoint per Dettagli Dataset

**Endpoint:**  
`GET /api/v1/dataset/{dataset_id}`

**Parametri:**
- `dataset_id`: ID numerico del dataset (**obbligatorio**)

**Esempio di chiamata:**
```powershell
$datasetDetails = Invoke-RestMethod -Uri "$SupersetUrl/api/v1/dataset/24" -Headers $headers
```

**Risposta Completa:**
La risposta contiene tutti i dettagli necessari per utilizzare il dataset:

```json
{
  "result": {
    "id": 24,
    "table_name": "users_channels",
    "datasource_name": "users_channels",
    "datasource_type": "table",
    "database": {
      "id": 1,
      "database_name": "examples",
      "backend": "sqlite",
      "allow_multi_catalog": false
    },
    "schema": "main",
    "sql": null,
    "columns": [
      {
        "id": 762,
        "column_name": "user_id",
        "type": "STRING",
        "groupby": true,
        "filterable": true,
        "is_dttm": false
      },
      {
        "id": 763,
        "column_name": "name", 
        "type": "STRING",
        "groupby": true,
        "filterable": true,
        "is_dttm": false
      }
    ],
    "metrics": [
      {
        "id": 31,
        "metric_name": "count",
        "expression": "count(*)",
        "metric_type": null
      }
    ]
  }
}
```

---

## 🗄️ Creazione Dataset

### Dataset Fisici (Tabelle Database)

**Endpoint:**  
`POST /api/v1/dataset/`

**Parametri indispensabili:**
- `database`: ID numerico del database connection (**obbligatorio**)
- `table_name`: Nome della tabella esistente nel database (**obbligatorio**)
- `schema`: Nome dello schema (può essere null per SQLite) (**opzionale**)
- `owners`: Array con ID degli owner (es. [1]) (**opzionale**)

**Esempio creazione dataset fisico:**
```json
{
  "database": 1,
  "table_name": "users_channels",
  "schema": null,
  "owners": [1]
}
```

**⚠️ Limitazioni Dataset Fisici:**
- La tabella deve esistere fisicamente nel database
- Non è possibile creare dataset per tabelle già associate (errore 422)
- Verificare sempre l'esistenza della tabella prima della creazione

---

### Dataset Virtuali (SQL Personalizzato)

**Endpoint:**  
`POST /api/v1/dataset/`

**Parametri indispensabili per dataset virtuali:**
- `database`: ID numerico del database connection (**obbligatorio**)
- `sql`: Query SQL personalizzata (**obbligatorio per dataset virtuali**)
- `table_name`: Nome univoco del dataset virtuale (**obbligatorio**)
- `schema`: Nome dello schema (può essere null) (**opzionale**)
- `owners`: Array con ID degli owner (es. [1]) (**opzionale**)

**Esempio creazione dataset virtuale FUNZIONANTE:**
```json
{
  "database": 1,
  "schema": null,
  "sql": "SELECT 'test' as test_column, 1 as test_number, date('now') as test_date",
  "table_name": "virtual_dataset_173513",
  "owners": [1]
}
```

**✅ Vantaggi Dataset Virtuali:**
- Sempre funzionanti (non dipendono da tabelle esistenti)
- Query SQL personalizzata per dati calcolati
- Ideali per test e prove di concetto
- Supportano qualsiasi logica SQL valida

**Esempio SQL avanzato:**
```sql
SELECT 
  'Categoria A' as categoria,
  RANDOM() * 100 as valore,
  date('now', '-' || (RANDOM() * 365) || ' days') as data_random
UNION ALL
SELECT 
  'Categoria B' as categoria,
  RANDOM() * 200 as valore,
  date('now', '-' || (RANDOM() * 365) || ' days') as data_random
```

---

### Workflow Creazione Dataset

**Step 1: Ottenere Database ID**
```powershell
$databases = Invoke-RestMethod -Uri "$SupersetUrl/api/v1/database/" -Headers $headers
# Seleziona il database desiderato
$databaseId = $databases.result[0].id
```

**Step 2: Creare Dataset (Approccio Consigliato - Virtual Dataset)**
```powershell
# Approccio SEMPRE FUNZIONANTE con dataset virtuali
$timestamp = Get-Date -Format 'HHmmss'
$datasetData = @{
    database = $databaseId
    schema = $null
    sql = "SELECT 'test' as test_column, 1 as test_number, date('now') as test_date"
    table_name = "my_virtual_dataset_$timestamp"
    owners = @(1)
} | ConvertTo-Json

$datasetResponse = Invoke-RestMethod -Uri "$SupersetUrl/api/v1/dataset/" -Method POST -Headers $headers -Body $datasetData -ContentType "application/json"
```

**Step 2 Alternativo: Creare Dataset da Tabella Fisica (se tabella esiste e non ha già dataset)**
```powershell
$datasetData = @{
    database = $databaseId
    table_name = "nome_tabella_esistente"  # DEVE esistere nel database
    schema = $null
    owners = @(1)
} | ConvertTo-Json

$datasetResponse = Invoke-RestMethod -Uri "$SupersetUrl/api/v1/dataset/" -Method POST -Headers $headers -Body $datasetData -ContentType "application/json"
```

**Step 3: Ottenere Dataset ID e Testare con Chart**
```powershell
$datasetId = $datasetResponse.id
Write-Host "Dataset creato con ID: $datasetId"

# Verifica il dataset creato
$datasetDetails = Invoke-RestMethod -Uri "$SupersetUrl/api/v1/dataset/$datasetId" -Headers $headers

# Test immediato con creazione chart
$chartData = @{
    datasource_id = $datasetId
    datasource_type = "table"
    slice_name = "Test Chart - Dataset $datasetId"
    viz_type = "table" 
    params = "{`"datasource`":{`"id`":$datasetId,`"type`":`"table`"},`"viz_type`":`"table`",`"all_columns`":[`"test_column`",`"test_number`"],`"row_limit`":10}"
} | ConvertTo-Json

$chartResponse = Invoke-RestMethod -Uri "$SupersetUrl/api/v1/chart/" -Method POST -Headers $headers -Body $chartData
Write-Host "Chart creato con ID: $($chartResponse.id)"
```

---

## 🏗️ Struttura Dataset Response

### Campi Principali

**Identificazione:**
- `id`: ID numerico del dataset (usare per chart)
- `table_name`: Nome tabella originale
- `datasource_name`: Nome completo dataset
- `datasource_type`: Sempre "table"

**Database Connection:**
- `database.id`: ID connection database
- `database.database_name`: Nome database
- `database.backend`: Tipo database (sqlite, postgresql, etc.)

**Schema e Struttura:**
- `schema`: Schema database (può essere null)
- `sql`: Query SQL personalizzata (null per tabelle fisiche)
- `kind`: "physical" per tabelle, "virtual" per viste SQL

**Colonne Disponibili:**
```json
"columns": [
  {
    "id": 762,
    "column_name": "user_id",
    "type": "STRING",
    "groupby": true,     // Usabile per raggruppamenti
    "filterable": true,  // Usabile per filtri
    "is_dttm": false     // È colonna temporale
  }
]
```

**Metriche Disponibili:**
```json
"metrics": [
  {
    "id": 31,
    "metric_name": "count",
    "expression": "count(*)",
    "metric_type": null
  }
]
```

---

## 🔧 Gestione Database Connections

### Ottenere Database Disponibili

**Endpoint:**  
`GET /api/v1/database/`

**Esempio:**
```powershell
$databases = Invoke-RestMethod -Uri "$SupersetUrl/api/v1/database/" -Headers $headers
foreach ($db in $databases.result) {
    Write-Host "ID: $($db.id) | Name: $($db.database_name) | Backend: $($db.backend)"
}
```

### Differenze per Tipo Database

**SQLite (Current Setup):**
```json
{
  "database": 1,
  "table_name": "birth_names",
  "schema": null
}
```

**Dremio + MongoDB (Future Setup):**
```json
{
  "database": 2,
  "table_name": "mongo.mydb.collection_name",
  "schema": null
}
```

**Dremio + PostgreSQL (Future Setup):**
```json
{
  "database": 3,
  "table_name": "postgres.public.table_name", 
  "schema": "public"
}
```

---

## ⚠️ Note Tecniche Importanti

### Limitazioni API
- **Dataset Fisici**: Tabelle devono esistere fisicamente nel database
- **Duplicati**: Errore 422 se il dataset per la tabella esiste già
- **Permessi**: L'utente deve avere permessi sul database connection
- **Dataset Virtuali**: Sempre funzionanti se la SQL è valida

### Best Practices
1. **Usare Dataset Virtuali per Test**: Sempre funzionanti e indipendenti
2. **Nomi Univoci**: Aggiungere timestamp per evitare conflitti
3. **Verificare Database Connection**: Assicurarsi che il database sia attivo
4. **Test Immediato**: Creare subito un chart per verificare il dataset
5. **Gestire Errori 422**: Indicano dataset duplicati o SQL non valida

### Workflow Consigliato (VALIDATO)
1. Autenticarsi con `POST /api/v1/security/login`
2. Ottenere database disponibili con `GET /api/v1/database/`
3. **Creare dataset virtuale** con `POST /api/v1/dataset/` (approccio consigliato)
4. Usare dataset ID come `datasource_id` nei chart
5. Testare immediatamente con creazione chart
6. Verificare dataset con `GET /api/v1/dataset/{id}`

---

## 🔍 Script di Esempio

### Get-Dataset-Details.ps1
Script per analizzare struttura dataset esistente:
```powershell
.\Get-Dataset-Details.ps1 -DatasetId 26
```

### Test-Virtual-Dataset-Creation.ps1  
Script per creare nuovo dataset virtuale (SEMPRE FUNZIONANTE):
```powershell
.\Test-Virtual-Dataset-Creation.ps1
```

**Output esempio di successo:**
```
SUCCESS: Virtual Dataset created!
Dataset ID: 26
Dataset Name: virtual_dataset_173513
Database: examples (ID: 1)
Virtual Dataset Details:
  - Dataset ID: 26
  - Kind: virtual
  - SQL: SELECT 'test' as test_column, 1 as test_number, date('now') as test_date
  - Columns Count: 3
  - Metrics Count: 1
SUCCESS: Chart created with ID 1173 using virtual dataset!
=== COMPLETE WORKFLOW SUCCESSFUL ===
```

### Test-Dataset-Creation.ps1  
Script per creare dataset da tabelle fisiche (può fallire se tabella ha già dataset):
```powershell
.\Test-Dataset-Creation.ps1
```

---

## 🔄 Integrazione con Chart API

### Usare Dataset ID nei Chart

Una volta creato il dataset, usa l'ID per creare chart:

```json
{
  "datasource_id": 24,        // ID del dataset creato
  "datasource_type": "table",
  "slice_name": "Mio Chart",
  "viz_type": "table",
  "params": "{\"datasource\":{\"id\":24,\"type\":\"table\"},\"viz_type\":\"table\",\"all_columns\":[\"user_id\",\"name\"],\"row_limit\":100}"
}
```

### Colonne e Metriche Disponibili

Usa le informazioni del dataset per costruire chart validi:
- **Colonne**: Usa `column_name` delle colonne con `groupby: true`
- **Metriche**: Usa `metric_name` delle metriche disponibili
- **Filtri**: Usa colonne con `filterable: true`

---

> 📋 **Conclusione**: L'API dataset di Superset v6 permette creazione programmatica di dataset da qualsiasi database connesso. Il dataset ID ottenuto viene utilizzato come `datasource_id` per creare chart tramite l'API chart.