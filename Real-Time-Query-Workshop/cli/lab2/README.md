# Lab 2 - Basic JSON Operations
CRUD (Create, Read, Update, Delete) operations with the Redis JSON data type

## Business Value Statement <a name="value"></a>
Document stores are a NoSQL database type that provide flexible schemas and access patterns that are familiar to developers.  Redis can provide document store functionality natively with its JSON data type.  This allows Redis to complement existing document store databases such as MongoDB or provide standalone JSON document storage.

## Create <a name="create"></a>
### Syntax
[JSON.SET](https://redis.io/commands/json.set/)
### Key Value Pair <a name="kvp"></a>
Insert a simple KVP as a JSON object.
```redis Command
JSON.SET ex1:1 $ '"val"'
```

### Single String Property <a name="single_string"></a>
Insert a single-property JSON object.
```redis Command
JSON.SET ex1:2 $ '{"field1": "val1"}'
```

### Multiple Properties <a name="multiple_properties"></a>
Insert a JSON object with multiple properties.
```redis Command
JSON.SET ex1:3 $ '{"field1": "val1", "field2": "val2"}'
```

### Multiple Properties + Data Types <a name="multiple_types"></a>
Insert a JSON object with multiple properties of different data types.
```redis Command
JSON.SET ex1:4 $ '{"field1": "val1", "field2": 2, "field3": true, "field4": null}'
```

### JSON Arrays <a name="arrays"></a>
Insert a JSON object that contains an array.
```redis Command
JSON.SET ex1:5 $ '{"arr1": ["val1", "val2", "val3"]}'
```


### JSON Objects <a name="objects"></a>
Insert a JSON object that contains a nested object.
```redis Command
JSON.SET ex1:6 $ '{"obj1": {"str1": "val1", "num2": 2}}'
```


### Mix <a name="mix"></a>
Insert a JSON object with a mixture of property data types.
```redis Command
JSON.SET ex1:7 $ '{"str1": "val1", "str2": "val2", "arr1":[1,2,3,4], "obj1": {"num1": 1,"arr2":["val1","val2", "val3"]}}'
```

## Read <a name="read"></a>
### Syntax
[JSON.GET](https://redis.io/commands/json.get/)
### Key Fetch <a name="key_fetch"></a>
Set and Fetch a simple JSON KVP.
```redis Command
JSON.SET ex2:1 $ '"val"'
JSON.GET ex2:1 $
```

### Single Property Fetch <a name="single_fetch"></a>
Set and Fetch a single property from a JSON object.
```redis Command
JSON.SET ex2:2 $ '{"field1": "val1"}'
JSON.GET ex2:2 $.field1
```

### Multi-Property Fetch <a name="multiple_fetch"></a>
Fetch multiple properties.
```redis Command
JSON.SET ex2:3 $ '{"field1": "val1", "field2": "val2"}'
JSON.GET ex2:3 $.field1 $.field2
```

### Nested Property Fetch <a name="nested_fetch"></a>
Fetch a property nested in another JSON object.
```redis Command
JSON.SET ex2:4 $ '{"obj1": {"str1": "val1", "num2": 2}}'
JSON.GET ex2:4 $.obj1.num2
```

### Array Fetch <a name="array_fetch"></a>
Fetch properties within an array and utilize array subscripting.
```redis Command
JSON.SET ex2:5 $ '{"str1": "val1", "str2": "val2", "arr1":[1,2,3,4], "obj1": {"num1": 1,"arr2":["val1","val2", "val3"]}}'
JSON.GET ex2:5 $.obj1.arr2
JSON.GET ex2:5 $.arr1[1]
JSON.GET ex2:5 $.obj1.arr2[0:2]
JSON.GET ex2:5 $.arr1[-2:]
```

## Update <a name="update"></a>
### Syntax
[JSON.SET](https://redis.io/commands/json.set/)
### Entire Object <a name="entire_update"></a>
Update an entire JSON object.
```redis Command
JSON.SET ex3:1 $ '{"field1": "val1"}'
JSON.SET ex3:1 $ '{"foo": "bar"}'
JSON.GET ex3:1
```

### Single Property <a name="single_update"></a>
Update a single property within an object.
```redis Command
JSON.SET ex3:2 $ '{"field1": "val1", "field2": "val2"}'
JSON.SET ex3:2 $.field1 '"foo"'
JSON.GET ex3:2
```

### Nested Property <a name="nested_update"></a>
Update a property in an embedded JSON object.
```redis Command
JSON.SET ex3:3 $ '{"obj1": {"str1": "val1", "num2": 2}}'
JSON.SET ex3:3 $.obj1.num2 3
JSON.GET ex3:3
```

### Array Item <a name="array_update"></a>
Update an item in an array via index.
```redis Command
JSON.SET ex3:4 $ '{"arr1": ["val1", "val2", "val3"]}'
JSON.SET ex3:4 $.arr1[0] '"foo"'
JSON.GET ex3:4
```

## Delete <a name="delete"></a>
### Syntax
[JSON.DEL](https://redis.io/commands/json.del/)
### Entire Object <a name="entire_delete"></a>
Delete entire object/key.
```redis Command
JSON.SET ex4:1 $ '{"field1": "val1"}'
JSON.DEL ex4:1
JSON.GET ex4:1
```

### Single Property <a name="single_delete"></a>
Delete a single property from an object.
```redis Command
JSON.SET ex4:2 $ '{"field1": "val1", "field2": "val2"}'
JSON.DEL ex4:2 $.field1 
JSON.GET ex4:2
```

### Nested Property <a name="nested_delete"></a>
Delete a property from an embedded object.
```redis Command
JSON.SET ex4:3 $ '{"obj1": {"str1": "val1", "num2": 2}}'
JSON.DEL ex4:3 $.obj1.num2 
JSON.GET ex4:3
```

### Array Item <a name="array_delete"></a>
Delete a single item from an array.
```redis Command
JSON.SET ex4:4 $ '{"arr1": ["val1", "val2", "val3"]}'
JSON.DEL ex4:4 $.arr1[0] 
JSON.GET ex4:4
```
