# Lab 5 - Advanced Search
Aggregation and other more complex RediSearch queries
## Contents
1.  [Business Value Statement](#value)
2.  [Vector Similarity Search](#vss)
    1.  [Data Set](#vss_dataset)
    2.  [Data Load](#vss_dataload)
    3.  [Index Creation](#vss_index)
    4.  [Search](#vss_search)
3.  [Advanced Search Queries](#adv_search)
    1.  [Data Set](#advs_dataset)
    2.  [Data Load](#advs_dataload)
    3.  [Index Creation](#advs_index)
    4.  [Search w/JSON Filtering - Example 1](#advs_ex1)
    5.  [Search w/JSON Filtering - Example 2](#advs_ex2)
4.  [Aggregation](#aggr)
    1.  [Data Set](#aggr_dataset)
    2.  [Data Load](#aggr_dataload)
    3.  [Index Creation](#aggr_index)
    4.  [Aggregation - Count](#aggr_count)
    5.  [Aggregation - Sum](#aggr_sum)

## Business Value Statement <a name="value"></a>
Redis provides the following additional advanced search capabilities to derive further value of Redis-held data:
* Vector Similarity Search - Store and search by ML-generated encodings of text and images
* Search + JSON Filtering - Combine the power of search with JSONPath filtering of search results
* Aggregation - Create processing pipelines of search results to extract analytic insights.

## Vector Similarity Search (VSS) <a name="vss"></a>
The VSS exercises must be done against a Redis Stack env.
### Data Set <a name="vss_dataset"></a>
- Image 16185: Enroute Men Leather Black Formal Shoes  
![shoes](16185.jpg)
- Image 4790: ADIDAS Sky Ball Brown T-shirt  
![shirt](4790.jpg)
- Image 25628: Fastrack Women Charcoal Grey Dial Watch  
![watch](25628.jpg)
### Data Load <a name="vss_dataload"></a>
```javascript
import { SchemaFieldTypes, VectorAlgorithms } from 'redis';
import * as mobilenet from '@tensorflow-models/mobilenet';
import * as tfnode from '@tensorflow/tfjs-node';
import fsPromises from 'node:fs/promises';
import * as path  from 'path';

async function vectorize(fileName) {
    const image =  await fsPromises.readFile(path.join(process.env.PWD, `lab5/${fileName}`));
    const decodedImage = tfnode.node.decodeImage(image, 3);
    const model = await mobilenet.load({version:1, alpha:.5});
    const vector = model.infer(decodedImage, true);
    return (await vector.array())[0];
}

    const images = ['16185.jpg', '4790.jpg', '25628.jpg'];
    for (const image of images) {
        const vec = await vectorize(image);
        const id = path.basename(image, '.jpg');
        await client.json.set(`image:${id}`, '$', {image_id: id, image_vector: vec});
    }
```
### Index Creation <a name="vss_index">
#### Command
```javascript
    let idxRes = await client.ft.create('vss_idx', {
        '$.image_id': {
            type: SchemaFieldTypes.TAG,
            AS: 'image_id'
        },
        '$.image_vector': {
            type: SchemaFieldTypes.VECTOR,
            AS: 'image_vector',
            ALGORITHM: VectorAlgorithms.FLAT,
            TYPE: 'FLOAT32',
            DIM: 512,
            DISTANCE_METRIC: 'L2'
        }
     }, { ON: 'JSON', PREFIX: 'image:'});

    console.log(idxRes);
```
#### Result
```bash
OK
```

### Search <a name="vss_search">
#### Query Item
- Image 35460: Doodle Boys Printed Green T-shirt  
![shirt](35460.jpg)
#### Command
```javascript
    let vec = await vectorize('35460.jpg');
    let result = await client.ft.search('vss_idx', '*=>[KNN 3 @image_vector $query_vec]', {
        PARAMS: { query_vec: Buffer.from(new Float32Array(vec).buffer) },
        RETURN: ['__image_vector_score', 'image_id'],
        DIALECT: 2
    });
    console.log(JSON.stringify(result, null, 4));
```
#### Result
```json
{
    "total": 3,
    "documents": [
        {
            "id": "image:4790",
            "value": {
                "__image_vector_score": "426.185058594",
                "image_id": "4790"
            }
        },
        {
            "id": "image:16185",
            "value": {
                "__image_vector_score": "336.573822021",
                "image_id": "16185"
            }
        },
        {
            "id": "image:25628",
            "value": {
                "__image_vector_score": "436.19921875",
                "image_id": "25628"
            }
        }
    ]
}
```

## Advanced Search Queries <a name="adv_search">
### Data Set <a name="advs_dataset">
```json
{
    "city": "Boston",
    "location": "42.361145, -71.057083",
    "inventory": [
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
},
{
    "city": "Dallas",
    "location": "32.779167, -96.808891",
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
}
```

### Data Load  <a name="advs_dataload">
```javascript
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
    await client.json.set('warehouse:1', '$', {
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
```

### Index Creation <a name="advs_index">
#### Command
```javascript
    let result = await client.ft.create('wh_idx', {
        '$.city': {
            type: SchemaFieldTypes.TEXT,
            AS: 'city'
        },
        '$.location': {
            type: SchemaFieldTypes.GEO,
            AS: 'location'
        }, 
        '$.inventory[*].id': {
            type: SchemaFieldTypes.NUMERIC,
            AS: 'id'
        },
        '$.inventory[*].gender': {
            type: SchemaFieldTypes.TAG,
            AS: 'gender'
        },
        '$.inventory[*].season.*': {
            type: SchemaFieldTypes.TAG,
            AS: 'season'
        },
        '$.inventory[*].description': {
            type: SchemaFieldTypes.TEXT,
            AS: 'description'
        },
        '$.inventory[*].price': {
            type: SchemaFieldTypes.NUMERIC,
            AS: 'price'
        }
     }, { ON: 'JSON', PREFIX: 'warehouse:'});
    console.log(result);
```
#### Result
```bash
OK
```

### Search w/JSON Filtering - Example 1 <a name="advs_ex1">
Find all inventory ids from all warehouses that have a season value of Fall and Price > $50.
#### Command
```javascript
    result = await client.ft.search('wh_idx', '@season:{Fall}', {
        RETURN: ['$.inventory[?(@.price>50)].id'],
        DIALECT: 3
    });
```
#### Result
```json
{
    "total": 2,
    "documents": [
        {
            "id": "warehouse:2",
            "value": {
                "$.inventory[?(@.price>50)].id": "[51919,4602]"
            }
        },
        {
            "id": "warehouse:1",
            "value": {
                "$.inventory[?(@.price>50)].id": "[59263]"
            }
        }
    ]
}
```

### Search w/JSON Filtering - Example 2 <a name="advs_ex2">
Find all inventory items in Dallas that are for Women or Girls
#### Command
```javascript
    result = await client.ft.search('wh_idx', '@city:(Dallas)', {
        RETURN: ['$.inventory[?(@.gender=="Women" || @.gender=="Girls")]'],
        DIALECT: 3
    });
    console.log(JSON.stringify(result, null, 4));
```
#### Result
```json
{
    "total": 1,
    "documents": [
        {
            "id": "warehouse:2",
            "value": {
                "$.inventory[?(@.gender==\"Women\" || @.gender==\"Girls\")]": "[{\"id\":51919,\"gender\":\"Women\",\"season\":[\"Summer\"],\"description\":\"Nyk Black Horado Handbag\",\"price\":52.49},{\"id\":37561,\"gender\":\"Girls\",\"season\":[\"Spring\",\"Summer\"],\"description\":\"Madagascar3 Infant Pink Snapsuit Romper\",\"price\":23.95}]"
            }
        }
    ]
}
```

## Aggregation <a name="aggr">
### Syntax
See redis.io
### Data Set <a name="aggr_dataset">
```JSON
{
    "title": "System Design Interview",
    "year": 2020,
    "price": 35.99
},
{
    "title": "The Age of AI: And Our Human Future",
    "year": 2021,
    "price": 13.99
},
{
    "title": "The Art of Doing Science and Engineering: Learning to Learn",
    "year": 2020,
    "price": 20.99
},
{
    "title": "Superintelligence: Path, Dangers, Stategies",
    "year": 2016,
    "price": 14.36
}
```
### Data Load <a name="aggr_dataload">
```javascript
await client.json.set('book:1', '$', {"title": "System Design Interview","year": 2020,"price": 35.99});
await client.json.set('book:2', '$', {"title": "The Age of AI: And Our Human Future","year": 2021,"price": 13.99});
await client.json.set('book:3', '$', {"title": "The Art of Doing Science and Engineering: Learning to Learn","year": 2020,"price": 20.99});
await client.json.set('book:4', '$', {"title": "Superintelligence: Path, Dangers, Stategies","year": 2016,"price": 14.36});

```

### Index Creation <a name="aggr_index">
#### Command
```bash
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
```
#### Result
```bash
OK
```

### Aggregation - Count <a name="aggr_count">
Find the total number of books per year
#### Command
```javascript
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
```
#### Result
```json
[
    {
        "year": "2021",
        "count": "1"
    },
    {
        "year": "2020",
        "count": "2"
    },
    {
        "year": "2016",
        "count": "1"
    }
]
```

### Aggregation - Sum <a name="aggr_sum">
Sum of inventory dollar value by year
#### Command
```javascript
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
    })
    console.log(JSON.stringify(result.results,null,4));
```
#### Result
```json
[
    {
        "year": "2021",
        "sum": "13.99"
    },
    {
        "year": "2020",
        "sum": "56.98"
    },
    {
        "year": "2016",
        "sum": "14.36"
    }
]
```