# Giai đoạn 1: Build
FROM mcr.microsoft.com/dotnet/sdk:9.0 AS build
WORKDIR /src

# Copy các tệp dự án và restore dependencies trước
# Điều này tận dụng Docker layer caching, giúp build nhanh hơn ở các lần sau
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