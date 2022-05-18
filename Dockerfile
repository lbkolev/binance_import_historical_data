FROM postgres
ENV POSTGRES_USER binance
ENV POSTGRES_DB binance
COPY schema.sql /docker-entrypoint-initdb.d/
