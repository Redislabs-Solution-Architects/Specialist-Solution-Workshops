# Lab 2 - Basic JSON Operations
CRUD (Create, Read, Update, Delete) operations with the Redis JSON data type

## Create
### Syntax
`JSON.SET <KEY> <PATH> <OBJECT>`
### Examples
#### Key Value Pair
```bash
JSON.SET ex1:1 $ '"val"'
```
#### Single String Field
```bash
JSON.SET ex1:2 $ '{"field1": "val1"}'
```
#### Multiple Fields
```bash
JSON.SET ex1:3 $ '{"field1": "val1", "field2": "val2"}'
```
#### Multiple Fields + Data Types
```bash
JSON.SET ex1:4 $ '{"field1": "val1", "field2": 2, "field3": true, "field4": null}'
```
#### JSON Arrays
```bash
JSON.SET ex1:5 $ '{"arr1": ["val1", "val2", "val3"]}'
```
#### JSON Objects
```bash
JSON.SET ex1:6 $ '{"obj1": {"str1": "val1", "num2": 2}}'
```
#### Mix
```bash
JSON.SET ex1:7 $ '{"str1": "val1", "str2": "val2", "arr1":[1,2,3,4], "obj1": {"num1": 1,"arr2":["val1","val2", "val3"]}}'
```
## Read
### Syntax
`JSON.GET <KEY> <PATH>`
### Examples
#### Key Fetch
```bash
JSON.SET ex2:1 $ '"val"'
JSON.GET ex2:1 $
```
#### Single Field Fetch
```bash
JSON.SET ex2:2 $ '{"field1": "val1"}'
JSON.GET ex2:2 $.field1
```
#### Multi-Field Fetch
```bash
JSON.SET ex2:3 $ '{"field1": "val1", "field2": "val2"}'
JSON.GET ex2:3 $.field1 $.field2
JSON.GET ex2:3 $.*
```
#### Nested Field Fetch
```bash
JSON.SET ex2:4 $ '{"obj1": {"str1": "val1", "num2": 2}}'
JSON.GET ex2:4 $.obj1.num2
```
#### Array Fetch
```bash
JSON.SET ex2:5 $ '{"str1": "val1", "str2": "val2", "arr1":[1,2,3,4], "obj1": {"num1": 1,"arr2":["val1","val2", "val3"]}}'
JSON.GET ex2:5 $.obj1.arr2
JSON.GET ex2:5 $.arr1[1]
JSON.GET ex2:5 $.obj1.arr2[0:2]
JSON.GET ex2:5 $.arr1[-2:]
```
## Update
### Syntax
`JSON.SET <KEY> <PATH> <OBJECT>`
### Examples
#### Entire Object
```bash
JSON.SET ex3:1 $ '{"field1": "val1"}'
JSON.SET ex3:1 $ '{"foo": "bar"}'
```
#### Single Field
```bash
JSON.SET ex3:2 $ '{"field1": "val1", "field2": "val2"}'
JSON.SET ex3:2 $.field1 '"foo"'
```
#### Nested Field
```bash
JSON.SET ex3:3 $ '{"obj1": {"str1": "val1", "num2": 2}}'
JSON.SET ex3:3 $.obj1.num2 3
JSON.SET ex3:3 $.obj1.str1 '"foo"'
```
#### Array Item
```bash
JSON.SET ex3:4 $ '{"arr1": ["val1", "val2", "val3"]}'
JSON.SET ex3:4 $.arr1[0] '"foo"'
```
## Delete
### Syntax
`JSON.DEL <KEY> <PATH>`
### Examples
#### Entire Object
```bash
JSON.SET ex4:1 $ '{"field1": "val1"}'
JSON.DEL ex4:1
```
#### Single Field
```bash
JSON.SET ex4:2 $ '{"field1": "val1", "field2": "val2"}'
JSON.DEL ex4:2 $.field1 
```
#### Nested Field
```bash
JSON.SET ex4:3 $ '{"obj1": {"str1": "val1", "num2": 2}}'
JSON.DEL ex4:3 $.obj1.num2 
```
#### Array Item
```bash
JSON.SET ex4:4 $ '{"arr1": ["val1", "val2", "val3"]}'
JSON.DEL ex4:4 $.arr1[0] 