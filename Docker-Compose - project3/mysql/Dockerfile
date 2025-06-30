FROM mysql:8.0.42

LABEL Project="web-app"
LABEL Environment = "prod"
LABEL Owner       = "Shreyash"
LABEL Team        = "Devops"
LABEL CostCenter  = "Ops"
LABEL APP     = "mysql"

ENV MYSQL_DATABASE="accounts"
ENV MYSQL_ROOT_PASSWORD="qwerty123"

COPY ./db_backup.sql /docker-entrypoint-initdb.d/db_backup.sql


