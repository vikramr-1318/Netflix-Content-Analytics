# 🎬 Netflix Content Analytics Dashboard

> **Project Status:** Completed (November 19, 2024) | **Maintainer:** R Vikram

## 1. Project Title & Overview
**Netflix Content Analytics** is an entertainment media analytics project investigating catalog composition, international expansion, genre trends, and content longevity across 8,807 Netflix Movies and TV Shows. The project normalizes multi-value fields into a Star Schema data model in Power BI supported by advanced DAX measures and pure SQL analytics.

---

## 2. Business Problem
Global streaming entertainment platforms face escalating content acquisition costs and fierce competition from rival networks (Disney+, Prime Video, HBO Max). Content executives must optimize catalog investments by understanding:
1. What is the optimal balance between feature films and multi-season episodic television series?
2. Which international markets produce the highest volume of exportable original content?
3. What are the dominant maturity rating profiles, and how do they shape subscriber demographics?
4. How do content addition schedules align with consumer streaming seasonality throughout the calendar year?

---

## 3. Project Objectives
* Resolve critical data alignment bugs and newline shift errors in the raw titles dataset using Python.
* Normalize comma-separated genres and multi-country production credits into 1-to-many bridge tables (`Genre.csv`, `Country.csv`).
* Develop comprehensive SQL queries (`SQL/netflix_analytics_queries.sql`) to evaluate content growth trajectories.
* Build a 5-page cinematic dark-mode Power BI dashboard with red neon-glow aesthetics.
* Quantify TV show renewal rates and film runtime distributions to guide content acquisition strategy.

---

## 4. Dataset Description
* **Source:** [Kaggle - Netflix Movies and TV Shows](https://www.kaggle.com/datasets/shivamb/netflix-shows)
* **Tables:** 3 Star Schema tables (`Titles.csv` Fact Table, `Genre.csv` Bridge Table, `Country.csv` Bridge Table).
* **Catalog Size:** 8,807 unique titles (6,131 Movies, 2,676 TV Shows).
* **Coverage:** 42 distinct genres across 121 producing nations from 1925 to 2021.

---

## 5. Tools & Technologies
* **Power BI Desktop:** 5-page cinematic dashboard, Star Schema modeling, drill-through filters.
* **DAX:** Advanced measures for catalog segmentation, duration averages, and YoY growth percentages.
* **Python (Pandas, Pillow):** Bug-fixing ETL pipeline and 1920x1080 gradient neon background generation.
* **SQL (ANSI SQL / PostgreSQL / MySQL):** Schema DDL, temporal release analysis, and bridge-table queries.

---

## 6. Data Architecture (Star Schema)
```
┌─────────────────────┐                 ┌─────────────────────┐
│      Genre.csv      │                 │     Country.csv     │
│  (Bridge Table: N)  │                 │  (Bridge Table: N)  │
└──────────┬──────────┘                 └──────────┬──────────┘
           │ N                                     │ N
           │                                       │
           │ 1                                     │ 1
┌──────────┴───────────────────────────────────────┴──────────┐
│                         Titles.csv                          │
│                        (Fact Table)                         │
└─────────────────────────────────────────────────────────────┘
```

---

## 7. Data Cleaning Methodology
Data processing is automated via [process_netflix_data.py](process_netflix_data.py):
1. **Newline Cleaning:** Stripped embedded `\n` and `\r` characters from `description` text fields to eliminate CSV row splitting during Power BI import.
2. **Louis C.K. Data Shift Correction:** Repaired the famous dataset shift where `74 min` duration was misplaced into the `rating` column.
3. **Missing Value Imputation:** Imputed missing values for `director`, `cast`, and `country` with `'Unknown'`, and `rating` with `'Not Rated'`.
4. **Relational Normalization:** Exploded multi-value comma-delimited strings in `listed_in` and `country` into normalized relational bridge tables (`Genre.csv` with 19,323 rows; `Country.csv` with 10,845 rows).

---

## 8. SQL Analysis
The project includes a complete analytical SQL suite in [SQL/netflix_analytics_queries.sql](SQL/netflix_analytics_queries.sql):
* Schema DDL for fact and bridge entities with primary/foreign key constraints.
* Catalog format breakdowns (Movies vs TV Shows).
* Year-over-Year (YoY) content addition growth rates using window functions (`LAG`).
* Top producing nations and genre penetration percentages.
* Release month seasonality and TV show renewal longevity distributions.

---

## 9. Python Implementation
* **[process_netflix_data.py](process_netflix_data.py):** Automated ETL pipeline that fixes data shifts, cleans text, and generates Star Schema CSVs.
* **[generate_netflix_bg.py](generate_netflix_bg.py):** Generates 1920x1080 cinematic dark canvas with Netflix Red radial neon glows.

---

## 10. Power BI Dashboard
The dashboard [Netflix Content Analytics Dashboard.pbix](Netflix%20Content%20Analytics%20Dashboard.pbix) comprises 5 analytical views:
1. **Overview:** Total titles, format split, content addition timeline, and maturity rating distribution.
2. **Genre Analysis:** Top genre treemap, genre co-occurrence, and film vs TV genre popularity.
3. **Country Analysis:** Global production map, top content exporter rankings, and domestic vs international content share.
4. **Time Analysis:** Release year trajectories, monthly release seasonality, and YoY growth percentages.
5. **Rating Analysis:** Audience maturity breakdowns (TV-MA, TV-14, PG) by content format and country.

---

## 11. Dashboard Screenshots
Dashboard preview assets are located in the [Screenshots/](Screenshots/) directory:

![Dashboard Theme Preview](Screenshots/01_dashboard_canvas_theme.png)

*The complete interactive dashboard can be explored via [Netflix Content Analytics Dashboard.pbix](Netflix%20Content%20Analytics%20Dashboard.pbix).*

---

## 12. Key Performance Indicators (KPIs)
| KPI | Value | Business Significance |
|:---|:---:|:---|
| **Total Catalog Titles** | 8,807 | Total streaming entertainment titles |
| **Feature Movies** | 6,131 | Film content share (69.61% of catalog) |
| **TV Shows** | 2,676 | Episodic content share (30.39% of catalog) |
| **Average Movie Duration** | 99.57 min | Mean film runtime (~1 hr 40 min) |
| **Average TV Show Longevity**| 1.76 seasons| Mean seasons released per TV title |
| **Genres Covered** | 42 | Thematic content diversity |
| **Countries Covered** | 121 | Geographic distribution of content origins |

---

## 13. Business Insights
*Detailed analytical findings available in [Documentation/Netflix_Analytics_Insights.md](Documentation/Netflix_Analytics_Insights.md).*
* **Adult Audience Focus:** Nearly **61% of library content** is rated TV-MA or TV-14, underscoring Netflix's positioning toward mature viewers.
* **The Single-Season Reality:** Over **66.8% of TV shows** consist of exactly 1 season, highlighting aggressive cancellation thresholds for lower-tier series.
* **International Expansion:** 48% of titles now originate outside the US, driven by explosive growth in Indian, British, South Korean, and Japanese productions.

---

## 14. Strategic Recommendations
1. **Invest in 2-to-3 Season Mid-Tier Franchises:** Expanding proven Season 1 hits to Season 2 drives higher subscriber retention than funding unproven new debuts.
2. **Optimize Q4 Holiday Release Pipelines:** Align major blockbuster releases with the proven July and December consumer viewing surges.
3. **Expand Anime & K-Drama Co-Productions:** Capitalize on the high international exportability and passionate subscriber base of East Asian scripted content.

---

## 15. Project Folder Structure
```
Netflix Content Analytics/
│
├── Netflix Content Analytics Dashboard.pbix # Interactive Power BI report
├── Netflix_Theme.json                       # Custom Netflix dark theme
├── Netflix_Background.png                   # High-res radial canvas background
├── Titles.csv                               # Normalized Fact Table
├── Genre.csv                                # Normalized Genre Bridge Table
├── Country.csv                              # Normalized Country Bridge Table
├── process_netflix_data.py                  # Automated data cleaning pipeline
├── generate_netflix_bg.py                   # Background generation script
├── requirements.txt                         # Python dependencies
├── SQL/
│   └── netflix_analytics_queries.sql        # Production SQL query suite
├── Documentation/
│   ├── DAX_Measures.md                      # Comprehensive DAX catalog
│   └── Netflix_Analytics_Insights.md        # Detailed analytical findings
└── Screenshots/
    └── 01_dashboard_canvas_theme.png        # Canvas theme preview
```

---

## 16. Installation Instructions
```bash
# Clone the repository
git clone https://github.com/vikramr-1318/Data-Analyst-Portfolio.git
cd "Data-Analyst-Portfolio/Netflix Content Analytics"

# Install Python dependencies
pip install -r requirements.txt
```

---

## 17. Execution Instructions
```bash
# Execute data cleaning & normalization pipeline:
python process_netflix_data.py

# Regenerate Netflix red neon background:
python generate_netflix_bg.py
```

---

## 18. Dataset Download Instructions
Raw data (`netflix_titles.csv`) can be downloaded from [Kaggle - Netflix Shows](https://www.kaggle.com/datasets/shivamb/netflix-shows). Place the file into the project folder and run `python process_netflix_data.py`.

---

## 19. Limitations & Future Work
* **Viewer Engagement Metrics:** Dataset tracks library availability rather than actual consumer streaming hours or completion rates.
* **Future Work:** Integrate third-party streaming telemetry (e.g. IMDb ratings, Rotten Tomatoes scores) to model viewership success.

---

## 20. Contact & Maintainer
* **Developer & Maintainer:** R Vikram
* **GitHub:** [vikramr-1318](https://github.com/vikramr-1318)
* **Email:** `rv367629@gmail.com`
