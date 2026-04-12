# Test REST Java API

A minimal Spring Boot REST API for testing deployments across various cloud platforms. The goal is to explore free-tier hosting options for Java backend services and compare their setup complexity, deployment speed, and limitations.

## Endpoints

| Method | Path | Description |
|--------|------|-------------|
| GET | `/api/hello` | Returns a hello world message |
| GET | `/api/hello/{name}` | Returns a personalized greeting |
| GET | `/actuator/health` | Spring health check |

## Running Locally

### Prerequisites

- Java 17+
- Maven 3.9+ (or Docker)

### Option 1: Maven

```bash
mvn spring-boot:run
```

### Option 2: Maven build + run JAR

```bash
mvn package -DskipTests
java -jar target/test-rest-java-api-0.0.1-SNAPSHOT.jar
```

### Option 3: Docker

```bash
docker build -t test-rest-java-api .
docker run -p 8080:8080 test-rest-java-api
```

The API will be available at `http://localhost:8080`.

### Quick test

```bash
curl http://localhost:8080/api/hello
curl http://localhost:8080/api/hello/Alex
curl http://localhost:8080/actuator/health
```

## Deployment Targets

The app is packaged as a Docker image (multi-stage build, JRE-only final image) making it portable across any container-based platform. The goal is to deploy it on multiple free-tier platforms and compare:

- Setup complexity
- Auto-deploy support
- Cold start behaviour
- Free tier limitations (memory, CPU, sleep/spin-down)

### Planned Platforms

| Platform | Free Tier | Notes |
|----------|-----------|-------|
| **Render** | 1 web service, spins down after 15min | Simple Docker deploy |
| **Railway** | ~$5 credits/month | Already set up for static site |
| **Fly.io** | 3 shared VMs, 256MB RAM | Great DX, easy Docker deploy |
| **Oracle Cloud** | 2 ARM VMs, 24GB RAM total | Most generous always-free tier |
| **Google Cloud Run** | 2M requests/month | Scales to zero |
| **Azure Container Apps** | 180k vCPU-seconds/month | Already have account |
| **Koyeb** | 1 nano service, 512MB RAM | No spin-down on free tier |

## Active Deployments

_(To be updated as platforms are deployed)_
