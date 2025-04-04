# 🚀 Dự án Tích hợp n8n, Redis và Supabase với Docker

Chào mừng bạn đến với dự án tích hợp n8n, Redis và Supabase, được triển khai hoàn toàn bằng Docker. Hệ thống này cung cấp một giải pháp mạnh mẽ cho việc tự động hóa quy trình làm việc, quản lý hàng đợi hiệu quả và lưu trữ dữ liệu linh hoạt, bao gồm cả hỗ trợ vector database cho các ứng dụng AI.

[README with Enlish](README.en.md)

## ✨ Tổng quan Hệ thống

Hệ thống bao gồm ba thành phần chính hoạt động phối hợp với nhau:

1.  **n8n & ngrok 🔗**:
    * **n8n**: Nền tảng tự động hóa quy trình làm việc mã nguồn mở, giúp kết nối các ứng dụng và dịch vụ khác nhau.
    * **ngrok**: Dịch vụ tạo đường hầm an toàn, cho phép truy cập n8n từ internet công cộng thông qua một URL ổn định.
2.  **Redis 💾**:
    * Một kho lưu trữ cấu trúc dữ liệu trong bộ nhớ, được sử dụng làm message broker và bộ đệm (cache). Trong dự án này, Redis đóng vai trò quản lý hàng đợi và lưu trữ trạng thái cho n8n, đảm bảo hiệu suất và độ tin cậy.
3.  **Supabase 🗄️**:
    * Một giải pháp thay thế Firebase mã nguồn mở, cung cấp một bộ công cụ backend hoàn chỉnh bao gồm cơ sở dữ liệu PostgreSQL, xác thực, lưu trữ file, API tự động và hỗ trợ vector database (thông qua tiện ích mở rộng `pgvector`).

## 📂 Cấu trúc Thư mục

Dưới đây là cấu trúc thư mục của dự án:

```
D:\Docker\n8n
├── start-all.bat          # 🚀 Script để khởi động tất cả các dịch vụ Docker
├── stop-all.bat           # 🛑 Script để dừng tất cả các dịch vụ Docker
├── n8n-ngrok
│   ├── .env               # ⚙️ Biến môi trường cấu hình cho n8n
│   ├── docker-compose.yml # 🐳 Cấu hình Docker Compose cho n8n và ngrok
│   ├── ngrok.yml          # 🔗 Cấu hình cụ thể cho ngrok (domain, cổng,...)
│   └── data
│       └── export\        # 📤 Thư mục chứa dữ liệu xuất từ n8n (nếu có)
├── redis
│   ├── docker-compose.yml # 🐳 Cấu hình Docker Compose cho Redis
│   └── data\              # 💾 Thư mục lưu trữ dữ liệu bền vững của Redis
├── supabase
├── .env               # ⚙️ Biến môi trường cấu hình cho Supabase
├── docker-compose.yml # 🐳 Cấu hình Docker Compose cho Supabase và các dịch vụ liên quan
├── volumes\           # 📦 Thư mục chứa dữ liệu bền vững của Supabase
├── api
│   └── kong.yml   # 🌐 Cấu hình cho Kong API Gateway
├── db\            # 🛢️ Dữ liệu của PostgreSQL
├── imgproxy\      # 🖼️ Dữ liệu (cache) của imgproxy (nếu dùng)
├── storage\       # 📁 Dữ liệu lưu trữ file của Supabase
└── vector\        # 💡 Dữ liệu liên quan đến vector (nếu có cấu hình riêng)
```
## 🔧 Chi tiết Cấu hình Từng Thành phần

### 1. n8n và ngrok (`n8n-ngrok/docker-compose.yml`)

* **n8n**:
    * Sử dụng PostgreSQL (từ Supabase) làm cơ sở dữ liệu chính (`DB_TYPE=postgresdb`, `DB_POSTGRESDB_*`).
    * Kết nối với Redis để quản lý hàng đợi (`QUEUE_BULL_REDIS_*`).
    * Chạy ở chế độ `queue` (main process) và có một `worker` riêng để xử lý các tác vụ, tăng khả năng mở rộng và hiệu suất.
    * Thư mục `~/.n8n` trong container được mount ra `./data` trên máy host để lưu trữ cấu hình và dữ liệu workflow bền vững.
    * Biến môi trường quan trọng như `N8N_ENCRYPTION_KEY`, `WEBHOOK_URL` được định nghĩa trong file `.env`.
* **ngrok**:
    * Kết nối tới dịch vụ n8n thông qua tên container `n8n` và cổng `5678`.
    * Sử dụng cấu hình từ file `ngrok.yml` để thiết lập domain cố định (`select-regularly-emu.ngrok-free.app`) và các thông số khác.
    * Yêu cầu `NGROK_AUTHTOKEN` được cung cấp qua biến môi trường (trong file `.env`).

### 2. Redis (`redis/docker-compose.yml`)

* Sử dụng image `redis:alpine` nhẹ và hiệu quả.
* Mount thư mục `./data` trên máy host vào `/data` trong container để lưu trữ dữ liệu Redis.
* Bật chế độ `AOF` (Append Only File) với `appendonly yes` để tăng cường độ bền dữ liệu, giảm thiểu mất mát khi có sự cố.

### 3. Supabase (`supabase/docker-compose.yml`)

Đây là một stack phức tạp hơn, bao gồm nhiều dịch vụ được quản lý bởi Docker Compose:

* **Database (PostgreSQL)**:
    * Sử dụng image `supabase/postgres:15.1.0.117` đã tích hợp sẵn tiện ích mở rộng `pgvector`.
    * Dữ liệu được lưu trữ bền vững trong `volumes/db`.
    * Mật khẩu được đặt qua biến môi trường `POSTGRES_PASSWORD` (tham chiếu từ file `.env`).
* **Kong API Gateway**:
    * Quản lý việc định tuyến (routing) các yêu cầu API đến các dịch vụ backend phù hợp (Auth, REST, Storage, Realtime).
    * Sử dụng cấu hình trong `volumes/api/kong.yml`.
    * Xử lý việc xác thực và áp dụng các chính sách bảo mật.
* **Auth Service (`gotrue`)**: Quản lý xác thực người dùng, JWT, và các nhà cung cấp OAuth.
* **Storage Service**: Cung cấp API để quản lý việc tải lên, tải xuống và lưu trữ file.
* **Realtime Service**: Cho phép các ứng dụng client đăng ký nhận các thay đổi dữ liệu trong PostgreSQL theo thời gian thực qua WebSockets.
* **REST API (`postgrest`)**: Tự động tạo ra một RESTful API dựa trên schema của cơ sở dữ liệu PostgreSQL.
* **Studio**: Giao diện người dùng web (chạy trên cổng 3000) để quản lý cơ sở dữ liệu, người dùng, lưu trữ và các cấu hình khác của Supabase.
* **Vector Support**: Được cung cấp bởi tiện ích mở rộng `pgvector` đã cài đặt sẵn trong image PostgreSQL, cho phép lưu trữ và truy vấn vector embeddings.

### 🔑 Khóa và Bí mật (Secrets)

Tất cả các khóa và bí mật quan trọng được tạo với tiền tố `DuyLVD-` và quản lý thông qua các file `.env`:

* Database Password: `<DuyLVD-postgres>`
* JWT Secret: `DuyLVD-jwt-secret`
* Anon Key: `DuyLVD-anon-key` (Sử dụng cho truy cập công khai/ẩn danh vào API)
* Service Role Key: `DuyLVD-service-role-key` (Sử dụng cho truy cập với quyền quản trị vào API)
* Supabase Studio Password: `DuyLVD-dashboard` (Mật khẩu đăng nhập vào Studio)
* n8n Encryption Key: `DuyLVD-encryption-key` (Khóa mã hóa dữ liệu nhạy cảm trong n8n)

## 🔄 Tích hợp n8n và Supabase

n8n được cấu hình để tương tác với Supabase theo hai cách chính:

1.  **Kết nối Cơ sở dữ liệu Trực tiếp**:
    * n8n sử dụng PostgreSQL của Supabase làm nơi lưu trữ dữ liệu workflow và credentials.
    * Cấu hình kết nối trong `n8n-ngrok/.env`:
        * `DB_POSTGRESDB_HOST=supabase-db` (Tên service của PostgreSQL trong mạng Docker)
        * `DB_POSTGRESDB_PORT=5432`
        * `DB_POSTGRESDB_DATABASE=postgres`
        * `DB_POSTGRESDB_USER=postgres`
        * `DB_POSTGRESDB_PASSWORD=${POSTGRES_PASSWORD}` (Tham chiếu đến biến trong `.env`)
2.  **Tương tác qua Supabase API**:
    * Trong các workflow n8n, bạn có thể sử dụng node `HTTP Request` để gọi các endpoint API của Supabase (thông qua Kong Gateway).
    * URL cơ sở của API: `http://supabase-kong:8000` (Tên service của Kong trong mạng Docker)
    * Sử dụng `Anon Key` (`DuyLVD-anon-key`) hoặc `Service Role Key` (`DuyLVD-service-role-key`) trong header `apikey` để xác thực yêu cầu.

## 🛠️ Hướng dẫn Sử dụng

### Điều kiện tiên quyết

* **Docker Desktop**: Đã cài đặt và đang chạy trên máy Windows của bạn.
* **ngrok Account và Authtoken**: Cần có tài khoản ngrok và lấy Authtoken để cấu hình trong `n8n-ngrok/.env`.
* **Cấu hình file `.env`**: Đảm bảo các file `.env` trong `n8n-ngrok` và `supabase` đã được điền đầy đủ các giá trị cần thiết (đặc biệt là `NGROK_AUTHTOKEN` và các khóa `DuyLVD-*`).

### Các bước thực hiện

1.  **Khởi động Tất cả Dịch vụ**:
    * Điều hướng đến thư mục gốc `D:\Docker\n8n\` trong Command Prompt hoặc PowerShell.
    * Chạy script `start-all.bat` bằng cách nhấp đúp vào nó hoặc gõ `.\start-all.bat` trong terminal.
    * Script sẽ lần lượt khởi động các container cho Redis, Supabase (và các dịch vụ phụ thuộc), sau đó là n8n và ngrok.
    * Quá trình khởi động Supabase có thể mất vài phút trong lần chạy đầu tiên.
    * Theo dõi output trong terminal để xem trạng thái và các URL truy cập khi hoàn tất.
2.  **Dừng Tất cả Dịch vụ**:
    * Chạy script `stop-all.bat` bằng cách nhấp đúp hoặc gõ `.\stop-all.bat` trong terminal.
    * Script sẽ dừng các container theo thứ tự ngược lại để đảm bảo tắt hệ thống một cách an toàn.
3.  **Truy cập Các Dịch vụ**:
    * **n8n UI**: [http://localhost:5678](http://localhost:5678)
    * **n8n qua ngrok**: [https://{YOUR NGROK DOMAIN}](https://dashboard.ngrok.com/get-started/setup/docker) (Truy cập vào trang chủ ngrok để có thể đăng ký một tên miền của riêng mình)
    * **Supabase Studio**: [http://localhost:3000](http://localhost:3000) (Đăng nhập với email `admin` hoặc `postgres` và mật khẩu `DuyLVD-dashboard`)
    * **Supabase API Gateway**: [http://localhost:8000](http://localhost:8000) (Điểm cuối để các ứng dụng bên ngoài tương tác API)

## 💡 Sử dụng Supabase làm Vector Database với n8n

Supabase với `pgvector` cho phép bạn xây dựng các ứng dụng AI như tìm kiếm ngữ nghĩa, hệ thống gợi ý, RAG (Retrieval-Augmented Generation), v.v.

1.  **Truy cập Supabase Studio**: Mở [http://localhost:3000](http://localhost:3000) và đăng nhập.
2.  **Kích hoạt Extension (nếu chưa có)**: Vào mục "Database" -> "Extensions", tìm "vector" và kích hoạt nó. (Trong cấu hình này, nó thường đã được kích hoạt sẵn).
3.  **Tạo Bảng Lưu Trữ Vector**: Mở SQL Editor ("SQL Editor" -> "New query") và chạy lệnh SQL sau để tạo bảng `documents` (ví dụ):

    ```sql
    -- Đảm bảo extension đã được kích hoạt
    CREATE EXTENSION IF NOT EXISTS vector;

    -- Tạo bảng để lưu trữ nội dung, metadata và vector embedding
    CREATE TABLE documents (
      id SERIAL PRIMARY KEY,
      content TEXT,          -- Nội dung gốc (ví dụ: đoạn văn bản)
      metadata JSONB,        -- Dữ liệu bổ sung (ví dụ: nguồn, ngày tạo)
      embedding VECTOR(384)  -- Cột lưu trữ vector. Điều chỉnh kích thước (384)
                             -- cho phù hợp với mô hình embedding bạn sử dụng.
    );

    -- (Tùy chọn nhưng khuyến nghị) Tạo index để tăng tốc độ tìm kiếm vector
    -- Chọn phương thức index phù hợp (ivfflat, hnsw) và hàm khoảng cách (vector_cosine_ops, vector_l2_ops, ...)
    -- Ví dụ sử dụng IVFFlat với cosine similarity:
    CREATE INDEX ON documents USING ivfflat (embedding vector_cosine_ops) WITH (lists = 100);
    -- Lưu ý: Tham số `lists` cần được điều chỉnh dựa trên số lượng bản ghi dự kiến.
    ```

4.  **Tương tác từ n8n**:
    * **Cách 1: Dùng Node PostgreSQL**:
        * Tạo một credential PostgreSQL trong n8n kết nối đến Supabase DB (sử dụng thông tin từ `n8n-ngrok/.env`).
        * Sử dụng node "Postgres" để thực thi các lệnh `INSERT` (lưu vector) hoặc `SELECT` (tìm kiếm vector).
    * **Cách 2: Dùng Node HTTP Request**:
        * Sử dụng node "HTTP Request" để gọi Supabase REST API (thông qua `http://supabase-kong:8000`). Bạn cần tạo các hàm RPC trong PostgreSQL để thực hiện việc chèn và tìm kiếm vector, sau đó gọi các hàm RPC này qua API. Cách này phức tạp hơn nhưng có thể linh hoạt hơn trong một số trường hợp.

5.  **Ví dụ SQL (Thực thi qua Node Postgres)**:
    * **Lưu Vector Embedding**:
        ```sql
        INSERT INTO documents (content, metadata, embedding)
        VALUES (
          'Đây là nội dung của tài liệu cần lưu trữ.',
          '{"source": "example.txt", "category": "documentation"}',
          '[0.1, 0.2, 0.3, ..., 0.384]'::vector -- Thay thế bằng vector embedding thực tế
        );
        ```
    * **Tìm kiếm Vector Tương tự (Similarity Search)**: Tìm 5 tài liệu gần nhất với vector truy vấn dựa trên cosine similarity.
        ```sql
        SELECT
          id,
          content,
          metadata,
          1 - (embedding <=> '[0.9, 0.8, 0.7, ..., 0.123]'::vector) AS similarity -- Tính cosine similarity
        FROM documents
        ORDER BY embedding <=> '[0.9, 0.8, 0.7, ..., 0.123]'::vector -- Sắp xếp theo khoảng cách cosine (nhỏ nhất là gần nhất)
        LIMIT 5;
        ```
        *(Lưu ý: `<=>` là toán tử tính khoảng cách cosine trong pgvector. `1 - distance` sẽ ra similarity)*

## ⚠️ Lưu ý Quan trọng

1.  **Mạng Docker**: Tất cả các dịch vụ (n8n, ngrok, redis, supabase-*) được kết nối chung vào một mạng Docker tùy chỉnh tên là `n8n-network` (hoặc tên tương tự được định nghĩa trong các file `docker-compose.yml`). Điều này cho phép chúng giao tiếp với nhau bằng tên service (ví dụ: `n8n` có thể gọi `supabase-db`, `supabase-kong`).
2.  **Dữ liệu Bền vững**: Các thư mục `data` (cho n8n, redis) và `volumes` (cho supabase) được mount từ máy host vào các container. Điều này đảm bảo rằng tất cả dữ liệu quan trọng (workflows, cấu hình, cơ sở dữ liệu, file lưu trữ) sẽ không bị mất khi các container được dừng, xóa hoặc khởi động lại.
3.  **Môi trường Windows**: Các script `start-all.bat` và `stop-all.bat` được viết cho môi trường Windows. Nếu sử dụng trên Linux hoặc macOS, bạn cần điều chỉnh các lệnh và đường dẫn cho phù hợp (ví dụ: sử dụng script shell `.sh`).
4.  **Cập nhật ngrok**: Domain miễn phí của ngrok có thể thay đổi hoặc hết hạn. Nếu URL ngrok ngừng hoạt động, bạn cần:
    * Kiểm tra tài khoản ngrok của bạn.
    * Cập nhật `NGROK_AUTHTOKEN` trong `n8n-ngrok/.env` nếu cần.
    * Cập nhật cấu hình domain trong `n8n-ngrok/ngrok.yml` nếu bạn sử dụng domain tĩnh và nó đã thay đổi.
    * Khởi động lại dịch vụ `n8n-ngrok`.
5.  **Tài nguyên**: Chạy nhiều dịch vụ Docker, đặc biệt là stack Supabase, có thể tiêu tốn khá nhiều tài nguyên hệ thống (RAM, CPU). Đảm bảo máy tính của bạn đủ mạnh và đã cấp phát đủ tài nguyên cho Docker Desktop.

## 📚 Tài liệu Tham khảo

* **n8n Docker Documentation**: [https://docs.n8n.io/hosting/installation/docker/](https://docs.n8n.io/hosting/installation/docker/)
* **ngrok Docker**: [https://github.com/ngrok/docker-ngrok](https://github.com/ngrok/docker-ngrok)
* **Supabase Self-Hosting (Docker)**: [https://supabase.com/docs/guides/self-hosting/docker](https://supabase.com/docs/guides/self-hosting/docker)
* **Supabase GitHub Discussions (Self-Hosting)**: [https://github.com/orgs/supabase/discussions/27467](https://github.com/orgs/supabase/discussions/27467)
* **pgvector Extension**: [https://github.com/pgvector/pgvector](https://github.com/pgvector/pgvector)

## 👤 Tác giả & Liên hệ

* **Tên**: Lương Vũ Đình Duy
* **Email**: [luongvudinhduy03@gmail.com](mailto:luongvudinhduy03@gmail.com)

---

Chúc bạn triển khai và sử dụng hệ thống thành công! 🎉
