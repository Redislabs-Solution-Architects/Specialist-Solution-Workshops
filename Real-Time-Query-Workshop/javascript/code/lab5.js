/**
 * @fileoverview Advanced Search operations with the redis client
 * @maker Joey Whelan
 */
import { SchemaFieldTypes, VectorAlgorithms, AggregateSteps, AggregateGroupByReducers } from 'redis';

export class Lab5 {
    
    async run(client) {
        console.log('\n*** Lab 5 - VSS - Index Creation ***');
        try {await client.ft.dropIndex('vss_idx')} catch(err){};
        let idxRes = await client.ft.create('vss_idx', {
            '$.vector': {
                type: SchemaFieldTypes.VECTOR,
                AS: 'vector',
                ALGORITHM: VectorAlgorithms.FLAT,
                TYPE: 'FLOAT32',
                DIM: 4,
                DISTANCE_METRIC: 'L2'
            }
        }, { ON: 'JSON', PREFIX: 'vec:'});
        console.log(idxRes);

        console.log('\n*** Lab 5 - VSS - Data Load ***');
        await client.json.set('vec:1', '$', {vector: [1,1,1,1]});
        await client.json.set('vec:2', '$', {vector: [2,2,2,2]});
        await client.json.set('vec:3', '$', {vector: [3,3,3,3]});
        await client.json.set('vec:4', '$', {vector: [4,4,4,4]});

        console.log('\n*** Lab 5 - VSS - Search ***');
        let vec = [2,2,3,3]
        let result = await client.ft.search('vss_idx', '*=>[KNN 3 @vector $query_vec]', {
            PARAMS: { query_vec: Buffer.from(new Float32Array(vec).buffer) },
            DIALECT: 2,
            SORTBY: {
                BY: '__vector_score',
                DIRECTIION: 'ASC'
            }
        });
        console.log(JSON.stringify(result, null, 4));

        console.log('\n*** Lab 5 - Advanced Search Queries - Index Creation ***');
        try {await client.ft.dropIndex('wh_idx')} catch(err){};
        result = await client.ft.create('wh_idx', {
            '$.city': {
                type: SchemaFieldTypes.TEXT,
                AS: 'city'
            }
        }, { ON: 'JSON', PREFIX: 'warehouse:'});
        console.log(result);

        console.log('\n*** Lab 5 - Advanced Search Queries - Data Load ***');
        await client.json.set('warehouse:1', '$', {
            "city": "Boston",
            "location": "-71.057083, 42.361145",
            "inventory":[
                {
                    "id": 15970,
                    "gender": "Men",
                    "season":["Fall", "Winter"],
                    "description": "Turtle Check Men Navy Blue Shirt",
                    "price": 34.95
                },
                {
                    "id": 59263,
                    "gender": "Women",
                    "season": ["Fall", "Winter", "Spring", "Summer"],
                    "description": "Titan Women Silver Watch",
                    "price": 129.99
                },
                {
                    "id": 46885,
                    "gender": "Boys",
                    "season": ["Fall"],
                    "description": "Ben 10 Boys Navy Blue Slippers",
                    "price": 45.99
                }
            ]
        });
        await client.json.set('warehouse:2', '$', {
            "city": "Dallas",
            "location": "-96.808891, 32.779167",
            "inventory": [
                {
                    "id": 51919,
                    "gender": "Women",
                    "season":["Summer"],
                    "description": "Nyk Black Horado Handbag",
                    "price": 52.49
                },
                {
                    "id": 4602,
                    "gender": "Unisex",
                    "season": ["Fall", "Winter"],
                    "description": "Wildcraft Red Trailblazer Backpack",
                    "price": 50.99
                },
                {
                    "id": 37561,
                    "gender": "Girls",
                    "season": ["Spring", "Summer"],
                    "description": "Madagascar3 Infant Pink Snapsuit Romper",
                    "price": 23.95
                }
            ]
        });

        console.log('\n*** Lab 5 - Search w/JSON Filtering - Example 1 ***');
        result = await client.ft.search('wh_idx', '@city:Boston', {
            RETURN: ['$.inventory[?(@.price>50)].id'],
            DIALECT: 3
        });
        console.log(JSON.stringify(result, null, 4));

        console.log('\n*** Lab 5 - Search w/JSON Filtering - Example 2 ***');
        result = await client.ft.search('wh_idx', '@city:(Dallas)', {
            RETURN: ['$.inventory[?(@.gender=="Women" || @.gender=="Girls")]'],
            DIALECT: 3
        });
        console.log(JSON.stringify(result, null, 4));

        console.log('\n*** Lab 5 - Aggregation - Index Creation ***');
        try {await client.ft.dropIndex('book_idx')} catch(err){};
        result = await client.ft.create('book_idx', {
            '$.title': {
                type: SchemaFieldTypes.TEXT,
                AS: 'title'
            },
            '$.year': {
                type: SchemaFieldTypes.NUMERIC,
                AS: 'year'
            },
            '$.price': {
            type: SchemaFieldTypes.NUMERIC,
            AS: 'price'
        }
        }, { ON: 'JSON', PREFIX: 'book:'});
        console.log(result);

        console.log('\n*** Lab 5 - Aggregation - Data Load ***');
        await client.json.set('book:1', '$', {"title": "System Design Interview","year": 2020,"price": 35.99});
        await client.json.set('book:2', '$', {"title": "The Age of AI: And Our Human Future","year": 2021,"price": 13.99});
        await client.json.set('book:3', '$', {"title": "The Art of Doing Science and Engineering: Learning to Learn","year": 2020,"price": 20.99});
        await client.json.set('book:4', '$', {"title": "Superintelligence: Path, Dangers, Stategies","year": 2016,"price": 14.36});

        console.log('\n*** Lab 5 - Aggregation - Count ***');
        result = await client.ft.aggregate('book_idx', '*', {
            STEPS: [
                {   type: AggregateSteps.GROUPBY,
                    properties: ['@year'],
                    REDUCE: [
                        {   type: AggregateGroupByReducers.COUNT,
                            property: '@year',
                            AS: 'count'
                        }
                    ]   
                }
            ]
        })
        console.log(JSON.stringify(result.results,null,4));

        console.log('\n*** Lab 5 - Aggregation - Sum ***');
        result = await client.ft.aggregate('book_idx', '*', {
            STEPS: [
                {   type: AggregateSteps.GROUPBY,
                    properties: ['@year'],
                    REDUCE: [
                        {   type: AggregateGroupByReducers.SUM,
                            property: '@price',
                            AS: 'sum'
                        }
                    ]   
                }
            ]
        });
        console.log(JSON.stringify(result.results,null,4));
    }
}