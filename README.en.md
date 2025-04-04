# 🚀 n8n, Redis, and Supabase Integration Project with Docker

Welcome to the n8n, Redis, and Supabase integration project, fully deployed using Docker. This system provides a robust solution for workflow automation, efficient queue management, and flexible data storage, including vector database support for AI applications.

[README with Vietnamese](README.vi.md)

## ✨ System Overview

The system consists of three main components working together:

1.  **n8n & ngrok 🔗**:
    * **n8n**: An open-source workflow automation platform that helps connect various applications and services.
    * **ngrok**: A service that creates secure tunnels, allowing public internet access to n8n via a stable URL.
2.  **Redis 💾**:
    * An in-memory data structure store, used as a message broker and cache. In this project, Redis manages queues and stores state for n8n, ensuring performance and reliability.
3.  **Supabase 🗄️**:
    * An open-source Firebase alternative, providing a complete backend toolkit including a PostgreSQL database, authentication, file storage, auto-generated APIs, and vector database support (via the `pgvector` extension).

## 📂 Directory Structure

Here is the project's directory structure:

```
D:\Docker\n8n
├── start-all.bat          # 🚀 Script to start all Docker services
├── stop-all.bat           # 🛑 Script to stop all Docker services
├── n8n-ngrok
│   ├── .env               # ⚙️ Environment variables for n8n configuration
│   ├── docker-compose.yml # 🐳 Docker Compose configuration for n8n and ngrok
│   ├── ngrok.yml          # 🔗 Specific configuration for ngrok (domain, port, etc.)
│   └── data
│       └── export\        # 📤 Directory for exported data from n8n (if any)
├── redis

│   ├── docker-compose.yml # 🐳 Docker Compose configuration for Redis
│   └── data\              # 💾 Directory for persistent Redis data
└── supabase

├── .env               # ⚙️ Environment variables for Supabase configuration
├── docker-compose.yml # 🐳 Docker Compose configuration for Supabase and related services
└── volumes\           # 📦 Directory for persistent Supabase data
├── api

│   └── kong.yml   # 🌐 Configuration for Kong API Gateway
├── db\            # 🛢️ PostgreSQL data
├── imgproxy\      # 🖼️ imgproxy data (cache) (if used)
├── storage\       # 📁 Supabase file storage data
└── vector\        # 💡 Vector-related data (if specifically configured)
```

## 🔧 Component Configuration Details

### 1. n8n and ngrok (`n8n-ngrok/docker-compose.yml`)

* **n8n**:
    * Uses PostgreSQL (from Supabase) as the main database (`DB_TYPE=postgresdb`, `DB_POSTGRESDB_*`).
    * Connects to Redis for queue management (`QUEUE_BULL_REDIS_*`).
    * Runs in `queue` mode (main process) and has a separate `worker` for handling tasks, enhancing scalability and performance.
    * The `~/.n8n` directory inside the container is mounted to `./data` on the host machine for persistent storage of configurations and workflow data.
    * Important environment variables like `N8N_ENCRYPTION_KEY`, `WEBHOOK_URL` are defined in the `.env` file.
* **ngrok**:
    * Connects to the n8n service via the container name `n8n` and port `5678`.
    * Uses configuration from the `ngrok.yml` file to set up a fixed domain (`select-regularly-emu.ngrok-free.app`) and other parameters.
    * Requires `NGROK_AUTHTOKEN` to be provided via an environment variable (in the `.env` file).

### 2. Redis (`redis/docker-compose.yml`)

* Uses the lightweight and efficient `redis:alpine` image.
* Mounts the `./data` directory on the host to `/data` inside the container for persistent Redis data storage.
* Enables `AOF` (Append Only File) mode with `appendonly yes` to enhance data durability and minimize data loss in case of issues.

### 3. Supabase (`supabase/docker-compose.yml`)

This is a more complex stack, comprising multiple services managed by Docker Compose:

* **Database (PostgreSQL)**:
    * Uses the `supabase/postgres:15.1.0.117` image, which includes the `pgvector` extension pre-installed.
    * Data is stored persistently in `volumes/db`.
    * The password is set via the `POSTGRES_PASSWORD` environment variable (referenced from the `.env` file).
* **Kong API Gateway**:
    * Manages the routing of API requests to the appropriate backend services (Auth, REST, Storage, Realtime).
    * Uses configuration from `volumes/api/kong.yml`.
    * Handles authentication and applies security policies.
* **Auth Service (`gotrue`)**: Manages user authentication, JWTs, and OAuth providers.
* **Storage Service**: Provides APIs for managing file uploads, downloads, and storage.
* **Realtime Service**: Allows client applications to subscribe to real-time data changes in PostgreSQL via WebSockets.
* **REST API (`postgrest`)**: Automatically generates a RESTful API based on the PostgreSQL database schema.
* **Studio**: A web-based user interface (running on port 3000) for managing the database, users, storage, and other Supabase configurations.
* **Vector Support**: Provided by the `pgvector` extension pre-installed in the PostgreSQL image, enabling storage and querying of vector embeddings.

### 🔑 Keys and Secrets

All important keys and secrets are generated with the prefix `TaraJSC-` and managed through `.env` files:

* Database Password: `TaraJSC-postgres`
* JWT Secret: `TaraJSC-jwt-secret`
* Anon Key: `TaraJSC-anon-key` (Used for public/anonymous API access)
* Service Role Key: `TaraJSC-service-role-key` (Used for administrative API access)
* Supabase Studio Password: `TaraJSC-dashboard` (Login password for the Studio)
* n8n Encryption Key: `TaraJSC-encryption-key` (Key for encrypting sensitive data in n8n)

## 🔄 n8n and Supabase Integration

n8n is configured to interact with Supabase in two main ways:

1.  **Direct Database Connection**:
    * n8n uses Supabase's PostgreSQL as its storage for workflow data and credentials.
    * Connection configuration in `n8n-ngrok/.env`:
        * `DB_POSTGRESDB_HOST=supabase-db` (Service name of PostgreSQL in the Docker network)
        * `DB_POSTGRESDB_PORT=5432`
        * `DB_POSTGRESDB_DATABASE=postgres`
        * `DB_POSTGRESDB_USER=postgres`
        * `DB_POSTGRESDB_PASSWORD=${POSTGRES_PASSWORD}` (References the variable in `.env`)
2.  **Interaction via Supabase API**:
    * Within n8n workflows, you can use the `HTTP Request` node to call Supabase API endpoints (via the Kong Gateway).
    * Base API URL: `http://supabase-kong:8000` (Service name of Kong in the Docker network)
    * Use the `Anon Key` (`TaraJSC-anon-key`) or `Service Role Key` (`TaraJSC-service-role-key`) in the `apikey` header for request authentication.

## 🛠️ Usage Guide

### Prerequisites

* **Docker Desktop**: Must be installed and running on your Windows machine.
* **ngrok Account and Authtoken**: You need an ngrok account and its Authtoken configured in `n8n-ngrok/.env`.
* **`.env` File Configuration**: Ensure the `.env` files in `n8n-ngrok` and `supabase` are populated with the necessary values (especially `NGROK_AUTHTOKEN` and the `TaraJSC-*` keys).

### Steps

1.  **Start All Services**:
    * Navigate to the root directory `D:\Docker\n8n\` in Command Prompt or PowerShell.
    * Run the `start-all.bat` script by double-clicking it or typing `.\start-all.bat` in the terminal.
    * The script will sequentially start containers for Redis, Supabase (and its dependencies), followed by n8n and ngrok.
    * The initial startup for Supabase might take a few minutes the first time.
    * Monitor the terminal output for status updates and access URLs upon completion.
2.  **Stop All Services**:
    * Run the `stop-all.bat` script by double-clicking or typing `.\stop-all.bat` in the terminal.
    * The script will stop the containers in reverse order to ensure a safe shutdown.
3.  **Access Services**:
    * **n8n UI**: [http://localhost:5678](http://localhost:5678)
    * **n8n via ngrok**: [https://select-regularly-emu.ngrok-free.app](https://select-regularly-emu.ngrok-free.app) (This URL might differ based on your ngrok configuration)
    * **Supabase Studio**: [http://localhost:3000](http://localhost:3000) (Login with email `admin` or `postgres` and password `TaraJSC-dashboard`)
    * **Supabase API Gateway**: [http://localhost:8000](http://localhost:8000) (Endpoint for external applications to interact with the API)

## 💡 Using Supabase as a Vector Database with n8n

Supabase with `pgvector` allows you to build AI applications like semantic search, recommendation systems, RAG (Retrieval-Augmented Generation), etc.

1.  **Access Supabase Studio**: Open [http://localhost:3000](http://localhost:3000) and log in.
2.  **Enable Extension (if not already)**: Go to "Database" -> "Extensions", find "vector", and enable it. (It's usually enabled by default in this setup).
3.  **Create Vector Storage Table**: Open the SQL Editor ("SQL Editor" -> "New query") and run the following SQL command to create an example `documents` table:

    ```sql
    -- Ensure the extension is enabled
    CREATE EXTENSION IF NOT EXISTS vector;

    -- Create a table to store content, metadata, and vector embeddings
    CREATE TABLE documents (
      id SERIAL PRIMARY KEY,
      content TEXT,          -- Original content (e.g., text passage)
      metadata JSONB,        -- Additional data (e.g., source, creation date)
      embedding VECTOR(384)  -- Column to store vectors. Adjust the dimension (384)
                             -- based on the embedding model you use.
    );

    -- (Optional but recommended) Create an index to speed up vector searches
    -- Choose an appropriate index type (ivfflat, hnsw) and distance function (vector_cosine_ops, vector_l2_ops, ...)
    -- Example using IVFFlat with cosine similarity:
    CREATE INDEX ON documents USING ivfflat (embedding vector_cosine_ops) WITH (lists = 100);
    -- Note: The `lists` parameter should be tuned based on the expected number of records.
    ```

4.  **Interact from n8n**:
    * **Method 1: Use PostgreSQL Node**:
        * Create a PostgreSQL credential in n8n connecting to the Supabase DB (using info from `n8n-ngrok/.env`).
        * Use the "Postgres" node to execute `INSERT` (to save vectors) or `SELECT` (to search vectors) commands.
    * **Method 2: Use HTTP Request Node**:
        * Use the "HTTP Request" node to call the Supabase REST API (via `http://supabase-kong:8000`). You would need to create RPC functions in PostgreSQL to handle vector insertion and search, then call these RPC functions via the API. This method is more complex but can offer more flexibility in some cases.

5.  **Example SQL (Execute via Postgres Node)**:
    * **Save Vector Embedding**:
        ```sql
        INSERT INTO documents (content, metadata, embedding)
        VALUES (
          'This is the content of the document to store.',
          '{"source": "example.txt", "category": "documentation"}',
          '[0.1, 0.2, 0.3, ..., 0.384]'::vector -- Replace with the actual embedding vector
        );
        ```
    * **Similarity Search**: Find the 5 documents closest to a query vector based on cosine similarity.
        ```sql
        SELECT
          id,
          content,
          metadata,
          1 - (embedding <=> '[0.9, 0.8, 0.7, ..., 0.123]'::vector) AS similarity -- Calculate cosine similarity
        FROM documents
        ORDER BY embedding <=> '[0.9, 0.8, 0.7, ..., 0.123]'::vector -- Order by cosine distance (smallest is closest)
        LIMIT 5;
        ```
        *(Note: `<=>` is the cosine distance operator in pgvector. `1 - distance` gives the similarity)*

## ⚠️ Important Notes

1.  **Docker Network**: All services (n8n, ngrok, redis, supabase-*) are connected to a custom Docker network named `n8n-network` (or a similar name defined in the `docker-compose.yml` files). This allows them to communicate using service names (e.g., `n8n` can reach `supabase-db`, `supabase-kong`).
2.  **Persistent Data**: The `data` (for n8n, redis) and `volumes` (for supabase) directories are mounted from the host machine into the containers. This ensures that all critical data (workflows, configurations, database, storage files) persists even if containers are stopped, removed, or restarted.
3.  **Windows Environment**: The `start-all.bat` and `stop-all.bat` scripts are designed for a Windows environment. If using Linux or macOS, you'll need to adapt the commands and paths accordingly (e.g., use shell scripts `.sh`).
4.  **ngrok Updates**: Free ngrok domains might change or expire. If the ngrok URL stops working, you need to:
    * Check your ngrok account.
    * Update `NGROK_AUTHTOKEN` in `n8n-ngrok/.env` if necessary.
    * Update the domain configuration in `n8n-ngrok/ngrok.yml` if you use a static domain and it has changed.
    * Restart the `n8n-ngrok` service.
5.  **Resources**: Running multiple Docker services, especially the Supabase stack, can consume significant system resources (RAM, CPU). Ensure your machine is powerful enough and Docker Desktop has sufficient resources allocated.

## 📚 References

* **n8n Docker Documentation**: [https://docs.n8n.io/hosting/installation/docker/](https://docs.n8n.io/hosting/installation/docker/)
* **ngrok Docker**: [https://github.com/ngrok/docker-ngrok](https://github.com/ngrok/docker-ngrok)
* **Supabase Self-Hosting (Docker)**: [https://supabase.com/docs/guides/self-hosting/docker](https://supabase.com/docs/guides/self-hosting/docker)
* **Supabase GitHub Discussions (Self-Hosting)**: [https://github.com/orgs/supabase/discussions/27467](https://github.com/orgs/supabase/discussions/27467)
* **pgvector Extension**: [https://github.com/pgvector/pgvector](https://github.com/pgvector/pgvector)

## 👤 Author & Contact

* **Name**: Luong Vu Dinh Duy
* **Email**: [luongvudinhduy03@gmail.com](mailto:luongvudinhduy03@gmail.com)

---

Happy automating! 🎉
