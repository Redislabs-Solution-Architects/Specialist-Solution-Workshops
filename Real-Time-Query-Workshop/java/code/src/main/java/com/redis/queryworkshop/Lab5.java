/**
 * @fileoverview Advanced Search operations with the redis client
 * @maker Joey Whelan
 */
package com.redis.queryworkshop;
import java.util.List;
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

    
public class Lab5 {
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

    public void run(JedisPooled client) {
        System.out.println("\n*** Lab 5 - Advanced Search Queries - Index Creation ***");
        try {client.ftDropIndex("wh_idx");} catch(Exception e) {};   
        Schema schema = new Schema().addTextField("$.city",1.0).as("city");
        IndexDefinition rule = new IndexDefinition(IndexDefinition.Type.JSON)
            .setPrefixes(new String[]{"warehouse:"});
        client.ftCreate("wh_idx", IndexOptions.defaultOptions().setDefinition(rule), schema);  

        System.out.println("\n*** Lab 5 - Advanced Search Queries - Data Load ***");
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
        
        System.out.println("\n*** Lab 5 - Search w/JSON Filtering - Example 1 ***"); 
        Query q = new Query("@city:Boston")
                    .returnFields("$.inventory[?(@.price>50)].id")
                    .dialect(3);
        SearchResult res = client.ftSearch("wh_idx", q);
        List<Document> docs = res.getDocuments();
        for (Document doc : docs) {
            System.out.println(doc);
        }
             
        System.out.println("\n*** Lab 5 - Search w/JSON Filtering - Example 2 ***");
        q = new Query("@city:Dallas")
                .returnFields("$.inventory[?(@.gender==\"Women\" || @.gender==\"Girls\")]")
                .dialect(3);
        res = client.ftSearch("wh_idx", q);
        docs = res.getDocuments();
        for (Document doc : docs) {
            System.out.println(doc);
        }
        
        System.out.println("\n*** Lab 5 - Aggregation - Index Creation ***");
        try {client.ftDropIndex("book_idx");} catch(Exception e) {};   
        schema = new Schema().addTextField("$.title",1.0).as("title")
                            .addNumericField("$.year").as("year")
                            .addNumericField("$.price").as("price");
        rule = new IndexDefinition(IndexDefinition.Type.JSON)
            .setPrefixes(new String[]{"book:"});
        client.ftCreate("book_idx", IndexOptions.defaultOptions().setDefinition(rule), schema); 

        System.out.println("\n*** Lab 5 - Aggregation - Data Load ***");
        Book book1 = new Book("System Design Interview",2020,35.99);
        Book book2 = new Book("The Age of AI: And Our Human Future",2021,13.99);
        Book book3 = new Book("The Art of Doing Science and Engineering: Learning to Learn",2020,20.99);
        Book book4 = new Book("Superintelligence: Path, Dangers, Stategies",2016,14.36);
        client.jsonSet("book:1", gson.toJson(book1)); 
        client.jsonSet("book:2", gson.toJson(book2)); 
        client.jsonSet("book:3", gson.toJson(book3)); 
        client.jsonSet("book:4", gson.toJson(book4));  

        System.out.println("\n*** Lab 5 - Aggregation - Count ***");
        AggregationBuilder ab = new AggregationBuilder("*")
            .groupBy("@year", Reducers.count().as("count"));
        AggregationResult ar = client.ftAggregate("book_idx", ab);
        for (int i=0; i < ar.getTotalResults(); i++) {
            Row row = ar.getRow(i);
            System.out.println(row.getLong("year") + ":" + row.getLong("count"));
        }

        System.out.println("\n*** Lab 5 - Aggregation - Sum ***");
        ab = new AggregationBuilder("*")
            .groupBy("@year", Reducers.sum("@price").as("sum"));
        ar = client.ftAggregate("book_idx", ab);
        for (int i=0; i < ar.getTotalResults(); i++) {
            Row row = ar.getRow(i);
            System.out.println(row.getLong("year") + ":" + row.getDouble("sum"));
        }
    }
}