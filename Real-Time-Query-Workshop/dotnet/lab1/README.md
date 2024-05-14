**Real Time Query Workshop**

# Lab 1 - Create your Redis Environment

See [00-Setup](../../00-Setup/README.md)

## .NET Setup
### Packages
```bash
dotnet add package StackExchange.Redis
dotnet add package NRedisStack
```
### Connect Client
```c#
ConfigurationOptions options = new ConfigurationOptions
{
  EndPoints = {<your URL> + ":" + <your PORT>},
  Password = <your password>
};
ConnectionMultiplexer muxer = ConnectionMultiplexer.Connect(options);
IDatabase client = muxer.GetDatabase();
Console.WriteLine($"ping: {client.Ping().TotalMilliseconds} ms");
```
### Result
```bash
ping: 0.5424 ms
```