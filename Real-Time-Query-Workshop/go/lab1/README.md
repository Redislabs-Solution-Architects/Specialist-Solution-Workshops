**Real Time Query Workshop**

# Lab 1 - Set up your Go Environment

See [00-Setup](../../00-Setup/README.md)

## Go Setup
You'll want to use at least Go version 1.21

To check:
```bash
go version
```

## Connect to Redis and set and get a value
```go
package main

import (
	"context"

	"github.com/redis/go-redis/v9"
)

var ctx = context.Background()

func main() {
rdb := redis.NewClient(&redis.Options{
		Addr:     "localhost:6379",
		Password: "", // no password set
		DB:       0,  // use default DB
	})

err := rdb.Set(ctx, "key", "value", 0).Err()
if err != nil {
        panic(err)
}

val, err := rdb.Get(ctx, "key").Result()
if err != nil {
        panic(err)
}
fmt.Println("key", val)
```

## Result
```bash
key value
```

```go
val2, err := rdb.Get(ctx, "key2").Result()
if err == redis.Nil {
        fmt.Println("key2 does not exist")
} else if err != nil {
        panic(err)
} else {
        fmt.Println("key2", val2)
}
```
## Result
```bash
key2 does not exist
```

