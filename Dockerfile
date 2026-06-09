# ─────────────────────────────────────────────
# Stage 1 — Build (Maven + Java 17)
# ─────────────────────────────────────────────
FROM maven:3.9.6-eclipse-temurin-17 AS builder

WORKDIR /build

# Cache de dependências separado da compilação
COPY pom.xml .
RUN mvn dependency:go-offline -B --no-transfer-progress

COPY src ./src
RUN mvn clean package -DskipTests -B --no-transfer-progress

# ─────────────────────────────────────────────
# Stage 2 — Runtime (Eclipse Temurin 17 JRE)
# ─────────────────────────────────────────────
FROM eclipse-temurin:17-jre-alpine AS runtime

# Criar grupo e usuário não-root
RUN addgroup -S appgroup && adduser -S appuser -G appgroup

WORKDIR /app

# Copiar apenas o JAR gerado
COPY --from=builder /build/target/smartdisaster-1.0.0.jar app.jar

# Ajustar ownership
RUN chown appuser:appgroup /app/app.jar

# Variáveis de ambiente padrão (sobrescritas pelo docker-compose)
ENV SPRING_PROFILES_ACTIVE=docker
ENV SERVER_PORT=8080

# Executar como usuário não-root
USER appuser

EXPOSE 8080

ENTRYPOINT ["java", "-jar", "app.jar"]
