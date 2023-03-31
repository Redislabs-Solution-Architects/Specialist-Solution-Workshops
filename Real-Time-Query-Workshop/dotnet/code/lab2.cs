/**
 * @fileoverview Basic JSON operations with the redis client
 * @maker Joey Whelan
 */
using StackExchange.Redis;
using NRedisStack;
using NRedisStack.RedisStackCommands;

namespace SearchWorkshop 
{
    public class Lab2 
    {
        public void Run(IDatabase db) 
        {   
            
            Console.WriteLine("\n*** Lab 2 - Insert a simple KVP as a JSON object ***");
            IJsonCommands json = db.JSON();
            Console.WriteLine(json.Set("ex1:1", "$", "\"val\""));

            Console.WriteLine("\n*** Lab 2 - Insert a single-property JSON object ***");
            Console.WriteLine(json.Set("ex1:2", "$", new {field1 = "val1" }));

            Console.WriteLine("\n*** Lab 2 - Insert a JSON object with multiple properties ***");
            Console.WriteLine(json.Set("ex1:3", "$", new {
                field1 = "val1",
                field2 = "val2"
            }));

            Console.WriteLine("\n*** Lab 2 - Insert a JSON object with multiple properties of different data types ***");
            Console.WriteLine(json.Set("ex1:4", "$", new {
                field1 = "val1",
                field2 = "val2",
                field3 = true,
                field4 = (string?) null
            }));

            Console.WriteLine("\n*** Lab 2 - Insert a JSON object that contains an array ***");
            Console.WriteLine(json.Set("ex1:5", "$", new {
                arr1 = new [] {"val1", "val2", "val3"}
            }));

            Console.WriteLine("\n*** Lab 2 - Insert a JSON object that contains a nested object ***");
            Console.WriteLine(json.Set("ex1:6", "$", new {
                obj1 = new {
                    str1 = "val1",
                    num2 = 2
                }
            })); 

            Console.WriteLine("\n*** Lab 2 - Insert a JSON object with a mixture of property data types ***");
            Console.WriteLine(json.Set("ex1:7", "$", new { 
                str1 = "val1", 
                str2 = "val2", 
                arr1 = new [] {1,2,3,4},
                obj1 = new {
                    num1 = 1,
                    arr2 = new [] {"val1","val2", "val3"}
                } 
            })); 

            Console.WriteLine("\n*** Lab 2 - Set and Fetch a simple JSON KVP ***");
            json.Set("ex2:1", "$", "\"val\"");
            Console.WriteLine(json.Get(key: "ex2:1", 
                path: "$", 
                indent: "\t", 
                newLine: "\n"
            ));             

            Console.WriteLine("\n*** Lab 2 - Set and Fetch a single property from a JSON object ***");
            json.Set("ex2:2", "$", new {
                field1 = "val1"
            });
            Console.WriteLine(json.Get(key: "ex2:2", 
                path: "$.field1", 
                indent: "\t", 
                newLine: "\n"
            )); 

            Console.WriteLine("\n*** Lab 2 - Fetch multiple properties ***");
            json.Set("ex2:3", "$", new {
                field1 = "val1", 
                field2 = "val2"
            });
            Console.WriteLine(json.Get(key: "ex2:3", 
                paths: new[] {"$.field1", "$.field2" }, 
                indent: "\t", 
                newLine: "\n"
            ));            

            Console.WriteLine("\n*** Lab 2 - Fetch a property nested in another JSON object ***");
            json.Set("ex2:4", "$", new {
                obj1 = new {
                    str1 = "val1", 
                    num2 = 2
                }
            });
            Console.WriteLine(json.Get(key: "ex2:4", 
                path: "$.obj1.num2", 
                indent: "\t", 
                newLine: "\n"
            )); 

            Console.WriteLine("\n*** Lab 2 - Fetch properties within an array and utilize array subscripting ***");
            json.Set("ex2:5", "$",new {
                str1 = "val1", 
                str2 = "val2", 
                arr1 = new[] {1,2,3,4}, 
                obj1 = new {
                    num1 = 1,
                    arr2 = new[] {"val1","val2", "val3"}
                }
            });
            Console.WriteLine(json.Get(key: "ex2:5", 
                path: "$.obj1.arr2", 
                indent: "\t", 
                newLine: "\n"
            ));
            Console.WriteLine(json.Get(key: "ex2:5", 
                path: "$.arr1[1]", 
                indent: "\t", 
                newLine: "\n"
            ));   
            Console.WriteLine(json.Get(key: "ex2:5", 
                path: "$.obj1.arr2[0:2]", 
                indent: "\t", 
                newLine: "\n"
            ));      
            Console.WriteLine(json.Get(key: "ex2:5", 
                path: "$.arr1[-2:]", 
                indent: "\t", 
                newLine: "\n"
            ));         

            Console.WriteLine("\n*** Lab 2 - Update an entire JSON object ***");
            json.Set("ex3:1", "$", new {field1 = "val1"});
            json.Set("ex3:1", "$", new {foo = "bar"});
            Console.WriteLine(json.Get(key: "ex3:1", 
                indent: "\t", 
                newLine: "\n"
            )); 

            Console.WriteLine("\n*** Lab 2 - Update a single property within an object ***");
            json.Set("ex3:2", "$", new {
                field1 = "val1", 
                field2 = "val2"
            });
            json.Set("ex3:2", "$.field1", "\"foo\"");
            Console.WriteLine(json.Get(key: "ex3:2", 
                indent: "\t", 
                newLine: "\n"
            )); 

            Console.WriteLine("\n*** Lab 2 - Update a property in an embedded JSON object ***");
            json.Set("ex3:3", "$", new {
                obj1 = new {
                    str1 = "val1", 
                    num2 = 2
                }
            });
            json.Set("ex3:3", "$.obj1.num2", 3);
            Console.WriteLine(json.Get(key: "ex3:3", 
                indent: "\t", 
                newLine: "\n"
            ));             
       
            Console.WriteLine("\n*** Lab 2 - Update an item in an array via index ***");
            json.Set("ex3:4", "$", new {
                arr1 = new[] {"val1", "val2", "val3"}
            });
            json.Set("ex3:4", "$.arr1[0]", "\"foo\"");
            Console.WriteLine(json.Get(key: "ex3:4", 
                indent: "\t", 
                newLine: "\n"
            ));  

            Console.WriteLine("\n*** Lab 2 - Delete entire object/key ***");
            json.Set("ex4:1", "$", new {field1 = "val1"});
            json.Del("ex4:1");
            Console.WriteLine(json.Get(key: "ex4:1", 
                indent: "\t", 
                newLine: "\n"
            ));

            Console.WriteLine("\n*** Lab 2 - Delete a single property from an object ***");
            json.Set("ex4:2", "$", new {
                field1 = "val1", 
                field2 =  "val2"
            });
            json.Del("ex4:2", "$.field1");
            Console.WriteLine(json.Get(key: "ex4:2", 
                indent: "\t", 
                newLine: "\n"
            ));

            Console.WriteLine("\n*** Lab 2 - Delete a property from an embedded object ***");
            json.Set("ex4:3", "$", new {
                obj1 = new {
                    str1 = "val1", 
                    num2 = 2
                }
            });
            json.Del("ex4:3", "$.obj1.num2");
            Console.WriteLine(json.Get(key: "ex4:3", 
                indent: "\t", 
                newLine: "\n"
            ));

            Console.WriteLine("\n*** Lab 2 - Delete a single item from an array ***");
            json.Set("ex4:4", "$", new {
                arr1 = new[] {"val1", "val2", "val3"}
            });
            json.Del("ex4:4", "$.arr1[0]");
            Console.WriteLine(json.Get(key: "ex4:4", 
                indent: "\t", 
                newLine: "\n"
            ));
        }
    }
}