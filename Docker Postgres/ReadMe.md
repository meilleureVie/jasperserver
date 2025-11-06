# Prepare your Custom PostgreSQL Docker Image:
```
FROM postgres:16-alpine
# Add any custom configurations or extensions here
COPY custom_init.sql /docker-entrypoint-initdb.d/
# Example: Install a specific extension
# RUN apk add --no-cache postgresql-contrib
```

# Install Flyctl:
```
# install fly/cli
# curl -L https://fly.io/install.sh | sh
# launch new fly.io app
fly launch --name my-custom-postgres-app --no-deploy
```

# Choose your preferred region when prompted.
```
fly volumes create pg_data --app my-custom-postgres-app --region <your-region> --size 10 # Adjust size as needed
```

# Configure Environment Variables/Secrets:
```
fly secrets set POSTGRES_PASSWORD="your_secure_password" --app my-custom-postgres-app
```

# Update fly.toml:
```
app = "my-custom-postgres-app"
primary_region = "<your-region>"

[build]
    dockerfile = "Dockerfile" # Path to your custom Dockerfile

[mounts]
    source="pg_data"
    destination="/var/lib/postgresql/data" # Standard PostgreSQL data directory

[http_service]
    internal_port = 5432 # Standard PostgreSQL port
    force_https = true
    auto_stop_machines = 'suspend'
    auto_start_machines = true
    min_machines_running = 0
```

# Deploy Your App:
```
fly deploy --app my-custom-postgres-app
```

# scale down to one node:
```
fly scale count 1
```

# Connect to Your Database:
```
postgres://<username>:<password>@my-custom-postgres-app.internal:5432/<database-name>
```
