# Guida Postman - Clonazione Dashboard Superset

Questa guida fornisce esempi di chiamate Postman per clonare dashboard in Apache Superset, equivalente al file `Test-Dashboard-Clone.ps1`.

## Setup Iniziale

### Variabili Postman
Configura queste variabili nella tua collection:
- `superset_url`: http://localhost:8080
- `access_token`: [token dal login]
- `source_dashboard_id`: 11 (ID dashboard da clonare)
- `timestamp`: {{$timestamp}}

### Autenticazione
Vedi la guida "Postman-Creazione-Grafici.md" per i dettagli del login.

## Processo di Clonazione Dashboard

### 1. Ottenere Dettagli Dashboard Sorgente

**GET** `{{superset_url}}/api/v1/dashboard/{{source_dashboard_id}}`

**Headers:**
```
Authorization: Bearer {{access_token}}
Content-Type: application/json
```

**Response:**
Salva i seguenti campi dalla risposta per usarli nella clonazione:
- `dashboard_title`
- `position_json`
- `json_metadata`
- `css`

### 2. Creare Dashboard Base

**POST** `{{superset_url}}/api/v1/dashboard/`

**Headers:**
```
Authorization: Bearer {{access_token}}
Content-Type: application/json
```

**Body:**
```json
{
    "dashboard_title": "CLONATA - [Titolo Dashboard Originale] - {{timestamp}}",
    "published": false
}
```

**Risposta:**
Salva l'`id` della nuova dashboard per i passaggi successivi.

### 3. Aggiornare Dashboard con Struttura Completa

**PUT** `{{superset_url}}/api/v1/dashboard/{{new_dashboard_id}}`

**Headers:**
```
Authorization: Bearer {{access_token}}
Content-Type: application/json
```

**Body:**
```json
{
    "position_json": "[COPIA position_json dalla dashboard sorgente]",
    "json_metadata": "[COPIA json_metadata dalla dashboard sorgente]",
    "css": "[COPIA css dalla dashboard sorgente]"
}
```

### 4. Ottenere Lista Grafici dalla Dashboard Sorgente

Estraendo dal `position_json`, identifica gli ID dei grafici. In alternativa, usa:

**GET** `{{superset_url}}/api/v1/dashboard/{{source_dashboard_id}}/charts`

**Headers:**
```
Authorization: Bearer {{access_token}}
```

### 5. Associare Grafici alla Nuova Dashboard

Per ogni grafico identificato:

**GET** `{{superset_url}}/api/v1/chart/{{chart_id}}`

**Headers:**
```
Authorization: Bearer {{access_token}}
```

Poi aggiornare il grafico aggiungendo la nuova dashboard:

**PUT** `{{superset_url}}/api/v1/chart/{{chart_id}}`

**Headers:**
```
Authorization: Bearer {{access_token}}
Content-Type: application/json
```

**Body:**
```json
{
    "dashboards": [
        "[lista_dashboard_esistenti]",
        "{{new_dashboard_id}}"
    ]
}
```

## Esempio Completo - Script Postman

### Pre-request Script
```javascript
// Ottieni dettagli dashboard sorgente
pm.sendRequest({
    url: pm.environment.get("superset_url") + "/api/v1/dashboard/" + pm.environment.get("source_dashboard_id"),
    method: 'GET',
    header: {
        'Authorization': 'Bearer ' + pm.environment.get("access_token"),
        'Content-Type': 'application/json'
    }
}, function (err, response) {
    if (err) {
        console.log(err);
    } else {
        var sourceData = response.json().result;
        pm.environment.set("source_title", sourceData.dashboard_title);
        pm.environment.set("source_position_json", JSON.stringify(sourceData.position_json));
        pm.environment.set("source_json_metadata", sourceData.json_metadata || "{}");
        pm.environment.set("source_css", sourceData.css || "");
    }
});
```

### Tests Script (per la creazione dashboard)
```javascript
// Salva ID nuova dashboard
if (pm.response.code === 201) {
    var responseJson = pm.response.json();
    pm.environment.set("new_dashboard_id", responseJson.id);
    console.log("Nuova dashboard creata con ID: " + responseJson.id);
}
```

## Workflow Completo con Collection Runner

1. **Step 1**: Login (ottieni token)
2. **Step 2**: Get Dashboard Sorgente (salva dati)
3. **Step 3**: Create Dashboard Base
4. **Step 4**: Update Dashboard con Struttura
5. **Step 5**: Get Charts Lista
6. **Step 6**: Associate Charts (ripeti per ogni grafico)

## Esempio Position JSON

Il `position_json` contiene la struttura layout della dashboard:

```json
{
    "DASHBOARD_VERSION_KEY": "v2",
    "ROOT_ID": {
        "children": ["GRID_ID"],
        "id": "ROOT_ID",
        "type": "ROOT"
    },
    "GRID_ID": {
        "children": ["CHART-1", "CHART-2"],
        "id": "GRID_ID",
        "type": "GRID"
    },
    "CHART-1": {
        "children": [],
        "id": "CHART-1",
        "meta": {
            "chartId": 123,
            "height": 400,
            "width": 6
        },
        "type": "CHART"
    }
}
```

## Verifica Risultato

Dopo la clonazione, verifica la nuova dashboard:

**GET** `{{superset_url}}/api/v1/dashboard/{{new_dashboard_id}}`

**Headers:**
```
Authorization: Bearer {{access_token}}
```

**URL Dashboard UI:**
`{{superset_url}}/superset/dashboard/{{new_dashboard_id}}/`

## Note Importanti

1. **Permessi**: Assicurati di avere i permessi per clonare dashboard
2. **Grafici**: I grafici vengono condivisi, non duplicati
3. **Filtri**: I filtri dashboard vengono copiati nel `json_metadata`
4. **CSS**: Eventuali stili personalizzati vengono mantenuti
5. **Slug**: Viene auto-generato per evitare duplicati

## Gestione Errori

- **403 Forbidden**: Permessi insufficienti
- **404 Not Found**: Dashboard sorgente non trovata
- **422 Unprocessable**: Errore nei dati JSON
- **500 Internal Error**: Problema server (spesso dovuto a position_json malformato)