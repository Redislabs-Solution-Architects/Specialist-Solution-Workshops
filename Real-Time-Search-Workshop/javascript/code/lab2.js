/**
 * @fileoverview Basic JSON operations with the node-redis client
 * @maker Joey Whelan
 */

export class Lab2 {

    async run(client) {
        console.log('\n*** Lab 2 - Insert a simple KVP as a JSON object ***');
        let result = await client.json.set('ex1:1', '$', 'val');
        console.log(result);

        console.log('\n*** Lab 2 - Insert a single-property JSON object ***');
        result = await client.json.set('ex1:2', '$', {"field1": "val1"});
        console.log(result);

        console.log('\n*** Lab 2 - Insert a JSON object with multiple properties ***');
        result = await client.json.set('ex1:3', '$', {"field1": "val1", "field2": "val2"});
        console.log(result);

        console.log('\n*** Lab 2 - Insert a JSON object with multiple properties of different data types ***');
        result = await client.json.set('ex1:4', '$', {"field1": "val1", "field2": 2, "field3": true, "field4": null});
        console.log(result);

        console.log('\n*** Lab 2 - Insert a JSON object that contains an array ***');
        result = await client.json.set('ex1:5', '$', {"arr1": ["val1", "val2", "val3"]});
        console.log(result);

        console.log('\n*** Lab 2 - Insert a JSON object that contains a nested object ***');
        result = await client.json.set('ex1:6', '$', {"obj1": {"str1": "val1", "num2": 2}});
        console.log(result); 

        console.log('\n*** Lab 2 - Insert a JSON object with a mixture of property data types ***');
        result = await client.json.set('ex1:7', '$', {
            "str1": "val1", 
            "str2": "val2", 
            "arr1":[1,2,3,4], 
            "obj1": { "num1": 1, "arr2":["val1","val2", "val3"] }
        });
        console.log(result); 

        console.log('\n*** Lab 2 - Set and Fetch a simple JSON KVP ***');
        await client.json.set('ex2:1', '$', 'val');
        result = await client.json.get('ex2:1', '$');
        console.log(result); 

        console.log('\n*** Lab 2 - Set and Fetch a single property from a JSON object ***');
        await client.json.set('ex2:2', '$', {"field1": "val1"});
        result = await client.json.get('ex2:2', { path: '$.field1' });
        console.log(result); 

        console.log('\n*** Lab 2 - Fetch multiple properties ***');
        await client.json.set('ex2:3', '$', {"field1": "val1", "field2": "val2"});
        result = await client.json.get('ex2:3', { path: ['$.field1', '$.field2'] });
        console.log(result); 

        console.log('\n*** Lab 2 - Fetch a property nested in another JSON object ***');
        await client.json.set('ex2:4', '$', {"obj1": {"str1": "val1", "num2": 2}});
        result = await client.json.get('ex2:4', { path: '$.obj1.num2' });
        console.log(result); 

        console.log('\n*** Lab 2 - Fetch properties within an array and utilize array subscripting ***');
        await client.json.set('ex2:5', '$', {"str1": "val1", "str2": "val2", "arr1":[1,2,3,4], "obj1": {"num1": 1,"arr2":["val1","val2", "val3"]}});
        result = await client.json.get('ex2:5', { path: '$.obj1.arr2' });
        console.log(result); 
        result = await client.json.get('ex2:5', { path: '$.arr1[1]' });
        console.log(result);
        result = await client.json.get('ex2:5', { path: '$.obj1.arr2[0:2]' });
        console.log(result);
        result = await client.json.get('ex2:5', { path: '$.arr1[-2:]' });
        console.log(result);

        console.log('\n*** Lab 2 - Update an entire JSON object ***');
        await client.json.set('ex3:1', '$', {"field1": "val1"});
        await client.json.set('ex3:1', '$', {"foo": "bar"});
        result = await client.json.get('ex3:1');
        console.log(result); 

        console.log('\n*** Lab 2 - Update a single property within an object ***');
        await client.json.set('ex3:2', '$', {"field1": "val1", "field2": "val2"});
        await client.json.set('ex3:2', '$.field1', 'foo');
        result = await client.json.get('ex3:2');
        console.log(result); 

        console.log('\n*** Lab 2 - Update a property in an embedded JSON object ***');
        await client.json.set('ex3:3', '$', {"obj1": {"str1": "val1", "num2": 2}});
        await client.json.set('ex3:3', '$.obj1.num2', 3);
        result = await client.json.get('ex3:3');
        console.log(result); 

        console.log('\n*** Lab 2 - Update an item in an array via index ***');
        await client.json.set('ex3:4', '$', {"arr1": ["val1", "val2", "val3"]});
        await client.json.set('ex3:4', '$.arr1[0]', 'foo');
        result = await client.json.get('ex3:4');
        console.log(result); 

        console.log('\n*** Lab 2 - Delete entire object/key ***');
        await client.json.set('ex4:1', '$', {"field1": "val1"});
        await client.json.del('ex4:1');
        result = await client.json.get('ex4:1');
        console.log(result); 

        console.log('\n*** Lab 2 - Delete a single property from an object ***');
        await client.json.set('ex4:2', '$', {"field1": "val1", "field2": "val2"});
        await client.json.del('ex4:2', '$.field1');
        result = await client.json.get('ex4:2');
        console.log(result); 

        console.log('\n*** Lab 2 - Delete a property from an embedded object ***');
        await client.json.set('ex4:3', '$', {"obj1": {"str1": "val1", "num2": 2}});
        await client.json.del('ex4:3', '$.obj1.num2');
        result = await client.json.get('ex4:3');
        console.log(result); 

        console.log('\n*** Lab 2 - Delete a single item from an array ***');
        await client.json.set('ex4:4', '$', {"arr1": ["val1", "val2", "val3"]});
        await client.json.del('ex4:4', '$.arr1[0]');
        result = await client.json.get('ex4:4');
        console.log(result); 
    }
}