import pandas as pd
import numpy as np
import pyodbc 
server = '' 
database = '' 
username = '' 
password = '' 
cnxn = pyodbc.connect('DRIVER={ODBC Driver 17 for SQL Server};SERVER='+server+';DATABASE='+database+';UID='+username+';PWD='+ password)

Emp_Info = pd.read_sql("SELECT * FROM Emp_Info", cnxn)
Emp_Info.info()

Emp_Info.isna().sum().sort_values(ascending=False)

EmpDepDiv = pd.read_sql("SELECT * FROM EmpDepDiv", cnxn)
EmpPosHist = pd.read_sql("SELECT * FROM EmpPosHist", cnxn)
EmpStatus = pd.read_sql("SELECT * FROM EmpStatus", cnxn)

data_frames = [Emp_Info,EmpDepDiv, EmpPosHist, EmpStatus]

from functools import reduce
df_merged = reduce(lambda  left,right: pd.merge(left,right,on=['EmployeeID'],
                    how='left'), data_frames)

df_merged.info()

df_merged[df_merged.duplicated(['EmployeeID'])]