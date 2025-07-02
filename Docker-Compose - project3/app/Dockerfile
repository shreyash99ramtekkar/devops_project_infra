#Build
FROM maven as BUILD_IMAGE
RUN git clone https://github.com/hkhcoder/vprofile-project.git
RUN cd vprofile-project && git checkout containers && mvn clean install 
RUN ls /vprofile-project/target

FROM tomcat:10-jdk17
LABEL Project="web-app"
LABEL Environment = "prod"
LABEL Owner       = "Shreyash"
LABEL Team        = "Devops"
LABEL CostCenter  = "Ops"

RUN rm -rf /usr/local/tomcat/webapps/*

COPY --from=BUILD_IMAGE /vprofile-project/target/vprofile-v2.war /usr/local/tomcat/webapps/ROOT.war


EXPOSE 8080

CMD ["catalina.sh", "run"]