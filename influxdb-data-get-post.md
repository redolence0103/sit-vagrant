# InfluxDB 2.x API를 이용한 data GET/PUT Python Code
## GET DATA
```python
from influxdb_client import InfluxDBClient
import pandas as pd

org = "influxdata"
bucket = "kafka"
token = 'xxxxxxx'

#establish a connection
client = InfluxDBClient(url="http://x.x.x.x:8086", token=token, org=org)

#instantiate the WriteAPI and QueryAPI

query_api = client.query_api()
query = 'from(bucket:"kafka")\
|> range(start: -7d)\
|> filter(fn:(r) => r._measurement == "AI028_PR2")\
|> filter(fn: (r) => r["_field"] == "WTS0001_SIRS" or r["_field"] == "VCB0001_TAE") \
|> aggregateWindow(every: 5m, fn: mean, createEmpty: false)'
result = query_api.query(org=org, query=query)
results = []
for table in result:
    for record in table.records:
#        print(record.get_time().strftime('%Y-%m-%dT%H:%M:%S%mZ'))
       results.append((record.get_field(), record.get_value(), record.get_time().strftime('%Y-%m-%dT%H:%M:%SZ')))
df = pd.DataFrame(results, columns=['endpoint', 'value', 'date'])
df_pivot = df.pivot(index='date', columns='endpoint', values='value')
# print(df_pivot)

df_pivot.to_csv('ai028_pr2.csv')

client.close()
```
## POST DATA
```python
from collections import OrderedDict
from csv import DictReader

import rx
from rx import operators as ops

from influxdb_client import Point, InfluxDBClient, WriteOptions


def parse_row(row: OrderedDict):
    return Point("tae-sirs") \
        .tag("type", "vix-daily") \
        .field("TAE", float(row['VCB0001_TAE'])) \
        .field("SIRS", float(row['WTS0001_SIRS'])) \
        .time(row['date'])

data = rx \
    .from_iterable(DictReader(open('ai028_pr2.csv', 'r'))) \
    .pipe(ops.map(lambda row: parse_row(row)))

with InfluxDBClient(url="http://x.x.x.x:8086", token="xxxxxxx", org="influxdata", debug=True) as client:
        with client.write_api(write_options=WriteOptions(batch_size=50_000, flush_interval=10_000)) as write_api:
                    write_api.write(bucket="atid", record=data)
```
