#!/bin/bash
set -e

# apply default values for env variables
#DB_HOST=${DB_HOST:-DEFAULT_VALE}
#DB_PORT=${DB_PORT:-DEFAULT_VALE}
#DB_USER=${DB_USER:-DEFAULT_VALE}
#DB_PASSWORD=${DB_PASSWORD:-DEFAULT_VALE}
#DB_TYPE=${DB_TYPE:-DEFAULT_VALE}
DB_NAME=${DB_NAME:-"jasperserver"}

# wait upto 30 seconds for the database to start before connecting
/wait-for-it.sh $DB_HOST:$DB_PORT -t 30

# required to skip interactive prompt when creating keystore in 7.5.0+
# see https://community.jaspersoft.com/questions/1155841/docker-install-75-failing-create-ks-interactive-prompt.
export BUILDOMATIC_MODE=script

# check if we need to bootstrap the JasperServer
if [ -f "/.do_deploy_jasperserver" ]; then
    pushd /usr/src/jasperreports-server/buildomatic
    
    # echo "host: $DB_HOST"
    # echo "port: $DB_PORT"
    # echo "user: $DB_USER"
    # echo "password: $DB_PASSWORD"
    # echo "db: $DB_NAME"
    
    # Use provided configuration templates
    # Note: only works for Postgres or MySQL
    cp sample_conf/${DB_TYPE}_master.properties default_master.properties
    
    # tell the bootstrap script where to deploy the war file to
    sed -i -e "s|^appServerDir.*$|appServerDir = $CATALINA_HOME|g" default_master.properties
    
    # set all the database settings
    DB_PASSWORD=$(sed -e 's/[&\\/]/\\&/g; s/$/\\/' -e '$s/\\$//' <<<"$DB_PASSWORD")
    sed -i -e "s|^dbHost.*$|dbHost=$DB_HOST|g; s|^# dbPort.*$|dbPort=$DB_PORT|g; s|^dbUsername.*$|dbUsername=$DB_USER|g; s|^dbPassword.*$|dbPassword=$DB_PASSWORD|g; s|^# js\.dbName.*$|js.dbName=$DB_NAME|g" default_master.properties
    
    # rename the application war so that it can be served as the default tomcat web application
    sed -i -e "s|^# webAppNameCE.*$|webAppNameCE = ROOT|g" default_master.properties

    # run the minimum bootstrap script to initial the JasperServer
    ./js-ant create-js-db || true #create database and skip it if database already exists
    ./js-ant init-js-db-ce 
    ./js-ant import-minimal-ce 
    ./js-ant deploy-webapp-ce

    # bootstrap was successful, delete file so we don't bootstrap on subsequent restarts
    rm /.do_deploy_jasperserver

fi

# run Tomcat to start JasperServer webapp
catalina.sh run
