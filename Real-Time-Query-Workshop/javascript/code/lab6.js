/*
  @fileoverview AA Search operations with the redis-py client
  @maker Joey Whelan
*/

import { SchemaFieldTypes } from 'redis';

export class Lab6 {

    async run(client) {
        console.log('\n*** Lab 6 - Index Creation ***');
        try {await client.ft.dropIndex('idx1')} catch(err){};
        let result = await client.ft.create('idx1', {
            '$.id': {
                type: SchemaFieldTypes.NUMERIC,
                AS: 'id'
            },
            '$.gender': {
                type: SchemaFieldTypes.TAG,
                AS: 'gender'
            }, 
            '$.season.*': {
                type: SchemaFieldTypes.TAG,
                AS: 'season'
            },
            '$.description': {
                type: SchemaFieldTypes.TEXT,
                AS: 'description'
            },
            '$.price': {
                type: SchemaFieldTypes.NUMERIC,
                AS: 'price'
            },
            '$.city': {
                type: SchemaFieldTypes.TEXT,
                AS: 'city'
            },
            '$.coords': {
                type: SchemaFieldTypes.GEO,
                AS: 'coords'
            }
        }, { ON: 'JSON', PREFIX: 'product:'});
        console.log(result);

        console.log('\n*** Lab 6 - Add a product ***')
        await client.json.set('product:15970', '$', {"id": 15970, "gender": "Men", "season":["Fall", "Winter"], "description": "Turtle Check Men Navy Blue Shirt", "price": 34.95, "city": "Boston", "coords": "-71.057083, 42.361145"});
       
        console.log('\n*** Lab 6 - Search 1 ***')
        result = await client.ft.search('idx1', '@description:shirt');
        console.log(JSON.stringify(result, null, 4));

        console.log('\n*** Lab 6 - Add another product ***')
        await client.json.set('product:59263', '$', {"id": 59263, "gender": "Women", "season":["Fall", "Winter", "Spring", "Summer"],"description": "Titan Women Silver Watch", "price": 129.99, "city": "Dallas", "coords": "-96.808891, 32.779167"});
       
        console.log('\n*** Lab 6 - Search 2 ***')
        result = await client.ft.search('idx1', '@season:{Winter}');
        console.log(JSON.stringify(result, null, 4));
    }
}