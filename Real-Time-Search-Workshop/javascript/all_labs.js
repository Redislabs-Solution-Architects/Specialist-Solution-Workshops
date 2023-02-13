/**
 * @fileoverview Executes all labs
 * @maker Joey Whelan
 */

import { lab1 } from "./lab1/lab1.js";
import { lab2 } from "./lab2/lab2.js";
import { lab3 } from "./lab3/lab3.js";
import { lab4 } from "./lab4/lab4.js";
import { lab5 } from "./lab5/lab5.js";

(async () => {
    const client = await lab1();
    await lab2(client);
    await lab3(client);
    await lab4(client);
    await lab5(client);
    await client.disconnect();
})();
