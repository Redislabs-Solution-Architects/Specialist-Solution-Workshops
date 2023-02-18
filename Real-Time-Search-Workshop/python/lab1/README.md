**Real Time Search Workshop**

# Lab 1 - Create your Redis Environment

## 1. Sign up for the Redis Cloud trial

Visit [https://redis.com/try-free/](https://redis.com/try-free/) and sign-up for a free trial:

![alt_text](images/image1.png "image_tooltip")

## 2. Check your email to verify your account

![alt_text](images/image2.png "image_tooltip")

## 3. Login with your new credentials

![alt_text](images/image3.png "image_tooltip")

## 4. Click "+ New Subscription" to add a new subscription to your account

![alt_text](images/image4.png "image_tooltip")

## 5. Select a free Fixed plan using a cloud provider and region of your choice

![alt_text](images/image5.png "image_tooltip")

## 6. Name your subscription and click "Create Subscription"

![alt_text](images/image6.png "image_tooltip")

## 7. Create a new database under your newly created subscription

![alt_text](images/image7.png "image_tooltip")

## 8. Give a name to your new database and select type "Redis Stack"

![alt_text](images/image8.png "image_tooltip")

## 9. Set a password for your database

![alt_text](images/image9.png "image_tooltip")

## 10. Activate your new database

![alt_text](images/image10.png "image_tooltip")

## 11. Download RedisInsight Desktop on your laptop

![alt_text](images/image11.png "image_tooltip")

## 12. Install RedisInsight Desktop

![alt_text](images/image12.png "image_tooltip")

## 13. Open RedisInsight Desktop and add a new database

![alt_text](images/image13.png "image_tooltip")

## 14. Copy the URI details of your new database and paste it in RedisInsight

![alt_text](images/image14.png "image_tooltip")

![alt_text](images/image15.png "image_tooltip")

## 15. Your Redis database has been added and is ready to be used

![alt_text](images/image16.png "image_tooltip")

## 16. Your environment is now ready for the labs in this workshop

![alt_text](images/image17.png "image_tooltip")

## 17. Python Setup
### Virtual Environment
```bash
python3 -m venv .venv
source ./.venv/bin/activate
pip install redis
```
### Modules Needed
``` python
from redis import from_url
```
### Connect Client
```python
        user = 'your user'
        pwd = 'your password'
        url = 'your url'
        port = 'your port'
    
        client = from_url(f'redis://{user}:{pwd}@{url}:{port}')
        print(client.ping())
```
### Result
```bash
True
```