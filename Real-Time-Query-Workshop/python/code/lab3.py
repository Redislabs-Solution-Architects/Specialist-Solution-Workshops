'''
  @fileoverview Basic Search operations with the redis-py client
  @maker Joey Whelan
'''
from redis.commands.search.field import NumericField, TagField, TextField, GeoField
from redis.commands.search.indexDefinition import IndexDefinition, IndexType
from redis.commands.search.query import Query

class Lab3(object):

    def run(self, client):
        print('\n*** Lab 3 - Data Loading ***')
        client.json().set('product:15970', '$', {"id": 15970, "gender": "Men", "season":["Fall", "Winter"], "description": "Turtle Check Men Navy Blue Shirt", "price": 34.95, "city": "Boston", "coords": "-71.057083, 42.361145"})
        client.json().set('product:59263', '$', {"id": 59263, "gender": "Women", "season":["Fall", "Winter", "Spring", "Summer"],"description": "Titan Women Silver Watch", "price": 129.99, "city": "Dallas", "coords": "-96.808891, 32.779167"})
        client.json().set('product:46885', '$', {"id": 46885, "gender": "Boys", "season":["Fall"], "description": "Ben 10 Boys Navy Blue Slippers", "price": 45.99, "city": "Denver", "coords": "-104.991531, 39.742043"})

        print('\n*** Lab 3 - Index Creation ***')
        try: 
            client.ft('idx1').dropindex()
        except:
            pass

        idx_def = IndexDefinition(index_type=IndexType.JSON, prefix=['product:'])
        schema = [
            NumericField('$.id', as_name='id'),
            TagField('$.gender', as_name='gender'),
            TagField('$.season.*', as_name='season'),
            TextField('$.description', as_name='description'),
            NumericField('$.price', as_name='price'),
            TextField('$.city', as_name='city'),
            GeoField('$.coords', as_name='coords')
        ]
        result = client.ft('idx1').create_index(schema, definition=idx_def)
        print(result)

        print('\n*** Lab 3 - Retrieve All ***')
        query = Query('*')
        result = client.ft('idx1').search(query)
        print(result)

        print('\n*** Lab 3 - Single Term Text ***')
        query = Query('@description:Slippers')
        result = client.ft('idx1').search(query)
        print(result)

        print('\n*** Lab 3 - Exact Phrase Text ***')
        query = Query('@description:("Blue Shirt")')
        result = client.ft('idx1').search(query)
        print(result)

        print('\n*** Lab 3 - Numeric Range ***')
        query = Query('@price:[40,130]')
        result = client.ft('idx1').search(query)
        print(result)

        print('\n*** Lab 3 - Tag Array ***')
        query = Query('@season:{Spring}')
        result = client.ft('idx1').search(query)
        print(result)

        print('\n*** Lab 3 - Logical AND ***')
        query = Query('@price:[40, 100] @description:Blue')
        result = client.ft('idx1').search(query)
        print(result)

        print('\n*** Lab 3 - Logical OR ***')
        query = Query('(@gender:{Women})|(@city:Boston)')
        result = client.ft('idx1').search(query)
        print(result)

        print('\n*** Lab 3 - Negation ***')
        query = Query('-(@description:Shirt)')
        result = client.ft('idx1').search(query)
        print(result)

        print('\n*** Lab 3 - Prefix ***')
        query = Query('@description:Nav*')
        result = client.ft('idx1').search(query)
        print(result)

        print('\n*** Lab 3 - Suffix ***')
        query = Query('@description:*Watch')
        result = client.ft('idx1').search(query)
        print(result)

        print('\n*** Lab 3 - Fuzzy ***')
        query = Query('@description:%wavy%')
        result = client.ft('idx1').search(query)
        print(result)

        print('\n*** Lab 3 - Geo ***')
        query = Query('@coords:[-104.800644 38.846127 100 mi]')
        result = client.ft('idx1').search(query)
        print(result)