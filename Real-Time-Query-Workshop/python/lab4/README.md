# Lab 4 - Advanced JSON
Redis JSON array filtering examples
## Contents
1.  [Business Value Statement](#value)
2.  [Modules Needed](#modules)
3.  [Data Set](#dataset)
4.  [Data Loading](#dataload)
5.  [Array Filtering Examples](#arrayfiltering)
    1.  [All Properties of Array](#allprops)
    2.  [All Properties of a Field](#allfield)
    3.  [Relational - Equality](#equality)
    4.  [Relational - Less Than](#lessthan)
    5.  [Relational - Greater Than or Equal](#greaterthan)
    6.  [Logical AND](#logicaland)
    7.  [Logical OR](#logicalor)
    8.  [Regex - Contains Exact](#regex_exact)
    9.  [Regex - Contains, Case Insensitive](#regex_contains)
    10.  [Regex - Begins With](#regex_begins)

## Business Value Statement <a name="value"></a>
The ability to query within a JSON object unlocks further value to the underlying data.  Redis supports JSONPath array filtering natively. 

## Modules Needed <a name="modules"></a>
```python
from redis.commands.json.path import Path
import json
```

## Data Set <a name="dataset"></a>
```JSON
{
    "city": "Boston",
    "location": "42.361145, -71.057083",
    "inventory": [
        {   
            "id": 15970,
            "gender": "Men",
            "season":["Fall", "Winter"],
            "description": "Turtle Check Men Navy Blue Shirt",
            "price": 34.95
        },
        {
            "id": 59263,
            "gender": "Women",
            "season": ["Fall", "Winter", "Spring", "Summer"],
            "description": "Titan Women Silver Watch",
            "price": 129.99
        },
        {
            "id": 46885,
            "gender": "Boys",
            "season": ["Fall"],
            "description": "Ben 10 Boys Navy Blue Slippers",
            "price": 45.99
        }
    ]
}
```
## Data Loading <a name="dataload"></a>
```python
        client.json().set('warehouse:1', '$', {
            "city": "Boston",
            "location": "42.361145, -71.057083",
            "inventory":[{
                "id": 15970,
                "gender": "Men",
                "season":["Fall", "Winter"],
                "description": "Turtle Check Men Navy Blue Shirt",
                "price": 34.95
            },{
                "id": 59263,
                "gender": "Women",
                "season": ["Fall", "Winter", "Spring", "Summer"],
                "description": "Titan Women Silver Watch",
                "price": 129.99
            },{
                "id": 46885,
                "gender": "Boys",
                "season": ["Fall"],
                "description": 
                "Ben 10 Boys Navy Blue Slippers",
                "price": 45.99
        }]})
```
## Array Filtering Examples <a name="arrayfiltering"></a>
### Syntax
[JSON.GET](https://redis.io/commands/json.get/)

### All Properties of Array <a name="allprops"></a>
Fetch all properties of an array.
#### Command
```python
result = client.json().get('warehouse:1', Path('$.inventory[*]'))
print(json.dumps(result, indent=4)) 
```
#### Result
```json
[
    {
        "id": 15970,
        "gender": "Men",
        "season": [
            "Fall",
            "Winter"
        ],
        "description": "Turtle Check Men Navy Blue Shirt",
        "price": 34.95
    },
    {
        "id": 59263,
        "gender": "Women",
        "season": [
            "Fall",
            "Winter",
            "Spring",
            "Summer"
        ],
        "description": "Titan Women Silver Watch",
        "price": 129.99
    },
    {
        "id": 46885,
        "gender": "Boys",
        "season": [
            "Fall"
        ],
        "description": "Ben 10 Boys Navy Blue Slippers",
        "price": 45.99
    }
]
```

### All Properties of a Field <a name="allfield"></a>
Fetch all values of a field within an array.
#### Command
```python
result = client.json().get('warehouse:1', Path('$.inventory[*].price'))
print(json.dumps(result, indent=4)) 
```
#### Result
```json
[
    34.95,
    129.99,
    45.99
]
```

### Relational - Equality <a name="equality"></a>
Fetch all items within an array where a text field matches a given value.
#### Command
```python
result = client.json().get('warehouse:1', Path('$.inventory[?(@.description=="Turtle Check Men Navy Blue Shirt")]'))
print(json.dumps(result, indent=4))
```
#### Result
```json
[
    {
        "id": 15970,
        "gender": "Men",
        "season": [
            "Fall",
            "Winter"
        ],
        "description": "Turtle Check Men Navy Blue Shirt",
        "price": 34.95
    }
]
```

### Relational - Less Than <a name="lessthan"></a>
Fetch all items within an array where a numeric field is less than a given value.
#### Command
```python
result = client.json().get('warehouse:1', Path('$.inventory[?(@.price<100)]'))
print(json.dumps(result, indent=4)) 
```
#### Result
```json
[
    {
        "id": 15970,
        "gender": "Men",
        "season": [
            "Fall",
            "Winter"
        ],
        "description": "Turtle Check Men Navy Blue Shirt",
        "price": 34.95
    },
    {
        "id": 46885,
        "gender": "Boys",
        "season": [
            "Fall"
        ],
        "description": "Ben 10 Boys Navy Blue Slippers",
        "price": 45.99
    }
]
```

### Relational - Greater Than or Equal <a name="greaterthan"></a>
Fetch all items within an array where a numeric field is greater than or equal to a given value.
#### Command
```python
result = client.json().get('warehouse:1', Path('$.inventory[?(@.id>=20000)]'))
print(json.dumps(result, indent=4)) 
```
#### Result
```json
[
    {
        "id": 59263,
        "gender": "Women",
        "season": [
            "Fall",
            "Winter",
            "Spring",
            "Summer"
        ],
        "description": "Titan Women Silver Watch",
        "price": 129.99
    },
    {
        "id": 46885,
        "gender": "Boys",
        "season": [
            "Fall"
        ],
        "description": "Ben 10 Boys Navy Blue Slippers",
        "price": 45.99
    }
]
```

### Logical AND <a name="logicaland"></a>
Fetch all items within an array that meet two relational operations.
#### Command
```python
result = client.json().get('warehouse:1', Path('$.inventory[?(@.gender=="Men"&&@.price>20)]'))
print(json.dumps(result, indent=4)) 
```
#### Result
```json
[
    {
        "id": 15970,
        "gender": "Men",
        "season": [
            "Fall",
            "Winter"
        ],
        "description": "Turtle Check Men Navy Blue Shirt",
        "price": 34.95
    }
]
```

### Logical OR <a name="logicalor"></a>
Fetch all items within an array that meet at least one relational operation.  In this case, return only the ids of those items.
#### Command
```python
result = client.json().get('warehouse:1', Path('$.inventory[?(@.price<100||@.gender=="Women")].id'))
print(json.dumps(result, indent=4))
```
#### Result
```json
[
    15970,
    59263,
    46885
]
```

### Regex - Contains Exact <a name="regex_exact"></a>
Fetch all items within an array that match a given regex pattern.
#### Command
```python
result = client.json().get('warehouse:1', Path('$.inventory[?(@.description =~ "Blue")]'))
print(json.dumps(result, indent=4))
```
#### Result
```json
[
    {
        "id": 15970,
        "gender": "Men",
        "season": [
            "Fall",
            "Winter"
        ],
        "description": "Turtle Check Men Navy Blue Shirt",
        "price": 34.95
    },
    {
        "id": 46885,
        "gender": "Boys",
        "season": [
            "Fall"
        ],
        "description": "Ben 10 Boys Navy Blue Slippers",
        "price": 45.99
    }
]
```

### Regex - Contains, Case Insensitive <a name="regex_contains"></a>
Fetch all items within an array where a field contains a term, case insensitive.
#### Command
```python
result = client.json().get('warehouse:1', Path('$.inventory[?(@.description =~ "(?i)watch")]'))
print(json.dumps(result, indent=4))
```
#### Result
```json
[
    {
        "id": 59263,
        "gender": "Women",
        "season": [
            "Fall",
            "Winter",
            "Spring",
            "Summer"
        ],
        "description": "Titan Women Silver Watch",
        "price": 129.99
    }
]
```

### Regex - Begins With <a name="regex_begins"></a>
Fetch all items within an array where a field begins with a given expression.
#### Command
```python
result = client.json().get('warehouse:1', Path('$.inventory[?(@.description =~ "^T")]'))
print(json.dumps(result, indent=4))
```
#### Result
```json
[
    {
        "id": 15970,
        "gender": "Men",
        "season": [
            "Fall",
            "Winter"
        ],
        "description": "Turtle Check Men Navy Blue Shirt",
        "price": 34.95
    },
    {
        "id": 59263,
        "gender": "Women",
        "season": [
            "Fall",
            "Winter",
            "Spring",
            "Summer"
        ],
        "description": "Titan Women Silver Watch",
        "price": 129.99
    }
]
```