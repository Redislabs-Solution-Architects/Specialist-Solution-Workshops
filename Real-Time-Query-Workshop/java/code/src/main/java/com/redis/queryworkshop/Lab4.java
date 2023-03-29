/**
 * @fileoverview Advanced JSON operations with the redis client
 * @maker Joey Whelan
 */
package com.redis.queryworkshop;
import redis.clients.jedis.JedisPooled;
import redis.clients.jedis.json.Path;
import com.google.gson.Gson;

public class Lab4 {
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
        private Product[] inventory;;

        public Warehouse(String city, String location, Product[] inventory) {
                this.city = city;
                this.location = location;
                this.inventory = inventory;
        }
    }

    public void run(JedisPooled client) {  
        System.out.println("\n*** Lab 4 - Data Loading ***");
        Product prod15970 = new Product(15970, "Men", new String[]{"Fall", "Winter"}, "Turtle Check Men Navy Blue Shirt",
            34.95);
        Product prod59263 = new Product(59263, "Women", new String[]{"Fall", "Winter", "Spring", "Summer"}, "Titan Women Silver Watch",
            129.99);
        Product prod46885 = new Product(46885, "Boys", new String[]{"Fall"}, "Ben 10 Boys Navy Blue Slippers",
            45.99);
        Warehouse wh1 = new Warehouse("Boston", "42.361145, -71.057083", 
            new Product[]{prod15970, prod59263, prod46885});
        Gson gson = new Gson();
        client.jsonSet("warehouse:1", gson.toJson(wh1));    
         
        System.out.println("\n*** Lab 4 - All Properties of Array ***");
        String res = client.jsonGetAsPlainString("warehouse:1", new Path("$.inventory[*]"));
        System.out.println(res);
   
        System.out.println("\n*** Lab 4 - All Properties of a Field ***");
        res = client.jsonGetAsPlainString("warehouse:1", new Path("$.inventory[*].price"));
        System.out.println(res);

        System.out.println("\n*** Lab 4 - Relational - Equality ***");
        res = client.jsonGetAsPlainString("warehouse:1", 
                new Path("$.inventory[?(@.description==\"Turtle Check Men Navy Blue Shirt\")]"));
        System.out.println(res);
 
        System.out.println("\n*** Lab 4 - Relational - Less Than ***");
        res = client.jsonGetAsPlainString("warehouse:1", new Path("$.inventory[?(@.price<100)]"));
        System.out.println(res);
       
        System.out.println("\n*** Lab 4 - Relational - Greater Than or Equal ***");
        res = client.jsonGetAsPlainString("warehouse:1", new Path("$.inventory[?(@.id>=20000)]"));
        System.out.println(res);      
 
        System.out.println("\n*** Lab 4 - Logical AND ***");
        res = client.jsonGetAsPlainString("warehouse:1", 
                new Path("$.inventory[?(@.gender==\"Men\"&&@.price>20)]"));
        System.out.println(res);

        System.out.println("\n*** Lab 4 - Logical OR ***");
        res = client.jsonGetAsPlainString("warehouse:1", 
                new Path("$.inventory[?(@.price<100||@.gender==\"Women\")].id"));
        System.out.println(res); 

        System.out.println("\n*** Lab 4 - Regex - Contains Exact ***");
        res = client.jsonGetAsPlainString("warehouse:1", 
                new Path("$.inventory[?(@.description =~ \"Blue\")]"));
        System.out.println(res);  

        System.out.println("\n*** Lab 4 - Regex - Contains, Case Insensitive ***");
        res = client.jsonGetAsPlainString("warehouse:1", 
                new Path("$.inventory[?(@.description =~ \"(?i)watch\")]"));
        System.out.println(res);  

        System.out.println("\n*** Lab 4 - Regex - Begins With ***");
        res = client.jsonGetAsPlainString("warehouse:1", 
            new Path("$.inventory[?(@.description =~ \"^T\")]"));
        System.out.println(res);  
    }
}
