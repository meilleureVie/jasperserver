https://fly.io/docs/postgres/getting-started/create-pg-cluster/

# ################### Option 1 ##########################

# Install flyctl
curl -L https://fly.io/install.sh | sh

# Create a new Fly Postgres app
fly pg create --name jasperserver-db --image-ref flyio/postgres-standalone:13

# Attach the database to another app
fly pg attach jasperserver

# ################### Option 2 ##########################

# create fly database container with default database "postgres"
fly postgres create

# connect to your Postgres database
fly postgres connect -a jasperserver-db

# forward the server port to your local system
fly proxy 5434:5432 -a jasperserver-db
