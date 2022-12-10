# Lab 3 - Basic Search Operations
Examples of simple search operations with RediSearch 
## Data Set
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
## Data Loading
```bash
JSON.SET product:15970 $ '{"id": 15970, "gender": "Men", "season":["Fall", "Winter"], "description": "Turtle Check Men Navy Blue Shirt", "price": 34.95, "city": "Boston", "coords": "-71.057083, 42.361145"}'
```
```bash
JSON.SET product:59263 $ '{"id": 59263, "gender": "Women", "season":["Fall", "Winter", "Spring", "Summer"],"description": "Titan Women Silver Watch", "price": 129.99, "city": "Dallas", "coords": "-96.808891, 32.779167"}'
```
```bash
JSON.SET product:46885 $ '{"id": 46885, "gender": "Boys", "season":["Fall"], "description": "Ben 10 Boys Navy Blue Slippers", "price": 45.99, "city": "Denver", "coords": "-104.991531, 39.742043"}'
```
## Index Creation
### Syntax (highly abbreviated)
``` FT.CREATE <name> ON JSON PREFIX <count> <prefix> SCHEMA <fieldName> AS <alias> TEXT | TAG | NUMERIC | GEO | VECTOR ```
```bash
FT.CREATE idx1 ON JSON PREFIX 1 product: SCHEMA $.id as id NUMERIC $.gender as gender TAG $.season[*] AS season TAG $.description AS description TEXT $.price AS price NUMERIC $.city AS city TEXT $.coords AS coords GEO
```
## Search Examples
### Syntax (also abbreviated)
```FT.SEARCH <index> <query>```
#### Retrieve All
```bash
FT.SEARCH idx1 *
```
#### Single Term Text
```bash
FT.SEARCH idx1 '@description:Slippers'
```
#### Exact Phrase Text
```bash
FT.SEARCH idx1 '@description:("Blue Shirt")'
```
#### Numeric Range
```bash
FT.SEARCH idx1 '@price:[40,130]'
```
#### Tag Array
```bash
FT.SEARCH idx1 '@season:{Spring}'
```
#### Logical AND
```bash
FT.SEARCH idx1 '@price:[40, 100] @description:Blue'
```
#### Logical OR
```bash
FT.SEARCH idx1 '(@gender:{Women})|(@city:Boston)'
```
#### Negation
```bash
FT.SEARCH idx1 '-(@description:Shirt)'
```
#### Prefix
```bash
FT.SEARCH idx1 '@description:Nav*'
```
#### Suffix
```bash
FT.SEARCH idx1 '@description:*Watch'
```
#### Fuzzy
```bash
FT.SEARCH idx1 '@description:%wavy%'
```
#### Geo
Colorado Springs coords (long, lat) = -104.800644, 38.846127
```bash
FT.SEARCH idx1 '@description:%slipper% @coords:[-104.800644 38.846127 100 mi]'
```