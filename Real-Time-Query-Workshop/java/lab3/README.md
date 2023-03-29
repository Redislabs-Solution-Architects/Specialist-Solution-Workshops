# Lab 3 - Basic Query Operations
Examples of simple query operations with RediSearch
## Contents
1.  [Business Value Statement](#value)
2.  [Modules Needed](#modules)
3.  [Data Set](#dataset)
4.  [Data Loading](#loading)
5.  [Index Creation](#index_creation)
6.  [Search Examples](#search_examples)
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
## Modules Needed <a name="modules"></a>
```java
import java.util.List;
import com.google.gson.Gson;
import redis.clients.jedis.JedisPooled;
import redis.clients.jedis.search.IndexDefinition;
import redis.clients.jedis.search.IndexOptions;
import redis.clients.jedis.search.Query;
import redis.clients.jedis.search.Schema;
import redis.clients.jedis.search.SearchResult;
import redis.clients.jedis.search.Document;
```

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
```java
    private class Product {
        private int id;
        private String gender;
        private String[] season;
        private String description;
        private double price;
        private String city;
        private String coords;

        public Product(int id, String gender, String[] season, 
            String description, double price, String city, String coords) {
                this.id = id;
                this.gender = gender;
                this.season = season;
                this.description = description;
                this.price = price;
                this.city = city;
                this.coords = coords;
        }
    }

    Product prod15970 = new Product(15970, "Men", new String[]{"Fall, Winter"}, "Turtle Check Men Navy Blue Shirt",
                                34.95, "Boston", "-71.057083, 42.361145");
    Product prod59263 = new Product(59263, "Women", new String[]{"Fall, Winter", "Spring", "Summer"}, "Titan Women Silver Watch",
                                129.99, "Dallas", "-96.808891, 32.779167");
    Product prod46885 = new Product(46885, "Boys", new String[]{"Fall"}, "Ben 10 Boys Navy Blue Slippers",
                                45.99, "Denver", "-104.991531, 39.742043");
                     
    Gson gson = new Gson();
    client.jsonSet("product:15970", gson.toJson(prod15970));   
    client.jsonSet("product:59263", gson.toJson(prod59263));  
    client.jsonSet("product:46885", gson.toJson(prod46885));  
```
## Index Creation <a name="index_creation"></a>
### Syntax
[FT.CREATE](https://redis.io/commands/ft.create/)

#### Command
```java
        Schema schema = new Schema().addNumericField("$.id")
            .addTagField("$.gender").as("gender")
            .addTagField("$.season.*").as("season")
            .addTextField("$.description", 1.0).as("description")
            .addNumericField("$.price").as("price")
            .addTextField("$.city",1.0).as("city")
            .addGeoField("$.coords").as("coords");
        IndexDefinition rule = new IndexDefinition(IndexDefinition.Type.JSON)
            .setPrefixes(new String[]{"product:"});
        client.ftCreate("idx1", IndexOptions.defaultOptions().setDefinition(rule), schema);
```

## Search Examples <a name="search_examples"></a>
### Syntax
[FT.SEARCH](https://redis.io/commands/ft.search/)

### Retrieve All <a name="retrieve_all"></a>
Find all documents for a given index.
#### Command
```java
        Query q = new Query("*");
        SearchResult res = client.ftSearch("idx1", q);
        List<Document> docs = res.getDocuments();
        for (Document doc : docs) {
            System.out.println(doc);
        }
```
#### Result
```bash
id:product:15970, score: 1.0, payload:null, properties:[$={"id":15970,"gender":"Men","season":["Fall, Winter"],"description":"Turtle Check Men Navy Blue Shirt","price":34.95,"city":"Boston","coords":"-71.057083, 42.361145"}]
id:product:59263, score: 1.0, payload:null, properties:[$={"id":59263,"gender":"Women","season":["Fall, Winter","Spring","Summer"],"description":"Titan Women Silver Watch","price":129.99,"city":"Dallas","coords":"-96.808891, 32.779167"}]
id:product:46885, score: 1.0, payload:null, properties:[$={"id":59263,"gender":"Boys","season":["Fall"],"description":"Ben 10 Boys Navy Blue Slippers","price":45.99,"city":"Denver","coords":"-104.991531, 39.742043"}]
```

### Single Term Text <a name="single_term"></a>
Find all documents with a given word in a text field.
#### Command
```java
        q = new Query("@description:Slippers");
        res = client.ftSearch("idx1", q);
        docs = res.getDocuments();
        for (Document doc : docs) {
            System.out.println(doc);
        }
```
#### Result
```bash
id:product:46885, score: 1.0, payload:null, properties:[$={"id":59263,"gender":"Boys","season":["Fall"],"description":"Ben 10 Boys Navy Blue Slippers","price":45.99,"city":"Denver","coords":"-104.991531, 39.742043"}]
```

### Exact Phrase Text <a name="exact_phrase"></a>
Find all documents with a given phrase in a text field.
#### Command
```java
        q = new Query("@description:(\"Blue Shirt\")");
        res = client.ftSearch("idx1", q);
        docs = res.getDocuments();
        for (Document doc : docs) {
            System.out.println(doc);
        }
```
#### Result
```bash
id:product:15970, score: 1.0, payload:null, properties:[$={"id":15970,"gender":"Men","season":["Fall, Winter"],"description":"Turtle Check Men Navy Blue Shirt","price":34.95,"city":"Boston","coords":"-71.057083, 42.361145"}]
```

### Numeric Range <a name="numeric_range"></a>
Find all documents with a numeric field in a given range.
#### Command
```java
        q = new Query("@price:[40,130]");
        res = client.ftSearch("idx1", q);
        docs = res.getDocuments();
        for (Document doc : docs) {
            System.out.println(doc);
        }
```
#### Result
```bash
id:product:59263, score: 1.0, payload:null, properties:[$={"id":59263,"gender":"Women","season":["Fall, Winter","Spring","Summer"],"description":"Titan Women Silver Watch","price":129.99,"city":"Dallas","coords":"-96.808891, 32.779167"}]
id:product:46885, score: 1.0, payload:null, properties:[$={"id":59263,"gender":"Boys","season":["Fall"],"description":"Ben 10 Boys Navy Blue Slippers","price":45.99,"city":"Denver","coords":"-104.991531, 39.742043"}]
```

### Tag Array <a name="tag_array"></a>
Find all documents that contain a given value in an array field (tag).
#### Command
```java
        q = new Query("@season:{Spring}");
        res = client.ftSearch("idx1", q);
        docs = res.getDocuments();
        for (Document doc : docs) {
            System.out.println(doc);
        }
```
#### Result
```bash
id:product:59263, score: 1.0, payload:null, properties:[$={"id":59263,"gender":"Women","season":["Fall","Winter","Spring","Summer"],"description":"Titan Women Silver Watch","price":129.99,"city":"Dallas","coords":"-96.808891, 32.779167"}]
```

### Logical AND <a name="logical_and"></a>
Find all documents contain both a numeric field in a range and a word in a text field.
#### Command
```java
        q = new Query("@price:[40, 100] @description:Blue");
        res = client.ftSearch("idx1", q);
        docs = res.getDocuments();
        for (Document doc : docs) {
            System.out.println(doc);
        }   
```
#### Result
```bash
id:product:46885, score: 1.0, payload:null, properties:[$={"id":59263,"gender":"Boys","season":["Fall"],"description":"Ben 10 Boys Navy Blue Slippers","price":45.99,"city":"Denver","coords":"-104.991531, 39.742043"}]
```

### Logical OR <a name="logical_or"></a>
Find all documents that either match tag value or text value.
#### Command
```java
        q = new Query("(@gender:{Women})|(@city:Boston)");
        res = client.ftSearch("idx1", q);
        docs = res.getDocuments();
        for (Document doc : docs) {
            System.out.println(doc);
        }    
```
#### Result
```bash
id:product:15970, score: 1.0, payload:null, properties:[$={"id":15970,"gender":"Men","season":["Fall","Winter"],"description":"Turtle Check Men Navy Blue Shirt","price":34.95,"city":"Boston","coords":"-71.057083, 42.361145"}]
id:product:59263, score: 1.0, payload:null, properties:[$={"id":59263,"gender":"Women","season":["Fall","Winter","Spring","Summer"],"description":"Titan Women Silver Watch","price":129.99,"city":"Dallas","coords":"-96.808891, 32.779167"}]
```

### Negation <a name="negation"></a>
Find all documents that do not contain a given word in a text field.
#### Command
```java
        q = new Query("-(@description:Shirt)");
        res = client.ftSearch("idx1", q);
        docs = res.getDocuments();
        for (Document doc : docs) {
            System.out.println(doc);
        }
```
#### Result
```bash
id:product:59263, score: 1.0, payload:null, properties:[$={"id":59263,"gender":"Women","season":["Fall","Winter","Spring","Summer"],"description":"Titan Women Silver Watch","price":129.99,"city":"Dallas","coords":"-96.808891, 32.779167"}]
id:product:46885, score: 1.0, payload:null, properties:[$={"id":59263,"gender":"Boys","season":["Fall"],"description":"Ben 10 Boys Navy Blue Slippers","price":45.99,"city":"Denver","coords":"-104.991531, 39.742043"}]
```

### Prefix <a name="prefix"></a>
Find all documents that have a word that begins with a given prefix value.
#### Command
```java
        q = new Query("@description:Nav*");
        res = client.ftSearch("idx1", q);
        docs = res.getDocuments();
        for (Document doc : docs) {
            System.out.println(doc);
        }
```
#### Result
```bash
id:product:15970, score: 1.0, payload:null, properties:[$={"id":15970,"gender":"Men","season":["Fall","Winter"],"description":"Turtle Check Men Navy Blue Shirt","price":34.95,"city":"Boston","coords":"-71.057083, 42.361145"}]
id:product:46885, score: 1.0, payload:null, properties:[$={"id":59263,"gender":"Boys","season":["Fall"],"description":"Ben 10 Boys Navy Blue Slippers","price":45.99,"city":"Denver","coords":"-104.991531, 39.742043"}]
```

### Suffix <a name="suffix"></a>
Find all documents that contain a word that ends with a given suffix value.
#### Command
```java
        q = new Query("@description:*Watch");
        res = client.ftSearch("idx1", q);
        docs = res.getDocuments();
        for (Document doc : docs) {
            System.out.println(doc);
        }
```
#### Result
```bash
id:product:59263, score: 1.0, payload:null, properties:[$={"id":59263,"gender":"Women","season":["Fall","Winter","Spring","Summer"],"description":"Titan Women Silver Watch","price":129.99,"city":"Dallas","coords":"-96.808891, 32.779167"}]
```

### Fuzzy <a name="fuzzy"></a>
Find all documents that contain a word that is within 1 Levenshtein distance of a given word.
#### Command
```java
        q = new Query("@description:%wavy%");
        res = client.ftSearch("idx1", q);
        docs = res.getDocuments();
        for (Document doc : docs) {
            System.out.println(doc);
        }
```
#### Result
```bash
id:product:15970, score: 1.0, payload:null, properties:[$={"id":15970,"gender":"Men","season":["Fall","Winter"],"description":"Turtle Check Men Navy Blue Shirt","price":34.95,"city":"Boston","coords":"-71.057083, 42.361145"}]
id:product:46885, score: 1.0, payload:null, properties:[$={"id":59263,"gender":"Boys","season":["Fall"],"description":"Ben 10 Boys Navy Blue Slippers","price":45.99,"city":"Denver","coords":"-104.991531, 39.742043"}]
```

### Geo <a name="geo"></a>
Find all documents that have geographic coordinates within a given range of a given coordinate.
Colorado Springs coords (long, lat) = -104.800644, 38.846127
#### Command
```java
        System.out.println("\n*** Lab 3 - Geo ***");
        q = new Query("@coords:[-104.800644 38.846127 100 mi]");
        res = client.ftSearch("idx1", q);
        docs = res.getDocuments();
        for (Document doc : docs) {
            System.out.println(doc);
        }
```
#### Result
```bash
id:product:46885, score: 1.0, payload:null, properties:[$={"id":59263,"gender":"Boys","season":["Fall"],"description":"Ben 10 Boys Navy Blue Slippers","price":45.99,"city":"Denver","coords":"-104.991531, 39.742043"}]
```
