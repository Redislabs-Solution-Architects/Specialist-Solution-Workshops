/**
 * @fileoverview Creates a StackExchange.Redis client
 * @maker Joey Whelan
 */
using System.Configuration;
using StackExchange.Redis;

namespace SearchWorkshop 
{
    public class Lab1 
    {
        public IDatabase Run() 
        {
            Console.WriteLine("*** Lab 1 - Connect Client ***");
            var redis = ConfigurationManager.AppSettings;
            ConfigurationOptions options = new ConfigurationOptions
            {
                EndPoints = {redis["URL"] + ":" + redis["Port"]},
                Password = redis["Password"]
            };
            ConnectionMultiplexer muxer = ConnectionMultiplexer.Connect(options);
            IDatabase client = muxer.GetDatabase();
            Console.WriteLine($"ping: {client.Ping().TotalMilliseconds} ms");
            return client;
        }
    }
}