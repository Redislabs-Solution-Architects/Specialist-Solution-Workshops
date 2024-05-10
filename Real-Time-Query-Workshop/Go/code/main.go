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
		Protocol: 2,  // Use RESP2 for now for search
	})

	lab1(rdb)
	lab2(rdb)
	lab3(rdb)
	lab4(rdb)
}
