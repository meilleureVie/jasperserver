
# Deploy a webapp from github
- Install Flyctl
```
# install fly/cli
curl -L https://fly.io/install.sh | sh
launch new fly.io app
fly version
```
- Run fly **launch --no-deploy** from within the project source directory to create a new app and a fly.toml configuration file.
- Type **y** to when prompted to tweak settings and enter a name for the app. Adjust other settings, such as region, as needed. Then click `Confirm Settings`.
- Still in the project source directory, get a Fly API deploy token by running **fly tokens create deploy -x 999999h**. Copy the output, including the FlyV1 and space at the beginning.
- Go to your newly-created repository on `GitHub` and select `Settings`.
- Under `Secrets and variables`, select `Actions`, and then create a new repository secret called **FLY_API_TOKEN** with the value of the token.
- Back in your project source directory, create `.github/workflows/fly.yml` with these contents:
```
name: Fly Deploy
on:
  push:
    branches:
      - master    # change to main if needed
jobs:
  deploy:
    name: Deploy app
    runs-on: ubuntu-latest
    concurrency: deploy-group    # optional: ensure only one action runs at a time
    steps:
      - uses: actions/checkout@v4
      - uses: superfly/flyctl-actions/setup-flyctl@master
      - run: flyctl deploy --remote-only
        env:
          FLY_API_TOKEN: ${{ secrets.FLY_API_TOKEN }}
```
- Configure Environment Variables/Secrets (optional)

If your app needs some critical env. variables that can not be declared in `fly.toml`, declare them as following :
```
fly secrets set DB_PASSWORD="your_secure_password"
# fly ssh console -C "printenv"     # print all env. variables
```
- Commit your changes and push them up to GitHub. You should be pushing two new files: `fly.toml`, the Fly Launch configuration file, and `fly.yml`, the GitHub action file.
- Scale down to one node if needed :
```
fly scale count 1
# fly scale show    # show nodes
```

Read more at https://fly.io/docs/launch/continuous-deployment-with-github-actions/


# Deploy a database service using custom postgres image
- Prepare your Custom PostgreSQL Docker Image
```
FROM postgres:16-alpine
# Add any custom configurations or extensions here
COPY custom_init.sql /docker-entrypoint-initdb.d/
# Example: Install a specific extension
# RUN apk add --no-cache postgresql-contrib
```
- Launch new fly.io app
```
fly launch --name my-custom-postgres-app --no-deploy
```
- Create a persistent volume for your PostgreSQL data in the same region or choose your preferred region when prompted
```
fly volumes create pg_data --app my-custom-postgres-app --region <your-region> --size 10 # Adjust size as needed
```
- Configure Environment Variables/Secrets
```
fly secrets set POSTGRES_PASSWORD="your_secure_password" --app my-custom-postgres-app
```
- Update fly.toml
```
app = "my-custom-postgres-app"
primary_region = "<your-region>"

[build]
    dockerfile = "Dockerfile" # Path to your custom Dockerfile

[mounts]
    source="pg_data"
    destination="/var/lib/postgresql" # Standard PostgreSQL data directory

[[services]]
  protocol = 'tcp'
  internal_port = 5432
  auto_stop_machines = 'suspend'
  auto_start_machines = true
  min_machines_running = 0
  processes = ['app']

  [[services.ports]]
    port = 5432
    handlers = ['pg_tls']

[[vm]]
  memory = '1gb'
  cpu_kind = 'shared'
  cpus = 1
```
- Deploy Your App:
```
fly deploy --app my-custom-postgres-app
```
- Scale down to one node (optional)
```
fly scale count 1
```
- Connect to Your Database:
```
// Forward the server port `5432` to your local system
fly proxy 15432:5432 -a <postgres-app-name> 

// Then connect to localhost:15432
psql postgres://postgres:<password>@localhost:15432

// Connecting to database from fly cloud environnement
postgres://<username>:<password>@my-custom-postgres-app.internal:5432/<database-name>
```
Read more about `fly.toml` config at : \
https://fly.io/docs/reference/configuration/#the-services-sections \
https://fly.io/docs/networking/services/#postgres-tls-handler \
https://fly.io/docs/reference/configuration/#run-one-off-commands-before-releasing-a-deployment \
https://fly.io/docs/about/pricing/


# Deploy a database service using fly postgres image
- Create a new Fly Postgres app
```
fly postgres create
# fly pg create --name my-custom-postgres-app --image-ref flyio/postgres-standalone:17
```
- Connect to your Postgres database
```
fly postgres connect -a my-custom-postgres-app
```
- Forward the server port to your local system
```
fly proxy 5434:5432 -a my-custom-postgres-app
```
- Attach the database to another app
```
fly pg attach my-backend-app
```

Read more at : https://fly.io/docs/postgres/getting-started/create-pg-cluster/


# Troubleshooting
```
    flyctl ssh console                  # to connect to running app and execute sh cmd
    flyctl logs -a another-app-name     # to connect and stream logs when app is deploying
    flyctl status -a another-app-name

    # create a volume
    fly volumes create pg_data --app my-custom-postgres-app --region <your-region> --size 10

    # using volume snapshot
    fly volumes create jasper_webapps_dir --snapshot-id vs_7PpMJJ2m7eBMf9O5wlaeQ --size 1 -a my-app-name

    # destroying and recreate an app
    fly scale count 2
    fly volume destroy vol_name

    # update some machine capacity
    fly machine update -a my-app-name -i some-savvy-image --vm-cpus 2 --vm-memory 512 73d8d46dbee589
```