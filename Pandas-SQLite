## Large File 전처리를 위한 Python Code
### file 및 library 설정
```python
import numpy as np
import pandas as pd
import sqlite3
from sqlalchemy import create_engine
DIR = '/home/atid/csv'
FILE = '/2msr.csv'
file = '{}{}'.format(DIR, FILE)
# print('File Directory: {}'.format(file))
# print(pd.read_csv(file, nrows=2))
```
### Pandas 사용을 위한 코드
1) SQLite Database connector 생성
2) 묶음으로 분리하여 Database에 Load
3) SQL query를 사용한 Pandas DataFrame 구성
```python
# CREATE A CONNECTOR TO A DATABASE
csv_database = create_engine('sqlite:///csv_database.db')
chunksize = 100000
i = 0
j = 0
for df in pd.read_csv(file, chunksize=chunksize, iterator=True):
    df = df.rename(columns = {c: c.replace(' ', '') for c in df.columns} )
    df.index += j
    
    df.to_sql('data_use', csv_database, if_exists = 'append')
    j = df.index[-1]+1
    
    print('| index: {}'.format(j))
```
```python
df = pd.read_sql_query('select * from data_use where Country="Botswana"', csv_database)
df
```
