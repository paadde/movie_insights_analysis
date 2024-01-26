# Library
import psycopg2
import pandas as pd
from sqlalchemy import create_engine, text

# Define the database connection parameters
db_params = {
    'host': 'xxxxxxxxx',
    'database': 'xxxxxxxxx',
    'user': 'xxxxxxxxx',
    'password': 'xxxxxxxxxx'
}



# Connect to the 'xxxxxxxx' database
db_params['database'] = 'xxxxxxxx'
engine = create_engine(f'postgresql://{db_params["user"]}:{db_params["password"]}@{db_params["host"]}/{db_params["database"]}')

# Define the file paths for your CSV files
csv_files = {
    'tmdb_movie_credits': '/home/tmdb_movie_credits.csv',
    'tmdb_movie_dataset': '/home/tmdb_movie_dataset.csv',
    'tmdb_movie_ratings': '/home/tmdb_movie_ratings.csv',
}

# Load and display the contents of each CSV file to check
for table_name, file_path in csv_files.items():
    print(f"Contents of '{table_name}' CSV file:")
    df = pd.read_csv(file_path)
    print(df.head(2))  # Display the first few rows of the DataFrame
    print("\n")




# Loop through the CSV files and import them into PostgreSQL
for table_name, file_path in csv_files.items():
    df = pd.read_csv(file_path)
    df.to_sql(table_name, engine, if_exists='replace', index=False)
