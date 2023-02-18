'''
  @fileoverview AA Search operations with the redis-py client
  @maker Joey Whelan
'''
from redis.commands.search.field import NumericField, TagField, TextField, GeoField
from redis.commands.search.indexDefinition import IndexDefinition, IndexType
from redis.commands.search.query import Query

class Lab6(object):

    def run(self, client):
        print('\n*** Lab 6 - Index Creation ***')
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

        print('\n*** Lab 6 - Add a product ***')
        client.json().set('product:15970', '$', {"id": 15970, "gender": "Men", "season":["Fall", "Winter"], "description": "Turtle Check Men Navy Blue Shirt", "price": 34.95, "city": "Boston", "coords": "-71.057083, 42.361145"})
       
        print('\n*** Lab 6 - Search 1 ***')
        query = Query('@description:shirt')
        result = client.ft('idx1').search(query)
        print(result)

        print('\n*** Lab 6 - Add another product ***')
        client.json().set('product:59263', '$', {"id": 59263, "gender": "Women", "season":["Fall", "Winter", "Spring", "Summer"],"description": "Titan Women Silver Watch", "price": 129.99, "city": "Dallas", "coords": "-96.808891, 32.779167"})
       
        print('\n*** Lab 6 - Search 2 ***')
        query = Query('@season:{Winter}')
        result = client.ft('idx1').search(query)
        print(result)