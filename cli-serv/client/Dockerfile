FROM openjdk:21
WORKDIR /app
COPY ./src /app/src
COPY ./truststore /app/truststore
RUN javac src/*.java -d /app
CMD ["java", "-cp", "/app", "Client"]
