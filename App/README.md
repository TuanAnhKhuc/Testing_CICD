# Hướng Dẫn Toàn Diện cho Dự Án TodojsAspire

Tài liệu này tổng hợp các bước để thiết lập, di chuyển cơ sở dữ liệu và containerize ứng dụng TodojsAspire.

## 1\. Cấu Trúc Dự Án

Dự án được tổ chức theo cấu trúc full-stack hiện đại, tách biệt rõ ràng giữa frontend, backend và các thành phần điều phối.

```
todojsaspire/
├── src/
│   ├── todo-frontend/              # Ứng dụng Frontend (React + Vite)
│   │   ├── Dockerfile              # Định nghĩa container cho frontend
│   │   ├── nginx.conf              # Cấu hình Nginx để phục vụ app và proxy API
│   │   ├── package.json            # Quản lý các dependency của Node.js
│   │   └── src/                    # Mã nguồn của ứng dụng React
│   │       └── components/         # Các component React (TodoList, TodoItem)
│   │
│   ├── TodojsAspire.ApiService/    # Backend API Service (.NET)
│   │   ├── Dockerfile              # Định nghĩa container cho backend
│   │   ├── Program.cs              # Điểm khởi chạy của API, đăng ký dịch vụ
│   │   ├── TodoEndpoints.cs        # Định nghĩa các API endpoint (/Todo, /Todo/{id}, ...)
│   │   ├── TodoDbContext.cs        # Định nghĩa DB context cho Entity Framework
│   │   └── Todo.cs                 # Model (thực thể) cho một công việc
│   │
│   ├── TodojsAspire.AppHost/       # .NET Aspire AppHost
│   │   └── AppHost.cs              # Điều phối việc khởi chạy các service khi phát triển local
│   │
│   ├── TodojsAspire.ServiceDefaults/ # Project chứa các cấu hình chung
│   │
│   └── TodojsAspire.sln            # Tệp solution của .NET
│
├── docker-compose.yml              # Định nghĩa và chạy ứng dụng đa container
└── README.md                       # Tài liệu hướng dẫn
```

### Giải thích chi tiết:

  - **`src/todo-frontend/`**: Chứa toàn bộ mã nguồn cho phần giao diện người dùng.
      - `Dockerfile` & `nginx.conf`: Phục vụ việc đóng gói ứng dụng React vào một container Nginx, giúp tối ưu hóa việc phục vụ các tệp tĩnh và hoạt động như một reverse proxy cho API.
  - **`src/TodojsAspire.ApiService/`**: Chứa logic nghiệp vụ của backend.
      - `Program.cs`: Nơi cấu hình pipeline của ứng dụng, kết nối cơ sở dữ liệu và đăng ký các endpoint.
      - `TodoEndpoints.cs`: Tách biệt logic định nghĩa các endpoint (GET, POST, DELETE...) ra khỏi `Program.cs`, giúp mã nguồn gọn gàng hơn.
  - **`src/TodojsAspire.AppHost/`**: "Nhạc trưởng" của .NET Aspire. Tệp `AppHost.cs` định nghĩa các tài nguyên (backend, frontend, database) và cách chúng kết nối với nhau trong môi trường phát triển local. Đây là project bạn chạy để khởi động toàn bộ hệ thống.
  - **`docker-compose.yml`**: Dùng để định nghĩa và chạy ứng dụng trong môi trường container. Nó thay thế vai trò của `AppHost` khi bạn muốn triển khai ứng dụng một cách độc lập, ví dụ như trên server.

## 2\. Yêu Cầu Cần Có

  - .NET 9 SDK (hoặc phiên bản tương thích)
  - Node.js (v18+)
  - Docker và Docker Compose
  - Công cụ dòng lệnh Entity Framework Core. Nếu chưa có, cài đặt bằng lệnh:
    ```bash
    dotnet tool install --global dotnet-ef
    ```

## 3\. Di Chuyển Cơ Sở Dữ Liệu từ SQLite sang PostgreSQL

Đây là các bước để chuyển đổi cơ sở dữ liệu cho ứng dụng khi chạy local với `.NET Aspire`.

#### Bước 1: Thêm các gói NuGet cần thiết

```bash
# Thêm gói EF Core Provider cho PostgreSQL vào ApiService
dotnet add src/TodojsAspire.ApiService/TodojsAspire.ApiService.csproj package Npgsql.EntityFrameworkCore.PostgreSQL

# Thêm gói tích hợp Aspire cho PostgreSQL EF Core vào ApiService
dotnet add src/TodojsAspire.ApiService/TodojsAspire.ApiService.csproj package Aspire.Npgsql.EntityFrameworkCore.PostgreSQL

# Thêm gói hosting Aspire cho PostgreSQL vào AppHost
dotnet add src/TodojsAspire.AppHost/TodojsAspire.AppHost.csproj package Aspire.Hosting.PostgreSQL
```

#### Bước 2: Cập nhật mã nguồn

1.  **Trong `src/TodojsAspire.AppHost/AppHost.cs`:**
    Thay thế `AddSqlite` bằng `AddPostgres`.

    ```csharp
    // Thay thế dòng này:
    // var db = builder.AddSqlite("db").WithSqliteWeb();

    // Bằng dòng này:
    var db = builder.AddPostgres("db").WithPgAdmin();
    ```

2.  **Trong `src/TodojsAspire.ApiService/Program.cs`:**
    Thay thế `AddSqliteDbContext` và cấu hình thêm `CommandTimeout` để tránh lỗi timeout khi database khởi động.

    ```csharp
    // Thêm using ở đầu file nếu chưa có
    using Microsoft.EntityFrameworkCore;

    // Thay thế dòng này:
    // builder.AddSqliteDbContext<TodoDbContext>("db");

    // Bằng đoạn code sau:
    builder.AddNpgsqlDbContext<TodoDbContext>("db", 
        configureDbContextOptions: options => 
        {
            options.UseNpgsql(npgsqlOptions => 
            {
                npgsqlOptions.CommandTimeout(60); // Tăng thời gian chờ lên 60s
            });
        });
    ```

#### Bước 3: Tạo Migration mới

1.  **Xóa migration cũ:** Xóa thủ công thư mục `src/TodojsAspire.ApiService/Migrations` để đảm bảo sạch sẽ.
2.  **Tạo migration mới cho PostgreSQL:**
    ```bash
    dotnet ef migrations add InitialPostgresCreate -p src/TodojsAspire.ApiService -s src/TodojsAspire.ApiService
    ```

#### Bước 4: Chạy ứng dụng với Aspire

```bash
dotnet run --project src/TodojsAspire.AppHost
```

Lệnh này sẽ khởi động tất cả các dịch vụ và tự động áp dụng migration vào database PostgreSQL.

## 4\. Containerize và Chạy với Docker Compose

Các `Dockerfile` đã được cung cấp sẵn để đóng gói frontend và backend. Chúng ta sẽ sử dụng `docker-compose.yml` để điều phối chúng.

#### Bước 1: Tối ưu hóa Dockerfile cho ApiService

Để quá trình build nhanh và ổn định hơn, hãy thay thế nội dung tệp `src/TodojsAspire.ApiService/Dockerfile` bằng nội dung sau:

```dockerfile
# Giai đoạn 1: Build
FROM mcr.microsoft.com/dotnet/sdk:9.0 AS build
WORKDIR /src

# Copy các tệp dự án và restore dependencies trước
COPY src/TodojsAspire.ApiService/TodojsAspire.ApiService.csproj ./TodojsAspire.ApiService/
COPY src/TodojsAspire.ServiceDefaults/TodojsAspire.ServiceDefaults.csproj ./TodojsAspire.ServiceDefaults/
RUN dotnet restore ./TodojsAspire.ApiService/TodojsAspire.ApiService.csproj

# Copy toàn bộ source code của các project liên quan
COPY src/TodojsAspire.ApiService/ ./TodojsAspire.ApiService/
COPY src/TodojsAspire.ServiceDefaults/ ./TodojsAspire.ServiceDefaults/

# Publish ứng dụng
WORKDIR /src/TodojsAspire.ApiService
RUN dotnet publish -c Release -o /app/publish

# Giai đoạn 2: Final image, chỉ chứa runtime
FROM mcr.microsoft.com/dotnet/aspnet:9.0
WORKDIR /app
COPY --from=build /app/publish .
EXPOSE 8080
ENTRYPOINT ["dotnet", "TodojsAspire.ApiService.dll"]
```

#### Bước 2: Cập nhật `docker-compose.yml`

Sử dụng tệp `docker-compose.yml` dưới đây. Nó đã được cập nhật để dùng PostgreSQL và thêm `healthcheck` để tránh lỗi race condition khi khởi động.

```yaml
services:
  # Dịch vụ Backend API
  apiservice:
    build:
      context: .
      dockerfile: src/TodojsAspire.ApiService/Dockerfile
    container_name: todo_api
    ports:
      - "8081:8080"
    environment:
      - ConnectionStrings__db=Host=postgres_db;Database=tododb;Username=user;Password=password
    depends_on:
      postgres_db:
        condition: service_healthy

  # Dịch vụ Frontend
  frontend:
    build:
      context: src/todo-frontend
      dockerfile: Dockerfile
    container_name: todo_frontend
    ports:
      - "8080:80"
    depends_on:
      - apiservice

  # Dịch vụ PostgreSQL
  postgres_db:
    image: postgres
    container_name: postgres_db
    environment:
      POSTGRES_DB: tododb
      POSTGRES_USER: user
      POSTGRES_PASSWORD: password
    volumes:
      - postgres_data:/var/lib/postgresql/data
    ports:
      - "5433:5432" # Sử dụng cổng 5433 trên máy host để tránh xung đột
    healthcheck:
      test: ["CMD-SHELL", "pg_isready -U user -d tododb"]
      interval: 5s
      timeout: 5s
      retries: 5

volumes:
  postgres_data:
```

#### Bước 3: Khởi chạy ứng dụng

```bash
# Dừng và xóa các container cũ (nếu có)
docker compose down

# Build và khởi chạy toàn bộ ứng dụng
docker compose up --build
```

Sau khi hoàn tất, bạn có thể truy cập ứng dụng tại: **[http://localhost:8080](https://www.google.com/search?q=http://localhost:8080)**

## 5\. Hướng Dẫn Xử Lý Lỗi Thường Gặp

  - **Lỗi `dotnet-ef does not exist`:**

      - **Nguyên nhân:** Chưa cài đặt công cụ EF Core.
      - **Giải pháp:** `dotnet tool install --global dotnet-ef`

  - **Lỗi `Detected package downgrade` (NU1605):**

      - **Nguyên nhân:** Các gói NuGet liên quan (ví dụ: `Microsoft.EntityFrameworkCore.*`) không cùng phiên bản.
      - **Giải pháp:** Chỉnh sửa tệp `.csproj` để tất cả các gói liên quan có cùng phiên bản.

  - **Lỗi `'9.0.' is not a valid version string`:**

      - **Nguyên nhân:** Lỗi cú pháp khi sửa phiên bản trong tệp `.csproj`.
      - **Giải pháp:** Kiểm tra và sửa lại, ví dụ `9.0.` thành `9.0.7`.

  - **Lỗi `address already in use` khi chạy Docker:**

      - **Nguyên nhân:** Cổng trên máy host đã bị một ứng dụng khác chiếm (thường là một bản PostgreSQL cài trực tiếp trên máy).
      - **Giải pháp:** Thay đổi cổng trong `docker-compose.yml` (ví dụ: `"5433:5432"`) hoặc dừng dịch vụ đang chiếm cổng.

  - **Lỗi `Connection refused` hoặc `Timeout` khi API kết nối Database lúc khởi động:**

      - **Nguyên nhân:** "Race condition" - API service khởi động và kết nối trước khi database sẵn sàng.
      - **Giải pháp:** Thêm `healthcheck` vào dịch vụ database và `condition: service_healthy` vào `depends_on` của API service trong `docker-compose.yml`.