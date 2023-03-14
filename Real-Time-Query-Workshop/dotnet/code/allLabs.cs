/**
 * @fileoverview Executes all labs
 * @maker Joey Whelan
 */

using SearchWorkshop;
using StackExchange.Redis;

public class AllLabs
{
    static void Main(string[] args)
    {
        Lab1 lab1 = new Lab1();
        IDatabase db = lab1.Run();

        Lab2 lab2 = new Lab2();
        lab2.Run(db);

        Lab3 lab3 = new Lab3();
        lab3.Run(db);

        Lab4 lab4 = new Lab4();
        lab4.Run(db);

        Lab5 lab5 = new Lab5();
        lab5.Run(db);

        Lab6 lab6 = new Lab6();
        lab6.Run(db);
    }
}