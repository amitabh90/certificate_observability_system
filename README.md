# Certificate Observability System

A comprehensive certificate monitoring and observability system using Prometheus, Grafana, and Telegraf to track SSL/TLS certificate expiration and health across multiple applications.

## Architecture Overview

```
┌─────────────────────────────────────────────────────────────────┐
│                    Certificate Observability System             │
├─────────────────────────────────────────────────────────────────┤
│                                                                 │
│  ┌─────────────┐    ┌─────────────┐    ┌─────────────┐         │
│  │ Demo App 1  │    │ Demo App 2  │    │ Demo App 3  │ ...     │
│  │             │    │             │    │             │         │
│  │ Nginx+HTTPS │    │ Nginx+HTTPS │    │ Nginx+HTTPS │         │
│  │ :8443       │    │ :8443       │    │ :8443       │         │
│  │             │    │             │    │             │         │
│  │ Telegraf    │    │ Telegraf    │    │ Telegraf    │         │
│  │ :9273       │    │ :9273       │    │ :9273       │         │
│  └─────────────┘    └─────────────┘    └─────────────┘         │
│         │                   │                   │               │
│         └───────────────────┼───────────────────┘               │
│                             │                                   │
│                    ┌─────────▼──────────┐                      │
│                    │     Prometheus     │                      │
│                    │    Data Source     │                      │
│                    │      :9090         │                      │
│                    └─────────┬──────────┘                      │
│                              │                                 │
│                    ┌─────────▼──────────┐                      │
│                    │      Grafana       │                      │
│                    │   Visualization    │                      │
│                    │      :3000         │                      │
│                    └────────────────────┘                      │
│                                                                 │
└─────────────────────────────────────────────────────────────────┘
                    custom_monitoring_network
```

## Key Components

- **Demo Applications**: 4 containerized applications with HTTPS endpoints and self-signed certificates
- **Telegraf**: Collects certificate metrics from each application (expiration dates, validity, etc.)
- **Prometheus**: Scrapes and stores metrics from all Telegraf instances
- **Grafana**: Provides visualization and alerting for certificate monitoring
- **Terraform**: Infrastructure as Code for Grafana data source provisioning

## Prerequisites

- Docker and Docker Compose
- Git
- Terraform (optional, for infrastructure provisioning)
- curl and jq (for testing)

## Quick Start Deployment

### Step 1: Clone the Repository

```bash
git clone <repository-url>
cd certificate_observability_system
```

### Step 2: Start the Monitoring Stack

```bash
# Start Prometheus and Grafana
docker-compose up -d
```

### Step 3: Deploy Demo Applications

```bash
# Navigate to demo applications directory
cd demo-application-lab

# Start the demo applications
docker-compose up -d --build
```

### Step 4: Verify Deployment

Check that all services are running:
```bash
docker ps
```

You should see containers for:
- `prometheus`
- `grafana`
- `demo-app-1`, `demo-app-2`, `demo-app-3`, `demo-app-4`

### Step 5: Access the Services

- **Prometheus**: http://localhost:9090
- **Grafana**: http://localhost:3000
- **Demo Apps**: 
  - App 1: https://localhost:8441
  - App 2: https://localhost:8442
  - App 3: https://localhost:8443
  - App 4: https://localhost:8444

## Detailed Deployment Steps

### 1. Infrastructure Setup

#### Option A: Using Docker Compose (Recommended)

Start the core monitoring infrastructure:

```bash
# From project root
docker-compose up -d prometheus grafana
```

#### Option B: Using Terraform (Advanced)

```bash
cd terraform
terraform init
terraform plan
terraform apply
```

### 2. Deploy Demo Applications

```bash
cd demo-application-lab
docker-compose up -d --build
```

This will:
- Build Docker images for 4 demo applications
- Generate self-signed certificates for each app
- Start Nginx with HTTPS on different ports
- Configure Telegraf to collect certificate metrics
- Connect all applications to the monitoring network

### 3. Configure Prometheus Data Sources

The system automatically configures Prometheus to scrape:
- Prometheus self-metrics (job: `prometheus`)
- Demo application metrics (job: `demo-applications`)

### 4. Verification Steps

#### Check Prometheus Targets

```bash
curl -s http://localhost:9090/api/v1/targets | jq '.data.activeTargets[] | {job: .labels.job, instance: .labels.instance, health: .health}'
```

All targets should show `"health": "up"`.

#### Query Certificate Metrics

```bash
# Check certificate expiration
curl -s 'http://localhost:9090/api/v1/query?query=x509_cert_expiry' | jq '.data.result[]'

# Check certificate age
curl -s 'http://localhost:9090/api/v1/query?query=x509_cert_age' | jq '.data.result[]'
```

#### Access Grafana

1. Navigate to http://localhost:3000
2. Default credentials: `admin` / `admin`
3. Configure Prometheus data source: `http://prometheus:9090`
4. Import certificate monitoring dashboards

## Available Metrics

The system collects the following certificate-related metrics:

- `x509_cert_expiry` - Seconds until certificate expires
- `x509_cert_age` - Certificate age in seconds
- `x509_cert_startdate` - Certificate start date (Unix timestamp)
- `x509_cert_enddate` - Certificate end date (Unix timestamp)
- `x509_cert_verification_code` - Certificate verification status

## Network Configuration

All services communicate via the `custom_monitoring_network` Docker network:

- **Network Name**: `custom_monitoring_network`
- **Driver**: bridge
- **Services Connected**: prometheus, grafana, demo-app-1, demo-app-2, demo-app-3, demo-app-4

## Port Mapping

| Service | Internal Port | External Port | Purpose |
|---------|---------------|---------------|---------|
| Prometheus | 9090 | 9090 | Web UI and API |
| Grafana | 3000 | 3000 | Web UI |
| Demo App 1 | 8443, 9273 | 8441, 9271 | HTTPS, Metrics |
| Demo App 2 | 8443, 9273 | 8442, 9272 | HTTPS, Metrics |
| Demo App 3 | 8443, 9273 | 8443, 9273 | HTTPS, Metrics |
| Demo App 4 | 8443, 9273 | 8444, 9274 | HTTPS, Metrics |

## Troubleshooting

### Common Issues

1. **Targets showing as 'down' in Prometheus**:
   - Verify all containers are on the same network
   - Check container logs: `docker logs <container-name>`

2. **Certificate metrics not appearing**:
   - Ensure Telegraf configuration includes x509_cert input plugin
   - Verify certificate paths in Telegraf config

3. **Grafana can't connect to Prometheus**:
   - Use `http://prometheus:9090` as data source URL
   - Ensure both containers are on `custom_monitoring_network`

### Useful Commands

```bash
# View logs
docker logs prometheus
docker logs grafana
docker logs demo-app-1

# Restart services
docker-compose restart

# Rebuild demo applications
cd demo-application-lab
docker-compose up -d --build --force-recreate

# Check network connectivity
docker network inspect custom_monitoring_network
```

## Development and Customization

### Adding New Applications

1. Add new service to `demo-application-lab/docker-compose.yml`
2. Update Prometheus configuration in `prometheus/prometheus.yml`
3. Add scrape target for new application

### Custom Certificate Paths

Modify `telegraf.conf` to monitor certificates in different locations:

```toml
[[inputs.x509_cert]]
  sources = ["/path/to/your/certificate.pem"]
```

## Security Considerations

- Demo applications use self-signed certificates (for testing only)
- In production, use proper CA-signed certificates
- Configure Grafana authentication and HTTPS
- Implement proper network security and firewall rules
- Use Docker secrets for sensitive configuration

## Contributing

1. Fork the repository
2. Create a feature branch
3. Make your changes
4. Test the deployment
5. Submit a pull request

## License

See [LICENSE](LICENSE) file for details.
