/**
 * @fileoverview Basic Search operations with the node-redis client
 * @maker Joey Whelan
 */
import { SchemaFieldTypes } from 'redis';

export class Lab3 {

    async run(client) {
        console.log('\n*** Lab 3 - Data Loading ***');
        await client.json.set('product:15970', '$', {"id": 15970, "gender": "Men", "season":["Fall", "Winter"], "description": "Turtle Check Men Navy Blue Shirt", "price": 34.95, "city": "Boston", "coords": "-71.057083, 42.361145"});
        await client.json.set('product:59263', '$', {"id": 59263, "gender": "Women", "season":["Fall", "Winter", "Spring", "Summer"],"description": "Titan Women Silver Watch", "price": 129.99, "city": "Dallas", "coords": "-96.808891, 32.779167"});
        await client.json.set('product:46885', '$', {"id": 46885, "gender": "Boys", "season":["Fall"], "description": "Ben 10 Boys Navy Blue Slippers", "price": 45.99, "city": "Denver", "coords": "-104.991531, 39.742043"});

        console.log('\n*** Lab 3 - Index Creation ***');
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

        console.log('\n*** Lab 3 - Retrieve All ***');
        result = await client.ft.search('idx1', '*');
        console.log(JSON.stringify(result, null, 4));

        console.log('\n*** Lab 3 - Single Term Text ***');
        result = await client.ft.search('idx1', '@description:Slippers');
        console.log(JSON.stringify(result, null, 4));

        console.log('\n*** Lab 3 - Exact Phrase Text ***');
        result = await client.ft.search('idx1', '@description:("Blue Shirt")');
        console.log(JSON.stringify(result, null, 4));

        console.log('\n*** Lab 3 - Numeric Range ***');
        result = await client.ft.search('idx1', '@price:[40,130]');
        console.log(JSON.stringify(result, null, 4));

        console.log('\n*** Lab 3 - Tag Array ***');
        result = await client.ft.search('idx1', '@season:{Spring}');
        console.log(JSON.stringify(result, null, 4));

        console.log('\n*** Lab 3 - Logical AND ***');
        result = await client.ft.search('idx1', '@price:[40, 100] @description:Blue');
        console.log(JSON.stringify(result, null, 4));

        console.log('\n*** Lab 3 - Logical OR ***');
        result = await client.ft.search('idx1', '(@gender:{Women})|(@city:Boston)');
        console.log(JSON.stringify(result, null, 4));

        console.log('\n*** Lab 3 - Negation ***');
        result = await client.ft.search('idx1', '-(@description:Shirt)');
        console.log(JSON.stringify(result, null, 4));

        console.log('\n*** Lab 3 - Prefix ***');
        result = await client.ft.search('idx1', '@description:Nav*');
        console.log(JSON.stringify(result, null, 4));

        console.log('\n*** Lab 3 - Suffix ***');
        result = await client.ft.search('idx1', '@description:*Watch');
        console.log(JSON.stringify(result, null, 4));

        console.log('\n*** Lab 3 - Fuzzy ***');
        result = await client.ft.search('idx1', '@description:%wavy%');
        console.log(JSON.stringify(result, null, 4));

        console.log('\n*** Lab 3 - Geo ***');
        result = await client.ft.search('idx1', '@coords:[-104.800644 38.846127 100 mi]');
        console.log(JSON.stringify(result, null, 4));
    }
}