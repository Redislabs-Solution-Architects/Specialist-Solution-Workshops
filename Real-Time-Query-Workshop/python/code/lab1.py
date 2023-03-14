# Maker: Joey Whelan
from redis import from_url
import configparser

class Lab1(object):
    def run(self):
        print('*** Lab 1 - Connect Client ***');
        config = configparser.ConfigParser()
        config.read('redis.ini')

        user = config['Redis']['USER_NAME']
        pwd = config['Redis']['PASSWORD']
        url = config['Redis']['URL']
        port = config['Redis']['PORT']
    
        client = from_url(f'redis://{user}:{pwd}@{url}:{port}')
        print(client.ping())
        return client