# Vancouver Livability Analysis
### An analysis of crime, green space, businesses and community services across 22 Vancouver neighbourhoods (2023–2025)

---

## 🔍 Project Overview
This project explores what makes Vancouver neighbourhoods liveable by combining four civic datasets into a single interactive Power BI dashboard. The analysis covers 100,000+ crime incidents, 218 parks, 50,000+ active businesses and 27 community centres across 22 neighbourhoods.

**Headline Finding:** Vancouver crime dropped 11.69% between 2023 and 2025 — including a consistent decline in the Downtown core.

---

## 📊 Dashboard
The Power BI dashboard consists of three pages:
- **Overview** — Crime concentration across Vancouver neighbourhoods
- **Crime Trends** — Year-over-year crime change from 2023 to 2025
- **Neighbourhood Profile** — Green space, businesses and community centres by neighbourhood

---

## 🗂️ Data Sources
| Dataset | Source | Records |
|---|---|---|
| Crime Data (2023–2025) | [VPD GeoDASH](https://geodash.vpd.ca/opendata/) | 102,906 incidents |
| Parks | [City of Vancouver Open Data](https://opendata.vancouver.ca) | 218 parks |
| Business Licences | [City of Vancouver Open Data](https://opendata.vancouver.ca) | 52,560 licences |
| Community Centres | [City of Vancouver Open Data](https://opendata.vancouver.ca) | 27 centres |

---

## 🛠️ Tools Used
- **Excel** — Initial data exploration and cleaning
- **MySQL** — Data storage, cleaning and analysis
- **Power BI** — Interactive dashboard and visualisation

---

## 🔧 Data Cleaning Decisions
- **Stanley Park** (489 incidents) and **Musqueam** (104 incidents) were excluded from analysis as they lack comparable business and community services data
- **Out of Town** and **UBC** entries were excluded from the business licences dataset as they fall outside Vancouver city boundaries
- Records with missing neighbourhood values were excluded (< 2% of total records)
- Parks with zero hectare values were excluded as they represent data entry errors
- Neighbourhood names were standardised across all four datasets using the VPD crime data as the master reference (e.g. "Downtown" → "Central Business District")

---

## 💡 Key Findings
1. **Crime is falling** — Vancouver saw an 11.69% reduction in crime between 2023 and 2025 across all neighbourhoods
2. **Downtown dominates on all metrics** — Central Business District has the highest crime (35K), most businesses (12.6K) and most community centres (4) — reflecting its density rather than inherent danger
3. **The West End paradox** — highest green space in the city (416 hectares) yet second highest crime count, showing that green space alone does not determine neighbourhood safety
4. **South Vancouver is underserved** — neighbourhoods like Arbutus Ridge, Oakridge and Shaughnessy have zero community centres and below average business density despite low crime rates
