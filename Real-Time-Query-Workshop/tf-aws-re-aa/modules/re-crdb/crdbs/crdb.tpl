# https://curlconverter.com/
import requests
import json
from requests.adapters import HTTPAdapter
from requests.packages.urllib3.util.retry import Retry

# cluster info
cluster1     = "${cluster1}"
cluster2     = "${cluster2}"
username1    = "${username1}"
pwd1         = "${pwd1}"
username2    = "${username2}"
pwd2         = "${pwd2}"

# db info
db_name      = "${db_name}"
port         = ${port}
memory_size  = ${memory_size}
replication  = ${replication}
aof_policy   = "${aof_policy}"
sharding     = ${sharding}
shards_count = ${shards_count}

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

