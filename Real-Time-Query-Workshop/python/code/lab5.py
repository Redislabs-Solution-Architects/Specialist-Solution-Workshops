'''
  @fileoverview Advanced Search operations with the redis-py client
  @maker Joey Whelan
'''
from redis.commands.search.field import NumericField, TagField, TextField, VectorField 
from redis.commands.search.indexDefinition import IndexDefinition, IndexType
from redis.commands.search.query import Query
from redis.commands.search.aggregation import AggregateRequest
from redis.commands.search import reducers
import numpy as np

class Lab5(object):

    def run(self, client):
        print('\n*** Lab 5 - VSS - Index Creation ***')
        try: 
            client.ft('vss_idx').dropindex()
        except:
            pass
        schema = [VectorField('$.vector', 'FLAT', { "TYPE": 'FLOAT32', "DIM": 4, "DISTANCE_METRIC": 'L2'},  as_name='vector')]
        idx_def: IndexDefinition = IndexDefinition(index_type=IndexType.JSON, prefix=['vec:'])
        result = client.ft('vss_idx').create_index(schema, definition=idx_def)
        print(result)
        
        print('\n*** Lab 5 - VSS - Data Load ***')
        client.json().set('vec:1', '$', {'vector': [1,1,1,1]})
        client.json().set('vec:2', '$', {'vector': [2,2,2,2]}) 
        client.json().set('vec:3', '$', {'vector': [3,3,3,3]}) 
        client.json().set('vec:4', '$', {'vector': [4,4,4,4]}) 
        
        print('\n*** Lab 5 - VSS - Search ***')
        vec = [2,2,3,3]
        query_vector = np.array(vec, dtype=np.float32).tobytes()
        q_str = '*=>[KNN 3 @vector $query_vec]'
        q = Query(q_str)\
            .sort_by('__vector_score')\
            .dialect(2)    
        params_dict = {"query_vec": query_vector}
        results = client.ft('vss_idx').search(q, query_params=params_dict)
        print(results) 

        print('\n*** Lab 5 - Advanced Search Queries - Index Creation ***')
        try: 
            client.ft('wh_idx').dropindex()
        except:
            pass
        idx_def = IndexDefinition(index_type=IndexType.JSON, prefix=['warehouse:'])
        schema = [
            TextField('$.city', as_name='city')
        ]
        result = client.ft('wh_idx').create_index(schema, definition=idx_def)
        print(result)

        print('\n*** Lab 5 - Advanced Search Queries - Data Load ***')
        client.json().set('warehouse:1', '$', {
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
        })
        client.json().set('warehouse:2', '$', {
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
        })

        print('\n*** Lab 5 - Search w/JSON Filtering - Example 1 ***')
        query = Query('@city:Boston').return_field('$.inventory[?(@.price>50)].id')
        result = client.ft('wh_idx').search(query)
        print(result)

        print('\n*** Lab 5 - Search w/JSON Filtering - Example 2 ***')
        query = Query('@city:Dallas')\
            .return_field('$.inventory[?(@.gender=="Women" || @.gender=="Girls")]')\
            .dialect(3)
        result = client.ft('wh_idx').search(query)
        print(result)

        print('\n*** Lab 5 - Aggregation - Index Creation ***')
        try: 
            client.ft('book_idx').dropindex()
        except:
            pass
        idx_def = IndexDefinition(index_type=IndexType.JSON, prefix=['book:'])
        schema = [
            TextField('$.title', as_name='title'),
            NumericField('$.year', as_name='year'),
            NumericField('$.price', as_name='price')
        ]
        result = client.ft('book_idx').create_index(schema, definition=idx_def)
        print(result)

        print('\n*** Lab 5 - Aggregation - Data Load ***')
        client.json().set('book:1', '$', {"title": "System Design Interview","year": 2020,"price": 35.99})
        client.json().set('book:2', '$', {"title": "The Age of AI: And Our Human Future","year": 2021,"price": 13.99})
        client.json().set('book:3', '$', {"title": "The Art of Doing Science and Engineering: Learning to Learn","year": 2020,"price": 20.99})
        client.json().set('book:4', '$', {"title": "Superintelligence: Path, Dangers, Stategies","year": 2016,"price": 14.36})

        print('\n*** Lab 5 - Aggregation - Count ***')
        request = AggregateRequest(f'*').group_by('@year', reducers.count().alias('count'))
        result = client.ft('book_idx').aggregate(request)
        print(result.rows)

        print('\n*** Lab 5 - Aggregation - Sum ***')
        request = AggregateRequest(f'*').group_by('@year', reducers.sum('@price').alias('sum'))
        result = client.ft('book_idx').aggregate(request)
        print(result.rows)