# MovieLens SQL Analysis Project

A SQL-based analysis project using the MovieLens dataset to demonstrate data modeling, querying, and analytical skills. This project explores movie ratings, user behavior, and content popularity using T-SQL on Microsoft SQL Server.

Built with real-world data from the GroupLens Research Lab, focusing on practical SQL techniques for recommendation systems and user analytics.

---

## Project Overview

This project analyzes movie ratings and user behavior using the MovieLens dataset, which contains millions of ratings for thousands of movies. The analysis demonstrates:

- Relational database design with proper constraints
- Efficient data loading and transformation techniques
- Complex analytical queries using CTEs, aggregations, and window functions
- Data quality validation and verification
- Business insights for recommendation systems

---

## Dataset Information

**Source:** [MovieLens Dataset](https://grouplens.org/datasets/movielens/) by GroupLens Research Lab

**Contents:**
- **movies.csv**: Movie titles and genres (pipe-separated)
- **ratings.csv**: User ratings (0.5 to 5.0 scale) with timestamps
- **tags.csv**: User-generated tags for movies
- **links.csv**: External IDs (IMDB, TMDB) for movies

---

## Key Features

- **Relational Database Design**: Properly normalized tables with foreign key constraints
- **Unix Timestamp Conversion**: Transformation of Unix timestamps to SQL datetime
- **Data Quality Checks**: Comprehensive verification scripts for data integrity
- **Analytical Queries**: Business-focused queries for insights:
  - Most rated movies (popularity)
  - Most active users (engagement)
  - Rating trends over time
  - Popular tags and movie descriptions
  - Top-rated movies with quality thresholds
  - Genre analysis and content strategy
  - User engagement metrics

---

## Project Structure

```
movielens-sql-project/
├── README.md
├── .gitignore
│
├── datasets/                          # CSV data files
│   ├── movies.csv                     # Movie information
│   ├── ratings.csv                    # User ratings
│   ├── tags.csv                       # User-generated tags
│   └── links.csv                      # External IDs
│
└── scripts/                           # SQL scripts
    ├── 01_create_database_tables.sql  # Database and table creation
    ├── 02_load_data.sql               # Data loading (BULK INSERT)
    ├── 03_verification.sql            # Data quality checks
    └── 04_analysis_queries.sql        # Analytical queries
```

---

## Technologies Used

- **Database**: Microsoft SQL Server
- **Language**: T-SQL
- **Techniques**: 
  - Foreign key constraints and referential integrity
  - BULK INSERT for efficient data loading
  - Common Table Expressions (CTEs)
  - Aggregations and window functions
  - DateTime transformations
  - Data quality validation
- **Tools**: SQL Server Management Studio (SSMS)

---

## Getting Started

### Prerequisites

- Microsoft SQL Server (2016 or later)
- SQL Server Management Studio (SSMS)
- MovieLens dataset CSV files

### Setup

**Step 1: Prepare Data Files**

Download the MovieLens dataset and place CSV files in a folder:

- Default path: `C:\MovieLens\datasets\`
- Or update paths in `02_load_data.sql` using Find & Replace

**Step 2: Create Database and Tables**

Run the database initialization script:

```sql
scripts/01_create_database_tables.sql
```

This will:
- Create the `MovieLens` database
- Create four tables (movies, ratings, tags, links)
- Set up foreign key constraints and indexes

**Step 3: Load Data**

Run the data loading script:

```sql
scripts/02_load_data.sql
```

This will:
- Load data from CSV files using BULK INSERT
- Convert Unix timestamps to SQL datetime
- Handle NULL values and data type conversions
- Display load statistics and row counts

**Step 4: Verify Data**

Run the verification script to ensure data integrity:

```sql
scripts/03_verification.sql
```

This performs:
- Row count checks
- Sample data inspection
- Foreign key integrity validation
- Data quality checks
- Summary statistics

**Step 5: Run Analysis Queries**

Explore the data using the analytical queries:

```sql
scripts/04_analysis_queries.sql
```

Execute individual queries or sections as needed for your analysis.

---

## Sample Analysis Results

### Most Rated Movies
Identifies which movies have the highest number of ratings, indicating popularity and user engagement.

### Most Active Users
Discovers power users who contribute the most ratings, important for understanding community engagement.

### Rating Trends Over Time
Tracks rating activity year-over-year to understand platform growth and seasonality.

### Top Tags by Frequency
Analyzes user-generated tags to understand how users categorize and describe movies.

### Top-Rated Movies (Quality with Threshold)
Finds highest-rated movies with a minimum of 50 ratings to ensure statistical reliability, ideal for recommendation systems.

---

## Business Applications

This analysis demonstrates skills applicable to:

- **Recommendation Systems**: Content-based and collaborative filtering insights
- **User Engagement Analytics**: Understanding user behavior and retention
- **Content Strategy**: Identifying popular genres and trending content
- **Quality Metrics**: Balancing popularity with quality ratings
- **A/B Testing**: Baseline metrics for platform experiments

---

## Acknowledgments

This project uses the MovieLens dataset provided by GroupLens Research at the University of Minnesota. The dataset structure and analysis approach were adapted from educational materials, with all SQL implementations independently developed for Microsoft SQL Server.

**Dataset Citation:**
F. Maxwell Harper and Joseph A. Konstan. 2015. The MovieLens Datasets: History and Context. ACM Transactions on Interactive Intelligent Systems (TiiS) 5, 4: 19:1–19:19.
