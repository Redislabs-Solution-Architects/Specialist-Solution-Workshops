/**
 * @fileoverview Basic Search operations with the redis client
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
import redis.clients.jedis.search.Document;

public class Lab3 {
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

    public void run(JedisPooled client) { 
        System.out.println("\n*** Lab 3 - Index Creation ***");
        try {client.ftDropIndex("idx1");} catch(Exception e) {};
        
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

        System.out.println("\n*** Lab 3 - Data Loading ***");
        Product prod15970 = new Product(15970, "Men", new String[]{"Fall", "Winter"}, "Turtle Check Men Navy Blue Shirt",
                                34.95, "Boston", "-71.057083, 42.361145");
        Product prod59263 = new Product(59263, "Women", new String[]{"Fall", "Winter", "Spring", "Summer"}, "Titan Women Silver Watch",
                                129.99, "Dallas", "-96.808891, 32.779167");
        Product prod46885 = new Product(46885, "Boys", new String[]{"Fall"}, "Ben 10 Boys Navy Blue Slippers",
                                45.99, "Denver", "-104.991531, 39.742043");
                     
        Gson gson = new Gson();
        client.jsonSet("product:15970", gson.toJson(prod15970));   
        client.jsonSet("product:59263", gson.toJson(prod59263));  
        client.jsonSet("product:46885", gson.toJson(prod46885));   
         
        System.out.println("\n*** Lab 3 - Retrieve All ***");
        Query q = new Query("*");
        SearchResult res = client.ftSearch("idx1", q);
        List<Document> docs = res.getDocuments();
        for (Document doc : docs) {
            System.out.println(doc);
        }
            
        System.out.println("\n*** Lab 3 - Single Term Text ***");
        q = new Query("@description:Slippers");
        res = client.ftSearch("idx1", q);
        docs = res.getDocuments();
        for (Document doc : docs) {
            System.out.println(doc);
        }
  
        System.out.println("\n*** Lab 3 - Exact Phrase Text ***");
        q = new Query("@description:(\"Blue Shirt\")");
        res = client.ftSearch("idx1", q);
        docs = res.getDocuments();
        for (Document doc : docs) {
            System.out.println(doc);
        }

        System.out.println("\n*** Lab 3 - Numeric Range ***");
        q = new Query("@price:[40,130]");
        res = client.ftSearch("idx1", q);
        docs = res.getDocuments();
        for (Document doc : docs) {
            System.out.println(doc);
        }
    
        System.out.println("\n*** Lab 3 - Tag Array ***");
        q = new Query("@season:{Spring}");
        res = client.ftSearch("idx1", q);
        docs = res.getDocuments();
        for (Document doc : docs) {
            System.out.println(doc);
        }
        
        System.out.println("\n*** Lab 3 - Logical AND ***");
        q = new Query("@price:[40, 100] @description:Blue");
        res = client.ftSearch("idx1", q);
        docs = res.getDocuments();
        for (Document doc : docs) {
            System.out.println(doc);
        }   
      
        System.out.println("\n*** Lab 3 - Logical OR ***");
        q = new Query("(@gender:{Women})|(@city:Boston)");
        res = client.ftSearch("idx1", q);
        docs = res.getDocuments();
        for (Document doc : docs) {
            System.out.println(doc);
        }       

        System.out.println("\n*** Lab 3 - Negation ***");
        q = new Query("-(@description:Shirt)");
        res = client.ftSearch("idx1", q);
        docs = res.getDocuments();
        for (Document doc : docs) {
            System.out.println(doc);
        }
        
        System.out.println("\n*** Lab 3 - Prefix ***");
        q = new Query("@description:Nav*");
        res = client.ftSearch("idx1", q);
        docs = res.getDocuments();
        for (Document doc : docs) {
            System.out.println(doc);
        }
 
        System.out.println("\n*** Lab 3 - Suffix ***");
        q = new Query("@description:*Watch");
        res = client.ftSearch("idx1", q);
        docs = res.getDocuments();
        for (Document doc : docs) {
            System.out.println(doc);
        }
            
        System.out.println("\n*** Lab 3 - Fuzzy ***");
        q = new Query("@description:%wavy%");
        res = client.ftSearch("idx1", q);
        docs = res.getDocuments();
        for (Document doc : docs) {
            System.out.println(doc);
        }

        System.out.println("\n*** Lab 3 - Geo ***");
        q = new Query("@coords:[-104.800644 38.846127 100 mi]");
        res = client.ftSearch("idx1", q);
        docs = res.getDocuments();
        for (Document doc : docs) {
            System.out.println(doc);
        }
    }
}