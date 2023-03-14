# Lab 5 - Advanced Search
Aggregation and other more complex RediSearch queries
## Contents
1.  [Business Value Statement](#value)
2.  [Modules Needed](#modules)
3.  [Advanced Search Queries](#adv_search)
    1.  [Data Set](#advs_dataset)
    2.  [Data Load](#advs_dataload)
    3.  [Index Creation](#advs_index)
    4.  [Search w/JSON Filtering - Example 1](#advs_ex1)
    5.  [Search w/JSON Filtering - Example 2](#advs_ex2)
4.  [Aggregation](#aggr)
    1.  [Data Set](#aggr_dataset)
    2.  [Data Load](#aggr_dataload)
    3.  [Index Creation](#aggr_index)
    4.  [Aggregation - Count](#aggr_count)
    5.  [Aggregation - Sum](#aggr_sum)

## Business Value Statement <a name="value"></a>
Redis provides the following additional advanced search capabilities to derive further value of Redis-held data:
* Vector Similarity Search - Store and search by ML-generated encodings of text and images
* Search + JSON Filtering - Combine the power of search with JSONPath filtering of search results
* Aggregation - Create processing pipelines of search results to extract analytic insights.

## Modules Needed <a name="modules"></a>
```c#
using StackExchange.Redis;
using NRedisStack;
using NRedisStack.RedisStackCommands;
using NRedisStack.Search;
using NRedisStack.Search.Literals.Enums;
using NRedisStack.Search.Aggregation;
```

## Advanced Search Queries <a name="adv_search">
### Data Set <a name="advs_dataset">
```json
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

### Data Load  <a name="advs_dataload">
```c#
IJsonCommands json = db.JSON();
json.Set("warehouse:1", "$", new {
    city = "Boston",
    location = "-71.057083, 42.361145",
    inventory = new[] {
        new {
            id = 15970,
            gender = "Men",
            season = new[] {"Fall", "Winter"},
            description = "Turtle Check Men Navy Blue Shirt",
            price = 34.95
        },
        new {
            id = 59263,
            gender = "Women",
            season = new[] {"Fall", "Winter", "Spring", "Summer"},
            description = "Titan Women Silver Watch",
            price = 129.99
        },
        new {
            id = 46885,
            gender = "Boys",
            season = new[] {"Fall"},
            description = "Ben 10 Boys Navy Blue Slippers",
            price = 45.99
        }
    }
});
json.Set("warehouse:2", "$", new {
    city = "Dallas",
    location = "-96.808891, 32.779167",
    inventory = new[] {
        new {
            id = 51919,
            gender = "Women",
            season = new[] {"Summer"},
            description = "Nyk Black Horado Handbag",
            price = 52.49
        },
        new {
            id = 4602,
            gender = "Unisex",
            season = new[] {"Fall", "Winter"},
            description = "Wildcraft Red Trailblazer Backpack",
            price = 50.99
        },
        new {
            id = 37561,
            gender = "Girls",
            season = new[] {"Spring", "Summer"},
            description = "Madagascar3 Infant Pink Snapsuit Romper",
            price = 23.95
        }
    }
});
```

### Index Creation <a name="advs_index">
#### Command
```c#
ISearchCommands ft = db.FT();
try {ft.DropIndex("wh_idx");} catch {};
Console.WriteLine(ft.Create("wh_idx", new FTCreateParams()
                        .On(IndexDataType.JSON)
                        .Prefix("warehouse:"),
                        new Schema().AddTextField(new FieldName("$.city", "city"))));
```
#### Result
```bash
True
```

### Search w/JSON Filtering - Example 1 <a name="advs_ex1">
Find all inventory ids from all the Boston warehouse that have a price > $50.
#### Command
```c#
foreach (var doc in ft.Search("wh_idx", 
                        new Query("@city:Boston")
                            .ReturnFields(new FieldName("$.inventory[?(@.price>50)].id", "result"))
                            .Dialect(3))
                    .Documents.Select(x => x["result"]))
{
    Console.WriteLine(doc);
}  
```
#### Result
```json
[59263]
```

### Search w/JSON Filtering - Example 2 <a name="advs_ex2">
Find all inventory items in Dallas that are for Women or Girls
#### Command
```c#
foreach (var doc in ft.Search("wh_idx", 
                        new Query("@city:(Dallas)")
                            .ReturnFields(new FieldName("$.inventory[?(@.gender==\"Women\" || @.gender==\"Girls\")]", "result"))
                            .Dialect(3))
                    .Documents.Select(x => x["result"]))
{
    Console.WriteLine(doc);
} 
```
#### Result
```json
[{"id":51919,"gender":"Women","season":["Summer"],"description":"Nyk Black Horado Handbag","price":52.49},{"id":37561,"gender":"Girls","season":["Spring","Summer"],"description":"Madagascar3 Infant Pink Snapsuit Romper","price":23.95}]
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
```c#
json.Set("book:1", "$", new {
    title = "System Design Interview",
    year = 2020,
    price = 35.99
});
json.Set("book:2", "$", new {
    title =  "The Age of AI: And Our Human Future",
    year = 2021,
    price = 13.99
});
json.Set("book:3", "$", new {
    title = "The Art of Doing Science and Engineering: Learning to Learn",
    year = 2020,
    price = 20.99
});
json.Set("book:4", "$", new {
    title = "Superintelligence: Path, Dangers, Stategies",
    year = 2016,
    price = 14.36
});
```

### Index Creation <a name="aggr_index">
#### Command
```c#
Console.WriteLine(ft.Create("book_idx", new FTCreateParams()
                        .On(IndexDataType.JSON)
                        .Prefix("book:"),
                        new Schema().AddTextField(new FieldName("$.title", "title"))
                            .AddNumericField(new FieldName("$.year", "year"))
                            .AddNumericField(new FieldName("$.price", "price"))));
```
#### Result
```bash
True
```

### Aggregation - Count <a name="aggr_count">
Find the total number of books per year
#### Command
```c#
var request = new AggregationRequest("*").GroupBy("@year", Reducers.Count().As("count"));
var result = ft.Aggregate("book_idx", request);
for (var i=0; i<result.TotalResults; i++)
{
    var row = result.GetRow(i);
    Console.WriteLine($"{row["year"]}: {row["count"]}");
}
```
#### Result
```bash
2021: 1
2020: 2
2016: 1
```

### Aggregation - Sum <a name="aggr_sum">
Sum of inventory dollar value by year
#### Command
```c#
request = new AggregationRequest("*").GroupBy("@year", Reducers.Sum("@price").As("sum"));
result = ft.Aggregate("book_idx", request);
for (var i=0; i<result.TotalResults; i++)
{
    var row = result.GetRow(i);
    Console.WriteLine($"{row["year"]}: {row["sum"]}");
}
```
#### Result
```bash
2021: 13.99
2020: 56.98
2016: 14.36
```