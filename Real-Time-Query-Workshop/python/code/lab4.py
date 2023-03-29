'''
  @fileoverview Advanced JSON operations with the redis client
  @maker Joey Whelan
'''
from redis.commands.json.path import Path
import json

class Lab4(object):
    
    def run(self, client):
        print('\n*** Lab 4 - Data Loading ***')
        client.json().set('warehouse:1', '$', {
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
        }]})
    
        print('\n*** Lab 4 - All Properties of Array ***')
        result = client.json().get('warehouse:1', Path('$.inventory[*]'))
        print(json.dumps(result, indent=4)) 

        print('\n*** Lab 4 - All Properties of a Field ***')
        result = client.json().get('warehouse:1', Path('$.inventory[*].price'))
        print(json.dumps(result, indent=4)) 

        print('\n*** Lab 4 - Relational - Equality ***')
        result = client.json().get('warehouse:1', Path('$.inventory[?(@.description=="Turtle Check Men Navy Blue Shirt")]'))
        print(json.dumps(result, indent=4)) 

        print('\n*** Lab 4 - Relational - Less Than ***')
        result = client.json().get('warehouse:1', Path('$.inventory[?(@.price<100)]'))
        print(json.dumps(result, indent=4)) 

        print('\n*** Lab 4 - Relational - Greater Than or Equal ***')
        result = client.json().get('warehouse:1', Path('$.inventory[?(@.id>=20000)]'))
        print(json.dumps(result, indent=4)) 

        print('\n*** Lab 4 - Logical AND ***')
        result = client.json().get('warehouse:1', Path('$.inventory[?(@.gender=="Men"&&@.price>20)]'))
        print(json.dumps(result, indent=4)) 

        print('\n*** Lab 4 - Logical OR ***')
        result = client.json().get('warehouse:1', Path('$.inventory[?(@.price<100||@.gender=="Women")].id'))
        print(json.dumps(result, indent=4))

        print('\n*** Lab 4 - Regex - Contains Exact ***')
        result = client.json().get('warehouse:1', Path('$.inventory[?(@.description =~ "Blue")]'))
        print(json.dumps(result, indent=4))

        print('\n*** Lab 4 - Regex - Contains, Case Insensitive ***')
        result = client.json().get('warehouse:1', Path('$.inventory[?(@.description =~ "(?i)watch")]'))
        print(json.dumps(result, indent=4))

        print('\n*** Lab 4 - Regex - Begins With ***')
        result = client.json().get('warehouse:1', Path('$.inventory[?(@.description =~ "^T")]'))
        print(json.dumps(result, indent=4))