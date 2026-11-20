# 🎬 Netflix Content Analytics — DAX Measures Reference Guide

This document catalogs the verified DAX calculations used in the **Netflix Content Analytics Dashboard** (`Netflix Content Analytics Dashboard.pbix`).

---

## 📐 Measure Catalog

### 1. Total Titles
* **DAX Formula:**
  ```dax
  Total Titles = COUNTROWS(Titles)
  ```
* **Business Definition:** Total catalog size of streaming entertainment assets indexed in the library.
* **Calculation Logic:** Row count of the primary `Titles` fact table.
* **Interpretation:** Total library size comprises **8,807 titles**.
* **Use Case:** Executive scorecard volume metric and denominator for genre/country penetration.

---

### 2. Movies Count
* **DAX Formula:**
  ```dax
  Movies = 
  CALCULATE(
      COUNTROWS(Titles),
      Titles[type] = "Movie"
  )
  ```
* **Business Definition:** Count of feature-length films, documentaries, and stand-up specials.
* **Calculation Logic:** Filtered count where `type = "Movie"`.
* **Interpretation:** **6,131 movies** (**69.61%** of overall catalog).
* **Use Case:** Content acquisition budget split and catalog format distribution.

---

### 3. TV Shows Count
* **DAX Formula:**
  ```dax
  TV Shows = 
  CALCULATE(
      COUNTROWS(Titles),
      Titles[type] = "TV Show"
  )
  ```
* **Business Definition:** Count of episodic, multi-episode, or serialized television productions.
* **Calculation Logic:** Filtered count where `type = "TV Show"`.
* **Interpretation:** **2,676 TV shows** (**30.39%** of overall catalog).
* **Use Case:** Subscriber retention strategy (episodic content drives sustained weekly active usage).

---

### 4. Average Movie Duration
* **DAX Formula:**
  ```dax
  Avg Movie Duration = 
  CALCULATE(
      AVERAGE(Titles[duration_value]),
      Titles[type] = "Movie"
  )
  ```
* **Business Definition:** Mean runtime in minutes for feature films.
* **Calculation Logic:** Arithmetic average over `duration_value` where `type = "Movie"`.
* **Interpretation:** The average Netflix movie runs for **99.57 minutes** (~1 hr 40 min).
* **Use Case:** Viewing session length modeling and attention-span programming.

---

### 5. Average TV Show Seasons
* **DAX Formula:**
  ```dax
  Avg TV Show Seasons = 
  CALCULATE(
      AVERAGE(Titles[duration_value]),
      Titles[type] = "TV Show"
  )
  ```
* **Business Definition:** Mean number of seasons released per serialized TV title.
* **Calculation Logic:** Arithmetic average over `duration_value` where `type = "TV Show"`.
* **Interpretation:** Average series longevity is **1.76 seasons** (over 65% of shows have only 1 season).
* **Use Case:** Series renewal ROI modeling and franchise development.

---

### 6. Titles Year-over-Year (YoY) %
* **DAX Formula:**
  ```dax
  Titles YoY % = 
  VAR CurrentYearTitles = [Total Titles]
  VAR PrevYearTitles = 
      CALCULATE(
          [Total Titles],
          SAMEPERIODLASTYEAR('Calendar'[Date])
      )
  RETURN
      DIVIDE(CurrentYearTitles - PrevYearTitles, PrevYearTitles, 0)
  ```
* **Business Definition:** Growth rate percentage of newly added titles compared to the previous calendar year.
* **Calculation Logic:** Variance between current year and prior year catalog additions divided by prior year.
* **Interpretation:** Measures expansion speed; catalog expansion peaked in 2018–2019 before stabilizing in 2020–2021.
* **Use Case:** Strategic library growth monitoring and competitor benchmark analysis.
