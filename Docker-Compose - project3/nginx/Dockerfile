FROM nginx

LABEL Project="web-app"
LABEL Environment = "prod"
LABEL Owner       = "Shreyash"
LABEL Team        = "Devops"
LABEL CostCenter  = "Ops"
LABEL APP     = "nginx"

RUN rm -rf /etc/nginx/conf.d/default.conf
COPY ./nginx.conf /etc/nginx/conf.d/vproapp.conf
