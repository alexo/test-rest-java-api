# Test REST Java API

A minimal Spring Boot REST API for testing deployments across various cloud platforms. The goal is to explore free-tier hosting options for Java backend services and compare their setup complexity, deployment speed, and limitations.

## Endpoints

| Method | Path | Description |
|--------|------|-------------|
| GET | `/api/hello` | Returns a hello world message |
| GET | `/api/hello/{name}` | Returns a personalized greeting |
| GET | `/api/health` | Health check |
| GET | `/api/info` | Build info (timestamp and git commit) |

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
curl http://localhost:8080/api/health
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
| **Koyeb** | Starter plan from $0/month | No spin-down, but requires credit card |
| **Hetzner Cloud** | No free tier | From €3.29/month — IaaS, full VM control |

## Active Deployments

| Platform | URL | Status |
|----------|-----|--------|
| **Railway** | https://test-rest-java-api-production.up.railway.app | Active |
| **Render** | https://test-rest-java-api-latest.onrender.com | Active (spins down after 15min, deploys via GHCR) |

## Koyeb

**Status:** Skipped — credit card required even for the free tier.

Koyeb's Starter plan advertises $0/month for 1 nano instance (512MB RAM, 0.1 vCPU) with no spin-down, but account creation requires a valid credit card upfront. Pricing beyond the free nano instance:

| Resource | Rate |
|----------|------|
| Nano instance (512MB RAM, 0.1 vCPU) | Free (1 included) |
| Additional instances | From $5.61/month |
| Egress | $0.04 / GB (first 100GB free) |

The always-on free tier would make it an attractive option, but the credit card requirement is a barrier for a test/learn project.

---

## Hetzner Cloud

**Status:** Not attempted — no free tier, IaaS model requires more setup.

Hetzner is a German cloud provider offering bare-metal performance at very low prices. Unlike the PaaS platforms in this list, Hetzner provides raw VMs — you manage the OS, Docker, networking, and deployment pipeline yourself.

### Why consider it

- **Best price/performance ratio** among paid options
- **No artificial limits** — full VM with dedicated resources, no spin-down, no credit caps
- **EU-based** (Germany, Finland) — good for GDPR-sensitive workloads
- **One VM can host multiple services** — cost-effective if running several apps

### Instance types relevant for this app

| Instance | vCPU | RAM | Storage | Traffic | Price |
|----------|------|-----|---------|---------|-------|
| CAX11 (ARM) | 2 | 4 GB | 40 GB SSD | 20 TB | ~€3.29/month |
| CX22 (AMD) | 2 | 4 GB | 40 GB SSD | 20 TB | ~€3.79/month |
| CX11 (AMD) | 1 | 2 GB | 20 GB SSD | 20 TB | ~€3.29/month |

### Setup complexity

Significantly higher than PaaS options:
1. Create a Hetzner account and provision a VM
2. SSH into the VM, install Docker
3. Set up a reverse proxy (nginx/Caddy) for HTTPS
4. Configure firewall rules
5. Set up deployment — either manual (`docker pull` + `docker run`) or via GitHub Actions over SSH

No auto-deploy out of the box. A GitHub Actions workflow pushing over SSH would be needed for CI/CD.

### Cost analysis

For this app running 24/7 on a CAX11 (smallest ARM instance):
- **~€3.29/month** (~$3.50) flat rate — no surprises, no usage-based billing
- VM can host multiple services simultaneously, reducing effective per-service cost
- Cheapest option if running more than one backend service

### Verdict

Not suitable as a quick free-tier experiment, but the best value paid option if you need always-on reliability without per-usage billing surprises. Worth considering when graduating from free-tier testing to a stable low-cost hosting setup.

---

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

---

## Render Deployment

**Live URL:** https://test-rest-java-api-latest.onrender.com

### Setup

Deployed via Render dashboard using a pre-built Docker image from GitHub Container Registry (GHCR). A GitHub Actions workflow (`.github/workflows/deploy-render.yml`) builds the image on every push to `main`, pushes it to `ghcr.io/alexo/test-rest-java-api:latest`, then triggers a Render redeploy via a deploy hook.

This avoids building on Render's free tier, which has limited compute and can be slow or time out for Maven + Docker builds.

### Operations

**Deploy / Redeploy**
- Push to `main` branch — Render auto-deploys on every commit
- Or trigger manually from the Render dashboard: service → Manual Deploy → Deploy latest commit

**Stop the service**
- Dashboard → service → Settings → **Suspend Service** — stops the service without deleting it
- Or **Delete Service** for full removal

**Restart after suspending**
- Dashboard → service → **Resume Service**

**Check logs**
- Dashboard → service → **Logs** tab (live streaming)

### Behaviour

- **Spin-down:** The free tier spins down after **15 minutes of inactivity**
- **Cold start:** ~30 seconds for the first request after spin-down (JVM startup + Spring Boot init)
- **Auto-sleep:** Cannot be disabled on the free tier

### Cost Analysis

| Plan | Price | Notes |
|------|-------|-------|
| Free | $0 | 512MB RAM, 0.1 CPU, spins down after 15min inactivity |
| Starter | $7/month | 512MB RAM, always-on |
| Standard | $25/month | 2GB RAM, always-on |

**Free tier limits:**
- 750 hours/month of active runtime (enough for one always-on service, but free tier spins down anyway)
- Builds limited to 500 minutes/month
- No custom domains on free tier (only `.onrender.com` subdomain)

**Verdict:** Free tier is suitable for testing and low-traffic APIs where cold starts are acceptable. Upgrade to Starter ($7/month) for always-on without spin-down.
