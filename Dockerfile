# ─────────────────────────────────────────────
# Stage 1 — Build (Maven + Java 17)
# ─────────────────────────────────────────────
FROM maven:3.9.6-eclipse-temurin-17 AS builder

WORKDIR /build


COPY pom.xml .
RUN mvn dependency:go-offline -B --no-transfer-progress

COPY src ./src
RUN mvn clean package -DskipTests -B --no-transfer-progress


FROM eclipse-temurin:17-jre-alpine AS runtime


RUN addgroup -S appgroup && adduser -S appuser -G appgroup

WORKDIR /app


COPY --from=builder /build/target/smartdisaster-1.0.0.jar app.jar


RUN chown appuser:appgroup /app/app.jar


ENV SPRING_PROFILES_ACTIVE=docker
ENV SERVER_PORT=8080


USER appuser

EXPOSE 8080

ENTRYPOINT ["java", "-jar", "app.jar"]
