# remove the dollar signs from the salary data in the job data csv
import csv
import pandas as pd
from pathlib import Path
import chardet

# using standard python
def import_csv(file: Path):
    fields = []
    rows = []

    with open(file, "r", encoding="Windows-1252") as f:
        csvreader = csv.reader(f)

        fields = next(csvreader)

        for row in csvreader:
            rows.append(row)

    return fields, rows

def detect_encoding(file):
    # detect the encoding of the csv to pass as an argument when opening to avoid errors
    with open(file, "rb") as f:
        result = chardet.detect(f.read(100000))
    return result

def drop_dollarsign(val):
    if type(val) == str:
        val = val.replace("$", "")
        val = val.replace(",", "")

        try:
            val = float(val)
        except ValueError:
            val = None
    return val 


def main():
    # store the file path for the data
    file = r"C:\Users\johnj\OneDrive\Documents\programming\projects\worc_api\project\data\job_posting_data_master.csv"
    file_str = file.replace("\\", "/")
    file = Path(file_str)

    # obtain the csv encoding 
    encoding_type = detect_encoding(file)

    df = pd.read_csv(file, encoding=encoding_type["encoding"])
    
    # create a list of all the salary columns in the dataset
    cols = df.columns
    salary_cols = []
    cols_to_drop = ["Salary Frequency", "Salary Description"]

    for col in cols:
        if "Salary" in col:
            salary_cols.append(col)
    
    salary_df = df[salary_cols]
    salary_df = salary_df.drop(columns=cols_to_drop)
    salary_cols = salary_df.columns

    # remove all the $ and , commas from the salary data
    df[salary_cols] = df[salary_cols].map(drop_dollarsign)
    # convert to bool
    df["CIG or SAGC?"] = df["CIG or SAGC?"].map({"Yes": True, "No": False})
    # impute Nans in salary description
    df["Salary Description"] = df["Salary Description"].fillna("Salary description not provided")

    # convert to a clean csv
    file_path = str(file_str).rsplit("/", 1)
    file_path = Path(file_path[0])
    file_path = file_path / "clean_job_data.csv"
    df.to_csv(file_path, index=False, encoding="utf-8")
    
    
    
    
     
    

if __name__ == "__main__":
    main()