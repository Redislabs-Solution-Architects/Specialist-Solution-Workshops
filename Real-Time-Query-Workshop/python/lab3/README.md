# Lab 3 - Basic Query Operations
Examples of simple query operations with RediSearch
## Contents
1.  [Business Value Statement](#value)
2.  [Modules Needed](#modules)
3.  [Data Set](#dataset)
4.  [Data Loading](#loading)
5.  [Index Creation](#index_creation)
6.  [Search Examples](#search_examples)
    1.  [Retrieve All](#retrieve_all)
    2.  [Single Term Text](#single_term)
    3.  [Exact Phrase Text](#exact_phrase)
    4.  [Numeric Range](#numeric_range)
    5.  [Tag Array](#tag_array)
    6.  [Logical AND](#logical_and)
    7.  [Logical OR](#logical_or)
    8.  [Negation](#negation)
    9.  [Prefix](#prefix)
    10.  [Suffix](#suffix)
    11.  [Fuzzy](#fuzzy)
    12.  [Geo](#geo)  

## Business Value Statement <a name="value"></a>
Search is an essential function to derive the value of data.  Redis provides inherent, high-speed search capabilities for JSON and Hash Set data.  

## Modules Needed <a name="modules"></a>
```python
from redis.commands.search.field import NumericField, TagField, TextField, GeoField
from redis.commands.search.indexDefinition import IndexDefinition, IndexType
from redis.commands.search.query import Query
```

## Data Set <a name="dataset"></a>
```JSON
[
    {   
        "id": 15970,
        "gender": "Men",
        "season":["Fall", "Winter"],
        "description": "Turtle Check Men Navy Blue Shirt",
        "price": 34.95,
        "city": "Boston",
        "location": "-71.057083, 42.361145"
    },
    {
        "id": 59263,
        "gender": "Women",
        "season": ["Fall", "Winter", "Spring", "Summer"],
        "description": "Titan Women Silver Watch",
        "price": 129.99,
        "city": "Dallas",
        "location": "-96.808891, 32.779167"
    },
    {
        "id": 46885,
        "gender": "Boys",
        "season": ["Fall"],
        "description": "Ben 10 Boys Navy Blue Slippers",
        "price": 45.99,
        "city": "Denver",
        "location": "-104.991531, 39.742043"
    }
]
```
## Data Loading <a name="loading"></a>
```python
        client.json().set('product:15970', '$', {"id": 15970, "gender": "Men", "season":["Fall", "Winter"], "description": "Turtle Check Men Navy Blue Shirt", "price": 34.95, "city": "Boston", "coords": "-71.057083, 42.361145"})
        client.json().set('product:59263', '$', {"id": 59263, "gender": "Women", "season":["Fall", "Winter", "Spring", "Summer"],"description": "Titan Women Silver Watch", "price": 129.99, "city": "Dallas", "coords": "-96.808891, 32.779167"})
        client.json().set('product:46885', '$', {"id": 46885, "gender": "Boys", "season":["Fall"], "description": "Ben 10 Boys Navy Blue Slippers", "price": 45.99, "city": "Denver", "coords": "-104.991531, 39.742043"})
```
## Index Creation <a name="index_creation"></a>
### Syntax
[FT.CREATE](https://redis.io/commands/ft.create/)

#### Command
```python
idx_def = IndexDefinition(index_type=IndexType.JSON, prefix=['product:'])
schema = [
    NumericField('$.id', as_name='id'),
    TagField('$.gender', as_name='gender'),
    TagField('$.season.*', as_name='season'),
    TextField('$.description', as_name='description'),
    NumericField('$.price', as_name='price'),
    TextField('$.city', as_name='city'),
    GeoField('$.coords', as_name='coords')
]
result = client.ft('idx1').create_index(schema, definition=idx_def)
print(result)
```
#### Result
```bash
b'OK'
```

## Search Examples <a name="search_examples"></a>
### Syntax
[FT.SEARCH](https://redis.io/commands/ft.search/)

### Retrieve All <a name="retrieve_all"></a>
Find all documents for a given index.
#### Command
```python
query = Query('*')
result = client.ft('idx1').search(query)
print(result)
```
#### Result
```bash
Result{3 total, docs: [Document {'id': 'product:15970', 'payload': None, 'json': '{"id":15970,"gender":"Men","season":["Fall","Winter"],"description":"Turtle Check Men Navy Blue Shirt","price":34.95,"city":"Boston","coords":"-71.057083, 42.361145"}'}, Document {'id': 'product:46885', 'payload': None, 'json': '{"id":46885,"gender":"Boys","season":["Fall"],"description":"Ben 10 Boys Navy Blue Slippers","price":45.99,"city":"Denver","coords":"-104.991531, 39.742043"}'}, Document {'id': 'product:59263', 'payload': None, 'json': '{"id":59263,"gender":"Women","season":["Fall","Winter","Spring","Summer"],"description":"Titan Women Silver Watch","price":129.99,"city":"Dallas","coords":"-96.808891, 32.779167"}'}]}
```

### Single Term Text <a name="single_term"></a>
Find all documents with a given word in a text field.
#### Command
```python
query = Query('@description:Slippers')
result = client.ft('idx1').search(query)
print(result)
```
#### Result
```bash
Result{1 total, docs: [Document {'id': 'product:46885', 'payload': None, 'json': '{"id":46885,"gender":"Boys","season":["Fall"],"description":"Ben 10 Boys Navy Blue Slippers","price":45.99,"city":"Denver","coords":"-104.991531, 39.742043"}'}]}
```

### Exact Phrase Text <a name="exact_phrase"></a>
Find all documents with a given phrase in a text field.
#### Command
```python
query = Query('@description:("Blue Shirt")')
result = client.ft('idx1').search(query)
print(result)
```
#### Result
```bash
Result{1 total, docs: [Document {'id': 'product:15970', 'payload': None, 'json': '{"id":15970,"gender":"Men","season":["Fall","Winter"],"description":"Turtle Check Men Navy Blue Shirt","price":34.95,"city":"Boston","coords":"-71.057083, 42.361145"}'}]}
```

### Numeric Range <a name="numeric_range"></a>
Find all documents with a numeric field in a given range.
#### Command
```python
        query = Query('@price:[40,130]')
        result = client.ft('idx1').search(query)
        print(result)
```
#### Result
```bash
Result{2 total, docs: [Document {'id': 'product:46885', 'payload': None, 'json': '{"id":46885,"gender":"Boys","season":["Fall"],"description":"Ben 10 Boys Navy Blue Slippers","price":45.99,"city":"Denver","coords":"-104.991531, 39.742043"}'}, Document {'id': 'product:59263', 'payload': None, 'json': '{"id":59263,"gender":"Women","season":["Fall","Winter","Spring","Summer"],"description":"Titan Women Silver Watch","price":129.99,"city":"Dallas","coords":"-96.808891, 32.779167"}'}]}
```

### Tag Array <a name="tag_array"></a>
Find all documents that contain a given value in an array field (tag).
#### Command
```python
query = Query('@season:{Spring}')
result = client.ft('idx1').search(query)
print(result)
```
#### Result
```bash
Result{1 total, docs: [Document {'id': 'product:59263', 'payload': None, 'json': '{"id":59263,"gender":"Women","season":["Fall","Winter","Spring","Summer"],"description":"Titan Women Silver Watch","price":129.99,"city":"Dallas","coords":"-96.808891, 32.779167"}'}]}
```

### Logical AND <a name="logical_and"></a>
Find all documents contain both a numeric field in a range and a word in a text field.
#### Command
```python
query = Query('@price:[40, 100] @description:Blue')
result = client.ft('idx1').search(query)
print(result)
```
#### Result
```bash
Result{1 total, docs: [Document {'id': 'product:46885', 'payload': None, 'json': '{"id":46885,"gender":"Boys","season":["Fall"],"description":"Ben 10 Boys Navy Blue Slippers","price":45.99,"city":"Denver","coords":"-104.991531, 39.742043"}'}]}
```

### Logical OR <a name="logical_or"></a>
Find all documents that either match tag value or text value.
#### Command
```python
query = Query('(@gender:{Women})|(@city:Boston)')
result = client.ft('idx1').search(query)
print(result)
```
#### Result
```bash
Result{2 total, docs: [Document {'id': 'product:15970', 'payload': None, 'json': '{"id":15970,"gender":"Men","season":["Fall","Winter"],"description":"Turtle Check Men Navy Blue Shirt","price":34.95,"city":"Boston","coords":"-71.057083, 42.361145"}'}, Document {'id': 'product:59263', 'payload': None, 'json': '{"id":59263,"gender":"Women","season":["Fall","Winter","Spring","Summer"],"description":"Titan Women Silver Watch","price":129.99,"city":"Dallas","coords":"-96.808891, 32.779167"}'}]}
```

### Negation <a name="negation"></a>
Find all documents that do not contain a given word in a text field.
#### Command
```python
query = Query('-(@description:Shirt)')
result = client.ft('idx1').search(query)
print(result)
```
#### Result
```bash
Result{2 total, docs: [Document {'id': 'product:46885', 'payload': None, 'json': '{"id":46885,"gender":"Boys","season":["Fall"],"description":"Ben 10 Boys Navy Blue Slippers","price":45.99,"city":"Denver","coords":"-104.991531, 39.742043"}'}, Document {'id': 'product:59263', 'payload': None, 'json': '{"id":59263,"gender":"Women","season":["Fall","Winter","Spring","Summer"],"description":"Titan Women Silver Watch","price":129.99,"city":"Dallas","coords":"-96.808891, 32.779167"}'}]}
```

### Prefix <a name="prefix"></a>
Find all documents that have a word that begins with a given prefix value.
#### Command
```python
query = Query('@description:Nav*')
result = client.ft('idx1').search(query)
print(result)
```
#### Result
```bash
Result{2 total, docs: [Document {'id': 'product:15970', 'payload': None, 'json': '{"id":15970,"gender":"Men","season":["Fall","Winter"],"description":"Turtle Check Men Navy Blue Shirt","price":34.95,"city":"Boston","coords":"-71.057083, 42.361145"}'}, Document {'id': 'product:46885', 'payload': None, 'json': '{"id":46885,"gender":"Boys","season":["Fall"],"description":"Ben 10 Boys Navy Blue Slippers","price":45.99,"city":"Denver","coords":"-104.991531, 39.742043"}'}]}
```

### Suffix <a name="suffix"></a>
Find all documents that contain a word that ends with a given suffix value.
#### Command
```python
query = Query('@description:*Watch')
result = client.ft('idx1').search(query)
print(result)
```
#### Result
```bash
Result{1 total, docs: [Document {'id': 'product:59263', 'payload': None, 'json': '{"id":59263,"gender":"Women","season":["Fall","Winter","Spring","Summer"],"description":"Titan Women Silver Watch","price":129.99,"city":"Dallas","coords":"-96.808891, 32.779167"}'}]}
```

### Fuzzy <a name="fuzzy"></a>
Find all documents that contain a word that is within 1 Levenshtein distance of a given word.
#### Command
```python
query = Query('@description:%wavy%')
result = client.ft('idx1').search(query)
print(result)
```
#### Result
```bash
Result{2 total, docs: [Document {'id': 'product:15970', 'payload': None, 'json': '{"id":15970,"gender":"Men","season":["Fall","Winter"],"description":"Turtle Check Men Navy Blue Shirt","price":34.95,"city":"Boston","coords":"-71.057083, 42.361145"}'}, Document {'id': 'product:46885', 'payload': None, 'json': '{"id":46885,"gender":"Boys","season":["Fall"],"description":"Ben 10 Boys Navy Blue Slippers","price":45.99,"city":"Denver","coords":"-104.991531, 39.742043"}'}]}
```

### Geo <a name="geo"></a>
Find all documents that have geographic coordinates within a given range of a given coordinate.
Colorado Springs coords (long, lat) = -104.800644, 38.846127
#### Command
```python
query = Query('@coords:[-104.800644 38.846127 100 mi]')
result = client.ft('idx1').search(query)
print(result)
```
#### Result
```bash
Result{1 total, docs: [Document {'id': 'product:46885', 'payload': None, 'json': '{"id":46885,"gender":"Boys","season":["Fall"],"description":"Ben 10 Boys Navy Blue Slippers","price":45.99,"city":"Denver","coords":"-104.991531, 39.742043"}'}]}
```
