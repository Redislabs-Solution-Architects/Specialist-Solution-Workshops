package com.redis.queryworkshop;
import redis.clients.jedis.JedisPooled;

public class AllLabs {
    public static void main(String[] args) {
        Lab1 lab1 = new Lab1();
        JedisPooled client = lab1.run();

        Lab2 lab2 = new Lab2();
        lab2.run(client);

        Lab3 lab3 = new Lab3();
        lab3.run(client);

        Lab4 lab4 = new Lab4();
        lab4.run(client);

        Lab5 lab5 = new Lab5();
        lab5.run(client);

        Lab6 lab6 = new Lab6();
        lab6.run(client);
    }
    
}
