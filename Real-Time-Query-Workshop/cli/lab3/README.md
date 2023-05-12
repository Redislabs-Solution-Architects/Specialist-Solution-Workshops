# Lab 3 - Basic Query Operations
Examples of simple query operations with RediSearch 
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
```bash
JSON.SET product:15970 $ '{"id": 15970, "gender": "Men", "season":["Fall", "Winter"], "description": "Turtle Check Men Navy Blue Shirt", "price": 34.95, "city": "Boston", "coords": "-71.057083, 42.361145"}'
```
```bash
JSON.SET product:59263 $ '{"id": 59263, "gender": "Women", "season":["Fall", "Winter", "Spring", "Summer"],"description": "Titan Women Silver Watch", "price": 129.99, "city": "Dallas", "coords": "-96.808891, 32.779167"}'
```
```bash
JSON.SET product:46885 $ '{"id": 46885, "gender": "Boys", "season":["Fall"], "description": "Ben 10 Boys Navy Blue Slippers", "price": 45.99, "city": "Denver", "coords": "-104.991531, 39.742043"}'
```
## Index Creation <a name="index_creation"></a>
### Syntax
[FT.CREATE](https://redis.io/commands/ft.create/)
```redis Command
FT.CREATE idx1 ON JSON PREFIX 1 product: SCHEMA $.id as id NUMERIC $.gender as gender TAG $.season.* AS season TAG $.description AS description TEXT $.price AS price NUMERIC $.city AS city TEXT $.coords AS coords GEO
```

## Search Examples <a name="search_examples"></a>
### Syntax
[FT.SEARCH](https://redis.io/commands/ft.search/)
### Retrieve All <a name="retrieve_all"></a>
Find all documents for a given index.
```redis Command
FT.SEARCH idx1 *
```

### Single Term Text <a name="single_term"></a>
Find all documents with a given word in a text field.
```redis Command
FT.SEARCH idx1 '@description:Slippers'
```

### Exact Phrase Text <a name="exact_phrase"></a>
Find all documents with a given phrase in a text field.
```redis Command
FT.SEARCH idx1 '@description:("Blue Shirt")'
```

### Numeric Range <a name="numeric_range"></a>
Find all documents with a numeric field in a given range.
```redis Command
FT.SEARCH idx1 '@price:[40,130]'
```

### Tag Array <a name="tag_array"></a>
Find all documents that contain a given value in an array field (tag).
```redis Command
FT.SEARCH idx1 '@season:{Spring}'
```

### Logical AND <a name="logical_and"></a>
Find all documents contain both a numeric field in a range and a word in a text field.
```redis Command
FT.SEARCH idx1 '@price:[40, 100] @description:Blue'
```

### Logical OR <a name="logical_or"></a>
Find all documents that either match tag value or text value.
```redis Command
FT.SEARCH idx1 '(@gender:{Women})|(@city:Boston)'
```

### Negation <a name="negation"></a>
Find all documents that do not contain a given word in a text field.
```redis Command
FT.SEARCH idx1 '-(@description:Shirt)'
```

### Prefix <a name="prefix"></a>
Find all documents that have a word that begins with a given prefix value.
```redis Command
FT.SEARCH idx1 '@description:Nav*'
```

### Suffix <a name="suffix"></a>
Find all documents that contain a word that ends with a given suffix value.
```redis Command
FT.SEARCH idx1 '@description:*Watch'
```

### Fuzzy <a name="fuzzy"></a>
Find all documents that contain a word that is within 1 Levenshtein distance of a given word.
```redis Command
FT.SEARCH idx1 '@description:%wavy%'
```

### Geo <a name="geo"></a>
Find all documents that have geographic coordinates within a given range of a given coordinate.
Colorado Springs coords (long, lat) = -104.800644, 38.846127
```redis Command
FT.SEARCH idx1 '@coords:[-104.800644 38.846127 100 mi]'
```