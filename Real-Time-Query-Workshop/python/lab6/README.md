<!-- IaaS AWS Terraform Version with A-A Redis Search -->

**Real Time Query Workshop**

# Lab 6 - Deploying a 99.999 Redis Environment

## 1. Login to the Redis Enterprise admin console using the URL and credentials provided by your instructor

## 2. Create a new Geo Distributed CRDB database

![alt_text](images/image1.png "image_tooltip")

## 3. Give your database a name following the pattern &lt;last-name>-crdb

* Add the RedisJSON and the RediSearch 2 module
* Add the participating clusters and leave 0.1 GB of memory limit

![alt_text](images/image2.png "image_tooltip")

## 4. Note the endpoint of your recently created CRDB in us-east-1 and us-west-2 regions

![alt_text](images/image3.png "image_tooltip")

#####

![alt_text](images/image4.png "image_tooltip")

## 5. Configure RedisInsight to connect to both CRDB regions

![alt_text](images/image5.png "image_tooltip")

![alt_text](images/image6.png "image_tooltip")

## 6. Open each CRDB region in a separate window

![alt_text](images/image7.png "image_tooltip")

## 7. Create an index on each CRDB region

```python
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
```

![alt_text](images/image8.png "image_tooltip")

## 8. Add a new JSON document on us-east-1 CRDB region and verify that it was propagated to us-west-2 CRDB region

```python
client.json().set('product:15970', '$', {"id": 15970, "gender": "Men", "season":["Fall", "Winter"], "description": "Turtle Check Men Navy Blue Shirt", "price": 34.95, "city": "Boston", "coords": "-71.057083, 42.361145"})
```

![alt_text](images/image9.png "image_tooltip")

## 9. Search for "shirt" on both CRDB regions and verify that you get results on both regions

```python
query = Query('@description:shirt')
result = client.ft('idx1').search(query)
print(result)
```

![alt_text](images/image10.png "image_tooltip")

## 10. Now add a second JSON document on us-west-2 CRDB region and verify that it was propagated to us-east-1 CRDB region

```python
client.json().set('product:59263', '$', {"id": 59263, "gender": "Women", "season":["Fall", "Winter", "Spring", "Summer"],"description": "Titan Women Silver Watch", "price": 129.99, "city": "Dallas", "coords": "-96.808891, 32.779167"})
'
```

![alt_text](images/image11.png "image_tooltip")

## 11. Search for the "Winter" season tag on both CRDB regions and verify that you get two results on both regions

```python
query = Query('@season:{Winter}')
result = client.ft('idx1').search(query)
print(result)
```

![alt_text](images/image12.png "image_tooltip")
