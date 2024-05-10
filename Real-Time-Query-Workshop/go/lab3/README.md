**Real Time Query Workshop**

# Lab 3 - Basic search with Redis

## Index commands
```bash
FT._list
FT.info <index name>
FT.drop <index name>
```

## Read a csv file, convert to JSON and add to Redis
```go
import (
	_ "embed"
	"fmt"
	"log"

	"github.com/gocarina/gocsv"
	"github.com/redis/go-redis/v9"
)

//go:embed customers_test.csv
var customerData string

var dropArgs = []interface{}{"FT.DROP", "demoindex"}
var indexArgs = []interface{}{"FT.CREATE", "demoindex", "ON", "JSON", "PREFIX", "1", "customer:", "SCORE", "1", "SCHEMA", "$.owner", "AS", "owner", "TAG", "SORTABLE", "$.accountno", "AS", "account", "NUMERIC", "SORTABLE"}
var searchArgs = []interface{}{"FT.SEARCH", "demoindex", "@owner:{lara\\.croft}", "SLOP", "0", "DIALECT", "3"}

func lab3(rdb *redis.Client) {
	fmt.Println("*** Lab 3 - Search within JSON objects ***")

	// Drop the index if it already exists
	dropCmd := redis.NewCmd(ctx, dropArgs...)
	rdb.Process(ctx, dropCmd)
	// Ignore any error here

	// Create the index
	cmd := redis.NewCmd(ctx, indexArgs...)
	rdb.Process(ctx, cmd)

	if cmd.Err() != nil {
		log.Fatalf("redis error creating index: %+v", cmd.Err())
	}

	if err := loadData(rdb); err != nil {
		log.Fatalf("error loading data: %+v", err)
	}

	// Run the search command
	searchCmd := redis.NewSliceCmd(ctx, searchArgs...)
	rdb.Process(ctx, searchCmd)

	fmt.Println("\n\nsearch for customers owned by lara croft")

	if searchCmd.Err() != nil {
		log.Fatalf("redis error executing search: %+v", cmd.Err())
	}

	// Print the search results
	searchResults := searchCmd.Val()

	for n := 1; n < len(searchResults); n += 2 {
		key := searchResults[n].(string)
		val := searchResults[n+1].([]interface{})[1].(string)
		fmt.Printf("%s:\t\t%s\n", key, val)
	}
}

func loadData(rdb *redis.Client) error {
	customers := []*Customer{}

	if err := gocsv.UnmarshalString(customerData, &customers); err != nil { // Load rdbs from file
		log.Fatalf("csv error: %+v", err)
	}

	for _, customer := range customers {
		fmt.Printf("Customer: %s\n", customer.Email)
		if err := rdb.JSONSet(ctx, "customer:"+customer.IP, "$", customer).Err(); err != nil {
			return err
		}
	}

	return nil
}

```
## Result
```bash
search for customers owned by lara croft
customer:182.115.99.238:		[{"surname":"Brahms","firstname":"Aili","email":"abrahms5@wikia.com","ip":"182.115.99.238","accountno":0,"owner":"lara.croft","balance":0}]
...
```
## Check Redis Insight
Look for the keys with `customer:` prefix