/*
  @fileoverview AA Search operations with the redis client
  @maker Joey Whelan
*/

using StackExchange.Redis;
using NRedisStack;
using NRedisStack.RedisStackCommands;
using NRedisStack.Search;
using NRedisStack.Search.Literals.Enums;

namespace SearchWorkshop 
{
    public class Lab6 
    {
        public void Run(IDatabase db)
        {
            Console.WriteLine("\n*** Lab 6 - Index Creation ***");
            ISearchCommands ft = db.FT();
            try {ft.DropIndex("idx1");} catch {};
            Console.WriteLine(ft.Create("idx1", new FTCreateParams()
                                .On(IndexDataType.JSON)
                                .Prefix("product:"),
                                new Schema()
                                    .AddNumericField(new FieldName("$.id", "id"))
                                    .AddTagField(new FieldName("$.gender", "gender"))
                                    .AddTagField(new FieldName("$.season.*", "season"))
                                    .AddTextField(new FieldName("$.description", "description"))
                                    .AddNumericField(new FieldName("$.price", "price"))
                                    .AddTextField(new FieldName("$.city", "city"))
                                    .AddGeoField(new FieldName("$.coords", "coords"))));

            Console.WriteLine("\n*** Lab 6 - Add a product ***");
            IJsonCommands json = db.JSON();
            json.Set("product:15970", "$", new {
                id = 15970, 
                gender = "Men", 
                season = new[] {"Fall", "Winter"}, 
                description = "Turtle Check Men Navy Blue Shirt", 
                price = 34.95, 
                city = "Boston", 
                coords = "-71.057083, 42.361145"});
           
       
            Console.WriteLine("\n*** Lab 6 - Search 1 ***");
            foreach (var doc in ft.Search("idx1", new Query("@description:shirt"))
                                .Documents.Select(x => x["json"]))
            {
                Console.WriteLine(doc);
            }

            Console.WriteLine("\n*** Lab 6 - Add another product ***");
            json.Set("product:59263", "$", new {
                id = 59263, 
                gender = "Women", 
                season = new[] {"Fall", "Winter", "Spring", "Summer"},
                description = "Titan Women Silver Watch", 
                price = 129.99, 
                city = "Dallas", 
                coords = "-96.808891, 32.779167"});
            
            Console.WriteLine("\n*** Lab 6 - Search 2 ***");
            foreach (var doc in ft.Search("idx1", new Query("@season:{Winter}"))
                                .Documents.Select(x => x["json"]))
            {
                Console.WriteLine(doc);
            }
        }
    }
}