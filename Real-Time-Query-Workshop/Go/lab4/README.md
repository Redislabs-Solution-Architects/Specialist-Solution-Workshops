**Real Time Query Workshop**

# Lab 4 - Aggregation with Redis

## Perform an aggregation of data already stored in Redis
```go
import (
	"fmt"
	"strings"
	"log"

	"github.com/redis/go-redis/v9"
)

var aggregateArgs = []interface{}{"FT.AGGREGATE", "demoindex", "*", "load", "3", "$balance", "as", "balance", "GROUPBY", "1", "@owner", "reduce", "sum", "1", "balance", "as", "balance", "SORTBY", "2", "@balance", "DESC", "dialect", "3"}

func lab4(rdb *redis.Client) {
	fmt.Println("*** Lab 4 - Perform aggregation of data ***")
	fmt.Println("\n\nAggregate balance by owner: FT.AGGREGATE")

	aggregateCmd := redis.NewSliceCmd(ctx, aggregateArgs...)
	rdb.Process(ctx, aggregateCmd)

	if aggregateCmd.Err() != nil {
		log.Fatalf("redis error executing aggregate: %+v", aggregateCmd.Err())
	}

	aggregateResults := aggregateCmd.Val()

	titles := []string{}
	r1 := aggregateResults[1].([]interface{})
	for n := 0; n < len(r1); n += 2 {
		titles = append(titles, r1[n].(string))
	}
	fmt.Println(strings.Join(titles, ", "))

	for n := 1; n < len(aggregateResults); n++ {
		r := aggregateResults[n].([]interface{})
		values := []string{}
		for m := 1; m < len(r); m += 2 {
			values = append(values, r[m].(string))
		}
		fmt.Println(strings.Join(values, ", "))
	}
}

```
## Result
```bash
Aggregate balance by owner: FT.AGGREGATE
owner, balance
lara.croft, 930.24
ellen.ripley, 113
sarah.oconnor, -11636.73
```
## Check Redis Insight
Look for the keys with `customer:` prefix