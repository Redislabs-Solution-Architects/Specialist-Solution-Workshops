# https://curlconverter.com/
import requests
import json
from requests.adapters import HTTPAdapter
from requests.packages.urllib3.util.retry import Retry

# cluster info
cluster1     = "yuan-workshop-us-east-1-cluster.redisdemo.com"
cluster2     = "yuan-workshop-us-west-2-cluster.redisdemo.com"
username1    = "admin@admin.com"
pwd1         = "admin"
username2    = "admin@admin.com"
pwd2         = "admin"

# db info
db_name      = "crdb2"
port         = 12001
memory_size  = 100000000
replication  = True
aof_policy   = "appendfsync-every-sec"
sharding     = True
shards_count = 1

headers = {
    # Already added when you pass json= but not when you pass data=
    # 'Content-Type': 'application/json',
}

json_data = {
    'default_db_config': {
        'name': db_name,
        'bigstore': False,
        'replication': replication,
        'memory_size': memory_size,
        'module_list': [
            {
                'module_name': 'search',
                'args': 'PARTITIONS AUTO',
            },
            {
                'module_name': 'ReJSON',
            }
        ],
        'aof_policy': 'appendfsync-every-sec',
        'snapshot_policy': [],
        'sharding': sharding,
        'shards_count': shards_count,
        'shard_key_regex': [
            {
                'regex': '.*\\{(?<tag>.*)\\}.*',
            },
            {
                'regex': '(?<tag>.*)',
            },
        ],
        'port': port,
    },
    'instances': [
        {
            'cluster': {
                'url': 'https://'+cluster1+':9443',
                'credentials': {
                    'username': username1,
                    'password': pwd1,
                },
                'name': cluster1,
            },
            'compression': 6,
        },
        {
            'cluster': {
                'url': 'https://'+cluster2+':9443',
                'credentials': {
                    'username': username2,
                    'password': pwd2,
                },
                'name': cluster2,
            },
            'compression': 6,
        },
    ],
    'name': db_name,
}

s = requests.Session()
retries = Retry(total=5,
                backoff_factor=1)

s.mount('https://', HTTPAdapter(max_retries=retries))

response = s.post('https://'+cluster1+':9443/v1/crdbs', headers=headers, json=json_data, verify=False, auth=(username1, pwd1), timeout=60)

