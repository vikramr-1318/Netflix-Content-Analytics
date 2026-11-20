"""
Netflix Content Analytics - Data Cleaning & Star Schema Pipeline
Cleans raw netflix_titles.csv, fixes duration/rating shifts, strips newlines,
and normalizes multi-value genres and countries into Star Schema bridge tables.
"""

import os
from pathlib import Path
import pandas as pd
import numpy as np


def clean_netflix_data():
    base_dir = Path(__file__).resolve().parent
    raw_path = base_dir / "netflix_titles.csv"
    fact_file = base_dir / "Titles.csv"
    genre_file = base_dir / "Genre.csv"
    country_file = base_dir / "Country.csv"

    print("=" * 60)
    print("NETFLIX CONTENT ANALYTICS ETL & NORMALIZATION PIPELINE")
    print("=" * 60)
    print(f"Working Directory: {base_dir}")

    if not raw_path.exists():
        print(f"\n[INFO] Raw file not found: {raw_path.name}")
        if fact_file.exists() and genre_file.exists() and country_file.exists():
            print("[OK] Existing cleaned Star Schema tables found:")
            print(f"     Titles.csv  : {pd.read_csv(fact_file).shape}")
            print(f"     Genre.csv   : {pd.read_csv(genre_file).shape}")
            print(f"     Country.csv : {pd.read_csv(country_file).shape}")
            print("[INFO] To reprocess from raw data, download 'netflix_titles.csv' from:")
            print("       https://www.kaggle.com/datasets/shivamb/netflix-shows")
            print("       and place it inside the 'Netflix Content Analytics' directory.")
            return
        else:
            raise FileNotFoundError(
                f"Raw dataset '{raw_path.name}' not found in {base_dir}.\n"
                f"Download from: https://www.kaggle.com/datasets/shivamb/netflix-shows"
            )

    print(f"\nStep 1: Loading raw Netflix titles from '{raw_path.name}'...")
    df = pd.read_csv(raw_path)
    print(f"  Initial records: {df.shape[0]} rows, {df.shape[1]} columns")

    # 1. Clean newline and carriage return characters from all string columns
    print("\nStep 2: Cleaning newlines, carriage returns, and extra whitespace...")
    for col in df.select_dtypes(include=['object']).columns:
        df[col] = df[col].apply(
            lambda x: str(x).replace('\n', ' ').replace('\r', ' ').strip() if pd.notnull(x) else x
        )

    # 2. Fix the rating/duration shift for Louis C.K. standups
    null_duration_idx = df[df['duration'].isnull()].index
    if len(null_duration_idx) > 0:
        print(f"  Fixing duration/rating shift for {len(null_duration_idx)} affected records...")
        df.loc[null_duration_idx, 'duration'] = df.loc[null_duration_idx, 'rating']
        df.loc[null_duration_idx, 'rating'] = 'Not Rated'

    # 3. Impute missing values for categorical metadata
    print("\nStep 3: Imputing missing categorical metadata...")
    df['director'] = df['director'].fillna('Unknown')
    df['cast'] = df['cast'].fillna('Unknown')
    df['country'] = df['country'].fillna('Unknown')
    df['rating'] = df['rating'].fillna('Not Rated')

    # 4. Standardize dates and extract temporal fields
    print("\nStep 4: Standardizing date_added and extracting release year...")
    df['date_added'] = df['date_added'].astype(str).str.strip()
    df['date_added_parsed'] = pd.to_datetime(df['date_added'], format='%B %d, %Y', errors='coerce')
    df['year_added'] = df['date_added_parsed'].dt.year.astype('Int64')

    # 5. Extract numeric duration value for analytical calculations
    print("Step 5: Extracting numeric duration values...")
    df['duration_value'] = df['duration'].str.split(' ').str[0].astype(float).fillna(0).astype(int)

    # 6. Deduplicate show_id
    initial_len = len(df)
    df.drop_duplicates(subset=['show_id'], inplace=True)
    if len(df) < initial_len:
        print(f"  Removed {initial_len - len(df)} duplicate records.")

    # 7. Save normalized Fact Table (Titles.csv)
    fact_cols = [
        'show_id', 'type', 'title', 'director', 'cast', 'country',
        'date_added_parsed', 'release_year', 'rating', 'duration',
        'duration_value', 'year_added', 'description'
    ]
    fact_df = df[fact_cols].rename(columns={'date_added_parsed': 'date_added'})
    fact_df.to_csv(fact_file, index=False)
    print(f"\n[SAVED] Fact Table '{fact_file.name}' with shape {fact_df.shape}")

    # 8. Generate Genre Bridge Table (Genre.csv)
    print("Step 6: Generating Genre Bridge Table (1-to-Many)...")
    genres_df = df[['show_id', 'listed_in']].copy()
    genres_df['genre'] = genres_df['listed_in'].str.split(', ')
    genres_df = genres_df.explode('genre')
    genres_df = genres_df[['show_id', 'genre']].dropna()
    genres_df.to_csv(genre_file, index=False)
    print(f"[SAVED] Genre Bridge Table '{genre_file.name}' with shape {genres_df.shape}")

    # 9. Generate Country Bridge Table (Country.csv)
    print("Step 7: Generating Country Bridge Table (1-to-Many)...")
    countries_df = df[['show_id', 'country']].copy()
    countries_df['country_split'] = countries_df['country'].str.split(', ')
    countries_df = countries_df.explode('country_split')
    countries_df = countries_df[['show_id', 'country_split']].rename(columns={'country_split': 'country'}).dropna()
    countries_df.to_csv(country_file, index=False)
    print(f"[SAVED] Country Bridge Table '{country_file.name}' with shape {countries_df.shape}")

    print("\n[SUCCESS] Netflix Content Analytics ETL pipeline completed successfully!")


if __name__ == "__main__":
    clean_netflix_data()
