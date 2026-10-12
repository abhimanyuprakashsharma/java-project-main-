# Multi-stage Docker build for Trendify Java Web Application
FROM maven:3.9.9-eclipse-temurin-17 AS build
WORKDIR /app

# Copy dependency definition and source
COPY pom.xml .
COPY src ./src

# Build production WAR package
RUN mvn clean package -DskipTests

# Run with Apache Tomcat 11
FROM tomcat:11.0-jdk17-temurin

# Clean default Tomcat apps
RUN rm -rf /usr/local/tomcat/webapps/*

# Deploy application as ROOT so it opens directly at https://your-domain.com/
COPY --from=build /app/target/shopsphere.war /usr/local/tomcat/webapps/ROOT.war

EXPOSE 8080

CMD ["catalina.sh", "run"]
