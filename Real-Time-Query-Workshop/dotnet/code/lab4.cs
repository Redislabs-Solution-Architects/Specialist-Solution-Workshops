/**
 * @fileoverview Advanced JSON operations with the node-redis client
 * @maker Joey Whelan
 */
using StackExchange.Redis;
using NRedisStack;
using NRedisStack.RedisStackCommands;
using System.Text.Json;

namespace SearchWorkshop 
{
    public class Lab4 
    {
        public void Run(IDatabase db) 
        {
            Console.WriteLine("\n*** Lab 4 - Data Loading ***");
            IJsonCommands json = db.JSON();
            json.Set("warehouse:1", "$", new {
                city = "Boston",
                location = "42.361145, -71.057083",
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
                        description =  "Ben 10 Boys Navy Blue Slippers",
                        price = 45.99
                    }
                }
            });
    
            Console.WriteLine("\n*** Lab 4 - All Properties of Array ***");
            Console.WriteLine(json.Get(key: "warehouse:1",   
                path: "$.inventory[*]",
                indent: "\t", 
                newLine: "\n"
            ));

            Console.WriteLine("\n*** Lab 4 - All Properties of a Field ***");
            Console.WriteLine(json.Get(key: "warehouse:1", 
                path: "$.inventory[*].price", 
                indent: "\t", 
                newLine: "\n"
            ));

            Console.WriteLine("\n*** Lab 4 - Relational - Equality ***");
            Console.WriteLine(json.Get(key: "warehouse:1", 
                path: "$.inventory[?(@.description==\"Turtle Check Men Navy Blue Shirt\")]", 
                indent: "\t", 
                newLine: "\n"
            ));

            Console.WriteLine("\n*** Lab 4 - Relational - Less Than ***");
            Console.WriteLine(json.Get(key: "warehouse:1", 
                path: "$.inventory[?(@.price<100)]", 
                indent: "\t", 
                newLine: "\n"
            ));        

            Console.WriteLine("\n*** Lab 4 - Relational - Greater Than or Equal ***");
            Console.WriteLine(json.Get(key: "warehouse:1", 
                path: "$.inventory[?(@.id>=20000)]", 
                indent: "\t", 
                newLine: "\n"
            ));   

            Console.WriteLine("\n*** Lab 4 - Logical AND ***");
            Console.WriteLine(json.Get(key: "warehouse:1", 
                path: "$.inventory[?(@.gender==\"Men\"&&@.price>20)]", 
                indent: "\t", 
                newLine: "\n"
            ));  

            Console.WriteLine("\n*** Lab 4 - Logical OR ***");
            Console.WriteLine(json.Get(key: "warehouse:1", 
                path: "$.inventory[?(@.price<100||@.gender==\"Women\")].id", 
                indent: "\t", 
                newLine: "\n"
            ));  

            Console.WriteLine("\n*** Lab 4 - Regex - Contains Exact ***");
            Console.WriteLine(json.Get(key: "warehouse:1", 
                path: "$.inventory[?(@.description =~ \"Blue\")]", 
                indent: "\t", 
                newLine: "\n"
            )); 

            Console.WriteLine("\n*** Lab 4 - Regex - Contains, Case Insensitive ***");
            Console.WriteLine(json.Get(key: "warehouse:1", 
                path: "$.inventory[?(@.description =~ \"(?i)watch\")]", 
                indent: "\t", 
                newLine: "\n"
            )); 

            Console.WriteLine("\n*** Lab 4 - Regex - Begins With ***");
            Console.WriteLine(json.Get(key: "warehouse:1", 
                path: "$.inventory[?(@.description =~ \"^T\")]", 
                indent: "\t", 
                newLine: "\n"
            )); 
        }
    }
}