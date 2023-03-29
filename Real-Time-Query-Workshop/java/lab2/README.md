# Lab 2 - Basic JSON Operations
CRUD (Create, Read, Update, Delete) operations with the Redis JSON data type

## Contents
1.  [Business Value Statement](#value)
2.  [Create](#create)
    1.  [Key Value Pair](#kvp)
    2.  [Single String Property](#single_string)
    3.  [Multiple Properties](#multiple_properties)
    4.  [Multiple Properties + Data Types](#multiple_types)
    5.  [JSON Arrays](#arrays)
    6.  [JSON Objects](#objects)
    7.  [Mix](#mix)
3.  [Read](#read)
    1.  [Key Fetch](#key_fetch)
    2.  [Single Property Fetch](#single_fetch)
    3.  [Multi-Property Fetch](#multiple_fetch)
    4.  [Nested Property Fetch](#nested_fetch)
    5.  [Array Fetch](#array_fetch)
4.  [Update](#update)
    1.  [Entire Object](#entire_update)
    2.  [Single Property](#single_update)
    3.  [Nested Property](#nested_update)
    4.  [Array Item](#array_update)
5.  [Delete](#delete)
    1.  [Entire Object](#entire_delete)
    2.  [Single Property](#single_delete)
    3.  [Nested Property](#nested_delete)
    4.  [Array Item](#array_delete)  
    
## Business Value Statement <a name="value"></a>
Document stores are a NoSQL database type that provide flexible schemas and access patterns that are familiar to developers.  Redis can provide document store functionality natively with its JSON data type.  This allows Redis to complement existing document store databases such as MongoDB or provide standalone JSON document storage.

## Create <a name="create"></a>
### Syntax
[JSON.SET](https://redis.io/commands/json.set/)

### Key Value Pair <a name="kvp"></a>
Insert a simple KVP as a JSON object.
#### Command
```java
        String res = client.jsonSet("ex1:1", new Path("$"),"val");
        System.out.println(res);
```
#### Result
```bash
OK
```

### Single String Property <a name="single_string"></a>
Insert a single-property JSON object.
#### Command
```java
        JSONObject jo = new JSONObject();
        jo.put("field1","val1");
        res = client.jsonSet("ex1:2", jo);
        System.out.println(res);
```
#### Result
```bash
OK
```

### Multiple Properties <a name="multiple_properties"></a>
Insert a JSON object with multiple properties.
#### Command
```java
        jo = new JSONObject();
        jo.put("field1","val1");
        jo.put("field2", "val2");
        res = client.jsonSet("ex1:3", jo);
        System.out.println(res);
#### Result
```bash
OK
```

### Multiple Properties + Data Types <a name="multiple_types"></a>
Insert a JSON object with multiple properties of different data types.
#### Command
```java
        jo = new JSONObject();
        jo.put("field1","val1");
        jo.put("field2", "val2");
        jo.put("field3", Boolean.TRUE);
        jo.put("field4", JSONObject.NULL);
        res = client.jsonSet("ex1:4", jo);
        System.out.println(res);
```
#### Result
```bash
OK
```

### JSON Arrays <a name="arrays"></a>
Insert a JSON object that contains an array.
#### Command
```java
        JSONArray ja = new JSONArray(Arrays.asList("val1", "val2", "val3"));
        res = client.jsonSet("ex1:5", ja);
        System.out.println(res);
```
#### Result
```bash
OK
```

### JSON Objects <a name="objects"></a>
Insert a JSON object that contains a nested object.
#### Command
```java
        JSONObject no = new JSONObject();
        no.put("str1","val1");
        no.put("num2", 2);
        jo = new JSONObject();
        jo.put("obj1", no);
        res = client.jsonSet("ex1:6", jo);
        System.out.println(res);
```
#### Result
```bash
OK
```

### Mix <a name="mix"></a>
Insert a JSON object with a mixture of property data types.
#### Command
```java
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
```
#### Result
```bash
OK
```

## Read <a name="read"></a>
### Syntax
[JSON.GET](https://redis.io/commands/json.get/)

### Key Fetch <a name="key_fetch"></a>
Set and Fetch a simple JSON KVP.
#### Command
```java
        client.jsonSet("ex2:1", new Path("$"),"val");
        res = client.jsonGetAsPlainString("ex2:1", new Path("$"));
        System.out.println(res); 
```
#### Result
```bash
["val"]
```

### Single Property Fetch <a name="single_fetch"></a>
Set and Fetch a single property from a JSON object.
#### Command
```java
        jo = new JSONObject();
        jo.put("field1", "val1"); 
        client.jsonSet("ex2:2", jo);
        res = client.jsonGetAsPlainString("ex2:2", new Path("$"));
        System.out.println(res);
```
#### Result
```bash
[{"field1":"val1"}]
```

### Multi-Property Fetch <a name="multiple_fetch"></a>
Fetch multiple properties.
#### Command
```java
        jo = new JSONObject();
        jo.put("field1", "val1"); 
        jo.put("field2", "val2");
        client.jsonSet("ex2:3", jo);
        Object ro = client.jsonGet("ex2:3", 
                        new Path("$.field1"), 
                        new Path("$.field2"));
        System.out.println(ro);  
```
#### Result
```bash
{$.field1=[val1], $.field2=[val2]}
```

### Nested Property Fetch <a name="nested_fetch"></a>
Fetch a property nested in another JSON object.
#### Command
```java
        no = new JSONObject();
        no.put("str1", "val1");
        no.put("num2", 2);
        jo = new JSONObject();  
        jo.put("obj1", no); 
        client.jsonSet("ex2:4", jo);
        res = client.jsonGetAsPlainString("ex2:4", new Path("$.obj1.num2"));
        System.out.println(res);
```
#### Result
```bash
[2]
```

### Array Fetch <a name="array_fetch"></a>
Fetch properties within an array and utilize array subscripting.
#### Command
```java
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
```
#### Results
```bash
[["val1","val2","val3"]]
[2]
["val1","val2"]
[3,4]
```

## Update <a name="update"></a>
### Syntax
[JSON.SET](https://redis.io/commands/json.set/)

### Entire Object <a name="entire_update"></a>
Update an entire JSON object.
#### Command
```java
        jo = new JSONObject();
        jo.put("field1", "val1");
        client.jsonSet("ex3:1", jo);
        jo = new JSONObject();
        jo.put("foo", "bar");
        client.jsonSet("ex3:1", jo);
        res = client.jsonGetAsPlainString("ex3:1", new Path("$"));
        System.out.println(res); 
```
#### Result
```bash
[{"foo":"bar"}]
```

### Single Property <a name="single_update"></a>
Update a single property within an object.
#### Command
```java
        jo = new JSONObject();
        jo.put("field1", "val1");
        jo.put("field2", "val2"); 
        client.jsonSet("ex3:2", jo);   
        client.jsonSet("ex3:2", new Path("$.field1"), "foo");
        res = client.jsonGetAsPlainString("ex3:2", new Path("$"));
        System.out.println(res); 
```
#### Result
```bash
[{"field1":"foo","field2":"val2"}]
```

### Nested Property <a name="nested_update"></a>
Update a property in an embedded JSON object.
#### Command
```java
        no = new JSONObject();
        no.put("str1", "val1");
        no.put("num2", 2);
        jo = new JSONObject();
        jo.put("obj1", no);
        client.jsonSet("ex3:3", jo);    
        client.jsonSet("ex3:3", new Path("$.obj1.num2"), 3);    
        res = client.jsonGetAsPlainString("ex3:3", new Path("$"));
        System.out.println(res); 
```
#### Result
```bash
[{"obj1":{"str1":"val1","num2":3}}]
```

### Array Item <a name="array_update"></a>
Update an item in an array via index.
#### Command
```java
        jo = new JSONObject();
        jo.put("arr1", new JSONArray(Arrays.asList("val1", "val2", "val3")));    
        client.jsonSet("ex3:4", jo);    
        client.jsonSet("ex3:4", new Path("$.arr1[0]"), "foo");    
        res = client.jsonGetAsPlainString("ex3:4", new Path("$"));
        System.out.println(res); 
```
#### Result
```bash
[{"arr1":["foo","val2","val3"]}]
```

## Delete <a name="delete"></a>
### Syntax
[JSON.DEL](https://redis.io/commands/json.del/)

### Entire Object <a name="entire_delete"></a>
Delete entire object/key.
#### Command
```java
        jo = new JSONObject();
        jo.put("field1", "val1"); 
        client.jsonSet("ex4:1", jo); 
        client.jsonDel("ex4:1");
        res = client.jsonGetAsPlainString("ex4:1", new Path("$"));
        System.out.println(res); 
```
#### Result
```bash
null
```

### Single Property <a name="single_delete"></a>
Delete a single property from an object.
#### Command
```java
        jo = new JSONObject();
        jo.put("field1", "val1");
        jo.put("field2", "val2");
        client.jsonSet("ex4:2", jo); 
        client.jsonDel("ex4:2", new Path("$.field1"));
        res = client.jsonGetAsPlainString("ex4:2", new Path("$"));
        System.out.println(res); 
```
#### Result
```bash
[{"field2":"val2"}]
```

### Nested Property <a name="nested_delete"></a>
Delete a property from an embedded object.
#### Command
```java
        no = new JSONObject();
        no.put("str1", "val1");
        no.put("num2", 2);
        jo = new JSONObject();
        jo.put("obj1", no); 
        client.jsonSet("ex4:3", jo); 
        client.jsonDel("ex4:3", new Path("$.obj1.num2"));
        res = client.jsonGetAsPlainString("ex4:3", new Path("$"));
        System.out.println(res); 
```
#### Result
```bash
[{"obj1":{"str1":"val1"}}]
```

### Array Item <a name="array_delete"></a>
Delete a single item from an array.
#### Command
```java
        jo = new JSONObject();
        jo.put("arr1", new JSONArray(Arrays.asList("val1", "val2", "val3")));  
        client.jsonSet("ex4:4", jo); 
        client.jsonDel("ex4:4", new Path("$.arr1[0]"));
        res = client.jsonGetAsPlainString("ex4:4", new Path("$"));
        System.out.println(res); 
```
#### Result
```bash
[{"arr1":["val2","val3"]}]
```  