# 🗄️ Riferimento Tipi di Datasource Superset

## 🎯 Obiettivo
Documentazione completa sui diversi tipi di datasource disponibili in Superset v6 per la creazione di chart tramite API REST, con esempi pratici e casi d'uso specifici.

---

## 📑 Indice

- [🔍 Panoramica Generale](#-panoramica-generale)
- [📊 Datasource Types Disponibili](#-datasource-types-disponibili)
  - [1. table - Tabelle Database](#1-table---tabelle-database)
  - [2. query - Query SQL Lab](#2-query---query-sql-lab)
  - [3. dataset - Dataset Virtuali](#3-dataset---dataset-virtuali)
  - [4. druid - Apache Druid](#4-druid---apache-druid)
  - [5. sl_table - Semantic Layer](#5-sl_table---semantic-layer)
- [🎯 Quando Usare Ogni Tipo](#-quando-usare-ogni-tipo)
- [⚠️ Note Tecniche e Limitazioni](#️-note-tecniche-e-limitazioni)

---

## 🔍 Panoramica Generale

Il parametro `datasource_type` in Superset definisce il tipo di sorgente dati su cui si basa il chart. Ogni tipo ha caratteristiche specifiche, strutture dati diverse e casi d'uso ottimali.

> ⚠️ **IMPORTANTE - Confusione Terminologica**: 
> Nell'interfaccia UI di Superset, tutto viene chiamato "Dataset", ma nell'API ci sono tipi specifici:
> - **Physical Dataset** (UI) = `"table"` (API)
> - **Virtual Dataset** (UI) = `"dataset"` (API)

**Sintassi generale:**
```json
{
  "datasource_id": NUMERO_ID,
  "datasource_type": "TIPO_DATASOURCE",
  "slice_name": "Nome Chart",
  "viz_type": "TIPO_VISUALIZZAZIONE",
  "params": "CONFIGURAZIONE_JSON"
}
```

## 🔄 **Mappatura UI → API**

| Cosa vedi nell'UI Superset | datasource_type da usare nell'API | Esempio |
|----------------------------|-------------------------------------|---------|
| **Physical Dataset** | `"table"` | `users_channels`, `covid_vaccines` |
| **Virtual Dataset** | `"dataset"` | `hierarchical_dataset`, `project_management` |
| **SQL Lab Query** (salvata) | `"query"` | Query personalizzate salvate |
| **Druid Datasource** | `"druid"` | Sorgenti Apache Druid |

---

## 📊 Datasource Types Disponibili

### 1. **table** - Tabelle Database (Physical Datasets)

**Descrizione:** Tabelle fisiche o viste nel database collegato a Superset. Nell'UI Superset appaiono come "Physical Dataset".

**Come riconoscerle nell'UI:**
- Etichetta: **"Physical"** nella lista Datasets
- Esempi dal tuo Superset: `users_channels`, `covid_vaccines`, `unicode_test`, `video_game_sales`

**⚠️ IMPORTANTE - Architetture Multi-Layer:**
Anche con architetture complesse (Database → Dremio → Superset), i dataset rimangono "Physical" se:
- Superset si connette direttamente a tabelle/viste di Dremio
- Non c'è SQL personalizzato aggiuntivo in Superset
- Il dataset rappresenta direttamente una risorsa di Dremio

**Caratteristiche:**
- Sorgente dati più comune e stabile
- Accesso diretto alle tabelle del database (o viste Dremio)
- Performance ottimali per dataset strutturati
- Supporto completo per tutti i tipi di chart

**Struttura datasource nei params:**
```json
"datasource": {"id": NUMERO_ID, "type": "table"}
```

**Esempio pratico (Table Chart):**
```json
{
  "datasource_id": 17,
  "datasource_type": "table",
  "slice_name": "Vendite per Regione",
  "viz_type": "table",
  "params": "{\"datasource\":{\"id\":17,\"type\":\"table\"},\"viz_type\":\"table\",\"all_columns\":[\"regione\",\"vendite\",\"data\"],\"row_limit\":100,\"adhoc_filters\":[]}"
}
```

**Esempio pratico (Bar Chart):**
```json
{
  "datasource_id": 9,
  "datasource_type": "table", 
  "slice_name": "Trend Vendite Mensili",
  "viz_type": "echarts_timeseries_bar",
  "params": "{\"datasource\":{\"id\":9,\"type\":\"table\"},\"viz_type\":\"echarts_timeseries_bar\",\"x_axis\":\"data_ordine\",\"metrics\":[\"count\"],\"time_grain_sqla\":\"P1M\"}"
}
```

**Casi d'uso ideali:**
- Report operativi su dati transazionali
- Dashboard aziendali standard
- Analisi su tabelle di fatto e dimensioni
- Tutti i tipi di chart documentati nella guida principale

---

### 2. **query** - Query SQL Lab

**Descrizione:** Query SQL personalizzate salvate tramite SQL Lab di Superset.

**Caratteristiche:**
- Flessibilità massima nella definizione dei dati
- Possibilità di utilizzare JOIN complessi e logiche custom
- Ideale per analisi ad-hoc e calcoli specifici
- Richiede competenze SQL avanzate

**Struttura datasource nei params:**
```json
"datasource": {"id": NUMERO_ID, "type": "query"}
```

**Prerequisiti:**
1. Creare e salvare una query in SQL Lab
2. Ottenere l'ID della query salvata
3. Utilizzare questo ID come `datasource_id`

**Esempio di query SQL Lab (prerequisito):**
```sql
-- Query salvata in SQL Lab con ID 45
SELECT 
    DATE_TRUNC('month', order_date) as mese,
    product_category as categoria,
    SUM(revenue) as ricavi_totali,
    COUNT(*) as numero_ordini,
    AVG(revenue) as ricavo_medio
FROM orders o
JOIN products p ON o.product_id = p.id
WHERE order_date >= '2024-01-01'
GROUP BY DATE_TRUNC('month', order_date), product_category
ORDER BY mese DESC, ricavi_totali DESC
```

**Esempio pratico (Chart basato su Query):**
```json
{
  "datasource_id": 45,
  "datasource_type": "query",
  "slice_name": "Analisi Ricavi per Categoria",
  "viz_type": "echarts_timeseries_line",
  "params": "{\"datasource\":{\"id\":45,\"type\":\"query\"},\"viz_type\":\"echarts_timeseries_line\",\"x_axis\":\"mese\",\"metrics\":[\"ricavi_totali\"],\"groupby\":[\"categoria\"]}"
}
```

**Esempio pratico (Pivot Table da Query):**
```json
{
  "datasource_id": 45,
  "datasource_type": "query",
  "slice_name": "Matrice Ricavi Mese-Categoria", 
  "viz_type": "pivot_table_v2",
  "params": "{\"datasource\":{\"id\":45,\"type\":\"query\"},\"viz_type\":\"pivot_table_v2\",\"groupbyRows\":[\"mese\"],\"groupbyColumns\":[\"categoria\"],\"metrics\":[\"ricavi_totali\"],\"metricsLayout\":\"COLUMNS\"}"
}
```

**Casi d'uso ideali:**
- Analisi complesse che richiedono JOIN multipli
- Calcoli business specifici non disponibili come metriche standard
- Report che combinano dati da più tabelle
- KPI personalizzati con logiche di calcolo complesse

---

### 3. **dataset** - Dataset Virtuali (Virtual Datasets)

**Descrizione:** Dataset virtuali creati tramite l'interfaccia di Superset, basati su query SQL ma con metadata aggiuntivi. Nell'UI Superset appaiono come "Virtual Dataset".

**Come riconoscerle nell'UI:**
- Etichetta: **"Virtual"** nella lista Datasets  
- Esempi dal tuo Superset: `hierarchical_dataset`, `project_management`, `users_channels-uzooNNtSRO`

**Caratteristiche:**
- Combinazione di flessibilità SQL e struttura dataset
- Metadata arricchiti (descrizioni colonne, tipi dati, ecc.)
- Riutilizzabilità across multiple chart
- Gestione centralizzata delle definizioni business

**Struttura datasource nei params:**
```json
"datasource": {"id": NUMERO_ID, "type": "dataset"}
```

**Prerequisiti:**
1. Creare un dataset virtuale tramite UI Superset
2. Definire le colonne e metriche del dataset
3. Salvare e ottenere l'ID del dataset

**Esempio di definizione dataset virtuale (prerequisito):**
```sql
-- SQL del dataset virtuale "vendite_aggregate" (ID 78)
SELECT 
    v.data_vendita,
    v.regione,
    v.canale_vendita,
    p.categoria_prodotto,
    p.subcategoria_prodotto,
    SUM(v.importo) as vendite_totali,
    COUNT(v.id) as numero_transazioni,
    AVG(v.importo) as scontrino_medio
FROM vendite v
JOIN prodotti p ON v.prodotto_id = p.id
WHERE v.data_vendita >= CURRENT_DATE - INTERVAL '2 years'
GROUP BY v.data_vendita, v.regione, v.canale_vendita, p.categoria_prodotto, p.subcategoria_prodotto
```

**Esempio pratico (Heat Map da Dataset Virtuale):**
```json
{
  "datasource_id": 78,
  "datasource_type": "dataset",
  "slice_name": "Mappa Calore Vendite Regione-Categoria",
  "viz_type": "heatmap_v2", 
  "params": "{\"datasource\":{\"id\":78,\"type\":\"dataset\"},\"viz_type\":\"heatmap_v2\",\"x_axis\":\"regione\",\"groupby\":\"categoria_prodotto\",\"metric\":\"vendite_totali\"}"
}
```

**Esempio pratico (Big Number da Dataset):**
```json
{
  "datasource_id": 78,
  "datasource_type": "dataset",
  "slice_name": "KPI Vendite Totali",
  "viz_type": "big_number_total",
  "params": "{\"datasource\":{\"id\":78,\"type\":\"dataset\"},\"viz_type\":\"big_number_total\",\"metric\":\"vendite_totali\",\"adhoc_filters\":[{\"clause\":\"WHERE\",\"subject\":\"canale_vendita\",\"operator\":\"==\",\"comparator\":\"Online\",\"expressionType\":\"SIMPLE\"}]}"
}
```

**Casi d'uso ideali:**
- Standardizzazione di definizioni business across team
- Dataset condivisi per multiple dashboard
- Analisi che richiedono metadata ricchi
- Governance centralizzata dei dati analitici

---

### 4. **druid** - Apache Druid

**Descrizione:** Datasource collegati ad Apache Druid per analisi time-series ad alte performance.

**Caratteristiche:**
- Ottimizzato per analisi time-series
- Performance eccellenti su grandi volumi di dati
- Aggregazioni pre-calcolate (rollup)
- Ideale per real-time analytics

**Struttura datasource nei params:**
```json
"datasource": {"id": "DRUID_DATASOURCE_NAME", "type": "druid"}
```

**Prerequisiti:**
1. Configurare connessione Druid in Superset
2. Avere datasource Druid disponibili
3. Configurare le dimensioni e metriche Druid

**Esempio pratico (Time Series da Druid):**
```json
{
  "datasource_id": "web_analytics_hourly",
  "datasource_type": "druid",
  "slice_name": "Traffico Web Orario",
  "viz_type": "echarts_timeseries_line",
  "params": "{\"datasource\":{\"id\":\"web_analytics_hourly\",\"type\":\"druid\"},\"viz_type\":\"echarts_timeseries_line\",\"granularity_sqla\":\"__time\",\"metrics\":[\"page_views\",\"unique_visitors\"],\"time_grain_sqla\":\"PT1H\"}"
}
```

**Esempio pratico (Gauge Chart da Druid):**
```json
{
  "datasource_id": "iot_sensors_realtime", 
  "datasource_type": "druid",
  "slice_name": "Temperatura Media Sensori",
  "viz_type": "gauge_chart",
  "params": "{\"datasource\":{\"id\":\"iot_sensors_realtime\",\"type\":\"druid\"},\"viz_type\":\"gauge_chart\",\"metric\":\"avg_temperature\",\"groupby\":[\"sensor_location\"]}"
}
```

**Casi d'uso ideali:**
- Monitoring real-time di applicazioni
- Analisi time-series su dati IoT
- Dashboard operative con aggiornamenti frequenti
- Analytics su stream di eventi ad alto volume

---

### 5. **sl_table** - Semantic Layer

**Descrizione:** Tabelle del Semantic Layer per enterprise analytics (Superset v3.0+).

**Caratteristiche:**
- Semantic layer unificato per analytics enterprise
- Definizioni business centralizzate e governate
- Lineage dei dati e metadata avanzati
- Integrazione con strumenti di data governance

**Struttura datasource nei params:**
```json
"datasource": {"id": NUMERO_ID, "type": "sl_table"}
```

**Prerequisiti:**
1. Superset versione 3.0+ con Semantic Layer abilitato
2. Configurazione del semantic layer
3. Definizione delle entità semantic layer

**Esempio teorico (funzionalità enterprise):**
```json
{
  "datasource_id": 12,
  "datasource_type": "sl_table",
  "slice_name": "Metriche Business Governate",
  "viz_type": "table",
  "params": "{\"datasource\":{\"id\":12,\"type\":\"sl_table\"},\"viz_type\":\"table\",\"all_columns\":[\"business_metric\",\"certified_value\",\"governance_status\"]}"
}
```

**Casi d'uso ideali:**
- Enterprise analytics con governance rigorosa
- Standardizzazione di metriche business critical
- Compliance e audit trail dei dati
- Integrazione con moderne data platform

---

## 🎯 Quando Usare Ogni Tipo

### � **Come Determinare il Tipo Corretto per i Tuoi Dataset**

Per i tuoi dataset specifici, ecco come determinare il `datasource_type` corretto:

#### **Step 1: Controlla l'UI Superset**
1. Vai a **Data > Datasets**
2. Trova il tuo dataset nella lista
3. Guarda la colonna **"Type"**:
   - Se dice **"Physical"** → usa `"table"`
   - Se dice **"Virtual"** → usa `"dataset"`

#### **Step 2: Esempi dai Tuoi Dataset**

**Physical Datasets (usa `"table"`):**
```json
// Per users_channels (ID esempio: 17)
{
  "datasource_id": 17,
  "datasource_type": "table",
  "params": "{\"datasource\":{\"id\":17,\"type\":\"table\"},...}"
}

// Per covid_vaccines (ID esempio: 18)
{
  "datasource_id": 18,
  "datasource_type": "table", 
  "params": "{\"datasource\":{\"id\":18,\"type\":\"table\"},...}"
}
```

**Virtual Datasets (usa `"dataset"`):**
```json
// Per hierarchical_dataset (ID esempio: 25)
{
  "datasource_id": 25,
  "datasource_type": "dataset",
  "params": "{\"datasource\":{\"id\":25,\"type\":\"dataset\"},...}"
}

// Per project_management (ID esempio: 26)
{
  "datasource_id": 26,
  "datasource_type": "dataset",
  "params": "{\"datasource\":{\"id\":26,\"type\":\"dataset\"},...}"
}
```

#### **Step 3: Trova l'ID del Dataset**
1. Nell'UI Superset, clicca sul dataset
2. Guarda l'URL: `.../superset/explore/?datasource=ID__table` 
3. L'ID è il numero prima di `__table` o `__dataset`

### 🏗️ **Architetture Multi-Layer (es. Database → Dremio → Superset)**

Anche con architetture complesse, il tipo di datasource dipende da **come Superset vede i dati**:

#### **Scenario 1: Connessione Diretta Dremio → Superset**
```
Database → Dremio View → Superset Physical Dataset
```
- **Tipo UI**: Physical
- **API Type**: `"table"`
- **Esempio**: Dataset che punta direttamente a una vista Dremio

#### **Scenario 2: SQL Personalizzato in Superset**
```
Database → Dremio → Custom SQL in Superset → Virtual Dataset  
```
- **Tipo UI**: Virtual
- **API Type**: `"dataset"`
- **Esempio**: Dataset con SQL personalizzato che interroga Dremio

#### **Esempio Pratico Dremio:**

**Physical Dataset (Dremio View):**
```json
// Dataset "sales_summary" che punta a vista Dremio
{
  "datasource_id": 30,
  "datasource_type": "table",  // Anche se dietro c'è Dremio!
  "params": "{\"datasource\":{\"id\":30,\"type\":\"table\"},...}"
}
```

**Virtual Dataset (SQL su Dremio):**
```json
// Dataset con SQL: "SELECT * FROM dremio_space.sales WHERE region='EU'"
{
  "datasource_id": 31,
  "datasource_type": "dataset",  // SQL personalizzato
  "params": "{\"datasource\":{\"id\":31,\"type\":\"dataset\"},...}"
}
```

### �📊 **Matrice Decisionale**

| Scenario | Datasource Type | Motivazione |
|----------|----------------|-------------|
| Dashboard operativa standard | `table` | Performance e semplicità |
| Analisi complessa multi-tabella | `query` | Flessibilità SQL |
| Metriche business standardizzate | `dataset` | Riutilizzabilità e governance |
| Real-time monitoring | `druid` | Performance time-series |
| Enterprise con governance | `sl_table` | Compliance e standardizzazione |

### 🔄 **Workflow Consigliato**

1. **Prototipazione**: Inizia con `table` per semplicità
2. **Complessità**: Passa a `query` per logiche custom
3. **Standardizzazione**: Converti in `dataset` per riuso
4. **Scale**: Considera `druid` per grandi volumi
5. **Governance**: Migra a `sl_table` per enterprise

---

## ⚠️ Note Tecniche e Limitazioni

### **Compatibilità Chart Types**

| Datasource Type | Compatibilità Chart | Note |
|-----------------|---------------------|------|
| `table` | ✅ Tutti i tipi | Supporto completo |
| `query` | ✅ Tutti i tipi | Dipende dalla query SQL |
| `dataset` | ✅ Tutti i tipi | Basato su definizione dataset |
| `druid` | ⚠️ Limitata | Ottimizzato per time-series |
| `sl_table` | ✅ Tutti i tipi | Funzionalità enterprise |

### **Performance Considerations**

- **`table`**: Performance dipendenti da indici database
- **`query`**: Performance dipendenti dalla complessità SQL
- **`dataset`**: Overhead aggiuntivo per metadata
- **`druid`**: Performance eccellenti per time-series
- **`sl_table`**: Overhead semantic layer

### **Errori Comuni**

❌ **Errore**: ID datasource non esistente
```json
{"datasource_id": 999, "datasource_type": "table"}
```

❌ **Errore**: Tipo incompatibile con ID
```json
{"datasource_id": 17, "datasource_type": "druid"}  // ID 17 è una table
```

❌ **Errore**: Mismatch params vs datasource_type
```json
{
  "datasource_type": "query",
  "params": "{\"datasource\":{\"id\":17,\"type\":\"table\"}}"  // Incoerente!
}
```

### **Best Practices**

✅ **Verifica esistenza datasource** prima di creare chart
✅ **Mantieni coerenza** tra `datasource_type` e `params.datasource.type`
✅ **Testa performance** per datasource complessi
✅ **Documenta logiche custom** per query e dataset virtuali
✅ **Usa naming convention** consistent per tutti i tipi

---

## 🔗 Riferimenti

- [Documentazione Chart Creation](./API_Chart_Creation_Reference.md)
- [Guida Streamlined](./Riferimento%20API%20superset%20v6.md)
- [Superset Documentation](https://superset.apache.org/docs/)
- [Apache Druid Integration](https://superset.apache.org/docs/databases/druid)

---

> 📝 **Nota**: Questa documentazione è basata su Superset v6. Alcune funzionalità potrebbero variare in versioni diverse. Per implementazioni enterprise, consultare la documentazione ufficiale per funzionalità specifiche del semantic layer.