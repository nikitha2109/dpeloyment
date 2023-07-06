FROM maven:3.8.4-openjdk-8-slim AS maven_build


WORKDIR /app

COPY pom.xml .

# Resolve Maven dependencies (this step can be cached if the pom.xml hasn't changed)
RUN mvn dependency:go-offline

# Copy the source code
COPY src ./src

# Build the application
RUN mvn package -DskipTests

# Create a final lightweight image
FROM openjdk:8-jre-slim

# Set the working directory
WORKDIR /app

# Copy the built JAR file from the Maven build stage
COPY --from=maven_build /app/target/sample-1.0.3.jar .

# Set the entry point to run the application
CMD ["java", "-jar", "sample-1.0.3.jar"]
