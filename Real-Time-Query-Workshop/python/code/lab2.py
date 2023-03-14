'''
  @fileoverview Basic json() operations with the redis-py client
  @maker Joey Whelan
'''
from redis.commands.json.path import Path

class Lab2(object):

    def run(self, client):
        print('\n*** Lab 2 - Insert a simple KVP as a json() object ***')
        result = client.json().set('ex1:1', '$', 'val')
        print(result)

        print('\n*** Lab 2 - Insert a single-property json() object ***')
        result = client.json().set('ex1:2', '$', {"field1": "val1"})
        print(result)

        print('\n*** Lab 2 - Insert a json object with multiple properties ***')
        result = client.json().set('ex1:3', '$', {"field1": "val1", "field2": "val2"})
        print(result)

        print('\n*** Lab 2 - Insert a json object with multiple properties of different data types ***')
        result = client.json().set('ex1:4', '$', {"field1": "val1", "field2": 2, "field3": True, "field4": None})
        print(result)

        print('\n*** Lab 2 - Insert a json object that contains an array ***')
        result = client.json().set('ex1:5', '$', {"arr1": ["val1", "val2", "val3"]})
        print(result)

        print('\n*** Lab 2 - Insert a json object that contains a nested object ***')
        result = client.json().set('ex1:6', '$', {"obj1": {"str1": "val1", "num2": 2}})
        print(result)

        print('\n*** Lab 2 - Insert a json object with a mixture of property data types ***')
        result = client.json().set('ex1:7', '$', {
            "str1": "val1", 
            "str2": "val2", 
            "arr1":[1,2,3,4], 
            "obj1": { "num1": 1, "arr2":["val1","val2", "val3"] }
        })
        print(result) 

        print('\n*** Lab 2 - Set and Fetch a simple json KVP ***')
        client.json().set('ex2:1', '$', 'val')
        result = client.json().get('ex2:1', Path('$'))
        print(result)

        print('\n*** Lab 2 - Set and Fetch a single property from a json object ***')
        client.json().set('ex2:2', '$', {"field1": "val1"})
        result = client.json().get('ex2:2', Path('$.field1'))
        print(result)

        print('\n*** Lab 2 - Fetch multiple properties ***')
        client.json().set('ex2:3', '$', {"field1": "val1", "field2": "val2"})
        result = client.json().get('ex2:3', Path('$.field1'), Path('$.field2'))
        print(result)

        print('\n*** Lab 2 - Fetch a property nested in another json object ***')
        client.json().set('ex2:4', '$', {"obj1": {"str1": "val1", "num2": 2}})
        result = client.json().get('ex2:4', Path('$.obj1.num2' ))
        print(result); 

        print('\n*** Lab 2 - Fetch properties within an array and utilize array subscripting ***')
        client.json().set('ex2:5', '$', {"str1": "val1", "str2": "val2", "arr1":[1,2,3,4], "obj1": {"num1": 1,"arr2":["val1","val2", "val3"]}})
        result = client.json().get('ex2:5', Path('$.obj1.arr2'))
        print(result)
        result = client.json().get('ex2:5', Path('$.arr1[1]' ))
        print(result)
        result = client.json().get('ex2:5', Path('$.obj1.arr2[0:2]'))
        print(result)
        result = client.json().get('ex2:5', Path('$.arr1[-2:]'))
        print(result)

        print('\n*** Lab 2 - Update an entire json object ***')
        client.json().set('ex3:1', '$', {"field1": "val1"})
        client.json().set('ex3:1', '$', {"foo": "bar"})
        result = client.json().get('ex3:1')
        print(result)

        print('\n*** Lab 2 - Update a single property within an object ***')
        client.json().set('ex3:2', '$', {"field1": "val1", "field2": "val2"})
        client.json().set('ex3:2', '$.field1', 'foo')
        result = client.json().get('ex3:2')
        print(result); 

        print('\n*** Lab 2 - Update a property in an embedded json object ***')
        client.json().set('ex3:3', '$', {"obj1": {"str1": "val1", "num2": 2}})
        client.json().set('ex3:3', '$.obj1.num2', 3)
        result = client.json().get('ex3:3')
        print(result)

        print('\n*** Lab 2 - Update an item in an array via index ***')
        client.json().set('ex3:4', '$', {"arr1": ["val1", "val2", "val3"]})
        client.json().set('ex3:4', '$.arr1[0]', 'foo')
        result = client.json().get('ex3:4')
        print(result) 

        print('\n*** Lab 2 - Delete entire object/key ***')
        client.json().set('ex4:1', '$', {"field1": "val1"})
        client.json().delete('ex4:1')
        result = client.json().get('ex4:1')
        print(result)

        print('\n*** Lab 2 - Delete a single property from an object ***')
        client.json().set('ex4:2', '$', {"field1": "val1", "field2": "val2"})
        client.json().delete('ex4:2', '$.field1')
        result = client.json().get('ex4:2')
        print(result)

        print('\n*** Lab 2 - Delete a property from an embedded object ***')
        client.json().set('ex4:3', '$', {"obj1": {"str1": "val1", "num2": 2}})
        client.json().delete('ex4:3', '$.obj1.num2')
        result = client.json().get('ex4:3')
        print(result); 

        print('\n*** Lab 2 - Delete a single item from an array ***')
        client.json().set('ex4:4', '$', {"arr1": ["val1", "val2", "val3"]})
        client.json().delete('ex4:4', '$.arr1[0]')
        result = client.json().get('ex4:4')
        print(result); 