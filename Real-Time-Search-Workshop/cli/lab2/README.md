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
`JSON.SET <KEY> <PATH> <OBJECT>`
### Key Value Pair <a name="kvp"></a>
Insert a simple KVP as a JSON object.
#### Command
```bash
JSON.SET ex1:1 $ '"val"'
```
#### Result
```bash
"OK"
```

### Single String Property <a name="single_string"></a>
Insert a single-property JSON object.
#### Command
```bash
JSON.SET ex1:2 $ '{"field1": "val1"}'
```
#### Result
```bash
"OK"
```

### Multiple Properties <a name="multiple_properties"></a>
Insert a JSON object with multiple properties.
#### Command
```bash
JSON.SET ex1:3 $ '{"field1": "val1", "field2": "val2"}'
```
#### Result
```bash
"OK"
```

### Multiple Properties + Data Types <a name="multiple_types"></a>
Insert a JSON object with multiple properties of different data types.
#### Command
```bash
JSON.SET ex1:4 $ '{"field1": "val1", "field2": 2, "field3": true, "field4": null}'
```
#### Result
```bash
"OK"
```

### JSON Arrays <a name="arrays"></a>
Insert a JSON object that contains an array.
#### Command
```bash
JSON.SET ex1:5 $ '{"arr1": ["val1", "val2", "val3"]}'
```
#### Result
```bash
"OK"
```

### JSON Objects <a name="objects"></a>
Insert a JSON object that contains a nested object.
#### Command
```bash
JSON.SET ex1:6 $ '{"obj1": {"str1": "val1", "num2": 2}}'
```
#### Result
```bash
"OK"
```

### Mix <a name="mix"></a>
Insert a JSON object with a mixture of property data types.
#### Command
```bash
JSON.SET ex1:7 $ '{"str1": "val1", "str2": "val2", "arr1":[1,2,3,4], "obj1": {"num1": 1,"arr2":["val1","val2", "val3"]}}'
```
#### Result
```bash
"OK"
```

## Read <a name="read"></a>
### Syntax
`JSON.GET <KEY> <PATH>`
### Key Fetch <a name="key_fetch"></a>
Set and Fetch a simple JSON KVP.
#### Command
```bash
JSON.SET ex2:1 $ '"val"'
```
```bash
JSON.GET ex2:1 $
```
#### Result
```bash
"[\"val\"]"
```

### Single Property Fetch <a name="single_fetch"></a>
Set and Fetch a single property from a JSON object.
#### Command
```bash
JSON.SET ex2:2 $ '{"field1": "val1"}'
```
```bash
JSON.GET ex2:2 $.field1
```
#### Result
```bash
"[\"val1\"]"
```

### Multi-Property Fetch <a name="multiple_fetch"></a>
Fetch multiple properties.
#### Command
```bash
JSON.SET ex2:3 $ '{"field1": "val1", "field2": "val2"}'
```
```bash
JSON.GET ex2:3 $.field1 $.field2
```
#### Result
```bash
"{\"$.field1\":[\"val1\"],\"$.field2\":[\"val2\"]}"
```

### Nested Property Fetch <a name="nested_fetch"></a>
Fetch a property nested in another JSON object.
#### Command
```bash
JSON.SET ex2:4 $ '{"obj1": {"str1": "val1", "num2": 2}}'
```
```bash
JSON.GET ex2:4 $.obj1.num2
```
#### Result
```bash
"[2]"
```

### Array Fetch <a name="array_fetch"></a>
Fetch properties within an array and utilize array subscripting.
#### Command
```bash
JSON.SET ex2:5 $ '{"str1": "val1", "str2": "val2", "arr1":[1,2,3,4], "obj1": {"num1": 1,"arr2":["val1","val2", "val3"]}}'
```
```bash
JSON.GET ex2:5 $.obj1.arr2
```
```bash
JSON.GET ex2:5 $.arr1[1]
```
```bash
JSON.GET ex2:5 $.obj1.arr2[0:2]
```
```bash
JSON.GET ex2:5 $.arr1[-2:]
```
#### Results
```bash
"[[\"val1\",\"val2\",\"val3\"]]"
"[2]"
"[\"val1\",\"val2\"]"
"[3,4]"
```

## Update <a name="update"></a>
### Syntax
`JSON.SET <KEY> <PATH> <OBJECT>`
### Entire Object <a name="entire_update"></a>
Update an entire JSON object.
#### Command
```bash
JSON.SET ex3:1 $ '{"field1": "val1"}'
```
```bash
JSON.SET ex3:1 $ '{"foo": "bar"}'
```
```bash
JSON.GET ex3:1
```
#### Result
```bash
"{\"foo\":\"bar\"}"
```

### Single Property <a name="single_update"></a>
Update a single property within an object.
#### Command
```bash
JSON.SET ex3:2 $ '{"field1": "val1", "field2": "val2"}'
```
```bash
JSON.SET ex3:2 $.field1 '"foo"'
```
```bash
JSON.GET ex3:2
```
#### Result
```bash
"{\"field1\":\"foo\",\"field2\":\"val2\"}"
```

### Nested Property <a name="nested_update"></a>
Update a property in an embedded JSON object.
#### Command
```bash
JSON.SET ex3:3 $ '{"obj1": {"str1": "val1", "num2": 2}}'
```
```bash
JSON.SET ex3:3 $.obj1.num2 3
```
```bash
JSON.GET ex3:3
```
#### Result
```bash
"{\"obj1\":{\"str1\":\"val1\",\"num2\":3}}"
```

### Array Item <a name="array_update"></a>
Update an item in an array via index.
#### Command
```bash
JSON.SET ex3:4 $ '{"arr1": ["val1", "val2", "val3"]}'
```
```bash
JSON.SET ex3:4 $.arr1[0] '"foo"'
```
```bash
JSON.GET ex3:4
```
#### Result
```bash
"{\"arr1\":[\"foo\",\"val2\",\"val3\"]}"
```

## Delete <a name="delete"></a>
### Syntax
`JSON.DEL <KEY> <PATH>`
### Entire Object <a name="entire_delete"></a>
Delete entire object/key.
#### Command
```bash
JSON.SET ex4:1 $ '{"field1": "val1"}'
```
```bash
JSON.DEL ex4:1
```
```bash
JSON.GET ex4:1
```
#### Result
```bash
(nil)
```

### Single Property <a name="single_delete"></a>
Delete a single property from an object.
#### Command
```bash
JSON.SET ex4:2 $ '{"field1": "val1", "field2": "val2"}'
```
```bash
JSON.DEL ex4:2 $.field1 
```
```bash
JSON.GET ex4:2
```
#### Result
```bash
"{\"field2\":\"val2\"}"
```

### Nested Property <a name="nested_delete"></a>
Delete a property from an embedded object.
#### Command
```bash
JSON.SET ex4:3 $ '{"obj1": {"str1": "val1", "num2": 2}}'
```
```bash
JSON.DEL ex4:3 $.obj1.num2 
```
```bash
JSON.GET ex4:3
```
#### Result
```bash
"{\"obj1\":{\"str1\":\"val1\"}}"
```

### Array Item <a name="array_delete"></a>
Delete a single item from an array.
#### Command
```bash
JSON.SET ex4:4 $ '{"arr1": ["val1", "val2", "val3"]}'
```
```bash
JSON.DEL ex4:4 $.arr1[0] 
```
```bash
JSON.GET ex4:4
```
#### Result
```bash
"{\"arr1\":[\"val2\",\"val3\"]}"
```  
