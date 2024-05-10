**Real Time Query Workshop**

# Lab 1 - Create your Redis Environment

See [00-Setup](../../00-Setup/README.md)

## Python Setup
You'll want to use at least Python version 3.9

### Virtual Environment
```bash
# Note your python may be at python or python3 depending on your OS
python3 -m venv .venv
source ./.venv/bin/activate
pip install redis
```
### Modules Needed
``` python
from redis import from_url
```
### Connect Client
```python
        user = 'your user'
        pwd = 'your password'
        url = 'your url'
        port = 'your port'
    
        client = from_url(f'redis://{user}:{pwd}@{url}:{port}')
        print(client.ping())
```
### Result
```bash
True
```