# Guida Postman - Creazione Dataset Superset

Questa guida fornisce esempi di chiamate Postman per creare dataset in Apache Superset, equivalente al file `Test-Dataset-Creation.ps1`.

## Setup Iniziale

### Variabili Postman
- `superset_url`: http://localhost:8080
- `access_token`: [token dal login]
- `database_id`: ID del database da utilizzare
- `table_name`: Nome della tabella per il dataset
- `timestamp`: {{$timestamp}}

### Autenticazione
Vedi la guida "Postman-Creazione-Grafici.md" per i dettagli del login.

## Creazione Dataset da Tabelle Fisiche

### 1. Ottenere Database Disponibili

**GET** `{{superset_url}}/api/v1/database/`

**Headers:**
```
Authorization: Bearer {{access_token}}
Content-Type: application/json
```

**Response:**
Salva l'`id` del database che vuoi utilizzare.

### 2. Ottenere Tabelle Disponibili

**GET** `{{superset_url}}/api/v1/database/{{database_id}}/table_metadata/`

**Headers:**
```
Authorization: Bearer {{access_token}}
Content-Type: application/json
```

**Response:**
Lista delle tabelle disponibili nel database selezionato.

### 3. Creare Dataset da Tabella Esistente

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
    "table_name": "energy_usage",
    "schema": null,
    "owners": [1]
}
```

**Esempio con Variabili:**
```json
{
    "database": {{database_id}},
    "table_name": "{{table_name}}",
    "schema": null,
    "owners": [1]
}
```

### 4. Ottenere Dettagli Dataset Creato

**GET** `{{superset_url}}/api/v1/dataset/{{dataset_id}}`

**Headers:**
```
Authorization: Bearer {{access_token}}
```

**Response Include:**
- ID dataset
- Nome tabella
- Informazioni database
- Lista colonne con tipi
- Metriche disponibili

## Esempi Dataset per Diverse Tabelle

### Dataset da birth_names

**POST** `{{superset_url}}/api/v1/dataset/`

**Body:**
```json
{
    "database": 1,
    "table_name": "birth_names",
    "schema": null,
    "owners": [1]
}
```

### Dataset da long_lat

**POST** `{{superset_url}}/api/v1/dataset/`

**Body:**
```json
{
    "database": 1,
    "table_name": "long_lat",
    "schema": null,
    "owners": [1]
}
```

### Dataset da energy_usage

**POST** `{{superset_url}}/api/v1/dataset/`

**Body:**
```json
{
    "database": 1,
    "table_name": "energy_usage",
    "schema": null,
    "owners": [1]
}
```

## Test Creazione Grafico con Nuovo Dataset

Dopo aver creato il dataset, testalo creando un grafico:

**POST** `{{superset_url}}/api/v1/chart/`

**Headers:**
```
Authorization: Bearer {{access_token}}
Content-Type: application/json
```

**Body:**
```json
{
    "datasource_id": "{{dataset_id}}",
    "datasource_type": "table",
    "slice_name": "Test Chart - Dataset {{dataset_id}} - {{timestamp}}",
    "viz_type": "table",
    "params": "{\"datasource\":{\"id\":{{dataset_id}},\"type\":\"table\"},\"viz_type\":\"table\",\"all_columns\":[\"[prima_colonna]\"],\"row_limit\":10}"
}
```

## Configurazioni per Diversi Database

### SQLite (Locale)
```json
{
    "database": 1,
    "table_name": "nome_tabella",
    "schema": null,
    "owners": [1]
}
```

### PostgreSQL
```json
{
    "database": 2,
    "table_name": "nome_tabella",
    "schema": "public",
    "owners": [1]
}
```

### Dremio
```json
{
    "database": 3,
    "table_name": "mongo.collezione_nome",
    "schema": null,
    "owners": [1]
}
```

## Pre-request Script per Auto-Discovery

```javascript
// Ottieni primo database disponibile
pm.sendRequest({
    url: pm.environment.get("superset_url") + "/api/v1/database/",
    method: 'GET',
    header: {
        'Authorization': 'Bearer ' + pm.environment.get("access_token")
    }
}, function (err, response) {
    if (!err && response.code === 200) {
        var databases = response.json().result;
        if (databases.length > 0) {
            pm.environment.set("database_id", databases[0].id);
            pm.environment.set("database_name", databases[0].database_name);
            console.log("Database selezionato: " + databases[0].database_name + " (ID: " + databases[0].id + ")");
        }
    }
});

// Ottieni tabelle disponibili
setTimeout(function() {
    pm.sendRequest({
        url: pm.environment.get("superset_url") + "/api/v1/database/" + pm.environment.get("database_id") + "/table_metadata/",
        method: 'GET',
        header: {
            'Authorization': 'Bearer ' + pm.environment.get("access_token")
        }
    }, function (err, response) {
        if (!err && response.code === 200) {
            var tables = response.json().result;
            if (tables.length > 0) {
                pm.environment.set("table_name", tables[0]);
                console.log("Tabella selezionata: " + tables[0]);
            }
        }
    });
}, 1000);
```

## Tests Script

```javascript
// Salva ID dataset creato
if (pm.response.code === 201) {
    var responseJson = pm.response.json();
    pm.environment.set("dataset_id", responseJson.id);
    console.log("Dataset creato con ID: " + responseJson.id);
}

// Verifica creazione
pm.test("Dataset creato con successo", function () {
    pm.response.to.have.status(201);
    pm.expect(pm.response.json().id).to.be.a('number');
});
```

## Gestione Errori Comuni

### Tabella Non Trovata (404)
```json
{
    "message": "Table 'nome_tabella' not found"
}
```
**Soluzione**: Verifica che la tabella esista e sia accessibile.

### Database Non Valido (400)
```json
{
    "message": "Invalid database ID"
}
```
**Soluzione**: Controlla che l'ID database sia corretto.

### Dataset Già Esistente (409)
```json
{
    "message": "Dataset already exists"
}
```
**Soluzione**: Usa un nome diverso o aggiorna il dataset esistente.

## Workflow Collection Runner

1. **Login**: Ottieni access_token
2. **Get Databases**: Lista database disponibili
3. **Get Tables**: Lista tabelle per database selezionato
4. **Create Dataset**: Crea dataset da tabella
5. **Get Dataset Details**: Verifica dettagli dataset
6. **Create Test Chart**: Testa dataset con grafico semplice

## Parametri Avanzati

### Con Schema Specifico
```json
{
    "database": 2,
    "table_name": "customers",
    "schema": "sales",
    "owners": [1]
}
```

### Con Configurazione Custom
```json
{
    "database": 1,
    "table_name": "my_table",
    "schema": null,
    "owners": [1],
    "description": "Dataset per analisi vendite",
    "external_url": "https://docs.company.com/dataset_info"
}
```

## Note Importanti

1. **Owners**: L'array `owners` deve contenere ID utenti validi
2. **Schema**: Usa `null` per database che non supportano schemi (SQLite)
3. **Permessi**: Assicurati di avere permessi di lettura sulla tabella
4. **Cache**: I metadati delle colonne potrebbero essere cached
5. **Sync**: Usa la funzione "Sync columns from source" se la struttura tabella cambia