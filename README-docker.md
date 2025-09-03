# Why you may not see your Vite app in Docker

When you run: `npm run dev` Vite starts a development web server inside the container.

By default, it binds to:
- **Host** (bind address): `127.0.0.1` (aka `localhost`)
- **Port**: 5173 (default, unless you override it in `vite.config.ts`)

So inside the container, it's listening on `127.0.0.1:5173`.

What this means is that, it "only accept connections that originate from inside the container itself."

So, even if you expose or map ports in Docker, nothing outside the container can connect, because the server isn't listening on the container's external interface `0.0.0.0`.

```yaml
Container
 ├── 127.0.0.1:5173 (only inside the container)
 └── 0.0.0.0:5173 (reachable from outside, if bound)

```

```yaml
Host (your machine)         Container
+-------------------+       +---------------------+
| curl localhost:3000| ---> |  127.0.0.1:5173     |  ❌ only listens inside
|                   |       |                     |
+-------------------+       +---------------------+
```

Hence, we may see this message when running `docker compose up` 
```sh
➜  Local:   http://localhost:5173/
➜  Network: use --host to expose
```

This means that inside the container its listening on 5173, but only on localhost (127.0.0.1), not on 0.0.0.0. We need to **tell Vite to listen on all interfaces (0.0.0.0)** so Docker can expose it.

There is 2 approaches to solve this:

Option 1: update `vite.config.ts`

```sh
import { defineConfig } from 'vite';
import react from '@vitejs/plugin-react';

export default defineConfig({
  plugins: [react()],
  optimizeDeps: {
    exclude: ['lucide-react'],
  },
  server: {
    host: '0.0.0.0',  // 👈 allow external access
    port: 5173        // 👈 explici is better than implicit
  }
});

```


Option 2: pass CLI flag in `Dockerfile.dev`

```sh
# use this:
CMD ["npm", "run", "dev", "--", "--host", "0.0.0.0"]
```
This way the container runs Vite on `0.0.0.0:5173` (accessible from outside)

```yaml
Host (your machine)         Container
+-------------------+       +---------------------+
| curl localhost:3000| ---> |  0.0.0.0:5173       | ✅ open to all interfaces
|                   |       |                     |
+-------------------+       +---------------------+

```


Now you can start developing the app. The following commands may come in handy:
```sh
docker compose build mario-dev
docker compose up mario-dev

# or simply:
docker compose up --build mario-dev

# run in detached mode:
docker compose up -d mario-dev

# you can check the logs with:
docker compose logs -f mario-dev

```
