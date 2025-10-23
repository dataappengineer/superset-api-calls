# Guide Postman per API Superset

Questa cartella contiene guide complete per utilizzare Postman con le API di Apache Superset, equivalenti ai script PowerShell presenti nella cartella `PowershellApiCalls`.

## Indice Guide

### 1. [Postman-Creazione-Grafici.md](./Postman-Creazione-Grafici.md)
Equivalente a: `Test-All-Charts-Clean.ps1`

**Contenuto:**
- Autenticazione API
- Creazione di 20+ tipi di grafici validati
- Configurazioni per tabelle, torte, linee, barre, heatmap
- Esempi Big Number, Gauge, Area, Waterfall
- Configurazioni complete con parametri JSON

**Grafici Inclusi:**
- Tabelle (Raw e Aggregate)
- Pivot Tables
- Pie Charts, Line Charts, Bar Charts
- Heatmaps, Scatter Plots
- Big Numbers, Gauge Charts
- E molti altri...

### 2. [Postman-Clonazione-Dashboard.md](./Postman-Clonazione-Dashboard.md)
Equivalente a: `Test-Dashboard-Clone.ps1`

**Contenuto:**
- Clonazione completa di dashboard esistenti
- Gestione position_json e layout
- Associazione grafici alla nuova dashboard
- Script Pre-request per automazione
- Workflow completo con Collection Runner

**Processo:**
1. Lettura dashboard sorgente
2. Creazione dashboard base
3. Aggiornamento con struttura completa
4. Associazione grafici esistenti

### 3. [Postman-Creazione-Dataset.md](./Postman-Creazione-Dataset.md)
Equivalente a: `Test-Dataset-Creation.ps1`

**Contenuto:**
- Creazione dataset da tabelle fisiche
- Discovery automatico database e tabelle
- Configurazioni per SQLite, PostgreSQL, Dremio
- Test immediato con creazione grafici
- Gestione errori e troubleshooting

**Database Supportati:**
- SQLite (locale)
- PostgreSQL
- MySQL
- Dremio
- Altri database SQL

### 4. [Postman-Dataset-Virtuali.md](./Postman-Dataset-Virtuali.md)
Equivalente a: `Test-Virtual-Dataset-Creation.ps1`

**Contenuto:**
- Creazione dataset con SQL personalizzato
- Query complesse con JOIN e aggregazioni
- Esempi per analytics e KPI
- Test in SQL Lab prima della creazione
- Dataset per time series e dashboard

**Tipi Query:**
- Query semplici di test
- Join complessi
- Aggregazioni e calcoli
- Time series
- KPI e metriche business

## Setup Iniziale Postman

### 1. Installazione
- Scarica Postman Desktop o usa Postman Web
- Crea nuovo Workspace per Superset

### 2. Configurazione Environment
Crea un Environment con queste variabili:

```
superset_url: http://localhost:8080
username: admin
password: admin
access_token: [verrà popolato automaticamente]
timestamp: {{$timestamp}}
database_id: [da scoprire con API]
dataset_id: [da popolare durante i test]
dashboard_id: [da popolare durante i test]
```

### 3. Collection Setup
- Importa o crea Collection "Superset API Tests"
- Aggiungi cartelle per ogni tipo di operazione
- Configura Tests e Pre-request Scripts

## Workflow Generale

### 1. Autenticazione
```
POST /api/v1/security/login
→ Salva access_token in environment
```

### 2. Discovery
```
GET /api/v1/database/
GET /api/v1/dataset/
GET /api/v1/dashboard/
→ Esplora risorse disponibili
```

### 3. Creazione
```
POST /api/v1/dataset/    (dataset)
POST /api/v1/chart/      (grafici)
POST /api/v1/dashboard/  (dashboard)
→ Crea nuove risorse
```

### 4. Verifica
```
GET /api/v1/[risorsa]/[id]
→ Verifica creazione corretta
```

## Script Utili

### Pre-request Script Globale
```javascript
// Auto-login se token scaduto
if (!pm.environment.get("access_token")) {
    pm.sendRequest({
        url: pm.environment.get("superset_url") + "/api/v1/security/login",
        method: 'POST',
        header: {'Content-Type': 'application/json'},
        body: {
            mode: 'raw',
            raw: JSON.stringify({
                username: pm.environment.get("username"),
                password: pm.environment.get("password"),
                provider: "db",
                refresh: true
            })
        }
    }, function (err, response) {
        if (!err && response.code === 200) {
            pm.environment.set("access_token", response.json().access_token);
        }
    });
}
```

### Tests Script Globale
```javascript
// Verifica autenticazione
pm.test("Request authenticated", function () {
    pm.expect(pm.response.code).to.not.equal(401);
});

// Log response per debug
if (pm.response.code >= 400) {
    console.log("Error response:", pm.response.text());
}
```

## Collection Runner

Per eseguire test batch:

1. **Setup Collection**: Organizza requests in sequenza logica
2. **Configure Data**: Usa CSV o JSON per dati test multipli
3. **Run Collection**: Esegui tutti i test in sequenza
4. **Review Results**: Analizza successi e fallimenti

### Esempio Sequenza Test
```
1. Login
2. Get Databases
3. Create Dataset
4. Create Chart
5. Create Dashboard
6. Associate Chart to Dashboard
7. Verify Complete Workflow
```

## Best Practices

### Nomi Univoci
- Usa `{{$timestamp}}` per evitare conflitti
- Includi tipo risorsa nel nome
- Aggiungi prefisso "TEST-" per test temporanei

### Gestione Errori
- Sempre verificare status codes
- Loggare errori per debug
- Implementare retry per operazioni flaky

### Performance
- Aggiungi delay tra requests se necessario
- Non creare troppe risorse in parallelo
- Cleanup risorse test dopo uso

### Sicurezza
- Non hardcodare credenziali in requests
- Usa environment variables
- Limita permessi account test

## Troubleshooting

### Errori Comuni
- **401 Unauthorized**: Token scaduto, ri-autentica
- **403 Forbidden**: Permessi insufficienti
- **404 Not Found**: Risorsa inesistente
- **422 Validation Error**: Dati request non validi
- **500 Server Error**: Problema server/configurazione

### Debug
- Attiva Postman Console per log dettagliati
- Usa Network tab per vedere request/response raw
- Verifica environment variables
- Controlla sintassi JSON nei body

## Risorse Aggiuntive

- [Documentazione API Superset](https://superset.apache.org/docs/api)
- [Postman Documentation](https://learning.postman.com/)
- [Superset GitHub](https://github.com/apache/superset)

## Contributi

Per aggiungere nuovi esempi o migliorare le guide esistenti:
1. Fork il repository
2. Crea nuovi file .md nella cartella PostmanGuides
3. Aggiorna questo README.md
4. Crea Pull Request con descrizione dettagliata