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

- Java 26+ (Spring Boot 4.0)
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

| Platform | URL | Status |
|----------|-----|--------|
| **Railway** | https://test-rest-java-api-production.up.railway.app | Active |

## Railway Deployment

**Live URL:** https://test-rest-java-api-production.up.railway.app

### Setup

Deployed via Railway dashboard connecting directly to the GitHub repository. Railway detects the `Dockerfile` automatically and builds/runs the image on every push to `main`.

### Operations

**Deploy / Redeploy**
- Push to `main` branch — Railway auto-deploys on every commit
- Or trigger manually from the Railway dashboard: service → Deployments → Redeploy

**Stop the service**
- Dashboard → service → Settings → Danger zone → **Delete service**
- Alternatively, use the Railway CLI: `railway down` (removes the deployment but keeps config)

**Restart after stopping**
- If deleted: recreate the service in the dashboard and reconnect to the GitHub repo
- If using CLI: `railway up` to redeploy from local, or push a new commit to trigger auto-deploy

**Check logs**
- Dashboard → service → Deployments → click the active deployment → Logs
- Or via CLI: `railway logs`

### Cost Analysis

Railway charges based on actual resource usage (RAM + CPU per minute).

| Resource | Rate |
|----------|------|
| RAM | $0.000231 / GB / minute |
| CPU | $0.000463 / vCPU / minute |
| Egress | $0.10 / GB |

**Estimated monthly cost for this app (24/7):**

| Scenario | RAM usage | Estimated cost |
|----------|-----------|----------------|
| Idle / low traffic | ~150 MB | ~$1.50/month |
| Moderate traffic | ~200 MB | ~$2.00/month |
| 512 MB allocated | 512 MB | ~$5.00/month |

**Railway Hobby plan** costs $5/month and includes $5 in usage credits — so the app can run continuously and stay within the included credits depending on actual allocation.

**Free trial:** $5 one-time credit (no card required), covering roughly 1–2 weeks of continuous running.

**Cost-saving tip:** Delete the service when not actively testing. With GitHub auto-deploy, redeployment takes ~2–3 minutes on the next push.
