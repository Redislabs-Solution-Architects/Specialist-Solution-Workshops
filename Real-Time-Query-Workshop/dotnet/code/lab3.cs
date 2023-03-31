/**
 * @fileoverview Basic Search operations with the redis client
 * @maker Joey Whelan
 */
using StackExchange.Redis;
using NRedisStack;
using NRedisStack.RedisStackCommands;
using NRedisStack.Search;
using NRedisStack.Search.Literals.Enums;

namespace SearchWorkshop 
{
    public class Lab3 
    { 
        public void Run(IDatabase db)
        {
            Console.WriteLine("\n*** Lab 3 - Index Creation ***");
            ISearchCommands ft = db.FT();
            try {ft.DropIndex("idx1");} catch {};
            ft.Create("idx1",   new FTCreateParams().On(IndexDataType.JSON)
                                                    .Prefix("product:"),
                                new Schema().AddNumericField(new FieldName("$.id", "id"))
                                            .AddTagField(new FieldName("$.gender", "gender"))
                                            .AddTagField(new FieldName("$.season.*", "season"))
                                            .AddTextField(new FieldName("$.description", "description"))
                                            .AddNumericField(new FieldName("$.price", "price"))
                                            .AddTextField(new FieldName("$.city", "city"))
                                            .AddGeoField(new FieldName("$.coords", "coords")));

            Console.WriteLine("\n*** Lab 3 - Data Loading ***");
            IJsonCommands json = db.JSON();
            json.Set("product:15970", "$", new {
                id = 15970, 
                gender = "Men", 
                season = new[] {"Fall", "Winter"}, 
                description = "Turtle Check Men Navy Blue Shirt", 
                price = 34.95, 
                city = "Boston", 
                coords = "-71.057083, 42.361145"
            });
            json.Set("product:59263", "$", new {
                id = 59263, 
                gender = "Women", 
                season = new[] {"Fall", "Winter", "Spring", "Summer"},
                description = "Titan Women Silver Watch", 
                price = 129.99, 
                city = "Dallas", 
                coords = "-96.808891, 32.779167"
            });
            json.Set("product:46885", "$", new {
                id = 46885, 
                gender = "Boys", 
                season = new[] {"Fall"}, 
                description = "Ben 10 Boys Navy Blue Slippers", 
                price = 45.99, 
                city = "Denver", 
                coords = "-104.991531, 39.742043"
            });

            Console.WriteLine("\n*** Lab 3 - Retrieve All ***");
            foreach (var doc in ft.Search("idx1", new Query("*")).Documents.Select(x => x["json"]))
            {
                Console.WriteLine(doc);
            }
      
            Console.WriteLine("\n*** Lab 3 - Single Term Text ***");
            foreach (var doc in ft.Search("idx1", new Query("@description:Slippers"))
                                .Documents.Select(x => x["json"]))
            {
                Console.WriteLine(doc);
            }

            Console.WriteLine("\n*** Lab 3 - Exact Phrase Text ***");
            foreach (var doc in ft.Search("idx1", new Query("@description:(\"Blue Shirt\")"))
                                .Documents.Select(x => x["json"]))
            {
                Console.WriteLine(doc);
            }

            Console.WriteLine("\n*** Lab 3 - Numeric Range ***");
            foreach (var doc in ft.Search("idx1", new Query("@price:[40,130]"))
                                .Documents.Select(x => x["json"]))
            {
                Console.WriteLine(doc);
            }        

            Console.WriteLine("\n*** Lab 3 - Tag Array ***");
            foreach (var doc in ft.Search("idx1", new Query("@season:{Spring}"))
                                .Documents.Select(x => x["json"]))
            {
                Console.WriteLine(doc);
            }          

            Console.WriteLine("\n*** Lab 3 - Logical AND ***");
            foreach (var doc in ft.Search("idx1", new Query("@price:[40, 100] @description:Blue"))
                                .Documents.Select(x => x["json"]))
            {
                Console.WriteLine(doc);
            }          

            Console.WriteLine("\n*** Lab 3 - Logical OR ***");
            foreach (var doc in ft.Search("idx1", new Query("(@gender:{Women})|(@city:Boston)"))
                                .Documents.Select(x => x["json"]))
            {
                Console.WriteLine(doc);
            }         

            Console.WriteLine("\n*** Lab 3 - Negation ***");
            foreach (var doc in ft.Search("idx1", new Query("-(@description:Shirt)"))
                                .Documents.Select(x => x["json"]))
            {
                Console.WriteLine(doc);
            } 

            Console.WriteLine("\n*** Lab 3 - Prefix ***");
            foreach (var doc in ft.Search("idx1", new Query("@description:Nav*"))
                                .Documents.Select(x => x["json"]))
            {
                Console.WriteLine(doc);
            }

            Console.WriteLine("\n*** Lab 3 - Suffix ***");
            foreach (var doc in ft.Search("idx1", new Query("@description:*Watch"))
                                .Documents.Select(x => x["json"]))
            {
                Console.WriteLine(doc);
            }

            Console.WriteLine("\n*** Lab 3 - Fuzzy ***");
            foreach (var doc in ft.Search("idx1", new Query("@description:%wavy%"))
                                .Documents.Select(x => x["json"]))
            {
                Console.WriteLine(doc);
            }

            Console.WriteLine("\n*** Lab 3 - Geo ***");
            foreach (var doc in ft.Search("idx1", new Query("@coords:[-104.800644 38.846127 100 mi]"))
                                .Documents.Select(x => x["json"]))
            {
                Console.WriteLine(doc);
            }
        }
    }
}