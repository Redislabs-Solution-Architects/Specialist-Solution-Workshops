/**
 * @fileoverview Creates a node-redis client
 * @maker Joey Whelan
 */

import { createClient } from 'redis';
import * as dotenv from 'dotenv';
dotenv.config();

export class Lab1 {

    async run() {
        console.log('*** Lab 1 - Connect Client ***');
        const user = process.env.USER_NAME;
        const pwd = process.env.PASSWORD;
        const url = process.env.URL;
        const port = process.env.PORT;
    
        const client = createClient({url: `redis://${user}:${pwd}@${url}:${port}`});
        await client.connect();
        let result = await client.ping();
        console.log(result);
        return client;
    }
}