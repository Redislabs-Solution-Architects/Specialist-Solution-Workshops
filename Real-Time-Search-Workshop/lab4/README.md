# Lab 4 - Advanced JSON
Redis JSON array filtering examples
## Data Set
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
## Data Loading
```bash
JSON.SET warehouse:1 $ '{"city": "Boston","location": "42.361145, -71.057083","inventory":[{"id": 15970,"gender": "Men","season":["Fall", "Winter"],"description": "Turtle Check Men Navy Blue Shirt","price": 34.95},{"id": 59263,"gender": "Women","season": ["Fall", "Winter", "Spring", "Summer"],"description": "Titan Women Silver Watch","price": 129.99},{"id": 46885,"gender": "Boys","season": ["Fall"],"description": "Ben 10 Boys Navy Blue Slippers","price": 45.99}]}'
```
## Array Filtering Examples
### Syntax
```JSON.GET <key> <path w/filter>```
### All Properties of Array
```bash
JSON.GET warehouse:1 '$.inventory[*]'
```
### All Properties of a Type
```bash
JSON.GET warehouse:1 '$.inventory[*].price'
```
### Relational - Equality
```bash
JSON.GET warehouse:1 '$.inventory[?(@.description=="Turtle Check Men Navy Blue Shirt")]'
```
### Relational - Less Than
```bash
JSON.GET warehouse:1 '$.inventory[?(@.price<100)]'
```
### Relational - Greater Than or Equal
```bash
JSON.GET warehouse:1 '$.inventory[?(@.id>=20000)]'
```
### Logical AND
```bash
JSON.GET warehouse:1 '$.inventory[?(@.gender=="Men"&&@.price>20)]'
```
### Logical OR
```bash
JSON.GET warehouse:1 '$.inventory[?(@.price<100||@.gender=="Women")].id'
```
### Regex - Contains Exact
```bash
JSON.GET warehouse:1 '$.inventory[?(@.description =~ "Blue")]'
```
### Regex - Contains, Case Insensitive
```bash
JSON.GET warehouse:1 '$.inventory[?(@.description =~ "(?i)watch")]'
```
### Regex - Begins With
```bash
JSON.GET warehouse:1 '$.inventory[?(@.description =~ "^T")]'
```
