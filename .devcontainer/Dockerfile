FROM ubuntu:22.04

# Cài đặt các thư viện hệ thống cần thiết
RUN apt-get update && apt-get install -y \
    curl git unzip xz-utils zip libglu1-mesa openjdk-17-jdk wget

# Tạo user để không chạy bằng root (tránh lỗi file permission)
user root
WORKDIR /home/developer

# Tải Flutter SDK
RUN git clone https://github.com/flutter/flutter.git -b stable /opt/flutter
ENV PATH="/opt/flutter/bin:/opt/flutter/bin/cache/dart-sdk/bin:${PATH}"

# Chạy doctor để kiểm tra
RUN flutter doctor