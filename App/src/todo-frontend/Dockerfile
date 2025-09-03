# Giai đoạn 1: Build ứng dụng React
# Sử dụng Node.js image (phiên bản Alpine cho nhẹ)
FROM node:20-alpine AS build
WORKDIR /app

# Chỉ Copy package.json để npm tự phân giải dependencies cho môi trường Linux
COPY package.json ./
RUN npm install

# Copy toàn bộ source code và build
COPY . .
RUN npm run build

# Giai đoạn 2: Phục vụ các file tĩnh bằng Nginx
# Sử dụng Nginx image nhẹ
FROM nginx:stable-alpine AS final

# Copy các file tĩnh đã được build từ giai đoạn 1 vào thư mục phục vụ của Nginx
COPY --from=build /app/dist /usr/share/nginx/html

# Copy file cấu hình Nginx
COPY nginx.conf /etc/nginx/conf.d/default.conf

# Expose port 80
EXPOSE 80

# Lệnh để khởi động Nginx
CMD ["nginx", "-g", "daemon off;"]