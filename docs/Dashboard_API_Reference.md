# 📊 Riferimento API per Creazione Dashboard Superset

## 🎯 Obiettivo
Documentazione dettagliata dei parametri API e esempi pratici per la creazione e clonazione di dashboard in Superset tramite chiamate REST.

> 📋 **Stato Validazione**: **Dashboard API completamente validata e testata** con Superset v6
> - ✅ GET Dashboard Details (lettura completa struttura)
> - ✅ POST Dashboard Creation (creazione nuova dashboard)  
> - ✅ PUT Dashboard Update (aggiornamento struttura e layout)
> - ✅ Dashboard Cloning (clonazione completa con chart)

---

## 📑 Indice

- [🔑 Autenticazione](#-autenticazione)
- [🔍 Lettura Dashboard Esistente](#-lettura-dashboard-esistente)
- [📋 Creazione Dashboard](#-creazione-dashboard)
- [📊 Clonazione Dashboard](#-clonazione-dashboard)
- [🏗️ Struttura Position JSON](#️-struttura-position-json)
- [🔧 Associazione Chart alla Dashboard](#-associazione-chart-alla-dashboard)

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

## 🔍 Lettura Dashboard Esistente

### Endpoint per Dettagli Dashboard

**Endpoint:**  
`GET /api/v1/dashboard/{dashboard_id}`

**Parametri:**
- `dashboard_id`: ID numerico della dashboard (**obbligatorio**)

**Risposta Completa:**
La risposta contiene tutti i dettagli necessari per clonare o modificare una dashboard:

```json
{
  "result": {
    "id": 11,
    "dashboard_title": "Slack Dashboard",
    "slug": "slack-dashboard",
    "published": true,
    "position_json": "{...struttura layout completa...}",
    "json_metadata": "{...metadati e configurazioni...}",
    "css": "...stili personalizzati...",
    "charts": [
      {
        "id": 77,
        "slice_name": "Weekly Threads"
      },
      ...
    ]
  }
}
```

**Parametri chiave nella risposta:**
- `position_json`: **Struttura completa del layout** (JSON string)
- `json_metadata`: Metadati dashboard (colori, filtri, etc.)
- `css`: Stili CSS personalizzati
- `charts`: Array con tutti i chart presenti
- `dashboard_title`: Nome della dashboard
- `published`: Stato di pubblicazione

---

## 📋 Creazione Dashboard

### Metodo 1: Creazione Minima

**Endpoint:**  
`POST /api/v1/dashboard/`

**Parametri indispensabili:**
- `dashboard_title`: Nome della dashboard (**obbligatorio**)
- `published`: Stato pubblicazione (true/false) (**obbligatorio**)

**Esempio creazione minima:**
```json
{
  "dashboard_title": "Mia Dashboard Test",
  "published": false
}
```

### Metodo 2: Creazione Completa

**Parametri opzionali aggiuntivi:**
- `position_json`: Struttura layout (JSON string)
- `json_metadata`: Metadati e configurazioni
- `css`: Stili CSS personalizzati
- `slug`: URL slug (se vuoto, auto-generato)

**Esempio creazione completa:**
```json
{
  "dashboard_title": "Dashboard Completa",
  "published": false,
  "position_json": "{\"ROOT_ID\":{\"children\":[\"GRID_ID\"],\"id\":\"ROOT_ID\",\"type\":\"ROOT\"},...}",
  "json_metadata": "{\"color_scheme\":\"supersetColors\",...}",
  "css": ".dashboard-component { margin: 10px; }"
}
```

---

## 📊 Clonazione Dashboard

### Processo Completo di Clonazione

**Step 1: Lettura Dashboard Originale**
```powershell
$sourceDashboard = Invoke-RestMethod -Uri "$SupersetUrl/api/v1/dashboard/$SourceDashboardId" -Headers $headers
```

**Step 2: Creazione Dashboard Vuota**
```json
{
  "dashboard_title": "CLONED - Dashboard Originale",
  "published": false
}
```

**Step 3: Aggiornamento con Struttura Completa**
```json
{
  "position_json": "...position_json della dashboard originale...",
  "json_metadata": "...json_metadata della dashboard originale...", 
  "css": "...css della dashboard originale..."
}
```

**Step 4: Associazione Chart**
Per ogni chart nella dashboard originale, aggiornare la sua lista di dashboard:
```json
{
  "dashboards": [1, 2, 12]  // IDs delle dashboard che includono questo chart
}
```

---

## 🏗️ Struttura Position JSON

### Comprensione ROOT_ID

**ROOT_ID è una chiave fissa** nella struttura `position_json` che rappresenta il contenitore radice dell'intera dashboard.

**Struttura gerarchica tipica:**
```
ROOT_ID (tipo: ROOT)
  └── GRID_ID (tipo: GRID)
      ├── ROW-abc123 (tipo: ROW)
      │   ├── CHART-def456 (tipo: CHART)
      │   └── CHART-ghi789 (tipo: CHART)
      ├── ROW-jkl012 (tipo: ROW)
      │   └── COLUMN-mno345 (tipo: COLUMN)
      │       ├── MARKDOWN-pqr678 (tipo: MARKDOWN)
      │       └── CHART-stu901 (tipo: CHART)
      └── ROW-vwx234 (tipo: ROW)
          └── CHART-yza567 (tipo: CHART)
```

### Tipi di Componenti

**ROOT_ID**
- **Tipo**: `ROOT`
- **Scopo**: Contenitore principale
- **Children**: Sempre `["GRID_ID"]`

**GRID_ID**
- **Tipo**: `GRID`
- **Scopo**: Griglia principale del layout
- **Children**: Array di ROW-* IDs

**ROW-{randomId}**
- **Tipo**: `ROW`
- **Scopo**: Riga orizzontale nel layout
- **Children**: Array di CHART-*, COLUMN-*, MARKDOWN-* IDs

**CHART-{randomId}**
- **Tipo**: `CHART`
- **Scopo**: Container per un chart
- **Meta**: Contiene `chartId`, `height`, `width`, `sliceName`

**COLUMN-{randomId}**
- **Tipo**: `COLUMN`
- **Scopo**: Colonna per raggruppare elementi verticalmente
- **Children**: Array di elementi figli

**MARKDOWN-{randomId}**
- **Tipo**: `MARKDOWN`
- **Scopo**: Elemento di testo/HTML
- **Meta**: Contiene `code`, `height`, `width`

### Esempio Position JSON Completo

```json
{
  "ROOT_ID": {
    "children": ["GRID_ID"],
    "id": "ROOT_ID",
    "type": "ROOT"
  },
  "GRID_ID": {
    "children": ["ROW-abc123"],
    "id": "GRID_ID",
    "parents": ["ROOT_ID"],
    "type": "GRID"
  },
  "ROW-abc123": {
    "children": ["CHART-def456"],
    "id": "ROW-abc123",
    "meta": {"background": "BACKGROUND_TRANSPARENT"},
    "parents": ["ROOT_ID", "GRID_ID"],
    "type": "ROW"
  },
  "CHART-def456": {
    "children": [],
    "id": "CHART-def456",
    "meta": {
      "chartId": 77,
      "height": 50,
      "sliceName": "My Chart",
      "width": 6
    },
    "parents": ["ROOT_ID", "GRID_ID", "ROW-abc123"],
    "type": "CHART"
  }
}
```

---

## 🔧 Associazione Chart alla Dashboard

### Aggiungere Chart a Dashboard Esistente

**Endpoint:**  
`PUT /api/v1/chart/{chart_id}`

**Parametri:**
- `dashboards`: Array di dashboard IDs che devono includere questo chart

**Processo:**
1. Ottenere lista dashboard attuali del chart
2. Aggiungere nuovo dashboard ID alla lista
3. Aggiornare il chart con la nuova lista

**Esempio:**
```json
{
  "dashboards": [1, 5, 12]  // Dashboard IDs (1=esistente, 5=esistente, 12=nuova)
}
```

**Codice PowerShell:**
```powershell
# Ottenere chart corrente
$chartData = Invoke-RestMethod -Uri "$SupersetUrl/api/v1/chart/$chartId" -Headers $headers

# Aggiungere nuova dashboard
$currentDashboards = @($chartData.result.dashboards | ForEach-Object { $_.id })
$currentDashboards += $newDashboardId

# Aggiornare chart
$updateData = @{ dashboards = $currentDashboards } | ConvertTo-Json
Invoke-RestMethod -Uri "$SupersetUrl/api/v1/chart/$chartId" -Method PUT -Headers $headers -Body $updateData
```

---

## ⚠️ Note Tecniche Importanti

### Limitazioni API
- **Position JSON**: Deve essere una stringa JSON valida, non un oggetto
- **Slug**: Se vuoto, Superset lo auto-genera
- **Dashboard vuote**: Si possono creare dashboard senza chart, i chart si associano successivamente

### Best Practices
1. **Creare prima dashboard vuota**, poi aggiornare con layout complesso
2. **Validare JSON**: Assicurarsi che position_json sia JSON valido
3. **Gestire errori**: Le API restituiscono 400/422 per dati non validi
4. **Associazione chart**: Sempre aggiornare la lista esistente, non sostituire

### Workflow Consigliato
1. Leggere dashboard originale con `GET /api/v1/dashboard/{id}`
2. Creare dashboard vuota con `POST /api/v1/dashboard/`
3. Aggiornare layout con `PUT /api/v1/dashboard/{id}`
4. Associare chart uno per uno con `PUT /api/v1/chart/{id}`

---

## 🔍 Script di Esempio

### Get-Dashboard-Details.ps1
Script per analizzare struttura dashboard esistente:
```powershell
.\Get-Dashboard-Details.ps1 -DashboardId 11
```

### Test-Dashboard-Clone.ps1  
Script per clonare dashboard completa:
```powershell
.\Test-Dashboard-Clone.ps1
```

**Output esempio:**
```
SUCCESS: Minimal dashboard created with ID: 12
SUCCESS: Dashboard updated with full structure!
Dashboard URL: http://localhost:8080/superset/dashboard/12/
Chart IDs to associate: 77, 78, 79, 80, 81, 82, 83, 84, 85
All charts associated successfully!
```

---

> 📋 **Conclusione**: L'API dashboard di Superset v6 permette clonazione completa e gestione avanzata del layout tramite position_json. ROOT_ID è una chiave fissa della struttura, non un ID variabile.