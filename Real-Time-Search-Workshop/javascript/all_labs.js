/**
 * @fileoverview Executes all labs
 * @maker Joey Whelan
 */

import { Lab1 } from "./lab1/lab1.js";
import { Lab2 } from "./lab2/lab2.js";
import { Lab3 } from "./lab3/lab3.js";
import { Lab4 } from "./lab4/lab4.js";
import { Lab5 } from "./lab5/lab5.js";

(async () => {
    const lab1 = new Lab1();
    const client = await lab1.run();

    const lab2 = new Lab2();
    await lab2.run(client);

    const lab3 = new Lab3();
    await lab3.run(client);

    const lab4 = new Lab4();
    await lab4.run(client);

    const lab5 = new Lab5();
    await lab5.run(client);
    
    await client.disconnect();
})();
