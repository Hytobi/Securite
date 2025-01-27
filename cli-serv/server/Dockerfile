FROM openjdk:21
WORKDIR /app
COPY ./src /app/src
COPY ./keystore /app/keystore
RUN javac src/*.java -d /app
CMD ["java", "-cp", "/app", "Server"]
