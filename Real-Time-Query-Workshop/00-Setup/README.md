# Redis Workshop 00 Setup

![Redis](https://redis.com/wp-content/themes/wpx/assets/images/logo-redis.svg?auto=webp&quality=85,75&width=120)

These labs are designed to run either with built-in RedisStack or Redis Cloud.

To provision free forever instance of Redis Cloud:
- Head to https://redis.io/try-free/
- Register with an email address you can access during the workshop
- Create an **Essentials** database with the 30MB free tier (no credit card required)
- Note your public Redis database endpoint and default user password

# OR

- Run Redis Stack via Docker
```bash
docker run -d --name my-redis-stack -p 6379:6379  redis/redis-stack-server:latest
```
Your database is at http://localhost:6379

- Download and install [Redis Insight](https://redis.io/insight/)
