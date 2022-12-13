# Lab 5 - Advanced Search
Aggregation and other more complex RediSearch queries
## Vector Similarity Search (VSS)
### Data Set
- Image 16185: Enroute Men Leather Black Formal Shoes  
![shoes](16185.jpg)
- Image 4790 ADIDAS Sky Ball Brown T-shirt  
![shirt](4790.jpg)
- Image 25628 Fastrack Women Charcoal Grey Dial Watch  
![watch](25628.jpg)
### Data Load
See vss_load.txt.  Copy/paste each JSON.SET command to the CLI or Workbench and execute.
### Index Creation
```bash
FT.CREATE vss_idx ON JSON PREFIX 1 image: SCHEMA $.image_id AS image_id TAG $.image_vector AS image_vector VECTOR FLAT 6 TYPE FLOAT32 DIM 512 DISTANCE_METRIC L2
```
### Search
#### Query Item
- Image 35460: Doodle Boys Printed Green T-shirt  
![shirt](35460.jpg)
#### Query
See vss_query.txt.  Copy/paste the command and execute in the CLI or Workbench.
## Advanced Search Queries
### Data Set
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
},
{
    "city": "Dallas",
    "location": "32.779167, -96.808891",
    "inventory": [
        {   
            "id": 51919,
            "gender": "Women",
            "season":["Summer"],
            "description": "Nyk Black Horado Handbag",
            "price": 52.49
        },
        {
            "id": 4602,
            "gender": "Unisex",
            "season": ["Fall", "Winter"],
            "description": "Wildcraft Red Trailblazer Backpack",
            "price": 50.99
        },
        {
            "id": 37561,
            "gender": "Girls",
            "season": ["Spring", "Summer"],
            "description": "Madagascar3 Infant Pink Snapsuit Romper",
            "price": 23.95
        }
    ]
}
```
### Data Load
```bash
JSON.SET warehouse:1 $ '{"city": "Boston","location": "-71.057083, 42.361145","inventory":[{"id": 15970,"gender": "Men","season":["Fall", "Winter"],"description": "Turtle Check Men Navy Blue Shirt","price": 34.95},{"id": 59263,"gender": "Women","season": ["Fall", "Winter", "Spring", "Summer"],"description": "Titan Women Silver Watch","price": 129.99},{"id": 46885,"gender": "Boys","season": ["Fall"],"description": "Ben 10 Boys Navy Blue Slippers","price": 45.99}]}'
```
```bash
JSON.SET warehouse:2 $ '{"city": "Dallas","location": "-96.808891, 32.779167","inventory": [{"id": 51919,"gender": "Women","season":["Summer"],"description": "Nyk Black Horado Handbag","price": 52.49},{"id": 4602,"gender": "Unisex","season": ["Fall", "Winter"],"description": "Wildcraft Red Trailblazer Backpack","price": 50.99},{"id": 37561,"gender": "Girls","season": ["Spring", "Summer"],"description": "Madagascar3 Infant Pink Snapsuit Romper","price": 23.95}]}'
```
### Index Creation
```bash
FT.CREATE wh_idx ON JSON PREFIX 1 warehouse: SCHEMA $.city as city TEXT $.location as location GEO $.inventory[*].id as id NUMERIC $.inventory[*].gender as gender TAG $.inventory[*].season.* AS season TAG $.inventory[*].description AS description TEXT $.inventory[*].price AS price NUMERIC
```
### Search w/JSON Filtering - Example 1
Find all inventory ids from all warehouses that have a season value of Fall and Price > $50.
#### Command
```bash
FT.SEARCH wh_idx '@season:{Fall}' RETURN 1 '$.inventory[?(@.price>50)].id' DIALECT 3
```
#### Result
```bash
1) "2"
2) "warehouse:2"
3) 1) "$.inventory[?(@.price>50)].id"
   2) "[51919,4602]"
4) "warehouse:1"
5) 1) "$.inventory[?(@.price>50)].id"
   2) "[59263]"
```
### Search w/JSON Filtering - Example 2
Find all inventory items in Dallas that are for Women or Girls
#### Command
```bash
FT.SEARCH wh_idx '@city:(Dallas)' RETURN 1 '$.inventory[?(@.gender=="Women" || @.gender=="Girls")]' DIALECT 3
```
#### Result
```bash
1) "1"
2) "warehouse:2"
3) 1) "$.inventory[?(@.gender==\"Women\" || @.gender==\"Girls\")]"
   2) "[{\"id\":51919,\"gender\":\"Women\",\"season\":[\"Summer\"],\"description\":\"Nyk Black Horado Handbag\",\"price\":52.49},{\"id\":37561,\"gender\":\"Girls\",\"season\":[\"Spring\",\"Summer\"],\"description\":\"Madagascar3 Infant Pink Snapsuit Romper\",\"price\":23.95}]"
```
## Aggregation
### Syntax
See redis.io
### Data Set
```JSON
{
    "title": "System Design Interview",
    "year": 2020,
    "price": 35.99
},
{
    "title": "The Age of AI: And Our Human Future",
    "year": 2021,
    "price": 13.99
},
{
    "title": "The Art of Doing Science and Engineering: Learning to Learn",
    "year": 2020,
    "price": 20.99
},
{
    "title": "Superintelligence: Path, Dangers, Stategies",
    "year": 2016,
    "price": 14.36
}
```
### Data Loading
```bash
JSON.SET book:1 $ '{"title": "System Design Interview","year": 2020,"price": 35.99}'
```
```bash
JSON.SET book:2 $ '{"title": "The Age of AI: And Our Human Future","year": 2021,"price": 13.99}'
```
```bash
JSON.SET book:3 $ '{"title": "The Art of Doing Science and Engineering: Learning to Learn","year": 2020,"price": 20.99}'
```
```bash
JSON.SET book:4 $ '{"title": "Superintelligence: Path, Dangers, Stategies","year": 2016,"price": 14.36}'
```
### Index Creation
```bash
FT.CREATE book_idx ON JSON PREFIX 1 book: SCHEMA $.title AS title TEXT $.year AS year NUMERIC $.price AS price NUMERIC
```
### Aggregation - Count
Find the total number of books per year
#### Command
```bash
FT.AGGREGATE book_idx "*" GROUPBY 1 @year REDUCE COUNT 0 as count
```
#### Result
```bash
1) "3"
2) 1) "year"
   2) "2021"
   3) "count"
   4) "1"
3) 1) "year"
   2) "2016"
   3) "count"
   4) "1"
4) 1) "year"
   2) "2020"
   3) "count"
   4) "2"
```
### Aggregation
Sum of inventory dollar value by year
#### Command
```bash
FT.AGGREGATE book_idx "*" GROUPBY 1 @year REDUCE SUM 1 @price AS sum
```
#### Result
```bash
1) "3"
2) 1) "year"
   2) "2021"
   3) "sum"
   4) "13.99"
3) 1) "year"
   2) "2016"
   3) "sum"
   4) "14.36"
4) 1) "year"
   2) "2020"
   3) "sum"
   4) "56.98"
```