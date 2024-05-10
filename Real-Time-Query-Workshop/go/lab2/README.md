**Real Time Query Workshop**

# Lab 2 - Add JSON to Redis

## Create an object and add to Redis as JSON
```go
type Customer struct {
	Surname   string 
	FirstName string 
	Email     string 
	IP        string 
	AccountNo string  
	Owner     string 
	Balance   float64
}

func lab2(rdb *redis.Client) {
	customer := Customer{"Smith", "Suzy", "suzy@example.com", "192.168.0.3", "1234", "Lara", 33.42}
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
```
## Result
```bash
OK
```
## Check Redis Insight for the new key and explore its value