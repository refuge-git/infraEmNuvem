FROM openjdk:21-jdk-slim
WORKDIR /app

COPY /app_loko.jar app.jar
COPY wait-for-mysql.sh wait-for-mysql.sh
RUN chmod +x wait-for-mysql.sh

# Instala MySQL client
RUN apt-get update && apt-get install -y default-mysql-client && rm -rf /var/lib/apt/lists/*

ENTRYPOINT ["./wait-for-mysql.sh", "mysql", "java", "-jar", "app.jar"]