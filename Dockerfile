# Stage 1: Build the JAR
FROM eclipse-temurin:26-jdk-alpine AS builder
RUN apk add --no-cache maven
WORKDIR /app
COPY pom.xml .
RUN mvn dependency:go-offline -q
COPY src ./src
RUN mvn package -DskipTests -q

# Stage 2: Build a minimal custom JRE with jlink
FROM eclipse-temurin:26-jdk-alpine AS jre-builder
RUN $JAVA_HOME/bin/jlink \
    --add-modules java.base,java.desktop,java.instrument,java.management,java.management.rmi,java.naming,java.net.http,java.prefs,java.rmi,java.scripting,java.security.jgss,java.security.sasl,java.sql,java.xml,jdk.attach,jdk.crypto.cryptoki,jdk.crypto.ec,jdk.httpserver,jdk.management,jdk.naming.dns,jdk.unsupported \
    --strip-debug \
    --strip-java-debug-attributes \
    --no-man-pages \
    --no-header-files \
    --compress=2 \
    --output /custom-jre

# Stage 3: Minimal final image
FROM alpine:3.20
RUN apk add --no-cache tzdata
WORKDIR /app
COPY --from=jre-builder /custom-jre /opt/jre
COPY --from=builder /app/target/*.jar app.jar
ENV PATH="/opt/jre/bin:$PATH"
ARG BUILD_TIME=unknown
ARG GIT_COMMIT=unknown
ENV BUILD_TIME=${BUILD_TIME}
ENV GIT_COMMIT=${GIT_COMMIT}

EXPOSE 8080
ENTRYPOINT ["java", \
  "-XX:+UseContainerSupport", \
  "-XX:MaxRAMPercentage=75.0", \
  "-XX:InitialRAMPercentage=50.0", \
  "-XX:MaxMetaspaceSize=96m", \
  "-XX:+UseSerialGC", \
  "-Djava.security.egd=file:/dev/./urandom", \
  "-jar", "app.jar"]
