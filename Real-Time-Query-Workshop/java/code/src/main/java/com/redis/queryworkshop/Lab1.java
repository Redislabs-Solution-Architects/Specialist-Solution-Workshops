package com.redis.queryworkshop;

import redis.clients.jedis.JedisPooled;
import redis.clients.jedis.Protocol;
import redis.clients.jedis.util.SafeEncoder;
import java.io.InputStream;
import java.util.Properties;

public class Lab1 {
    public JedisPooled run() {
        System.out.println("*** Lab 1 - Connect Client ***");
        JedisPooled client = null;
        try {
            InputStream input = ClassLoader.getSystemResourceAsStream("config.properties");
            Properties prop = new Properties();
            prop.load(input);
            client = new JedisPooled(prop.getProperty("redis.host"),
                Integer.parseInt(prop.getProperty("redis.port")), 
                prop.getProperty("redis.user"), 
                prop.getProperty("redis.password"));
            Object result = client.sendCommand(Protocol.Command.PING, "HELLO");
            System.out.println(SafeEncoder.encode((byte[]) result));
        }
        catch (Exception ex) {
            ex.printStackTrace();
        }
        return client;
    }
}
