package main

import (
	"encoding/json"
	"fmt"

	"github.com/redis/go-redis/v9"
)

type Customer struct {
	Surname   string  `csv:"surname"  json:"surname"`
	FirstName string  `csv:"firstname" json:"firstname"`
	Email     string  `csv:"email" json:"email"`
	IP        string  `csv:"ip" json:"ip"`
	AccountNo int64   `csv:"accountno" json:"accountno"`
	Owner     string  `csv:"owner" json:"owner"`
	Balance   float64 `csv:"balance" json:"balance"`
}

func lab2(rdb *redis.Client) {
	fmt.Println("*** Lab 2 - Insert a simple object as a json() object ***")
	customer := Customer{"Smith", "Suzy", "suzy@example.com", "192.168.0.3", 1234, "Lara", 33.42}
	b, err := json.Marshal(customer)
	if err != nil {
		panic(err)
	}
	result := rdb.JSONSet(ctx, "ex1:1", "$", b)
	if result.Err() != nil {
		panic(result.Err())
	}
	fmt.Println(result.Val())
}
