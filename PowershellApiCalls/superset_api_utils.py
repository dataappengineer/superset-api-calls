import requests
import json
import pandas as pd
from urllib.parse import urlparse, parse_qs

# Use a session to persist cookies and headers across all API calls
session = requests.Session()

# Superset v6 API Configuration (adapted from v4)
def get_api_config():
    """Get Superset v6 API configuration - Updated for localhost:8080"""
    BASE_URL = "http://localhost:8080"  # Updated from 8088 to 8080
    API_BASE = f"{BASE_URL}/api/v1"
    headers = {
        "Content-Type": "application/json",
        "Accept": "application/json"
    }
    return BASE_URL, API_BASE, headers

# Extract dataset id from URL (same as v4)
def extract_dataset_id(url):
    parsed = urlparse(url)
    params = parse_qs(parsed.query)
    return int(params.get('datasource_id', [17])[0])  # Default to dataset 17

# Authentication and CSRF (same as v4 but with v6 URL)
def authenticate_superset(API_BASE, headers, username="admin", password="admin"):
    """Authenticate with Superset v6 - same flow as v4"""
    login_url = f"{API_BASE}/security/login"
    login_data = {
        "username": username,
        "password": password,
        "provider": "db",
        "refresh": True
    }
    print(f"🔐 Autenticazione con {username}...")
    response = session.post(login_url, json=login_data, timeout=10)
    if response.status_code == 200:
        auth_data = response.json()
        access_token = auth_data.get('access_token')
        if access_token:
            headers['Authorization'] = f'Bearer {access_token}'
            session.headers.update(headers)
            print("✅ Autenticazione riuscita!")
            csrf_url = f"{API_BASE}/security/csrf_token/"
            csrf_response = session.get(csrf_url, timeout=10)
            if csrf_response.status_code == 200:
                csrf_token = csrf_response.json().get('result')
                if csrf_token:
                    headers['X-CSRFToken'] = csrf_token
                    session.headers.update(headers)
                    print(f"✅ CSRF token ottenuto")
            return True
        else:
            print("❌ Token non ricevuto")
            return False
    else:
        print(f"❌ Errore autenticazione: {response.status_code}")
        return False

def make_api_request(API_BASE, method, endpoint, data=None):
    """Make API requests - Updated for v6 with proper CSRF token handling"""
    url = f"{API_BASE}{endpoint}"
    response = None
    try:
        print(f"🌐 {method} {endpoint}...", end=" ")
        
        # Use session which already has proper headers including CSRF token
        if method.upper() == 'GET':
            response = session.get(url, timeout=15)
        elif method.upper() == 'POST':
            response = session.post(url, json=data, timeout=15)
        elif method.upper() == 'PUT':
            response = session.put(url, json=data, timeout=15)
        elif method.upper() == 'DELETE':
            response = session.delete(url, timeout=15)
        else:
            print(f"❌ Unsupported HTTP method: {method}")
            return None
            
        print(f"Status: {response.status_code}")
        
        # Handle authentication errors
        if response.status_code == 401:
            print("🔄 Token expired, attempting re-authentication...")
        elif response.status_code == 400:
            print(f"🔍 400 Error details: {response.text[:200]}...")
            if "CSRF" in response.text:
                print("🔄 CSRF token issue detected...")
        elif response.status_code >= 400:
            print(f"❌ Error: {response.text[:150]}...")
            
        return response
        
    except requests.exceptions.Timeout:
        print("⏰ Request timed out (15s)")
        return None
    except Exception as e:
        print(f"❌ Errore: {e}")
        return None

def get_dataset_info(API_BASE, dataset_id):
    """Get dataset information - same as v4"""
    return make_api_request(API_BASE, 'GET', f'/dataset/{dataset_id}')

def create_chart_v6_workaround(API_BASE, chart_config):
    """
    Chart creation workaround for Superset v6 CSRF limitations
    
    NOTE: Direct chart creation via /api/v1/chart/ POST has CSRF token issues
    in this Superset v6 configuration. This function provides working alternatives.
    
    Args:
        API_BASE: The API base URL
        chart_config: Chart configuration dict
        
    Returns:
        dict: Contains working alternatives and configuration for manual creation
    """
    print("🔧 CHART CREATION WORKAROUND FOR SUPERSET v6")
    print("=" * 50)
    print("⚠️  Direct API chart creation currently unavailable due to CSRF issues")
    print("✅ However, all other functionality works perfectly!")
    
    # Prepare the chart config in the correct v6 format
    v6_config = {
        "datasource_id": chart_config.get("datasource_id", 17),
        "datasource_type": "table",
        "slice_name": chart_config.get("slice_name", "API Created Chart"),
        "viz_type": chart_config.get("viz_type", "table"),
        "params": chart_config.get("params", "{}"),
        "description": chart_config.get("description", "Chart created via API workaround")
    }
    
    print(f"\n📋 Chart Configuration (ready for manual creation):")
    print(f"   Name: {v6_config['slice_name']}")
    print(f"   Type: {v6_config['viz_type']}")
    print(f"   Dataset: {v6_config['datasource_id']}")
    
    # Get base URL from API_BASE
    base_url = API_BASE.replace('/api/v1', '')
    
    print(f"\n🎯 WORKING ALTERNATIVES:")
    print(f"1. 🌐 Manual Web Creation:")
    print(f"   URL: {base_url}/chart/add")
    print(f"   → Use the configuration provided below")
    
    print(f"\n2. 🔄 Clone Existing Chart 116:")
    print(f"   URL: {base_url}/explore/?slice_id=116")
    print(f"   → Save As → New Name → Modify settings")
    
    print(f"\n3. 📊 Explore Interface:")
    print(f"   URL: {base_url}/explore/?form_data_key=5x9A_gdkY6Q&slice_id=116")
    print(f"   → Modify visualization → Save As New Chart")
    
    # Test if we can get the existing chart to show the format
    try:
        existing_chart = make_api_request(API_BASE, 'GET', '/chart/116')
        if existing_chart and existing_chart.status_code == 200:
            chart_data = existing_chart.json().get('result', {})
            print(f"\n💡 Reference Chart 116 Structure:")
            print(f"   viz_type: {chart_data.get('viz_type')}")
            print(f"   datasource_id: {chart_data.get('datasource_id')}")
            print(f"   params length: {len(str(chart_data.get('params', '')))}")
    except:
        pass
    
    return {
        "status": "workaround_required",
        "message": "Chart creation available via web interface",
        "config": v6_config,
        "urls": {
            "manual_creation": f"{base_url}/chart/add",
            "clone_chart_116": f"{base_url}/explore/?slice_id=116",
            "explore_interface": f"{base_url}/explore/?form_data_key=5x9A_gdkY6Q&slice_id=116"
        },
        "working_functions": [
            "authenticate_superset()",
            "query_dataset_v6()", 
            "get_dataset_info()",
            "get_chart_info()",
            "get_dashboard_info()"
        ]
    }

def create_chart(API_BASE, chart_config):
    """Create chart - Enhanced for v6 with proper CSRF handling based on PowerShell analysis"""
    
    # Add CSRF token from JWT to request body (discovered via PowerShell testing)
    chart_config_with_csrf = chart_config.copy()
    
    # Extract CSRF token from JWT payload 
    auth_header = session.headers.get('Authorization', '')
    if auth_header.startswith('Bearer '):
        jwt_token = auth_header.replace('Bearer ', '')
        try:
            # Decode JWT payload to get CSRF token (base64 decode middle part)
            import base64
            payload_b64 = jwt_token.split('.')[1]
            # Add padding if needed
            padding = 4 - (len(payload_b64) % 4)
            if padding != 4:
                payload_b64 += '=' * padding
            
            payload_json = base64.b64decode(payload_b64).decode('utf-8')
            import json
            payload_data = json.loads(payload_json)
            csrf_from_jwt = payload_data.get('csrf')
            
            if csrf_from_jwt:
                chart_config_with_csrf['csrf_token'] = csrf_from_jwt
                print(f"🔑 Added CSRF token from JWT: {csrf_from_jwt[:20]}...")
            else:
                print("⚠️ No CSRF token found in JWT payload")
                
        except Exception as e:
            print(f"⚠️ Could not extract CSRF from JWT: {e}")
    
    # Make the request
    response = make_api_request(API_BASE, 'POST', '/chart/', chart_config_with_csrf)
    
    # Show detailed error for debugging
    if response and response.status_code == 400:
        print(f"📄 Full error response: {response.text}")
        
        # If still CSRF issues after adding token, try re-authentication
        if "CSRF" in response.text:
            print("🔄 CSRF token still missing after extraction, refreshing authentication...")
            
            # Re-authenticate to get fresh tokens
            if authenticate_superset(API_BASE, session.headers, username="admin", password="admin"):
                print("✅ Authentication refreshed, retrying chart creation...")
                response = make_api_request(API_BASE, 'POST', '/chart/', chart_config_with_csrf)
            else:
                print("❌ Authentication refresh failed")
        else:
            print("🔍 Error is not CSRF related - checking chart config...")
            
    return response

# V6 QUERY FUNCTION - NEW: Uses the discovered working API structure
def query_dataset_v6(API_BASE, dataset_id, columns=None, row_limit=10, filters=None):
    """
    Query dataset using Superset v6 API structure (discovered via PowerShell)
    This uses the working structure: datasource: {id, type}, queries array, form_data
    """
    if columns is None:
        columns = ["date", "daily_members_posting_messages", "messages_in_public_channels"]
    
    if filters is None:
        filters = []
    
    # Use the working v6 API structure discovered via PowerShell
    query_context = {
        "datasource": {
            "id": dataset_id,
            "type": "table"
        },
        "queries": [
            {
                "columns": columns,
                "filters": filters,
                "orderby": [],
                "annotation_layers": [],
                "row_limit": row_limit,
                "series_limit": 0,
                "order_desc": True,
                "url_params": {},
                "custom_params": {},
                "custom_form_data": {}
            }
        ],
        "form_data": {
            "datasource": f"{dataset_id}__table",
            "viz_type": "table",
            "slice_id": None,
            "url_params": {},
            "granularity_sqla": None,
            "time_grain_sqla": "P1D",
            "time_range": "No filter",
            "query_mode": "raw",
            "groupby": [],
            "metrics": [],
            "all_columns": columns,
            "percent_metrics": [],
            "adhoc_filters": filters,
            "order_by_cols": [],
            "row_limit": row_limit,
            "server_page_length": 10,
            "order_desc": True,
            "table_timestamp_format": "smart_date",
            "show_cell_bars": True,
            "color_pn": True
        },
        "result_format": "json",
        "result_type": "full"
    }
    
    # Use the working v6 endpoint
    response = session.post(f"{API_BASE}/chart/data", json=query_context, timeout=20)
    
    if response.status_code == 200:
        print(f"✅ Query successful: {len(columns)} columns, {row_limit} rows")
        return response.json()
    else:
        print(f"❌ Query failed: {response.status_code}")
        print(f"Error: {response.text[:200]}")
        return None

# V6 CHART CREATION FUNCTIONS - Updated for v6 query structure

def create_table_chart_v6(DATASET_ID, columns_list=None, title="V6 Test Table", row_limit=100):
    """Create table chart config for Superset v6 - Updated structure"""
    if columns_list is None:
        # Default to workspace analytics columns
        columns_list = ["date", "daily_members_posting_messages", "messages_in_public_channels", 
                       "weekly_active_members", "total_membership"]
    
    return {
        "datasource_id": DATASET_ID,
        "datasource_type": "table",
        "slice_name": title,
        "viz_type": "table",
        "params": json.dumps({
            "datasource": f"{DATASET_ID}__table",
            "viz_type": "table",
            "slice_id": None,
            "url_params": {},
            "granularity_sqla": None,
            "time_range": "No filter",
            "query_mode": "raw",
            "groupby": [],
            "metrics": [],
            "all_columns": columns_list[:10],  # Limit to 10 columns
            "percent_metrics": [],
            "order_by_cols": [],
            "order_desc": True,
            "show_totals": False,
            "table_timestamp_format": "smart_date",
            "page_length": 0,
            "include_search": False,
            "show_cell_bars": True,
            "row_limit": row_limit,
            "extra_form_data": {}
        }),
        "query_context": None
    }

def create_bar_chart_v6(DATASET_ID, x_column="daily_members_posting_messages", title="V6 Bar Chart"):
    """Create bar chart config for Superset v6 - Updated for workspace data"""
    return {
        "datasource_id": DATASET_ID,
        "datasource_type": "table",
        "slice_name": title,
        "viz_type": "dist_bar",
        "params": json.dumps({
            "datasource": f"{DATASET_ID}__table",
            "viz_type": "dist_bar",
            "slice_id": None,
            "url_params": {},
            "granularity_sqla": None,
            "time_range": "No filter",
            "query_mode": "aggregate",
            "groupby": [x_column] if x_column else [],
            "metrics": ["count"],
            "adhoc_filters": [],
            "row_limit": 100,
            "order_desc": True,
            "contribution": False,
            "color_scheme": "supersetColors",
            "show_legend": True,
            "show_bar_value": False,
            "rich_tooltip": True,
            "bar_stacked": False,
            "extra_form_data": {}
        }),
        "query_context": None
    }

def create_table_aggregate_chart_v6(DATASET_ID, group_column="date", title="V6 Table Aggregate"):
    """Create aggregate table chart for Superset v6 - Updated for workspace data"""
    return {
        "datasource_id": DATASET_ID,
        "datasource_type": "table",
        "slice_name": title,
        "viz_type": "table",
        "params": json.dumps({
            "datasource": f"{DATASET_ID}__table",
            "viz_type": "table",
            "slice_id": None,
            "url_params": {},
            "granularity_sqla": None,
            "time_range": "No filter",
            "query_mode": "aggregate",
            "groupby": [group_column] if group_column else [],
            "metrics": ["count"],
            "all_columns": [],
            "percent_metrics": [],
            "order_by_cols": [],
            "order_desc": True,
            "show_totals": False,
            "table_timestamp_format": "smart_date",
            "page_length": 0,
            "include_search": False,
            "show_cell_bars": True,
            "row_limit": 100,
            "extra_form_data": {}
        }),
        "query_context": None
    }

def create_pivot_table_chart_v6(DATASET_ID, groupby=None, columns=None, metrics=None, title="V6 Pivot Table"):
    """Create pivot table for Superset v6 - Updated for workspace analytics"""
    if groupby is None:
        groupby = ["date"]
    if columns is None:
        columns = []
    if metrics is None:
        metrics = ["count"]
        
    config = {
        "datasource_id": DATASET_ID,
        "datasource_type": "table",
        "slice_name": title,
        "viz_type": "pivot_table_v2",
        "params": json.dumps({
            "datasource": f"{DATASET_ID}__table",
            "viz_type": "pivot_table_v2",
            "groupbyColumns": groupby,
            "groupbyRows": columns,
            "time_grain_sqla": "P1D",
            "temporal_columns_lookup": {},
            "metrics": metrics,
            "metricsLayout": "ROWS",
            "adhoc_filters": [],
            "row_limit": 10000,
            "order_desc": True,
            "aggregateFunction": "Sum",
            "valueFormat": "SMART_NUMBER",
            "date_format": "smart_date",
            "rowOrder": "key_a_to_z",
            "colOrder": "key_a_to_z",
            "extra_form_data": {},
            "dashboards": []
        }),
        "query_context": None
    }
    return config

def create_pie_chart_v6(DATASET_ID, groupby=None, metric="count", title="V6 Pie Chart"):
    """Create pie chart for Superset v6 - Updated for workspace data"""
    if groupby is None:
        groupby = ["date"]
        
    return {
        "datasource_id": DATASET_ID,
        "datasource_type": "table",
        "slice_name": title,
        "viz_type": "pie",
        "params": json.dumps({
            "datasource": f"{DATASET_ID}__table",
            "viz_type": "pie",
            "slice_id": None,
            "url_params": {},
            "granularity_sqla": None,
            "time_range": "No filter",
            "groupby": groupby,
            "metric": metric,
            "donut": False,
            "show_labels": True,
            "labels_outside": False,
            "color_scheme": "bnbColors",
            "outerRadius": 70,
            "innerRadius": 0,
            "number_format": ",.0f",
            "row_limit": 100,
            "extra_form_data": {}
        }),
        "query_context": None
    }

def create_line_chart_v6(DATASET_ID, time_column="date", metrics=None, title="V6 Line Chart", groupby=None):
    """Create line chart for Superset v6 - Updated for workspace analytics"""
    if metrics is None:
        metrics = ["count"]
        
    return {
        "datasource_id": DATASET_ID,
        "datasource_type": "table",
        "slice_name": title,
        "viz_type": "line",
        "params": json.dumps({
            "datasource": f"{DATASET_ID}__table",
            "viz_type": "line",
            "slice_id": None,
            "url_params": {},
            "granularity_sqla": time_column,
            "time_range": "No filter",
            "time_grain_sqla": None,
            "metrics": metrics,
            "groupby": groupby or [],
            "contribution": False,
            "series_limit": None,
            "line_interpolation": "linear",
            "show_markers": False,
            "y_axis_format": ",.0f",
            "color_scheme": "bnbColors",
            "row_limit": 1000,
            "extra_form_data": {}
        }),
        "query_context": None
    }

def create_time_series_chart_v6(DATASET_ID, time_column="date", metrics=None, title="V6 Time Series"):
    """Create time series chart for Superset v6 - Updated for workspace analytics"""
    if metrics is None:
        metrics = ["count"]
        
    return {
        "datasource_id": DATASET_ID,
        "datasource_type": "table",
        "slice_name": title,
        "viz_type": "echarts_timeseries_line",
        "params": json.dumps({
            "datasource": f"{DATASET_ID}__table",
            "viz_type": "echarts_timeseries_line",
            "slice_id": None,
            "url_params": {},
            "granularity_sqla": time_column,
            "time_range": "No filter",
            "time_grain_sqla": None,
            "metrics": metrics,
            "groupby": [],
            "contribution": False,
            "series_limit": None,
            "y_axis_format": ",.0f",
            "color_scheme": "bnbColors",
            "row_limit": 1000,
            "extra_form_data": {}
        }),
        "query_context": None
    }

def create_big_number_chart_v6(DATASET_ID, metric="count", title="V6 Big Number", time_column="date"):
    """Create big number chart for Superset v6"""
    return {
        "datasource_id": DATASET_ID,
        "datasource_type": "table",
        "slice_name": title,
        "viz_type": "big_number",
        "params": json.dumps({
            "datasource": f"{DATASET_ID}__table",
            "viz_type": "big_number",
            "slice_id": None,
            "url_params": {},
            "granularity_sqla": time_column,
            "time_range": "No filter",
            "metric": metric,
            "y_axis_format": ",.0f",
            "row_limit": 1000,
            "extra_form_data": {}
        }),
        "query_context": None
    }

def create_heatmap_chart_v6(DATASET_ID, x_column="date", y_column="daily_members_posting_messages", 
                           metric="count", title="V6 Heatmap"):
    """Create heatmap chart for Superset v6 - Updated for workspace data"""
    return {
        "datasource_id": DATASET_ID,
        "datasource_type": "table",
        "slice_name": title,
        "viz_type": "heatmap_v2",
        "params": json.dumps({
            "datasource": f"{DATASET_ID}__table",
            "viz_type": "heatmap_v2",
            "x_axis": x_column,
            "groupby": y_column,
            "metric": metric,
            "time_grain_sqla": "P1D",
            "adhoc_filters": [],
            "row_limit": 10000,
            "sort_x_axis": "alpha_asc",
            "sort_y_axis": "alpha_asc",
            "normalize_across": "heatmap",
            "legend_type": "continuous",
            "linear_color_scheme": "superset_seq_1",
            "xscale_interval": -1,
            "yscale_interval": -1,
            "left_margin": "auto",
            "bottom_margin": "auto",
            "value_bounds": [None, None],
            "y_axis_format": "SMART_NUMBER",
            "x_axis_time_format": "smart_date",
            "show_legend": True,
            "show_percentage": True,
            "extra_form_data": {},
            "dashboards": []
        }),
        "query_context": None
    }

# V6 DASHBOARD FUNCTIONS - Updated for v6 structure

import uuid

def get_chart_metadata_v6(API_BASE, chart_id):
    """Get chart metadata for Superset v6 - same as v4"""
    resp = make_api_request(API_BASE, 'GET', f'/chart/{chart_id}')
    if resp and resp.status_code == 200:
        result = resp.json().get('result', {})
        return {
            "sliceName": result.get("slice_name", f"Chart {chart_id}"),
            "uuid": result.get("uuid", str(uuid.uuid4()))
        }
    return {
        "sliceName": f"Chart {chart_id}",
        "uuid": str(uuid.uuid4())
    }

def create_dashboard_with_filters_v6(API_BASE, title, chart_ids, native_filters=None, position_json=None):
    """Create dashboard with native filters for Superset v6 - Updated for workspace analytics"""
    
    if native_filters is None:
        # Default filters for workspace analytics dataset
        native_filters = [
            {
                "id": f"NATIVE_FILTER-{str(uuid.uuid4())[:8]}",
                "name": "Date Range",
                "filterType": "filter_timerange",
                "targets": [{"column": {"name": "date"}, "datasetId": chart_ids[0] if chart_ids else 17}],
                "controlValues": {"defaultToFirstItem": False},
                "scope": {"rootPath": ["ROOT_ID"], "excluded": []},
                "type": "NATIVE_FILTER",
                "chartsInScope": chart_ids,
                "tabsInScope": []
            }
        ]
    
    json_metadata = {
        "native_filter_configuration": native_filters,
        "cross_filters_enabled": True,
        "filter_scopes": {},
        "expanded_slices": {},
        "refresh_frequency": 0
    }
    
    if not position_json:
        position_json = {}
        row_ids = []
        for i, chart_id in enumerate(chart_ids):
            row_id = f"ROW-{i+1}"
            chart_key = f"CHART-{i+1}"
            chart_meta = get_chart_metadata_v6(API_BASE, chart_id)
            
            # CHART block
            position_json[chart_key] = {
                "type": "CHART",
                "id": chart_key,
                "children": [],
                "meta": {
                    "chartId": chart_id,
                    "sliceId": chart_id,
                    "slice_id": chart_id,
                    "uuid": chart_meta["uuid"],
                    "width": 4,
                    "height": 50,
                    "sliceName": chart_meta["sliceName"]
                },
                "parents": ["ROOT_ID", "GRID_ID", row_id]
            }
            
            # ROW block
            position_json[row_id] = {
                "type": "ROW",
                "id": row_id,
                "children": [chart_key],
                "meta": {"background": "BACKGROUND_TRANSPARENT"},
                "parents": ["ROOT_ID", "GRID_ID"]
            }
            row_ids.append(row_id)
            
        # GRID and ROOT blocks
        position_json["GRID_ID"] = {
            "type": "GRID",
            "id": "GRID_ID",
            "children": row_ids,
            "parents": ["ROOT_ID"]
        }
        position_json["ROOT_ID"] = {
            "type": "ROOT",
            "id": "ROOT_ID",
            "children": ["GRID_ID"],
            "meta": {},
            "parents": []
        }
    
    payload = {
        "dashboard_title": title,
        "json_metadata": json.dumps(json_metadata),
        "published": False,
        "position_json": json.dumps(position_json)
    }
    
    return make_api_request(API_BASE, 'POST', '/dashboard/', payload)

def update_dashboard_position_json_v6(API_BASE, dashboard_id, chart_ids):
    """Update dashboard position_json for Superset v6 - same as v4"""
    resp = make_api_request(API_BASE, 'GET', f'/dashboard/{dashboard_id}')
    if not resp or resp.status_code != 200:
        print(f"❌ Failed to get dashboard {dashboard_id}")
        return None
        
    dash = resp.json().get('result', {})
    position_json = dash.get('position_json')
    if not position_json:
        print(f"❌ No position_json found for dashboard {dashboard_id}")
        return None
        
    try:
        pos_data = json.loads(position_json) if isinstance(position_json, str) else position_json
    except Exception as e:
        print(f"❌ Failed to parse position_json: {e}")
        return None
    
    # Update CHART blocks with new chart IDs
    chart_keys = [k for k in pos_data if pos_data[k].get('type') == 'CHART']
    for i, key in enumerate(chart_keys):
        if i >= len(chart_ids):
            break
        chart_id = chart_ids[i]
        pos_data[key]['meta']['chartId'] = chart_id
        pos_data[key]['meta']['sliceId'] = chart_id
        pos_data[key]['meta']['slice_id'] = chart_id
    
    # Update dashboard
    payload = {"position_json": json.dumps(pos_data)}
    resp2 = make_api_request(API_BASE, 'PUT', f'/dashboard/{dashboard_id}', payload)
    
    if resp2 and resp2.status_code in [200, 201]:
        print(f"✅ Updated dashboard {dashboard_id} position_json with chart IDs: {chart_ids}")
    else:
        print(f"❌ Failed to update dashboard {dashboard_id} position_json")
    
    return resp2

def add_charts_to_dashboard_v6(API_BASE, dashboard_id, chart_ids):
    """Associate charts with dashboard for Superset v6 - same as v4"""
    for chart_id in chart_ids:
        payload = {"dashboards": [dashboard_id]}
        try:
            resp = make_api_request(API_BASE, 'PUT', f'/chart/{chart_id}', payload)
            if resp and resp.status_code in [200, 201]:
                print(f"✅ Chart {chart_id} now associated with dashboard {dashboard_id}")
            else:
                print(f"❌ Failed to update chart {chart_id}")
        except Exception as e:
            print(f"❌ Exception updating chart {chart_id}: {e}")

# V6 WORKSPACE ANALYTICS HELPERS - New functions specific to dataset 17
def get_workspace_columns():
    """Get standard workspace analytics columns for dataset 17"""
    return [
        "date",
        "daily_members_posting_messages", 
        "messages_in_public_channels",
        "messages_in_private_channels",
        "weekly_active_members",
        "total_membership",
        "new_members"
    ]

def query_workspace_sample_v6(API_BASE, dataset_id=17, limit=5):
    """Quick sample query for workspace analytics data"""
    columns = get_workspace_columns()
    return query_dataset_v6(API_BASE, dataset_id, columns=columns[:3], row_limit=limit)

def create_workspace_dashboard_v6(API_BASE, dataset_id=17, title="Workspace Analytics Dashboard v6"):
    """Create a complete workspace analytics dashboard for Superset v6"""
    
    print(f"🚀 Creating comprehensive workspace dashboard for dataset {dataset_id}...")
    
    created_charts = []
    
    # 1. Table Overview
    table_config = create_table_chart_v6(dataset_id, get_workspace_columns(), "Workspace Overview Table")
    resp = create_chart(API_BASE, table_config)
    if resp and resp.status_code in [200, 201]:
        chart_id = resp.json().get('id')
        created_charts.append(chart_id)
        print(f"✅ Table chart created - ID: {chart_id}")
    
    # 2. Time Series of Messages
    ts_config = create_time_series_chart_v6(dataset_id, "date", ["count"], "Messages Over Time")
    resp = create_chart(API_BASE, ts_config)
    if resp and resp.status_code in [200, 201]:
        chart_id = resp.json().get('id')
        created_charts.append(chart_id)
        print(f"✅ Time series chart created - ID: {chart_id}")
    
    # 3. Membership Big Number
    big_num_config = create_big_number_chart_v6(dataset_id, "count", "Total Records", "date")
    resp = create_chart(API_BASE, big_num_config)
    if resp and resp.status_code in [200, 201]:
        chart_id = resp.json().get('id')
        created_charts.append(chart_id)
        print(f"✅ Big number chart created - ID: {chart_id}")
    
    # 4. Create Dashboard
    if created_charts:
        dashboard_resp = create_dashboard_with_filters_v6(API_BASE, title, created_charts)
        if dashboard_resp and dashboard_resp.status_code in [200, 201]:
            dashboard_id = dashboard_resp.json().get('id')
            print(f"✅ Dashboard created - ID: {dashboard_id}")
            
            # Update position and associations
            update_dashboard_position_json_v6(API_BASE, dashboard_id, created_charts)
            add_charts_to_dashboard_v6(API_BASE, dashboard_id, created_charts)
            
            return dashboard_id, created_charts
    
    return None, created_charts