FROM postgres:14-alpine
ENV TZ="America/Montreal"

# Add any custom configurations (e.g., custom postgresql.conf)
# COPY postgresql.conf /etc/postgresql/postgresql.conf

# Install any necessary extensions (example: pg_cron)
# RUN apk add --no-cache postgresql-contrib \
#     && echo "shared_preload_libraries = 'pg_cron'" >> /etc/postgresql/postgresql.conf \
#     && echo "cron.database_name = 'your_database_name'" >> /etc/postgresql/postgresql.conf

# Add any custom scripts or initialization files
# COPY init.sql /docker-entrypoint-initdb.d/
