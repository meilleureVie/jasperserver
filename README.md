# JasperReports Server CE Edition Docker Container

The Docker Image aims to quickly get up-and-running a JasperReports Server for a development environment.

[![](https://images.microbadger.com/badges/image/retriever/jasperserver.svg)](https://microbadger.com/images/retriever/jasperserver "Get your own image badge on microbadger.com")

## Start the Container

### Using Command Line

To start the JasperServer container you'll need to pass in 5 environment variables and link it to either a MySQL(DB_TYPE=mysql) or Postgres(DB_TYPE=postgresql) container.

E.g. `docker run -d --name jasperserver -e DB_TYPE=postgresql -e DB_HOST=db -e DB_PORT=5432 -e DB_USER=postgres -e DB_PASSWORD=****** -e DB_NAME=jasperserver --link jasperserver_db:db -p 8080:8080 chezgugu/jasperserver`

If you haven't got an existing MySQL or Postgres container then you can easily create one:
`docker run -d --name jasperserver_db -e POSTGRES_PASSWORD=****** postgres:14-alpine`
`docker run -d --name jasperserver_db -e MYSQL_ROOT_PASSWORD=****** mysql:8.4`

## Login to JasperReports Web

1. Go to URL http://${dockerHost}:8080/
2. Login using credentials: jasperadmin/jasperadmin


## Image Features
This image includes:
* JasperServer CE Edition version 8.2.0
* IBM DB2 JDBC driver version 4.19.26, Note: this jar had to be modified as per [exception-in-db2-jcc-driver-under-tomcat8](https://developer.ibm.com/answers/questions/308105/exception-in-db2-jcc-driver-under-tomcat8.html).
* MySQL JDBC driver version 8.4.0
* Waits for the database to start before connecting to it using [wait-for-it](https://github.com/vishnubob/wait-for-it) as recommended by [docker-compose documentation](https://docs.docker.com/compose/startup-order/).
* [Web Service Data Source plugin](https://community.jaspersoft.com/project/web-service-data-source) contributed by [@chiavegatto](https://github.com/chiavegatto)

## How to build this image
Use `docker build -t chezgugu/jasperserver .`

See comments in Dockerfile to speed up testing by not having to download the jasperserver release each time.

## Troubleshooting
If you are having problems starting the containers because of a MySQL error like "[ERROR] [FATAL] Innodb: Table flags are 0...", then you will need to delete the data_dir which contains the MySQL database and then recreate the containers. Please note that you will lose any data previously stored in the database.

## How to release a new image version

Since [changes-to-docker-hub-autobuilds](https://www.docker.com/blog/changes-to-docker-hub-autobuilds/) builds have to be done manually.

Steps to make a new official version of the image:

1. Push a new `git tag` using the naming convention `major.minor.iteration` where:
    * major and minor line up with the included version of jasperserver
    * iteration is incremented each time a change is done that isn't an upgrade of the included jasperserver version
2. Build the image locally for each tag e.g. `docker build -t chezgugu/jasperserver:8.2.0 -t chezgugu/jasperserver:latest .`
3. Login to dockerhub with account that has push privileges to retriever org (i.e. `docker login`)
4. Push image for each tag (e.g. `docker push retriever/jasperserver:8.2.0` and `docker push chezgugu/jasperserver:latest`)
5. Check images are on Docker Hub: [retriever/jaserpserver](https://hub.docker.com/r/chezgugu/jasperserver/)
6. Test new Docker Hub images by deleting local image e.g. `docker rmi chezgugu/jasperserver:8.2.0 chezgugu/jasperserver:latest` and re-downloading from Dockerhub and run up container e.g. `docker-compose up`. 
    * Note: ensure docker-compose.yml is pointing to right version and clear out local `datadir` to start fresh.

## How to clone the image project from github

1. Install git large file system
2. on linux use `git-lfs clone https://github.com/meilleureVie/jasperserver.git`
3. on windows use `git clone https://github.com/meilleureVie/jasperserver.git`
