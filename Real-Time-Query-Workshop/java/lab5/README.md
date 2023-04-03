# Lab 5 - Advanced Querying
Aggregation and other more complex RediSearch queries
## Contents
1.  [Business Value Statement](#value)
2.  [Modules Needed](#modules)
3.  [Vector Similarity Search](#vss)
    1.  [Data Load](#vss_dataload)
    2.  [Index Creation](#vss_index)
    3.  [Search](#vss_search)
4.  [Advanced Search Queries](#adv_search)
    1.  [Data Set](#advs_dataset)
    2.  [Data Load](#advs_dataload)
    3.  [Index Creation](#advs_index)
    4.  [Search w/JSON Filtering - Example 1](#advs_ex1)
    5.  [Search w/JSON Filtering - Example 2](#advs_ex2)
5.  [Aggregation](#aggr)
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
```java
import java.util.List;
import java.nio.ByteBuffer;
import java.nio.ByteOrder;
import java.util.HashMap;
import com.google.gson.Gson;
import redis.clients.jedis.JedisPooled;
import redis.clients.jedis.search.IndexDefinition;
import redis.clients.jedis.search.IndexOptions;
import redis.clients.jedis.search.Query;
import redis.clients.jedis.search.Schema;
import redis.clients.jedis.search.SearchResult;
import redis.clients.jedis.search.aggr.AggregationBuilder;
import redis.clients.jedis.search.aggr.AggregationResult;
import redis.clients.jedis.search.aggr.Reducers;
import redis.clients.jedis.search.aggr.Row;
import redis.clients.jedis.search.Document;
import org.json.JSONObject;
```
## Vector Similarity Search (VSS) <a name="vss"></a>
### Syntax
[VSS](https://redis.io/docs/stack/search/reference/vectors/)

### Data Load <a name="vss_dataload"></a>
```java
        client.jsonSet("vec:1", new JSONObject("{\"vector\": [1,1,1,1]}"));
        client.jsonSet("vec:2", new JSONObject("{\"vector\": [2,2,2,2]}"));
        client.jsonSet("vec:3", new JSONObject("{\"vector\": [3,3,3,3]}"));
        client.jsonSet("vec:4", new JSONObject("{\"vector\": [4,4,4,4]}"));
```

### Index Creation <a name="vss_index">
#### Command
```java
        HashMap<String, Object> attr = new HashMap<String, Object>();
        attr.put("TYPE", "FLOAT32");
        attr.put("DIM", "4");
        attr.put("DISTANCE_METRIC", "L2");
        Schema schema = new Schema().addVectorField("$.vector", Schema.VectorField.VectorAlgo.FLAT, attr).as("vector");
        IndexDefinition rule = new IndexDefinition(IndexDefinition.Type.JSON)
            .setPrefixes(new String[]{"vec:"});
        client.ftCreate("vss_idx", IndexOptions.defaultOptions().setDefinition(rule), schema);
```

### Search <a name="vss_search">
#### Command
Note the byte order directive below.  Redis Search is expecting vectors to be expressed in little-endian byte order.
```java
        float[] vec = new float[]{2,2,3,3};
        ByteBuffer buffer = ByteBuffer.allocate(vec.length * Float.BYTES);
        buffer.order(ByteOrder.LITTLE_ENDIAN);
        buffer.asFloatBuffer().put(vec);
        Query q = new Query("*=>[KNN 3 @vector $query_vec]")
                    .addParam("query_vec", buffer.array())
                    .setSortBy("__vector_score", true)
                    .dialect(2);
        SearchResult res = client.ftSearch("vss_idx", q);
        List<Document> docs = res.getDocuments();
        for (Document doc : docs) {
            System.out.println(doc);
        }
```
#### Result
```bash
id:vec:2, score: 1.0, payload:null, properties:[$={"vector":[2,2,2,2]}, __vector_score=2]
id:vec:3, score: 1.0, payload:null, properties:[$={"vector":[3,3,3,3]}, __vector_score=2]
id:vec:1, score: 1.0, payload:null, properties:[$={"vector":[1,1,1,1]}, __vector_score=10]
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
```java
    private class Product {
        private int id;
        private String gender;
        private String[] season;
        private String description;
        private double price;

        public Product(int id, String gender, String[] season, String description, double price) {
                this.id = id;
                this.gender = gender;
                this.season = season;
                this.description = description;
                this.price = price;
        }
    }

    private class Warehouse {
        private String city;
        private String location;
        private Product[] inventory;

        public Warehouse(String city, String location, Product[] inventory) {
                this.city = city;
                this.location = location;
                this.inventory = inventory;
        }
    }

        Product prod15970 = new Product(15970, "Men", new String[]{"Fall", "Winter"}, "Turtle Check Men Navy Blue Shirt",
            34.95);
        Product prod59263 = new Product(59263, "Women", new String[]{"Fall", "Winter", "Spring", "Summer"}, "Titan Women Silver Watch",
            129.99);
        Product prod46885 = new Product(46885, "Boys", new String[]{"Fall"}, "Ben 10 Boys Navy Blue Slippers",
            45.99);
        Product prod51919 = new Product(51919, "Women", new String[]{"Summer"}, "Nyk Black Horado Handbag",
            52.49);
        Product prod4602 = new Product(4602, "Unisex", new String[]{"Fall", "Winter"}, "Wildcraft Red Trailblazer Backpack",
            50.99);
        Product prod37561 = new Product(37561, "Girls", new String[]{"Spring", "Summer"}, "Madagascar3 Infant Pink Snapsuit Romper",
            23.95);
        
        Gson gson = new Gson();
        Warehouse wh1 = new Warehouse("Boston", "42.361145, -71.057083", 
            new Product[]{prod15970, prod59263, prod46885});
        client.jsonSet("warehouse:1", gson.toJson(wh1));  
        Warehouse wh2 = new Warehouse("Dallas", "-96.808891, 32.779167", 
            new Product[]{prod51919, prod4602, prod37561});
        client.jsonSet("warehouse:2", gson.toJson(wh2));  
```

### Index Creation <a name="advs_index">
#### Command
```java
        Schema schema = new Schema().addTextField("$.city",1.0).as("city");
        IndexDefinition rule = new IndexDefinition(IndexDefinition.Type.JSON)
            .setPrefixes(new String[]{"warehouse:"});
        client.ftCreate("wh_idx", IndexOptions.defaultOptions().setDefinition(rule), schema);
```

### Search w/JSON Filtering - Example 1 <a name="advs_ex1">
Find all inventory ids from all the Boston warehouse that have a price > $50.
#### Command
```java
        Query q = new Query("@city:Boston")
                    .returnFields("$.inventory[?(@.price>50)].id")
                    .dialect(3);
        SearchResult res = client.ftSearch("wh_idx", q);
        List<Document> docs = res.getDocuments();
        for (Document doc : docs) {
            System.out.println(doc);
        }
```
#### Result
```bash
id:warehouse:1, score: 1.0, payload:null, properties:[$.inventory[?(@.price>50)].id=[59263]]
```

### Search w/JSON Filtering - Example 2 <a name="advs_ex2">
Find all inventory items in Dallas that are for Women or Girls
#### Command
```java
        q = new Query("@city:Dallas")
                .returnFields("$.inventory[?(@.gender==\"Women\" || @.gender==\"Girls\")]")
                .dialect(3);
        res = client.ftSearch("wh_idx", q);
        docs = res.getDocuments();
        for (Document doc : docs) {
            System.out.println(doc);
        }
```
#### Result
```bash
id:warehouse:2, score: 1.0, payload:null, properties:[$.inventory[?(@.gender=="Women" || @.gender=="Girls")]=[{"id":51919,"gender":"Women","season":["Summer"],"description":"Nyk Black Horado Handbag","price":52.49},{"id":37561,"gender":"Girls","season":["Spring","Summer"],"description":"Madagascar3 Infant Pink Snapsuit Romper","price":23.95}]]
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
```java
    private class Book {
        private String title;
        private int year;
        private double price;

        public Book(String title, int year, double price) {
                this.title = title;
                this.year = year;
                this.price = price;
        }
    }

        Book book1 = new Book("System Design Interview",2020,35.99);
        Book book2 = new Book("The Age of AI: And Our Human Future",2021,13.99);
        Book book3 = new Book("The Art of Doing Science and Engineering: Learning to Learn",2020,20.99);
        Book book4 = new Book("Superintelligence: Path, Dangers, Stategies",2016,14.36);
        client.jsonSet("book:1", gson.toJson(book1)); 
        client.jsonSet("book:2", gson.toJson(book2)); 
        client.jsonSet("book:3", gson.toJson(book3)); 
        client.jsonSet("book:4", gson.toJson(book4)); 
```

### Index Creation <a name="aggr_index">
#### Command
```java
        schema = new Schema().addTextField("$.title",1.0).as("title")
                            .addNumericField("$.year").as("year")
                            .addNumericField("$.price").as("price");
        rule = new IndexDefinition(IndexDefinition.Type.JSON)
            .setPrefixes(new String[]{"book:"});
        client.ftCreate("book_idx", IndexOptions.defaultOptions().setDefinition(rule), schema); 
```

### Aggregation - Count <a name="aggr_count">
Find the total number of books per year
#### Command
```java
        AggregationBuilder ab = new AggregationBuilder("*")
            .groupBy("@year", Reducers.count().as("count"));
        AggregationResult ar = client.ftAggregate("book_idx", ab);
        for (int i=0; i < ar.getTotalResults(); i++) {
            Row row = ar.getRow(i);
            System.out.println(row.getLong("year") + ":" + row.getLong("count"));
        }
```
#### Result
```bash
2016:1
2020:2
2021:1
```

### Aggregation - Sum <a name="aggr_sum">
Sum of inventory dollar value by year
#### Command
```java
        ab = new AggregationBuilder("*")
            .groupBy("@year", Reducers.sum("@price").as("sum"));
        ar = client.ftAggregate("book_idx", ab);
        for (int i=0; i < ar.getTotalResults(); i++) {
            Row row = ar.getRow(i);
            System.out.println(row.getLong("year") + ":" + row.getDouble("sum"));
        }
```
#### Result
```bash
2016:14.36
2020:56.98
2021:13.99
```