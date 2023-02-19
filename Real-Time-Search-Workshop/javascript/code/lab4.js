/**
 * @fileoverview Advanced JSON operations with the node-redis client
 * @maker Joey Whelan
 */

export class Lab4 {
    
    async run(client) {
        console.log('\n*** Lab 4 - Data Loading ***');
        await client.json.set('warehouse:1', '$', {
            "city": "Boston",
            "location": "42.361145, -71.057083",
            "inventory":[{
                "id": 15970,
                "gender": "Men",
                "season":["Fall", "Winter"],
                "description": "Turtle Check Men Navy Blue Shirt",
                "price": 34.95
            },{
                "id": 59263,
                "gender": "Women",
                "season": ["Fall", "Winter", "Spring", "Summer"],
                "description": "Titan Women Silver Watch",
                "price": 129.99
            },{
                "id": 46885,
                "gender": "Boys",
                "season": ["Fall"],
                "description": 
                "Ben 10 Boys Navy Blue Slippers",
                "price": 45.99
        }]});
    
        console.log('\n*** Lab 4 - All Properties of Array ***');
        let result = await client.json.get('warehouse:1', { path: '$.inventory[*]' });
        console.log(JSON.stringify(result, null, 4)); 

        console.log('\n*** Lab 4 - All Properties of a Field ***');
        result = await client.json.get('warehouse:1', { path: '$.inventory[*].price' });
        console.log(JSON.stringify(result, null, 4)); 

        console.log('\n*** Lab 4 - Relational - Equality ***');
        result = await client.json.get('warehouse:1', { path: '$.inventory[?(@.description=="Turtle Check Men Navy Blue Shirt")]' });
        console.log(JSON.stringify(result, null, 4)); 

        console.log('\n*** Lab 4 - Relational - Less Than ***');
        result = await client.json.get('warehouse:1', { path: '$.inventory[?(@.price<100)]' });
        console.log(JSON.stringify(result, null, 4)); 

        console.log('\n*** Lab 4 - Relational - Greater Than or Equal ***');
        result = await client.json.get('warehouse:1', { path: '$.inventory[?(@.id>=20000)]' });
        console.log(JSON.stringify(result, null, 4)); 

        console.log('\n*** Lab 4 - Logical AND ***');
        result = await client.json.get('warehouse:1', { path: '$.inventory[?(@.gender=="Men"&&@.price>20)]' });
        console.log(JSON.stringify(result, null, 4)); 

        console.log('\n*** Lab 4 - Logical OR ***');
        result = await client.json.get('warehouse:1', { path: '$.inventory[?(@.price<100||@.gender=="Women")].id' });
        console.log(JSON.stringify(result, null, 4));

        console.log('\n*** Lab 4 - Regex - Contains Exact ***');
        result = await client.json.get('warehouse:1', { path: '$.inventory[?(@.description =~ "Blue")]' });
        console.log(JSON.stringify(result, null, 4));

        console.log('\n*** Lab 4 - Regex - Contains, Case Insensitive ***');
        result = await client.json.get('warehouse:1', { path: '$.inventory[?(@.description =~ "(?i)watch")]' });
        console.log(JSON.stringify(result, null, 4));

        console.log('\n*** Lab 4 - Regex - Begins With ***');
        result = await client.json.get('warehouse:1', { path: '$.inventory[?(@.description =~ "^T")]' });
        console.log(JSON.stringify(result, null, 4));
    }
}