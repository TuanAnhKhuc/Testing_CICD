# Giai đoạn 1: Build
FROM mcr.microsoft.com/dotnet/sdk:9.0 AS build
WORKDIR /src

# Copy csproj và restore dependencies
COPY src/TodojsAspire.ApiService/TodojsAspire.ApiService.csproj ./TodojsAspire.ApiService/
COPY src/TodojsAspire.ServiceDefaults/TodojsAspire.ServiceDefaults.csproj ./TodojsAspire.ServiceDefaults/
RUN dotnet restore ./TodojsAspire.ApiService/TodojsAspire.ApiService.csproj

# Copy toàn bộ source
COPY src/TodojsAspire.ApiService/ ./TodojsAspire.ApiService/
COPY src/TodojsAspire.ServiceDefaults/ ./TodojsAspire.ServiceDefaults/

# Publish ứng dụng
WORKDIR /src/TodojsAspire.ApiService
RUN dotnet publish -c Release -o /app/publish

# Giai đoạn 2: Runtime
FROM mcr.microsoft.com/dotnet/aspnet:9.0
WORKDIR /app

# Bắt buộc chạy trên port 5000
ENV ASPNETCORE_URLS=http://+:5000

COPY --from=build /app/publish .
EXPOSE 5000

ENTRYPOINT ["dotnet", "TodojsAspire.ApiService.dll"]
