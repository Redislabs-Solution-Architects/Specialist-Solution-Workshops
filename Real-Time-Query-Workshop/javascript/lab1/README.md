**Real Time Query Workshop**

# Lab 1 - Create your Redis Environment

See [00-Setup](../../00-Setup/README.md)

## Node-Redis Setup
### NPM
```bash
npm init -y
npm install redis
```
### Edit package.json to enable modules
```javascript
  },
  "type":"module"
}
```
### Modules Needed
```javascript
import { createClient } from 'redis';
```
### Connect Client
```javascript
const user = 'default';
const pwd = 'your password';
const url = 'your cloud url';
const port = 'your port';
const client = createClient({url: `redis://${user}:${pwd}@${url}:${port}`});

await client.connect();
let result = await client.ping();
console.log(result);
```
### Result
```bash
PONG
```
