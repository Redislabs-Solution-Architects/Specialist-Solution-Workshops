/*
  @fileoverview AA Search operations with the redis client
  @maker Joey Whelan
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

public class Lab6 {
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
        System.out.println("\n*** Lab 6 - Index Creation ***");
        try {client.ftDropIndex("idx1");} catch(Exception e) {};
        
        Schema schema = new Schema().addNumericField("$.id").as("id")
            .addTagField("$.gender").as("gender")
            .addTagField("$.season.*").as("season")
            .addTextField("$.description", 1.0).as("description")
            .addNumericField("$.price").as("price")
            .addTextField("$.city",1.0).as("city")
            .addGeoField("$.coords").as("coords");
        IndexDefinition rule = new IndexDefinition(IndexDefinition.Type.JSON)
            .setPrefixes(new String[]{"product:"});
        client.ftCreate("idx1", IndexOptions.defaultOptions().setDefinition(rule), schema);

        System.out.println("\n*** Lab 6 - Add a product ***");
        Product prod15970 = new Product(15970, "Men", new String[]{"Fall", "Winter"}, "Turtle Check Men Navy Blue Shirt",
        34.95, "Boston", "-71.057083, 42.361145");
        Gson gson = new Gson();
        client.jsonSet("product:15970", gson.toJson(prod15970)); 
       
        System.out.println("\n*** Lab 6 - Search 1 ***");
        Query q = new Query("@description:shirt");
        SearchResult res = client.ftSearch("idx1", q);
        List<Document> docs = res.getDocuments();
        for (Document doc : docs) {
            System.out.println(doc);
        }

        System.out.println("\n*** Lab 6 - Add another product ***");
        Product prod59263 = new Product(59263, "Women", new String[]{"Fall", "Winter", "Spring", "Summer"}, "Titan Women Silver Watch",
                                129.99, "Dallas", "-96.808891, 32.779167");
        client.jsonSet("product:59263", gson.toJson(prod59263));                         
            
        System.out.println("\n*** Lab 6 - Search 2 ***");
        q = new Query("@season:{Winter}");
        res = client.ftSearch("idx1", q);
        docs = res.getDocuments();
        for (Document doc : docs) {
            System.out.println(doc);
        }
    }
}