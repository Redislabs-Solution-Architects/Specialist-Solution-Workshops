![Redis](https://redis.io/wp-content/uploads/2024/04/Logotype.svg)

# Redis Workshop Setup

These labs are designed to run either with built-in RedisStack or Redis Cloud.

# Database setup
To provision a free forever instance of Redis Cloud:
- Head to https://redis.io/try-free/
- Register with an email address you can access during the workshop
- Create an **Essentials** database with the 30MB free tier (no credit card required)
- Note your public Redis database endpoint and default user password

## OR

- Run Redis Stack via Docker
```bash
docker run -d --name my-redis-stack -p 6379:6379  redis/redis-stack-server:latest
```
Your database is at http://localhost:6379

# Redis Insight
- Download and install [Redis Insight](https://redis.io/insight/)
