# Lab 3 - Basic Search Operations
Examples of simple search operations with RediSearch 
## Contents
1.  [Business Value Statement](#value)
2.  [Data Set](#dataset)
3.  [Data Loading](#loading)
4.  [Index Creation](#index_creation)
5.  [Search Examples](#search_examples)
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
        "location": "42.361145, -71.057083"
    },
    {
        "id": 59263,
        "gender": "Women",
        "season": ["Fall", "Winter", "Spring", "Summer"],
        "description": "Titan Women Silver Watch",
        "price": 129.99,
        "city": "Dallas",
        "location": "32.779167, -96.808891"
    },
    {
        "id": 46885,
        "gender": "Boys",
        "season": ["Fall"],
        "description": "Ben 10 Boys Navy Blue Slippers",
        "price": 45.99,
        "city": "Denver",
        "location": "39.742043, -104.991531"
    }
]
```
## Data Loading <a name="loading"></a>
```javascript
    await client.json.set('product:15970', '$', {"id": 15970, "gender": "Men", "season":["Fall", "Winter"], "description": "Turtle Check Men Navy Blue Shirt", "price": 34.95, "city": "Boston", "coords": "-71.057083, 42.361145"});
    await client.json.set('product:59263', '$', {"id": 59263, "gender": "Women", "season":["Fall", "Winter", "Spring", "Summer"],"description": "Titan Women Silver Watch", "price": 129.99, "city": "Dallas", "coords": "-96.808891, 32.779167"});
    await client.json.set('product:46885', '$', {"id": 46885, "gender": "Boys", "season":["Fall"], "description": "Ben 10 Boys Navy Blue Slippers", "price": 45.99, "city": "Denver", "coords": "-104.991531, 39.742043"});
```
## Index Creation <a name="index_creation"></a>
### Syntax (abbreviated)
```javascript
   client.ft.create(idx, {field: {type: SchemaFieldType, AS: name}},... {ON: obtype, PREFIX: pname});
```
#### Command
```javascript
    let result = await client.ft.create('idx1', {
        '$.id': {
            type: SchemaFieldTypes.NUMERIC,
            AS: 'id'
        },
        '$.gender': {
            type: SchemaFieldTypes.TAG,
            AS: 'gender'
        }, 
        '$.season.*': {
            type: SchemaFieldTypes.TAG,
            AS: 'season'
        },
        '$.description': {
            type: SchemaFieldTypes.TEXT,
            AS: 'description'
        },
        '$.price': {
            type: SchemaFieldTypes.NUMERIC,
            AS: 'price'
        },
        '$.city': {
            type: SchemaFieldTypes.TEXT,
            AS: 'city'
        },
        '$.coords': {
            type: SchemaFieldTypes.GEO,
            AS: 'coords'
        }
     }, { ON: 'JSON', PREFIX: 'product:'});
    console.log(result);
```
#### Result
```bash
OK
```

## Search Examples <a name="search_examples"></a>
### Syntax (abbreviated)
```javascript
client.ft.search(idx, query, {options});
```
### Retrieve All <a name="retrieve_all"></a>
Find all documents for a given index.
#### Command
```javascript
    result = await client.ft.search('idx1', '*');
    console.log(JSON.stringify(result, null, 4));
```
#### Result
```json
{
    "total": 3,
    "documents": [
        {
            "id": "product:15970",
            "value": {
                "id": 15970,
                "gender": "Men",
                "season": [
                    "Fall",
                    "Winter"
                ],
                "description": "Turtle Check Men Navy Blue Shirt",
                "price": 34.95,
                "city": "Boston",
                "coords": "-71.057083, 42.361145"
            }
        },
        {
            "id": "product:46885",
            "value": {
                "id": 46885,
                "gender": "Boys",
                "season": [
                    "Fall"
                ],
                "description": "Ben 10 Boys Navy Blue Slippers",
                "price": 45.99,
                "city": "Denver",
                "coords": "-104.991531, 39.742043"
            }
        },
        {
            "id": "product:59263",
            "value": {
                "id": 59263,
                "gender": "Women",
                "season": [
                    "Fall",
                    "Winter",
                    "Spring",
                    "Summer"
                ],
                "description": "Titan Women Silver Watch",
                "price": 129.99,
                "city": "Dallas",
                "coords": "-96.808891, 32.779167"
            }
        }
    ]
}
```

### Single Term Text <a name="single_term"></a>
Find all documents with a given word in a text field.
#### Command
```javascript
    result = await client.ft.search('idx1', '@description:Slippers');
    console.log(JSON.stringify(result, null, 4));
```
#### Result
```json
{
    "total": 1,
    "documents": [
        {
            "id": "product:46885",
            "value": {
                "id": 46885,
                "gender": "Boys",
                "season": [
                    "Fall"
                ],
                "description": "Ben 10 Boys Navy Blue Slippers",
                "price": 45.99,
                "city": "Denver",
                "coords": "-104.991531, 39.742043"
            }
        }
    ]
}
```

### Exact Phrase Text <a name="exact_phrase"></a>
Find all documents with a given phrase in a text field.
#### Command
```javascript
    result = await client.ft.search('idx1', '@description:("Blue Shirt")');
    console.log(JSON.stringify(result, null, 4));
```
#### Result
```json
{
    "total": 1,
    "documents": [
        {
            "id": "product:15970",
            "value": {
                "id": 15970,
                "gender": "Men",
                "season": [
                    "Fall",
                    "Winter"
                ],
                "description": "Turtle Check Men Navy Blue Shirt",
                "price": 34.95,
                "city": "Boston",
                "coords": "-71.057083, 42.361145"
            }
        }
    ]
}
```

### Numeric Range <a name="numeric_range"></a>
Find all documents with a numeric field in a given range.
#### Command
```javascript
    result = await client.ft.search('idx1', '@price:[40,130]');
    console.log(JSON.stringify(result, null, 4));
```
#### Result
```json
{
    "total": 2,
    "documents": [
        {
            "id": "product:46885",
            "value": {
                "id": 46885,
                "gender": "Boys",
                "season": [
                    "Fall"
                ],
                "description": "Ben 10 Boys Navy Blue Slippers",
                "price": 45.99,
                "city": "Denver",
                "coords": "-104.991531, 39.742043"
            }
        },
        {
            "id": "product:59263",
            "value": {
                "id": 59263,
                "gender": "Women",
                "season": [
                    "Fall",
                    "Winter",
                    "Spring",
                    "Summer"
                ],
                "description": "Titan Women Silver Watch",
                "price": 129.99,
                "city": "Dallas",
                "coords": "-96.808891, 32.779167"
            }
        }
    ]
}
```

### Tag Array <a name="tag_array"></a>
Find all documents that contain a given value in an array field (tag).
#### Command
```javascript
    result = await client.ft.search('idx1', '@season:{Spring}');
    console.log(JSON.stringify(result, null, 4));
```
#### Result
```json
{
    "total": 1,
    "documents": [
        {
            "id": "product:59263",
            "value": {
                "id": 59263,
                "gender": "Women",
                "season": [
                    "Fall",
                    "Winter",
                    "Spring",
                    "Summer"
                ],
                "description": "Titan Women Silver Watch",
                "price": 129.99,
                "city": "Dallas",
                "coords": "-96.808891, 32.779167"
            }
        }
    ]
}
```

### Logical AND <a name="logical_and"></a>
Find all documents contain both a numeric field in a range and a word in a text field.
#### Command
```javascript
    result = await client.ft.search('idx1', '@price:[40, 100] @description:Blue');
    console.log(JSON.stringify(result, null, 4));
```
#### Result
```json
{
    "total": 1,
    "documents": [
        {
            "id": "product:46885",
            "value": {
                "id": 46885,
                "gender": "Boys",
                "season": [
                    "Fall"
                ],
                "description": "Ben 10 Boys Navy Blue Slippers",
                "price": 45.99,
                "city": "Denver",
                "coords": "-104.991531, 39.742043"
            }
        }
    ]
}
```

### Logical OR <a name="logical_or"></a>
Find all documents that either match tag value or text value.
#### Command
```javascript
    result = await client.ft.search('idx1', '(@gender:{Women})|(@city:Boston)');
    console.log(JSON.stringify(result, null, 4));
```
#### Result
```json
{
    "total": 2,
    "documents": [
        {
            "id": "product:15970",
            "value": {
                "id": 15970,
                "gender": "Men",
                "season": [
                    "Fall",
                    "Winter"
                ],
                "description": "Turtle Check Men Navy Blue Shirt",
                "price": 34.95,
                "city": "Boston",
                "coords": "-71.057083, 42.361145"
            }
        },
        {
            "id": "product:59263",
            "value": {
                "id": 59263,
                "gender": "Women",
                "season": [
                    "Fall",
                    "Winter",
                    "Spring",
                    "Summer"
                ],
                "description": "Titan Women Silver Watch",
                "price": 129.99,
                "city": "Dallas",
                "coords": "-96.808891, 32.779167"
            }
        }
    ]
}
```

### Negation <a name="negation"></a>
Find all documents that do not contain a given word in a text field.
#### Command
```javascript
    result = await client.ft.search('idx1', '-(@description:Shirt)');
    console.log(JSON.stringify(result, null, 4));
```
#### Result
```json
{
    "total": 2,
    "documents": [
        {
            "id": "product:46885",
            "value": {
                "id": 46885,
                "gender": "Boys",
                "season": [
                    "Fall"
                ],
                "description": "Ben 10 Boys Navy Blue Slippers",
                "price": 45.99,
                "city": "Denver",
                "coords": "-104.991531, 39.742043"
            }
        },
        {
            "id": "product:59263",
            "value": {
                "id": 59263,
                "gender": "Women",
                "season": [
                    "Fall",
                    "Winter",
                    "Spring",
                    "Summer"
                ],
                "description": "Titan Women Silver Watch",
                "price": 129.99,
                "city": "Dallas",
                "coords": "-96.808891, 32.779167"
            }
        }
    ]
}
```

### Prefix <a name="prefix"></a>
Find all documents that have a word that begins with a given prefix value.
#### Command
```javascript
    result = await client.ft.search('idx1', '@description:Nav*');
    console.log(JSON.stringify(result, null, 4));
```
#### Result
```json
{
    "total": 2,
    "documents": [
        {
            "id": "product:15970",
            "value": {
                "id": 15970,
                "gender": "Men",
                "season": [
                    "Fall",
                    "Winter"
                ],
                "description": "Turtle Check Men Navy Blue Shirt",
                "price": 34.95,
                "city": "Boston",
                "coords": "-71.057083, 42.361145"
            }
        },
        {
            "id": "product:46885",
            "value": {
                "id": 46885,
                "gender": "Boys",
                "season": [
                    "Fall"
                ],
                "description": "Ben 10 Boys Navy Blue Slippers",
                "price": 45.99,
                "city": "Denver",
                "coords": "-104.991531, 39.742043"
            }
        }
    ]
}
```

### Suffix <a name="suffix"></a>
Find all documents that contain a word that ends with a given suffix value.
#### Command
```javascript
    result = await client.ft.search('idx1', '@description:*Watch');
    console.log(JSON.stringify(result, null, 4));
```
#### Result
```json
{
    "total": 1,
    "documents": [
        {
            "id": "product:59263",
            "value": {
                "id": 59263,
                "gender": "Women",
                "season": [
                    "Fall",
                    "Winter",
                    "Spring",
                    "Summer"
                ],
                "description": "Titan Women Silver Watch",
                "price": 129.99,
                "city": "Dallas",
                "coords": "-96.808891, 32.779167"
            }
        }
    ]
}
```

### Fuzzy <a name="fuzzy"></a>
Find all documents that contain a word that is within 1 Levenshtein distance of a given word. 
#### Command
```javascript
    result = await client.ft.search('idx1', '@description:%wavy%');
    console.log(JSON.stringify(result, null, 4));
```
#### Result
```json
{
    "total": 2,
    "documents": [
        {
            "id": "product:15970",
            "value": {
                "id": 15970,
                "gender": "Men",
                "season": [
                    "Fall",
                    "Winter"
                ],
                "description": "Turtle Check Men Navy Blue Shirt",
                "price": 34.95,
                "city": "Boston",
                "coords": "-71.057083, 42.361145"
            }
        },
        {
            "id": "product:46885",
            "value": {
                "id": 46885,
                "gender": "Boys",
                "season": [
                    "Fall"
                ],
                "description": "Ben 10 Boys Navy Blue Slippers",
                "price": 45.99,
                "city": "Denver",
                "coords": "-104.991531, 39.742043"
            }
        }
    ]
}
```

### Geo <a name="geo"></a>
Find all documents that have geographic coordinates within a given range of a given coordinate.
Colorado Springs coords (long, lat) = -104.800644, 38.846127
#### Command
```javascript
    result = await client.ft.search('idx1', '@coords:[-104.800644 38.846127 100 mi]');
    console.log(JSON.stringify(result, null, 4));
```
#### Result
```json
{
    "total": 1,
    "documents": [
        {
            "id": "product:46885",
            "value": {
                "id": 46885,
                "gender": "Boys",
                "season": [
                    "Fall"
                ],
                "description": "Ben 10 Boys Navy Blue Slippers",
                "price": 45.99,
                "city": "Denver",
                "coords": "-104.991531, 39.742043"
            }
        }
    ]
}
```