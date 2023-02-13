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
### Syntax (abbreviated)
``` FT.CREATE <name> ON JSON PREFIX <count> <prefix> SCHEMA <fieldName> AS <alias> TEXT | TAG | NUMERIC | GEO | VECTOR ```
#### Command
```bash
FT.CREATE idx1 ON JSON PREFIX 1 product: SCHEMA $.id as id NUMERIC $.gender as gender TAG $.season.* AS season TAG $.description AS description TEXT $.price AS price NUMERIC $.city AS city TEXT $.coords AS coords GEO
```
#### Result
```bash
"OK"
```

## Search Examples <a name="search_examples"></a>
### Syntax (abbreviated)
```FT.SEARCH <index> <query>```
### Retrieve All <a name="retrieve_all"></a>
Find all documents for a given index.
#### Command
```bash
FT.SEARCH idx1 *
```
#### Result
```bash
1) "3"
2) "product:46885"
3) 1) "$"
   2) "{\"id\":46885,\"gender\":\"Boys\",\"season\":[\"Fall\"],\"description\":\"Ben 10 Boys Navy Blue Slippers\",\"price\":45.99,\"city\":\"Denver\",\"coords\":\"-104.991531, 39.742043\"}"
4) "product:59263"
5) 1) "$"
   2) "{\"id\":59263,\"gender\":\"Women\",\"season\":[\"Fall\",\"Winter\",\"Spring\",\"Summer\"],\"description\":\"Titan Women Silver Watch\",\"price\":129.99,\"city\":\"Dallas\",\"coords\":\"-96.808891, 32.779167\"}"
6) "product:15970"
7) 1) "$"
   2) "{\"id\":15970,\"gender\":\"Men\",\"season\":[\"Fall\",\"Winter\"],\"description\":\"Turtle Check Men Navy Blue Shirt\",\"price\":34.95,\"city\":\"Boston\",\"coords\":\"-71.057083, 42.361145\"}"
```

### Single Term Text <a name="single_term"></a>
Find all documents with a given word in a text field.
#### Command
```bash
FT.SEARCH idx1 '@description:Slippers'
```
#### Result
```bash
1) "1"
2) "product:46885"
3) 1) "$"
   2) "{\"id\":46885,\"gender\":\"Boys\",\"season\":[\"Fall\"],\"description\":\"Ben 10 Boys Navy Blue Slippers\",\"price\":45.99,\"city\":\"Denver\",\"coords\":\"-104.991531, 39.742043\"}"
```

### Exact Phrase Text <a name="exact_phrase"></a>
Find all documents with a given phrase in a text field.
#### Command
```bash
FT.SEARCH idx1 '@description:("Blue Shirt")'
```
#### Result
```bash
1) "1"
2) "product:15970"
3) 1) "$"
   2) "{\"id\":15970,\"gender\":\"Men\",\"season\":[\"Fall\",\"Winter\"],\"description\":\"Turtle Check Men Navy Blue Shirt\",\"price\":34.95,\"city\":\"Boston\",\"coords\":\"-71.057083, 42.361145\"}"
```

### Numeric Range <a name="numeric_range"></a>
Find all documents with a numeric field in a given range.
#### Command
```bash
FT.SEARCH idx1 '@price:[40,130]'
```
#### Result
```bash
1) "2"
2) "product:46885"
3) 1) "$"
   2) "{\"id\":46885,\"gender\":\"Boys\",\"season\":[\"Fall\"],\"description\":\"Ben 10 Boys Navy Blue Slippers\",\"price\":45.99,\"city\":\"Denver\",\"coords\":\"-104.991531, 39.742043\"}"
4) "product:59263"
5) 1) "$"
   2) "{\"id\":59263,\"gender\":\"Women\",\"season\":[\"Fall\",\"Winter\",\"Spring\",\"Summer\"],\"description\":\"Titan Women Silver Watch\",\"price\":129.99,\"city\":\"Dallas\",\"coords\":\"-96.808891, 32.779167\"}"
```

### Tag Array <a name="tag_array"></a>
Find all documents that contain a given value in an array field (tag).
#### Command
```bash
FT.SEARCH idx1 '@season:{Spring}'
```
#### Result
```bash
1) "1"
2) "product:59263"
3) 1) "$"
   2) "{\"id\":59263,\"gender\":\"Women\",\"season\":[\"Fall\",\"Winter\",\"Spring\",\"Summer\"],\"description\":\"Titan Women Silver Watch\",\"price\":129.99,\"city\":\"Dallas\",\"coords\":\"-96.808891, 32.779167\"}"
```

### Logical AND <a name="logical_and"></a>
Find all documents contain both a numeric field in a range and a word in a text field.
#### Command
```bash
FT.SEARCH idx1 '@price:[40, 100] @description:Blue'
```
#### Result
```bash
1) "1"
2) "product:46885"
3) 1) "$"
   2) "{\"id\":46885,\"gender\":\"Boys\",\"season\":[\"Fall\"],\"description\":\"Ben 10 Boys Navy Blue Slippers\",\"price\":45.99,\"city\":\"Denver\",\"coords\":\"-104.991531, 39.742043\"}"
```

### Logical OR <a name="logical_or"></a>
Find all documents that either match tag value or text value.
#### Command
```bash
FT.SEARCH idx1 '(@gender:{Women})|(@city:Boston)'
```
#### Result
```bash
1) "2"
2) "product:59263"
3) 1) "$"
   2) "{\"id\":59263,\"gender\":\"Women\",\"season\":[\"Fall\",\"Winter\",\"Spring\",\"Summer\"],\"description\":\"Titan Women Silver Watch\",\"price\":129.99,\"city\":\"Dallas\",\"coords\":\"-96.808891, 32.779167\"}"
4) "product:15970"
5) 1) "$"
   2) "{\"id\":15970,\"gender\":\"Men\",\"season\":[\"Fall\",\"Winter\"],\"description\":\"Turtle Check Men Navy Blue Shirt\",\"price\":34.95,\"city\":\"Boston\",\"coords\":\"-71.057083, 42.361145\"}"
```

### Negation <a name="negation"></a>
Find all documents that do not contain a given word in a text field.
#### Command
```bash
FT.SEARCH idx1 '-(@description:Shirt)'
```
#### Result
```bash
1) "2"
2) "product:46885"
3) 1) "$"
   2) "{\"id\":46885,\"gender\":\"Boys\",\"season\":[\"Fall\"],\"description\":\"Ben 10 Boys Navy Blue Slippers\",\"price\":45.99,\"city\":\"Denver\",\"coords\":\"-104.991531, 39.742043\"}"
4) "product:59263"
5) 1) "$"
   2) "{\"id\":59263,\"gender\":\"Women\",\"season\":[\"Fall\",\"Winter\",\"Spring\",\"Summer\"],\"description\":\"Titan Women Silver Watch\",\"price\":129.99,\"city\":\"Dallas\",\"coords\":\"-96.808891, 32.779167\"}"
```

### Prefix <a name="prefix"></a>
Find all documents that have a word that begins with a given prefix value.
#### Command
```bash
FT.SEARCH idx1 '@description:Nav*'
```
#### Result
```bash
1) "2"
2) "product:46885"
3) 1) "$"
   2) "{\"id\":46885,\"gender\":\"Boys\",\"season\":[\"Fall\"],\"description\":\"Ben 10 Boys Navy Blue Slippers\",\"price\":45.99,\"city\":\"Denver\",\"coords\":\"-104.991531, 39.742043\"}"
4) "product:15970"
5) 1) "$"
   2) "{\"id\":15970,\"gender\":\"Men\",\"season\":[\"Fall\",\"Winter\"],\"description\":\"Turtle Check Men Navy Blue Shirt\",\"price\":34.95,\"city\":\"Boston\",\"coords\":\"-71.057083, 42.361145\"}"
```

### Suffix <a name="suffix"></a>
Find all documents that contain a word that ends with a given suffix value.
#### Command
```bash
FT.SEARCH idx1 '@description:*Watch'
```
#### Result
```bash
1) "1"
2) "product:59263"
3) 1) "$"
   2) "{\"id\":59263,\"gender\":\"Women\",\"season\":[\"Fall\",\"Winter\",\"Spring\",\"Summer\"],\"description\":\"Titan Women Silver Watch\",\"price\":129.99,\"city\":\"Dallas\",\"coords\":\"-96.808891, 32.779167\"}"
```

### Fuzzy <a name="fuzzy"></a>
Find all documents that contain a word that is within 1 Levenshtein distance of a given word. 
#### Command
```bash
FT.SEARCH idx1 '@description:%wavy%'
```
#### Result
```bash
1) "2"
2) "product:46885"
3) 1) "$"
   2) "{\"id\":46885,\"gender\":\"Boys\",\"season\":[\"Fall\"],\"description\":\"Ben 10 Boys Navy Blue Slippers\",\"price\":45.99,\"city\":\"Denver\",\"coords\":\"-104.991531, 39.742043\"}"
4) "product:15970"
5) 1) "$"
   2) "{\"id\":15970,\"gender\":\"Men\",\"season\":[\"Fall\",\"Winter\"],\"description\":\"Turtle Check Men Navy Blue Shirt\",\"price\":34.95,\"city\":\"Boston\",\"coords\":\"-71.057083, 42.361145\"}"
```

### Geo <a name="geo"></a>
Find all documents that have geographic coordinates within a given range of a given coordinate.
Colorado Springs coords (long, lat) = -104.800644, 38.846127
#### Command
```bash
FT.SEARCH idx1 '@coords:[-104.800644 38.846127 100 mi]'
```
#### Result
```bash
1) "1"
2) "product:46885"
3) 1) "$"
   2) "{\"id\":46885,\"gender\":\"Boys\",\"season\":[\"Fall\"],\"description\":\"Ben 10 Boys Navy Blue Slippers\",\"price\":45.99,\"city\":\"Denver\",\"coords\":\"-104.991531, 39.742043\"}"
```