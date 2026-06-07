FROM gradle:8-jdk21 AS builder
WORKDIR /app
COPY . .
RUN gradle clean build -x test --no-daemon

FROM eclipse-temurin:21-jre-alpine
RUN apk add --no-cache curl
WORKDIR /app
COPY --from=builder /app/build/libs/sampleapp-0.0.1-SNAPSHOT.jar app.jar
EXPOSE 8090

HEALTHCHECK --interval=30s --timeout=10s --retries=3 --start-period=180s \
  CMD curl -fsS http://localhost:8090/actuator/health/liveness || exit 1

ENTRYPOINT ["java", "-jar", "app.jar"]
