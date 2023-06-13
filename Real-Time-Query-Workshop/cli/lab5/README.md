# Lab 5 - Advanced Querying
Aggregation and other more complex RediSearch queries

## Business Value Statement <a name="value"></a>
Redis provides the following additional advanced search capabilities to derive further value of Redis-held data:
* Vector Similarity Search - Store and search by ML-generated encodings of text and images
* Search + JSON Filtering - Combine the power of search with JSONPath filtering of search results
* Aggregation - Create processing pipelines of search results to extract analytic insights.

## Vector Similarity Search (VSS) <a name="vss"></a>
### Syntax
[VSS](https://redis.io/docs/stack/search/reference/vectors/)
### Data Load <a name="vss_dataload"></a>
```bash
JSON.SET vec:1 $ '{"vector":[1,1,1,1]}'
JSON.SET vec:2 $ '{"vector":[2,2,2,2]}'
JSON.SET vec:3 $ '{"vector":[3,3,3,3]}'
JSON.SET vec:4 $ '{"vector":[4,4,4,4]}'
```
### Index Creation <a name="vss_index">
```redis Command
FT.CREATE vss_idx ON JSON PREFIX 1 vec: SCHEMA $.vector AS vector VECTOR FLAT 6 TYPE FLOAT32 DIM 4 DISTANCE_METRIC L2
```


### Search <a name="vss_search">
#### Query
```redis Command
FT.SEARCH vss_idx "*=>[KNN 3 @vector $query_vec]" PARAMS 2 query_vec "\x00\x00\x00@\x00\x00\x00@\x00\x00@@\x00\x00@@" SORTBY __vector_score DIALECT 2
```

## Advanced Search Queries <a name="adv_search">
### Data Set <a name="advs_dataset">
```JSON
{
    "city": "Boston",
    "location": "-71.057083, 42.361145",
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
    "location": "-96.808891, 32.779167",
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

### Data Load  <a name="advs_dataload">
```redis warehouse:1
JSON.SET warehouse:1 $ '{"city": "Boston","location": "-71.057083, 42.361145","inventory":[{"id": 15970,"gender": "Men","season":["Fall", "Winter"],"description": "Turtle Check Men Navy Blue Shirt","price": 34.95},{"id": 59263,"gender": "Women","season": ["Fall", "Winter", "Spring", "Summer"],"description": "Titan Women Silver Watch","price": 129.99},{"id": 46885,"gender": "Boys","season": ["Fall"],"description": "Ben 10 Boys Navy Blue Slippers","price": 45.99}]}'
```
```redis warehouse:2
JSON.SET warehouse:2 $ '{"city": "Dallas","location": "-96.808891, 32.779167","inventory": [{"id": 51919,"gender": "Women","season":["Summer"],"description": "Nyk Black Horado Handbag","price": 52.49},{"id": 4602,"gender": "Unisex","season": ["Fall", "Winter"],"description": "Wildcraft Red Trailblazer Backpack","price": 50.99},{"id": 37561,"gender": "Girls","season": ["Spring", "Summer"],"description": "Madagascar3 Infant Pink Snapsuit Romper","price": 23.95}]}'
```

### Index Creation <a name="advs_index">
```redis Command
FT.CREATE wh_idx ON JSON PREFIX 1 warehouse: SCHEMA $.city as city TEXT
```


### Search w/JSON Filtering - Example 1 <a name="advs_ex1">
Find all inventory ids from the Boston warehouse that have a price > $50.
```redis Command
FT.SEARCH wh_idx '@city:(Boston)' RETURN 1 '$.inventory[?(@.price>50)].id' DIALECT 3
```

### Search w/JSON Filtering - Example 2 <a name="advs_ex2">
Find all inventory items in Dallas that are for Women or Girls
```redis Command
FT.SEARCH wh_idx '@city:(Dallas)' RETURN 1 '$.inventory[?(@.gender=="Women" || @.gender=="Girls")]' DIALECT 3
```

## Aggregation <a name="aggr">
### Syntax
[FT.AGGREGATE](https://redis.io/commands/ft.aggregate/)

### Data Set <a name="aggr_dataset">
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
### Data Load <a name="aggr_dataload">
```bash book:1
JSON.SET book:1 $ '{"title": "System Design Interview","year": 2020,"price": 35.99}'
```
```bash book:2
JSON.SET book:2 $ '{"title": "The Age of AI: And Our Human Future","year": 2021,"price": 13.99}'
```
```bash book:3
JSON.SET book:3 $ '{"title": "The Art of Doing Science and Engineering: Learning to Learn","year": 2020,"price": 20.99}'
```
```bash book:4
JSON.SET book:4 $ '{"title": "Superintelligence: Path, Dangers, Stategies","year": 2016,"price": 14.36}'
```

### Index Creation <a name="aggr_index">
```redis Command
FT.CREATE book_idx ON JSON PREFIX 1 book: SCHEMA $.title AS title TEXT $.year AS year NUMERIC $.price AS price NUMERIC
```

### Aggregation - Count <a name="aggr_count">
Find the total number of books per year
```redis Command
FT.AGGREGATE book_idx "*" GROUPBY 1 @year REDUCE COUNT 0 as count
```

### Aggregation - Sum <a name="aggr_sum">
Sum of inventory dollar value by year
```redis Command
FT.AGGREGATE book_idx "*" GROUPBY 1 @year REDUCE SUM 1 @price AS sum
```