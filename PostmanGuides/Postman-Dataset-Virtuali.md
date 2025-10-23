# Guida Postman - Creazione Dataset Virtuali Superset

Questa guida fornisce esempi di chiamate Postman per creare dataset virtuali con SQL personalizzato in Apache Superset, equivalente al file `Test-Virtual-Dataset-Creation.ps1`.

## Setup Iniziale

### Variabili Postman
- `superset_url`: http://localhost:8080
- `access_token`: [token dal login]
- `database_id`: ID del database da utilizzare
- `timestamp`: {{$timestamp}}

### Autenticazione
Vedi la guida "Postman-Creazione-Grafici.md" per i dettagli del login.

## Creazione Dataset Virtuali

### 1. Ottenere Database Disponibili

**GET** `{{superset_url}}/api/v1/database/`

**Headers:**
```
Authorization: Bearer {{access_token}}
Content-Type: application/json
```

**Response:**
Seleziona il database per eseguire le query SQL.

### 2. Creare Dataset Virtuale Semplice

**POST** `{{superset_url}}/api/v1/dataset/`

**Headers:**
```
Authorization: Bearer {{access_token}}
Content-Type: application/json
```

**Body:**
```json
{
    "database": 1,
    "schema": null,
    "sql": "SELECT 'test' as test_column, 1 as test_number, date('now') as test_date",
    "table_name": "virtual_dataset_{{timestamp}}",
    "owners": [1]
}
```

### 3. Dataset Virtuale con Join

**POST** `{{superset_url}}/api/v1/dataset/`

**Body:**
```json
{
    "database": 1,
    "schema": null,
    "sql": "SELECT b.name, b.sum_boys, b.sum_girls, (b.sum_boys + b.sum_girls) as total FROM birth_names b WHERE b.year > 2000",
    "table_name": "virtual_birth_analysis_{{timestamp}}",
    "owners": [1]
}
```

### 4. Dataset Virtuale con Aggregazioni

**POST** `{{superset_url}}/api/v1/dataset/`

**Body:**
```json
{
    "database": 1,
    "schema": null,
    "sql": "SELECT year, SUM(sum_boys) as total_boys, SUM(sum_girls) as total_girls, COUNT(*) as name_count FROM birth_names GROUP BY year ORDER BY year",
    "table_name": "virtual_yearly_summary_{{timestamp}}",
    "owners": [1]
}
```

### 5. Dataset Virtuale con Calcoli Complessi

**POST** `{{superset_url}}/api/v1/dataset/`

**Body:**
```json
{
    "database": 1,
    "schema": null,
    "sql": "SELECT name, year, sum_boys, sum_girls, CASE WHEN sum_boys > sum_girls THEN 'More Boys' WHEN sum_girls > sum_boys THEN 'More Girls' ELSE 'Equal' END as gender_trend, (sum_boys + sum_girls) as total_births FROM birth_names WHERE year BETWEEN 1980 AND 2020",
    "table_name": "virtual_gender_trends_{{timestamp}}",
    "owners": [1]
}
```

## Esempi SQL per Diversi Database

### SQLite
```sql
SELECT 
    'sample' as category,
    random() % 100 as value,
    date('now', '-' || (random() % 365) || ' days') as date_column
```

### PostgreSQL
```sql
SELECT 
    'sample' as category,
    RANDOM() * 100 as value,
    CURRENT_DATE - INTERVAL '1 day' * (RANDOM() * 365) as date_column
```

### MySQL
```sql
SELECT 
    'sample' as category,
    RAND() * 100 as value,
    DATE_SUB(NOW(), INTERVAL FLOOR(RAND() * 365) DAY) as date_column
```

## Test Dataset Virtuale Creato

### Verifica Dettagli Dataset

**GET** `{{superset_url}}/api/v1/dataset/{{virtual_dataset_id}}`

**Headers:**
```
Authorization: Bearer {{access_token}}
```

**Response Include:**
- SQL query utilizzata
- Colonne rilevate automaticamente
- Tipi di dati inferiti
- Metriche disponibili

### Creazione Grafico di Test

**POST** `{{superset_url}}/api/v1/chart/`

**Headers:**
```
Authorization: Bearer {{access_token}}
Content-Type: application/json
```

**Body:**
```json
{
    "datasource_id": "{{virtual_dataset_id}}",
    "datasource_type": "table",
    "slice_name": "Test Chart - Virtual Dataset {{virtual_dataset_id}} - {{timestamp}}",
    "viz_type": "table",
    "params": "{\"datasource\":{\"id\":{{virtual_dataset_id}},\"type\":\"table\"},\"viz_type\":\"table\",\"all_columns\":[\"test_column\",\"test_number\",\"test_date\"],\"row_limit\":10}"
}
```

## Pre-request Script Avanzato

```javascript
// Genera SQL dinamico basato su timestamp
var timestamp = new Date().getTime();
var currentDate = new Date().toISOString().split('T')[0];

// SQL semplice per test
var simpleSql = `SELECT 
    '${timestamp}' as session_id,
    'test_value' as test_column, 
    ${Math.floor(Math.random() * 1000)} as random_number, 
    '${currentDate}' as test_date`;

pm.environment.set("dynamic_sql", simpleSql);
pm.environment.set("virtual_table_name", "virtual_dataset_" + timestamp);

console.log("SQL generato: " + simpleSql);
```

## Tests Script

```javascript
// Verifica creazione dataset virtuale
pm.test("Dataset virtuale creato", function () {
    pm.response.to.have.status(201);
    var response = pm.response.json();
    pm.expect(response.id).to.be.a('number');
    pm.environment.set("virtual_dataset_id", response.id);
});

// Verifica che sia un dataset virtuale
pm.test("È un dataset virtuale", function () {
    var response = pm.response.json();
    pm.expect(response.sql).to.not.be.null;
    pm.expect(response.sql).to.not.be.undefined;
});
```

## Workflow per Dataset Virtuali Complesso

### 1. Esplorazione Dati Esistenti

**GET** `{{superset_url}}/api/v1/dataset/`

**Headers:**
```
Authorization: Bearer {{access_token}}
```

Filtra per trovare dataset esistenti da cui derivare nuove query.

### 2. Test Query in SQL Lab

Prima di creare il dataset virtuale, testa la query:

**POST** `{{superset_url}}/api/v1/sqllab/execute/`

**Headers:**
```
Authorization: Bearer {{access_token}}
Content-Type: application/json
```

**Body:**
```json
{
    "database_id": 1,
    "sql": "SELECT 'test' as test_column, 1 as test_number, date('now') as test_date",
    "runAsync": false,
    "schema": null
}
```

### 3. Creazione Dataset se Query OK

Solo se la query funziona, procedi con la creazione del dataset virtuale.

## Esempi di Query Complesse

### Dataset per Dashboard Analytics

```json
{
    "database": 1,
    "schema": null,
    "sql": "WITH monthly_stats AS (SELECT strftime('%Y-%m', date) as month, COUNT(*) as total_records FROM birth_names GROUP BY strftime('%Y-%m', date)) SELECT month, total_records, LAG(total_records) OVER (ORDER BY month) as prev_month, (total_records - LAG(total_records) OVER (ORDER BY month)) as month_diff FROM monthly_stats ORDER BY month",
    "table_name": "virtual_monthly_trends_{{timestamp}}",
    "owners": [1]
}
```

### Dataset per KPI

```json
{
    "database": 1,
    "schema": null,
    "sql": "SELECT 'Total Names' as kpi_name, COUNT(DISTINCT name) as kpi_value, 'count' as kpi_type FROM birth_names UNION ALL SELECT 'Total Years' as kpi_name, COUNT(DISTINCT year) as kpi_value, 'count' as kpi_type FROM birth_names UNION ALL SELECT 'Avg Boys per Name' as kpi_name, AVG(sum_boys) as kpi_value, 'average' as kpi_type FROM birth_names",
    "table_name": "virtual_kpi_summary_{{timestamp}}",
    "owners": [1]
}
```

### Dataset per Time Series

```json
{
    "database": 1,
    "schema": null,
    "sql": "SELECT year, SUM(sum_boys + sum_girls) as total_births, SUM(sum_boys) as total_boys, SUM(sum_girls) as total_girls, ROUND(SUM(sum_boys) * 100.0 / SUM(sum_boys + sum_girls), 2) as boys_percentage FROM birth_names GROUP BY year ORDER BY year",
    "table_name": "virtual_time_series_{{timestamp}}",
    "owners": [1]
}
```

## Gestione Errori SQL

### Errore Sintassi SQL
```json
{
    "message": "SQL compilation error"
}
```
**Soluzione**: Verifica sintassi SQL prima di creare dataset.

### Tabelle Non Esistenti
```json
{
    "message": "Table 'table_name' doesn't exist"
}
```
**Soluzione**: Controlla che tutte le tabelle referenziate esistano.

### Permessi Insufficienti
```json
{
    "message": "Access denied"
}
```
**Soluzione**: Verifica permessi sul database e tabelle.

## Collection Runner Workflow

1. **Login**: Autenticazione
2. **Get Databases**: Lista database
3. **Test SQL Query**: Verifica query in SQL Lab
4. **Create Virtual Dataset**: Crea dataset se query OK
5. **Get Dataset Details**: Verifica struttura
6. **Create Chart**: Test con grafico
7. **Cleanup** (opzionale): Rimuovi dataset test

## Note Avanzate

### Performance
- Le query complesse possono essere lente
- Considera l'uso di LIMIT per dataset di test
- Monitora l'uso risorse database

### Sicurezza
- I dataset virtuali eseguono SQL ad ogni accesso
- Non includere dati sensibili nelle query
- Valida sempre input se SQL è dinamico

### Manutenzione
- Documenta la logica business nelle query
- Usa nomi descrittivi per colonne calcolate
- Aggiungi commenti SQL quando utile

### Limitazioni
- Non tutti i database supportano tutte le funzioni SQL
- Alcune funzioni potrebbero non essere disponibili in Superset
- Performance dipende dalla complessità query e volume dati