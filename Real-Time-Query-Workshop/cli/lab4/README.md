# Lab 4 - Advanced JSON
Redis JSON array filtering examples

## Business Value Statement <a name="value"></a>
The ability to query within a JSON object unlocks further value to the underlying data.  Redis supports JSONPath array filtering natively. 
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
```bash
JSON.SET warehouse:1 $ '{"city": "Boston","location": "42.361145, -71.057083","inventory":[{"id": 15970,"gender": "Men","season":["Fall", "Winter"],"description": "Turtle Check Men Navy Blue Shirt","price": 34.95},{"id": 59263,"gender": "Women","season": ["Fall", "Winter", "Spring", "Summer"],"description": "Titan Women Silver Watch","price": 129.99},{"id": 46885,"gender": "Boys","season": ["Fall"],"description": "Ben 10 Boys Navy Blue Slippers","price": 45.99}]}'
```
## Array Filtering Examples <a name="arrayfiltering"></a>
### Syntax
[JSON.GET](https://redis.io/commands/json.get/)
### All Properties of Array <a name="allprops"></a>
Fetch all properties of an array.
```redis Command
JSON.GET warehouse:1 '$.inventory[*]'
```

### All Properties of a Field <a name="allfield"></a>
Fetch all values of a field within an array.
```redis Command
JSON.GET warehouse:1 '$.inventory[*].price'
```

### Relational - Equality <a name="equality"></a>
Fetch all items within an array where a text field matches a given value.
```redis Command
JSON.GET warehouse:1 '$.inventory[?(@.description=="Turtle Check Men Navy Blue Shirt")]'
```

### Relational - Less Than <a name="lessthan"></a>
Fetch all items within an array where a numeric field is less than a given value.
```redis Command
JSON.GET warehouse:1 '$.inventory[?(@.price<100)]'
```

### Relational - Greater Than or Equal <a name="greaterthan"></a>
Fetch all items within an array where a numeric field is greater than or equal to a given value.
```redis Command
JSON.GET warehouse:1 '$.inventory[?(@.id>=20000)]'
```

### Logical AND <a name="logicaland"></a>
Fetch all items within an array that meet two relational operations.
```redis Command
JSON.GET warehouse:1 '$.inventory[?(@.gender=="Men"&&@.price>20)]'
```

### Logical OR <a name="logicalor"></a>
Fetch all items within an array that meet at least one relational operation.  In this case, return only the ids of those items.
```redis Command
JSON.GET warehouse:1 '$.inventory[?(@.price<100||@.gender=="Women")].id'
```

### Regex - Contains Exact <a name="regex_exact"></a>
Fetch all items within an array that match a given regex pattern.
```redis Command
JSON.GET warehouse:1 '$.inventory[?(@.description =~ "Blue")]'
```

### Regex - Contains, Case Insensitive <a name="regex_contains"></a>
Fetch all items within an array where a field contains a term, case insensitive.
```redis Command
JSON.GET warehouse:1 '$.inventory[?(@.description =~ "(?i)watch")]'
```

### Regex - Begins With <a name="regex_begins"></a>
Fetch all items within an array where a field begins with a given expression.
```redis Command
JSON.GET warehouse:1 '$.inventory[?(@.description =~ "^T")]'
```
