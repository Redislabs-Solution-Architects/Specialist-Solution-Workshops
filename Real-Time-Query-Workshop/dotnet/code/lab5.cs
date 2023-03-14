/**
 * @fileoverview Advanced Search operations with the node-redis client
 * @maker Joey Whelan
 */
using StackExchange.Redis;
using NRedisStack;
using NRedisStack.RedisStackCommands;
using NRedisStack.Search;
using NRedisStack.Search.Literals.Enums;
using NRedisStack.Search.Aggregation;

namespace SearchWorkshop 
{
    
    public class Lab5 
    {
        public void Run(IDatabase db) 
        {
            Console.WriteLine("\n*** Lab 5 - Advanced Search Queries - Data Load ***");
            IJsonCommands json = db.JSON();
            json.Set("warehouse:1", "$", new {
                city = "Boston",
                location = "-71.057083, 42.361145",
                inventory = new[] {
                    new {
                        id = 15970,
                        gender = "Men",
                        season = new[] {"Fall", "Winter"},
                        description = "Turtle Check Men Navy Blue Shirt",
                        price = 34.95
                    },
                    new {
                        id = 59263,
                        gender = "Women",
                        season = new[] {"Fall", "Winter", "Spring", "Summer"},
                        description = "Titan Women Silver Watch",
                        price = 129.99
                    },
                    new {
                        id = 46885,
                        gender = "Boys",
                        season = new[] {"Fall"},
                        description = "Ben 10 Boys Navy Blue Slippers",
                        price = 45.99
                    }
                }
            });
            json.Set("warehouse:2", "$", new {
                city = "Dallas",
                location = "-96.808891, 32.779167",
                inventory = new[] {
                    new {
                        id = 51919,
                        gender = "Women",
                        season = new[] {"Summer"},
                        description = "Nyk Black Horado Handbag",
                        price = 52.49
                    },
                    new {
                        id = 4602,
                        gender = "Unisex",
                        season = new[] {"Fall", "Winter"},
                        description = "Wildcraft Red Trailblazer Backpack",
                        price = 50.99
                    },
                    new {
                        id = 37561,
                        gender = "Girls",
                        season = new[] {"Spring", "Summer"},
                        description = "Madagascar3 Infant Pink Snapsuit Romper",
                        price = 23.95
                    }
                }
            });

            Console.WriteLine("\n*** Lab 5 - Advanced Search Queries - Index Creation ***");
            ISearchCommands ft = db.FT();
            try {ft.DropIndex("wh_idx");} catch {};
            Console.WriteLine(ft.Create("wh_idx", new FTCreateParams()
                                    .On(IndexDataType.JSON)
                                    .Prefix("warehouse:"),
                                    new Schema().AddTextField(new FieldName("$.city", "city"))));
       
            Console.WriteLine("\n*** Lab 5 - Search w/JSON Filtering - Example 1 ***"); 
            foreach (var doc in ft.Search("wh_idx", 
                                    new Query("@city:Boston")
                                        .ReturnFields(new FieldName("$.inventory[?(@.price>50)].id", "result"))
                                        .Dialect(3))
                                .Documents.Select(x => x["result"]))
            {
                Console.WriteLine(doc);
            }   
            
            Console.WriteLine("\n*** Lab 5 - Search w/JSON Filtering - Example 2 ***");
            foreach (var doc in ft.Search("wh_idx", 
                                    new Query("@city:(Dallas)")
                                        .ReturnFields(new FieldName("$.inventory[?(@.gender==\"Women\" || @.gender==\"Girls\")]", "result"))
                                        .Dialect(3))
                                .Documents.Select(x => x["result"]))
            {
                Console.WriteLine(doc);
            } 

            Console.WriteLine("\n*** Lab 5 - Aggregation - Data Load ***");
            json.Set("book:1", "$", new {
                title = "System Design Interview",
                year = 2020,
                price = 35.99
            });
            json.Set("book:2", "$", new {
                title =  "The Age of AI: And Our Human Future",
                year = 2021,
                price = 13.99
            });
            json.Set("book:3", "$", new {
                title = "The Art of Doing Science and Engineering: Learning to Learn",
                year = 2020,
                price = 20.99
            });
            json.Set("book:4", "$", new {
                title = "Superintelligence: Path, Dangers, Stategies",
                year = 2016,
                price = 14.36
            });

            Console.WriteLine("\n*** Lab 5 - Aggregation - Index Creation ***");
            try {ft.DropIndex("book_idx");} catch {};
            Console.WriteLine(ft.Create("book_idx", new FTCreateParams()
                                    .On(IndexDataType.JSON)
                                    .Prefix("book:"),
                                    new Schema().AddTextField(new FieldName("$.title", "title"))
                                        .AddNumericField(new FieldName("$.year", "year"))
                                        .AddNumericField(new FieldName("$.price", "price"))));
           

            Console.WriteLine("\n*** Lab 5 - Aggregation - Count ***");
            var request = new AggregationRequest("*").GroupBy("@year", Reducers.Count().As("count"));
            var result = ft.Aggregate("book_idx", request);
            for (var i=0; i<result.TotalResults; i++)
            {
                var row = result.GetRow(i);
                Console.WriteLine($"{row["year"]}: {row["count"]}");
            }

            Console.WriteLine("\n*** Lab 5 - Aggregation - Sum ***");
            request = new AggregationRequest("*").GroupBy("@year", Reducers.Sum("@price").As("sum"));
            result = ft.Aggregate("book_idx", request);
            for (var i=0; i<result.TotalResults; i++)
            {
                var row = result.GetRow(i);
                Console.WriteLine($"{row["year"]}: {row["sum"]}");
            }
        }
    }
}