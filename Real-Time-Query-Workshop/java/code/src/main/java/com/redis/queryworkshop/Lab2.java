/**
 * @fileoverview Basic JSON operations with the redis client
 * @maker Joey Whelan
*/

package com.redis.queryworkshop;
import org.json.JSONArray;
import org.json.JSONObject;
import java.util.Arrays;
import redis.clients.jedis.JedisPooled;
import redis.clients.jedis.json.Path;

public class Lab2 {
    public void run(JedisPooled client) {   
        System.out.println("\n*** Lab 2 - Insert a simple KVP as a JSON object ***");
        String res = client.jsonSet("ex1:1", new Path("$"),"val");
        System.out.println(res);

        System.out.println("\n*** Lab 2 - Insert a single-property JSON object ***");
        JSONObject jo = new JSONObject();
        jo.put("field1","val1");
        res = client.jsonSet("ex1:2", jo);
        System.out.println(res);

        System.out.println("\n*** Lab 2 - Insert a JSON object with multiple properties ***");
        jo = new JSONObject();
        jo.put("field1","val1");
        jo.put("field2", "val2");
        res = client.jsonSet("ex1:3", jo);
        System.out.println(res);
 
        System.out.println("\n*** Lab 2 - Insert a JSON object with multiple properties of different data types ***");
        jo = new JSONObject();
        jo.put("field1","val1");
        jo.put("field2", "val2");
        jo.put("field3", Boolean.TRUE);
        jo.put("field4", JSONObject.NULL);
        res = client.jsonSet("ex1:4", jo);
        System.out.println(res);

        System.out.println("\n*** Lab 2 - Insert a JSON object that contains an array ***");
        JSONArray ja = new JSONArray(Arrays.asList("val1", "val2", "val3"));
        res = client.jsonSet("ex1:5", ja);
        System.out.println(res);

        System.out.println("\n*** Lab 2 - Insert a JSON object that contains a nested object ***");
        JSONObject no = new JSONObject();
        no.put("str1","val1");
        no.put("num2", 2);
        jo = new JSONObject();
        jo.put("obj1", no);
        res = client.jsonSet("ex1:6", jo);
        System.out.println(res);

        System.out.println("\n*** Lab 2 - Insert a JSON object with a mixture of property data types ***");
        no = new JSONObject();
        no.put("num1", 1);
        no.put("arr2", new JSONArray(Arrays.asList("val1", "val2", "val3")));
        jo = new JSONObject();
        jo.put("str1", "val1");   
        jo.put("str2", "val2");
        jo.put("arr1", new JSONArray(Arrays.asList(1, 2, 3, 4)));
        jo.put("obj1", no);
        res = client.jsonSet("ex1:7", jo);
        System.out.println(res);
        
        System.out.println("\n*** Lab 2 - Set and Fetch a simple JSON KVP ***");
        client.jsonSet("ex2:1", new Path("$"),"val");
        res = client.jsonGetAsPlainString("ex2:1", new Path("$"));
        System.out.println(res); 

        System.out.println("\n*** Lab 2 - Set and Fetch a single property from a JSON object ***");
        jo = new JSONObject();
        jo.put("field1", "val1"); 
        client.jsonSet("ex2:2", jo);
        res = client.jsonGetAsPlainString("ex2:2", new Path("$"));
        System.out.println(res);

        System.out.println("\n*** Lab 2 - Fetch multiple properties ***");
        jo = new JSONObject();
        jo.put("field1", "val1"); 
        jo.put("field2", "val2");
        client.jsonSet("ex2:3", jo);
        Object ro = client.jsonGet("ex2:3", 
                        new Path("$.field1"), 
                        new Path("$.field2"));
        System.out.println(ro);         
 
        System.out.println("\n*** Lab 2 - Fetch a property nested in another JSON object ***");
        no = new JSONObject();
        no.put("str1", "val1");
        no.put("num2", 2);
        jo = new JSONObject();  
        jo.put("obj1", no); 
        client.jsonSet("ex2:4", jo);
        res = client.jsonGetAsPlainString("ex2:4", new Path("$.obj1.num2"));
        System.out.println(res);
            
        System.out.println("\n*** Lab 2 - Fetch properties within an array and utilize array subscripting ***");
        no = new JSONObject();
        no.put("num1", 1);
        no.put("arr2", new JSONArray(Arrays.asList("val1", "val2", "val3")));
        jo = new JSONObject();
        jo.put("str1", "val1");   
        jo.put("str2", "val2");
        jo.put("arr1", new JSONArray(Arrays.asList(1, 2, 3, 4)));
        jo.put("obj1", no);
        client.jsonSet("ex2:5", jo);
        res = client.jsonGetAsPlainString("ex2:5", new Path("$.obj1.arr2"));
        System.out.println(res);
        res = client.jsonGetAsPlainString("ex2:5", new Path("$.arr1[1]"));
        System.out.println(res);  
        res = client.jsonGetAsPlainString("ex2:5", new Path("$.obj1.arr2[0:2]"));
        System.out.println(res);     
        res = client.jsonGetAsPlainString("ex2:5", new Path("$.arr1[-2:]"));
        System.out.println(res); 
             
        System.out.println("\n*** Lab 2 - Update an entire JSON object ***");
        jo = new JSONObject();
        jo.put("field1", "val1");
        client.jsonSet("ex3:1", jo);
        jo = new JSONObject();
        jo.put("foo", "bar");
        client.jsonSet("ex3:1", jo);
        res = client.jsonGetAsPlainString("ex3:1", new Path("$"));
        System.out.println(res); 

        System.out.println("\n*** Lab 2 - Update a single property within an object ***");
        jo = new JSONObject();
        jo.put("field1", "val1");
        jo.put("field2", "val2"); 
        client.jsonSet("ex3:2", jo);   
        client.jsonSet("ex3:2", new Path("$.field1"), "foo");
        res = client.jsonGetAsPlainString("ex3:2", new Path("$"));
        System.out.println(res); 
 
        System.out.println("\n*** Lab 2 - Update a property in an embedded JSON object ***");
        no = new JSONObject();
        no.put("str1", "val1");
        no.put("num2", 2);
        jo = new JSONObject();
        jo.put("obj1", no);
        client.jsonSet("ex3:3", jo);    
        client.jsonSet("ex3:3", new Path("$.obj1.num2"), 3);    
        res = client.jsonGetAsPlainString("ex3:3", new Path("$"));
        System.out.println(res);  
            
        System.out.println("\n*** Lab 2 - Update an item in an array via index ***");
        jo = new JSONObject();
        jo.put("arr1", new JSONArray(Arrays.asList("val1", "val2", "val3")));    
        client.jsonSet("ex3:4", jo);    
        client.jsonSet("ex3:4", new Path("$.arr1[0]"), "foo");    
        res = client.jsonGetAsPlainString("ex3:4", new Path("$"));
        System.out.println(res); 
            
        System.out.println("\n*** Lab 2 - Delete entire object/key ***");
        jo = new JSONObject();
        jo.put("field1", "val1"); 
        client.jsonSet("ex4:1", jo); 
        client.jsonDel("ex4:1");
        res = client.jsonGetAsPlainString("ex4:1", new Path("$"));
        System.out.println(res); 

        System.out.println("\n*** Lab 2 - Delete a single property from an object ***");
        jo = new JSONObject();
        jo.put("field1", "val1");
        jo.put("field2", "val2");
        client.jsonSet("ex4:2", jo); 
        client.jsonDel("ex4:2", new Path("$.field1"));
        res = client.jsonGetAsPlainString("ex4:2", new Path("$"));
        System.out.println(res); 

        System.out.println("\n*** Lab 2 - Delete a property from an embedded object ***");
        no = new JSONObject();
        no.put("str1", "val1");
        no.put("num2", 2);
        jo = new JSONObject();
        jo.put("obj1", no); 
        client.jsonSet("ex4:3", jo); 
        client.jsonDel("ex4:3", new Path("$.obj1.num2"));
        res = client.jsonGetAsPlainString("ex4:3", new Path("$"));
        System.out.println(res);    

        System.out.println("\n*** Lab 2 - Delete a single item from an array ***");
        jo = new JSONObject();
        jo.put("arr1", new JSONArray(Arrays.asList("val1", "val2", "val3")));  
        client.jsonSet("ex4:4", jo); 
        client.jsonDel("ex4:4", new Path("$.arr1[0]"));
        res = client.jsonGetAsPlainString("ex4:4", new Path("$"));
        System.out.println(res); 
    }
}